//
//  StripeViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 27/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Stripe

protocol PaymentViewControllerDelegate {
    func paymentViewController(_ token: STPToken)
}
class StripeViewController: UIViewController {
    @IBOutlet weak var stripeTextField: STPPaymentCardTextField!
    var delegate: PaymentViewControllerDelegate?
    var isPayment = false
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.stripeTextField.postalCodeEntryEnabled = false
        
//        Stripe.setDefaultPublishableKey(ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? "")
        StripeAPI.defaultPublishableKey = (ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? "")
        self.configUI()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
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
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.customNavigationBarView(title: "card_details", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.setRightBarButtonItem()
    }
    @objc func rightBarAct(_ sender: UIButton) {
        if stripeTextField.isValid {
            self.view.endEditing(true)
            self.isPayment = true
            setRightBarButtonItem()
            STPAPIClient.shared.publishableKey =
                ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? ""
            let card = STPCardParams()
            card.number = self.stripeTextField.cardNumber
            card.expYear = UInt(self.stripeTextField.expirationYear)
            card .expMonth = UInt(self.stripeTextField.expirationMonth)
            card.cvc = self.stripeTextField.cvc
            //converting into token
//            let stpApiClient = STPAPIClient()
            STPAPIClient.shared.createToken(withCard: card) { (token, error) in
                if error == nil {
                    self.activityIndicator.stopAnimating()
                    DispatchQueue.main.async {
                        self.delegate?.paymentViewController(token!)
                    }
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.navigationController.popViewController(animated: true)

                } else {
                    self.isPayment = false
                    self.setRightBarButtonItem()
                    self.activityIndicator.stopAnimating()
                    let alert = UIAlertController(title: getLanguage["failed"] ?? "", message: error?.localizedDescription ?? "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("Failed")
                }
            }
        }
    }
    func setRightBarButtonItem() {
        if !self.isPayment {
            let barButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            barButton.addTarget(self, action: #selector(rightBarAct(_:)), for: .touchUpInside)

            barButton.titleLabel?.font = UIFont(name: APP_FONT_REGULAR, size: 16) ?? UIFont.systemFont(ofSize: 14)
            barButton.contentHorizontalAlignment = .trailing
            if stripeTextField.isValid {
                barButton.setTitleColor(UIColor(named: "whitecolor") ?? .white, for: .normal)
            }
            else {
                barButton.setTitleColor(UIColor(named: "LocationTextcolor") ?? .white, for: .normal)
            }
            barButton.setTitle(getLanguage["pay"] ?? "", for: .normal)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
        }
        else {
            let barButton = UIBarButtonItem(customView: activityIndicator)
            activityIndicator.startAnimating()
            self.navigationItem.setRightBarButton(barButton, animated: true)
        }
    }
}
extension StripeViewController: STPPaymentCardTextFieldDelegate {
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        self.setRightBarButtonItem()
    }
}
