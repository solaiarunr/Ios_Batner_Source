//
//  HSTextView+UITextView.swift
//  Hiddy
//
//  Created by APPLE on 06/08/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
import UIKit

extension UITextView{
    //MARK: configure label
    public func config(color:UIColor,font:UIFont?, align:NSTextAlignment, text:String){
        self.textColor = color
        self.textAlignment = align
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            if align == .left {
                self.textAlignment = .right
            }
            else if align == .right {
                self.textAlignment = .left
            }
        }
        self.font = font ?? UIFont.systemFont(ofSize: 14)
        self.tintColor = UIColor(named: "Placeholdercolor") ?? .white
        self.text = getLanguage[text] ?? ""
    }
    //MARK: check textfield is empty
    func isEmpty() -> Bool {
        if  (self.text! == "") || (self.text! == "NULL") || (self.text! == "(null)")  || (self.text! == "<null>") || (self.text! == "Json Error") || (self.text! == "0") || (self.text!.isEmpty) ||  self.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
extension UIScrollView {
   func scrollToBottom(animated: Bool) {
     if self.contentSize.height < self.bounds.size.height { return }
     let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
     self.setContentOffset(bottomOffset, animated: animated)
  }
}
