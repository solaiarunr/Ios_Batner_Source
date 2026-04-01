//
//  FilterType.swift
//  BBMetalImageDemo
//
//  Created by Kaibo Lu on 4/10/19.
//  Copyright © 2019 Kaibo Lu. All rights reserved.
//

enum FilterType {
    case brightness
    case exposure
    case contrast
    case saturation
    case gamma
    case levels
    case colorMatrix
    case rgba
    case hue
    case vibrance
    case whiteBalance
    case highlightShadow
    case highlightShadowTint
    case colorInversion
    case monochrome
    case falseColor
    case haze
    case luminance
    case luminanceThreshold
    case erosion
    case rgbaErosion
    case dilation
    case rgbaDilation
    case chromaKey
    case crop
    case resize
    case rotate
    case flip
    case sharpen
    case unsharpMask
    case gaussianBlur
    case boxBlur
    case zoomBlur
    case motionBlur
    case tiltShift
    case pixellate
    case polarPixellate
    case polkaDot
    case halftone
    case crosshatch
    case sketch
    case thresholdSketch
    case toon
    case posterize
    case kuwahara
    case swirl
    case convolution3x3
    case emboss
    case sobelEdgeDetection
    case bilateralBlur
    case beauty
}

var FilterList:[(String,FilterType?)] = [("Normal", nil), ("Brightness", .brightness),
                                        ("Exposure", .exposure),
                                        ("Contrast", .contrast),
                                        ("Saturation", .saturation),
                                        ("Gamma", .gamma),
                                        ("Levels", .levels),
                                        ("Color matrix", .colorMatrix),
                                        ("RGBA", .rgba),
                                        ("Hue", .hue),
                                        ("Vibrance", .vibrance),
                                        ("White balance", .whiteBalance),
                                        ("Highlight shadow", .highlightShadow),
                                        ("Highlight shadow tint", .highlightShadowTint),
                                        ("Color inversion", .colorInversion),
                                        ("Monochrome", .monochrome),
                                        ("False color", .falseColor),
                                        ("Haze", .haze),
                                        ("Luminance", .luminance),
                                        ("Luminance threshold", .luminanceThreshold),
                                        ("Erosion", .erosion),
                                        ("RGBAErosion", .rgbaErosion),
                                        ("Dilation", .dilation),
                                        ("RGBADilation", .rgbaDilation),
                                        ("Chroma key", .chromaKey),
                                        ("Resize", .resize),
                                        ("Flip", .flip),
                                        ("Sharpen", .sharpen),
                                        ("Unsharp mask", .unsharpMask),
                                        ("Gaussian blur", .gaussianBlur),
                                        ("Box blur", .boxBlur),
                                        ("Zoom blur", .zoomBlur),
                                        ("Motion blur", .motionBlur),
                                        ("Tilt shift", .tiltShift),
                                        ("Pixellate", .pixellate),
                                        ("Polar pixellate", .polarPixellate),
                                        ("Polka dot", .polkaDot),
                                        ("Halftone", .halftone),
                                        ("Crosshatch", .crosshatch),
                                        ("Sketch", .sketch),
                                        ("Threshold sketch", .thresholdSketch),
                                        ("Toon", .toon),
                                        ("Posterize", .posterize),
                                        ("Kuwahara", .kuwahara),
                                        ("Swirl", .swirl),
                                        ("Convolution3x3", .convolution3x3),
                                        ("Emboss", .emboss),
                                        ("SobelEdgeDetection", .sobelEdgeDetection),
                                        ("Beauty", .beauty)]
