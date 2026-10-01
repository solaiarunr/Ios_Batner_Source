

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
        self.clipsToBounds = true
        self.contentView.clipsToBounds = true
        self.verifyLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.NewSellLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: getLanguage["sellvia"] ?? "")
        self.titleLabel.config(color: UIColor(named: "ThemeTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.nextButton.tintColor = UIColor(named: "ThemeTextColor")
        self.descLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.descLabel.numberOfLines = 0
        self.textField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 15))
        self.switchButton.semanticContentAttribute = .forceLeftToRight
        self.ViewStack.layer.borderColor = UIColor(named: "AppThemeColorNew")?.cgColor
        self.ViewStack.layer.borderWidth = 0.5
        self.ViewStack.clipsToBounds = true
        self.ViewStack.layer.cornerRadius = 5
        self.ViewStack.setContentCompressionResistancePriority(.required, for: .vertical)
        self.BorderView.setContentCompressionResistancePriority(.required, for: .vertical)
        stripeTextView.isEditable = false
        stripeTextView.isScrollEnabled = false
        stripeTextView.showsVerticalScrollIndicator = false
        stripeTextView.showsHorizontalScrollIndicator = false
        stripeTextView.dataDetectorTypes = [] // prevent auto detection
        stripeTextView.backgroundColor = .clear
        stripeTextView.textContainerInset = .zero
        stripeTextView.textContainer.lineFragmentPadding = 0
        stripeTextView.textContainer.maximumNumberOfLines = 0
        stripeTextView.textContainer.lineBreakMode = .byWordWrapping
        stripeTextView.textContainer.widthTracksTextView = true
        stripeTextView.textContainer.heightTracksTextView = false
        stripeTextView.delegate = self
        self.ViewStack.isUserInteractionEnabled = true
        self.stripeTextView.isUserInteractionEnabled = true
        self.stripeTextView.isSelectable = true
        stripeTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        stripeTextView.setContentHuggingPriority(.required, for: .vertical)
        
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.switchButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }


    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let fitted = super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        guard !ViewStack.isHidden else { return fitted }

        layoutIfNeeded()
        stripeTextView.invalidateIntrinsicContentSize()
        ViewStack.invalidateIntrinsicContentSize()

        return super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    func loadData(_ profileData: ProfileResultModel, index: IndexPath) {
        
        self.stripeTextView.setNeedsLayout()
        self.stripeTextView.layoutIfNeeded()
        self.textField.tag = index.row
        self.titleLabel.isHidden = false
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
                    self.titleLabel.text = (getLanguage["Name"] ?? "Name").capitalized
                    self.textField.text = profileData.fullName
                    self.textField.isUserInteractionEnabled = true
                }
                else {
                    self.titleLabel.text = (getLanguage["username"] ?? "Username").capitalized
                    self.textField.text = profileData.userName
                    self.textField.isUserInteractionEnabled = false
                }
            }
            else {
                self.textField.text = "***************"
                self.textField.isUserInteractionEnabled = false
                self.titleLabel.text = (getLanguage["changepassword"] ?? "Change Password").capitalized
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
                    self.titleLabel.text = (getLanguage["location"] ?? "Location")
                    self.descLabel.text = profileData.location
                }
                else {
                    self.descLabel.isHidden = true

                    if index.row == 1 {
                        self.ViewStack.isHidden = true
                        if profileData.stripe_onboarding_complete ?? "false" == "true" {
                            self.titleLabel.text = (getLanguage["manage_stripe"] ?? "Manage Stripe")
                            self.NewSellLbl.isHidden = true
                            self.descLabel.isHidden = false
                            let dashboardText = getLanguage["go_to_dashboard"] ?? "Go to Dashboard"
                            let idText = "ID: \(profileData.stripe_account_id ?? "")"
                            let paragraphStyle = NSMutableParagraphStyle()
                            paragraphStyle.paragraphSpacing = 6
                            self.descLabel.attributedText = NSAttributedString(
                                string: "\(idText)\n\(dashboardText)",
                                attributes: [
                                    .font: UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 15),
                                    .foregroundColor: UIColor(named: "AppTextColor") ?? .white,
                                    .paragraphStyle: paragraphStyle
                                ]
                            )
                            self.verifyStackView.isHidden = false
                            self.verifyButton.isHidden = false
                            self.verifyButton.setImage(#imageLiteral(resourceName: "tick-green"), for: .normal)
                            self.verifyLabel.text = getLanguage["verified"] ?? "Verified"
                        } else {
                            self.titleLabel.text = (getLanguage["manage_stripe"] ?? "Manage Stripe")
                            self.NewSellLbl.isHidden = false
                            self.NewSellLbl.text = getLanguage["sellvia"] ?? "Sell via"
                            self.descLabel.isHidden = true
                            self.verifyStackView.isHidden = true
                            self.verifyButton.isHidden = true
                        }
                    }
                    else if index.row == 6 {
                        self.verifyStackView.isHidden = false
                        self.verifyButton.isHidden = true
                        self.verifyLabel.config(color: UIColor(named: "textfiledBackGroundColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
                        self.verifyLabel.text = getLanguage[UserDefaultModule.shared.getAppLanguage().lowercased()]
                        self.titleLabel.text = (getLanguage["language"] ?? "Language")
                    }else{
                        self.titleLabel.text = (getLanguage["theme"] ?? "Theme")
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
                    self.titleLabel.text = (getLanguage["Email"] ?? "Email").capitalized
                    self.descLabel.text = profileData.email
                    if profileData.emailVerification == "enable"{
                        if profileData.verification.email == true{
                            self.verifyLabel.text = getLanguage["verified"] ?? "Verified"
                            self.verifyButton.setImage(#imageLiteral(resourceName: "tick-green"), for: .normal)
                        }
                    }
                    else if profileData.emailVerification == "disable"{
                        self.verifyLabel.text = ""
                        self.verifyButton.isHidden = true
                     }
                 }
                else if index.row == 3 {
                    self.titleLabel.text = (getLanguage["Phone"] ?? "Phone").capitalized

                    if profileData.verification.mobNo {

                        // Phone verified
                        self.descLabel.isHidden = false
                        self.ViewStack.isHidden = true
                        self.verifyButton.isHidden = false

                        if profileData.mobileNo.contains("+") {
                            self.descLabel.text = profileData.mobileNo
                        } else {
                            self.descLabel.text = "+\(profileData.mobileNo ?? "")"
                        }

                        self.verifyLabel.text = getLanguage["verified"] ?? "Verified"
                        self.verifyButton.setImage(#imageLiteral(resourceName: "tick-green"), for: .normal)

                    } else if profileData.can_access {
                        // Phone not verified, waiting for admin approval
                        self.descLabel.isHidden = false
                        self.ViewStack.isHidden = false
                        self.verifyButton.isHidden = true
                        self.verifyLabel.text = ""

                        self.descLabel.config(
                            color: UIColor(named: "AppTextColor"),
                            font: UIFont(name: APP_FONT_REGULAR, size: 13),
                            align: .left,
                            text: getLanguage["few_days"] ?? "Your phone number will be verified within few days"
                        )

                        let title = getLanguage["Smswalltitle"] ?? "Bezpečný Batner začíná u tebe"
                        let body = getLanguage["Smswalldes"] ?? "Zakládáme si na tom, aby byl Batner plný reálných lidí. Proto dáváme zelenou pouze ověřeným českým telefonním číslům. Vyhneš se tak fake účtům, zahraničním botům a podvodníkům. Pojďme společně udržet komunitu čistou a bezpečnou!"

                        let attributedText = NSMutableAttributedString(
                            string: "\(title)\n",
                            attributes: [
                                .font: UIFont.boldSystemFont(ofSize: stripeTextView.font?.pointSize ?? 12),
                                .foregroundColor: UIColor(named: "AppTextColor") ?? .white
                            ]
                        )

                        attributedText.append(
                            NSAttributedString(
                                string: body,
                                attributes: [
                                    .foregroundColor: UIColor(named: "AppTextColor") ?? .white
                                ]
                            )
                        )

                        self.stripeTextView.attributedText = attributedText
                        self.ViewStack.isUserInteractionEnabled = true
                        self.stripeTextView.isUserInteractionEnabled = true
                        self.stripeTextView.isSelectable = true

                    } else {
                        // Phone not verified and no access
                        self.descLabel.isHidden = false
                        self.ViewStack.isHidden = true
                        self.verifyButton.isHidden = false
                        self.descLabel.text = getLanguage["link_your_account"] ?? "Link your account"
                        self.verifyLabel.text = getLanguage["unverified"] ?? "Unverified"
                        self.verifyButton.setImage(#imageLiteral(resourceName: "cancel-1"), for: .normal)
                    }                }
                else if index.row == 4 {
                    self.titleLabel.text = (getLanguage["Facebook"] ?? "Facebook").capitalized
                    if (profileData.verification.facebook == false){
                        self.descLabel.isHidden = false
                        self.descLabel.text = getLanguage["link_your_account"] ?? "Link your account"
                    }
                    else {
                        self.descLabel.isHidden = true
                    }
                    self.verifyLabel.text = (profileData.verification.facebook == true) ? (getLanguage["verified"] ?? "Verified") : (getLanguage["unverified"] ?? "Unverified")
                    self.verifyButton.setImage((profileData.verification.facebook == true) ? #imageLiteral(resourceName: "tick-green") : #imageLiteral(resourceName: "cancel-1"), for: .normal)
                }
                else if index.row == 5 {
                    self.verifyStackView.isHidden = true
                    self.switchButton.isHidden = false
                    self.titleLabel.text = (getLanguage["Allow calls"] ?? "Allow Calls").capitalized
                    self.descLabel.text = getLanguage["Allow user to call you"] ?? "Allow user to call you"
                    self.switchButton.isOn = profileData.showMobileNo
                }
            }
        }
        else {
            self.nextButton.setImage(#imageLiteral(resourceName: "InArrowImg"), for: .normal)
            self.descLabel.isHidden = true
            self.titleLabel.text = (getLanguage["logout"] ?? "Logout")
        }
        DispatchQueue.main.async {
            guard !self.ViewStack.isHidden else { return }
            self.stripeTextView.invalidateIntrinsicContentSize()
            self.ViewStack.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isHidden = false
        ViewStack.isHidden = true
        switchButton.isHidden = true
        NewSellLbl.isHidden = true
        verifyStackView.isHidden = true
        userImageView.isHidden = true
        nextButton.isHidden = true
        textField.isHidden = true
        descLabel.isHidden = true
        stripeTextView.attributedText = nil
        stripeTextView.invalidateIntrinsicContentSize()
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

    private var lastLayoutWidth: CGFloat = 0

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        isScrollEnabled = false
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = 0
        textContainer.lineBreakMode = .byWordWrapping
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .vertical)
        // Remove long press gestures to prevent selection menu
        gestureRecognizers?.forEach { gesture in
            if let longPress = gesture as? UILongPressGestureRecognizer {
                removeGestureRecognizer(longPress)
            }
        }
    }

    override var attributedText: NSAttributedString! {
        get { super.attributedText }
        set {
            super.attributedText = newValue
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let width = bounds.width > 0 ? bounds.width : super.intrinsicContentSize.width
        guard width > 0, let text = attributedText, text.length > 0 else {
            return super.intrinsicContentSize
        }

        let horizontalInsets = textContainerInset.left + textContainerInset.right + (textContainer.lineFragmentPadding * 2)
        let textWidth = max(0, width - horizontalInsets)
        let boundingRect = text.boundingRect(
            with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let height = ceil(boundingRect.height + textContainerInset.top + textContainerInset.bottom)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isHidden else { return }
        if abs(bounds.width - lastLayoutWidth) > 0.5 {
            lastLayoutWidth = bounds.width
            invalidateIntrinsicContentSize()
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
