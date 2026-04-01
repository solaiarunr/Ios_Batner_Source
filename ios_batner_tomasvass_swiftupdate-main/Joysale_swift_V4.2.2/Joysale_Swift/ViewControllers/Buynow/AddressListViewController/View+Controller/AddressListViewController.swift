//
//  AddressListViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 26/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

protocol AddressDelegate {
    func setAddressDelegate(_ address: AddressListResultModel)
}
class AddressListViewController: UIViewController {
    
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!

    @IBOutlet weak var addAddressButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var itemDetails: ItemModel?
    var itemDetailsvideo: StoryListModel?
    var viewModel = AddressViewModel()
    var isFromItemDetails = false
    var delegate: AddressDelegate?
    private let refreshControl = UIRefreshControl()
    var addressListArray = [AddressListResultModel]()
    var offerPayment = false
    var offerPrice = ""
    var isfromtype = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        self.loadData()
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
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "no_address")
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.customNavigationBarView(title: "my_address", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.tableView.register(UINib(nibName: "AddressListTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressListTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.addAddressButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.addAddressButton.cornerMiniumRadius()
        self.addAddressButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "addaddress")
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refreshAct), for: .valueChanged)
        Utility.shared.startAnimation(viewController: self)
    }
    @objc func refreshAct() {
        self.loadData()
    }
    func loadData() {
        var id = ""
        if self.isfromtype == "story"{
            id = "\(self.itemDetailsvideo?.id ?? 0)"
            
        }else{
            id = "\(self.itemDetails?.id ?? 0)"
        }
        
        self.viewModel.getShippingAddressAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(id)", onSuccess: { (success) in
            self.addressListArray.removeAll()
            if self.viewModel.addressListModel?.result.count ?? 0 > 0 {
                if let addressList = self.viewModel.addressListModel?.result {
                    for address in addressList {
                        if address.defaultshipping == 1 {
                            self.addressListArray.insert(address, at: 0)
                        }
                        else {
                            self.addressListArray.append(address)
                        }
                    }
                }
            }
            Utility.shared.stopAnimation(viewController: self)
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }) { (failure) in
            self.refreshControl.endRefreshing()
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    @IBAction func addaddressButtonAct(_ sender: UIButton) {
        let pageObj = AddressViewController()
        if self.isfromtype == "story"{
            pageObj.isfromtype = "story"
            pageObj.itemDetailsvideo = self.itemDetailsvideo
        }else{
            pageObj.isfromtype = ""
            pageObj.itemDetails = self.itemDetails
        }
       
        pageObj.viewType = self.isFromItemDetails ? 1 : 0
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
}
extension AddressListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        self.noItemStackView.isHidden = false
        return self.addressListArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.noItemStackView.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressListTableViewCell") as! AddressListTableViewCell
        cell.moreButton.tag = indexPath.section
        cell.moreButton.addTarget(self, action: #selector(self.moreButtonAct(_:)), for: .touchUpInside)
        cell.isFromBuyNowPage = false
        cell.loadData(addressResult: self.addressListArray[indexPath.section])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFromItemDetails {
            let pageObj = BuyNowViewController()
            pageObj.addressDetails = self.addressListArray[indexPath.section]
            pageObj.offerPayment = self.offerPayment
            pageObj.offerPrice = self.offerPrice
            if self.isfromtype == "story"{
                pageObj.isfromtype = "story"
                pageObj.itemDetailsvideo = self.itemDetailsvideo
            }else{
                pageObj.isfromtype = ""
                pageObj.itemDetails = self.itemDetails
            }
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
        else {
            self.delegate?.setAddressDelegate(self.addressListArray[indexPath.section])
        }
    }
    @objc func moreButtonAct(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: getLanguage["Edit"] ?? "", style: .default, handler: { (UIAlertAction) in
            let pageObj = AddressViewController()
            if self.isfromtype == "story"{
                pageObj.itemDetailsvideo = self.itemDetailsvideo
                pageObj.isfromtype = "story"
            }else{
                pageObj.itemDetails = self.itemDetails
                pageObj.isfromtype = ""
            }
            pageObj.addressResult = self.addressListArray[sender.tag]
            pageObj.viewType = self.isFromItemDetails ? 1 : 0
            pageObj.isEditView = true
            self.navigationController?.pushViewController(pageObj, animated: true)
        }))
        if sender.tag != 0 {
            alert.addAction(UIAlertAction(title: getLanguage["delete_product"] ?? "", style: .default, handler: { (UIAlertAction) in
                self.deleterAddress("\(self.addressListArray[sender.tag].shippingid ?? 0)")
            }))
            alert.addAction(UIAlertAction(title: getLanguage["markdefault"] ?? "", style: .default, handler: { (UIAlertAction) in
                Utility.shared.startAnimation(viewController: self)
                self.viewModel.setDefaultAddress(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", shipping_id: "\(self.addressListArray[sender.tag].shippingid ?? 0)", onSuccess: { (success) in
                    if success {
                        self.loadData()
                    }
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func deleterAddress(_ id: String) {
        let alert = UIAlertController(title: nil, message: getLanguage["Are you sure, you want to delete address?"] ?? "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "Ok", style: .default, handler: { (UIAlertAction) in
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.deleteAddress(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", shipping_id: id, onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                self.loadData()
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }))
        alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
