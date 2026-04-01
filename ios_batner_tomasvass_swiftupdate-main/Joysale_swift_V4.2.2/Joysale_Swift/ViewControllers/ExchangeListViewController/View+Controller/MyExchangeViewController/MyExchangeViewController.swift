//
//  MyExchangeViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 03/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class MyExchangeViewController: UIViewController {
    
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    var viewModel = MyExchangeViewModel()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var exchangeArray = [ExchageResultModel]()
    private let refreshControl = UIRefreshControl()
    var exchangePager: ExchangeListViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        CURRENT_CHAT = ""
//        self.loadData()
    }
    func configUI() {
        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "noExhanges")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "MyExchangeTableViewCell", bundle: nil), forCellReuseIdentifier: "MyExchangeTableViewCell")
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refreshAct), for: .valueChanged)
    }
    @objc func refreshAct() {
        self.loadData()
    }
    func loadData() {
        var type = "incoming"
        if self.view.tag == 1 {
            type = "outgoing"
        }
        else if self.view.tag == 2 {
            type = "success"
        }
        else if self.view.tag == 3 {
            type = "failed"
        }
        self.refreshControl.layoutIfNeeded()
        self.refreshControl.beginRefreshing()
        self.viewModel.exchangeData(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), type: type, onSuccess: { (success) in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }) { (failure) in
            self.refreshControl.endRefreshing()
        }
    }
}
extension MyExchangeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        self.noItemStackView.isHidden = false
        if self.viewModel.resultModel?.result != nil {
            return (self.viewModel.resultModel?.result.exchange.count ?? 0)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = #colorLiteral(red: 0.9567790627, green: 0.9569163918, blue: 0.956749022, alpha: 1)
//        return headerView
        
        let headerView = UIView()
        if UserDefaultModule.shared.getTheme() == "Dark"{
            headerView.backgroundColor = UIColor(named: "BackGroundColorNew")
        }else{
            headerView.backgroundColor = #colorLiteral(red: 0.9567790627, green: 0.9569163918, blue: 0.956749022, alpha: 1)
        }
       
        return headerView
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyExchangeTableViewCell") as! MyExchangeTableViewCell
        self.noItemStackView.isHidden = true
        if let exchangeData = self.viewModel.resultModel?.result.exchange[indexPath.section] {
            cell.loadData(exchangeData)
        }
        cell.userImageView.isUserInteractionEnabled = true
        cell.userImageView.tag = indexPath.section
        cell.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.userImageAct(_:))))
        cell.exchangerImageView.isUserInteractionEnabled = true
        cell.exchangerImageView.tag = indexPath.section
        cell.exchangerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.exchangeProductDetailsAct)))
        cell.myProductImageView.isUserInteractionEnabled = true
        cell.myProductImageView.tag = indexPath.section
        cell.myProductImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.myProductDetailsAct)))

        return cell
    }
    @objc func userImageAct(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view {
            if let exchangeData = self.viewModel.resultModel?.result.exchange[imageView.tag] {
                let pageObj = ViewProfileViewController()
                pageObj.userId = "\(exchangeData.exchangerId ?? 0)"
                self.delegate.navigationController.pushViewController(pageObj, animated: true)
            }
        }
    }
    @objc func exchangeProductDetailsAct(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view {
            if let exchangeData = self.viewModel.resultModel?.result.exchange[imageView.tag] {
                self.productDetailsAct("\(exchangeData.exchangeProduct.itemId ?? 0)")
            }
        }
    }
    func productDetailsAct(_ itemID: String) {
            let chatViewModel = ChatViewModel()
            Utility.shared.startAnimation(viewController: self)
        chatViewModel.searchItemData(item_id: "\(itemID)", user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
//            if success {
//                if let itemModel = chatViewModel.itemModel?.result.items.first {
//                    let pageObj = ItemDetailsViewController()
//                    pageObj.itemDetails = itemModel
//                    self.delegate.navigationController.pushViewController(pageObj, animated: true)
//                }
//            }
            if success {
                for i in  chatViewModel.itemModel?.result.items ?? [] {
                    if i.product_type == "video"{
                        let view = StoryAllList()
                        view.user_Img = i.sellerImg ?? ""
                        view.hts_product_id = "\(i.id ?? 0)"
                        view.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                        view.type = "after"
                        view.fromNav = "exchange"
                        view.page_type = "chat"
                        view.videoID = i.stream_id ?? ""
                        self.delegate.navigationController.pushViewController(view, animated: true)
//                        self.navigationController?.pushViewController(view, animated: true)
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
    @objc func myProductDetailsAct(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view {
            if let exchangeData = self.viewModel.resultModel?.result.exchange[imageView.tag] {
                self.productDetailsAct("\(exchangeData.myProduct.itemId ?? 0)")
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.view.tag == 0 || self.view.tag == 1 {
            let pageObj = ExchangeDetailsViewController()
            pageObj.exchangeDelgate = self
            if let exchangeData = self.viewModel.resultModel?.result.exchange[indexPath.section] {
                pageObj.receiverId = "\(exchangeData.exchangerId ?? 0)"
                pageObj.chatId = "\(exchangeData.exchangeId ?? 0)"
                pageObj.exchangeData = exchangeData
            }
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
    }
}
extension MyExchangeViewController: ExchangeDetailsDelgate {
    func updateExchangeStatus(_ status: String) {
        self.loadData()
        var selectedIndex = 0
        if status == "accept" {
            selectedIndex = 0
        }
        else if status == "success" {
            selectedIndex = 2
        }
        else if status == "decline" || status == "cancel" || status == "failed"{
            selectedIndex = 3
        }
        DispatchQueue.main.async {
            self.exchangePager?.reloadData()
            self.exchangePager?.segmentedPager.segmentedControl.select(index: selectedIndex, animated: false)
        }
    }
}
