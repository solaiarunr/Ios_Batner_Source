//
//  EditProfileViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 13/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import SafariServices
import AuthenticationServices
//import FirebaseUI
import PhoneNumberKit
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON
import Photos
import FirebaseAuth
import FirebaseAuthUI
import FirebasePhoneAuthUI

class EditProfileViewController: UIViewController, customLocationDelegate, PayStackPaymentDelegate, PHPhotoLibraryChangeObserver, SFSafariViewControllerDelegate, ASWebAuthenticationPresentationContextProviding {
    func backaction(isfrom: String) {
        
    }
    
    func successaction(isfrom: String) {
        self.viewModel.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            DispatchQueue.main.async {
                if success {
                    if let profileData = self.viewModel.profileModel?.result {
                        self.profileData = profileData
                        self.tableView.reloadData()
                    }
                }
            }
        }) { (failure) in
        }
    }

    // SFSafariViewController fallback: called when user taps Done
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if shouldReloadProfileAfterStripe {
            shouldReloadProfileAfterStripe = false
            self.loadData()
        }
    }

    // Required for ASWebAuthenticationSession
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }

    // MARK: - Stripe Connect
    // ✅ Uses system Safari browser — handles cross-domain cookies correctly
    // ✅ Detects return_url redirect exactly like old WKWebView (PaystackViewController) did
    // ✅ Works for BOTH: verified=true (dashboard login_link) AND verified=false (onboarding)
    private var stripeAuthSession: ASWebAuthenticationSession?

    func openStripeConnect(url stripeURLString: String, returnURL returnURLString: String) {
        guard let stripeURL = URL(string: stripeURLString) else { return }

        // callbackURLScheme = "https" — intercepts when Stripe redirects to returnurl
        let session = ASWebAuthenticationSession(
            url: stripeURL,
            callbackURLScheme: "https"
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let callbackURL = callbackURL {
                    let callbackStr = callbackURL.absoluteString
                    print("Stripe callback: \(callbackStr)")
                    // Detect return_url — same as old WKWebView didFinish check
                    if callbackStr.hasPrefix(returnURLString) ||
                       callbackStr.contains("stripesuccess") {
                        self.shouldReloadProfileAfterStripe = false
                        self.successaction(isfrom: "edit_profile") // ← same as old delegate
                    }
                } else if let err = error as? ASWebAuthenticationSessionError,
                          err.code == .canceledLogin {
                    // User tapped Cancel / X — same as back button in old WebView
                    self.shouldReloadProfileAfterStripe = false
                }
            }
        }
        // false = share cookies with Safari — critical for Stripe cross-domain redirect
        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = self
        self.stripeAuthSession = session
        session.start()
    }
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private let footerWrapperView = UIView()
    private let disclaimerContainerView = UIView()
    private let disclaimerIndicatorBar = UIView()
    private let disclaimerTextView = LinkOnlyTextView()
    var profileData: ProfileResultModel?
    var imagePicker: ImagePicker!
    let authUI = FUIAuth.defaultAuthUI()
    var viewModel = ProfileViewModel()
    private var videoFetchResult: PHFetchResult<PHAsset>?
    private var shouldReloadProfileAfterStripe = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        self.navigationController?.isNavigationBarHidden = false
        self.applyDisclaimerText()
        if self.shouldReloadProfileAfterStripe {
            self.shouldReloadProfileAfterStripe = false
            self.loadData()
        }
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
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 180
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50
        self.saveButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.saveButton.cornerMiniumRadius()
        self.saveButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "save")
        self.setupDisclaimerFooter()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
        ]
        Utility.shared.configureFirebaseAuthLanguage(authUI: self.authUI)
        self.authUI?.providers = providers
        self.authUI?.delegate = self
        self.loadData()
    }
    func loadData() {
        self.viewModel.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            DispatchQueue.main.async {
                if success {
                    if let profileData = self.viewModel.profileModel?.result {
                        self.profileData = profileData
                        self.tableView.reloadData()
                    }
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateFooterViewHeight()
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

    private func setupDisclaimerFooter() {
        footerWrapperView.backgroundColor = .clear

        disclaimerContainerView.translatesAutoresizingMaskIntoConstraints = false
        disclaimerContainerView.backgroundColor = UIColor(red: 125/255, green: 189/255, blue: 0/255, alpha: 0.215)
        disclaimerContainerView.layer.borderColor = UIColor(named: "AppThemeColorNew")?.cgColor
        disclaimerContainerView.layer.borderWidth = 0.5
        disclaimerContainerView.layer.cornerRadius = 5
        disclaimerContainerView.clipsToBounds = true

        disclaimerIndicatorBar.translatesAutoresizingMaskIntoConstraints = false
        disclaimerIndicatorBar.backgroundColor = UIColor(named: "AppThemeColorNew")
        disclaimerContainerView.addSubview(disclaimerIndicatorBar)

        disclaimerTextView.translatesAutoresizingMaskIntoConstraints = false
        disclaimerTextView.isEditable = false
        disclaimerTextView.isScrollEnabled = false
        disclaimerTextView.showsVerticalScrollIndicator = false
        disclaimerTextView.showsHorizontalScrollIndicator = false
        disclaimerTextView.dataDetectorTypes = []
        disclaimerTextView.backgroundColor = .clear
        disclaimerTextView.textContainerInset = .zero
        disclaimerTextView.textContainer.lineFragmentPadding = 0
        disclaimerTextView.textContainer.maximumNumberOfLines = 0
        disclaimerTextView.textContainer.lineBreakMode = .byWordWrapping
        disclaimerTextView.delegate = self
        disclaimerTextView.isUserInteractionEnabled = true
        disclaimerTextView.isSelectable = true
        disclaimerTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        disclaimerTextView.setContentHuggingPriority(.required, for: .vertical)
        disclaimerContainerView.addSubview(disclaimerTextView)

        footerWrapperView.addSubview(disclaimerContainerView)

        NSLayoutConstraint.activate([
            disclaimerIndicatorBar.leadingAnchor.constraint(equalTo: disclaimerContainerView.leadingAnchor),
            disclaimerIndicatorBar.topAnchor.constraint(equalTo: disclaimerContainerView.topAnchor),
            disclaimerIndicatorBar.bottomAnchor.constraint(equalTo: disclaimerContainerView.bottomAnchor),
            disclaimerIndicatorBar.widthAnchor.constraint(equalToConstant: 3),

            disclaimerTextView.leadingAnchor.constraint(equalTo: disclaimerIndicatorBar.trailingAnchor, constant: 6),
            disclaimerTextView.trailingAnchor.constraint(equalTo: disclaimerContainerView.trailingAnchor, constant: -6),
            disclaimerTextView.topAnchor.constraint(equalTo: disclaimerContainerView.topAnchor, constant: 6),
            disclaimerTextView.bottomAnchor.constraint(equalTo: disclaimerContainerView.bottomAnchor, constant: -6),

            disclaimerContainerView.topAnchor.constraint(equalTo: footerWrapperView.topAnchor, constant: 12),
            disclaimerContainerView.leadingAnchor.constraint(equalTo: footerWrapperView.leadingAnchor, constant: 10),
            disclaimerContainerView.trailingAnchor.constraint(equalTo: footerWrapperView.trailingAnchor, constant: -10),
            disclaimerContainerView.bottomAnchor.constraint(equalTo: footerWrapperView.bottomAnchor, constant: -15)
        ])

        applyDisclaimerText()
        updateFooterViewHeight()
    }

    private func updateFooterViewHeight() {
        let targetWidth = tableView.bounds.width > 0 ? tableView.bounds.width : UIScreen.main.bounds.width
        guard targetWidth > 0 else { return }
        let size = footerWrapperView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let newHeight = ceil(size.height)
        if abs(footerWrapperView.frame.height - newHeight) > 0.5 || abs(footerWrapperView.frame.width - targetWidth) > 0.5 {
            footerWrapperView.frame = CGRect(x: 0, y: 0, width: targetWidth, height: newHeight)
            tableView.tableFooterView = footerWrapperView
        }
    }

    private func applyDisclaimerText() {
        disclaimerContainerView.layer.borderColor = UIColor(named: "AppThemeColorNew")?.cgColor
        disclaimerIndicatorBar.backgroundColor = UIColor(named: "AppThemeColorNew")

        let fullText = getLanguage["Uponregistration"] ?? ""
        let bodyFont = UIFont(name: APP_FONT_REGULAR, size: 12) ?? UIFont.systemFont(ofSize: 12)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: bodyFont,
                .foregroundColor: UIColor(named: "AppTextColor") ?? .white,
                .paragraphStyle: paragraphStyle
            ]
        )

        let linkRange = termsLinkRange(in: fullText)
        if linkRange.location != NSNotFound {
            attributedString.addAttribute(
                .link,
                value: "https://batner.com/message/help?details=terms-and-policy",
                range: linkRange
            )
        }

        disclaimerTextView.linkTextAttributes = [
            .foregroundColor: UIColor(named: "AppThemeColorNew") ?? UIColor.green,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont(name: APP_FONT_BOLD, size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        ]
        disclaimerTextView.attributedText = attributedString
        disclaimerTextView.invalidateIntrinsicContentSize()
        updateFooterViewHeight()
    }

    private func termsLinkRange(in fullText: String) -> NSRange {
        let linkCandidates = [
            "View Terms & Policy",
            "Zobrazit podmínky a zásady",
            "Zobacz Regulamin i Politykę",
            "Zobraziť podmienky a zásady"
        ]
        for candidate in linkCandidates {
            let range = (fullText as NSString).range(of: candidate)
            if range.location != NSNotFound {
                return range
            }
        }
        return NSRange(location: NSNotFound, length: 0)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        disclaimerContainerView.layer.borderColor = UIColor(named: "AppThemeColorNew")?.cgColor
        disclaimerIndicatorBar.backgroundColor = UIColor(named: "AppThemeColorNew")
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
                self.shouldReloadProfileAfterStripe = true
                // verified=true  → login_link URL → Dashboard opens directly
                // verified=false → onboarding URL → Setup page opens
                self.openStripeConnect(
                    url: self.viewModel.stripeModel?.url ?? "",
                    returnURL: self.viewModel.stripeModel?.returnurl ?? ""
                )
            }
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    
    @objc func newSellLabelTapped() {
        // Guard: don't show if an alert is already presented (prevents flicker)
        guard self.presentedViewController == nil else { return }

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

        // ✅ Remove OLD gesture recognizers first (prevents duplicates on cell reuse → flicker fix)
        cell.NewSellLbl.gestureRecognizers?.forEach { cell.NewSellLbl.removeGestureRecognizer($0) }

        // Only add the info tap gesture to the Stripe row (section 2, row 1)
        if indexPath.section == 2 && indexPath.row == 1 {
            cell.NewSellLbl.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newSellLabelTapped))
            cell.NewSellLbl.addGestureRecognizer(tapGesture)
        } else {
            cell.NewSellLbl.isUserInteractionEnabled = false
        }



        if indexPath.section == 2 && indexPath.row == 4 {
            cell.isHidden = true
        }
        else if indexPath.section == 2 && indexPath.row == 5 {
            cell.isHidden = (self.profileData?.mobileNo ?? "") == ""
        }
        else if indexPath.section == 2 && indexPath.row == 1 {
            cell.isHidden = (ADMIN_VIEW_MODEL.adminModel?.result.buynow ?? "") == "disable"
        }
        else {
            cell.isHidden = false
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
                        self.shouldReloadProfileAfterStripe = true
                        // verified=true  → login_link URL → Dashboard opens directly
                        // verified=false → onboarding URL → Setup page opens
                        self.openStripeConnect(
                            url: self.viewModel.stripeModel?.url ?? "",
                            returnURL: self.viewModel.stripeModel?.returnurl ?? ""
                        )
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
            if self.profileData?.can_access == false {
                self.presentFirebasePhoneAuth()
            } else if self.profileData?.can_access == true && self.profileData?.verification.mobNo == true {
                self.presentFirebasePhoneAuth()
            }
        }
        else if indexPath.section == 2 && indexPath.row == 4 {
            if (self.profileData?.verification.facebook == false){
                self.handleFacebookAuthentication()
            }
        }
        else if indexPath.section == 2 && indexPath.row == 6 {
            let pageObj = LanguageViewController()
            let appLanguage = UserDefaultModule.shared.getAppLanguage()
            let countryCode = UserDefaultModule.shared.getcountrycode() ?? ""
            print("appLanguage:\(appLanguage), countryCode:\(countryCode)")
            if appLanguage.lowercased() == "czech" || countryCode.lowercased() == "cz" {
                pageObj.languageArray = ["Czech", "English"]
                pageObj.languageCode = ["cs", "en"]
            } else {
                pageObj.languageArray = [appLanguage]
                if appLanguage.lowercased() == "polish" {
                    pageObj.languageCode = ["pl"]
                } else if appLanguage.lowercased() == "slovakia" {
                    pageObj.languageCode = ["sk"]
                } else {
                    pageObj.languageCode = ["en"]
                }
            }
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

    private func presentFirebasePhoneAuth() {
        UINavigationBar.appearance().tintColor = UIColor(named: "whitecolor")
        guard let authUI = FUIAuth.defaultAuthUI() else { return }
        Utility.shared.configureFirebaseAuthLanguage(authUI: authUI)

        let countryCode = UserDefaultModule.shared.getcountrycode() ?? "CZ"
        let phoneProvider: FUIPhoneAuth
        if countryCode == "CZ" {
            phoneProvider = FUIPhoneAuth(authUI: authUI, whitelistedCountries: ["CZ", "SK"])
        } else {
            phoneProvider = FUIPhoneAuth(authUI: authUI, whitelistedCountries: [countryCode])
        }
        phoneProvider.defaultCountryCode = countryCode
        authUI.providers = [phoneProvider]
        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
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
        print("location1",location)
        print("city1",city)
        print("state1",state)
        print("country1",country)
        let fullLocation = [city, state, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        self.profileData?.location = fullLocation
        self.profileData?.city = city
        self.profileData?.state = state
        self.profileData?.country = country
        self.tableView.reloadData()
    }
}
//extension EditProfileViewController: FUIAuthDelegate {
//    @nonobjc func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
//        print(error?.localizedDescription ?? "")
//        if error == nil {
//            print(authDataResult?.user.phoneNumber ?? "")
//            let phonenumber = authDataResult?.user.phoneNumber ?? ""
//            let phoneNumberKit = PhoneNumberKit()
//            do {
//                let phoneNumbers = try phoneNumberKit.parse(authDataResult?.user.phoneNumber ?? "")
//                if (self.profileData?.mobileNo ?? "") != "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)" {
//                    self.profileData?.mobileNo = "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
//                    if (self.profileData?.userImg ?? "").contains("/logo/") {
//                        self.profileData?.userImg = ""
//                    }
//                    self.viewModel.editProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", email: self.profileData?.email ?? "", full_name: self.profileData?.fullName ?? "", first_name: "", last_name: "", mobile_no: self.profileData?.mobileNo ?? "", isFromFB: 2, show_mobile_no: self.profileData?.showMobileNo ?? false, user_img: self.profileData?.userImg ?? "", fb_profileurl: "", facebook_id: self.profileData?.facebookId ?? "", fb_phone: "", country_name: self.profileData?.country ?? "", city_name: self.profileData?.city ?? "", state_name: self.profileData?.state ?? "", onSuccess: { (success) in
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
//            }
//            catch {
////                cc
////                    self.viewModel.editProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", email: self.profileData?.email ?? "", full_name: self.profileData?.fullName ?? "", first_name: "", last_name: "", mobile_no:phonenumber, isFromFB: 2, show_mobile_no: self.profileData?.showMobileNo ?? false, user_img: self.profileData?.userImg ?? "", fb_profileurl: "", facebook_id: self.profileData?.facebookId ?? "", fb_phone: "", country_name: self.profileData?.country ?? "", city_name: self.profileData?.city ?? "", state_name: self.profileData?.state ?? "", onSuccess: { (success) in
////                        Utility.shared.stopAnimation(viewController: self)
////                        if !success {
////                            let alert = UIAlertController(title: nil, message: self.viewModel.tosModel?.message ?? "", preferredStyle: .alert)
////                            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
////                                if success {
////                                    self.navigationController?.popViewController(animated: true)
////                                }
////                            }))
////                            self.present(alert, animated: true, completion: nil)
////                        }
////                        else {
////                            self.loadData()
////                        }
////                    }) { (failure) in
////                        Utility.shared.stopAnimation(viewController: self)
////                    }
////                    self.profileData?.verification.mobNo = true
////                    self.tableView.reloadData()
////                }
//                
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
extension EditProfileViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print(error?.localizedDescription ?? "")
        if error == nil {
            let phonenumber = user?.phoneNumber ?? ""
            print(phonenumber)
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumbers = try phoneNumberKit.parse(phonenumber, ignoreType: true)
                if (self.profileData?.mobileNo ?? "") != "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)" {
                    self.profileData?.mobileNo = "\(phoneNumbers.countryCode)\(phoneNumbers.nationalNumber)"
                    if (self.profileData?.userImg ?? "").contains("/logo/") {
                        self.profileData?.userImg = ""
                    }
                    self.viewModel.editProfileData(
                        user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "",
                        email: self.profileData?.email ?? "",
                        full_name: self.profileData?.fullName ?? "",
                        first_name: "",
                        last_name: "",
                        mobile_no: self.profileData?.mobileNo ?? "",
                        isFromFB: 2,
                        show_mobile_no: self.profileData?.showMobileNo ?? false,
                        user_img: self.profileData?.userImg ?? "",
                        fb_profileurl: "",
                        facebook_id: self.profileData?.facebookId ?? "",
                        fb_phone: "",
                        country_name: self.profileData?.country ?? "",
                        city_name: self.profileData?.city ?? "",
                        state_name: self.profileData?.state ?? "",
                        onSuccess: { (success) in
                            Utility.shared.stopAnimation(viewController: self)
                            if !success {
                                let alert = UIAlertController(title: nil, message: self.viewModel.tosModel?.message ?? "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                self.profileData?.mobileNo = ""
                                self.profileData?.verification.mobNo = false
                                
                            } else {
                                self.loadData()
                                self.profileData?.verification.mobNo = true
                            }
                        }) { (failure) in
                            Utility.shared.stopAnimation(viewController: self)
                        }
                    
                    self.tableView.reloadData()
                }
            } catch {
                print("Phone number parse error\(error)")
            }
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

extension EditProfileViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        print("✅ Terms clicked:", URL)
        UIApplication.shared.open(URL)
        return false
    }
}
