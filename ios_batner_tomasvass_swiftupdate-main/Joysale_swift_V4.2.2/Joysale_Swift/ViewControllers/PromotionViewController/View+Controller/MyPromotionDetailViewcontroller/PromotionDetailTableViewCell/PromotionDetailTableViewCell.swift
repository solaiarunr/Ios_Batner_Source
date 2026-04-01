//
//  PromotionDetailTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 20/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class PromotionDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var paidStackView: UIStackView!
    @IBOutlet weak var promotionLabel: UILabel!
    @IBOutlet weak var promotionTitleLabel: UILabel!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var paidAmountTitleLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
        self.itemLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 18), align: .left, text: "")
        self.paidAmountLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 18), align: .left, text: "")
        self.paidAmountTitleLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "")
        self.promotionTitleLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "")
        self.promotionLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 18), align: .left, text: "")
    }
    func loadData(_ promotionData: PromotionResultModel, index: Int) {
        self.configUI()
        self.itemLabel.isHidden = true
        self.paidStackView.isHidden = true
        self.lineView.isHidden = true

        if index == 0 {
            self.itemLabel.isHidden = false
            self.itemLabel.text = promotionData.itemName
            self.paidStackView.isHidden = false
            self.promotionLabel.textColor = UIColor(named: "NameColor")
            self.promotionTitleLabel.text = (getLanguage["Promotion_type"] ?? "")
            self.lineView.isHidden = false
            if promotionData.promotionName.lowercased() == "premium promotion" {
                self.promotionLabel.text = getLanguage["adds"] ?? "Top"
            } else {
                self.promotionLabel.text = getLanguage[promotionData.promotionName.lowercased()] ?? ""
            }
            self.paidAmountTitleLabel.text = getLanguage["Paid_amount"] ?? ""
            self.paidAmountLabel.text = promotionData.formattedPaidAmount

        }
        else if index == 1 {
            self.promotionTitleLabel.text = (getLanguage["Transaction_id"] ?? "")
            self.promotionLabel.text = promotionData.transactionId
        }
        else if index == 2 {
            self.promotionTitleLabel.text = (getLanguage["up_to"] ?? "")
            let dateArr = promotionData.upto.components(separatedBy: " - ")
            self.promotionLabel.text = "\(Utility.shared.timeStampWithDateFormat(timeStamp: "\(dateArr.first ?? "")", dateFormat: "MMM dd, YYYY")) - \(Utility.shared.timeStampWithDateFormat(timeStamp: "\(dateArr.last ?? "")", dateFormat: "MMM dd, YYYY"))"
        }
        else {
            self.promotionTitleLabel.text = (getLanguage["Status"] ?? "")
            self.promotionLabel.text = (getLanguage[(promotionData.status ?? "").lowercased()] ?? (promotionData.status ?? ""))
            self.promotionLabel.textColor = UIColor(named: "StatusBlueTextColor") ?? .white
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
