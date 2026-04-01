//
//  WriteReviewViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 10/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Cosmos

class WriteReviewViewController: UIViewController {

    @IBOutlet weak var backButtonItem: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var stackViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var reviewDescLabel: UILabel!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    var viewModel = MyOrderSalesViewModel()
    var orderResultData: MyOrderResultModel?
    var orderVC: MyOrderSalesDetailViewController?
    var resModel = AdminViewModel()
    var item_id = ""
    var buyer_id = ""
    var isFromNotification = false
    var reviewID = ""
    var review_type = ""
//    var revie

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
  }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func configUI() {
        self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
        self.navigationBar.tintColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.navigationBar.barTintColor = UIColor(named: "AppThemeColorNew") ?? .white
        
        self.reviewTitleLabel.config(color: UIColor(named: "appblackcolorNew"), font: UIFont(name: APP_FONT_BOLD, size: 30), align: .center, text: "Write a review")
        self.reviewDescLabel.config(color: UIColor(named: "appblackcolorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 18), align: .center, text: "Review and rating based on the experience")
        self.titleLabel.config(color: UIColor(named: "appblackcolorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "title")
        self.titleTextField.config(color: UIColor(named: "appblackcolorNew"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 15))
        self.reviewLabel.config(color: UIColor(named: "appblackcolorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "review")
        self.reviewTextView.config(color: UIColor(named: "appblackcolorNew") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.submitButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "submit_button")
        self.submitButton.cornerMiniumRadius()
        self.submitButton.backgroundColor = UIColor(named: "AppThemeColorNew")
        if (self.orderResultData?.rating ?? 0) > 0 {
            self.ratingView.rating = Double(self.orderResultData?.rating ?? 0)
            self.titleTextField.text = self.orderResultData?.reviewTitle ?? ""
            self.reviewTextView.text = self.orderResultData?.reviewDes ?? ""
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.titleTextField.addDoneButtonOnKeyboard()
        self.reviewTextView.addDoneButtonOnKeyboard()
        self.backButtonItem.image = #imageLiteral(resourceName: "detail_back").imageFlippedForRightToLeftLayoutDirection()
        self.getReviewDetails()
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.stackViewBottomConst.constant = 20 + keyboardFrame.height
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        print(self.stackViewBottomConst.constant)
        self.viewDidLayoutSubviews()
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        self.stackViewBottomConst.constant = 10
        print(self.stackViewBottomConst.constant)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    func getReviewDetails() {
        if isFromNotification {
            Utility.shared.startAnimation(viewController: self)
            self.resModel.reviewDetails(user_id: (UserDefaultModule().getUserData()?.user_id ?? ""), item_id: item_id, onSuccess:{ (success) in
                Utility.shared.stopAnimation(viewController: self)
                if success  {
                    if let reviewModel = self.resModel.ratingModel?.result {
                        self.ratingView.rating = Double(reviewModel.rating ?? 0)
                        self.titleTextField.text = reviewModel.reviewTitle ?? ""
                        self.reviewTextView.text = reviewModel.reviewDes ?? ""
                        self.reviewID = "\(self.resModel.ratingModel?.result.reviewId ?? 0)"
                    }
                    print(success)
                }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }

    }
    @IBAction func backButtonAct(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func submitButtonAct(_ sender: UIButton) {
        if self.reviewTextView.text != "" && self.titleTextField.text != "" && self.ratingView.rating != 0 {
            Utility.shared.startAnimation(viewController: self)
            if isFromNotification {
                self.viewModel.updateReview(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), seller_id: "\(self.buyer_id)", review_id: self.reviewID, rating: "\(Int(self.ratingView.rating))", review_title: self.titleTextField.text!, review_des: self.reviewTextView.text!, order_id: item_id, review_type: self.review_type, onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    if success {
                        self.orderResultData?.reviewTitle = self.titleTextField.text!
                        self.orderResultData?.reviewDes = self.reviewTextView.text!
                        self.orderResultData?.rating = (Int(self.ratingView.rating))
                        self.orderVC?.orderResultData = self.orderResultData
                        DispatchQueue.main.async {
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                            if viewControllers.count >= 3 {
                                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                            }
                            else{
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }
            else {
                self.viewModel.updateReview(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), seller_id: "\(self.orderResultData?.orderitems.buyerId ?? 0)", review_id: "\(self.orderResultData?.reviewId ?? 0)", rating: "\(Int(self.ratingView.rating) )", review_title: self.titleTextField.text!, review_des: self.reviewTextView.text!, order_id: "\(self.orderResultData?.orderid ?? 0)",review_type: self.review_type, onSuccess: { (success) in
                    Utility.shared.stopAnimation(viewController: self)
                    if success {
                        self.orderResultData?.reviewTitle = self.titleTextField.text!
                        self.orderResultData?.reviewDes = self.reviewTextView.text!
                        self.orderResultData?.rating = (Int(self.ratingView.rating))
                        self.orderVC?.orderResultData = self.orderResultData
                        DispatchQueue.main.async {
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                            if viewControllers.count >= 3 {
                                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                            }
                            else{
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }

        }
        else {
            var message = ""
            if self.ratingView.rating == 0 {
                message = "rate_us"
            }
            else if self.titleTextField.text == "" {
                message = "review_title"
            }
            else {
                message = "review_desc"
            }
            let alert = UIAlertController(title: "", message: (getLanguage[message] ?? ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: (getLanguage["ok"] ?? ""), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
extension WriteReviewViewController: UITextViewDelegate, UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.containsEmoji {
            return false
        }
        let strLength = textView.text?.count ?? 0
        let lngthToAdd = text.count
        let lengthCount = strLength + lngthToAdd
        if lengthCount > 500 {
            let alert = UIAlertController(title: nil, message: getLanguage["Maximum 500 Character only allowed"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        let strLength = textField.text?.count ?? 0
        let lngthToAdd = string.count
        let lengthCount = strLength + lngthToAdd
        if lengthCount > 60 {
            let alert = UIAlertController(title: nil, message: getLanguage["Maximum 60 Character only allowed"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
}

