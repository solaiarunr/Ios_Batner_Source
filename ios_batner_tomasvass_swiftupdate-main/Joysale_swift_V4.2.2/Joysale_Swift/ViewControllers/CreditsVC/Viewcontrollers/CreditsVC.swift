//
//  CreditsVC.swift
//  Joysale_Swift
//
//  Created by HTS-4533 on 26/06/26.
//  Copyright © 2026 Hitasoft. All rights reserved.
//

import UIKit

class CreditsVC: UIViewController {
    
    @IBOutlet weak var topview: UIView!
    @IBOutlet weak var yourcreditlbl: UILabel!
    @IBOutlet weak var balbtn: UIButton!
    @IBOutlet weak var creditdeslbl: UILabel!
    @IBOutlet weak var howcreditworkLbl: UILabel!
    @IBOutlet weak var credit1point: UILabel!
    @IBOutlet weak var credit2point: UILabel!
    @IBOutlet weak var credit3point: UILabel!
    @IBOutlet weak var credit4point: UILabel!
    @IBOutlet weak var yourpromoLbl: UILabel!
    @IBOutlet weak var promodeslbl: UILabel!
    @IBOutlet weak var promocodelbl: UILabel!
    @IBOutlet weak var promohint: UILabel!
    @IBOutlet weak var promotxt: UITextField!
    @IBOutlet weak var promobtn: UIButton!
    @IBOutlet weak var referalLbl: UILabel!
    @IBOutlet weak var referaldes: UILabel!
    @IBOutlet weak var refferaltxt: UITextField!
    @IBOutlet weak var copybtn: UIButton!
    @IBOutlet weak var changecodeview: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    
    
    
    var viewModel = CreditsViewModel()
    private let refreshControl = UIRefreshControl()
    var referral_code_locked = false

    private var multilineLabels: [UILabel] {
        [yourcreditlbl, creditdeslbl, howcreditworkLbl,
         credit1point, credit2point, credit3point, credit4point,
         yourpromoLbl, promodeslbl, promohint,
         referalLbl, referaldes]
    }

    private enum Layout {
        static let contentHorizontalInset: CGFloat = 20
        static let bulletExtraInset: CGFloat = 20
        static let topCardHorizontalInset: CGFloat = 90
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }

    func config(){
        self.navigationController?.customNavigationBarView(title: "credit", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "advertise_history", isLeft: false, vc: self, transparantView: false)
        self.credit1point.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "credit1point")
        self.credit2point.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "credit2point")
        self.credit3point.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "credit3point")
        self.credit4point.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "credit4point")
        self.promodeslbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "your_promo_des")
        self.promocodelbl.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 20), align: .center, text: "")
        
        self.yourcreditlbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 14), align: .center, text: "your_credit")
        self.creditdeslbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .center, text: "credit_des")
        self.promohint.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "promo_hint")
        self.referaldes.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "invite_friend_des")
        self.howcreditworkLbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 18), align: .center, text: "how_credit_works")
        self.yourpromoLbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 18), align: .left, text: "your_promocode")
        self.referalLbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 18), align: .left, text: "invite_friend_credit")
        
        configureMultilineLabels()
        applyLabelWidths()
        self.balbtn.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.balbtn.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "")
        self.promotxt.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "promo_placeholder", font: UIFont(name: APP_FONT_REGULAR, size: 15))
        self.balbtn.cornerMiniumRadius(10)
        self.promobtn.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.promobtn.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "")
        self.promobtn.setTitle(getLanguage["change"], for: .normal)
        self.promobtn.cornerMiniumRadius(10)
        self.copybtn.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.copybtn.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "copy_the_link")
        self.copybtn.titleLabel?.numberOfLines = 0
        self.copybtn.titleLabel?.lineBreakMode = .byWordWrapping
        self.promobtn.titleLabel?.numberOfLines = 0
        self.promobtn.titleLabel?.lineBreakMode = .byWordWrapping
        self.promotxt.addDoneButtonOnKeyboard()
        self.copybtn.cornerMiniumRadius(10)
        self.refferaltxt.adjustsFontSizeToFitWidth = true
        self.refferaltxt.minimumFontSize = 10
        if referral_code_locked{
            self.changecodeview.isHidden = true
            self.promohint.text = "🔒 \(getLanguage["changecode_alert"] ?? "")"
        }
        loaddata()
    }

    private func configureMultilineLabels() {
        multilineLabels.forEach { label in
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
    }

    private func currentScreenWidth() -> CGFloat {
        if view.bounds.width > 0 {
            return view.bounds.width
        }
        if let windowWidth = view.window?.bounds.width, windowWidth > 0 {
            return windowWidth
        }
        return UIScreen.main.bounds.width
    }

    private func targetWidth(for label: UILabel, screenWidth: CGFloat) -> CGFloat {
        if label === credit1point || label === credit2point || label === credit3point || label === credit4point {
            return floor(screenWidth - Layout.contentHorizontalInset - Layout.bulletExtraInset)
        }
        if label === yourcreditlbl || label === creditdeslbl {
            return floor(screenWidth - Layout.topCardHorizontalInset)
        }
        return floor(screenWidth - Layout.contentHorizontalInset)
    }

    private func applyLabelWidths(forceLayout: Bool = false) {
        let screenWidth = currentScreenWidth()
        guard screenWidth > 0 else { return }

        multilineLabels.forEach { label in
            let width = targetWidth(for: label, screenWidth: screenWidth)
            guard width > 0 else { return }

            if let wrappingLabel = label as? WrappingLabel {
                wrappingLabel.setExplicitLayoutWidth(width)
            } else {
                label.preferredMaxLayoutWidth = width
                label.invalidateIntrinsicContentSize()
            }
        }

        contentView?.setNeedsLayout()
        scrollView?.setNeedsLayout()
        if forceLayout {
            contentView?.layoutIfNeeded()
            scrollView?.layoutIfNeeded()
        }
    }

    private func refreshMultilineLayout() {
        applyLabelWidths(forceLayout: true)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    override func viewWillLayoutSubviews() {
        applyLabelWidths()
        super.viewWillLayoutSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshMultilineLayout()
    }
    
    func loaddata(){
        let group = DispatchGroup()
        self.refreshControl.beginRefreshing()
            group.enter()
            self.viewModel.getcreditData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", onSuccess: { (success) in
                if !success {
                 print("sucesscredit")
                }
                else {
                    let balance = (self.viewModel.creditModel?.balance ?? "").czechFormattedCreditBalance
                    self.balbtn.setTitle("\(balance)Kč", for: .normal)
                    self.promocodelbl.text = self.viewModel.creditModel?.referral_code
                    self.refferaltxt.text = self.viewModel.creditModel?.invite_url
                }
                group.leave()
            }) { (failure) in
                group.leave()
            }
        group.notify(queue: DispatchQueue.main) {
            self.refreshControl.endRefreshing()
            self.refreshMultilineLayout()
        }
        
    }
    
    @IBAction func applycodebtnTapped(_ sender: Any) {
        if self.promotxt.text == ""{
            let alert = UIAlertController(title: nil, message: getLanguage["enter_code"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let group = DispatchGroup()
            self.refreshControl.beginRefreshing()
            group.enter()
            self.viewModel.ChangecodeApi(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", code: self.promotxt.text ?? "", onSuccess: { (success) in
                if !success {
                    print("sucesscredit")

                   
                }
                else {
                    self.changecodeview.isHidden = true
                    self.promohint.text = "🔒 \(getLanguage["changecode_alert"] ?? "")"
                    self.refreshMultilineLayout()
                }
                let alert = UIAlertController(title: nil, message: self.viewModel.ChangecodeModel?.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                group.leave()
            }, onFailure: {(failure) in
                group.leave()
                
            })
            group.notify(queue: DispatchQueue.main) {
                self.refreshControl.endRefreshing()
                self.refreshMultilineLayout()
            }
        }
    }
    
    @IBAction func copybtn(_ sender: Any) {
        UIPasteboard.general.string = refferaltxt.text

            copybtn.setTitle(getLanguage["copied"] ?? "", for: .normal)
        copybtn.isEnabled = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.copybtn.setTitle(getLanguage["copy_the_link"] ?? "", for: .normal)
                self.copybtn.isEnabled = true
            }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        refreshMultilineLayout()
    }
    override func viewWillDisappear(_ animated: Bool) {

        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
                let vc = CreditHistoryVC()
                vc.historymodel = self.viewModel.creditModel?.history ?? [CreditResultModel]()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}
