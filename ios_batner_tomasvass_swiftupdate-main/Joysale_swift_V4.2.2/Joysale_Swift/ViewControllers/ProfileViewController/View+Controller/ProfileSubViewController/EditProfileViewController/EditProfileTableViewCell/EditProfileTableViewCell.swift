

import UIKit
protocol editProfileDelegate {
    func textFieldEndEditingAct(_ textField: UITextField)
}
class EditProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var verifyStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var NewSellLbl: UILabel!
    @IBOutlet weak var StripeNewLbl: UILabel!
    var delegate: editProfileDelegate?
    
    @IBOutlet weak var BorderView: UIView!
    @IBOutlet weak var ViewStack: UIStackView!
    
    @IBOutlet weak var stripeTextView: LinkOnlyTextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
        // Enable user interaction on label
        self.textField.delegate = self
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        StripeNewLbl.isUserInteractionEnabled = true
//        StripeNewLbl.addGestureRecognizer(tapGesture)
        self.userImageView.cornerViewRadius()
        self.verifyLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.NewSellLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "sellvia")
        self.titleLabel.config(color: UIColor(named: "ThemeTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.nextButton.tintColor = UIColor(named: "ThemeTextColor")
        self.descLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.textField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 15))
        self.switchButton.semanticContentAttribute = .forceLeftToRight
        self.ViewStack.layer.borderColor = UIColor(named: "AppThemeColorNew")?.cgColor
        self.ViewStack.layer.borderWidth = 0.5
        self.ViewStack.clipsToBounds = true
        self.ViewStack.layer.cornerRadius = 5
        stripeTextView.isEditable = false
        stripeTextView.isScrollEnabled = false
        stripeTextView.dataDetectorTypes = [] // prevent auto detection
        stripeTextView.backgroundColor = .clear
        stripeTextView.textContainerInset = .zero
        stripeTextView.textContainer.lineFragmentPadding = 0
        stripeTextView.delegate = self
        self.ViewStack.isUserInteractionEnabled = true
        self.stripeTextView.isUserInteractionEnabled = true
        self.stripeTextView.isSelectable = true
        let fullText = "✅ Upon registration, I agreed that transactions are at the buyer's and seller's own risk. Our platform verifies each user via phone number. When using the Buy Now button, reviews can be utilized, and the button is secured through Stripe, ensuring safe payments. However, BATNER holds no responsibility, as it is only a platform. View Terms & Policy"

        let attributedString = NSMutableAttributedString(string: fullText)
        let linkText = "View Terms & Policy"
        let range = (fullText as NSString).range(of: linkText)

        attributedString.addAttribute(.link,
                                      value: "https://batner.com/message/help?details=terms-and-policy",
                                      range: range)

        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor(named: "AppTextColor") ?? .white,
                                      range: NSRange(location: 0, length: fullText.count))

        stripeTextView.linkTextAttributes = [
            .foregroundColor: UIColor(named: "AppThemeColorNew") ?? UIColor.green,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont(name: APP_FONT_BOLD, size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        ]

        stripeTextView.attributedText = attributedString
        stripeTextView.textContainer.lineBreakMode = .byWordWrapping
        stripeTextView.textContainer.widthTracksTextView = true
        stripeTextView.textContainer.heightTracksTextView = false
        stripeTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        stripeTextView.setContentHuggingPriority(.required, for: .vertical)
        
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.switchButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        stripeTextView.sizeToFit()
        stripeTextView.layoutIfNeeded()
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        stripeTextView.invalidateIntrinsicContentSize()
    }
    func loadData(_ profileData: ProfileResultModel, index: IndexPath) {
        
        self.stripeTextView.setNeedsLayout()
        self.stripeTextView.layoutIfNeeded()
        self.textField.tag = index.row
        self.userImageView.isHidden = true
        self.verifyStackView.isHidden = true
        self.nextButton.isHidden = true
        self.switchButton.isHidden = true
        self.descLabel.isHidden = true
        self.textField.isHidden = true
        self.verifyButton.isHidden = false
        self.ViewStack.isHidden = true
        self.nextButton.setImage(#imageLiteral(resourceName: "InArrowImg").imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        self.verifyLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.NewSellLbl.isHidden = true
        if index.section == 0 {
            self.nextButton.isHidden = false
            self.userImageView.isHidden = false
            var imageName = profileData.userImg ?? ""
            if !profileData.userImg.contains("https") {
                let baseURL = (UserDefaultModule.shared.getbaseurlonly() ?? "https://batner.com/")
                let safeBaseURL = baseURL.hasSuffix("/") ? baseURL : baseURL + "/"
                let imagePath = "profile/\(profileData.userImg ?? "")"
                 imageName = safeBaseURL + imagePath
            }
            self.userImageView.sd_setImage(with: URL(string: imageName), placeholderImage: #imageLiteral(resourceName: "applogo"), completed: nil)
            self.titleLabel.text = getLanguage["Edit"] ?? "Edit"
        }
        else if index.section == 1 {
            self.textField.isHidden = false
            self.descLabel.isHidden = true

            if index.row == 0 || index.row == 1 {
                if index.row == 0 {
                    self.titleLabel.text = (getLanguage["Name"] ?? "").capitalized
                    self.textField.text = profileData.fullName
                    self.textField.isUserInteractionEnabled = true
                }
                else {
                    self.titleLabel.text = (getLanguage["username"] ?? "").capitalized
                    self.textField.text = profileData.userName
                    self.textField.isUserInteractionEnabled = false
                }
            }
            else {
                self.textField.text = "***************"
                self.textField.isUserInteractionEnabled = false
                self.titleLabel.text = (getLanguage["changepassword"] ?? "").capitalized
                self.nextButton.isHidden = false
            }
        }
        else if index.section == 2 {
            self.descLabel.isHidden = false
            if index.row == 0 || index.row == 1 || index.row == 6 || index.row == 7 {
                self.nextButton.isHidden = false
                self.verifyStackView.isHidden = false
                self.verifyButton.isHidden = true
                if index.row == 0 {
                    self.titleLabel.text = (getLanguage["location"] ?? "")
                    self.descLabel.text = profileData.location
                }
                else {
                    self.descLabel.isHidden = true

                    // In loadData(), where index.row == 1, add:
                    if index.row == 1 {
                        self.titleLabel.text = (getLanguage["manage_stripe"] ?? "")
                        self.NewSellLbl.isHidden = false
                        self.ViewStack.isHidden = false
                        self.ViewStack.isUserInteractionEnabled = true
                        self.stripeTextView.isUserInteractionEnabled = true
                        self.stripeTextView.isSelectable = true
                       
                    }
                    else if index.row == 6 {
                        self.verifyStackView.isHidden = false
                        self.verifyButton.isHidden = true
                        self.verifyLabel.config(color: UIColor(named: "textfiledBackGroundColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
                        self.verifyLabel.text = getLanguage[UserDefaultModule.shared.getAppLanguage().lowercased()]
                        self.titleLabel.text = (getLanguage["language"] ?? "")
                    }else{
                        self.titleLabel.text = (getLanguage["theme"] ?? "")
                        self.verifyLabel.text = UserDefaultModule.shared.getTheme()
                    }
                }
            }
            else {
                self.verifyStackView.isHidden = false
                self.verifyButton.isHidden = false
                self.switchButton.isHidden = true
                self.descLabel.isHidden = false
                if index.row == 2 {
                    self.titleLabel.text = (getLanguage["Email"] ?? "").capitalized
                    self.descLabel.text = profileData.email
                    if profileData.emailVerification == "enable"{
                        if profileData.verification.email == true{
                            self.verifyLabel.text = getLanguage["verified"]
                            self.verifyButton.setImage(#imageLiteral(resourceName: "tick-green"), for: .normal)
                        }
                    }
                    else if profileData.emailVerification == "disable"{
                        self.verifyLabel.text = ""
                        self.verifyButton.isHidden = true
                     }
                 }
                else if index.row == 3 {
                    self.titleLabel.text = (getLanguage["Phone"] ?? "").capitalized
                    if profileData.mobileNo.contains("+") {
                        self.descLabel.text = profileData.mobileNo
                    }
                    else {
                        self.descLabel.text = "+\(profileData.mobileNo ?? "")"
                    }
                    if (profileData.mobileNo == ""){
                        self.descLabel.text = getLanguage["link_your_account"] ?? ""
                    }
                   self.verifyLabel.text = (profileData.mobileNo != "") ? (getLanguage["verified"] ?? "") : (getLanguage["unverified"] ?? "")
                    self.verifyButton.setImage((profileData.mobileNo != "") ? #imageLiteral(resourceName: "tick-green") : #imageLiteral(resourceName: "cancel-1"), for: .normal)
                }
                else if index.row == 4 {
                    self.titleLabel.text = (getLanguage["Facebook"] ?? "").capitalized
                    if (profileData.verification.facebook == false){
                        self.descLabel.isHidden = false
                        self.descLabel.text = getLanguage["link_your_account"] ?? ""
                    }
                    else {
                        self.descLabel.isHidden = true
                    }
                    self.verifyLabel.text = (profileData.verification.facebook == true) ? (getLanguage["verified"] ?? "") : (getLanguage["unverified"] ?? "")
                    self.verifyButton.setImage((profileData.verification.facebook == true) ? #imageLiteral(resourceName: "tick-green") : #imageLiteral(resourceName: "cancel-1"), for: .normal)
                }
                else if index.row == 5 {
                    self.verifyStackView.isHidden = true
                    self.switchButton.isHidden = false
                    self.titleLabel.text = (getLanguage["Allow calls"] ?? "").capitalized
                    self.descLabel.text = getLanguage["Allow user to call you"] ?? ""
                    self.switchButton.isOn = profileData.showMobileNo
                }
            }
        }
        else {
            self.nextButton.setImage(#imageLiteral(resourceName: "InArrowImg"), for: .normal)
            self.descLabel.isHidden = true
            self.titleLabel.text = (getLanguage["logout"] ?? "")
        }
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension EditProfileTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldEndEditingAct(textField)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        let strLength = textField.text?.count ?? 0
        let lngthToAdd = string.count
        let lengthCount = strLength + lngthToAdd
        if lengthCount > 30 {
            return false
        }
        return true
    }
}

extension EditProfileTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        
        print("✅ Terms clicked:", URL)
        
        UIApplication.shared.open(URL)
        return false
    }
}

class LinkOnlyTextView: UITextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Remove long press gestures to prevent selection menu
        gestureRecognizers?.forEach { gesture in
            if let longPress = gesture as? UILongPressGestureRecognizer {
                removeGestureRecognizer(longPress)
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let pos = closestPosition(to: point),
              let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else {
            return false
        }
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false // Disables Copy/Cut/Paste menu
    }
}
