//
//  ExchangeOfferViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 23/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit


class ExchangeOfferViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var stackViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    var itemDetails: ItemModel?
    var viewModel = ItemDetailsViewModel()
    var itemDetailsvideo:StoryListModel?
    var isfromtype = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    func configUI() {
        self.userImageView.cornerViewRadius()
        self.userNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
//        self.priceTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "type_your_offer", font: UIFont(name: APP_FONT_REGULAR, size: 15))
        self.priceTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "type_your_offer", font: UIFont(name: APP_FONT_REGULAR, size: 15), placeHolder_color: "Placeholdercolor")
        self.descTextView.config(color: UIColor(named: "Placeholdercolor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "type_your_message")
        self.sendButton.cornerViewMiniumRadius()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let userImg = (isfromtype == "story") ? (self.itemDetailsvideo?.sellerImg ?? "") : (self.itemDetails?.sellerImg ?? "")
        let username = (isfromtype == "story") ? (self.itemDetailsvideo?.sellerName ?? "") : (self.itemDetails?.sellerName ?? "")
        
        self.userImageView.sd_setImage(with: URL(string: (userImg)), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.userImageView.setViewBorder(color: (UIColor(named: "whitecolor") ?? .white))
                                       
        self.userNameLabel.text = username
        self.descTextView.textContainerInset = UIEdgeInsets.zero
        self.descTextView.textContainer.lineFragmentPadding = 0
        self.view.isUserInteractionEnabled = true
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissViewAct)))
    }
    @objc func dismissViewAct() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func endViewButtonAct(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var newHeight = keyboardFrame.height
        if #available(iOS 11.0, *) {
            newHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        } else {
            newHeight = keyboardFrame.height
        }
        self.stackViewBottomConst.constant = newHeight
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        print(self.stackViewBottomConst.constant)
        self.viewDidLayoutSubviews()
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        self.stackViewBottomConst.constant = 0
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func sendButtonAct(_ sender: UIButton) {
        let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: "Should not be Empty, Please Enter some text", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
        self.descTextView.endEditing(true)
        let Prices = (isfromtype == "story") ? (self.itemDetailsvideo?.price ?? "") : (self.itemDetails?.price ?? "")
        if priceTextField.text == "" {
            alert.message = getLanguage["price should not be empty"] ?? ""
            self.present(alert, animated: true, completion: nil)
        }
        else if (Float(self.priceTextField.text!) ?? 0) == 0 {
            alert.message = getLanguage["entervalidprice"] ?? ""
            self.present(alert, animated: true, completion: nil)
        }
       
        else if (Float(self.priceTextField.text!) ?? 0) > (Float(Prices) ?? 0) {
            alert.message = getLanguage["Offer price should less than product price"] ?? ""
            self.present(alert, animated: true, completion: nil)
        }
        else if (Float(self.priceTextField.text!) ?? 0) == (Float(Prices) ?? 0){
            alert.message = getLanguage["offer price should not same"] ?? ""
            self.present(alert, animated: true, completion: nil)
        }
        else if self.descTextView.tag == 0 || self.descTextView.text == "" {
            alert.message = getLanguage["Should not be Empty, Please Enter some text"] ?? ""
            self.present(alert, animated: true, completion: nil)
        }
            
        else {
            self.getChatIdValue()
        }
    }
    func getChatIdValue() {
        self.view.endEditing(true)
        self.activityIndicatorView.startAnimating()
        self.sendButton.tintColor = UIColor(named: "lightWhite")
        self.view.isUserInteractionEnabled = false
        let sellerId = (isfromtype == "story") ? (self.itemDetailsvideo?.sellerId ?? "0") : (self.itemDetails?.sellerId ?? "0")
        self.viewModel.getChatIdAct(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: sellerId, onSuccess: { (success) in
            if success {
                self.sendChatAfterID(self.viewModel.itemChatModel?.chatId ?? "")
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.activityIndicatorView.stopAnimating()
                self.sendButton.tintColor = UIColor(named: "whitecolor")
            }
        }) { (failure) in
            self.view.isUserInteractionEnabled = true
            self.activityIndicatorView.stopAnimating()
            self.sendButton.tintColor = UIColor(named: "whitecolor")
        }
    }
    func sendChatAfterID(_ chatID: String) {
            let source_id = (isfromtype == "story") ? (self.itemDetailsvideo?.id ?? 0) : (self.itemDetails?.id ?? 0)
        self.viewModel.sendofferRequest(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), source_id: "\(source_id ?? 0)", chat_id: chatID, message: self.descTextView.text!, offer_price: self.priceTextField.text!, onSuccess: { (success) in
            let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage["message_send_successfully"], preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.sendButton.tintColor = UIColor(named: "whitecolor")
            self.view.isUserInteractionEnabled = true
            self.activityIndicatorView.stopAnimating()
            self.present(alert, animated: true, completion: nil )
        }) { (failure) in
            self.view.isUserInteractionEnabled = false
            self.activityIndicatorView.stopAnimating()
            self.sendButton.tintColor = UIColor(named: "whitecolor")
        }
    }
}
extension ExchangeOfferViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        let amountString: NSString = textField.text! as NSString
        let newString: NSString = amountString.replacingCharacters(in: range, with: string) as NSString
        let regex = "\\d{0,\(ADMIN_VIEW_MODEL.adminModel?.result.priceRange.beforeDecimalNotation ?? "5")}(\\.\\d{0,\(ADMIN_VIEW_MODEL.adminModel?.result.priceRange.afterDecimalNotation ?? "2")})?"

        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let allowedCharacters = CharacterSet(charactersIn:".0123456789")//Here change this characters based on your requirement
        let characterSet = CharacterSet(charactersIn: string)

        return predicate.evaluate(with:newString) && allowedCharacters.isSuperset(of: characterSet)
    }
}
extension ExchangeOfferViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.textViewAct(textView)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.tag = 0
        }
        self.textViewAct(textView)
    }
    func textViewAct(_ textView: UITextView) {
        if textView.tag == 0 {
            textView.text = ""
            textView.textColor = UIColor(named: "AppTextColor") ?? .white
            textView.tag = 1
        }
        else {
            if textView.text == "" && textView.tag == 1{
                textView.text = getLanguage["type_your_message"] ?? ""
                textView.tag = 0
                textView.textColor = UIColor(named: "Placeholdercolor") ?? .white
            }
            else {
                textView.textColor = UIColor(named: "AppTextColor")
            }
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.containsEmoji {
            return false
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if text == "\n" {
            textView.endEditing(true)
            return false
        }
         else if numberOfChars > 500 {
            textView.endEditing(true)
            let alert = UIAlertController(title: getLanguage[""] ?? "", message: getLanguage["Maximum 500 Character only allowed"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: { (UIAlertAction) in
            }))
            self.present(alert, animated: true, completion: nil)
        }
        return numberOfChars <= 500
    }
}
