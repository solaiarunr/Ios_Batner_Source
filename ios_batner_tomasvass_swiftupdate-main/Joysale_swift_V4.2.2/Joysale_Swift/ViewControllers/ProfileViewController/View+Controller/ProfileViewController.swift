//
//  ProfileViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Network

class ProfileViewController: UIViewController, CountryCodeDelegate {
    func selectedCode(cc: String, cn: String) {
        
    }
    

    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var profileArr = [String]()
    var viewModel = ProfileViewModel()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let monitor = NWPathMonitor()
   var bannerView1: GADBannerView!
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    var signupModel: SignupModel?
    override func viewDidLoad() {
        super.viewDidLoad()
         
        self.view.addSubview(indicatorView)
        Utility.shared.startAnimation(viewController: self)
        self.configUI()
    }

    func configUI() {
        self.tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        self.tableView.register(UINib(nibName: "ProfileHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderTableViewCell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50
        self.checkAdStatusAndLoadBanner()
        /***Addons***/
//        self.loadBannerView()
     }
    
        override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        Utility.shared.setBadge(vc: self)
        self.updateTheme(page: "present")
        self.loadData()
        self.checkAdStatusAndLoadBanner()
    }
    
    func loadBannerView() {
//        self.bannerView.isHidden = true
//        if (ADMIN_VIEW_MODEL.adminModel?.result.googleAds ?? "").lowercased() == "enable" {
            // MARK: Banner Ads AddOn
        
            bannerView1 = GADBannerView(adSize: GADAdSizeBanner)
            bannerView1.translatesAutoresizingMaskIntoConstraints = false
            bannerView.addSubview(bannerView1)
            bannerView1.leftAnchor.constraint(equalTo: bannerView.leftAnchor, constant: 0).isActive = true
            bannerView1.rightAnchor.constraint(equalTo: bannerView.rightAnchor, constant: 0).isActive = true
            bannerView1.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 0).isActive = true
            bannerView1.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 0).isActive = true
        self.bannerView.isHidden = false
            self.bannerView1.frame  = self.bannerView.bounds
            self.bannerView1.adUnitID = BANNNER_ID
            self.bannerView1.rootViewController = self
            self.bannerView1.load(GADRequest())
            self.bannerView1.delegate = self
//        }
 
    }
    func checkAdStatusAndLoadBanner() {
        if Ad_Status {
            self.loadBannerView()
        }else{
            self.bannerView.isHidden = true
        }
    }
    func loadData() {
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                print("Internet connection is on.")
                let group = DispatchGroup()
                group.enter()
                self.viewModel.getProfileData(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), user_name: "",profile_id: "", onSuccess: { (success) in
                    print(success)
                    Utility.shared.stopAnimation(viewController: self)
                    self.tableView.reloadData()
                    group.leave()
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                    group.leave()
                }
        //        group.enter()
        //        ADMIN_VIEW_MODEL.getAdminData(onSuccess: { (success) in
        //            print(success)
        //            self.tableView.reloadData()
        //            group.leave()
        //        }) { (failure) in
        //            group.leave()
        //        }
                group.notify(queue: DispatchQueue.main) {
                    self.profileArr.removeAll()
                    self.profileArr.append("")
                    if PAID_BANNER_FLAG {
//                        self.profileArr.append("advertise")
                    }
                    self.profileArr.append("notifications")
                    if BUYNOW_MODEL_FLAG {
                        self.profileArr.append("myordersale")
                    }
                    if PROMOTION_FLAG {
                        self.profileArr.append("my_promotions")
                    }
                    if EXCHANGE_MODEL_FLAG {
                        self.profileArr.append("myexchange")
                    }
//                    self.profileArr.append("my_subscription")
                    
                     if BUYNOW_MODEL_FLAG {
                       self.profileArr.append("addressbook")
                    }
                    self.profileArr.append("credit")
                    self.profileArr.append("help")
                    self.profileArr.append("Invite friends")
                    self.profileArr.append("PremiumFeatures")
                    self.profileArr.append("AdPremium")
                    self.profileArr.append("logout")
                    self.profileArr.append("delete_account")
                    self.tableView.reloadData()
                }
            } else {
                print("There's no internet connection.")
            }
        }
        monitor.start(queue: queue)
    }
    func deleteAccount(user_id: String) {
        let parameter: [String: Any] = ["user_id": user_id]
        let loginType = UserDefaultModule.shared.getType()
        print("loginType check \(loginType)")
        if loginType == "Apple" {
            let urlString = "https://appleid.apple.com/auth/revoke"
                    let url = NSURL(string: urlString)!
                    let paramString: [String : Any] = [
                        "client_id": UserDefaultModule.shared.getClientId()!,
                        "client_secret": UserDefaultModule.shared.getClientSecret()!,
                        "token": UserDefaultModule.shared.getAccesssToken()!,
                        "token_type_hint": UserDefaultModule.shared.getTokenType()!
                    ]

            print("BASE URL : \(url)")
            print("PARAMS : \(paramString)")
            
                    let request = NSMutableURLRequest(url: url as URL)
                    request.httpMethod = "POST"
                    request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")


                    let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                            guard
                                let response = response as? HTTPURLResponse,
                                error == nil
                            else {                                                               // check for fundamental networking error
                                print("error", error ?? URLError(.badServerResponse))
                                return
                            }

                            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                                print("statusCode should be 2xx, but is \(response.statusCode)")
                                print("response = \(response)")
                                return
                            }


                        if let error = error {
                            print(error)
                        }else{
                            UserDefaultModule.shared.setType(key: "")
                        }
                    }
                    task.resume()
            CallParsingFunction().postDataCall(subURl: DELETE_ACCOUNT, params: parameter, onSuccess: { (response) in
                let rootClass = SignupModel.init(fromJson: response)
                self.signupModel = rootClass
                if rootClass.status == true {
                    let messageAlert = UIAlertController(title: getLanguage["alert"], message: rootClass.message, preferredStyle: .alert)
                    self.present(messageAlert, animated: true, completion: nil)
                    let fcmToken = UserDefaultModule.shared.getFCMToken()
                    let voipToken = UserDefaultModule.shared.getPushToken()
                    let appFirst = UserDefaultModule.shared.getAppFirst()
                    let appLanguage = UserDefaultModule.shared.getAppLanguage()
                    let domain = Bundle.main.bundleIdentifier
                    UserDefaults.standard.removePersistentDomain(forName: domain ?? "")
                    UserDefaults.standard.synchronize()
                    UserDefaultModule.shared.setAppFirst(appFirst)
                    UserDefaultModule.shared.setFCMToken(fcm_token: fcmToken ?? "")
                    UserDefaultModule().setAppLanguage(language: appLanguage)
                    UserDefaults.standard.set(APP_RTC_URL, forKey: "web_rtc_web")
                    UserDefaultModule().setPushToken(fcm_token: voipToken ?? "")
                    self.delegate.initVC(initialView: InitialViewController())
                } else {
                    let messageAlert = UIAlertController(title: getLanguage["alert"], message: rootClass.message, preferredStyle: .alert)
                    messageAlert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                    self.present(messageAlert, animated: true, completion: nil)
                }
            }) { (error) in
            }
            
            
        } else {
            CallParsingFunction().postDataCall(subURl: DELETE_ACCOUNT, params: parameter, onSuccess: { (response) in
                let rootClass = SignupModel.init(fromJson: response)
                self.signupModel = rootClass
                if rootClass.status == true {
                    let messageAlert = UIAlertController(title: getLanguage["alert"], message: rootClass.message, preferredStyle: .alert)
                    self.present(messageAlert, animated: true, completion: nil)
                    let fcmToken = UserDefaultModule.shared.getFCMToken()
                    let voipToken = UserDefaultModule.shared.getPushToken()
                    let appFirst = UserDefaultModule.shared.getAppFirst()
                    let appLanguage = UserDefaultModule.shared.getAppLanguage()
                    let domain = Bundle.main.bundleIdentifier
                    UserDefaults.standard.removePersistentDomain(forName: domain ?? "")
                    UserDefaults.standard.synchronize()
                    UserDefaultModule.shared.setAppFirst(appFirst)
                    UserDefaultModule.shared.setFCMToken(fcm_token: fcmToken ?? "")
                    UserDefaultModule().setAppLanguage(language: appLanguage)
                    UserDefaults.standard.set(APP_RTC_URL, forKey: "web_rtc_web")
                    UserDefaultModule().setPushToken(fcm_token: voipToken ?? "")
                    self.delegate.initVC(initialView: InitialViewController())
                } else {
                    let messageAlert = UIAlertController(title: getLanguage["alert"], message: rootClass.message, preferredStyle: .alert)
                    messageAlert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                    self.present(messageAlert, animated: true, completion: nil)
                }
            }) { (error) in
            }

        }

    }
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.profileArr.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (self.profileArr.count - 1) {
            return 0
        }
        return 6
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if UserDefaultModule.shared.getTheme() == "Dark"{
            footerView.backgroundColor = UIColor(named: "BackGroundColorNew")
        }else{
            footerView.backgroundColor = #colorLiteral(red: 0.9567790627, green: 0.9569163918, blue: 0.956749022, alpha: 1)
        }
       
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        return 55
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell") as! ProfileHeaderTableViewCell
            cell.loadData(self.viewModel.profileModel?.result)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
            cell.titleLabel.textColor = UIColor(named: "AppTextColor")
            cell.isHidden = false
            cell.notificationButton.isHidden = true
            cell.titleLabel.text = getLanguage[self.profileArr[indexPath.section]]
            

            let key = self.profileArr[indexPath.section]

            switch key {
            case "advertise":
              cell.arrowImageView.image = #imageLiteral(resourceName: "ad_annocement")
                cell.titleLabel.textColor = UIColor(named: "AppThemeColorNew")

            case "notifications":
                if (ADMIN_VIEW_MODEL.getCountModel?.notificationCount ?? 0) > 0 {
                    cell.notificationButton.isHidden = false
                    cell.notificationButton.setTitle("\(ADMIN_VIEW_MODEL.getCountModel?.notificationCount ?? 0)", for: .normal)
                } else {
                    cell.notificationButton.isHidden = true
                }
                cell.arrowImageView.image = #imageLiteral(resourceName: "InArrowImg")

            case "logout":
                cell.arrowImageView.image = #imageLiteral(resourceName: "logout")

            case "AdPremium":
                cell.arrowImageView.image = #imageLiteral(resourceName: "InArrowImg")
                
            case "PremiumFeatures":
                cell.arrowImageView.image = #imageLiteral(resourceName: "InArrowImg")
                
            case "delete_account":
                cell.arrowImageView.image = #imageLiteral(resourceName: "Delete_icon")
            case "credit":
                if self.viewModel.profileModel?.result.credit_balance != "0" {
                    cell.notificationButton.isHidden = false
                    cell.notificationButton.setTitle("\(self.viewModel.profileModel?.result.credit_balance ?? "0")Kč", for: .normal)
                } else {
                    cell.notificationButton.isHidden = true
                }


            default:
                cell.arrowImageView.image = #imageLiteral(resourceName: "InArrowImg")
            }
            return cell
        }
    }

    func checkAdStatusAndLoadBannerApiCall() {
        ADMIN_VIEW_MODEL.GetAdStatus(
            user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "",
            onSuccess: { success in
                if success == "true",
                   ADMIN_VIEW_MODEL.adModel?.adstatus == "enable" {
                    Ad_Status = true
                } else {
                    Ad_Status = false
                }
                
                DispatchQueue.main.async {
                    self.checkAdStatusAndLoadBanner()
                }
                
            }, onFailure: { error in
                Ad_Status = true
                DispatchQueue.main.async {
                    self.checkAdStatusAndLoadBanner()
                }
            }
        )
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let pageObj = ViewProfileViewController()
            pageObj.viewModel = self.viewModel
            pageObj.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
            pageObj.modalPresentationCapturesStatusBarAppearance = true
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
        if self.profileArr[indexPath.section] == "advertise" {
            let pageObj = BannerViewController()
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
        if self.profileArr[indexPath.section] == "my_promotions" {
            let pageObj = MyPromotionViewController()
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
        if self.profileArr[indexPath.section] == "notifications" {
            let pageObj = NotificationViewController()
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
        if self.profileArr[indexPath.section] == "myexchange" {
            let pageObj = ExchangeListViewController()
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
        
        if self.profileArr[indexPath.section] == "PremiumFeatures" {
             let pageObj = PremiumPromoVc()
             pageObj.onPremiumActivated = { [weak self] in
                 print("🔥 Premium activated — refreshing Page A")
             }
             self.delegate.navigationController.pushViewController(pageObj, animated: true)
           
        }
        
        if self.profileArr[indexPath.section] == "AdPremium" {
             let pageObj = PremiumAdvc()
             pageObj.onPremiumActivated = { [weak self] in
                 print("🔥 AD Premium activated — refreshing Page A")
                 self?.checkAdStatusAndLoadBannerApiCall()
                 self?.checkAdStatusAndLoadBanner()
             }
             self.delegate.navigationController.pushViewController(pageObj, animated: true)
           
        }
        
        
        if self.profileArr[indexPath.section] == "my_subscription"{
            /*
            let pageObj = SubcriptionDetailPage()
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
            */
 
        }
        else if self.profileArr[indexPath.section] == "addressbook" {
          
            let pageObj = AddressListViewController()
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
            
            
        }
        else if self.profileArr[indexPath.section] == "Invite friends" {
            let pageObj = InviteViewController()
            pageObj.isModalInPopover = true
            pageObj.modalPresentationStyle = .overCurrentContext
            self.delegate.navigationController.present(pageObj, animated: true, completion: nil)
        }
        else if self.profileArr[indexPath.section] == "myordersale" {
            
            let pageObj = MyOrderSegmentViewController()
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        
        }
        else if self.profileArr[indexPath.section] == "help" {
            let pageObj = HelpViewController()
            pageObj.viewType = "help"
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
        else if self.profileArr[indexPath.section] == "credit" {
            let pageObj = CreditsVC()
            pageObj.referral_code_locked = self.viewModel.profileModel?.result.referral_code_locked ?? false
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
        else if self.profileArr[indexPath.section] == "logout" {
            let alert = UIAlertController(title: "", message: getLanguage["reallySignOut"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["yes"] ?? "", style: .default, handler: { (UIAlertAction) in
                ADMIN_VIEW_MODEL.pushSignout()
                let fcmToken = UserDefaultModule.shared.getFCMToken()
                let voipToken = UserDefaultModule.shared.getPushToken()
                let appFirst = UserDefaultModule.shared.getAppFirst()
                let appcountryname = UserDefaultModule.shared.getcountryname()
                let appcountrycode = UserDefaultModule.shared.getcountrycode()
                let appLanguage = UserDefaultModule.shared.getAppLanguage()
                
                let baseonlyurl = UserDefaultModule.shared.getbaseurlonly()
                let baseurl = UserDefaultModule.shared.getbaseurl()
                let setChaturl = UserDefaultModule.shared.getchaturl()
                let setstreamurl = UserDefaultModule.shared.getstreamurl()
                let domain = Bundle.main.bundleIdentifier
                UserDefaults.standard.removePersistentDomain(forName: domain ?? "")
                UserDefaults.standard.synchronize()
                UserDefaultModule.shared.setCountrycode(code:appcountrycode ?? "")
                UserDefaultModule.shared.setCountryname(country:appcountryname ?? "")
                UserDefaultModule.shared.setAppFirst(appFirst)
                UserDefaultModule.shared.setFCMToken(fcm_token: fcmToken ?? "")
                UserDefaultModule().setAppLanguage(language: appLanguage)
                UserDefaults.standard.set(APP_RTC_URL, forKey: "web_rtc_web")
                UserDefaultModule().setPushToken(fcm_token: voipToken ?? "")
                UserDefaultModule.shared.setBaseonly(baseurl: baseonlyurl ?? "")
                UserDefaultModule.shared.setBase(baseurl: baseurl ?? "")
                UserDefaultModule.shared.setChaturl(chaturl: setChaturl ?? "")
                UserDefaultModule.shared.setstreamurl(streamurl: setstreamurl ?? "")
                self.delegate.initVC(initialView: InitialViewController())
            }))
            alert.addAction(UIAlertAction(title: getLanguage["no"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if self.profileArr[indexPath.section] == "delete_account" {
            print("delete clicked")
            let alert = UIAlertController(title: "", message: getLanguage["reallyDelete"] ?? "", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: getLanguage["yes"] ?? "", style: .default, handler: { (UIAlertAction) in
                self.deleteAccount(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""))
            }))
            alert.addAction(UIAlertAction(title: getLanguage["no"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController: GADBannerViewDelegate{
    //banner view delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            bannerView.isHidden = false
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.bannerView.isHidden = true
        print("BANNER ERROR \(error.localizedDescription)")
    }
}


