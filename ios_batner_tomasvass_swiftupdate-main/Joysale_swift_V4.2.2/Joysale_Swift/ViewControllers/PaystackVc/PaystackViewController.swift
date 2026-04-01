//
//  PaystackViewController.swift
//  ZiingoPrime
//
//  Created by External Display Mac on 14/04/25.
//

import UIKit
import WebKit
protocol PayStackPaymentDelegate{
   func backaction(isfrom:String)
    func successaction(isfrom:String)
}
class PaystackViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backbtn: UIButton!
    
    var flag = true
    var url = ""
    var return_url = ""
    var bookingID = ""
    var isform = ""
    var PayStackPaymentDelegate :PayStackPaymentDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configWebView()
        self.navigationController?.customNavigationBarView(title: "manage_stripe", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        self.navigationController?.isNavigationBarHidden = false
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

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
        }
    }
    
    func configWebView() {
        self.navigationController?.isNavigationBarHidden = true
        self.webView.backgroundColor = .white
        self.webView.scrollView.backgroundColor = .white
        self.webView.uiDelegate = self
//        self.webView.addSubview(indicatorView)
        self.showLoader()
        self.webView.navigationDelegate = self
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async {
            guard let url = URL(string: self.url) else { return }
            self.webView.load(URLRequest(url: url))
        }
    }
    
    @IBAction func backAct(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        self.PayStackPaymentDelegate?.backaction(isfrom: self.isform)
    //    self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("ERROR LOADING \(error.localizedDescription)")
        self.hideLoader()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoader()
        let url = webView.url?.absoluteString ?? ""
        let codeval = url.components(separatedBy: "code=").last ?? ""
        print("suurccesDidfinis::\(url) and conval::\(return_url)")
        if url == return_url {
            self.navigationController?.popViewController(animated: true)
            self.PayStackPaymentDelegate?.successaction(isfrom: self.isform)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let url = webView.url?.absoluteString ?? ""
        let codeval = url.components(separatedBy: "code=").last ?? ""
        self.flag = false
    }

}
