//
//  InitialViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 08/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON
import AuthenticationServices
import GoogleSignIn
//import FirebaseUI
import PhoneNumberKit
import FirebaseAuth
import FirebaseAuthUI
import FirebasePhoneAuthUI
class InitialViewController: UIViewController{
    @IBOutlet weak var mobileButton: UIButton!
    @IBOutlet weak var mobileView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var continueDescLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var viewModel = AuthenticationViewModel()
    let authUI = FUIAuth.defaultAuthUI()
    var isFromList = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
    }
    func configUI() {
//        self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        self.navigationController?.isNavigationBarHidden = true
        self.skipButton.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .right, title: "skip")
        self.facebookButton.cornerMiniumRadius()
        self.googleButton.cornerMiniumRadius()
        self.appleButton.cornerMiniumRadius()
        self.mobileView.cornerViewMiniumRadius()
        self.facebookButton.backgroundColor = UIColor(named: "MessengerColor")
        self.googleButton.backgroundColor = UIColor(named: "googleColor")
        self.appleButton.backgroundColor = UIColor(named: "BlackColor")
        self.facebookButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "Facebook")
        self.googleButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "Google")
        self.appleButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "apple_sign_in")
        self.loginButton.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "login")
       
        self.mobileButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "login_mobile")
        self.signupButton.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "signup")
        self.descLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 18), align: .center, text: "startmaking")
        self.continueDescLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, text: "or Continue with email")

        if #available(iOS 13.0, *) {
            self.appleView.isHidden = false
        }
        else {
            self.appleView.isHidden = true
        }
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = UIColor(named: "AppThemeColorNew")
        navigationBarAppearace.isTranslucent = false
        
        // MARK: Mobile Login with OTP
       // self.mobileView.isHidden = true
        
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
        ]
        self.authUI?.providers = providers
        self.authUI?.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        navigationController?.setNavigationBarHidden(true, animated: animated)
     }
    @IBAction func skipButtonAct(_ sender: UIButton) {
       
        if isFromList {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.delegate.initVC(initialView: TabbarController())
        }
    }
 
    @IBAction func facebookButtonAct(_ sender: UIButton) {
        self.handleFacebookAuthentication()
    }
    
    @IBAction func googleButtonAct(_ sender: UIButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func appleButtonAct(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()

            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])

            authorizationController.delegate = self

//            authorizationController.presentationContextProvider = self

            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
//    @IBAction func mobileLoginAct(_ sender: UIButton) {
//            UINavigationBar.appearance().tintColor = UIColor(named: "whitecolor")
//            let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
//            phoneProvider.defaultCountryCode  = UserDefaultModule.shared.getcountrycode()  ??  "IN"
//             phoneProvider.whitelistedCountries = ["IN"]
//            phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
//        
//        
//        }
    @IBAction func mobileLoginAct(_ sender: UIButton) {
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
        @IBAction func authenticationButtonAct(_ sender: UIButton) {
        if sender == loginButton {
            let pageObj = LoginViewController()
            pageObj.modalPresentationStyle = .fullScreen
            self.present(pageObj, animated: true, completion: nil)
        }
        else if sender == signupButton {
            let pageObj = SignupViewController()
            pageObj.modalPresentationStyle = .fullScreen
            self.present(pageObj, animated: true, completion: nil)
        }
    }
}
extension InitialViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil)
        {
            
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.SocialLogin(type: "google", id: user.userID ?? "", first_name: user.profile.name ?? "", last_name: user.profile.familyName ?? "", email: user.profile.email ?? "", image_url: user.profile.imageURL(withDimension: 100)?.absoluteString ?? "", country_name: (self.delegate.currentLocation?.country ?? ""), state_name: (self.delegate.currentLocation?.subAdministrativeArea ?? ""), city_name: (self.delegate.currentLocation?.locality ?? ""), onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                if success {
                    self.delegate.initVC(initialView: TabbarController())
                }
                else {
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    alert.message = (self.viewModel.loginModel?.message ?? "")
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }else{
            print(error.localizedDescription)
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
}
extension InitialViewController {
  
  /// Our custom functions
  private func handleFacebookAuthentication() {
    let loginManager = LoginManager()
    loginManager.logOut()
    loginManager.logIn(permissions: ["email", "public_profile"], from: self) { (result, error) in
        if error != nil {
//          self.showPopup(isSuccess: false, type: .facebook)
            return
        }
        guard let token = AccessToken.current else {
            print("Failed to get access token")
//            self.showPopup(isSuccess: false, type: .facebook)
            return
        }
        print("AppID\(token.appID)")
//      self.viewModel.token = token.appID
        GraphRequest(graphPath: "me", parameters: ["fields": "id,name,first_name,last_name,email,birthday,gender,location,hometown,about,likes,work,education,picture,photos"]).start { (connection, result, error) -> Void in
            if (error == nil), let result = result as? [String: Any], let _ = result["email"] as? String {
                print("Email:: \(result)")
                let resJson = JSON(result)
                self.viewModel.SocialLogin(type: "facebook", id: resJson["id"].stringValue, first_name: resJson["first_name"].stringValue, last_name: resJson["last_name"].stringValue, email: resJson["email"].stringValue, image_url: resJson["picture","data","url"].stringValue, country_name: (self.delegate.currentLocation?.country ?? ""), state_name: (self.delegate.currentLocation?.administrativeArea ?? ""), city_name: (self.delegate.currentLocation?.locality ?? ""), onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    if success {
                        self.delegate.initVC(initialView: TabbarController())
                    }
                    else {
                        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        alert.message = (self.viewModel.loginModel?.message ?? "")
                        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }
        }

    }
  }
}
@available(iOS 13.0, *)
extension InitialViewController: ASAuthorizationControllerDelegate {

     // ASAuthorizationControllerDelegate function for authorization failed
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

        print(error.localizedDescription)

    }
//
       // ASAuthorizationControllerDelegate function for successful authorization

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Create an account as per your requirement
            let appleId = appleIDCredential.user
            let appleUserLastName = appleIDCredential.fullName?.familyName
            let appleUserEmail = appleIDCredential.email
            let userData = UserDefaultModule.shared.getAppleLoginData()
            print("pop:\(userData)")
            if appleUserEmail != "" {
                userData.email = appleUserEmail ?? ""
                print("AppleUserEmail ===> \(appleUserEmail)")
                userData.fName = appleIDCredential.fullName?.givenName ?? ""
                print("AppleUserName ===> \(appleIDCredential.fullName?.givenName ?? "")")
                userData.lName = appleIDCredential.fullName?.familyName ?? ""
                userData.id = appleId
                UserDefaultModule.shared.setAppleLogin(fName: userData.fName, Id: userData.id, email: userData.email, lName: userData.lName)
            } else {
                userData.id = appleId
            }

            self.viewModel.SocialLogin(type: "apple", id: userData.id, first_name: userData.fName, last_name: userData.lName, email: userData.email, image_url: userData.image, country_name: (self.delegate.currentLocation?.country ?? ""), state_name: (self.delegate.currentLocation?.subAdministrativeArea ?? ""), city_name: (self.delegate.currentLocation?.locality ?? ""), onSuccess: { (success) in

                Utility.shared.stopAnimation(viewController: self)
                if success {
                    self.delegate.initVC(initialView: TabbarController())
                }
                else {
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    alert.message = (self.viewModel.loginModel?.message ?? "")
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
        else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            //Write your code
        }

    }

}
//@available(iOS 13.0, *)
//extension InitialViewController: ASAuthorizationControllerPresentationContextProviding {
//    //For present window
//
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//
//}

//extension InitialViewController: FUIAuthDelegate {
//    @nonobjc func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
//        
//        
//        print(error?.localizedDescription ?? "")
//        if authDataResult?.user != nil{
//            if authDataResult?.user.phoneNumber != nil{
//                let phoneNumberKit = PhoneNumberKit()
//                do {
//                    let phoneNumbers = try phoneNumberKit.parse(authDataResult?.user.phoneNumber ?? "")
//                    print("Phone Number -->\(String(describing: (authDataResult?.user.phoneNumber)))")
//                    self.viewModel.MobileLogin(phone: "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)", onSuccess: { (success) in
//                        Utility.shared.stopAnimation(viewController: self)
//                        if success {
//                            self.delegate.initVC(initialView: TabbarController())
//                        }
//                        else {
//                            //let alert = UIAlertController(title: "message", message: getLanguage[self.viewModel.loginModel?.message ?? "kindly signup your mobile number"] ?? "kindly signup your mobile number" , preferredStyle: .alert)
//                            let alert = UIAlertController(title: nil, message: getLanguage["new_message"],preferredStyle: .alert)
//                            //                            alert.message = (self.viewModel.loginModel?.message ?? "")
//                            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
//                            }))
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                    }) { (failure) in
//                        Utility.shared.stopAnimation(viewController: self)
//                    }                }
//                catch {
//                    print("Generic parser error")
//                }
//                
//            }
//        }
//    }
//    
//    func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
//        print(error?.localizedDescription ?? "")
//    }
//}

extension InitialViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print(error?.localizedDescription ?? "")
        if let user = user, let phoneNumber = user.phoneNumber {
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumbers = try phoneNumberKit.parse(phoneNumber)
                print("Phone Number --> \(phoneNumber)")
                self.viewModel.MobileLogin(phone: "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)", onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    if success {
                        self.delegate.initVC(initialView: TabbarController())
                    } else {
                        let alert = UIAlertController(title: nil, message: getLanguage["new_message"], preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            } catch {
                print("Generic parser error")
            }
        }
    }

    func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
}
