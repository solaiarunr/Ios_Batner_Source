//
//  HSTextField+UITextField.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 10/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {

//MARK: configure textField
    public func config(color:UIColor?, align:NSTextAlignment,placeHolder:String, font: UIFont?, placeHolder_color: String = "SecondaryTextColor"){
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
        self.tintColor = UIColor(named: "SecondaryTextColor") ?? .white
        self.placeholder = getLanguage[placeHolder] ?? placeHolder
        self.font = font ?? UIFont.systemFont(ofSize: 14)
        let redPlaceholderText = NSAttributedString(string: (getLanguage[placeHolder] ?? placeHolder), attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: placeHolder_color) ?? .white])
        self.attributedPlaceholder = redPlaceholderText
        self.textColor = color ?? .white
    }
    
    func textFieldWithShowAct(title: String, image: UIImage?) {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(40), height: CGFloat(40))
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        if title != "" {
            button.setTitle(getLanguage[title] ?? "", for: .normal)
        }
        else {
            button.setImage(image, for: .normal)
        }
        button.addTarget(self, action: #selector(showButtonAct), for: .touchUpInside)
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            button.config(color: UIColor(named: "AppTextColor") ?? .white, font: REGULAR_FONT, align: .left, title: title)
            self.leftViewMode = .always
            self.leftView = button
        }
        else {
            button.config(color: UIColor(named: "AppTextColor") ?? .white, font: REGULAR_FONT, align: .right, title: title)
            self.rightViewMode = .always
            self.rightView = button
        }
    }
    func textFieldWithRightView(title: String, image: UIImage?) {
        let padding: CGFloat = 10
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: padding * 2 + 20, height: 20))
        let imageView = UIImageView(frame: CGRect(x: padding, y: 0, width: 20, height: 20))
        imageView.image = image
        imageView.tintColor = UIColor(named: "AppTextColor") ?? .white
        outerView.addSubview(imageView)
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.rightViewMode = .always
            self.rightView = outerView
        }
        else {
            self.leftViewMode = .always
            self.leftView = outerView
        }
    }
    @objc func showButtonAct(_ sender: UIButton) {
        if sender.tag == 0 {
            self.isSecureTextEntry = false
            sender.tag = 1
            if sender.titleLabel?.text != "" && sender.titleLabel?.text != nil{
                sender.config(color: UIColor(named: "AppTextColor") ?? .white, font: REGULAR_FONT, align: .right, title: "hide")
            }
            else {
                sender.config(color: UIColor(named: "AppTextColor") ?? .white, font: REGULAR_FONT, align: .right, title: "show")

                //sender.setImage(#imageLiteral(resourceName: "eye-2"), for: .normal)
            }
        }
        else {
            if sender.titleLabel?.text != "" && sender.titleLabel?.text != nil{
                sender.config(color: UIColor(named: "AppTextColor") ?? .white, font: REGULAR_FONT, align: .right, title: "show")
            }
            else {
                sender.config(color: UIColor(named: "AppTextColor") ?? .white, font: REGULAR_FONT, align: .right, title: "hide")

              //  sender.setImage(#imageLiteral(resourceName: "hidden"), for: .normal)
            }
            self.isSecureTextEntry = true
            sender.tag = 0
        }
    }
    //MARK: Rounded radius
    func cornerRoundRadius() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }
    //minimum radius
    func cornerMiniumRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    // set border
    func setBorder() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
    //MARK: email Validation
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text)
    }
    //MARK: left padding
    func setLeftPadding(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
  
    //MARK: check textfield is empty
    func isEmpty() -> Bool {
        if  (self.text! == "") || (self.text! == "NULL") || (self.text! == "(null)")  || (self.text! == "<null>") || (self.text! == "Json Error") || (self.text! == "0") || (self.text!.isEmpty) ||  self.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
    func setDatePicker(target: Any, selector: Selector, minimumDate: Date, dateFormat: String = "dd-MMM-YYYY") {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .date //2
        
        datePicker.minimumDate = minimumDate
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
         self.inputView = datePicker //3
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
        toolBar.setItems([cancel, flexible, barButton], animated: false) //8
        self.inputAccessoryView = toolBar //9
        datePicker.accessibilityLabel = dateFormat
        datePicker.addTarget(self, action: #selector(self.datePickerAct(_:)), for: .valueChanged)
    }
    @objc func datePickerAct(_ sender: UIDatePicker) {
        let dateformatter = DateFormatter() // 2-2
        dateformatter.dateFormat = sender.accessibilityLabel ?? "dd-MMM-YYYY"
        self.text = dateformatter.string(from: sender.date)
    }
    func setInputViewDatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .date //2
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar

        components.year = -18
        components.month = 12
        let maxDate = calendar.date(byAdding: components, to: currentDate)!

        components.year = -150
        let minDate = calendar.date(byAdding: components, to: currentDate)!

        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        self.inputView = datePicker //3
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
        toolBar.setItems([cancel, flexible, barButton], animated: false) //8
        self.inputAccessoryView = toolBar //9
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    func isValidEmail(emailID:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}
extension UITextView {
    // add Done button to keyboard
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}
extension UIToolbar {

func ToolbarPiker(mySelect : Selector) -> UIToolbar {
    let toolBar = UIToolbar()
    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.tintColor = UIColor.black
    toolBar.sizeToFit()
    let doneButton = UIBarButtonItem(title: getLanguage["Done"] ?? "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    toolBar.setItems([ spaceButton, doneButton], animated: false)
    toolBar.isUserInteractionEnabled = true
    return toolBar
}

}
