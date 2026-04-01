//
//  BannerViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import WebKit

class BannerViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var bannerImageView: UIImageView!
    var viewModel = BannerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
                let pageObj = BannerListViewController()
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func configUI() {
        self.bannerImageView.isHidden = true
        self.textView.config(color: UIColor(named: "AppTextColor") ?? .black, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.navigationController?.customNavigationBarView(title: "advertise", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "advertise_history", isLeft: false, vc: self, transparantView: false)
        self.continueButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.continueButton.layer.cornerRadius = 8
     
        self.continueButton.clipsToBounds = true
        self.continueButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "continue")
        self.webView.navigationDelegate = self
        self.loadData()
    }
    func loadData() {
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.getAddData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", onSuccess: { (success) in
            self.bannerImageView.sd_setImage(with: URL(string: (self.viewModel.bannerModel?.result.first?.adImage ?? "")), placeholderImage: #imageLiteral(resourceName: "profilelogo")) { (image, error, chache, url) in
                if error == nil {
                    self.bannerImageView.isHidden = false
                }
                else {
                    self.bannerImageView.isHidden = true
                }
            }
            self.webView.loadHTMLString((headerString + (self.viewModel.bannerModel?.result.first?.adDescription ?? "")), baseURL: nil)
            let htmlString = (self.viewModel.bannerModel?.result.first?.adDescription ?? "").replacingOccurrences(of: "\n", with: "<br>")
            self.textView.text = htmlString.html2String
            Utility.shared.stopAnimation(viewController: self)
        }){(failure) in
        }
    }
    @IBAction func continueButtonAct(_ sender: UIButton) {
        let pageObj = AddBannerViewController()
        pageObj.bannerResultModel = self.viewModel.bannerModel?.result.first
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
}
extension BannerViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Utility.shared.stopAnimation(viewController: self)
    }
}
