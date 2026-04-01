//
//  MyOrderSalesViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 06/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class MyOrderSalesViewController: UIViewController {

    @IBOutlet weak var bottomLoader: UIActivityIndicatorView!
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!

    @IBOutlet weak var tableView: UITableView!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    private let refreshControl = UIRefreshControl()

    var viewModel = MyOrderSalesViewModel()
    var myOrderArray = [MyOrderResultModel]()
    var offset = 0
    var isFound = true
    
    var userstatus : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.loadData()
    }

    func configUI() {
        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        let noDescString = self.view.tag == 0 ? "noOrder" : "noSales"
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: noDescString)
        self.view.addSubview(indicatorView)
        Utility.shared.startAnimation(viewController: self)
        self.tableView.register(UINib(nibName: "MyOrderSalesTableViewCell", bundle: nil), forCellReuseIdentifier: "MyOrderSalesTableViewCell")
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
        self.myOrderArray.removeAll()
        self.tableView.reloadData()
        self.loadData()
    }
    func loadData() {
        self.viewModel.myOrderSalesData(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), offset: "\(self.offset)", limit: "50", type: "\(self.view.tag)", onSuccess: { (success) in
            
            if !success {
                self.isFound = false
                if self.myOrderArray.count == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            else {
                if self.offset == 0 {
                    self.myOrderArray.removeAll()
                }
                if let result = self.viewModel.resultModel?.result , result.count > 0 {
                    self.myOrderArray += self.viewModel.resultModel!.result
                    
                }
                else {
                    self.isFound = false
                }
                if self.myOrderArray.count == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            self.refreshControl.endRefreshing()
            self.bottomLoader.stopAnimating()
            Utility.shared.stopAnimation(viewController: self)
            self.tableView.reloadData()
        }) { (failure) in
            self.refreshControl.endRefreshing()
            self.bottomLoader.stopAnimating()
            Utility.shared.stopAnimation(viewController: self)
        }
    }

}
extension MyOrderSalesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.viewModel.resultModel?.result != nil {
            return self.myOrderArray.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        }
        return 3
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        if UserDefaultModule.shared.getTheme() == "Dark"{
            headerView.backgroundColor = UIColor(named: "BackGroundColorNew")
        }else{
            headerView.backgroundColor = #colorLiteral(red: 0.9567790627, green: 0.9569163918, blue: 0.956749022, alpha: 1)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrderSalesTableViewCell") as! MyOrderSalesTableViewCell
        cell.loadData(self.myOrderArray[indexPath.section], viewType: self.view.tag)
        if "\(self.view.tag)" != "1" {
            if self.myOrderArray[indexPath.section].status == "paid" {
                cell.statusButton.setTitle(getLanguage["Item delivered"] ?? self.myOrderArray[indexPath.section].status, for: .normal)
                cell.statusButton.setBackgroundColor(color: UIColor(named: "AppThemeColorNew") ?? .white, forState: .normal)
            }
        }
        if indexPath.row == (self.myOrderArray.count - 1) && self.isFound && self.myOrderArray.count >= 20{
            self.offset = self.myOrderArray.count
            self.bottomLoader.startAnimating()
            self.loadData()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.userstatus = self.myOrderArray[indexPath.section].userstatus
        if self.userstatus == "2" || self.userstatus == "0"{
            var message = ""
            if self.userstatus == "2"{
                message = "Account deleted by user"
            }else if self.userstatus == "0"{
                message = "Account deactivated by admin"
            }
            let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage[message], preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let pageObj = MyOrderSalesDetailViewController()
            pageObj.view.tag = self.view.tag
            pageObj.orderResultData = self.myOrderArray[indexPath.section]
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }
        
        /*
         //old
        if self.myOrderArray[indexPath.section].sellerStatus == "deleted" {
            let deleteAlert = UIAlertController(title: getLanguage["alert"], message: getLanguage["Account has been deleted"], preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(deleteAlert, animated: true, completion: nil)
        } else {
        let pageObj = MyOrderSalesDetailViewController()
        pageObj.view.tag = self.view.tag
        pageObj.orderResultData = self.myOrderArray[indexPath.section]
        self.delegate.navigationController.pushViewController(pageObj, animated: true)
                  
        }
         */
      }
    }

