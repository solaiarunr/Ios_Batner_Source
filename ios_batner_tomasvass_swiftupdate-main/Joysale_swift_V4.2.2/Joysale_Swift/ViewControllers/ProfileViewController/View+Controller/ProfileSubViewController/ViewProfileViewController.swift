//
//  ViewProfileViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import MXSegmentedPager

class ViewProfileViewController: MXSegmentedPagerController {

    let myListingVC = ListAndLikeViewController()
    let myLikeVC = ListAndLikeViewController()
    let followerVC = FollowAndReviewViewController()
    let followingVC = FollowAndReviewViewController()
    let reviewVC = FollowAndReviewViewController()
    var myProfileArray = [UIViewController]()
    var titleArray = ["my_listing", "liked", "followers", "followings"]
    let headerView = ViewProfileHeaderView()
    var viewModel = ProfileViewModel()
    var statusBaStyle = 0
    var userId = ""
    var isfrom = ""
    var isTabBar = false
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var previousIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        delegateapp.checkTheme()
//    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveData(_:)), name: NSNotification.Name("ReceiveData"), object: nil)
//       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        self.navigationController?.isNavigationBarHidden = true
        self.loadData()
        self.segmentedPager.segmentedControl.removeAll()
        self.segmentedPager.reloadData()
        self.segmentedPager.segmentedControl.layoutSubviews()
    }
    
    @objc func onReceiveData(_ notification: Notification) {
        self.segmentedPager.reloadData()
        self.segmentedPager.segmentedControl.layoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool) {
//        self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        self.navigationController?.isNavigationBarHidden = false
    }
    func configUI() {
        //self.myProfileArray = [myListingVC, myLikeVC, followerVC, followingVC]   //Not Needed

        
        if (ADMIN_VIEW_MODEL.adminModel?.result.buynow ?? "") == "disable"
       {
            self.titleArray = ["my_listing", "liked", "followers", "followings"]
            self.myProfileArray = [myListingVC, myLikeVC, followerVC, followingVC]
        }
        else
        {
            self.titleArray = ["my_listing", "liked", "followers", "followings", "review"]
            self.myProfileArray = [myListingVC, myLikeVC, followerVC, followingVC, reviewVC]
        }
         
        self.navigationController?.isNavigationBarHidden = true
        segmentedPager.backgroundColor = UIColor(named: "BackGroundColor")
        segmentedPager.segmentedControl.backgroundColor = UIColor(named: "BackColorwhite")
        segmentedPager.segmentedControl.textColor = (UIColor(named: "AppTextColor") ?? .white)
        segmentedPager.segmentedControl.segmentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        segmentedPager.segmentedControl.font = (UIFont(name: APP_FONT_BOLD, size: 16) ?? UIFont.systemFont(ofSize: 16))
        segmentedPager.segmentedControl.selectedTextColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        segmentedPager.segmentedControl.indicator.lineView.backgroundColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.editButton.setImage(nil, for: .normal)
        headerView.wholeRatingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.ratingViewAct)))
        segmentedPager.parallaxHeader.view = headerView
        segmentedPager.parallaxHeader.height = 280
        segmentedPager.bounces = false
        segmentedPager.parallaxHeader.mode = .fill
//        self.headerView.backButton.setImage(#imageLiteral(resourceName: "detail_back").imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        self.headerView.backButton.addTarget(self, action: #selector(self.backButtonAct(_:)), for: .touchUpInside)
        self.headerView.editButton.addTarget(self, action: #selector(self.editButtonAct(_:)), for: .touchUpInside)
        var wholeHeight = 60
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            wholeHeight = Int((window?.safeAreaInsets.top ?? 0) + 44)
        }
        segmentedPager.parallaxHeader.minimumHeight = CGFloat(wholeHeight)
        headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        myListingVC.userId = self.userId
        myLikeVC.userId = self.userId
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.segmentedPager.segmentedControl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.segmentedPager.pager.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.myListingVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.myLikeVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.followerVC.view.transform  = CGAffineTransform(scaleX: -1, y: 1)
            self.followingVC.view.transform  = CGAffineTransform(scaleX: -1, y: 1)
            self.reviewVC.view.transform  = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    @objc func ratingViewAct() {
        DispatchQueue.main.async {
            if let index = self.titleArray.firstIndex(of: "review") {
                self.segmentedPager.segmentedControl.select(index: index, animated: true)
             }
        }
    }
    @objc func backButtonAct(_ sender: UIButton) {
        if isTabBar {
            delegate.initVC(initialView: TabbarController())
        }else if isfrom == "appdelegate"{
            let Tabbar = TabbarController()
            Tabbar.selectedIndex = 0
            delegate.initVC(initialView: Tabbar)
        }
        else {
            self.navigationController?.popViewController(animated: true)
           
        }
    }
    @objc func editButtonAct(_ sender: UIButton) {
        Utility.shared.startAnimation(viewController: self)
         if self.userId != (UserDefaultModule.shared.getUserData()?.user_id ?? "") && (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
            let type = self.headerView.editButton.currentImage == #imageLiteral(resourceName: "following_red") ? "unfollow" : "follow"
            self.viewModel.followUser(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", follow_id: userId, type: type, onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                if success {
                   // Utility.shared.startAnimation(viewController: self)
                     if type == "follow" {
                        self.viewModel.followerModel?.result.append(self.userId)
                        self.headerView.editButton.setImage(#imageLiteral(resourceName: "following_red"), for: .normal)
                     }
                    else {
                          self.viewModel.followerModel?.result.removeAll(where: {$0 == self.userId})
                        self.headerView.editButton.setImage(#imageLiteral(resourceName: "unFollow"), for: .normal)
                      }
                   // Utility.shared.stopAnimation(viewController: self)
                 }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
        else {
            if (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
                let pageObj = EditProfileViewController()
                pageObj.profileData = self.viewModel.profileModel?.result
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
         }
        Utility.shared.stopAnimation(viewController: self)
     }
    func loadData() {
        let group = DispatchGroup()
        group.enter()
//        Utility.shared.startAnimation(viewController: self)
        self.viewModel.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: userId, onSuccess: { (success) in
            group.leave()
            print(success)
            if success {
                if let profileData = self.viewModel.profileModel?.result {
                    self.headerView.loadData(profileData)
                }
            }
        }) { (failure) in
            group.leave()
        }
        
        group.enter()
        self.viewModel.getFollowedUserId(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), onSuccess: { (success) in
            group.leave()
        }) { (failure) in
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
//            Utility.shared.stopAnimation(viewController: self)
            if self.userId != (UserDefaultModule.shared.getUserData()?.user_id ?? "") && (UserDefaultModule.shared.getUserData()?.user_id ?? "" != ""){
                self.headerView.editButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                self.headerView.editButton.backgroundColor = UIColor(named: "lightWhitenew")
                self.headerView.editButton.setImage(#imageLiteral(resourceName: "unFollow"), for: .normal)

                if let followedIDArr = self.viewModel.followerModel?.result {
                    for id in followedIDArr {
                        if id == self.userId {
                            self.headerView.editButton.setImage(#imageLiteral(resourceName: "following_red"), for: .normal)
                        }
                    }
                }
            }
            else {
                if (UserDefaultModule.shared.getUserData()?.user_id ?? "" != "") {
                    self.headerView.editButton.backgroundColor = UIColor(named: "clearcolor")
                    self.headerView.editButton.setImage(#imageLiteral(resourceName: "profile_settingheader"), for: .normal)
                    self.headerView.editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
                else {
                    self.headerView.editButton.setImage(nil, for: .normal)
                    self.headerView.editButton.isUserInteractionEnabled = false
                }
            }
        }
    }
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return (getLanguage[titleArray[index]] ?? "")
    }
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didScrollWith parallaxHeader: MXParallaxHeader) {
        self.headerView.updateView(val: (parallaxHeader.progress * parallaxHeader.height))
        if (parallaxHeader.progress * parallaxHeader.height) <= 150{
            self.statusBaStyle = 0
            self.setNeedsStatusBarAppearanceUpdate()
//            self.setStatusBarBackgroundColor(color: UIColor(named: "whitecolor") ?? .black)
           self.updateStatusbarBackgroundnew(Color: UIColor(named: "Back24color")!)
        }
        else {
            DispatchQueue.main.async {
                self.statusBaStyle = 1
                self.setNeedsStatusBarAppearanceUpdate()
            }
//            self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
           self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        }
        
    }
    override func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        return titleArray.count
    }
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        if index == 0 || index == 1 {
            let vc: ListAndLikeViewController = myProfileArray[index] as! ListAndLikeViewController
            vc.userId = self.userId
            vc.view.tag = index
            vc.offset = 0
            vc.isFound = true
            vc.itemModel.removeAll()
            vc.collectionView.reloadData()
            previousIndex = index
            vc.loadData()
            return vc
        }
        else {
            let vc: FollowAndReviewViewController = myProfileArray[index] as! FollowAndReviewViewController
            vc.view.tag = index
            vc.userId = self.userId
            return vc
        }
    }
}
