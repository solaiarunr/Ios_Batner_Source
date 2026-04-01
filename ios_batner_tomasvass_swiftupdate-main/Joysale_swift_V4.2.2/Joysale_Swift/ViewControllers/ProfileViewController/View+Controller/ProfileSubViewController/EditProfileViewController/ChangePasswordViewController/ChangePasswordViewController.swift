//
//  ChangePasswordViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 13/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var edit1View: UIView!
    @IBOutlet weak var edit2View: UIView!
    @IBOutlet weak var edit3View: UIView!
    @IBOutlet weak var edit1Label: UILabel!
    @IBOutlet weak var edit1TextField: UITextField!
    @IBOutlet weak var edit2Label: UILabel!
    @IBOutlet weak var edit2TextField: UITextField!
    @IBOutlet weak var edit3TextField: UITextField!
    @IBOutlet weak var edit3Label: UILabel!
    var viewType = ""
    var viewModel = ProfileViewModel()
    var profileData: ProfileResultModel?
    var editProfileVC: EditProfileViewController?
    var showBtn  = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
    func configUI() {

        self.navigationController?.customNavigationBarView(title: self.viewType, fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.saveButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.saveButton.cornerMiniumRadius()
        self.saveButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "save")
        if viewType == "changepassword" {
            self.edit1Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "currentpassword")
            self.edit2Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "newpassword")
            self.edit3Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "confirmpassword")
            self.edit1TextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "************", font: UIFont(name: APP_FONT_REGULAR, size: 15))
            self.edit1TextField.isSecureTextEntry = true
            self.edit2TextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "************", font: UIFont(name: APP_FONT_REGULAR, size: 15))
              self.edit2TextField.isSecureTextEntry = true
             self.edit2TextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            self.edit3TextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "************", font: UIFont(name: APP_FONT_REGULAR, size: 15))
            self.edit3TextField.isSecureTextEntry = true
            self.edit3View.isHidden = false
        }
        else {
            self.edit1TextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "enter_here", font: UIFont(name: APP_FONT_REGULAR, size: 15))
            self.edit1TextField.isSecureTextEntry = false
            self.edit2TextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "enter_here", font: UIFont(name: APP_FONT_REGULAR, size: 15))
            self.edit2TextField.isSecureTextEntry = false
            self.edit1Label.config(color: UIColor(named: "CommentDaysTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .left, text: "private_key")
            self.edit2Label.config(color: UIColor(named: "CommentDaysTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .left, text: "public_key")
            self.edit1TextField.text = (STRIPE_DETAILS?.stripePrivatekey ?? "")
            self.edit2TextField.text = (STRIPE_DETAILS?.stripePublickey ?? "")
            self.edit3View.isHidden = true
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @IBAction func saveButtonAct(_ sender: UIButton) {
        if viewType == "changepassword" {
            if validatePassword().0 {
                Utility.shared.startAnimation(viewController: self)
                self.viewModel.changePassword(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", old_password: "\(self.edit1TextField.text!)", new_password: "\(self.edit2TextField.text!)", onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: self.viewModel.tosModel?.message ?? "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                        if success {                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }) { (failure) in
                    
                }
            }
            else {
                let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage[validatePassword().1] ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            if self.edit1TextField.text != "" && self.edit2TextField.text != "" {
                Utility.shared.startAnimation(viewController: self)
                
                self.viewModel.stripeDetails(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", stripe_privatekey: "\(self.edit1TextField.text!)", stripe_publickey: "\(self.edit2TextField.text!)", onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: (self.viewModel.tosModel?.message ?? ""), preferredStyle: .alert)
                    if success {
                        alert.message = getLanguage["stripe_details_success"] ?? ""
                    }
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                        if success {
                            self.editProfileVC?.profileData?.stripeDetails.stripePrivatekey = (self.edit1TextField.text!)
                            self.editProfileVC?.profileData?.stripeDetails.stripePublickey = (self.edit2TextField.text!)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }) { (failure) in
                    
                }
            }
            else {
                var message = ""
                if self.edit1TextField.text == "" {
                    message = "enter_private_key"
                }
                else {
                    message = "enter_public_key"
                }
                let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage[message] ?? "" , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    @objc func textFieldDidChange() {
        if  self.edit2TextField.hasText {
            self.edit2TextField.textFieldWithShowAct(title: "show", image: nil)
        }
        else if self.edit2TextField.text == "" {
            self.edit2TextField.textFieldWithShowAct(title: "", image: nil)
        }
      }
      func validatePassword() -> (Bool, String) {
        var isValid = false
        var message = ""
        if self.edit1TextField.text == "" {
            message = "Please enter current password"
        }
        else if (self.edit1TextField.text?.count ?? 0) < 6 {
            message = "Password should be in minimum six characters"
        }
        else if self.edit2TextField.text == "" {
            message = "Please enter new password"
        }
        else if (self.edit2TextField.text?.count ?? 0) < 6 {
            message = "Password should be in minimum six characters"
        }
        else if self.edit3TextField.text == "" {
            message = "Please enter confirm password"
        }
        else if self.edit2TextField.text != self.edit3TextField.text {
            message = "Please check the password and try again"
        }
        else {
            isValid = true
        }
        return (isValid, message)
    }
}
extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
