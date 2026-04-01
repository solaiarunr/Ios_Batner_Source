//
//  MyPromotionSubViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 20/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class MyPromotionSubViewController: UIViewController {

    @IBOutlet weak var errorDescLabel: UILabel!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    var viewModel = PromotionViewModel()
    var type = ""
    let delegate = UIApplication.shared.delegate as! AppDelegate
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        self.loadData()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func configUI() {
        self.errorTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.errorDescLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "noItem")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "MyPromotionTableViewCell", bundle: nil), forCellReuseIdentifier: "MyPromotionTableViewCell")
        self.noItemStackView.isHidden = true
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
        if self.view.tag == 0 {
            type = "urgent"
        }
        else if self.view.tag == 1 {
            type = "ad"
        }
        else {
            type = "expire"
        }
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.myPromotionData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", type: type, onSuccess: { (success) in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            Utility.shared.stopAnimation(viewController: self)
        }) { (failure) in
            self.refreshControl.endRefreshing()
            Utility.shared.stopAnimation(viewController: self)
        }
    }
}
extension MyPromotionSubViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.viewModel.premiumModel?.result.count != nil {
            self.noItemStackView.isHidden = false
            return (self.viewModel.premiumModel?.result.count ?? 0)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.noItemStackView.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPromotionTableViewCell") as! MyPromotionTableViewCell
        if let premiumData = self.viewModel.premiumModel?.result[indexPath.section] {
            cell.loadData(premiumData, type: self.type)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let pageObj = MyPromotionDetailViewController()
            if let premiumData = self.viewModel.premiumModel?.result[indexPath.section] {
                pageObj.promotionModel = premiumData
            }
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
    }
    
}
