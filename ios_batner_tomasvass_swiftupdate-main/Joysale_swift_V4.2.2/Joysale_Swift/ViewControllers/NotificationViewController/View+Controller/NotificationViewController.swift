//
//  NotificationViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    var viewModel = NotificationViewModel()
    var offset = 0
    var isFound = true
    var notificationArray = [NotificationResultModel]()
    private let refreshControl = UIRefreshControl()
    var isFromNotification = false
    let delegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        ADMIN_VIEW_MODEL.getCountModel?.notificationCount = 0
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
            }
            else {
                if self.isFromNotification {
                    self.delegate.initVC(initialView: TabbarController())
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    func configUI() {
        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "noNotification")
        
        self.navigationController?.customNavigationBarView(title: "notifications", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        Utility.shared.startAnimation(viewController: self)
        self.loadData()
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refreshAct), for: .valueChanged)
    }
    @objc func refreshAct() {
        self.offset = 0
        self.isFound = true
        self.tableView.reloadData()
        self.loadData()
    }
    func loadData() {
        self.viewModel.getNotificationData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", offset: "\(self.offset)", onSuccess: { (success) in
            if !success {
                self.isFound = false
                if self.notificationArray.count == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            else {
                if self.offset == 0 {
                    self.notificationArray.removeAll()
                }
                if self.viewModel.notificationModel?.result != nil {
                    self.notificationArray += self.viewModel.notificationModel!.result
                }
                else {
                    self.isFound = false
                }
                if self.notificationArray.count == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            self.refreshControl.endRefreshing()
            Utility.shared.stopAnimation(viewController: self)
            self.tableView.reloadData()
        }) { (failure) in
            self.refreshControl.endRefreshing()
            Utility.shared.stopAnimation(viewController: self)
        }
    }
}
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return notificationArray.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as! NotificationTableViewCell
        cell.loadData(notificationArray[indexPath.section])
        if indexPath.section > self.notificationArray.count && self.isFound {
            self.offset += 10
            self.loadData()
        }
        cell.userImageView.tag = indexPath.section
        cell.userImageView.isUserInteractionEnabled = true
        cell.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.userImageAct(_:))))
        return cell
    }
    @objc func userImageAct(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            let notification  = self.notificationArray[tag]
            if notification.type != "admin" && notification.type != "adminpayment" {
                let pageObj = ViewProfileViewController()
                pageObj.userId = "\(notification.userId ?? 0)"
                self.delegate.navigationController.pushViewController(pageObj, animated: true)
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < self.notificationArray.count {
            let notification = self.notificationArray[indexPath.section]
            if notification.type == "admin"{}
            else if notification.type == "follow"{
                let pageObj = ViewProfileViewController()
                pageObj.userId = "\(notification.userId ?? 0)"
                self.delegate.navigationController.pushViewController(pageObj, animated: true)
            }
            else if notification.type == "banner" {
                
            }
            else if notification.type == "review" {
                
                let pageObj = WriteReviewViewController()
                pageObj.buyer_id = "\(notification.userId ?? 0)"
                pageObj.item_id = "\(notification.itemId ?? 0)"
                pageObj.isFromNotification = true
                pageObj.review_type = "solditem"
                self.navigationController?.pushViewController(pageObj, animated: true)
                
                 
            }
            else if notification.type == "order" {
                
                let pageObj = MyOrderSegmentViewController()
                self.delegate.navigationController.pushViewController(pageObj, animated: true)
               
            }
            else if notification.type == "adminpayment" || notification.type == "order" {
                if notification.message.contains("stripe credentials") {
                    let pageObj = ChangePasswordViewController()
                    pageObj.viewType = "manage_stripe"
                    self.delegate.navigationController.pushViewController(pageObj, animated: true)
                }

            }
            else if notification.type == "myoffer" {
                let Tabbar = TabbarController()
                Tabbar.selectedIndex = 3
                delegate.initVC(initialView: Tabbar)
                
            }
            else if notification.type == "exchange" {
                let pageObj = ExchangeListViewController()
                self.delegate.navigationController.pushViewController(pageObj, animated: true)
            }
            else if notification.type == "add" || notification.type == "like" || notification.type == "promotion" || notification.type == "comment" {
                let chatViewModel = ChatViewModel()
                Utility.shared.startAnimation(viewController: self)
                chatViewModel.searchItemData(item_id: "\(notification.itemId ?? 0)", user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
//                    if success {
//                        if let itemModel = chatViewModel.itemModel?.result.items.first {
//                            let pageObj = ItemDetailsViewController()
//                            pageObj.itemDetails = itemModel
//                            self.delegate.navigationController.pushViewController(pageObj, animated: true)
//                        }
//                    }
                    if success {
                        for i in  chatViewModel.itemModel?.result.items ?? [] {
                            if i.product_type == "video"{
                                let view = StoryAllList()
                                view.user_Img = i.sellerImg ?? ""
                                view.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                                view.type = "after"
                                view.fromNav = "notification"
                                view.page_type = "notification"
                                view.hts_product_id = "\(i.id ?? 0)"
                                view.videoID = i.stream_id ?? ""
                                self.navigationController?.pushViewController(view, animated: true)
                            }else{
                                if let itemModel = chatViewModel.itemModel?.result.items.first {
                                    let pageObj = ItemDetailsViewController()
                                    pageObj.itemDetails = itemModel
                                    self.delegate.navigationController.pushViewController(pageObj, animated: true)
                                }
                            }
                        }
                    }
                    
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }
        }
    }
}

