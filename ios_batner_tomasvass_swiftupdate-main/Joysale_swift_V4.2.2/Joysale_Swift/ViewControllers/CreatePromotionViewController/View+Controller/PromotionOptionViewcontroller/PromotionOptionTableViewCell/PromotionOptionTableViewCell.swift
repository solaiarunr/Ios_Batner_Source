//
//  PromotionOptionTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 22/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class PromotionOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    var viewModel = PromotionViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
        self.durationLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.priceLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 17), align: .left, text: "")
        self.daysLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .left, text: "")
        self.selectedView.isHidden = true
    }
    
    func loadData(promotionData: OtherPromotionModel, index: Int) {
        self.topImageView.isHidden = true
        if index == 0 {
            self.topImageView.isHidden = false
        }
        self.durationLabel.text = promotionData.name
        self.priceLabel.text = promotionData.formattedPrice
        self.daysLabel.text = "\(promotionData.days ?? 0) \(getLanguage["days"] ?? "")"
    }
    func loadSubcribeData(promotionData1: Subscription, index: Int) {
        self.topImageView.isHidden = true
        if index == 0 {
            self.topImageView.isHidden = false
        }
        self.durationLabel.text = promotionData1.name
        self.priceLabel.text = "\(self.viewModel.getSubcriptionModel?.result.currencySymbol ?? "") \(promotionData1.price ?? "0")"
         self.daysLabel.text = "\(promotionData1.listcount ?? 0) \(getLanguage["post"] ?? "")"
     }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
