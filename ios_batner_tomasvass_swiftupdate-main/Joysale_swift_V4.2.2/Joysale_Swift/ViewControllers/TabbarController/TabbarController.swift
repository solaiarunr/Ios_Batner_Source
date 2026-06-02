//
//  TabbarController.swift
//  Howzu_swift
//
//  Created by Hitasoft on 13/04/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class TabbarController: UITabBarController, UITabBarControllerDelegate {
    let delegateapp = UIApplication.shared.delegate as! AppDelegate
    let homeVC = HomeViewController()
    let categoryVC = CategoryViewController()
    let addProductVC = CameraVC()
    let chatVC = ChatListViewController()
    let profileVC = ProfileViewController()
    var isFromNotification = false
    var profileNavigationController = UINavigationController()
    var viewModel = AdminViewModel()
//    var interstitial :GADInterstitialAd?
    var profileData: ProfileResultModel?
    var viewModels = ProfileViewModel()
    var adModel: AdModel?
    var getFreePost = Int()
    var didCheckAd  = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileNavigationController.setNavigationBarHidden(true, animated: false)
        setNavigationDetails()
        self.configUI()
        self.loadData()
        //        Utility.shared.setBadge(vc: self)

        
        // Do any additional setup after loading the view.
    }

    func loadAds() {
        /*
        interstitial = nil
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:INTERESTITIAL_KEY, request: request, completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        }
        )
         */
    }
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        delegateapp.checkTheme()
//    }
    override func viewDidAppear(_ animated: Bool) {
        self.loadAds()
//        if !didCheckAd{
//            didCheckAd = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.checkAdStatusAndLoadBanner()
//            }
//        }
        if self.selectedIndex != 2 {
            self.navigationController?.isNavigationBarHidden = false
        }
        else {
            self.navigationController?.isNavigationBarHidden = true
        }
        if self.isFromNotification {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.titleView = nil
            self.navigationController?.customNavigationBarView(title: "chat", fColor: "whitecolor",fontName: UIFont(name: APP_FONT_REGULAR, size: 20),vc: self)
        }
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func configUI() {
        self.delegate = self
        
        categoryVC.CategoryDetails = CategoryDetailsModel(Category_id: FILTER_DATA.Category_id, subcategory_id: FILTER_DATA.subcategory_id, child_category_id: FILTER_DATA.child_category_id)
        categoryVC.delegate = self
        
        homeVC.refreshFilter = { refresh in
            self.setNavigationDetails()
        }
        homeVC.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "tab_home"), selectedImage: #imageLiteral(resourceName: "tab_home_sel"))
        homeVC.tabBarItem.tag = 0
        homeVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        categoryVC.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "tab_category"), selectedImage: #imageLiteral(resourceName: "tab_category_sel"))
        categoryVC.tabBarItem.tag = 1
        categoryVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

        addProductVC.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "tab_camera"), selectedImage: #imageLiteral(resourceName: "tab_camera_sel"))
        addProductVC.tabBarItem.tag = 2
        addProductVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

        
        chatVC.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "tab_messages"), selectedImage: #imageLiteral(resourceName: "tab_messages_sel"))
        chatVC.tabBarItem.tag = 3
        chatVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        profileVC.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "tab_profile"), selectedImage: #imageLiteral(resourceName: "tab_profile_sel"))
        profileVC.tabBarItem.tag = 4
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        //        profileNavigationController = UINavigationController(rootViewController: profileVC)
        self.profileNavigationController.isNavigationBarHidden = true
        let tabBarList = [homeVC, categoryVC, addProductVC, chatVC, profileVC]
       
        self.tabBar.unselectedItemTintColor = UIColor(named: "BlackTextColor") ?? .white
        self.tabBar.tintColor = UIColor(named: "AppThemeColor") ?? .white
        //        self.tabBar.isTranslucent = false
        viewControllers = tabBarList
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
        //        self.edgesForExtendedLayout = .bottom
    }
    
    @objc func filterButtonAct(_ sender: UIButton) {
        if sender.tag == 0 {
            let pageObj = SearchViewController()
            pageObj.categoryData = FILTER_DATA
            pageObj.searchDelegate = self
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
        else {
            let pageObj = FilterViewController()
            pageObj.filterDelegate = self
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
    }
    func showAlerts() {
            let alertController = UIAlertController(title: "Batner", message: "Kindly Verify Your Mobile Number", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                if (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
                    let pageObj = EditProfileViewController()
                    pageObj.profileData = self.viewModels.profileModel?.result
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
                self.tabBar.isUserInteractionEnabled = true
            }

            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        self.checkAdStatusAndLoadBanner()
        if !(viewController.isKind(of: HomeViewController.self) || viewController.isKind(of: CategoryViewController.self)){
            if let homeVC = viewController as? HomeViewController {
                 homeVC.callHomeAPI()
             }
            if (UserDefaultModule.shared.getUserData()?.user_id ?? "" == "") {
                let vc = InitialViewController()
                vc.isFromList = true
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated: true, completion: nil)
                return false
            }
            else if !(viewController.isKind(of: ChatListViewController.self) || viewController.isKind(of: ProfileViewController.self)){
                self.tabBar.isUserInteractionEnabled = false
                self.loadSubScriptionData()
                return false
              
                
            }
            else {
                return true
            }
        }
      
        return true
    }
    func loadSubScriptionData(){
        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            if success {
                if let profileData = self.viewModels.profileModel?.result {
                    self.profileData = profileData
                    if self.profileData?.verification.mobNo == false{
                        self.showAlerts()
                    }else{
                        self.tabBar.isUserInteractionEnabled = true
                        self.selectedIndex = 2
                    }
                    
                }
            }
        }) { (failure) in
        }
        
       
        //self.presentInterstitialAds()

        /*
        let group = DispatchGroup()
        group.enter()
        var value = false
        self.viewModel.getProfileDetailCount(user_id:  UserDefaultModule.shared.getUserData()?.user_id ?? "", onSuccess:{ (val) in
            print(val)
            if self.viewModel.postProductModel?.status ?? false{
                let res = self.viewModel.postProductModel?.result.first
                self.getFreePost = res!.subscriptionEnable
                if self.getFreePost != 0{
                    value = false
                 
                   
                }else{
                    value = true
                
                }
            }
            group.leave()
        })
        { (failure) in
            value = true
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            if value {
                self.tabBar.isUserInteractionEnabled = true
                self.selectedIndex = 2
//                self.presentInterstitialAds()
            }
            else {
                print("ganesh:\(value)")
                let pageObj = SubscribePlanPage()
                self.tabBar.isUserInteractionEnabled = true
                pageObj.from_page = "camera"
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
        }
       */
    }
    func loadData() {
        if UserDefaultModule.shared.getUserData()?.user_id != nil {
        ADMIN_VIEW_MODEL.getCountData(onSuccess: { (success) in
            if success {
                if (ADMIN_VIEW_MODEL.getCountModel?.notificationCount ?? 0) > 0 {
                    self.profileVC.tabBarItem.badgeValue = "\(ADMIN_VIEW_MODEL.getCountModel?.notificationCount ?? 0)"
//                    if #available(iOS 13.0, *) {
//                        self.profileVC.tabBarItem.standardAppearance?.backgroundColor = .yellow
//                    } else {
//                        // Fallback on earlier versions
//                    }
                    
//                    self.tabBar.addBadge(index: 4)

                }
                else {
                    self.profileVC.tabBarItem.badgeValue = nil
                }
                if (ADMIN_VIEW_MODEL.getCountModel?.chatCount ?? 0) > 0 {
                    self.chatVC.tabBarItem.badgeValue = "\(ADMIN_VIEW_MODEL.getCountModel?.chatCount ?? 0)"
                }
                else {
                    self.chatVC.tabBarItem.badgeValue = nil
                }
            }
        }) { (failure) in
        }
            
        }
    }
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        if (item.tag == 0 || item.tag == 1) || (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
//            self.navigationController?.isNavigationBarHidden = false
//            self.navigationItem.rightBarButtonItem = nil
//            self.navigationItem.leftBarButtonItem = nil
//            self.navigationItem.titleView = nil
//            if item.tag == 0 || item.tag == 2 {
//                self.setNavigationDetails()
//            }
//             else if item.tag == 1 {
//                self.navigationController?.customNavigationBarView(title: "category", fColor: "whitecolor",fontName: UIFont(name: APP_FONT_REGULAR, size: 20),vc: self)
//            }
//
//            else if item.tag == 3 {
//                 self.navigationController?.customNavigationBarView(title: "chat", fColor: "whitecolor",fontName: UIFont(name: APP_FONT_REGULAR, size: 20),vc: self)
//            }
//            else {
//                self.navigationController?.customNavigationBarView(title: "myprofile", fColor: "whitecolor",fontName: UIFont(name: APP_FONT_REGULAR, size: 20),vc: self)
//            }
//        }
//        self.loadData()
//    }
//    func setNavigationDetails() {
//        let navigationBarAppearace = UINavigationBar.appearance()
//        self.navigationController?.isNavigationBarHidden = false
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
//       imageView.image = #imageLiteral(resourceName: "AppiconOE")
//        imageView.contentMode = .scaleAspectFit
//        self.navigationItem.titleView = imageView
//        self.navigationItem.titleView?.tintColor = UIColor(named: "whitecolor")
//        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
//        button.setImage(UIImage(named: "search_btn")?.withHorizontallyFlippedOrientation(), for: UIControl.State.normal)
//        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
//            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
//        }
//        else {
//            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
//        }
//        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        let barButton = UIBarButtonItem(customView: button)
//        self.navigationItem.leftBarButtonItem = barButton
//        button.tintColor = UIColor(named: "whitecolor")
//        button.tag = 0
//        button.addTarget(self, action: #selector(self.filterButtonAct(_:)), for: .touchUpInside)
//        let button1: MFBadgeButton = MFBadgeButton(type: UIButton.ButtonType.custom)
//        button1.setImage(UIImage(named: "search_adv"), for: UIControl.State.normal)
//        if FILTER_DATA.toDictionary().keys.count > 0 {
//             button1.badgeValue = "●"
//        }
//        else {
//            button1.badgeValue = nil
//        }
//        button1.tag = 1
//        button1.addTarget(self, action: #selector(self.filterButtonAct(_:)), for: .touchUpInside)
//        button1.tintColor = UIColor(named: "whitecolor")
//        button1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        button1.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
//
//        let barButton1 = UIBarButtonItem(customView: button1)
//        self.navigationItem.rightBarButtonItem = barButton1
//        navigationBarAppearace.barTintColor = UIColor(named: "AppThemeColor")
//        navigationBarAppearace.isTranslucent = false
//        let navigationBar = navigationController?.navigationBar
//        navigationBar?.barTintColor = UIColor(named: "AppThemeColor") ?? .white
//        navigationBar?.isTranslucent = false
//        navigationBar?.setBackgroundImage(UIImage(), for: .default)
//        navigationBar?.shadowImage = UIImage()
//        
//        // Change Tabbar Background Color
//        if #available(iOS 13.0, *) {
//            let appearance = tabBar.standardAppearance
//            appearance.shadowImage = nil
//            appearance.shadowColor = nil
//            if UserDefaultModule.shared.getTheme() == "Dark" {
//                appearance.backgroundColor = UIColor.black
//            }else{
//                appearance.backgroundColor = UIColor(named: "whitecolor")
//            }
//            tabBar.standardAppearance = appearance;
//        } else {
//            tabBar.shadowImage = UIImage()
//            tabBar.backgroundImage = UIImage()
//            // Fallback on earlier versions
//        }
//        if UserDefaultModule.shared.getTheme() == "Dark" {
//            tabBar.layer.backgroundColor = UIColor.black.cgColor
//        }else{
//            tabBar.layer.backgroundColor = (UIColor(named: "whitecolor") ?? .white).cgColor
//            
//        }
//       
//    }
    func setNavigationDetails() {
        
        // MARK: - Navigation Bar Setup
        self.navigationController?.isNavigationBarHidden = false

        // Title view with logo
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        imageView.image = #imageLiteral(resourceName: "AppiconOE")
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationItem.titleView?.tintColor = UIColor(named: "whitecolor") ?? .white

        // Left Button
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "search_btn"), for: .normal)
        button.contentEdgeInsets = (UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic") ?
            UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6) :
            UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = UIColor(named: "whitecolor") ?? .white
        button.tag = 0
        button.addTarget(self, action: #selector(self.filterButtonAct(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)

        // Right Button (with badge)
        let button1 = MFBadgeButton(type: .custom)
        button1.setImage(UIImage(named: "search_adv"), for: .normal)
        button1.badgeValue = FILTER_DATA.toDictionary().keys.count > 0 ? "●" : nil
        button1.tag = 1
        button1.addTarget(self, action: #selector(self.filterButtonAct(_:)), for: .touchUpInside)
        button1.tintColor = UIColor(named: "whitecolor") ?? .white
        button1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button1.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button1)

        // MARK: - Navigation Bar Appearance
        let navBar = self.navigationController?.navigationBar
        let navColor = UIColor(named: "AppThemeColor") ?? .white

        if #available(iOS 13.0, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = navColor
            navAppearance.shadowImage = UIImage()
            navAppearance.shadowColor = nil

            navBar?.standardAppearance = navAppearance
            if #available(iOS 15.0, *) {
                navBar?.scrollEdgeAppearance = navAppearance
            }
        } else {
            navBar?.barTintColor = navColor
            navBar?.isTranslucent = false
            navBar?.setBackgroundImage(UIImage(), for: .default)
            navBar?.shadowImage = UIImage()
        }

        // MARK: - Tab Bar Appearance
        let tabColor = (UserDefaultModule.shared.getTheme() == "Dark") ?
        (UIColor(named: "whitecolorNEW") ?? .white) : (UIColor(named: "whitecolor") ?? .white)

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            appearance.backgroundColor = tabColor

            tabBar.standardAppearance = appearance

            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }

        tabBar.layer.backgroundColor = tabColor.cgColor
    }

    
}
extension TabbarController: SearchDelegate, CategoryDelegate, FilterDelegate {
    func loadadmindata() {
      
    }
    
    
    func filterAct(_ filterData: FilterDataModel) {
        
        self.setNavigationDetails()
        FILTER_DATA = filterData
        self.homeVC.itemModel.removeAll()
        self.homeVC.collectionView.reloadData()
        self.homeVC.offset = 0
        self.homeVC.isFound = true
        self.homeVC.loadFilterData()
        self.homeVC.loadData()
    }
    func updateSearchData(_ searchData: FilterDataModel) {
        self.setNavigationDetails()
        FILTER_DATA = searchData
        if FILTER_DATA.location.lowercased() != UserDefaultModule.shared.getcountryname()?.lowercased() && FILTER_DATA.location.lowercased() != "WorldWide".lowercased(){
            FILTER_DATA.isDistanceSlider = true
        }
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        self.homeVC.itemModel.removeAll()
        self.homeVC.collectionView.reloadData()
        self.homeVC.offset = 0
        self.homeVC.isFound = true
        self.homeVC.loadFilterData()
        self.homeVC.loadData()
    }
    func updateCategoryData(_ searchData: CategoryDetailsModel) {
        self.setNavigationDetails()
        FILTER_DATA.Category_id = searchData.Category_id
        FILTER_DATA.subcategory_id = searchData.subcategory_id
        FILTER_DATA.child_category_id = searchData.child_category_id
        FILTER_DATA.filters = ""
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        self.homeVC.itemModel.removeAll()
        self.homeVC.collectionView.reloadData()
        self.homeVC.offset = 0
        self.homeVC.isFound = true
        self.homeVC.loadFilterData()
        self.homeVC.loadData()
    }
}
