//
//  ReviewTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 10/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var editReviewButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.reviewTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "review")
        self.titleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.descLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.dateLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")

        self.editReviewButton.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .center, title: "editreview")
    }
    func loadData(_ orderData: MyOrderResultModel) {
        self.ratingView.rating = Double(orderData.rating)
        self.titleLabel.text = orderData.reviewTitle
        self.descLabel.text = orderData.reviewDes
        if (orderData.createdDate ?? 0) > 0 {
            self.dateLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(orderData.createdDate ?? Int(Date().timeIntervalSince1970))", dateFormat: "MMM dd, YYYY")
        }
        else {
            self.dateLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(Int(Date().timeIntervalSince1970))", dateFormat: "MMM dd, YYYY")

        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
