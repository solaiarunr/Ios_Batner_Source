//
//  BuyNowViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 27/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Stripe

class BuyNowViewController: UIViewController {

    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    var itemDetails: ItemModel?
    var itemDetailsvideo: StoryListModel?
    var addressDetails: AddressListResultModel?
    var offerPayment = false
    var offerPrice = ""
    var offerId = ""
    var viewModel = ItemDetailsViewModel()
    var isFromAddAddress = false
    var stripeModel = StripeDataModel()
    var isfromtype = ""
    var stripe_currency = ["BIF","CLP","DJF","GNF","JPY","KMF","KRW","MGA","PYG","RWF","UGX","VND","VUV","XAF","XOF","XPF"];
    let delegate = UIApplication.shared.delegate as! AppDelegate
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
                if isFromAddAddress {
                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                    if viewControllers.count >= 3 {
                        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                    }
                    else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else{
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    func configUI() {
        print("selfitemDetailsvideo",self.itemDetailsvideo)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.NavigationBarWithBackButtonAndTitle(title: "checkout", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.tableView.register(UINib(nibName: "PriceTableViewCell", bundle: nil), forCellReuseIdentifier: "PriceTableViewCell")
        self.tableView.register(UINib(nibName: "AddressListTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressListTableViewCell")
        self.tableView.register(UINib(nibName: "ItemDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemDetailsTableViewCell")
        self.tableView.register(UINib(nibName: "FilterHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterHeaderTableViewCell")
        self.collectionView.register(UINib(nibName: "ItemDetailsImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemDetailsImageCollectionViewCell")
        self.tableView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
        
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.checkOutButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.checkOutButton.cornerMiniumRadius()
        self.checkOutButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "checkout")
    }

    @IBAction func checkOutButtonAct(_ sender: UIButton) {
            self.checkOutButton.isUserInteractionEnabled = false
            self.presentStripe()
    }
    
    @objc func presentStripe() {
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }

        
        let currencyCode: [String]?
        var shippingCost = ""
        var price = ""
        
        
        if self.isfromtype == "story" {
            currencyCode = self.itemDetailsvideo?.currencyCode.components(separatedBy: "-")
            shippingCost = self.itemDetailsvideo?.shippingCost ?? ""
            price =  "\(self.itemDetailsvideo?.price ?? "0")"
        } else {
            currencyCode = self.itemDetails?.currencyCode.components(separatedBy: "-")
            shippingCost = self.itemDetails?.shippingCost ?? ""
            price =  "\(self.itemDetails?.price ?? "0")"
        }

        var cSymbol = ""
        if let parts = currencyCode, parts.count > 1 {
            cSymbol = parts[1]
        }

        if offerPayment {
            price = offerPrice
        }
        price = price.replacingOccurrences(of: ",", with: "")
        let totalVal = (Double(shippingCost) ?? 0)+(Double(price) ?? 0)
        var totalString = String(format: "%.2f", totalVal)
        if stripe_currency.contains(cSymbol) {
            var roundedPrice = price
            var roundedShippingCost = shippingCost
            roundedPrice = String(format: "%.0f", (round((Double(roundedPrice) ?? 0))))
            roundedShippingCost = String(format: "%.0f", (round((Double(roundedShippingCost) ?? 0))))
            let roundedtotalVal = (round((Double(roundedPrice) ?? 0)))+(round((Double(roundedShippingCost) ?? 0)))
            totalString = String(format: "%.0f", roundedtotalVal)
        }
        
        var paymentSheet: PaymentSheet?
        let viewModel = StripeDataViewModel()

        viewModel.getStripeDetails(amount: totalString, currency: cSymbol) { (success) in
            if viewModel.stripeModel?.status ?? false {
                guard let viewData = viewModel.stripeModel else {
                    return
                }
                self.stripeModel = viewData
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = APP_NAME
                configuration.customer = .init(id: self.stripeModel.customer, ephemeralKeySecret: self.stripeModel.ephemeralKey)
                paymentSheet = PaymentSheet(paymentIntentClientSecret: self.stripeModel.paymentIntent, configuration: configuration)
                DispatchQueue.main.async {
                    self.checkOutButton.isUserInteractionEnabled = true
                    paymentSheet?.present(from: self) { paymentResult in
                      // MARK: Handle the payment result
                      switch paymentResult {
                      case .completed:
                          if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                              UIView.appearance().semanticContentAttribute = .forceRightToLeft
                          }
                        print("Your order is confirmed")
                        let token = self.stripeModel.paymentIntent.components(separatedBy: "_secret_")
                        self.payAct(type: "stripe", token: token.first ?? "")
                      case .canceled:
                          if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                              UIView.appearance().semanticContentAttribute = .forceRightToLeft
                          }
                        print("Canceled!")
                        UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(getLanguage["Payment_cancelled"])
                      case .failed(let error):
                          if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                              UIView.appearance().semanticContentAttribute = .forceRightToLeft
                          }
                        print("Payment failed: \n\(error.localizedDescription)")
                      }
                    }
                }
            }
            else {
                let alert = UIAlertController(title: nil, message: getLanguage["amount_too_small"] ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.checkOutButton.isUserInteractionEnabled = true
                self.present(alert, animated: true, completion: nil)
            }
        } onFailure: { (failure) in
            let alert = UIAlertController(title: nil, message: getLanguage["amount_too_small"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.checkOutButton.isUserInteractionEnabled = true
            self.present(alert, animated: true, completion: nil)
        }

    }
}
extension BuyNowViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 3
        }
        return 1
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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemDetailsTableViewCell") as! ItemDetailsTableViewCell
            if self.isfromtype == "story" {
                if let itemData = self.itemDetailsvideo {
                    cell.loadBuyNowDataVideo(itemData)
                }
            }else{
                if let itemData = self.itemDetails {
                    cell.loadBuyNowData(itemData)
                }
            }
           
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressListTableViewCell") as! AddressListTableViewCell
            if let addressDetails = self.addressDetails {
                cell.isFromBuyNowPage = true
                if self.isfromtype == "story" {
                    cell.loadBuyNowData(self.itemDetailsvideo?.sellerName ?? "", addressResult: addressDetails)
                }else{
                    cell.loadBuyNowData(self.itemDetails?.sellerName ?? "", addressResult: addressDetails)
                }
                
               
            }
            cell.changeButton.addTarget(self, action: #selector(self.changeButtonAct), for: .touchUpInside)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PriceTableViewCell") as! PriceTableViewCell
            if self.isfromtype == "story" {
                if let itemData = self.itemDetailsvideo {
                    var price = "\(itemData.price ?? "0")"
                    if offerPayment {
                        price = offerPrice
                    }
                    cell.loadDatavideo(indexPath.row, item: itemData, price: price)
                }
            }else{
                if let itemData = self.itemDetails {
                    var price = "\(itemData.price ?? "0")"
                    
                    if offerPayment {
                        price = offerPrice
                    }
                    cell.loadData(indexPath.row, item: itemData, price: price)
                }
            }
            
            
         
            return cell
        }
    }
    @objc func changeButtonAct() {
        let pageObj = AddressListViewController()
        if self.isfromtype == "story" {
            pageObj.itemDetailsvideo = self.itemDetailsvideo
            pageObj.isfromtype = "story"
        }else{
            pageObj.itemDetails = self.itemDetails
            pageObj.isfromtype = ""
        }
        pageObj.delegate = self
        pageObj.isFromItemDetails = true
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
extension BuyNowViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isfromtype == "story" {
            return (self.itemDetailsvideo?.photos.count ?? 0)
        }else{
            return (self.itemDetails?.photos.count ?? 0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemDetailsImageCollectionViewCell", for: indexPath) as! ItemDetailsImageCollectionViewCell
        if self.isfromtype == "story" {
            if let photos = self.itemDetailsvideo?.photos[indexPath.row] {
                cell.loadData(photos)
            }
        }else{
            if let photos = self.itemDetails?.photos[indexPath.row] {
                cell.loadData(photos)
            }
        }
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.collectionView.bounds.height)
    }
    @objc func scrollAutomatically(_ timer1: Timer) {
        for cell in self.collectionView.visibleCells {
            let indexPath: IndexPath? = collectionView.indexPath(for: cell)
            
            if self.isfromtype == "story" {
                if ((indexPath?.row)!  < (self.itemDetailsvideo?.photos.count ?? 0) - 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                    collectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    collectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
                }
            }else{
                if ((indexPath?.row)!  < (self.itemDetails?.photos.count ?? 0) - 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                    collectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    collectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
                }
                
            }
            
       
        }
    }
}
extension BuyNowViewController: PaymentViewControllerDelegate {
    func paymentViewController(_ token: STPToken) {
        print("stripestripe \(token)")
        self.payAct(type: "stripe", token: "\(token)")
    }
    func payAct(type: String, token: String) {
        Utility.shared.startAnimation(viewController: self)

        let currencyCode: [String]?
        var shippingCost = ""
        var price = ""
        if self.isfromtype == "story" {
            currencyCode = self.itemDetailsvideo?.currencyCode.components(separatedBy: "-")
            shippingCost = self.itemDetailsvideo?.shippingCost ?? ""
            price =  "\(self.itemDetailsvideo?.price ?? "0")"
        } else {
            currencyCode = self.itemDetails?.currencyCode.components(separatedBy: "-")
            shippingCost = self.itemDetails?.shippingCost ?? ""
            price =  "\(self.itemDetails?.price ?? "0")"
        }

        var cSymbol = ""
        if let parts = currencyCode, parts.count > 1 {
            cSymbol = parts[1]
        }
        if offerPayment {
            price = offerPrice
        }
        price = price.replacingOccurrences(of: ",", with: "")
        let totalVal = (Double(shippingCost) ?? 0)+(Double(price) ?? 0)
        let totalString = String(format: "%.2f", totalVal)
        
        if self.isfromtype == "story" {
            self.viewModel.paymentAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetailsvideo?.id ?? 0)", shipping_id: "\(self.addressDetails?.shippingid ?? 0)", merchant_id: (self.itemDetailsvideo?.sellerId ?? ""), currency_code: cSymbol, nonce: token, item_price: (offerPayment == true ? offerPrice : "\(self.itemDetailsvideo?.price ?? "0")"), shipping_fee: shippingCost, order_total: totalString, offer_id: self.offerId, payment_type: type, onSuccess: { (success) in
                var alertMessage = (self.viewModel.checkoutModel?.message ?? "")
                if !(self.viewModel.checkoutModel?.status ?? false) {
                    alertMessage = "payment_error"
                }
                else {
                    alertMessage = "ordered_successfully"
                }
                let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage[alertMessage] ?? (self.viewModel.checkoutModel?.message ?? ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: { (UIAlertAction) in
                    let pageObj = MyOrderSegmentViewController()
                    pageObj.isTabbar = true
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }))
                Utility.shared.stopAnimation(viewController: self)
                self.present(alert, animated: true, completion: nil)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
            
        }else{
            self.viewModel.paymentAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetails?.id ?? 0)", shipping_id: "\(self.addressDetails?.shippingid ?? 0)", merchant_id: (self.itemDetails?.sellerId ?? ""), currency_code: cSymbol, nonce: token, item_price: (offerPayment == true ? offerPrice : "\(self.itemDetails?.price ?? "0")"), shipping_fee: shippingCost, order_total: totalString, offer_id: self.offerId, payment_type: type, onSuccess: { (success) in
                var alertMessage = (self.viewModel.checkoutModel?.message ?? "")
                if !(self.viewModel.checkoutModel?.status ?? false) {
                    alertMessage = "payment_error"
                }
                else {
                    alertMessage = "ordered_successfully"
                }
                let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage[alertMessage] ?? (self.viewModel.checkoutModel?.message ?? ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: { (UIAlertAction) in
                    let pageObj = MyOrderSegmentViewController()
                    pageObj.isTabbar = true
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }))
                Utility.shared.stopAnimation(viewController: self)
                self.present(alert, animated: true, completion: nil)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
            
        }
        
    }
}
extension BuyNowViewController: AddressDelegate {
    func setAddressDelegate(_ address: AddressListResultModel) {
        self.addressDetails = address
        self.navigationController?.popViewController(animated: true)
        self.tableView.reloadData()
    }
}
