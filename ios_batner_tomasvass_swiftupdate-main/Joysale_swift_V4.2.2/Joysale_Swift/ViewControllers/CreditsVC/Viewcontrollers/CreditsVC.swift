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
    
    
    
    
    var viewModel = CreditsViewModel()
    private let refreshControl = UIRefreshControl()
    var referral_code_locked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        // Do any additional setup after loading the view.
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
        self.creditdeslbl.numberOfLines = 0
        self.balbtn.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.balbtn.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "")
        self.promotxt.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "promo_placeholder", font: UIFont(name: APP_FONT_REGULAR, size: 15))
        self.balbtn.cornerMiniumRadius(10)
        self.promobtn.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.promobtn.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "")
        self.promobtn.setTitle("345xk", for: .normal)
        self.promobtn.cornerMiniumRadius(10)
        self.copybtn.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.copybtn.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "copy_the_link")
        self.promotxt.addDoneButtonOnKeyboard()
      //  self.copybtn.setTitle("copy_the_link", for: .normal)
        self.copybtn.cornerMiniumRadius(10)
        if referral_code_locked{
            self.changecodeview.isHidden = true
            self.promohint.text = "🔒 \(getLanguage["changecode_alert"] ?? "")"
        }
        loaddata()
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
                    self.balbtn.setTitle("\(self.viewModel.creditModel?.balance ?? "")Kč", for: .normal)
                    self.promocodelbl.text = self.viewModel.creditModel?.referral_code
                    self.refferaltxt.text = self.viewModel.creditModel?.invite_url
                }
                group.leave()
            }) { (failure) in
                group.leave()
            }
        group.notify(queue: DispatchQueue.main) {
            self.refreshControl.endRefreshing()
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
                }
                let alert = UIAlertController(title: nil, message: self.viewModel.promoModel?.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                group.leave()
            }, onFailure: {(failure) in
                group.leave()
                
            })
            group.notify(queue: DispatchQueue.main) {
                self.refreshControl.endRefreshing()
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
                let vc = CreditHistoryVC()
                vc.historymodel = self.viewModel.creditModel?.history ?? [CreditResultModel]()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
