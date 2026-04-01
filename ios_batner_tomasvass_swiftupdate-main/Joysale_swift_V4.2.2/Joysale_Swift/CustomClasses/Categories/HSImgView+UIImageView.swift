//
//  HSImgView+UIImageView.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 15/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    func rounded() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    func setBorder(color:UIColor) {
        self.layer.borderWidth = 2
        self.layer.borderColor = color.cgColor
    }
    
    func blurImage() {
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.bounds
        self.addSubview(blurView)
    }
    func removeBlurImage()  {
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        for subview in blurView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
    
    
}
