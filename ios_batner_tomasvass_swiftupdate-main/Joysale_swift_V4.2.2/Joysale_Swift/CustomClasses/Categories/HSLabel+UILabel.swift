//
//  HSLabel+UILabel.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 10/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
 
    //MARK: configure label
    public func config(color:UIColor?,font:UIFont?, align:NSTextAlignment, text:String){
        self.textColor = color ?? .white
        self.textAlignment = align
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            if align == .left {
                self.textAlignment = .right
            }
            else if align == .right {
                self.textAlignment = .left
            }
        }
        self.text = getLanguage[text] ?? text
        self.font = font
    }
    
    //set attributed text
    func attributed(text:String)  {
        
        let attributedString = NSMutableAttributedString(string: getLanguage[text] ?? "")
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 10 // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        // *** Set Attributed String to your label ***
        self.attributedText = attributedString;
    }
    
    //round corner
    func cornerRadius() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    //specific corner size
    func lblMinimumCornerRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }

        
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    func sizeToFitHeight() {
        let maxHeight = CGFloat.infinity
        let rect = self.attributedText?.boundingRect(with: CGSize(width: self.frame.size.width, height: maxHeight), options: .usesLineFragmentOrigin, context: nil)
        var frame = self.frame
        frame.size.height = rect?.size.height ?? self.frame.size.height
        self.frame = frame
    }
    
    override open var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        if let insets = padding {
            return CGSize(width: size.width + insets.left + insets.right,
                          height: size.height + insets.top + insets.bottom)
        }
        return size
    }
}
extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
}

@IBDesignable
class WrappingLabel: UILabel {
    private var explicitLayoutWidth: CGFloat?

    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    override func layoutSubviews() {
        updateWrappingWidthIfNeeded()
        super.layoutSubviews()
    }

    override var intrinsicContentSize: CGSize {
        guard preferredMaxLayoutWidth > 0 else {
            return super.intrinsicContentSize
        }

        let text = self.text ?? attributedText?.string ?? ""
        guard !text.isEmpty, let font else {
            return super.intrinsicContentSize
        }

        let boundingRect = (text as NSString).boundingRect(
            with: CGSize(width: preferredMaxLayoutWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )

        return CGSize(width: UIView.noIntrinsicMetric, height: ceil(boundingRect.height))
    }

    func setExplicitLayoutWidth(_ width: CGFloat) {
        let roundedWidth = floor(max(width, 0))
        guard roundedWidth > 0 else { return }

        explicitLayoutWidth = roundedWidth
        preferredMaxLayoutWidth = roundedWidth
        invalidateIntrinsicContentSize()
    }

    func refreshLayout(explicitWidth: CGFloat) {
        setExplicitLayoutWidth(explicitWidth)
        var ancestor = superview
        while ancestor != nil {
            ancestor?.setNeedsLayout()
            if ancestor is UIStackView {
                ancestor?.invalidateIntrinsicContentSize()
            }
            ancestor = ancestor?.superview
        }
    }

    private func updateWrappingWidthIfNeeded() {
        if let explicitLayoutWidth, explicitLayoutWidth > 0 {
            if preferredMaxLayoutWidth != explicitLayoutWidth {
                preferredMaxLayoutWidth = explicitLayoutWidth
                invalidateIntrinsicContentSize()
            }
            return
        }

        let screenWidth = window?.bounds.width ?? UIScreen.main.bounds.width
        guard screenWidth > 0 else { return }

        let targetWidth: CGFloat
        if let rowStack = superview as? UIStackView, rowStack.axis == .horizontal {
            targetWidth = floor(screenWidth - 40)
        } else {
            targetWidth = floor(screenWidth - 20)
        }

        guard targetWidth > 0, preferredMaxLayoutWidth != targetWidth else { return }
        preferredMaxLayoutWidth = targetWidth
        invalidateIntrinsicContentSize()
    }
}

@IBDesignable
class PaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 4.0
    @IBInspectable var bottomInset: CGFloat = 4.0
    @IBInspectable var leftInset: CGFloat = 10.0
    @IBInspectable var rightInset: CGFloat = 10.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
