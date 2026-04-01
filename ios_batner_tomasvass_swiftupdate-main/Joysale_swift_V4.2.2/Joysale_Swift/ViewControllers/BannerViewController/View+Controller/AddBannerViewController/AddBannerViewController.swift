//
//  AddBannerViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.

import UIKit
import Stripe
import BraintreeDropIn
import Braintree
import Photos

class AddBannerViewController: UIViewController,PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    @IBOutlet weak var priceTypeLabel: UILabel!
    @IBOutlet weak var appCloseButton: UIButton!
    @IBOutlet weak var webCloseButton: UIButton!
    @IBOutlet weak var appImageButton: UIButton!
    @IBOutlet weak var webImageButton: UIButton!
    @IBOutlet weak var stackViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var appSizeLabel: UILabel!
    @IBOutlet weak var webSizeLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var appImageView: UIImageView!
    @IBOutlet weak var webImageView: UIImageView!
    @IBOutlet weak var webView: UIView!
    @IBOutlet weak var appView: UIView!
    
    @IBOutlet weak var bannerLinkTitleLabel: UILabel!
    @IBOutlet weak var webLinkTextField: UITextField!
    @IBOutlet weak var appLinkTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    var bannerResultModel: BannerResultModel?
    let dateformatter = DateFormatter() // 2-2
    var imagePicker: ImagePicker!
    var isWebImage = ""
    var webImageURL = ""
    var appImageURL = ""
    var viewModel = BannerViewModel()
    let timeZone = TimeZone(identifier: "UTC")
    var calendar = Calendar.current
    var stripeModel = StripeDataModel()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var totalAmountPay = ""
    private var videoFetchResult: PHFetchResult<PHAsset>?
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
        self.imagePicker = ImagePicker(presentationController: self , delegate: self)
        self.navigationController?.customNavigationBarView(title: "ad_banner", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.webView.cornerViewMiniumRadius()
        self.appView.cornerViewMiniumRadius()
        self.webSizeLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "Web banner (size 1920px 400px)")
        self.appSizeLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "App banner (size 1024px 500px)")
        self.bannerLinkTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "banner_link")
        self.bannerLinkTitleLabel.text = self.bannerLinkTitleLabel.text?.uppercased()
        self.whenLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "when_banner_display")
        self.whenLabel.text = self.whenLabel.text?.uppercased()
        self.priceLabel.config(color: UIColor(named: "redcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .right, text: "")
        self.priceTypeLabel.config(color: UIColor(named: "redcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .right, text: "")
        self.webLinkTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "web_link", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.appLinkTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "app_link", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.startTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "start_date", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.endTextField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "end_date", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.descLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "")
        self.priceLabel.text = "\(self.bannerResultModel?.formattedPricePerDay ?? "") "
        self.priceTypeLabel.text = (getLanguage["per_day"] ?? "")
        
//        self.descLabel.text = "\(getLanguage["ads_run"] ?? "") 0 \(getLanguage["days"]?.lowercased() ?? ""). \(getLanguage["spend"] ?? "")"
        let string = NSMutableAttributedString(string: "\(getLanguage["ads_run"] ?? "") 0 \(getLanguage["days"]?.lowercased() ?? ""). \(getLanguage["spend"] ?? "")")
        string.setColorWithFont("0 \(getLanguage["days"]?.lowercased() ?? "")", with: UIColor(named: "BlackColor") ?? .white, font: UIFont(name: APP_FONT_BOLD, size: 14) ?? UIFont.boldSystemFont(ofSize: 14))
        self.descLabel.attributedText = string
        
        self.totalPriceLabel.config(color: UIColor(named: "BlackColor"), font: UIFont(name: APP_FONT_BOLD, size: 14), align: .center, text: "")
        self.startTextField.setDatePicker(target: self, selector: #selector(datePickerAct), minimumDate: Date(), dateFormat: "yyyy-MM-dd")
        self.endTextField.setDatePicker(target: self, selector: #selector(endPickerAct), minimumDate: Date(), dateFormat: "yyyy-MM-dd")
        let currency = (self.bannerResultModel?.currencyMode ?? "") == "symbol" ? (self.bannerResultModel?.currencySymbol ?? "") : (self.bannerResultModel?.currencyCode ?? "")
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.totalPriceLabel.text = (self.bannerResultModel?.currencyPosition) == "postfix" ? "\(currency) 0" : "0 \(currency)"
            self.totalPriceLabel.text = "0"
        }
        else {
            self.totalPriceLabel.text = (self.bannerResultModel?.currencyPosition) == "postfix" ? "0 \(currency)" : "\(currency) 0"
        }
        
        self.continueButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.continueButton.cornerMiniumRadius()
        self.continueButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "pay")
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.appCloseButton.isHidden = true
        self.webCloseButton.isHidden = true
        self.webLinkTextField.addDoneButtonOnKeyboard()
        self.appLinkTextField.addDoneButtonOnKeyboard()
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
    @objc func endPickerAct() {
        if let datePicker = self.endTextField.inputView as? UIDatePicker {
            dateformatter.dateFormat = "yyyy-MM-dd"
            self.endTextField.text = dateformatter.string(from: datePicker.date)
        }
        self.updatePrice()
    }
    @objc func datePickerAct() {
        if let datePicker = self.startTextField.inputView as? UIDatePicker {
            dateformatter.dateFormat = "yyyy-MM-dd"
             
            self.startTextField.text = dateformatter.string(from: datePicker.date)
            self.endTextField.text = ""
            self.endTextField.setDatePicker(target: self, selector: #selector(endPickerAct), minimumDate: datePicker.date, dateFormat:  "yyyy-MM-dd")

        }
        self.updatePrice()
    }
    func updatePrice() {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.view.endEditing(true)
        var numberOfDays = 0
        formatter.dateFormat = "yyyy-MM-dd"
        if let startDate = formatter.date(from: self.startTextField.text!), let endDate = formatter.date(from: self.endTextField.text!) {
            print("Start\(startDate)")
            print("End\(endDate)")
            numberOfDays = (calendar.dateComponents([.day], from: startDate, to: endDate).day! + 1)
            print("differ\(numberOfDays)")
            let pricePerDay = Double(self.bannerResultModel?.pricePerDay ?? "0") ?? 0
//            self.descLabel.text = "\(getLanguage["ads_run"] ?? "") \(numberOfDays) \(getLanguage["days"]?.lowercased() ?? ""). \(getLanguage["spend"] ?? "")"
            let string = NSMutableAttributedString(string: "\(getLanguage["ads_run"] ?? "") \(numberOfDays) \(getLanguage["days"]?.lowercased() ?? ""). \(getLanguage["spend"] ?? "")")
            string.setColorWithFont("\(numberOfDays) \(getLanguage["days"]?.lowercased() ?? "")", with: UIColor(named: "BlackColor") ?? .white, font: UIFont(name: APP_FONT_BOLD, size: 14) ?? UIFont.boldSystemFont(ofSize: 14))
            self.descLabel.attributedText = string

            let totalPrice = (pricePerDay * Double(numberOfDays))
            self.totalAmountPay = "\(String(format: "%.2f", totalPrice))"
            let currency = (self.bannerResultModel?.currencyMode ?? "") == "symbol" ? (self.bannerResultModel?.currencySymbol ?? "") : (self.bannerResultModel?.currencyCode ?? "")
            if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                self.totalPriceLabel.text = (self.bannerResultModel?.currencyPosition) == "postfix" ? "\(currency) \(String(format: "%.2f", totalPrice))" : "\(String(format: "%.2f", totalPrice)) \(currency)"
            }
            else {
                self.totalPriceLabel.text = (self.bannerResultModel?.currencyPosition) == "postfix" ? "\(String(format: "%.2f", totalPrice)) \(currency)" : "\(currency) \(String(format: "%.2f", totalPrice))"
            }
        }
        else {
            self.descLabel.text = "\(getLanguage["ads_run"] ?? "") \(0) \(getLanguage["days"]?.lowercased() ?? ""). \(getLanguage["spend"] ?? "")"
            self.totalPriceLabel.text = "\(String(format: "%.2f", 0)) \(self.bannerResultModel?.currencySymbol ?? "")"

        }
    }
    
    @IBAction func calenderButtonAct(_ sender: UIButton) {
        if sender.tag == 0 {
            self.startTextField.becomeFirstResponder()
        }
        else {
            self.endTextField.becomeFirstResponder()
        }
    }
    @IBAction func addButtonAct(_ sender: UIButton) {
        self.isWebImage = sender == webImageButton ? "web" : "app"
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.videoFetchResult = PHAsset.fetchAssets(with: .video, options: options)
        PHPhotoLibrary.shared().register(self)
        self.imagePicker.present(from: sender)
    }
    @IBAction func closeButtonAct(_ sender: UIButton) {
        if sender == webCloseButton {
            self.webImageView.image = nil
            self.webImageButton.setImage(#imageLiteral(resourceName: "plus_sign"), for: .normal)
            self.webImageURL = ""
        }
        else {
            self.appImageView.image = nil
            self.appImageButton.setImage(#imageLiteral(resourceName: "plus_sign"), for: .normal)
            self.appImageURL = ""
        }
        sender.isHidden = true
    }
    func updateUTCDateFormat(_ dateString: String) -> String {
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date = dateformatter.date(from: dateString) ?? Date()
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter1.timeZone =  timeZone
        return (dateFormatter1.string(from: date) )
    }
    @IBAction func continueButtonAct(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: nil))
        var isValid = false
        if self.webImageURL == "" {
            alert.message = getLanguage["upload_web"]
        }
        else if self.appImageURL == "" {
            alert.message = getLanguage["upload_app"]
        }
        else if !(self.webLinkTextField.text?.isValidURL ?? false) {
            alert.message = getLanguage["enter_valid_weblink"]
        }
        else if !(self.appLinkTextField.text?.isValidURL ?? false) {
            alert.message = getLanguage["enter_valid_applink"]
        }
        else if self.startTextField.text == "" {
            alert.message = getLanguage["choose_start_date"]
        }
        else if self.endTextField.text == "" {
            alert.message = getLanguage["choose_end_date"]
        }
        else {
            isValid = true
        }
        if isValid {
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.checkBannerAvailability(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", start_date: self.updateUTCDateFormat(self.startTextField.text!), end_date: self.updateUTCDateFormat(self.endTextField.text!), onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                if success {
                    if ADMIN_VIEW_MODEL.adminModel?.result.adminPaymentType == "braintree" {
                        self.presentDropInController()
                    }
                    else {
                        self.presentStripe()
//                        let pageObj = StripeViewController()
//                        pageObj.delegate = self
//                        self.navigationController?.pushViewController(pageObj, animated: true)
                    }
                }
                else {
                    let alert = UIAlertController(title: nil, message: (self.viewModel.addBannerModel?.message ?? ""), preferredStyle: .alert)
                    alert.message = "\((getLanguage[(self.viewModel.addBannerModel?.message ?? "")] ?? alert.message) ?? "") \(self.viewModel.addBannerModel?.noDates.joined(separator: ",") ?? "")"
                    alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
        else {
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func presentDropInController() {
       // BTUIKAppearance.sharedInstance()?.colorScheme = BTUIKColorScheme(rawValue: 0)!

        let dropInRequest = BTDropInRequest()


        let dropInController = BTDropInController(authorization: BRAINTREE_TOKEN, request: dropInRequest) { (dropInController, result, error) in
            guard let result = result, error == nil else {
                print("Error: \(error!)")
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
        //present(dropIn, animated: true, completion: nil)
    }
}
extension AddBannerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        return true
    }
}
extension AddBannerViewController: PaymentViewControllerDelegate {
    func paymentViewController(_ token: STPToken) {
        self.payAct(type: "stripe", token: "\(token)")
    }
    @objc func presentStripe() {
        var paymentSheet: PaymentSheet?
        let viewModel = StripeDataViewModel()
        viewModel.getStripeDetails(amount: "\(self.totalAmountPay)", currency: (self.bannerResultModel?.currencyCode ?? "")) { (success) in
            if viewModel.stripeModel?.status ?? false {
                guard let viewData = viewModel.stripeModel else {
                    return
                }
                self.stripeModel = viewData
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = APP_NAME
                configuration.customer = .init(id: self.stripeModel.customer, ephemeralKeySecret: self.stripeModel.ephemeralKey)
                paymentSheet = PaymentSheet(paymentIntentClientSecret: self.stripeModel.paymentIntent, configuration: configuration)
                DispatchQueue.main.async {
                    paymentSheet?.present(from: self) { paymentResult in
                      // MARK: Handle the payment result
                      switch paymentResult {
                      case .completed:
                        print("Your order is confirmed")
                        let token = self.stripeModel.paymentIntent.components(separatedBy: "_secret_")
                        self.payAct(type: "stripe", token: token.first ?? "")
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
                self.present(alert, animated: true, completion: nil)
            }
        } onFailure: { (failure) in
            let alert = UIAlertController(title: nil, message: getLanguage["amount_too_small"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
    func payAct(type: String, token: String) {
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.AddBanner(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), currency_code: (self.bannerResultModel?.currencyCode ?? ""), nonce: "\(token)", price: (self.bannerResultModel?.pricePerDay ?? ""), app_banner_url: self.appImageURL, web_banner_url: self.webImageURL, app_banner_link: self.appLinkTextField.text!, web_banner_link: self.webLinkTextField.text!, start_date: self.updateUTCDateFormat(self.startTextField.text!), end_date: self.updateUTCDateFormat(self.endTextField.text!), payment_type: type, onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: (self.viewModel.tosModel?.message ?? ""), preferredStyle: .alert)
            if success {
                alert.message = getLanguage["banner_added_successfully"] ?? "banner_added_successfully"
            }
            alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: { (UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
}
extension AddBannerViewController: ImageDelegate {

    func didSelect(image: UIImage?) {
        self.navigationController?.isNavigationBarHidden = false
        if let selectedImage = image {
            var isValid = false
            var message = "Invalid Image"
            let height = (selectedImage.size.height * selectedImage.scale)
            let width = (selectedImage.size.width * selectedImage.scale)
            if self.isWebImage == "web" {
                if (height == 400 && width == 1920) {
                    isValid = true
                    self.webCloseButton.isHidden = false
                    self.webImageView.image = selectedImage
                    self.webImageButton.setImage(nil, for: .normal)
                }
                else {
                    message = "\(getLanguage["image_size_alert"] ?? "") 1920px X 400px"
                }
            }
            else {
                if (height == 500 && width == 1024) {
                    self.appCloseButton.isHidden = false
                    isValid = true
                    self.appImageView.image = selectedImage
                    self.appImageButton.setImage(nil, for: .normal)
                }
                else {
                    message = "\(getLanguage["image_size_alert"] ?? "") 1024px X 500px"
                }
            }
            if isValid {
                CallParsingFunction().uploadImage(url: UPLOAD_IMAGE_URL, type: self.isWebImage, image: image, onSuccess: { (success) in
//                    Utility.shared.stopAnimation(viewController: self)
                    self.navigationController?.isNavigationBarHidden = false
                    print(success["banner","web_banner_url"].stringValue)
                    if success["status"].boolValue {
                        if success["banner","web_banner_url"].stringValue != "" {
                            self.webImageURL = success["banner","web_banner_url"].stringValue
                        }
                        else {
                            self.appImageURL = success["banner","app_banner_url"].stringValue
                        }
                    }
                }) { (failure) in
                }
            }
            else {
                let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func convertToJSON(_ images: [String]) -> (String) {
        let data = try! JSONSerialization.data(withJSONObject: images, options:.prettyPrinted)
        let jsonStr  = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return (jsonStr ?? "")
    }
}
