//
//  MyPromotionTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 20/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class MyPromotionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var validtitleLabel: UILabel!
    @IBOutlet weak var dateStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
        self.itemTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .left, text: "")
        self.arrowImageView.tintColor = UIColor(named: "ThirdryTextColor")
        self.validtitleLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "validupto")
        self.dateLabel.config(color: UIColor(named: "redcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "validupto")
    }
    
    func loadData(_ prootionData: PromotionResultModel, type: String) {
        self.itemTitleLabel.text = prootionData.itemName
        self.dateStackView.isHidden = true
        if type == "ad" {
            self.dateStackView.isHidden = false
            let dateArr = prootionData.upto.components(separatedBy: " - ")
            self.dateLabel.text = "\(Utility.shared.timeStampWithDateFormat(timeStamp: "\(dateArr.first ?? "")", dateFormat: "MMM dd, YYYY")) - \(Utility.shared.timeStampWithDateFormat(timeStamp: "\(dateArr.last ?? "")", dateFormat: "MMM dd, YYYY"))"
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
