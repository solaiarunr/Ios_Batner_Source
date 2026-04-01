//
//  EditProfileViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 13/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import FirebaseUI
import PhoneNumberKit
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON
import Photos

class EditProfileViewController: UIViewController, customLocationDelegate, PayStackPaymentDelegate,PHPhotoLibraryChangeObserver {
    func backaction(isfrom: String) {
        
    }
    
    func successaction(isfrom: String) {
        
    }
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var profileData: ProfileResultModel?
    var imagePicker: ImagePicker!
    let authUI = FUIAuth.defaultAuthUI()
    var viewModel = ProfileViewModel()
    private var videoFetchResult: PHFetchResult<PHAsset>?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        self.navigationController?.isNavigationBarHidden = false
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
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
    func configUI() {
        self.imagePicker = ImagePicker(presentationController: self , delegate: self)
        self.tableView.register(UINib(nibName: "EditProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "EditProfileTableViewCell")
        self.navigationController?.customNavigationBarView(title: "edit_profile", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50
        self.saveButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.saveButton.cornerMiniumRadius()
        self.saveButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "save")
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
        ]
        Auth.auth().languageCode = DEFAULT_LANGUAGE_CODE
        self.authUI?.providers = providers
        self.authUI?.delegate = self
        self.loadData()
    }
    func loadData() {
        self.viewModel.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            if success {
                if let profileData = self.viewModel.profileModel?.result {
                    self.profileData = profileData
                    self.tableView.reloadData()
                }
            }
        }) { (failure) in
        }
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        self.viewDidLayoutSubviews()
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func saveButtonAct(_ sender: UIButton) {
        if (self.profileData?.fullName ?? "") != "" {
            if (self.profileData?.userImg ?? "").contains("/logo/") {
                    self.profileData?.userImg = ""
                        }
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.editProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", email: self.profileData?.email ?? "", full_name: self.profileData?.fullName ?? "", first_name: "", last_name: "", mobile_no: self.profileData?.mobileNo ?? "", isFromFB: 0, show_mobile_no: self.profileData?.showMobileNo ?? false, user_img: self.profileData?.userImg ?? "", fb_profileurl: "", facebook_id: self.profileData?.facebookId ?? "", fb_phone: "", country_name: self.profileData?.country ?? "", city_name: self.profileData?.city ?? "", state_name: self.profileData?.state ?? "", onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                let alert = UIAlertController(title: nil, message: getLanguage["your_changes_saved"] ?? "", preferredStyle: .alert)
                if !success {
                    alert.message = self.viewModel.tosModel?.message ?? ""
                }
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
        else {
            let alert = UIAlertController(title: nil, message: getLanguage["enter_the_name"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource, editProfileDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        }
        else if section == 2 {
            return 8
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
         if indexPath.section == 2 && indexPath.row == 4 {
         return 0
        }
        if indexPath.section == 2 && indexPath.row == 5 {
            
            if (self.profileData?.mobileNo ?? "") == "" {
                return 0
            }
        }
        
       
        else if (indexPath.section == 2 && indexPath.row == 1) {
            if (ADMIN_VIEW_MODEL.adminModel?.result.buynow ?? "") == "disable" {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    @objc func nextButtonaction() {
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.stripeDetails(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", stripe_privatekey: "", stripe_publickey: "", onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            if success {
                let pageObj = PaystackViewController()
                pageObj.url = self.viewModel.stripeModel?.url ?? ""
                pageObj.PayStackPaymentDelegate = self
                pageObj.return_url = self.viewModel.stripeModel?.returnurl ?? ""
                pageObj.modalPresentationStyle = .overFullScreen
                self.navigationController?.pushViewController(pageObj, animated: true)
                
            }
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    
    @objc func newSellLabelTapped() {
        let alert = UIAlertController(
            title: "Connect Stripe Account",
            message: """
            Connect your Stripe account to receive payments directly.
            Batner charges a 7% fee (or according to the current pricing).
            As the seller, you are responsible for your orders – any returns, refunds, or disputes must be handled by you directly through your Stripe account.
            """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    // Add this selector in EditProfileTableViewCell


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileTableViewCell") as! EditProfileTableViewCell
        cell.delegate = self
        cell.NewSellLbl.tag = indexPath.row
        if let profileData = self.profileData {
            cell.loadData(profileData, index: indexPath)
        }
//        cell.nextButton.tag = indexPath.row
//        cell.nextButton.addTarget(self, action: #selector(self.nextButtonaction), for: .touchUpInside)
        cell.switchButton.addTarget(self, action: #selector(self.switchControllAct(_:)), for: .valueChanged)
        cell.NewSellLbl.isUserInteractionEnabled = true
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newSellLabelTapped))
        cell.NewSellLbl.addGestureRecognizer(tapGesture)
        // ✅ Remove old gestures first (prevents duplicates on cell reuse)
     

        if indexPath.section == 2 && indexPath.row == 5 {
            if (self.profileData?.mobileNo ?? "") == "" {
                cell.isHidden = true
            }
        }
        else if indexPath.section == 2 && indexPath.row == 1 {
            if (ADMIN_VIEW_MODEL.adminModel?.result.buynow ?? "") == "disable" {
                cell.isHidden = true
            }
        }
        return cell
    }
    @objc func switchControllAct(_ sender: UISwitch) {
        profileData?.showMobileNo = sender.isOn
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.videoFetchResult = PHAsset.fetchAssets(with: .video, options: options)
            PHPhotoLibrary.shared().register(self)
            self.imagePicker.present(from: self.saveButton)
        }
        else if (indexPath.section == 1 && indexPath.row == 2) || (indexPath.section == 2 && indexPath.row == 1) {
            let pageObj = ChangePasswordViewController()
            if (indexPath.section == 1 && indexPath.row == 2) {
                pageObj.viewType = "changepassword"
                pageObj.editProfileVC = self
                pageObj.profileData = self.profileData
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
            else {
                Utility.shared.startAnimation(viewController: self)
                self.viewModel.stripeDetails(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", stripe_privatekey: "", stripe_publickey: "", onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    if success {
                        let pageObj = PaystackViewController()
                        pageObj.url = self.viewModel.stripeModel?.url ?? ""
                        pageObj.PayStackPaymentDelegate = self
                        pageObj.return_url = self.viewModel.stripeModel?.returnurl ?? ""
                        pageObj.modalPresentationStyle = .overFullScreen
                        self.navigationController?.pushViewController(pageObj, animated: true)
                        
                    }
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }

               
            }
           
        }
        else if indexPath.section == 2 && indexPath.row == 0{
            // MARK: Mabbox Addon
            
             let pageObj = MapViewController()
             pageObj.locationString = self.profileData?.location ?? ""
             pageObj.delegate = self
             pageObj.viewType = "profile"
             self.navigationController?.pushViewController(pageObj, animated: true)
             
            
//            let pageObj = LocationViewController()
//            pageObj.locationString = self.profileData?.location ?? ""
//            pageObj.delegate = self
//            pageObj.viewType = "profile"
//            self.navigationController?.pushViewController(pageObj, animated: true)
            
        }
        else if indexPath.section == 2 && indexPath.row == 3 {
            UINavigationBar.appearance().tintColor = UIColor(named: "whitecolor")
            let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
            phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
        }
        else if indexPath.section == 2 && indexPath.row == 4 {
            if (self.profileData?.verification.facebook == false){
                self.handleFacebookAuthentication()
            }
        }
        else if indexPath.section == 2 && indexPath.row == 6 {
            let pageObj = LanguageViewController()
            self.navigationController?.pushViewController(pageObj, animated: true)
        }  else if indexPath.section == 2 && indexPath.row == 7 {
            let pageObj = ThemeViewController()
            self.navigationController?.pushViewController(pageObj, animated: true)
        }else if indexPath.section == 2 && indexPath.row == 8 {
            let pageObj  = CountrySearchVC()
            pageObj.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
    }
    func textFieldEndEditingAct(_ textField: UITextField) {
        if textField.tag == 0 {
            self.profileData?.fullName = textField.text!
        }
    }
}
extension EditProfileViewController: ImageDelegate {

    func didSelect(image: UIImage?) {
        self.navigationController?.isNavigationBarHidden = false
        if image != nil {
            Utility.shared.startAnimation(viewController: self)
            CallParsingFunction().uploadImage(url: UPLOAD_IMAGE_URL, type: "user", image: image, onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                DispatchQueue.main.async {
                    self.navigationController?.isNavigationBarHidden = false
                    Utility.shared.stopAnimation(viewController: self)
                    if success["status"].boolValue {
                        self.profileData?.userImg = success["Image","Name"].stringValue
                        self.tableView.reloadData()
                    }
                    else {
                        let alert = UIAlertController(title: nil, message: getLanguage["Image cannot be uploaded"] ?? "Image cannot be uploaded", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: { (UIAlertAction) in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }) { (failure) in
                
            }
        }
    }
    func convertToJSON(_ images: [String]) -> (String) {
        let data = try! JSONSerialization.data(withJSONObject: images, options:.prettyPrinted)
        let jsonStr  = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return (jsonStr ?? "")
    }
}
extension EditProfileViewController {
    func locationAct(city: String, state: String, country: String,countryCode: String, lat: String, long: String, location: String) {
        self.profileData?.location = location
        self.profileData?.city = city
        self.profileData?.state = state
        self.profileData?.country = country
        self.tableView.reloadData()
    }
}
extension EditProfileViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print(error?.localizedDescription ?? "")
        if error == nil {
            print(authDataResult?.user.phoneNumber ?? "")
            let phonenumber = authDataResult?.user.phoneNumber ?? ""
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumbers = try phoneNumberKit.parse(authDataResult?.user.phoneNumber ?? "")
                if (self.profileData?.mobileNo ?? "") != "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)" {
                    self.profileData?.mobileNo = "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
                    if (self.profileData?.userImg ?? "").contains("/logo/") {
                        self.profileData?.userImg = ""
                    }
                    self.viewModel.editProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", email: self.profileData?.email ?? "", full_name: self.profileData?.fullName ?? "", first_name: "", last_name: "", mobile_no: self.profileData?.mobileNo ?? "", isFromFB: 2, show_mobile_no: self.profileData?.showMobileNo ?? false, user_img: self.profileData?.userImg ?? "", fb_profileurl: "", facebook_id: self.profileData?.facebookId ?? "", fb_phone: "", country_name: self.profileData?.country ?? "", city_name: self.profileData?.city ?? "", state_name: self.profileData?.state ?? "", onSuccess: { (success) in
                        Utility.shared.stopAnimation(viewController: self)
                        if !success {
                            let alert = UIAlertController(title: nil, message: self.viewModel.tosModel?.message ?? "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                                if success {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            self.loadData()
                        }
                    }) { (failure) in
                        Utility.shared.stopAnimation(viewController: self)
                    }
                    self.profileData?.verification.mobNo = true
                    self.tableView.reloadData()
                }
            }
            catch {
//                cc
//                    self.viewModel.editProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", email: self.profileData?.email ?? "", full_name: self.profileData?.fullName ?? "", first_name: "", last_name: "", mobile_no:phonenumber, isFromFB: 2, show_mobile_no: self.profileData?.showMobileNo ?? false, user_img: self.profileData?.userImg ?? "", fb_profileurl: "", facebook_id: self.profileData?.facebookId ?? "", fb_phone: "", country_name: self.profileData?.country ?? "", city_name: self.profileData?.city ?? "", state_name: self.profileData?.state ?? "", onSuccess: { (success) in
//                        Utility.shared.stopAnimation(viewController: self)
//                        if !success {
//                            let alert = UIAlertController(title: nil, message: self.viewModel.tosModel?.message ?? "", preferredStyle: .alert)
//                            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
//                                if success {
//                                    self.navigationController?.popViewController(animated: true)
//                                }
//                            }))
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                        else {
//                            self.loadData()
//                        }
//                    }) { (failure) in
//                        Utility.shared.stopAnimation(viewController: self)
//                    }
//                    self.profileData?.verification.mobNo = true
//                    self.tableView.reloadData()
//                }
                
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
extension EditProfileViewController {
  
  private func handleFacebookAuthentication() {
    let loginManager = LoginManager()
    loginManager.logOut()
    loginManager.logIn(permissions: ["email", "public_profile"], from: self) { (result, error) in
        if error != nil {
            return
        }
        guard let token = AccessToken.current else {
            print("Failed to get access token")
            return
        }
        print("AppID\(token.appID)")
      
      GraphRequest(graphPath: "me", parameters: ["fields": "id,name,first_name,last_name,email,birthday,gender,location,hometown,about,likes,work,education,picture,photos"]).start(completionHandler: { (connection, result, error) -> Void in
          if (error == nil), let result = result as? [String: Any], let email = result["email"] as? String {
            print("Email:: \(result)")
            let resJson = JSON(result)
            Utility.shared.startAnimation(viewController: self)
            if (self.profileData?.userImg ?? "").contains("/logo/") {
                self.profileData?.userImg = ""
            }
              self.viewModel.editProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", email: email, full_name: self.profileData?.fullName ?? "", first_name: resJson["first_name"].stringValue, last_name: resJson["last_name"].stringValue, mobile_no: self.profileData?.mobileNo ?? "", isFromFB: 1, show_mobile_no: self.profileData?.showMobileNo ?? false, user_img: self.profileData?.userImg ?? "", fb_profileurl: resJson["picture","data","url"].stringValue, facebook_id: resJson["id"].stringValue, fb_phone: "", country_name: self.profileData?.country ?? "", city_name: self.profileData?.city ?? "", state_name: self.profileData?.state ?? "", onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                if !success {
                    let alert = UIAlertController(title: nil, message: self.viewModel.tosModel?.message ?? "", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                        if success {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.loadData()
                }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
          }
      })
    }
  }
}
