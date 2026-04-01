//
//  LoginViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 09/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailTextField: FloatingTF!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: FloatingTF!
    @IBOutlet weak var passwordTitleLabel: UILabel!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var forgotView: UIView!

    @IBOutlet weak var forgotEmailTextField: FloatingTF!
    @IBOutlet weak var ForgotemailTitleLabel: UILabel!
    @IBOutlet weak var forgotTitleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var ResetButton: UIButton!
    @IBOutlet var errorCollectionLabel: [UILabel]!
    @IBOutlet weak var forgotErrorLabel: UILabel!

    var viewModel = AuthenticationViewModel()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var isFromSignup = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        if #available(iOS 13.0, *) {
             navigationController?.navigationBar.setNeedsLayout()
        }
        self.configUI()
    }
    func configUI() {
//        self.setStatusBarBackgroundColor(color: UIColor(named: "whitecolor") ?? .black)
//       self.updateStatusbarBackgroundnew(Color: UIColor(named: "Locationcolorsetup")!)
        self.hideView.isHidden = true
        self.forgotView.cornerViewMiniumRadius()
        self.forgotButton.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .right, title: "forgetpassword")
        self.titleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 30.0), align: .center, text: "login")
        self.forgotTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 25), align: .center, text: "forgetpassword")

        self.descLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "startmaking")
        self.emailTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "email")
        self.ForgotemailTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "email")

        self.emailTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.forgotEmailTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))

        self.passwordTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "password")
        self.passwordTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.loginButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "login")
        self.signupButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "signup_not_member")
        self.ResetButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, title: "reset")
        self.cancelButton.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, title: "cancel")

        self.signupButton.cornerMiniumRadius()
        self.loginButton.cornerMiniumRadius()
        self.signupButton.setBorder(color: UIColor(named: "AppThemeColorNew"))
        self.signupButton.backgroundColor = UIColor(named: "clearcolor")
        self.loginButton.backgroundColor = UIColor(named: "AppThemeColorNew")
        for errorLabel in errorCollectionLabel {
            errorLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
            errorLabel.isHidden = true
        }
        self.forgotErrorLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.hideView.isUserInteractionEnabled = true
        self.hideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.forgotAct)))
        self.backButton.setImage(#imageLiteral(resourceName: "detail_back").imageFlippedForRightToLeftLayoutDirection(), for: .normal)
    }
    @objc func forgotAct() {
        self.view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    @IBAction func forgotPasswordButtonAct(_ sender: UIButton) {
        self.view.endEditing(true)
        self.forgotEmailTextField.text = ""
        self.hideView.isHidden = false
    }
    @IBAction func backButtonAct(_ sender: UIButton) {
        if isFromSignup {
            self.view.endEditing(true)
            self.delegate.initVC(initialView: InitialViewController())
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func loginButtonAct(_ sender: UIButton) {
        self.view.endEditing(true)

        if self.updateErrorData(self.emailTextField) && self.updateErrorData(self.passwordTextField) {
            Utility.shared.startAnimation(viewController: self)
            var set = CharacterSet()
            set.insert(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
            let encodedPassword = self.passwordTextField.text?.addingPercentEncoding(withAllowedCharacters: set) ?? ""
            self.view.endEditing(true)
            self.viewModel.login(email: self.emailTextField.text!, password: encodedPassword, onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                print(success)
                if success {
                    self.delegate.initVC(initialView: TabbarController())
                }
                else {
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    alert.message = getLanguage[(self.viewModel.loginModel?.message ?? "")] ?? (self.viewModel.loginModel?.message ?? "")
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                        self.emailTextField.becomeFirstResponder()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
    }
    
    @IBAction func signupButtonAct(_ sender: UIButton) {
        let vc = SignupViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func forgotButtonAct(_ sender: UIButton) {
        if sender == ResetButton {
            self.view.endEditing(true)
            if (self.updateErrorData(self.forgotEmailTextField)) {
                Utility.shared.startAnimation(viewController: self)
                self.viewModel.ForgotEmail(email: self.forgotEmailTextField.text!, onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    self.view.endEditing(true)
                    self.hideView.isHidden = true
                    let alert = UIAlertController(title: "", message: getLanguage[(self.viewModel.loginModel?.message ?? "")] ?? (self.viewModel.loginModel?.message ?? ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                        if success {
                        }
                        else {
                            self.forgotEmailTextField.becomeFirstResponder()
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }
        }
        else {
            self.emailTextField.becomeFirstResponder()
            self.hideView.isHidden = true
        }
    }
    
}
extension LoginViewController: UITextFieldDelegate {
    func updateErrorData(_ sender: UITextField) -> Bool {
        var isValid = true
        var errorMessage = ""
        
        if sender == emailTextField || sender == forgotEmailTextField {
            if sender.text == "" || !sender.isValidEmail() {
                isValid = false
                errorMessage = getLanguage["Please enter valid Email address"] ?? ""
            }
        }
        else if sender == passwordTextField  {
            if sender.text == "" {
                isValid = false
                errorMessage = getLanguage["Please enter the password"] ?? ""
                self.passwordTextField.setErrorAlertActive = true
            }
            else if (sender.text?.count ?? 0) < 6 {
                isValid = false
                errorMessage = getLanguage["Password should be in minimum six characters"] ?? ""
                self.passwordTextField.setErrorAlertActive = true
            }
        }
        if sender == forgotEmailTextField {
            if !isValid {
                self.forgotErrorLabel.isHidden = false
                self.forgotErrorLabel.text = errorMessage
            }
            else {
                self.forgotErrorLabel.isHidden = true
            }
        }
        else if let errorLabel = errorCollectionLabel.filter({$0.tag == sender.tag}).first {
            if isValid == false {
                errorLabel.isHidden = false
                errorLabel.text = errorMessage
            }
            else {
                errorLabel.isHidden = true
            }
        }
        return isValid
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if updateErrorData(textField) {
            if textField == emailTextField {
                passwordTextField.becomeFirstResponder()
            }
            else {
                textField.resignFirstResponder()
            }
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        return true
    }
}
