//
//  MyOrderSalesDetailViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 08/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Cosmos

class MyOrderSalesDetailViewController: UIViewController,DateDelegate {
   
    @IBOutlet weak var reviewView: CosmosView!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewWholeView: UIView!
    @IBOutlet weak var printPageNumberLabel: UILabel!
    @IBOutlet weak var printurlLabel: UILabel!
    @IBOutlet weak var printDateLabel: UILabel!
    @IBOutlet weak var printTitleLabel: UILabel!
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var orderDetailsLabel: UILabel!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var paymentStatusLabel: UILabel!
    @IBOutlet weak var buyerDetailsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var shippingDetailsLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var mobileNoLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalPriceTitleLabel: UILabel!
    @IBOutlet weak var shippingFeeLabel: UILabel!
    @IBOutlet weak var shippingFeeTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemNameTitleLabel: UILabel!
    
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    
    var viewModel = MyOrderSalesViewModel()
    var orderResultData: MyOrderResultModel?
     var statusVal = ""
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
        self.NavigationBarButtonItem()
        self.rightBarButtonItem()
        self.configPrintView()
        self.tableView.reloadData()
        if ((self.orderResultData?.status ?? "") == "paid" || (self.orderResultData?.status ?? "") == "delivered") && self.view.tag == 0 {
            if (self.orderResultData?.rating ?? 0) == 0 {
                self.reviewWholeView.isHidden = false
                self.reviewView.rating = Double(self.orderResultData?.rating ?? 0)
            }
            else {
                self.reviewWholeView.isHidden = true
            }
        }
        if self.view.tag == 1 {
            self.chatButton.setTitle((getLanguage["chatwithbuyer"] ?? ""), for: .normal)
        }
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
    func configPrintView() {
        self.orderDetailsLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 16), align: .left, text: "")
        let dateString = Utility.shared.timeStampWithDateFormat(timeStamp: "\(orderResultData?.saledate ?? 0)", dateFormat: "MMM dd, YYYY")
        self.orderDetailsLabel.text = "\(getLanguage["order"] ?? "")# \(self.orderResultData?.invoice ?? "") \(getLanguage["on"] ?? "") \(dateString)"
        self.paymentTypeLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.paymentTypeLabel.text = "\(getLanguage["payment_method"] ?? ""): \(self.orderResultData?.paymentType ?? "")"
        self.paymentStatusLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.paymentStatusLabel.text = "\(getLanguage["payment_status"] ?? ""): Completed"
        self.buyerDetailsLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 13), align: .left, text: "buyer_detail")
        self.nameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 13), align: .left, text: "")
        self.nameLabel.text = "\(getLanguage["addressname"] ?? ""): \(self.orderResultData?.orderitems.buyerName ?? "")"
        self.emailLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.emailLabel.text = "\(getLanguage["email"] ?? ""): \(self.orderResultData?.orderitems.buyerEmail ?? "")"
        self.shippingDetailsLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 13), align: .left, text: "shippingdetails")
        self.userNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.userNameLabel.text = "\(orderResultData?.shippingaddress.name ?? ""),"
        self.firstNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.firstNameLabel.text = "\(orderResultData?.shippingaddress.nickname ?? ""),"
        self.address1Label.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.address1Label.text = "\(orderResultData?.shippingaddress.address1 ?? ""),"
        self.cityLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.cityLabel.text = "\(orderResultData?.shippingaddress.city ?? ""),"
        self.mobileNoLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.mobileNoLabel.text = "\(getLanguage["phonenumber"] ?? ""): \(orderResultData?.shippingaddress.phone ?? "")"
        self.countryLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.countryLabel.text = orderResultData?.shippingaddress.country
        self.stateLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.stateLabel.text = orderResultData?.shippingaddress.state
        self.itemNameTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .left, text: "item_name")
        self.itemNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.itemNameLabel.text = "\(orderResultData?.orderitems.itemname ?? "0")"
        self.totalPriceTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 13), align: .left, text: "total_price")
        self.shippingFeeTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 13), align: .left, text: "shippingfee")
        self.shippingFeeTitleLabel.text = (getLanguage["shippingfee"] ?? "").capitalized
        self.priceTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 13), align: .left, text: "item_unit_price")
        self.priceLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .right, text: "")
        self.priceLabel.text = "\(orderResultData?.orderitems.formattedPrice ?? "0")"
        self.shippingFeeLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .right, text: "")
        self.shippingFeeLabel.text = "\(orderResultData?.orderitems.formattedShippingCost ?? "0")"
        self.totalPriceLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .right, text: "")
        self.totalPriceLabel.text = "\(orderResultData?.orderitems.formattedTotal ?? "0")"
        
        self.printTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 9), align: .left, text: "")
        self.printTitleLabel.text = "\(APP_NAME) | \(APP_NAME) \(getLanguage["print_title"] ?? "")"
        self.printDateLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 9), align: .right, text: "")
        self.printDateLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(Date().timeIntervalSince1970)", dateFormat: "dd/MM/yy HH:mm a")
        self.printurlLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 9), align: .left, text: "")
        self.printurlLabel.text = BASE_URL + "sales"
        self.printPageNumberLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 9), align: .right, text: "")
        self.printPageNumberLabel.text = "Page 1 of 1"
    }
    func configUI() {
        self.reviewWholeView.isHidden = true
        self.printView.isHidden = true
        self.navigationController?.isNavigationBarHidden = true

        self.reviewTitleLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "Review and rating based on the experience")
        self.reviewButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "Write a review")
        self.reviewButton.cornerMiniumRadius()
        self.reviewButton.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.tableView.register(UINib(nibName: "PriceTableViewCell", bundle: nil), forCellReuseIdentifier: "PriceTableViewCell")
        self.tableView.register(UINib(nibName: "AddressListTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressListTableViewCell")
        self.tableView.register(UINib(nibName: "ItemDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemDetailsTableViewCell")
        self.tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewTableViewCell")
        self.tableView.register(UINib(nibName: "FilterHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterHeaderTableViewCell")
        self.collectionView.register(UINib(nibName: "ItemDetailsImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemDetailsImageCollectionViewCell")
        self.tableView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        
//        self.chatButton.backgroundColor = UIColor(named: "AppThemeColorNEW") ?? .white
        self.chatButton.cornerMiniumRadius()
        self.chatButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "chatwithseller")
    }
    func NavigationBarButtonItem() {
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "detail_back").imageFlippedForRightToLeftLayoutDirection(), for: UIControl.State.normal)
        button.tintColor = UIColor(named: "whitecolor")
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tag = 0
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        button.addTarget(self, action: #selector(self.leftBarButtonAct(_:)), for: .touchUpInside)
        
        let button1: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button1.setImage(self.resizedImage(at: #imageLiteral(resourceName: "applogo"), for: CGSize(width: 40, height: 40)), for: .normal)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "applogo"))
        imageView.sd_setImage(with: URL(string: self.orderResultData?.orderitems.buyerImg ?? ""), placeholderImage: #imageLiteral(resourceName: "applogo")) { (image, error, cache, url) in
            button1.setImage(self.resizedImage(at: (image ?? #imageLiteral(resourceName: "applogo")), for: CGSize(width: 40, height: 40)), for: .normal)
            button1.contentMode = .scaleAspectFill
            button1.layer.cornerRadius = 20
            button1.clipsToBounds = true
        }

        button1.tag = 1
        button1.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button1.addTarget(self, action: #selector(self.leftBarButtonAct(_:)), for: .touchUpInside)
        button1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        let button2: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button2.titleLabel?.lineBreakMode = .byTruncatingTail
        button2.titleLabel?.font = UIFont(name: APP_FONT_REGULAR, size: 20) ?? UIFont.systemFont(ofSize: 14)
        button2.setTitle((self.orderResultData?.orderitems.buyerName ?? ""), for: .normal)
        button2.tag = 2
        button2.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: button), UIBarButtonItem(customView: button1), UIBarButtonItem(customView: button2)]
    }
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    @objc func leftBarButtonAct(_ sender: UIButton) {
        if sender.tag == 0 {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func rightBarButtonTabbed(_ sender: UIButton) {
        if sender.tag == 0 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: (getLanguage["cancel"] ?? ""), style: .cancel, handler: nil))
            if ((self.orderResultData?.status ?? "") == "pending" || (self.orderResultData?.status ?? "") == "processing") {
                var titleString = ""
                if self.view.tag == 0 && (self.orderResultData?.cancel ?? false){
                    titleString = "cancelorder"
                }
                else if self.view.tag == 1 {
                     if (self.orderResultData?.status ?? "") == "pending" {
                         titleString = "markasprocessing"
                     }
                     else {
                         titleString = "markasshipped"
                     }
                }
                if titleString != "" {
                    alert.addAction(UIAlertAction(title: (getLanguage[titleString] ?? ""), style: .default, handler: { (UIAlertAction) in
                        self.view.endEditing(true)
                        if titleString == "cancelorder" {
                            self.cancelAlertAct()
                        }
                        else if titleString == "markasshipped" {
                            self.shippingAct("add")
                        }
                        else {
                            self.alertAct(titleString)
                        }
                    }))
                }
            }
            else if ((self.orderResultData?.status ?? "") == "paid" || (self.orderResultData?.status ?? "") == "delivered" || (self.orderResultData?.status ?? "") == "claimed") || (self.orderResultData?.status ?? "") == "shipped"{
                
                if ((self.orderResultData?.status ?? "") == "claimed" || (self.orderResultData?.status ?? "") == "shipped") && self.view.tag == 0 {
                    alert.addAction(UIAlertAction(title: getLanguage["markasreceived"], style: .default, handler: { (UIAlertAction) in
                        self.alertAct("markasreceived")
                        self.view.endEditing(true)
                    }))
                }
                
                if (self.orderResultData?.status ?? "") == "shipped" && self.view.tag == 1 {
                    alert.addAction(UIAlertAction(title: getLanguage["edittracking"], style: .default, handler: { (UIAlertAction) in
                        self.shippingAct("edit")
                        self.view.endEditing(true)
                    }))
                    if (self.orderResultData?.claim ?? false) {
                        alert.addAction(UIAlertAction(title: (getLanguage["claim"] ?? ""), style: .default, handler: { (UIAlertAction) in
                            self.view.endEditing(true)
                            self.alertAct("claim")
                        }))
                    }
                }
                else {
                    if self.view.tag == 0 && (self.orderResultData?.cancel ?? false){
                        alert.addAction(UIAlertAction(title: (getLanguage["cancelorder"] ?? ""), style: .default, handler: { (UIAlertAction) in
                            self.view.endEditing(true)
                            self.cancelAlertAct()
                        }))
                    }
                    alert.addAction(UIAlertAction(title: (getLanguage["shippingdetails"] ?? ""), style: .default, handler: { (UIAlertAction) in
                        self.view.endEditing(true)
                        self.shippingAct("view")
                    }))
                    
                }
            }
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.printView.isHidden = false
            let _ = self.printView.exportAsPdfFromView()
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docDirectoryPath = paths[0]
            let pdfPath = docDirectoryPath.appendingPathComponent("yourPDF.pdf")
            do {
                let printData = try Data(contentsOf: pdfPath)
                let printController = UIPrintInteractionController.shared
                if UIPrintInteractionController.canPrint(printData) {
                    printController.delegate = self
                    let printInfo = UIPrintInfo.printInfo()
                    printInfo.outputType = .general
                    printInfo.jobName = pdfPath.lastPathComponent
                    printInfo.duplex = .longEdge
                    printController.printInfo = printInfo
                    printController.printingItem = printData
                }
                printController.present(animated: true)
            } catch _ {
            }
            
        }
    }
    func shippingAct(_ value: String) {
        let pageObj = ShippingInfoViewController()
        pageObj.orderVC = self
         pageObj.orderResultData = self.orderResultData
        pageObj.DateDelegate = self
        pageObj.viewType = value
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
    func cancelAlertAct() {
        let alert = UIAlertController(title: nil, message: (getLanguage["Are you sure, you want to cancel the order?"] ?? ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: (getLanguage["cancel"] ?? ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: (getLanguage["ok"] ?? ""), style: .default) { (UIAlertAction) in
            self.alertAct("cancelorder")
        })
        self.present(alert, animated: true, completion: nil)
    }
    func alertAct(_ value: String) {
        
        if value == "claim" {
            statusVal = "claim"
        }
        else if value == "markasreceived"{
            statusVal = "Delivered"
        }
        else if value == "cancelorder" {
            statusVal = "cancel"
        }
        else if value == "markasprocessing" {
            statusVal = "Processing"
        }
        if title != "" {
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.getOrderStatus(orderid: "\(self.orderResultData?.orderid ?? 0)", chstatus: self.statusVal, subject: "", message: "", id: "", shippingdate: "", couriername: "", courierservice: "", trackid: "", notes: "", onSuccess: { (success) in
                let alert = UIAlertController(title: nil, message: (getLanguage[self.orderResultData?.status ?? ""] ?? (self.orderResultData?.status ?? "")).capitalized, preferredStyle: .alert)

                if success {
                    if (self.orderResultData?.status ?? "") == "cancelled" || self.statusVal == "cancel" {
                        self.orderResultData?.status = "cancelled"
                    }
                    else if self.view.tag == 1 {
                        if (self.orderResultData?.status ?? "") == "processing" || (self.orderResultData?.status ?? "") == "pending" {
                            self.orderResultData?.status = "processing"
                        }
                        else if (self.orderResultData?.status ?? "") == "shipped" {
                            if self.statusVal == "claim" {
                                self.orderResultData?.status = "claimed"
                            }
                        }
                    }
                    else if ((self.orderResultData?.status ?? "") == "shipped") {
                        self.orderResultData?.status = "delivered"
                        self.reviewWholeView.isHidden = false
                        self.reviewView.rating = Double(self.orderResultData?.rating ?? 0)
                    }
                    alert.message = (getLanguage[self.orderResultData?.status ?? ""] ?? (self.orderResultData?.status ?? ""))
                }
                else{
                    alert.message = getLanguage["failed"] ?? ""
                }
                alert.addAction(UIAlertAction(title: (getLanguage["ok"] ?? ""), style: .default, handler: { (UIAlertAction) in
                    if success {
                        self.rightBarButtonItem()
                        self.tableView.reloadData()
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                Utility.shared.stopAnimation(viewController: self)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
    }
    func rightBarButtonItem() {
        let rbutton: UIButton = UIButton(type: UIButton.ButtonType.custom)
        rbutton.setImage(#imageLiteral(resourceName: "option"), for: UIControl.State.normal)
        rbutton.tintColor = UIColor(named: "whitecolor")
        rbutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rbutton.tag = 0
        rbutton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        rbutton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)

        rbutton.addTarget(self, action: #selector(self.rightBarButtonTabbed), for: .touchUpInside)
        
        let rbutton1: UIButton = UIButton(type: UIButton.ButtonType.custom)
        rbutton1.setImage(#imageLiteral(resourceName: "print"), for: UIControl.State.normal)
        rbutton1.tintColor = UIColor(named: "whitecolor")
        rbutton1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rbutton1.tag = 1
        rbutton1.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        rbutton1.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)

        rbutton1.addTarget(self, action: #selector(self.rightBarButtonTabbed), for: .touchUpInside)
        if self.view.tag == 0 {
            if ((self.orderResultData?.status ?? "") != "processing" || (self.orderResultData?.cancel ?? false)) && (self.orderResultData?.status ?? "") != "cancelled"{
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rbutton)
            }
            else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        else {
            
            if ((orderResultData?.status ?? "") != "cancelled") && ((orderResultData?.cancel ?? false) || (orderResultData?.status ?? "") != "shipped" || (orderResultData?.status ?? "") != "delivered" || (orderResultData?.status ?? "") != "claimed" || (orderResultData?.status ?? "") != "paid") {
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rbutton), UIBarButtonItem(customView: rbutton1)]
            }
            else {
                if ((orderResultData?.status ?? "") != "cancelled"){
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rbutton)
                }
                else {
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
        }
    }
    
    @IBAction func reviewButtonAct(_ sender: UIButton) {
        let pageObj = WriteReviewViewController()
        pageObj.orderVC = self
        pageObj.review_type = "order"
        pageObj.orderResultData = self.orderResultData
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
    @IBAction func chatButtonAct(_ sender: UIButton) {
        let itemDetailModel = ItemDetailsViewModel()
        Utility.shared.startAnimation(viewController: self)
        itemDetailModel.getChatIdAct(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: "\(self.orderResultData?.orderitems.buyerId ?? 0)", onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            if success {
                let pageObj = ChatViewController()
                pageObj.receiverId = "\(self.orderResultData?.orderitems.buyerId ?? 0)"
                pageObj.chatId = (itemDetailModel.itemChatModel?.chatId ?? "")
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    func DateAct(_ DateStr: Int) {
        orderResultData?.trackingdetails.shippingdate = DateStr
    }
}
extension MyOrderSalesDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 3
        }
        else if section == 1 {
            if (self.orderResultData?.rating ?? 0) > 0 && self.view.tag == 0{
                return 1
            }
        }
        else {
            return 2
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return UITableView.automaticDimension
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterHeaderTableViewCell") as! FilterHeaderTableViewCell
        cell.overAllView.backgroundColor = UIColor(named: "whitecolorNEW")
        cell.headerLabel.font = UIFont(name: APP_FONT_BOLD, size: 15)
        cell.headerLabel.text = (getLanguage["pricedetails"] ?? "").uppercased()
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemDetailsTableViewCell") as! ItemDetailsTableViewCell
            if let result = self.orderResultData {
                cell.loadOrderData(result, viewType: self.view.tag)
            }
            return cell
        }
        else if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressListTableViewCell") as! AddressListTableViewCell
            if let result = self.orderResultData {
                cell.isFromBuyNowPage = true
                cell.loadOrderSalesData(result, viewType: self.view.tag)
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell") as! ReviewTableViewCell
            if let result = self.orderResultData {
                cell.loadData(result)
            }
            if self.view.tag == 0 {
                cell.editReviewButton.isHidden = false
            }
            else {
                cell.editReviewButton.isHidden = true
            }
            cell.editReviewButton.addTarget(self, action: #selector(editReviewAct), for: .touchUpInside)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PriceTableViewCell") as! PriceTableViewCell
            if let itemData = self.orderResultData {
                cell.loadOrderData(indexPath.row, item: itemData.orderitems)
            }
            return cell
        }
    }
    @objc func editReviewAct() {
        let pageObj = WriteReviewViewController()
        pageObj.orderResultData = self.orderResultData
        pageObj.review_type = "order"
        pageObj.orderVC = self
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let y = 300 - (scrollView.contentOffset.y + 300)
            let height = min(max(y, 0), 400)
            topViewHeightConst.constant = height
            self.collectionView.reloadData()
            if self.topViewHeightConst.constant < 10 {
                self.collectionView.isHidden = true
                self.topView.isHidden = true
            }
            else {
                self.collectionView.isHidden = false
                self.topView.isHidden = false
            }
        }
    }
}
extension MyOrderSalesDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemDetailsImageCollectionViewCell", for: indexPath) as! ItemDetailsImageCollectionViewCell
        if let photos = self.orderResultData?.orderitems.orderImage {
            cell.itemImageView.sd_setImage(with: URL(string: photos), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.collectionView.bounds.height)
    }
}
extension MyOrderSalesDetailViewController: UIPrintInteractionControllerDelegate {
    func printInteractionControllerParentViewController(_ printInteractionController: UIPrintInteractionController) -> UIViewController? {
        return self.navigationController
    }
    func printInteractionControllerDidPresentPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
        self.navigationController?.navigationBar.tintColor = UIColor(named: "whitecolor")
        self.navigationController?.topViewController?.navigationController?.navigationBar.tintColor = UIColor(named: "whitecolor")
    }
}
extension UIView {
    // Export pdf from Save pdf in drectory and return pdf file path
    func exportAsPdfFromView() -> String {
        
        let pdfPageFrame = self.bounds
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
        self.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        return self.saveViewPdf(data: pdfData)
        
    }
    
    // Save pdf file in document directory
    func saveViewPdf(data: NSMutableData) -> String {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent("yourPDF.pdf")
        if data.write(to: pdfPath, atomically: true) {
            return pdfPath.path
        } else {
            return ""
        }
    }
    
}
