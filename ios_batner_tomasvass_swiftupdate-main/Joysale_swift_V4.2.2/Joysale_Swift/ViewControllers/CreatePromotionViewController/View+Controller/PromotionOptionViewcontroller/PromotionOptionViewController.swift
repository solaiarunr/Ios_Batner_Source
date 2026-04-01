//
//  PromotionOptionViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 22/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

 

//original
/*
 

import UIKit
import Stripe
import BraintreeDropIn
import Braintree
import NVActivityIndicatorView

class PromotionOptionViewController: UIViewController {
    @IBOutlet weak var activityLoader: NVActivityIndicatorView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var viewModel = PromotionViewModel()
    var selectedTag: Int!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var itemID = ""
    var stripeModel = StripeDataModel()
    var paymentSheetFlowController: PaymentSheet.FlowController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(indicatorView)
        self.configUI()
        self.loadData()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewDidLayoutSubviews() {
       
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
    }
    func configUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "PromotionOptionTableViewCell", bundle: nil), forCellReuseIdentifier: "PromotionOptionTableViewCell")
        self.tableView.register(UINib(nibName: "PromotionHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "PromotionHeaderTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50
        self.payButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.payButton.cornerMiniumRadius()
        self.payButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "pay_and_promote")
    }
    func loadData() {
        self.activityLoader.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.viewModel.getPromotionData(onSuccess: { (success) in
            self.tableView.reloadData()
            self.activityLoader.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }) { (failure) in
            self.activityLoader.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    @IBAction func payButtonAct(_ sender: UIButton) {
        print("adminPaymentType123",ADMIN_VIEW_MODEL.adminModel?.result.adminPaymentType)
        self.payButton.isUserInteractionEnabled = false
        var isValid = true
        if self.view.tag == 0 {
            var promotionID = "0"
            if let selectedCell = self.selectedTag, (self.viewModel.getPromotionModel?.result.otherPromotions.count ?? 0) > selectedCell {
                promotionID = "\(self.viewModel.getPromotionModel?.result.otherPromotions[selectedCell].id ?? 0)"
            }
            if promotionID == "0" {
                isValid = false
            }
        }
        if isValid {
            if ADMIN_VIEW_MODEL.adminModel?.result.adminPaymentType == "braintree" {
                self.presentDropInController()
            }
            else {
                self.presentStripe()
            }
        }
        else {
            let alert = UIAlertController(title: nil, message: getLanguage["Please select the Promotion, you like to pay for"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.payButton.isUserInteractionEnabled = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func presentStripe() {
        let cSymbol = (self.viewModel.getPromotionModel?.result.currencyCode ?? "").trimmingCharacters(in: .whitespaces)
        var price = "\(self.viewModel.getPromotionModel?.result.urgent ?? 0)"
        if self.view.tag == 0 {
            if let selectedCell = self.selectedTag, (self.viewModel.getPromotionModel?.result.otherPromotions.count ?? 0) > selectedCell {
                price = "\(self.viewModel.getPromotionModel?.result.otherPromotions[selectedCell].price ?? "0")"
            }
        }
        var paymentSheet: PaymentSheet?
        let viewModel = StripeDataViewModel()
        viewModel.getStripeDetails(amount: price, currency: cSymbol) { (success) in
            if viewModel.stripeModel?.status ?? false {
                guard let viewData = viewModel.stripeModel else {
                    return
                }
                self.stripeModel = viewData
                
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Example, Inc."
//                configuration.redir
                configuration.customer = .init(id: self.stripeModel.customer, ephemeralKeySecret: self.stripeModel.ephemeralKey)
                paymentSheet = PaymentSheet(paymentIntentClientSecret: self.stripeModel.paymentIntent, configuration: configuration)
                DispatchQueue.main.async {
                    self.payButton.isUserInteractionEnabled = true
                    let delegate = UIApplication.shared.delegate as! AppDelegate

                    paymentSheet?.present(from: delegate.navigationController) { paymentResult in
                      // MARK: Handle the payment result
                      switch paymentResult {
                      case .completed:
                        print("Your order is confirmed")
                        let token = self.stripeModel.paymentIntent.components(separatedBy: "_secret_")
                        DispatchQueue.main.async {
                            self.payAct(type: "stripe", token: token.first ?? "")
                        }
                      case .canceled:
                        print("Canceled!")
                      case .failed(let error):
                        print("Payment failed: \n\(error.localizedDescription)")
                      }
                    }
                }
            }
            else {
                let alert = UIAlertController(title: nil, message: getLanguage["amount_too_small"] ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.payButton.isUserInteractionEnabled = true
                self.present(alert, animated: true, completion: nil)
            }
        } onFailure: { (failure) in
            let alert = UIAlertController(title: nil, message: getLanguage["amount_too_small"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.payButton.isUserInteractionEnabled = true
            self.present(alert, animated: true, completion: nil)
        }

    }
    @objc func presentDropInController() {
        DispatchQueue.main.async {
           self.payButton.isUserInteractionEnabled = true
        }
       // BTUIKAppearance.sharedInstance()?.colorScheme = BTUIKColorScheme(rawValue: 0)!
        let dropInRequest = BTDropInRequest()
        let dropInController = BTDropInController(authorization: BRAINTREE_TOKEN, request: dropInRequest) { (dropInController, result, error) in
            guard let result = result, error == nil else {
                print("Error: \(error!)")
                let alert = UIAlertController(title: nil, message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }

            if result.isCanceled {
                print("Cancelled🎲")
            } else if result.paymentMethodType == .applePay {
                print("Ready for checkout...")
            } else if let nonce = result.paymentMethod?.nonce {
                print("Ready for checkout...")
                self.payAct(type: "braintree", token: "\(nonce)")
            }
            dropInController.dismiss(animated: true, completion: nil)
        }

        guard let dropIn = dropInController else {
            return
        }
        self.delegate.navigationController.present(dropIn, animated: true, completion: nil)
       // present(dropIn, animated: true, completion: nil)
    }
}
extension PromotionOptionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.view.tag == 0 {
            return self.viewModel.getPromotionModel?.result.otherPromotions.count ?? 0
        }
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PromotionHeaderTableViewCell") as! PromotionHeaderTableViewCell
        cell.loadFooterData(viewTag: self.view.tag)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PromotionHeaderTableViewCell") as! PromotionHeaderTableViewCell
        cell.loadHeaderData(viewTag: self.view.tag)
        if self.view.tag == 1 {
            cell.priceLabel.text = self.viewModel.getPromotionModel?.result.formattedUrgent ?? ""
        }
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionOptionTableViewCell") as! PromotionOptionTableViewCell
        if let promotionData = self.viewModel.getPromotionModel?.result.otherPromotions[indexPath.row] {
            cell.loadData(promotionData: promotionData, index: indexPath.row)
        }
        if let selectedCell = self.selectedTag, selectedCell == indexPath.row {
            cell.selectedView.isHidden = false
        }
        else {
            cell.selectedView.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTag = indexPath.row
        self.tableView.reloadData()
    }
}
extension PromotionOptionViewController: PaymentViewControllerDelegate {
    func paymentViewController(_ token: STPToken) {
        self.payAct(type: "stripe", token: "\(token)")
    }
    
    func payAct(type: String, token: String) {
        let cSymbol = (self.viewModel.getPromotionModel?.result.currencyCode ?? "").trimmingCharacters(in: .whitespaces)
        var promotionID = "0"
        if self.view.tag == 0 {
            if let selectedCell = self.selectedTag, (self.viewModel.getPromotionModel?.result.otherPromotions.count ?? 0) > selectedCell {
                promotionID = "\(self.viewModel.getPromotionModel?.result.otherPromotions[selectedCell].id ?? 0)"
            }
        }
        self.activityLoader.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.viewModel.processingPayment(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: self.itemID, promotion_id: promotionID, currency_code: cSymbol, pay_nonce: "\(token)", payment_type: type, onSuccess: { (success) in
            self.activityLoader.stopAnimating()
            self.view.isUserInteractionEnabled = true
            let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage[(self.viewModel.checkoutModel?.message ?? "")] ?? (self.viewModel.checkoutModel?.message ?? ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: { (UIAlertAction) in
                let pageObj = ViewProfileViewController()
                pageObj.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                pageObj.isTabBar = true
                ADD_EDIT_ITEM_MODEL = AddEditViewModel()
                self.delegate.navigationController.pushViewController(pageObj, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }) { (failure) in
            self.activityLoader.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
        
    }
}

 */
protocol PromotionLoadDelegate: AnyObject {
    func promotionPageLoaded()
    func promotionPageLoadedActive()
}




import StoreKit
import NVActivityIndicatorView

class PromotionOptionViewController: UIViewController {
    @IBOutlet weak var activityLoader: NVActivityIndicatorView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var viewModel = PromotionViewModel()
    var selectedTag: Int?
    var itemID = ""
    var products: [Product] = []
    var adIds: [String] = []
    var validPromotions: [OtherPromotionModel] = []
    let delegate = UIApplication.shared.delegate as! AppDelegate
    weak var Prodelegate: PromotionLoadDelegate?
    var selectedPrice = ""
    var selectedCurrencySymbol = ""
    var selectedCurrency = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadData()
        
    }

    func configUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "PromotionOptionTableViewCell", bundle: nil),
                                forCellReuseIdentifier: "PromotionOptionTableViewCell")
        self.tableView.register(UINib(nibName: "PromotionHeaderTableViewCell", bundle: nil),
                                forHeaderFooterViewReuseIdentifier: "PromotionHeaderTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50

        self.payButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.payButton.cornerMiniumRadius()
        self.payButton.config(color: UIColor(named: "whitecolor"),
                              font: UIFont(name: APP_FONT_REGULAR, size: 15),
                              align: .center,
                              title: "pay_and_promote")
    }

    func loadData() {
        self.activityLoader.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.viewModel.getPromotionData(onSuccess: { _ in
            self.adIds =
                self.viewModel.getPromotionModel?.result.otherPromotions
                    .compactMap { $0.ios_id } ?? []
            self.loadProducts()
            self.tableView.reloadData()
            self.activityLoader.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }) { _ in
            self.activityLoader.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    func loadProducts() {
        Task {
            do {
                self.products = try await IAPManager.shared.loadProducts(ids: self.adIds)
                

                print("Products loaded:", products.map { $0.id })
                filterValidPromotions()   // ← NEW

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            } catch {
                print("Error loading products: \(error)")
            }
        }
    }

    func filterValidPromotions() {
        let storeIDs = Set(products.map { $0.id })

        if let promotions = self.viewModel.getPromotionModel?.result.otherPromotions {
            // keep only promotions whose ios_id matches product.id AND exclude urgent
            self.validPromotions = promotions.filter {
                storeIDs.contains($0.ios_id) && $0.ios_id != "com.app.urgentpromoplan"
            }
        }
        
        // SORT promotions by StoreKit price
        self.validPromotions.sort { promo1, promo2 in
            let p1 = products.first(where: { $0.id == promo1.ios_id })?.price ?? 0
            let p2 = products.first(where: { $0.id == promo2.ios_id })?.price ?? 0
            return p1 < p2
        }
        print("Valid promotions:", validPromotions.map { $0.ios_id })
    }
    
    


    func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func handlePurchase(for product: Product) {
        Task {
            self.activityLoader.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.Prodelegate?.promotionPageLoaded()
            do {
                print("🔄 Purchase Started for: \(product.id)")
                let transaction = try await IAPManager.shared.purchase(product)
                print("✅ Purchase Completed: \(transaction.productID)")
                self.payAct(type: "inapp", token: transaction.productID)

            } catch {
                self.activityLoader.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if let storeError = error as? StoreKitError {
                    switch storeError {
                    case .userCancelled:
                        print("⚠️ Purchase Cancelled by User")
                        self.showAlert(title: "Cancelled", message: "You cancelled the purchase.")
                    default:
                        print("❌ Purchase Failed: \(storeError.localizedDescription)")
                        self.showAlert(title: "Payment Failed",
                                       message: storeError.localizedDescription)
                    }
                    self.Prodelegate?.promotionPageLoadedActive()
                } else {
                    print("❌ Unknown Purchase Error: \(error.localizedDescription)")
                    self.showAlert(title: "Payment Failed",
                                   message: error.localizedDescription)
                    self.Prodelegate?.promotionPageLoadedActive()
                }
            }
        }
    }
    
    @IBAction func payButtonAct(_ sender: UIButton) {
        // 🔴 URGENT PLAN
        if self.view.tag == 1 {
            guard let urgentProduct = products.first(where: { $0.id == "com.app.urgentpromoplan" }) else {
                print("❌ Urgent product not loaded")
                return
            }

            // ✅ SET SELECTED PRICE FOR URGENT PLAN
            self.selectedPrice = "\(urgentProduct.price)"
            
            let currencyCode = urgentProduct.priceFormatStyle.currencyCode
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            
            self.selectedCurrencySymbol = formatter.currencySymbol     // ₹ / $
            self.selectedCurrency = currencyCode                       // INR / USD

            handlePurchase(for: urgentProduct)
            return
        }


        // 🔵 PROMOTION PLANS
        if validPromotions.isEmpty {
            showAlert(title: nil, message: "No ad promotions available. Please try again later.")
            return
        }

        guard let selected = selectedTag,
              selected < validPromotions.count else {
            showAlert(title: nil, message: "Please select a promotion to continue.")
            return
        }

        let promotion = validPromotions[selected]

        guard let product = products.first(where: { $0.id == promotion.ios_id }) else {
            showAlert(title: nil, message: "Selected promotion not available. Please try again.")
            return
        }

        handlePurchase(for: product)
    }



    func payAct(type: String, token: String) {
        let cSymbol = (self.viewModel.getPromotionModel?.result.currencyCode ?? "").trimmingCharacters(in: .whitespaces)
        var promotionID = "0"




        
        
        if self.view.tag == 1 {
              promotionID = "urgent"
          } else if self.view.tag == 0 {
              if let selectedCell = self.selectedTag,
                 selectedCell < validPromotions.count {
                  // FIXED → use validPromotions instead of otherPromotions
                  promotionID = "\(validPromotions[selectedCell].id ?? 0)"
                  print("Correct Promotion ID:", promotionID)
              }
          }
      
        self.activityLoader.startAnimating()
        self.view.isUserInteractionEnabled = false
        

        print("Promid",promotionID)
        print("tokaen",token)
        
        self.viewModel.processingPayment(
            user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""),
            item_id: self.itemID,
            promotion_id: promotionID,
            currency_code: self.selectedCurrency,
            pay_nonce: token,
            payment_type: type,ios_id:token,price:self.selectedPrice,currency_symbol:self.selectedCurrencySymbol,
            onSuccess: { _ in
               
                    self.activityLoader.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    let alert = UIAlertController(
                        title: "Success",
                        message: "Promotion applied!",
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        let pageObj = ViewProfileViewController()
                        pageObj.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                        pageObj.isTabBar = true
                        ADD_EDIT_ITEM_MODEL = AddEditViewModel()
                        self.delegate.navigationController.pushViewController(pageObj, animated: true)
                    }))

                    self.present(alert, animated: true)
               
            },
            onFailure: { _ in
                self.activityLoader.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        )

    }
}

extension PromotionOptionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.view.tag == 1 {
            return 0 // urgent has no list
        }
//        return self.viewModel.getPromotionModel?.result.otherPromotions.count ?? 0
        return validPromotions.count
    }
 


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PromotionHeaderTableViewCell") as! PromotionHeaderTableViewCell
        cell.loadFooterData(viewTag: self.view.tag)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PromotionHeaderTableViewCell") as! PromotionHeaderTableViewCell
        cell.loadHeaderData(viewTag: self.view.tag)

        if self.view.tag == 1 {
            // urgent price
            var urgentPrice = self.viewModel.getPromotionModel?.result.formattedUrgent ?? ""
            if let urgentProduct = products.first(where: { $0.id == "com.app.urgentpromoplan" }) {
                urgentPrice = urgentProduct.displayPrice
            }
            cell.priceLabel.text = urgentPrice
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let promotion = validPromotions[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PromotionOptionTableViewCell"
        ) as! PromotionOptionTableViewCell

        cell.loadData(promotionData: promotion, index: indexPath.row)
        
        if let product = products.first(where: { $0.id == promotion.ios_id }) {
            let amount: Decimal = product.price
                let currencyCode: String = product.priceFormatStyle.currencyCode

                print("Price:", amount)
                print("Currency:", currencyCode)
            cell.priceLabel.text = product.displayPrice
            
        } else {
            cell.priceLabel.text = promotion.formattedPrice
        }

        cell.selectedView.isHidden = (selectedTag != indexPath.row)
        return cell
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTag = indexPath.row
        
        let promotion = validPromotions[indexPath.row]

        if let product = products.first(where: { $0.id == promotion.ios_id }) {

            self.selectedPrice = "\(product.price)"

            let code = product.priceFormatStyle.currencyCode

            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = code   // INR, USD, EUR, etc.

            self.selectedCurrencySymbol = formatter.currencySymbol   // ₹ / $ / €
            
            self.selectedCurrency = code
            print("selectedPrice:", "\(product.price)")

            print("Symbol:", formatter.currencySymbol)
        }

        self.tableView.reloadData()
    }

}



