//
//  ViewProfileHeaderView.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 12/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Cosmos

class ViewProfileHeaderView: UIView {
    
    @IBOutlet weak var wholeRatingView: UIView!
    @IBOutlet weak var navTopConst: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var mailVerifyImageView: UIImageView!
    @IBOutlet weak var facebookVerifyImageView: UIImageView!
    @IBOutlet weak var mobileVerifyImageView: UIImageView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var wholeHeaderView: UIView!
    @IBOutlet weak var navUserNameLabel: UILabel!
    @IBOutlet weak var navFirstNameLabel: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navUserImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var nameStackView: UIStackView!
    
    @IBOutlet weak var UserNameLbl: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customUI()
    }
    
    func customUI() {
        Bundle.main.loadNibNamed("ViewProfileHeaderView", owner: self, options: nil)
        self.contentView.frame = self.bounds
        self.contentView.fixInView(self)
        self.userImageView.cornerViewRadius()
        self.navUserImageView.cornerViewRadius()
        self.userNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 20), align: .left, text: "")
        self.UserNameLbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 20), align: .left, text: "")
        self.navFirstNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .left, text: "")
        self.navUserNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "")
        self.ratingLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 20), align: .left, text: "")
        self.editButton.cornerMiniumRadius()
        
        self.backButton.setImage(#imageLiteral(resourceName: "detail_back").imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.backButton.semanticContentAttribute = .forceRightToLeft
        }
        else {
            self.backButton.semanticContentAttribute = .forceLeftToRight
        }
        self.navUserImageView.isHidden = true
        self.nameStackView.isHidden = true
        var wholeHeight = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            wholeHeight = Int(window?.safeAreaInsets.top ?? 0)
        }
        self.navTopConst.constant = CGFloat(wholeHeight)
        self.wholeRatingView.isHidden = !BUYNOW_MODEL_FLAG
    }
    func updateView(val: CGFloat) {
        if val > 180 {
            self.backButton.tintColor = (UIColor(named: "whitecolor") ?? .white)
            self.editButton.tintColor = (UIColor(named: "whitecolor") ?? .white)
            self.nameStackView.isHidden = true
            self.wholeStackView.isHidden = false
            self.navUserImageView.isHidden = true
            self.userImageView.isHidden = false
        }
        else if val > 150 {
            self.backButton.tintColor = (UIColor(named: "whitecolor") ?? .white)
            self.editButton.tintColor = (UIColor(named: "whitecolor") ?? .white)
            self.navUserNameLabel.textColor = (UIColor(named: "whitecolor") ?? .white)
            self.navFirstNameLabel.textColor = (UIColor(named: "whitecolor") ?? .white)
            self.nameStackView.isHidden = false
            self.wholeStackView.isHidden = false
            self.userImageView.isHidden = true
            self.navUserImageView.isHidden = false
        }
        else {
            self.backButton.tintColor = (UIColor(named: "AppTextColor") ?? .white)
            self.editButton.tintColor = (UIColor(named: "AppTextColor") ?? .white)
            self.navUserNameLabel.textColor = (UIColor(named: "AppTextColor") ?? .white)
            self.navFirstNameLabel.textColor = (UIColor(named: "AppTextColor") ?? .white)
            self.nameStackView.isHidden = false
            self.navUserImageView.isHidden = false
            self.wholeStackView.isHidden = true
            self.userImageView.isHidden = true
        }
    }
    func loadData(_ profileData: ProfileResultModel) {
        self.userNameLabel.text = profileData.fullName
        self.navUserNameLabel.text = profileData.userName
        self.UserNameLbl.text = profileData.userName
        self.navFirstNameLabel.text = profileData.fullName
        self.ratingView.rating = Double(profileData.rating ?? "0") ?? Double(0)
        self.ratingLabel.text = "(\(profileData.ratingUserCount ?? "0"))"
        print(profileData.userImg ?? "")
        self.userImageView.sd_setImage(with: URL(string: (profileData.userImg ?? ""))) { (image, error, chache, url) in
            if error != nil {
                self.userImageView.image = #imageLiteral(resourceName: "applogo")
            }
        }
        self.navUserImageView.sd_setImage(with: URL(string: (profileData.userImg ?? "")), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        
         if (ADMIN_VIEW_MODEL.adminModel?.result.emailVerification) == "enable"{
            if profileData.verification.email == true{
                self.mailVerifyImageView.image =  #imageLiteral(resourceName: "mail-veri")
            }
         }
         else if (ADMIN_VIEW_MODEL.adminModel?.result.emailVerification) == "disable"{
            self.mailVerifyImageView.isHidden = true
         }
        self.mobileVerifyImageView.image = profileData.verification.mobNo == true ? #imageLiteral(resourceName: "mob-veri") : #imageLiteral(resourceName: "mob-unveri")
        self.facebookVerifyImageView.image = profileData.verification.facebook == true ? #imageLiteral(resourceName: "fac-veri") : #imageLiteral(resourceName: "fac-unveri")
    }
}
extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
