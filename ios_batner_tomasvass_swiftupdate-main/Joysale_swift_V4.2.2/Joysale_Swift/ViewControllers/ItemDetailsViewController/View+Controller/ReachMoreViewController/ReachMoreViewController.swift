//
//  ReachMoreViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 31/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import WebKit

class ReachMoreViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var reachMore = ""
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
        self.webView.navigationDelegate = self
        self.navigationController?.customNavigationBarView(title: getLanguage["reach_more"] ?? "reach_more", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 17), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.loadData()
    }
    func loadData() {
        Utility.shared.startAnimation(viewController: self)
        self.webView.isHidden = false
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        self.webView.loadHTMLString((headerString + (self.reachMore)), baseURL: nil)
    }

}
extension ReachMoreViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Utility.shared.stopAnimation(viewController: self)
    }
}
