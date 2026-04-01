//  PremiumAdvc.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//
 

import UIKit
import StoreKit

class PremiumAdvc: UIViewController {
    
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Continue: UIButton!
    @IBOutlet weak var PlanView: UIView!
    @IBOutlet weak var PlanName: UILabel!
    @IBOutlet weak var PlanNameDetailLbl: UILabel!
    @IBOutlet weak var PlanNameDaysLbl: UILabel!
    @IBOutlet weak var PlanNameDaysDetailLbl: UILabel!
    @IBOutlet weak var ExpireLbl: UILabel!
    @IBOutlet weak var ExpireDateLbl: UILabel!
    @IBOutlet weak var DesLbl: UILabel!
    
    @IBOutlet weak var promotion4Label: UILabel!
    @IBOutlet weak var promotion3Label: UILabel!
    @IBOutlet weak var promotion2Label: UILabel!
    @IBOutlet weak var promotion1Label: UILabel!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var selectedIndex: IndexPath?
    var viewModel = PremiumAdViewModel()
    
    var adlistarr: [AdPremium] = []      // API list
    var products: [Product] = []         // StoreKit list
    var matchedProducts: [Product] = []  // Final matched list
    
    var adIds: [String] = []             // API inAppIds
    var onPremiumActivated: (() -> Void)?
    var selectedPrice = ""
    var selectedCurrencySymbol = ""
    var selectedCurrency = ""
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
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    
    // MARK: - Match Products
    func getMatchedProducts() -> [Product] {
        let apiIDs = adlistarr.map { $0.inAppId }
        return products.filter { apiIDs.contains($0.id) }
    }
    

    func updateMatchedList() {
        matchedProducts = getMatchedProducts()
        sortMatchedProductsByPrice()     // <-- sort by App Store price
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func convertTimestampToDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone.current   // or .utc if needed
        return formatter.string(from: date)
    }

    func CheckPlanDeatilsApi(){
        Utility.shared.startAnimation(viewController: self)
        ADMIN_VIEW_MODEL.GetAdStatus(user_id:UserDefaultModule.shared.getUserData()?.user_id ?? "",onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            if success == "true" {
                self.DesLbl.text = ADMIN_VIEW_MODEL.adModel?.ad_desc ?? "Ad Free Ad Plans"
                if ADMIN_VIEW_MODEL.adModel?.adstatus ?? "" == "disable" {
                    self.PlanView.isHidden = false
//                    self.DesLbl.text = ADMIN_VIEW_MODEL.adModel?.ad_desc ?? "Ad Free Ad Plans"
                    self.PlanNameDetailLbl.text = ADMIN_VIEW_MODEL.adModel?.plan_name
                    self.PlanNameDaysDetailLbl.text = "\(ADMIN_VIEW_MODEL.adModel?.plan_days ?? "") Days"
                    if let expiry = ADMIN_VIEW_MODEL.adModel?.expiry_date {
                        let dateString = self.convertTimestampToDate(TimeInterval(expiry) ?? 0.8999)
                        self.ExpireDateLbl.text = dateString
                    } else {
                        self.ExpireDateLbl.text = "-"
                    }

                }else{
                    self.PlanView.isHidden = true
                }
                self.loadData()
            }
        }, onFailure: { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        })
        
    }

    
    @objc func barButtonAction(_ notification: Notification) {
        if let isLeft = notification.userInfo?["isLeft"] as? Int, isLeft == 0 {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: UI
    func configUI() {
        noItemStackView.isHidden = true
//        self.PlanView.isHidden = true
        noItemTitleLabel.config(color: UIColor(named: "AppTextColor"),
                                font: UIFont(name: APP_FONT_REGULAR, size: 15),
                                align: .center,
                                text: "Sorry")
        
        noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"),
                              font: UIFont(name: APP_FONT_REGULAR, size: 14),
                              align: .center,
                              text: "No Plans Available")
        
        navigationController?.customNavigationBarView(title: "AdPremium",
                                                      fColor: "whitecolor",
                                                      fontName: UIFont(name: APP_FONT_REGULAR, size: 20),
                                                      vc: self)
        
        navigationController?.customRightBarButtonView(title: "",
                                                       fColor: "whitecolor",
                                                       fontName: UIFont(name: APP_FONT_REGULAR, size: 14),
                                                       imageName: "detail_back",
                                                       isLeft: true,
                                                       vc: self, transparantView: true)
        PlanName.config(color: UIColor(named: "whitecolorfir"),font: UIFont(name: APP_FONT_REGULAR, size: 20),align: .left,text: "PlanName")
        PlanNameDetailLbl.config(color: UIColor(named: "whitecolorfir"),font: UIFont(name: APP_FONT_REGULAR, size: 20),align: .left,text: "")
        PlanNameDaysLbl.config(color: UIColor(named: "whitecolorfir"),font: UIFont(name: APP_FONT_REGULAR, size: 20),align: .left,text: "PlanDays")
        PlanNameDaysDetailLbl.config(color: UIColor(named: "whitecolorfir"),font: UIFont(name: APP_FONT_REGULAR, size: 20),align: .left,text: "")
        ExpireLbl.config(color: UIColor(named: "whitecolorfir"),font: UIFont(name: APP_FONT_REGULAR, size: 20),align: .left,text: "ExpireDate")
        ExpireDateLbl.config(color: UIColor(named: "whitecolorfir"),font: UIFont(name: APP_FONT_REGULAR, size: 20),align: .left,text: "")
        
        self.promotion1Label.config(color: UIColor(named: "whitecolorfir"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.promotion2Label.config(color: UIColor(named: "whitecolorfir"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.promotion3Label.config(color: UIColor(named: "whitecolorfir"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.promotion4Label.config(color: UIColor(named: "whitecolorfir"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        
        self.promotion1Label.text = getLanguage["add_list1"] ?? ""
        self.promotion2Label.text = getLanguage["add_list2"] ?? ""
        self.promotion3Label.text = getLanguage["add_list3"] ?? ""
        self.promotion4Label.text = getLanguage["add_list4"] ?? ""

        
        
        
        tableView.register(UINib(nibName: "PreAdcellTableViewCell", bundle: nil), forCellReuseIdentifier: "PreAdcellTableViewCell")
        
        Continue.cornerMiniumRadius()
        Continue.backgroundColor = UIColor(named: "AppThemeColorNew")
        Continue.config(color: UIColor(named: "whitecolor"),
                        font: UIFont(name: APP_FONT_REGULAR, size: 15),
                        align: .center,
                        title: "continue")
       
        CheckPlanDeatilsApi()
//        loadData()
    }
    
    func sortMatchedProductsByPrice() {
        matchedProducts.sort { p1, p2 in
            return p1.price < p2.price   // ascending ₹/$
        }
    }

    // MARK: - Load StoreKit Products
    func loadProducts() {
        guard !self.adIds.isEmpty else {
            print("⚠️ No API IDs found.")
            return
        }
        Task {
            do {
                self.products = try await SubManager.shared.loadProducts(ids: self.adIds)
                print("self.productsneed : \(self.products)")
                self.updateMatchedList()
                self.updateEmptyState()
            } catch {
                print("❌ Error loading StoreKit products: \(error)")
            }
        }
    }
    
    // MARK: - Continue Button Action
    
    @IBAction func ContinuebtnTapped(_ sender: Any) {
        guard let selectedIndex = selectedIndex else {
            showAlertmsg(Message: "Please select a plan.")
            return
        }
        
        guard selectedIndex.row < matchedProducts.count else {
            showAlertmsg(Message: "Product not found.")
            return
        }
        
        let selectedProduct = matchedProducts[selectedIndex.row]
        
        // 🔍 Find API plan using inAppId
        guard let selectedPlan = adlistarr.first(where: { $0.inAppId == selectedProduct.id }) else {
            showAlertmsg(Message: "Plan not found for selected product.")
            return
        }
        
        print("🔗 API inAppId:", selectedPlan.inAppId)
        print("🔗 API plan_id:", selectedPlan.id ?? "")
        
        Task {
            do {
                Utility.shared.startAnimation(viewController: self)
                
                let transaction = try await SubManager.shared.purchase(selectedProduct)
                
                let currentTxnID = transaction.id                     // Int64
                let originalTxnID = transaction.originalID            // Int64 (THIS IS WHAT YOU NEED)

                print("Current Txn:", currentTxnID)
                print("Original Txn:", originalTxnID)
                
                DispatchQueue.main.async {
                    Utility.shared.stopAnimation(viewController: self)
                    // ✅ Pass API in-app ID to server
                    self.activatePremium(inappplanID: selectedPlan.inAppId, adplan_id: selectedPlan.id ?? "", purchase_token: "\(originalTxnID)")
                }
                
            }  catch {
                Utility.shared.stopAnimation(viewController: self)
                self.view.isUserInteractionEnabled = true
                if let storeError = error as? StoreKitError {
                    switch storeError {
                    case .userCancelled:
                        print("⚠️ Purchase Cancelled by User")
                        self.showAlert(title: "Cancelled", message: "The payment has been cancelled")
                    default:
                        print("❌ Purchase Failed: \(storeError.localizedDescription)")
                        self.showAlert(title: "Payment Failed",
                                       message: "The payment has been cancelled")
                    }
                } else {
                    print("❌ Unknown Purchase Error: \(error.localizedDescription)")
                    self.showAlert(title: "Payment Failed",
                                   message: "The payment has been cancelled")
                }
            }
        }
    }
    func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Activate Plan
    func activatePremium(inappplanID: String,adplan_id:String,purchase_token:String){
        Utility.shared.startAnimation(viewController: self)
        print("Masasa",adplan_id)
        print("Masasa2",inappplanID)
        
        viewModel.activeaddplan(
            user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "",
            adplan_id: adplan_id,
            inapp_id: inappplanID,
            purchase_token:purchase_token,
            price:self.selectedPrice,
            currency_symbol:self.selectedCurrencySymbol,
            currency_code:self.selectedCurrency,
            onSuccess: { success in
                
                Utility.shared.stopAnimation(viewController: self)
                
                if success {
                    let alert = UIAlertController(
                        title: "Success",
                        message: "Ad Premium activated successfully!",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        // 🔥 POP when user taps OK
                        self.onPremiumActivated?()
                        self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alert, animated: true)
                    
                } else {
                    self.showAlertmsg(Message: "Failed to activate premium!")
                }
                
            }, onFailure: { error in
                Utility.shared.stopAnimation(viewController: self)
                //                self.showAlertmsg(Message: "Failed to activate premium: \(error)")
                self.onPremiumActivated?()
                self.navigationController?.popViewController(animated: true)
            })
        
    }
    
    // MARK: Load API Data
    func loadData() {
        Utility.shared.startAnimation(viewController: self)
        
        viewModel.getAdpremiumdata(
            user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "",
            onSuccess: { success in
                
                Utility.shared.stopAnimation(viewController: self)
                
                if success {
                    self.adlistarr = self.viewModel.premiumAdModel?.adPremiumList ?? []
                    self.adIds = self.adlistarr.compactMap { $0.inAppId }
                    self.loadProducts()
                }
                
            }, onFailure: { _ in
                Utility.shared.stopAnimation(viewController: self)
                self.updateEmptyState()
            })
    }
    

    
    func updateEmptyState() {
        DispatchQueue.main.async {
            if self.matchedProducts.count == 0 {
                self.noItemStackView.isHidden = false
                self.tableView.isHidden = true
                self.Continue.isHidden = true
                self.DesLbl.isHidden = true
            } else {
                self.noItemStackView.isHidden = true
                self.tableView.isHidden = false
                self.Continue.isHidden = false
                self.DesLbl.isHidden = false   // 👈 Always show when count >= 1
            }
        }
    }

    func showAlertmsg(Message:String) {
        let alert = UIAlertController(title: nil, message: Message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
}

// MARK: - TableView Delegate
extension PremiumAdvc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchedProducts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreAdcellTableViewCell",
                                                 for: indexPath) as! PreAdcellTableViewCell
        
        let product = matchedProducts[indexPath.row]
        let plan = adlistarr.first(where: { $0.inAppId == product.id })
        cell.Planname.text = plan?.name ?? product.displayName
        cell.price.text = product.displayPrice
        cell.selectionStyle = .none
        cell.Plandays.text = "\(plan?.days ?? "0") Days"
        cell.CornerView.backgroundColor =
        (selectedIndex == indexPath) ?
        UIColor(named: "AppThemeColorTrans") :
        UIColor(named: "BlackColorad")
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        
        let product = matchedProducts[indexPath.row]
        let plan = adlistarr.first(where: { $0.inAppId == product.id })
        
        self.selectedPrice = "\(product.price)"

        let code = product.priceFormatStyle.currencyCode

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code   // INR, USD, EUR, etc.

        self.selectedCurrencySymbol = formatter.currencySymbol   // ₹ / $ / €
        
        self.selectedCurrency = code
        print("selectedPrice:", "\(product.price)")

        print("Symbol:", formatter.currencySymbol)
        
        tableView.reloadData()
    }
}


