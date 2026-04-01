//
//  HSButton+UIButton.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 10/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    func specificCornerRadiusRightnew(radius: Int) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.bounds
        rectShape.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        rectShape.path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath
        self.layer.mask = rectShape
    }

    public func config(color:UIColor?,font:UIFont?,align:UIControl.ContentHorizontalAlignment,title:String){
        self.setTitleColor(color ?? .white, for: .normal)
        self.setTitle(getLanguage[title] ?? "", for: .normal)
        self.contentHorizontalAlignment = align
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            if align == .left {
                self.contentHorizontalAlignment = .right
            }
            else if align == .right {
                self.contentHorizontalAlignment = .left
            }
        }
        self.titleLabel?.font = font
    }
    func cornerRoundRadius() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }
    func cornerMiniumRadius(_ cornerValue: CFloat = 5) {
        self.layer.cornerRadius = CGFloat(cornerValue)
        self.clipsToBounds = true
    }
    func setBorder(color:UIColor?) {
        self.layer.cornerRadius = 3
        self.layer.borderWidth = 1
        self.layer.borderColor = (color ?? .white).cgColor
    }
    
    //MARK: shadow effect
    func floatingEffect(color: UIColor) {
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.5;
    }
  
    func newEffect() {
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0.0, height: 2)
        self.layer.shadowRadius = 1.0;
        self.layer.shadowOpacity = 1;
    }
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
