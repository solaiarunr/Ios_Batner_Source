//
//  BannerListViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class BannerListViewController: UIViewController {
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!

    @IBOutlet weak var tableView: UITableView!
    var viewModel = BannerViewModel()
    var isFromAddBanner = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
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
        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "nohistoryfound")
        self.navigationController?.customNavigationBarView(title: "advertise_history", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.tableView.register(UINib(nibName: "BannerListTableViewCell", bundle: nil), forCellReuseIdentifier: "BannerListTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50
        self.loadData()
    }
    func loadData() {
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.getHistoryAct(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            self.tableView.reloadData()
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }

}
extension BannerListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        self.noItemStackView.isHidden = false
        return self.viewModel.bannerHistoryModel?.adHistory.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.noItemStackView.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "BannerListTableViewCell") as! BannerListTableViewCell
        if let result = self.viewModel.bannerHistoryModel?.adHistory[indexPath.section] {
            cell.loadData(result)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pageObj = BannerDetailsViewController()
        if let result = self.viewModel.bannerHistoryModel?.adHistory[indexPath.section] {
            pageObj.selectedAd = result
        }
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
    
}
