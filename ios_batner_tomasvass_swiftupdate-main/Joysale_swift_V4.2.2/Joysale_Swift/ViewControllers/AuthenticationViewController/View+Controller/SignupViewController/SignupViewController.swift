//
//  SignupViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 09/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import FirebaseUI
import PhoneNumberKit

class SignupViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mobileTextField: FloatingTF!
    @IBOutlet weak var mobileTitleLabel: UILabel!
    @IBOutlet weak var mobileStackView: UIStackView!
    @IBOutlet weak var stackViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: FloatingTF!
    @IBOutlet weak var userNameTitleLabel: UILabel!
    @IBOutlet weak var userNameTextfield: FloatingTF!
    @IBOutlet weak var fullNameTitleLabel: UILabel!
    @IBOutlet weak var fullNameTextField: FloatingTF!
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: FloatingTF!
    @IBOutlet weak var confirmPasswordTitleLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: FloatingTF!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var errorCollectionLabel: [UILabel]!
    @IBOutlet weak var termsBtn: UIButton!
    @IBOutlet weak var termsLbl: UILabel!
    var viewModel = AuthenticationViewModel()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let authUI = FUIAuth.defaultAuthUI()
    var mobileNo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
    func configUI() {
//       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
//        self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColorNew") ?? .black)
        userNameTextfield.keyboardType = .asciiCapable
        userNameTextfield.autocapitalizationType = .none
        userNameTextfield.autocorrectionType = .no
        userNameTextfield.spellCheckingType = .no


        self.navigationController?.isNavigationBarHidden = true

        self.titleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 30.0), align: .center, text: "register")
        self.descLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "startmaking1")
        self.emailTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.emailTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "email")
        self.passwordTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.passwordTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "password")
        self.confirmPasswordTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.confirmPasswordTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "confirmpassword")
        self.userNameTextfield.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.userNameTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "username")
        self.fullNameTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.fullNameTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "fullname")
        self.mobileTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.mobileTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "mobile")
        
        self.termsLbl.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "termsalert")
        

        self.signupButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "register")
        self.loginButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "already_member_login")
        self.signupButton.cornerMiniumRadius()
        self.loginButton.cornerMiniumRadius()
        self.loginButton.setBorder(color: UIColor(named: "AppThemeColorNew"))
        self.loginButton.backgroundColor = UIColor(named: "clearcolor")
        self.signupButton.backgroundColor = UIColor(named: "AppThemeColorNew")
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        for errorLabel in errorCollectionLabel {
            errorLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
            errorLabel.isHidden = true
        }
        
        self.mobileTextField.keyboardType = .phonePad
        self.backButton.setImage(#imageLiteral(resourceName: "detail_back").imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        // Firebase Mobile_No Authentication
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = UIColor(named: "AppThemeColorNew")
        navigationBarAppearace.isTranslucent = false
        
        // MARK: Mobile Login with OTP
       // self.mobileStackView.isHidden = true
        
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
        ]
        self.authUI?.providers = providers
        self.authUI?.delegate = self
        
        
        
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        navigationController?.setNavigationBarHidden(true, animated: animated)
     }
    override func viewWillDisappear(_ animated: Bool) {
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.stackViewBottomConst.constant = 20 + keyboardFrame.height
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        print(self.stackViewBottomConst.constant)
        self.viewDidLayoutSubviews()
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        self.stackViewBottomConst.constant = 20
        print(self.stackViewBottomConst.constant)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func termsButtonAct(_ sender: UIButton) {
        if sender.tag == 0 {
            self.termsBtn.tag = 1
            self.termsBtn.setImage(UIImage(named: "CheckBox"), for: .normal)
        }
        else {
            self.termsBtn.tag = 0
            self.termsBtn.setImage(UIImage(named: "CheckBox_withoutTick"), for: .normal)
        }
    }

    
    @IBAction func backButtonAct(_ sender: UIButton) {
//        fatalError("Crash was triggered")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func authenticationButtonAct(_ sender: UIButton) {
        if sender == loginButton {
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        else {
            // ✅ Terms & Conditions check
            if self.termsBtn.tag == 0 {
                let alert = UIAlertController(
                    title: "",
                    message: getLanguage["Pleaseclickthecheckboxup"] ?? "Please click the checkbox to before sign up",
                    preferredStyle: .alert
                )

                let action = UIAlertAction(title: getLanguage["OK"] ?? "OK", style: .cancel)
                alert.addAction(action)

                self.present(alert, animated: true)
                return
            }
            if self.updateErrorData(self.emailTextField) && self.updateErrorData(self.userNameTextfield) && self.updateErrorData(self.fullNameTextField) && self.updateErrorData(self.passwordTextField) && self.updateErrorData(self.confirmPasswordTextField)
                && self.updateErrorData(self.mobileTextField){
                var set = CharacterSet()
                set.insert(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
                let encodedPassword = self.passwordTextField.text?.addingPercentEncoding(withAllowedCharacters: set) ?? ""

                var location_val = false
                if (self.delegate.currentLocation?.country ?? "") != "" {
                    location_val = true
                }
                Utility.shared.startAnimation(viewController: self)
                self.viewModel.signUp(email: self.emailTextField.text!, user_name: self.userNameTextfield.text!, full_name: self.fullNameTextField.text!, password: encodedPassword, country_name: (self.delegate.currentLocation?.country ?? "") , state_name: (self.delegate.currentLocation?.subAdministrativeArea ?? ""), city_name: (self.delegate.currentLocation?.locality ?? ""), is_location: location_val, phone: self.mobileNo, onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    let alert = UIAlertController(title: "", message: getLanguage[self.viewModel.signupModel?.message ?? ""] ?? (self.viewModel.signupModel?.message.capitalized ?? ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
                        self.configUI()
                        if success {
                            DispatchQueue.main.async {
                                let pageObj = LoginViewController()
                                pageObj.isFromSignup = true
                                pageObj.modalPresentationStyle = .fullScreen
                                self.present(pageObj, animated: true, completion: nil)
                            }
                        }
                        else {
                            if (self.viewModel.signupModel?.message ?? "") == "Email already exists" {
                                self.emailTextField.becomeFirstResponder()
                                self.emailTextField.text = ""
                            }
                            else if (self.viewModel.signupModel?.message ?? "") == "Username already exists" {
                                self.userNameTextfield.becomeFirstResponder()
                                self.userNameTextfield.text = ""
                            }
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }
        }
    }
}
extension SignupViewController: UITextFieldDelegate {
    func updateErrorData(_ sender: UITextField) -> Bool {
        var isValid = true
        var errorMessage = ""
        
        if sender == emailTextField {
            if sender.text == "" || !sender.isValidEmail() {
                isValid = false
                errorMessage = getLanguage["Please enter valid Email address"] ?? ""
            }
        }
        else if sender == userNameTextfield {
            if sender.text == "" {
                isValid = false
                errorMessage = getLanguage["Please enter the Username"] ?? ""
            }
            else if (sender.text?.count ?? 0) < 3 {
                isValid = false
                errorMessage = getLanguage["Last name allows atleast 3 to 30 charcters"] ?? ""
            }
        }
        else if sender == fullNameTextField {
            if sender.text == "" {
                isValid = false
                errorMessage = getLanguage["fullnamealert"] ?? ""
            }
            else if (sender.text?.count ?? 0) < 3 {
                isValid = false
                errorMessage = getLanguage["Last name allows atleast 3 to 30 charcters"] ?? ""
            }
        }
        
        else if sender == mobileTextField{
            if sender.text == "" {
                isValid = false
                errorMessage = getLanguage["mobile_no_error"] ?? ""
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
        else if sender == confirmPasswordTextField {
            if sender.text != passwordTextField.text {
                isValid = false
                errorMessage = getLanguage["Password and confirm password is not matching"] ?? ""
                self.passwordTextField.setErrorAlertActive = true

            }
        }
        if let errorLabel = errorCollectionLabel.filter({$0.tag == sender.tag}).first {
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")

        if isBackSpace == -92 {
            return true
        }
//        if textField == userNameTextfield || textField == fullNameTextField {
        if textField == fullNameTextField {
            let allowedCharacters = CharacterSet(charactersIn:".0123456789")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            if allowedCharacters.isSuperset(of: characterSet) {
                return true
            }
            
            if string.containsEmoji {
                return false
            }
            return !(string.rangeOfCharacter(from: CharacterSet.letters) == nil) || (string.contains(" "))
        }
//        if textField == userNameTextfield {
//            let allowedCharacters = CharacterSet(charactersIn:".0123456789")//Here change this characters based on your requirement
//            let characterSet = CharacterSet(charactersIn: string)
//            if allowedCharacters.isSuperset(of: characterSet) {
//                return true
//            }
//            
//            if string.containsEmoji {
//                return false
//            }
//            return !(string.rangeOfCharacter(from: CharacterSet.letters) == nil) || (string.contains(" "))
//        }
        
        // 🔒 Username → small letters + numbers ONLY
        if textField == userNameTextfield {
            let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789")
            return allowed.isSuperset(of: CharacterSet(charactersIn: string.lowercased()))
        }

        else if textField == mobileTextField {
            let allowedCharacters = CharacterSet(charactersIn:".0123456789")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            if allowedCharacters.isSuperset(of: characterSet) {
                return true
            }
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == userNameTextfield {
            textField.text = textField.text?.lowercased()
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
    
        if textField == mobileTextField {
            UINavigationBar.appearance().tintColor = UIColor(named: "whitecolor")
            let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
            phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
        }
    
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if updateErrorData(textField) {
            if textField == emailTextField {
                userNameTextfield.becomeFirstResponder()
            }
            else if textField == userNameTextfield {
                fullNameTextField.becomeFirstResponder()
            }
            else if textField == fullNameTextField {
                passwordTextField.becomeFirstResponder()
            }
            else if textField == passwordTextField {
                confirmPasswordTextField.becomeFirstResponder()
            }
            else {
                textField.resignFirstResponder()
            }
        }
        else {
            return false
        }
        return true
    }
}

extension SignupViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print(error?.localizedDescription ?? "")
        if error == nil {
            print(authDataResult?.user.phoneNumber ?? "")
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumbers = try phoneNumberKit.parse(authDataResult?.user.phoneNumber ?? "")
                self.mobileTextField.text = "+\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
                self.mobileNo = "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
            }
            catch {
                print("Generic parser error")
            }
        }
        else {
        }
    }
    
    func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
    
}

