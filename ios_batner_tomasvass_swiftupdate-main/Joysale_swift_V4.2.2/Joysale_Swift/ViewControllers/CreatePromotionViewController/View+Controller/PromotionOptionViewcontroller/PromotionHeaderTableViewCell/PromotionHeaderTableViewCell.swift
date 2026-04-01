//
//  PromotionHeaderTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 22/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class PromotionHeaderTableViewCell: UITableViewHeaderFooterView {

    @IBOutlet weak var descStackView: UIStackView!
    @IBOutlet weak var promotionImageView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var promotion4Label: UILabel!
    @IBOutlet weak var promotion3Label: UILabel!
    @IBOutlet weak var promotion2Label: UILabel!
    @IBOutlet weak var promotion1Label: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var promotionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.priceLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "")
        self.lineView.isHidden = true
        self.promotion1Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.promotion2Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.promotion3Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.promotion4Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.statusButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, title: "")
    }
    func loadHeaderData(viewTag: Int) {
        self.promotionTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .center, text: "")
        self.descStackView.isHidden = true
        self.lineView.isHidden = true
        self.promotionImageView.isHidden = true
        self.priceLabel.isHidden = true
        if viewTag == 1 {
            self.priceLabel.isHidden = false
            self.promotionTitleLabel.text = getLanguage["urgent_ads_highlighted"] ?? ""
        }
        else {
            self.priceLabel.isHidden = true
            self.promotionTitleLabel.text = getLanguage["ads_instant_viewable"] ?? ""
        }
    }
    func loadFooterData(viewTag: Int) {
        self.promotionTitleLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 16), align: .center, text: "")
        self.descStackView.isHidden = false
        self.lineView.isHidden = false
        self.promotionImageView.isHidden = false
        self.priceLabel.isHidden = true

        if viewTag == 1 {
//            self.statusButton.setTitle(getLanguage["urgent"] ?? "", for: .normal)
            
//            self.statusButton.setBackgroundColor(color: UIColor(named: "UrgentColor") ?? .white, forState: .normal)
            self.statusButton.setBackgroundImage(UIImage(named: "Urgentimg"), for: .normal)
            self.promotionTitleLabel.text = getLanguage["urgent_tag_features"] ?? ""
            self.promotion1Label.text = getLanguage["urgent_feature_list1"] ?? ""
            self.promotion2Label.text = getLanguage["urgent_feature_list2"] ?? ""
            self.promotion3Label.text = getLanguage["urgent_feature_list3"] ?? ""
            self.promotion4Label.text = getLanguage["urgent_feature_list4"] ?? ""
        }
        else {
//            self.statusButton.setTitle(getLanguage["ad"] ?? "", for: .normal)
//            
//            self.statusButton.setBackgroundColor(color: UIColor(named: "NameColor") ?? .white, forState: .normal)
            self.statusButton.setBackgroundImage(UIImage(named: "adimg"), for: .normal)
            self.promotionTitleLabel.text = getLanguage["promote_tag_features"] ?? ""
            self.promotion1Label.text = getLanguage["promote_feature_list1"] ?? ""
            self.promotion2Label.text = getLanguage["promote_feature_list2"] ?? ""
            self.promotion3Label.text = getLanguage["promote_feature_list3"] ?? ""
            self.promotion4Label.text = getLanguage["promote_feature_list4"] ?? ""
        }
    }
}
