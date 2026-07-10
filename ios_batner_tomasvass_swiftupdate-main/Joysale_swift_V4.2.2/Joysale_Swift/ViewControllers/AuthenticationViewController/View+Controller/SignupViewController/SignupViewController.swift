//
//  SignupViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 09/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
//import FirebaseUI
import PhoneNumberKit
import SafariServices
import FirebaseAuth
import FirebaseAuthUI
import FirebasePhoneAuthUI
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
    @IBOutlet weak var termsLblbtn: UIButton!
    
    @IBOutlet weak var referaltitle: UILabel!
    @IBOutlet weak var referaltxt: FloatingTF!
    
    var viewModel = AuthenticationViewModel()
    var creditviewModel = CreditsViewModel()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let authUI = FUIAuth.defaultAuthUI()
    var mobileNo = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.mobileStackView.isHidden = true
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
        self.referaltxt.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.passwordTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "password")
        self.referaltitle.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "promo_codetitle")
        self.confirmPasswordTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.confirmPasswordTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "confirmpassword")
        self.userNameTextfield.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.userNameTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "username")
        self.fullNameTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.fullNameTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "fullname")
        self.mobileTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.mobileTitleLabel.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "mobile")
        
//        self.termsLbl.config(color: UIColor(named: "SignSignupTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "termsalert")
        
//        self.termsLblbtn.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, title: "TermsConditions")
        
        let fullText = getLanguage["termsalert"] ?? ""
        let highlightText = "Terms & Conditions"
        let attributedString = NSMutableAttributedString(string: fullText)

      
        attributedString.addAttributes([
            .foregroundColor: UIColor(named: "SignSignupTextColorNew")!,
            .font: UIFont(name: APP_FONT_REGULAR, size: 14)! // 👈 small size here
        ], range: NSRange(location: 0, length: fullText.count))

        // Highlight color + underline
        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)
            
            attributedString.addAttributes([
                .foregroundColor: UIColor(named: "AppThemeColorNew")!,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: nsRange)
        }
        termsLbl.attributedText = attributedString
        termsLbl.isUserInteractionEnabled = true
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTermsTap))
        termsLbl.addGestureRecognizer(tapGesture)
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
    @objc func handleTermsTap(_ gesture: UITapGestureRecognizer) {
        guard let text = termsLbl.text else { return }
        let highlightText = "Terms & Conditions"
        
        let nsText = text as NSString
        let range = nsText.range(of: highlightText)
        
        if gesture.didTapAttributedTextInLabel(label: termsLbl, inRange: range) {
            if let url = URL(string: "https://batner.com/message/help?details=terms-and-policy") {
                UIApplication.shared.open(url)
            }
        }
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
//    @IBAction func termsConditionButtonAct(_ sender: UIButton) {
//       
//        https://batner.com/message/help?details=terms-and-policy
//    }
    
   

    @IBAction func termsConditionButtonAct(_ sender: UIButton) {
        if let url = URL(string: "https://batner.com/message/help?details=terms-and-policy") {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
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
                /*&& self.updateErrorData(self.mobileTextField)*/{
                var set = CharacterSet()
                set.insert(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
                let encodedPassword = self.passwordTextField.text?.addingPercentEncoding(withAllowedCharacters: set) ?? ""

                var location_val = false
                if (self.delegate.currentLocation?.country ?? "") != "" {
                    location_val = true
                }
//
                    Utility.shared.startAnimation(viewController: self)
                    self.viewModel.signUp(email: self.emailTextField.text!, user_name: self.userNameTextfield.text!, full_name: self.fullNameTextField.text!, password: encodedPassword, country_name: (self.delegate.currentLocation?.country ?? "") , state_name: (self.delegate.currentLocation?.subAdministrativeArea ?? ""), city_name: (self.delegate.currentLocation?.locality ?? ""), is_location: location_val, phone: self.mobileNo, onSuccess: { (success) in
                        Utility.shared.stopAnimation(viewController: self)
                        if self.referaltxt.text != ""{
                        Utility.shared.startAnimation(viewController: self)
                        self.creditviewModel.applycodeApi(user_id: self.viewModel.signupModel?.user_id ?? "", code: self.referaltxt.text ?? "", onSuccess: { (success1) in
                            if !success1 {
                                Utility.shared.stopAnimation(viewController: self)
                                let alert = EmailVerificationAlertView()

                                alert.onOkTapped = {
                                    self.configUI()
                                    if success {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)  {
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
                                }
                                alert.show(in: self.view)
                            }else{
                                Utility.shared.stopAnimation(viewController: self)
                                let alert = UIAlertController(title: "", message: getLanguage[self.creditviewModel.promoModel?.message ?? ""] ?? (self.creditviewModel.promoModel?.message.capitalized ?? ""), preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
                                   
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }, onFailure: { (failure) in
                            Utility.shared.stopAnimation(viewController: self)
                        })
                       
                        }else{
                          //  Utility.shared.startAnimation(viewController: self)
                            let alert = EmailVerificationAlertView()

                            alert.onOkTapped = {
                                print("OK tapped")
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

                            }

                            alert.show(in: self.view)
//                            let alert = UIAlertController(title: "", message: getLanguage[self.viewModel.signupModel?.message ?? ""] ?? (self.viewModel.signupModel?.message.capitalized ?? ""), preferredStyle: .alert)
//                            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
//                                self.configUI()
//                                if success {
//                                    DispatchQueue.main.async {
//                                        let pageObj = LoginViewController()
//                                        pageObj.isFromSignup = true
//                                        pageObj.modalPresentationStyle = .fullScreen
//                                        self.present(pageObj, animated: true, completion: nil)
//                                    }
//                                }
//                                else {
//                                    if (self.viewModel.signupModel?.message ?? "") == "Email already exists" {
//                                        self.emailTextField.becomeFirstResponder()
//                                        self.emailTextField.text = ""
//                                    }
//                                    else if (self.viewModel.signupModel?.message ?? "") == "Username already exists" {
//                                        self.userNameTextfield.becomeFirstResponder()
//                                        self.userNameTextfield.text = ""
//                                    }
//                                }
//                            }))
//                            self.present(alert, animated: true, completion: nil)

                        }
                        
                    }) { (failure) in
                        Utility.shared.stopAnimation(viewController: self)
                    }
              //  }
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
            guard let authUI = FUIAuth.defaultAuthUI() else { return }
            if UserDefaultModule.shared.getcountrycode()  ??  "CZ" == "CZ"{
                let phoneProvider = FUIPhoneAuth(
                    authUI: authUI,
                    whitelistedCountries: ["CZ","SK"]
                )
                print("Msmdmf",UserDefaultModule.shared.getcountrycode()  ??  "IN")
                phoneProvider.defaultCountryCode = UserDefaultModule.shared.getcountrycode()  ??  "IN"
                authUI.providers = [phoneProvider]
                phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
            }else{
                let phoneProvider = FUIPhoneAuth(
                    authUI: authUI,
                    whitelistedCountries: [UserDefaultModule.shared.getcountrycode()  ??  "IN"]
                )
                print("Msmdmf",UserDefaultModule.shared.getcountrycode()  ??  "IN")
                phoneProvider.defaultCountryCode = UserDefaultModule.shared.getcountrycode()  ??  "IN"
                authUI.providers = [phoneProvider]
                phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
            }
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
//
//extension SignupViewController: FUIAuthDelegate {
//    @nonobjc func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
//        print(error?.localizedDescription ?? "")
//        if error == nil {
//            print(authDataResult?.user.phoneNumber ?? "")
//            let phoneNumberKit = PhoneNumberKit()
//            do {
//                let phoneNumbers = try phoneNumberKit.parse(authDataResult?.user.phoneNumber ?? "")
//                self.mobileTextField.text = "+\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
//                self.mobileNo = "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
//            }
//            catch {
//                print("Generic parser error")
//            }
//        }
//        else {
//        }
//    }
//    
//    func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
//        print(error?.localizedDescription ?? "")
//    }
//    
//}


extension SignupViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print(error?.localizedDescription ?? "")
        if error == nil {
            print(user?.phoneNumber ?? "")
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumbers = try phoneNumberKit.parse(user?.phoneNumber ?? "")
                self.mobileTextField.text = "+\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
                self.mobileNo = "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
            } catch {
                print("Generic parser error")
            }
        }
    }

    func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
}


class EmailVerificationAlertView: UIView {

    // MARK: - Callbacks
    var onOkTapped: (() -> Void)?

    // MARK: - Background
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()

    // MARK: - Alert Container
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()

    // MARK: - Icon
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "envelope.fill")
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = getLanguage["email_title"] ?? ""
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Message
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = getLanguage["email_des"] ?? ""
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Button
    private lazy var okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(getLanguage["ok"] ?? "", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 122/255, green: 195/255, blue: 0, alpha: 1)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(okPressed), for: .touchUpInside)
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {

        frame = UIScreen.main.bounds

        addSubview(dimView)
        addSubview(containerView)

        dimView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),

            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        [iconImageView, titleLabel, messageLabel, okButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }

        NSLayoutConstraint.activate([

            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 35),
            okButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            okButton.widthAnchor.constraint(equalToConstant: 160),
            okButton.heightAnchor.constraint(equalToConstant: 54),
            okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])
    }

    @objc
    private func okPressed() {
        dismiss()
        onOkTapped?()
    }

    // MARK: - Show
    func show(in parent: UIView) {
        alpha = 0
        parent.addSubview(self)

        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }

    // MARK: - Hide
    func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
