//
//  FilterCollectionViewCell.swift
//  ProductsVideo
//
//  Created by MAC BOOK on 07/11/22.
//

import UIKit
import BBMetalImage

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    var type: FilterType?
    private var image: UIImage!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.filterLabel.config(color: .white, font: .systemFont(ofSize: 12), align: .center, text: "")
    }
    func loadData(_ index: Int, selected: Int) {
        image = UIImage(named: "filter_sample_image.jpg")
        self.filterLabel.text = FilterList[index].0
        self.type = FilterList[index].1
        self.filterImageView.image = filteredImage
        if selected == index {
            self.filterImageView.layer.borderWidth = 2
            self.filterImageView.layer.borderColor = UIColor.orange.cgColor
        }
        else {
            self.filterImageView.layer.borderWidth = 0
        }
    }
    private var filteredImage: UIImage? {
        guard let filterType = type else { return  image}
        switch filterType {
        case .brightness: return BBMetalBrightnessFilter(brightness: 0.15).filteredImage(with: image)
        case .exposure: return BBMetalExposureFilter(exposure: 0.5).filteredImage(with: image)
        case .contrast: return BBMetalContrastFilter(contrast: 1.5).filteredImage(with: image)
        case .saturation: return BBMetalSaturationFilter(saturation: 2).filteredImage(with: image)
        case .gamma: return BBMetalGammaFilter(gamma: 1.5).filteredImage(with: image)
        case .levels: return BBMetalLevelsFilter(minimum: .red).filteredImage(with: image)
        case .colorMatrix:
            var matrix: matrix_float4x4 = .identity
            matrix[0][1] = 1
            matrix[2][1] = 1
            matrix[3][1] = 1
            return BBMetalColorMatrixFilter(colorMatrix: matrix).filteredImage(with: image)
        case .rgba: return BBMetalRGBAFilter(red: 1.2).filteredImage(with: image)
        case .hue: return BBMetalHueFilter(hue: 90).filteredImage(with: image)
        case .vibrance: return BBMetalVibranceFilter(vibrance: 1).filteredImage(with: image)
        case .whiteBalance: return BBMetalWhiteBalanceFilter(temperature: 7000).filteredImage(with: image)
        case .highlightShadow: return BBMetalHighlightShadowFilter(shadows: 0.5, highlights: 0.5).filteredImage(with: image)
        case .highlightShadowTint: return BBMetalHighlightShadowTintFilter(shadowTintColor: .blue,
                                                                           shadowTintIntensity: 0.5,
                                                                           highlightTintColor: .red,
                                                                           highlightTintIntensity: 0.5).filteredImage(with: image)
        case .colorInversion: return BBMetalColorInversionFilter().filteredImage(with: image)
        case .monochrome: return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.7, green: 0.6, blue: 0.5), intensity: 1).filteredImage(with: image)
        case .falseColor: return BBMetalFalseColorFilter().filteredImage(with: image)
        case .haze: return BBMetalHazeFilter(distance: 0.2).filteredImage(with: image)
        case .luminance: return BBMetalLuminanceFilter().filteredImage(with: image)
        case .luminanceThreshold: return BBMetalLuminanceThresholdFilter(threshold: 0.6).filteredImage(with: image)
        case .erosion: return BBMetalErosionFilter(pixelRadius: 2).filteredImage(with: image)
        case .rgbaErosion: return BBMetalRGBAErosionFilter(pixelRadius: 2).filteredImage(with: image)
        case .dilation: return BBMetalDilationFilter(pixelRadius: 2).filteredImage(with: image)
        case .rgbaDilation: return BBMetalRGBADilationFilter(pixelRadius: 2).filteredImage(with: image)
        case .chromaKey: return BBMetalChromaKeyFilter(colorToReplace: .blue).filteredImage(with: image)
        case .crop: return BBMetalCropFilter(rect: BBMetalRect(x: 0.25, y: 0.5, width: 0.5, height: 0.5)).filteredImage(with: image)
        case .resize: return BBMetalResizeFilter(size: BBMetalSize(width: 0.5, height: 0.8)).filteredImage(with: image)
        case .rotate: return BBMetalRotateFilter(angle: -120, fitSize: true).filteredImage(with: image)
        case .flip: return BBMetalFlipFilter(horizontal: true, vertical: true).filteredImage(with: image)
        case .sharpen: return BBMetalSharpenFilter(sharpeness: 0.5).filteredImage(with: image)
        case .unsharpMask: return BBMetalUnsharpMaskFilter(intensity: 4).filteredImage(with: image)
        case .gaussianBlur: return BBMetalGaussianBlurFilter(sigma: 3).filteredImage(with: image)
        case .boxBlur: return BBMetalBoxBlurFilter(kernelWidth: 25, kernelHeight: 65).filteredImage(with: image)
        case .zoomBlur: return BBMetalZoomBlurFilter(blurSize: 3, blurCenter: BBMetalPosition(x: 0.35, y: 0.55)).filteredImage(with: image)
        case .motionBlur: return BBMetalMotionBlurFilter(blurSize: 5, blurAngle: 30).filteredImage(with: image)
        case .tiltShift: return BBMetalTiltShiftFilter().filteredImage(with: image)
        case .pixellate: return BBMetalPixellateFilter().filteredImage(with: image)
        case .polarPixellate: return BBMetalPolarPixellateFilter(pixelSize: BBMetalSize(width: 0.05, height: 0.07), center: BBMetalPosition(x: 0.35, y: 0.55)).filteredImage(with: image)
        case .polkaDot: return BBMetalPolkaDotFilter().filteredImage(with: image)
        case .halftone: return BBMetalHalftoneFilter().filteredImage(with: image)
        case .crosshatch: return BBMetalCrosshatchFilter(crosshatchSpacing: 0.01).filteredImage(with: image)
        case .sketch: return BBMetalSketchFilter().filteredImage(with: image)
        case .thresholdSketch: return BBMetalThresholdSketchFilter(threshold: 0.15).filteredImage(with: image)
        case .toon: return BBMetalToonFilter().filteredImage(with: image)
        case .posterize: return BBMetalPosterizeFilter().filteredImage(with: image)
        case .kuwahara: return BBMetalKuwaharaFilter().filteredImage(with: image)
        case .swirl: return BBMetalSwirlFilter(center: BBMetalPosition(x: 0.35, y: 0.55), radius: 0.25).filteredImage(with: image)
        case .convolution3x3: return BBMetalConvolution3x3Filter(convolution: simd_float3x3(rows: [SIMD3<Float>(-1, 0, 1),
                                                                                                   SIMD3<Float>(-2, 0, 2),
                                                                                                   SIMD3<Float>(-1, 0, 1)])).filteredImage(with: image)
        case .emboss: return BBMetalEmbossFilter(intensity: 1).filteredImage(with: image)
        case .sobelEdgeDetection: return BBMetalSobelEdgeDetectionFilter().filteredImage(with: image)
        case .bilateralBlur: return BBMetalBilateralBlurFilter().filteredImage(with: image)
        case .beauty: return BBMetalBeautyFilter().filteredImage(with: image)
        }
    }
}
