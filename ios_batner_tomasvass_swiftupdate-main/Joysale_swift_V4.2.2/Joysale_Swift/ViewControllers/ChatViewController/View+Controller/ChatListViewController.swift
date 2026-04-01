 //
 //  ChatListViewController.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 29/06/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import UIKit
import GoogleMobileAds

 class ChatListViewController: UIViewController {
     @IBOutlet weak var bannerView: UIView!
     @IBOutlet weak var noItemDesLabel: UILabel!
     @IBOutlet weak var noItemTitleLabel: UILabel!
     @IBOutlet weak var noItemStackView: UIStackView!

     @IBOutlet weak var tableView: UITableView!
     var viewModel = ChatViewModel()
     var offset = 0
     var isFound = true
     var chatListArray = [ChatListResultModel]()
     var viewModels = ProfileViewModel()
     var profileData: ProfileResultModel?
     private let refreshControl = UIRefreshControl()
   var bannerView1: GADBannerView!

     override func viewDidLoad() {
         super.viewDidLoad()
         self.view.addSubview(indicatorView)
         self.configUI()
//         Utility.shared.setBadge(vc: self)
         self.checkAdStatusAndLoadBanner()
     }
     override func viewWillAppear(_ animated: Bool) {
         self.updateTheme(page: "present")
         self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
         CURRENT_CHAT = ""
         self.loadData()
//        self.loadBannerView()
         self.checkAdStatusAndLoadBanner()
     }
     override func viewWillDisappear(_ animated: Bool) {
         //ProductsVideo
         self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
         //         self.navigationController?.isNavigationBarHidden = true
//         NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
     }
     override var preferredStatusBarStyle : UIStatusBarStyle {
         return self.updateStatusBarStyle()
     }
     func configUI() {
         self.noItemStackView.isHidden = true
         self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
         self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "nomessagefound")
         self.tableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatListTableViewCell")
         self.tableView.sectionHeaderHeight = 0
         if #available(iOS 10.0, *) {
             self.tableView.refreshControl = refreshControl
         } else {
             self.tableView.addSubview(refreshControl)
         }
         self.refreshControl.addTarget(self, action: #selector(self.refreshAct), for: .valueChanged)
         Utility.shared.startAnimation(viewController: self)
        
        /****Addons**/
//        self.loadBannerView()
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
            
            self.bannerView1.frame  = self.bannerView.bounds
            self.bannerView.isHidden = false
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
     @objc func refreshAct() {
         self.offset = 0
         self.isFound = true
         self.chatListArray.removeAll()
         self.tableView.reloadData()
         self.loadData()
     }
 
     func loadData() {
         if !indicatorView.isAnimating {
             self.refreshControl.beginRefreshing()
         }
         self.viewModel.getMessages(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), offset: "\(self.offset)", limit: "20", onSuccess: { (success) in
             Utility.shared.stopAnimation(viewController: self)
             if !success {
                 self.isFound = false
                 if self.chatListArray.count == 0 {
                     self.noItemStackView.isHidden = false
                 }
                 else {
                     self.noItemStackView.isHidden = true
                 }
             }
             else {
                 if self.offset == 0 {
                     self.chatListArray.removeAll()
                 }
                 if self.viewModel.chatListModel?.result != nil {
                     self.chatListArray += self.viewModel.chatListModel?.result ?? [ChatListResultModel]()
                 }
                 else {
                     self.isFound = false
                 }
                 if self.chatListArray.count == 0 {
                     self.noItemStackView.isHidden = false
                 }
                 else {
                     self.noItemStackView.isHidden = true
                 }
             }
             self.tableView.reloadData()
             self.refreshControl.endRefreshing()
         }) { (failure) in
             self.refreshControl.endRefreshing()
             Utility.shared.stopAnimation(viewController: self)
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
                
//                 alertController.dismiss(animated: true, completion: nil)
             }

             alertController.addAction(okAction)

             present(alertController, animated: true, completion: nil)
         }
 }
 extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
     }
     func numberOfSections(in tableView: UITableView) -> Int {
         return self.chatListArray.count
     }
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 0
     }
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return 3
     }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
     }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell") as! ChatListTableViewCell
         cell.loadData(self.chatListArray[indexPath.section])
         if indexPath.row == (self.chatListArray.count - 1) && self.isFound && indexPath.row >= 20 {
             self.offset = self.chatListArray.count
             self.loadData()
         }
         return cell
     }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
             print(success)
             print("comingg",self.viewModels.profileModel?.status)
             
             if success {
                 if let profileData = self.viewModels.profileModel?.result{
                     self.profileData = profileData
                     if self.profileData?.verification.mobNo == false{
                         self.showAlerts()
                     }else{
                           DispatchQueue.main.async {
                             let pageObj = ChatViewController()
                             pageObj.receiverId = "\(self.chatListArray[indexPath.section].userId ?? 0)"
                             pageObj.chatId = "\(self.chatListArray[indexPath.section].chatId ?? 0)"
                             self.navigationController?.pushViewController(pageObj, animated: true)
                         }
                     }
                     
                 }
             }
         }) { (failure) in
         }
     }
 }
 
 extension ChatListViewController: GADBannerViewDelegate{
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

