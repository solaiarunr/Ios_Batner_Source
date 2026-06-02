//
//  AppDelegate.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 05/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import CoreLocation
import GoogleMaps
import GooglePlaces
import Stripe
import Firebase
import SwiftyJSON
import SafariServices
import FirebaseMessaging
import UserNotifications
import PushKit
import CallKit
import AVFoundation
import AVKit
//import FirebaseDynamicLinks
import StoreKit
import RadarSDK
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var currentLoc: CLLocation!
    var currentLocation: CLPlacemark?
    lazy var geocoder = CLGeocoder()
    var navigationController = UINavigationController()
    var deviceTokenString = ""
    var newlanguagecodevalue = String()
    var chattranslate = String()
    var chattranslateCode = String()
    // CALL DECLARATION
    var callStarted = Bool()
    var baseUUId = UUID()
    var callStatus : String!
    var callController = CXCallController()
    var provider: CXProvider!
    /// The app's provider configuration, representing its CallKit capabilities.
    static let providerConfiguration: CXProviderConfiguration = {
        let localizedName = NSLocalizedString("Calling From", comment: "Joysale")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)

        // Prevents multiple calls from being grouped.
        providerConfiguration.maximumCallsPerCallGroup = 1
        
        providerConfiguration.supportsVideo = true
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        return providerConfiguration
    }()
    var callKitPopup = false
    var currentCallerID = String()
    var isAlreadyInCall = false
    var callNotifyDict: JSON!
     
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(APP_RTC_URL, forKey: "web_rtc_web")
        window = UIWindow(frame: UIScreen.main.bounds)
        SITE_URL = UserDefaultModule.shared.getbaseurl() ?? "https://batner.com/api/"
//        FULL_WIDTH = self.window?.frame.width ?? UIScreen.main.bounds.width
//        FULL_HEIGHT = self.window?.frame.height ?? UIScreen.main.bounds.height
        NetStatus.shared.startMonitoring()
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = GOOGLE_CLIENT_KEY
        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_API_KEY)
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.backgroundColor = UIColor(named: "AppThemeColor")
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
//        Settings.appID = "1679929528949335"
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Utility.shared.configureLanguage()
        UserDefaults.standard.set([DEFAULT_LANGUAGE_CODE], forKey: "AppleLanguages")
        self.loadAdminData()
        self.registerForPushNotification(application)
        self.setInitialViewController()
        Utility.shared.getCountryData()
        
        // Navigation title color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: APP_FONT_REGULAR, size: 20) ?? UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor(named: "whitecolor") ?? .black]
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
        voipRegistry.delegate = self
        self.loadProductAdminData()
//        Radar.initialize(publishableKey: "prj_live_pk_21fbe6a0dc02b9514cc34ef6a3937ec81f321b88")
        listenForTransactions()
        return true
    }
    func setInitialViewController() {
        let filterVal = UserDefaultModule.shared.getFilterData()
        if filterVal.location != "" && filterVal.location.lowercased() != "worldwide" && filterVal.location.lowercased() !=  UserDefaultModule.shared.getcountryname()?.lowercased() {
            FILTER_DATA.city = filterVal.city
            FILTER_DATA.state = filterVal.state
            FILTER_DATA.country = filterVal.country
            FILTER_DATA.location = filterVal.location
            FILTER_DATA.lat = filterVal.lat
            FILTER_DATA.long = filterVal.long
        }
        else {
            FILTER_DATA.city = ""
            FILTER_DATA.state = ""
            FILTER_DATA.country =  UserDefaultModule.shared.getcountryname()
            print("maams",UserDefaultModule.shared.getcountryname())
//            FILTER_DATA.location =  UserDefaultModule.shared.getcountryname()
            FILTER_DATA.lat = ""
            FILTER_DATA.long = ""
            self.getCurrentLocation()
        }
        
        if let userData = UserDefaultModule.shared.getUserData()?.user_id, (userData != "") {
            self.initVC(initialView: TabbarController())
        }
        else{
            if UserDefaultModule.shared.getAppFirst() == false {
                self.initVC(initialView: HelpViewController())
            }
            else {
                self.initVC(initialView: TabbarController())
            }
        }
//        setInitVCDemo()
       
    }
    
    func setInitVCDemo(){
        let initialView = DescriptionPopupVC()
        self.navigationController = UINavigationController(rootViewController: initialView)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
    }
    
    func loadProductAdminData(){
        
        var viewModel = StoryListViewModel()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        viewModel.loadAppDefaults { json in
            if json["status"].boolValue {
//                VIDEO_MAXIMUM_DURATION = (json["video_max_duration"].intValue)
//                VIDEO_MINIMUM_DURATION = (json["video_min_duration"].intValue)
//                VIDEO_MAXIMUM_SIZE = json["video_max_size"].intValue
              
                dispatchGroup.leave()
            }
        } onFailure: { failure in
            dispatchGroup.leave()
        }
    }
    //MARK: Register for push notification
    func registerForPushNotification(_ application: UIApplication)  {
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {granted, error in
          })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        // MARK: Audio and Video Call Addon
        
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
        voipRegistry.delegate = self
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        
    }
    func initVC(initialView: UIViewController) {
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        self.getCurrentLocation()
        if let tabBarController = self.window!.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 0
        }
        self.navigationController = UINavigationController(rootViewController: initialView)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        self.checkTheme()
    }
    func setInitialViewController(initialView: UIViewController)
    {
        let vc = initialView
        let window = UIWindow()
        self.window = window
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController = UINavigationController(rootViewController: initialView)
        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        self.checkTheme()
    }
    func getCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways) {
            self.locationManager.startUpdatingLocation()
            currentLoc = locationManager.location
            if currentLoc != nil {
                print(currentLoc.coordinate.latitude)
                print(currentLoc.coordinate.longitude)
                FILTER_DATA.lat = "\(currentLoc.coordinate.latitude)"
                FILTER_DATA.long = "\(currentLoc.coordinate.longitude)"
            }
            else {
                // MARK: Location based personalization
                FILTER_DATA.lat = ""
                FILTER_DATA.long = ""
            }
            
        }
    }
    func checkTheme() {
        if #available(iOS 13.0, *) {
            if UserDefaultModule.shared.getTheme() == "" || UserDefaultModule.shared.getTheme() == nil {
                UserDefaultModule.shared.setTheme(theme: "Dark")
            }
            if UserDefaultModule.shared.getTheme() == "System Default" || UserDefaultModule.shared.getTheme() == "SystemDefault" {
                let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
                if userInterfaceStyle == .dark {
                    window!.overrideUserInterfaceStyle = .dark
                    print("Dark mode is enabled")
                } else {
                    window!.overrideUserInterfaceStyle = .light
                    print("Light mode is enabled")
                }
           
            }else if UserDefaultModule.shared.getTheme() == "Dark" {
                window!.overrideUserInterfaceStyle = .dark
            }else{
                window!.overrideUserInterfaceStyle = .light
            }

        }
    }
    func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
            }
        }
    }

    

    /*instatant update
    func checkTheme() {
        if #available(iOS 13.0, *) {
            if UserDefaultModule.shared.getTheme() == "" || UserDefaultModule.shared.getTheme() == nil {
                UserDefaultModule.shared.setTheme(theme: "Dark")
            }

            if let window = UIApplication.shared.windows.first {
                if UserDefaultModule.shared.getTheme() == "System Default" || UserDefaultModule.shared.getTheme() == "SystemDefault" {
                    let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
                    window.overrideUserInterfaceStyle = (userInterfaceStyle == .dark) ? .dark : .light
                } else if UserDefaultModule.shared.getTheme() == "Dark" {
                    window.overrideUserInterfaceStyle = .dark
                } else {
                    window.overrideUserInterfaceStyle = .light
                }
                // 🔥 Force Refresh for Instant Theme Update
               refreshAppUI(window: window)
            }
        }
    }
    func refreshAppUI(window: UIWindow) {
        DispatchQueue.main.async {
            let rootVC = window.rootViewController
            window.rootViewController = nil
            window.rootViewController = rootVC
            window.makeKeyAndVisible()
        }
    }
*/
    
    func loadAdminData() {
        
        let group = DispatchGroup()
        group.enter()
        ADMIN_VIEW_MODEL.getAdminData(onSuccess: { (success) in
            print("Checking the stripe key \(ADMIN_VIEW_MODEL.adminModel?.result)")
                     StripeAPI.defaultPublishableKey = (ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? "")
            BANNNER_ID = (ADMIN_VIEW_MODEL.adminModel?.result.googleAdsIos ?? "")
            print("self.chkbanneridhome1",BANNNER_ID)
//            Stripe.setDefaultPublishableKey(ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? "")
            group.leave()
        }) { (failure) in
            group.leave()
        }
        group.enter()
        ADMIN_VIEW_MODEL.productBeforeAddData(onSuccess: { (success) in
            group.leave()
        }) { (failure) in
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            if ADMIN_VIEW_MODEL.productBeforeModel?.result != nil && ADMIN_VIEW_MODEL.adminModel?.result != nil{
                if FILTER_DATA.location != "" && FILTER_DATA.location.lowercased() != "worldwide" {
                    FILTER_DATA.distance = (ADMIN_VIEW_MODEL.productBeforeModel?.result.distance ?? "")
                    FILTER_DATA.isDistanceSlider = false
                    FILTER_DATA.distance_type = (ADMIN_VIEW_MODEL.adminModel?.result.distanceType ?? "")
                }
                DispatchQueue.main.async {
                    if ADMIN_VIEW_MODEL.adminModel?.status ?? false && (ADMIN_VIEW_MODEL.adminModel?.result.adminPaymentType ?? "") == "braintree"{
                        ADMIN_VIEW_MODEL.getBraintreeToken(currency_code: (ADMIN_VIEW_MODEL.adminModel?.result.adminCurrencyCode.trimmingCharacters(in: .whitespaces) ?? ""))
                    }
                }
            }
        }
    }
    
    
    func  loadAdstatus() {
        
        
        
    }
    
    
    
    
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("mamasm1")
        if Auth.auth().canHandle(url) {
            return true
        }
        let stripeHandled = StripeAPI.handleURLCallback(with: url)
        if (stripeHandled) {
            return true
        } else {
            // This was not a Stripe url – handle the URL normally as you would
        }
        if ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation){
            return true
        }
        else if ((GIDSignIn.sharedInstance()?.handle(url))!){
            return true
        }
        return true
        
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool{
        print("mamasm2")
        
        guard let incomingURL = userActivity.webpageURL else {
            print("Universal link URL is nil.")
            return false
        }
       
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                if (stripeHandled) {
                    return true
                } else {
                    let urlString = url.absoluteString
                    print("Incoming Universal Link:", urlString)

                    if url.pathComponents.contains("referal_code") {
                        print("Referral link detected")
                        return true
                    }
                    else if url.pathComponents.contains("stream"),
                            let stream_id = url.pathComponents.last {
                        print("Stream ID:", stream_id)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            let pageObj = StoryAllList()
                            pageObj.isFromNotification = true
                            pageObj.productModel = []
                            pageObj.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                            pageObj.fromNav = "dynamicLink"
                            pageObj.type = "after"
                            pageObj.videoID = stream_id

                            self.navigationController = UINavigationController(rootViewController: pageObj)
                            self.window?.rootViewController = self.navigationController
                            self.window?.makeKeyAndVisible()
                        }
                    }
                    else if url.pathComponents.contains("productdetail_id"),
                        let stream_id = url.pathComponents.last {
                        print("Stream ID:", stream_id)
                        let pageObj = ItemDetailsViewController()
                        pageObj.navfrom = "dynamiclink"
                        pageObj.itemID = Int(stream_id) ?? 0
                        self.navigationController = UINavigationController(rootViewController: pageObj)
                        self.window!.rootViewController = self.navigationController
                        self.window!.makeKeyAndVisible()
                    }
                    /*
                    // This was not a Stripe url – handle the URL normally as you would
                    let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
                        
                        let inviteStr = dynamiclink!.url!.absoluteString
                        print("dferg3t4y",inviteStr)
                        if inviteStr.contains("referal_code"){ // referral invite link
                            let code = dynamiclink!.url!.absoluteString.replacingOccurrences(of: "\(BASE_URL)/appstore?referal_code=", with: "")
                        }else if inviteStr.contains("productdetail_id") {
                            var myString: String = dynamiclink!.url!.absoluteString
                            var myStringArr = myString.components(separatedBy: "=")
                            let stream_id: String = myStringArr[1]
                            let pageObj = ItemDetailsViewController()
                            pageObj.navfrom = "dynamiclink"
                            pageObj.itemID = Int(stream_id) ?? 0
                            self.navigationController = UINavigationController(rootViewController: pageObj)
                            self.window!.rootViewController = self.navigationController
                            self.window!.makeKeyAndVisible()
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            var myString: String = dynamiclink!.url!.absoluteString
                            var myStringArr = myString.components(separatedBy: "=")
                            let stream_id: String = myStringArr[1]
                            let pageObj = StoryAllList()
                            pageObj.isFromNotification = true
                            let productModel = [GetItemsResult1]()
                            pageObj.productModel = productModel
                            pageObj.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                            pageObj.fromNav = "dynamicLink"
                            pageObj.type = "after"
                            pageObj.videoID = stream_id
                                self.navigationController = UINavigationController(rootViewController: pageObj)
                                self.window!.rootViewController = self.navigationController
                                self.window!.makeKeyAndVisible()
                            }

                        }
                    }
                    return handled
                     */
                }
                /*{
                    // This was not a Stripe url – handle the URL normally as you would
                    let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
                        let inviteStr = dynamiclink!.url!.absoluteString
                        if inviteStr.contains("referal_code"){ // referral invite link
                            let code = dynamiclink!.url!.absoluteString.replacingOccurrences(of: "\(BASE_URL)/appstore?referal_code=", with: "")
                            /*
                            UserModel.shared.setInvite(code: code as NSString)
                            */
                        }else{ //video invite link
                            if UserDefaultModule.shared.getUserData()?.user_id  != nil {
                                /*
                                let id = dynamiclink!.url!.absoluteString.replacingOccurrences(of: "\(BASE_URL)/appstore?stream_id=", with: "")
                                */
                                var myString: String = dynamiclink!.url!.absoluteString
                                var myStringArr = myString.components(separatedBy: "=")
                                var othercontent: String = myStringArr[0]
                                let stream_id: String = myStringArr[1]
                                let pageObj = StoryAllList()
                                pageObj.isFromNotification = true
                                let productModel = [GetItemsResult1]()
                                pageObj.productModel = productModel
                                pageObj.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                                pageObj.fromNav = "Home"
                                pageObj.type = "after"
                                pageObj.videoID = stream_id
                                self.navigationController = UINavigationController(rootViewController: pageObj)
                                self.window!.rootViewController = self.navigationController
                                self.window!.makeKeyAndVisible()
                                
                                /*
                                self.notifyDelegate?.notifyLoader(true)
                                self.getStreamInfo(stream_id: id)
                                */
                            }
                        }
                    }
                    return handled
                }
                */
            }
        }
        return false
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
//        SocketIOManager.sharedInstance.disconnect()
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.getCurrentLocation()
        self.resetBadge()
      
//        SocketIOManager.sharedInstance.establishConnection()
    }
    func resetBadge() {
        DispatchQueue.main.async {
            ADMIN_VIEW_MODEL.resetBadge(deviceToken: (UserDefaultModule.shared.getFCMToken() ?? ""))
        }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == "" {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == "" {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = manager.location else { return }
        fetchCityAndCountry(from: location) { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            print(city + ", " + country)
            self.locationManager.stopUpdatingLocation()
        }
    }
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let placeMarker = placemarks?.first {
                self.currentLocation = placeMarker
                self.currentLoc = location
                if self.currentLoc != nil {
                    print("latt: location.coordinate.latitude")
                    print(location.coordinate.longitude)
                    FILTER_DATA.lat = "\(self.currentLoc.coordinate.latitude)"
                    FILTER_DATA.long = "\(self.currentLoc.coordinate.longitude)"
                }
                else {
                    // MARK: Location based personalization
                    FILTER_DATA.lat = ""
                    FILTER_DATA.long = ""
                }
                
            }
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    // authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case CLAuthorizationStatus.restricted: break
            case CLAuthorizationStatus.denied: break
            case CLAuthorizationStatus.notDetermined:break
            default:
                locationManager.startUpdatingLocation()
        }
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate,MessagingDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let FirebaseAuth = Auth.auth()
        if (FirebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
        }
        print("UserInfo \(userInfo)")
        let notificationData = JSON(userInfo)
        print(" NOTIFICATION \(notificationData)")
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        // Step 1: Get the "data" string from userInfo
        if let dataString = userInfo["data"] as? String,
           let data = dataString.data(using: .utf8) {
            
            // Step 2: Parse the JSON string
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let type = json["type"] as? String {
                    print("type123: \(type)")
                    // Step 3: Handle based on type
                    if type == "normal" {
                        let pageObj = TabbarController()
                        pageObj.selectedIndex = 3
                        pageObj.isFromNotification = true
                        navigationController = UINavigationController(rootViewController: pageObj)
                        window!.rootViewController = navigationController
                        window!.makeKeyAndVisible()
                        
                    } else if type == "videoposted" {
                        let pageObj = ViewProfileViewController()
                        pageObj.isfrom = "appdelegate"
                        pageObj.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                        self.navigationController.pushViewController(pageObj, animated: true)
                        
                    } else {
                        let pageObj = NotificationViewController()
                        pageObj.isFromNotification = true
                        navigationController = UINavigationController(rootViewController: pageObj)
                        window!.rootViewController = navigationController
                        window!.makeKeyAndVisible()
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }

        completionHandler()
    }

//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let jsonDict = JSON(notification.request.content.userInfo)
//        print(jsonDict)
//        let type = jsonDict["gcm.notification.type"].stringValue
//        let alertArray = jsonDict["aps","alert"].stringValue.components(separatedBy: " : ")
//        print("mic testing 1 \(type)")
//        if type == "message" || type == "exchange" || type == "normal" || type == "notification" {
//            print("mic testing 1 \(type)")
//            print("mic testing 4 \(CURRENT_CHAT)")
//            print("mic testing 5 \(alertArray.first)")
//            if CURRENT_CHAT == alertArray.first ?? ""{
//                print("mic testing 2 \(CURRENT_CHAT) == \(alertArray.first)")
//            }
//            else {
//                print("mic testing 3")
//                completionHandler([.alert, .badge, .sound])
//            }
//        }else if type == "videoposted"{
//            print("videopostedwillp")
//            NotificationCenter.default.post(name: Notification.Name("ReceiveData"), object: nil)
//            completionHandler([.alert, .badge, .sound])
//        }
//        else {
//            completionHandler([.alert, .badge, .sound])
//        }
//    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        var type = ""
        var alertArray: [String] = []

        // ✅ Extract and parse the "data" field
        if let dataString = userInfo["data"] as? String,
           let data = dataString.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    type = json["type"] as? String ?? ""
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }

        // ✅ Handle alert message safely
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? String {
            alertArray = alert.components(separatedBy: " : ")
        }

        print("mic testing 1 \(type)")
        if type == "message" || type == "exchange" || type == "normal" || type == "notification" {
            print("mic testing 1 \(type)")
            print("mic testing 4 \(CURRENT_CHAT)")
            print("mic testing 5 \(alertArray.first ?? "")")
            /*
            if CURRENT_CHAT == alertArray.first ?? "" {
                print("mic testing 2 \(CURRENT_CHAT) == \(alertArray.first ?? "")")
                // Don't show banner
            } else {
                print("mic testing 3")
                completionHandler([.alert, .badge, .sound])
            }
             */
            if !CURRENT_CHAT.isEmpty,
               let firstAlert = alertArray.first,
               !firstAlert.isEmpty,
               CURRENT_CHAT == firstAlert {
                // Don't show banner
            } else {
                completionHandler([.alert, .badge, .sound])
            }

        } else if type == "videoposted" {
            print("videopostedwillp")
            NotificationCenter.default.post(name: Notification.Name("ReceiveData"), object: nil)
            completionHandler([.alert, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
    func extractType(from userInfo: [AnyHashable: Any]) -> String {
        if let dataString = userInfo["data"] as? String,
           let data = dataString.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let type = json["type"] as? String {
                    return type
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        return ""
    }


    func convertToString(_ userinfo: String) -> [String: AnyObject] {
        if userinfo != "" {
            let data = Data(userinfo.utf8)
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                    // try to read out a string array
                    return json
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        return [userinfo:("" as AnyObject)]
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let FIRAUTH = Auth.auth()
        
       #if DEBUG
        FIRAUTH.setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
       #else
        FIRAUTH.setAPNSToken(deviceToken, type: AuthAPNSTokenType.prod)
        #endif
//        FIRAUTH.setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
         Messaging.messaging().apnsToken = deviceToken
        self.deviceTokenString = deviceToken.hexString
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaultModule.shared.setFCMToken(fcm_token: "\(fcmToken ?? "")")
        print("Firebase Token: \(fcmToken ?? "")")
        if ( UserDefaultModule.shared.getFCMToken() != nil) {
            self.addDeviceTokenToServer()
        }
        
        
    }
    func addDeviceTokenToServer() {
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
            ADMIN_VIEW_MODEL.loadNotification(onSuccess: { (success) in
            }) { (failure) in
            }
        }
    }
}


//MARK: - PKPushRegistryDelegate
extension AppDelegate : PKPushRegistryDelegate {
  
  // Handle updated push credentials
  func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
      print(credentials.token)
      //         let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
      let deviceTokenString = credentials.token.hexString
      print("PUSH KIT TOKEN \(deviceTokenString)")
    UserDefaultModule().setPushToken(fcm_token: deviceTokenString)
    if (UserDefaultModule().getFCMToken() != nil && UserDefaultModule().getPushToken() != nil){
        Utility.shared.registerPushServices()
   }
  }
  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
      print("pushRegistry:didInvalidatePushTokenForType:")
  }
    
  

  func pushRegistry(_ registry: PKPushRegistry,
                    didReceiveIncomingPushWith payload: PKPushPayload,
                    for type: PKPushType,
                    completion: @escaping () -> Void) {
    print("PUSHKIT NOTIFICATION123 \(payload.dictionaryPayload)")
    if (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
        
        if type == .voIP {
            let jsonDict = JSON(payload.dictionaryPayload)
            self.callNotifyDict = jsonDict
            if jsonDict["aps","type"].stringValue == "audio" || jsonDict["aps","type"].stringValue == "video"  && !callKitPopup {
                
                if !isAlreadyInCall {
                    self.baseUUId = UUID()
                    self.provider.setDelegate(self, queue: nil)
                    let update = CXCallUpdate()
                    let username = jsonDict["aps","alert","user_name"].stringValue
                    update.remoteHandle = CXHandle(type: .generic, value: username)
                    if jsonDict["aps","type"].stringValue == "video" {
                        update.hasVideo = true
                    }
                    else {
                        update.hasVideo = false
                    }
                    self.provider.configuration.maximumCallsPerCallGroup = 1
                    self.provider.reportNewIncomingCall(with: self.baseUUId, update: update, completion: { error in })
                    self.callKitPopup = true
                }
            }
            else {
                self.callKitPopup = false
                self.endCall()
                if (window?.rootViewController?.isKind(of: CallViewController.self))! {
                    window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                else {
                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    print("hello")
                    if var topController = keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                            if topController.isKind(of: CallViewController.self) {
                                window?.rootViewController?.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
      completion()
    
  }
    func endCall() {
        self.isAlreadyInCall = false
        let endCallAction = CXEndCallAction(call:self.baseUUId)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction) { error in
            if error == nil {
                self.provider.reportCall(with: self.baseUUId, endedAt: Date(), reason: .remoteEnded)
                return
            }
            else {
                
            }
        }
    }
  
}


extension AppDelegate: CXProviderDelegate {
  func providerDidReset(_ provider: CXProvider) {
  }
  
  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    action.fulfill()
    let session = AVAudioSession.sharedInstance()
    try! session.setCategory(AVAudioSession.Category.playback)
      let pageobj = CallViewController()
    pageobj.receiverId =  self.callNotifyDict["aps","alert","user_id"].stringValue
      pageobj.room_id = self.callNotifyDict["aps","alert","room_id"].stringValue
    pageobj.receiverImage = self.callNotifyDict["aps","alert","user_image"].stringValue
    pageobj.receiverName = self.callNotifyDict["aps","alert","user_name"].stringValue
    pageobj.senderFlag = false
    pageobj.viewType = "2"
    pageobj.call_type = self.callNotifyDict["aps","type"].stringValue
    pageobj.modalPresentationStyle = .fullScreen
    self.window!.makeKeyAndVisible()
    self.window?.rootViewController?.present(pageobj, animated: true, completion: nil)
}
  
  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
      action.fulfill()
      let viewModel = CallViewModel()
       viewModel.endCall(toId: self.callNotifyDict["aps","alert","user_id"].stringValue, fromId: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), room_id: callNotifyDict["aps","alert","room_id"].stringValue, type: "bye", chatId: callNotifyDict["aps","alert","chat_id"].stringValue)
            self.window?.rootViewController?.view.makeToast("Call declined")
  }
 
}

extension SFSafariViewController {
    override open var modalPresentationStyle: UIModalPresentationStyle {
        get { return .fullScreen}
        set { super.modalPresentationStyle = newValue }
    }
}
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0)}.joined()
        return hexString
    }
}

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
       
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
            
        }
        return nil
    }
    
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKind(of: UINavigationController.self) {
            
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.visibleViewController!)
            
        } else if vc.isKind(of: UITabBarController.self) {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
            
        }
        /*
        else if vc.isKind(of: MenuPage.self){
            let Menu = vc as! MenuPage
            return UIWindow.getVisibleViewControllerFrom(vc: Menu.topViewController!)
        }
        */
        else {
            if let presentedViewController = vc.presentedViewController {
                
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
                
            } else {
                
                return vc;
            }
        }
    }
}
