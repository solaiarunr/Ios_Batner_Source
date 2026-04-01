//
//  Extension.swift
//  FilterCameraModel
//
//  Created by HTS on 30/08/20.
//  Copyright © 2020 HitaSoft. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import AVKit

import ImageIO
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

extension AVAsset {

    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    completion(nil)
                }
            })
        }
    }
    //Qwerty
    func generateGif(completion: @escaping (CGImage?, String?) -> Void) {
        guard let reader = try? AVAssetReader(asset: self) else {
            return
        }

        guard let videoTrack = self.tracks(withMediaType: .video).first else {
            return
        }

        let videoSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)

        // Restrict it to 480p (max in either dimension), it's a GIF, no need to have it in crazy 1080p (saves encoding time a lot, too)
        let cappedResolution: CGFloat = 1080.0
        let aspectRatio = videoSize.width / videoSize.height

        let resultingSize: CGSize = {
            if videoSize.width > videoSize.height {
                let cappedWidth = round(min(cappedResolution, videoSize.width))
                return CGSize(width: cappedWidth, height: round(cappedWidth / aspectRatio))
            } else {
                let cappedHeight = round(min(cappedResolution, videoSize.height))
                return CGSize(width: round(cappedHeight * aspectRatio), height: cappedHeight)
            }
        }()

        let duration: CGFloat = CGFloat(self.duration.seconds)
        let nominalFrameRate = CGFloat(videoTrack.nominalFrameRate)
        let nominalTotalFrames = Int(round(duration * nominalFrameRate))
        let desiredFrameRate: CGFloat = 20.0

        // In order to convert from, say 30 FPS to 20, we'd need to remove 1/3 of the frames, this applies that math and decides which frames to remove/not process
        let framesToRemove: [Int] = {
            // Ensure the actual/nominal frame rate isn't already lower than the desired, in which case don't even worry about it
            if desiredFrameRate < nominalFrameRate {
//                let percentageOfFramesToRemove = (1.0 - (desiredFrameRate / nominalFrameRate))
                let percentageOfFramesToRemove = 0.78

                let totalFramesToRemove = Int(round(CGFloat(nominalTotalFrames) * percentageOfFramesToRemove))

                // We should remove a frame every `frameRemovalInterval` frames…
                // Since we can't remove e.g.: the 3.7th frame, round that up to 4, and we'd remove the 4th frame, then the 7.4th -> 7th, etc.
                let frameRemovalInterval = CGFloat(nominalTotalFrames) / CGFloat(totalFramesToRemove)
                var framesToRemove: [Int] = []

                var sum: CGFloat = 0.0

                while sum <= CGFloat(nominalTotalFrames) {
                    sum += frameRemovalInterval
                    let roundedFrameToRemove = Int(round(sum))
                    framesToRemove.append(roundedFrameToRemove)
                }

                return framesToRemove
            } else {
                return []
            }
        }()

        let totalFrames = nominalTotalFrames - framesToRemove.count

        let outputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: resultingSize.width,
            kCVPixelBufferHeightKey as String: resultingSize.height
        ]

        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)

        reader.add(readerOutput)
        reader.startReading()

        var sample: CMSampleBuffer? = readerOutput.copyNextSampleBuffer()

        let delayBetweenFrames: CGFloat = 1.0 / min(desiredFrameRate, nominalFrameRate)


        let fileProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0
            ]
        ]

        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime: delayBetweenFrames
            ]
        ]

        let resultingFilename = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "qwertygif.gif")
        let resultingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(resultingFilename)
        print("resultingFileURL",resultingFileURL)
        print("resultingFilename",resultingFilename)
        guard let destination = CGImageDestinationCreateWithURL(resultingFileURL as CFURL, kUTTypeGIF, totalFrames, nil) else {
            return
        }

        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1

        var framesCompleted = 0
        var currentFrameIndex = 0

        while (sample != nil) {
            currentFrameIndex += 1

            if framesToRemove.contains(currentFrameIndex) {
                sample = readerOutput.copyNextSampleBuffer()
                continue
            }

            if let newSample = sample {
                // Create it as an optional and manually nil it out every time it's finished otherwise weird Swift bug where memory will balloon enormously (see https://twitter.com/ChristianSelig/status/1241572433095770114)
                var cgImage: CGImage? = cgImageFromSampleBuffer(newSample)

                operationQueue.addOperation {
                    framesCompleted += 1

                    if let cgImage = cgImage {
                        CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
                        
                        completion(cgImage, resultingFilename)
                    }

                    cgImage = nil

                    let progress = CGFloat(framesCompleted) / CGFloat(totalFrames)
                    
                    // GIF progress is a little fudged so it works with downloading progress reports
                    let progressToReport = Int(progress * 100.0)
                            print(progressToReport)
                }
            }

            sample = readerOutput.copyNextSampleBuffer()
        }
            
        operationQueue.waitUntilAllOperationsAreFinished()
            
        let didCreateGIF = CGImageDestinationFinalize(destination)

        guard didCreateGIF else {
            return
        }
        
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: resultingFileURL)
            }) { (saved, error) in
                DispatchQueue.main.async {
                    if saved {
                        print("SAVED!")
                    } else {
                        if (error != nil){
                            print(error.debugDescription)
                        }
                    }
                }
            }
        }
            
        func cgImageFromSampleBuffer(_ buffer: CMSampleBuffer) -> CGImage? {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
                return nil
            }

            CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
            
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            
            guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else { return nil }
            
            let image = context.makeImage()
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

            return image
        }

    }
    //...
}

extension UIImageView{
    func setImgViewCornerRadius(radius: CGFloat){
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        
    }
    func configureImage(img:UIImage, tint_color:UIColor, tint_enabled:Bool) {
        self.image = img
        if tint_enabled == true {
            self.tintColor = tint_color
        }
    }
    
    func roundedImage(){
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    
    func makeOneSideCorner() {
        self.layer.cornerRadius = 18
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }
    
    func setImageBorder(borderWidth: CGFloat = 3.5, color: UIColor = #colorLiteral(red: 0.8669999838, green: 0.4359999895, blue: 0.3619999886, alpha: 1)) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
    }
    
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
//qwerty
extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }

        guard let characterSpacing = characterSpacing else {return attributedString}

        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }
}

extension AVPlayer {
   
   var isPlaying: Bool {
      if (self.rate != 0 && self.error == nil) {
         return true
      } else {
         return false
      }
   }
   
}
