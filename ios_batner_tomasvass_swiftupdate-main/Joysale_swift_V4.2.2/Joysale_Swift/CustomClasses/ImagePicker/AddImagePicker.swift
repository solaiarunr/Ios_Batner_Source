//
//  AddImagePicker.swift
//  Howzu_swift
//
//  Created by Hitasoft on 10/04/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//
/*
import Foundation
import AVFoundation
import Photos
import UIKit

public protocol ImageDelegate: class {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImageDelegate?

    public init(presentationController: UIViewController, delegate: ImageDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        self.pickerController.mediaTypes = ["public.image"]
    }

    public func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.pickerController.modalPresentationStyle = .fullScreen
            var istakePickerEnable = false
            if type == .photoLibrary {
                istakePickerEnable = self.checkLibrary()
            }
            else {
                istakePickerEnable = self.checkCamera()
            }
            if !istakePickerEnable {
                let alert = UIAlertController(title: nil, message: (getLanguage["Not have permission to access camera"] ?? ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["allow"] ?? "allow", style: .default, handler: { (UIAlertAction) in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                self.presentationController?.present(alert, animated: true)
            }
            else {
                self.presentationController?.navigationController?.present(self.pickerController, animated: true, completion: {
                    self.presentationController?.navigationController?.isNavigationBarHidden = false
                })
            }
        }
    }
    func galeryAct(for type: UIImagePickerController.SourceType, title: String) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return
        }
        self.pickerController.sourceType = type
        self.presentationController?.navigationController?.present(self.pickerController, animated: true, completion: {
            self.presentationController?.navigationController?.isNavigationBarHidden = false
        })
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: getLanguage["Take photo"] ?? "Take photo") {
            alertController.addAction(action)
        }
//        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
//            alertController.addAction(action)
//        }
        if let action = self.action(for: .photoLibrary, title: getLanguage["Photo library"] ?? "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }
    func checkCamera()-> Bool {
        var isAvailable = true
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            isAvailable = false
        case .restricted:
            isAvailable = false
        case .authorized:
            isAvailable = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    isAvailable = true
                } else {
                    //access denied
                    isAvailable = false
                }
            })
        default:
            isAvailable = false
        }
        return isAvailable
    }
    func checkLibrary()-> Bool {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .authorized {
            switch photos {
            case .authorized:
                return true
            case .denied:
                return false
            default:
                break
            }
        }
        return true
    }
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        controller.navigationController?.isNavigationBarHidden = true
        self.presentationController?.navigationController?.isNavigationBarHidden = true
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        
          self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}
*/

//
//  AddImagePicker.swift
//  Howzu_swift
//
//  Created by Hitasoft on 10/04/20.
//  Updated by Solai on 05/09/25
//

import Foundation
import AVFoundation
import Photos
import UIKit
import AssetsPickerViewController

public protocol ImageDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {
    
    private weak var presentationController: UIViewController?
    private weak var delegate: ImageDelegate?
    
    public init(presentationController: UIViewController, delegate: ImageDelegate) {
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
    }
    
    // MARK: - Public Entry Point
    public func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Camera
        if let action = self.cameraAction(title: getLanguage["Take photo"] ?? "Take photo") {
            alertController.addAction(action)
        }
        
        // Gallery
        let galleryAction = UIAlertAction(title: getLanguage["Photo library"] ?? "Photo library",
                                          style: .default) { [weak self] _ in
            self?.openAssetsPicker()
        }
        alertController.addAction(galleryAction)
        
        // Cancel
        alertController.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    // MARK: - Camera Handling
    private func cameraAction(title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return nil }
        return UIAlertAction(title: title, style: .default) { [weak self] _ in
            self?.openCamera()
        }
    }
    
    private func openCamera() {
        guard checkCamera() else {
            showPermissionAlert(message: getLanguage["Not have permission to access camera"]
                                ?? "No permission to access camera")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        presentationController?.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - AssetsPicker (Gallery)
    private func openAssetsPicker() {
        let picker = AssetsPickerViewController()
        picker.pickerDelegate = self
        // Hide camera button inside picker
        picker.pickerConfig.assetIsShowCameraButton = false
//        // ✅ Allow only images (no videos)
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
//        // Apply fetch options only for smart album (camera roll)
//        picker.pickerConfig.assetFetchOptions = [
//            .smartAlbum: fetchOptions,
//            .album: fetchOptions
//        ]

        presentationController?.present(picker, animated: true, completion: nil)
    }


    
    // MARK: - Permission Checkers
    private func checkCamera() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            var grantedAccess = false
            let semaphore = DispatchSemaphore(value: 0)
            AVCaptureDevice.requestAccess(for: .video) { granted in
                grantedAccess = granted
                semaphore.signal()
            }
            semaphore.wait()
            return grantedAccess
        @unknown default:
            return false
        }
    }
    
    private func showPermissionAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["allow"] ?? "Allow", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "Cancel", style: .cancel))
        presentationController?.present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate (Camera)
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        delegate?.didSelect(image: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        delegate?.didSelect(image: image)
    }
}

// MARK: - AssetsPickerViewControllerDelegate (Gallery)
extension ImagePicker: AssetsPickerViewControllerDelegate {
    public func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        controller.dismiss(animated: true, completion: nil)
        guard let asset = assets.first else {
            delegate?.didSelect(image: nil)
            return
        }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 1080, height: 1080),
                             contentMode: .aspectFit,
                             options: options) { [weak self] image, _ in
            self?.delegate?.didSelect(image: image)
        }
    }
    
    public func assetsPickerDidCancel(controller: AssetsPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
        delegate?.didSelect(image: nil)
    }
    
   

}


