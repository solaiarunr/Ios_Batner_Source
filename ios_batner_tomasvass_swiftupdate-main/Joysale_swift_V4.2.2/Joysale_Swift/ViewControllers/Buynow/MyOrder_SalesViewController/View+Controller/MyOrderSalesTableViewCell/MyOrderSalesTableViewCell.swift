//
//  MyOrderSalesTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 08/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Cosmos

class MyOrderSalesTableViewCell: UITableViewCell {

    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var listImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.ratingStackView.isHidden = true
        self.dateLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.ratingLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.listNameLabel.config(color: UIColor(named: "appblackcolorNew"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .left, text: "")
        self.statusButton.cornerMiniumRadius()
        self.statusButton.config(color: UIColor(named: "whitecolorNEW"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "")
    }
    func loadData(_ orderData: MyOrderResultModel, viewType: Int) {
        if orderData.userstatus == "2" {
            self.listImageView.image = #imageLiteral(resourceName: "applogo")
        } else {
            self.listImageView.sd_setImage(with: URL(string: orderData.orderitems.orderImage)) { (image, error, cache, url) in
                if error != nil {
                    self.listImageView.image = #imageLiteral(resourceName: "applogo")
                }
            }
        }
        /*
         //old
        if orderData.sellerStatus == "deleted" {
            self.listImageView.image = #imageLiteral(resourceName: "applogo")
        } else {
            self.listImageView.sd_setImage(with: URL(string: orderData.orderitems.orderImage)) { (image, error, cache, url) in
                if error != nil {
                    self.listImageView.image = #imageLiteral(resourceName: "applogo")
                }
            }
        }
         */
//        self.listImageView.sd_setImage(with: URL(string: orderData.orderitems.orderImage)) { (image, error, cache, url) in
//            if error != nil {
//                self.listImageView.image = #imageLiteral(resourceName: "applogo")
//            }
//        }
        self.listNameLabel.text = orderData.orderitems.itemname
        self.dateLabel.text = "\(Utility.shared.timeStampWithDateFormat(timeStamp: "\(orderData.saledate ?? 0)", dateFormat: "MMM dd, YYYY")) \((getLanguage["ORDER ON"] ?? ""))"
        if orderData.status == "cancelled" {
            self.statusButton.setTitle(getLanguage["Order Canceled"] ?? orderData.status, for: .normal)
            self.statusButton.setBackgroundColor(color: UIColor(named: "redcolor") ?? .white, forState: .normal)
        }
        else if orderData.status == "pending" {
            self.statusButton.setTitle(getLanguage["Pending"] ?? orderData.status, for: .normal)
            self.statusButton.setBackgroundColor(color: UIColor(named: "appblackcolorNew") ?? .white, forState: .normal)
        }
        else if orderData.status == "processing" {
            self.statusButton.setTitle(getLanguage["Under Processing"] ?? orderData.status, for: .normal)
            self.statusButton.setBackgroundColor(color: UIColor(named: "appblackcolorNew") ?? .white, forState: .normal)
        }
        else if orderData.status == "delivered" {
            self.statusButton.setTitle(getLanguage["Item delivered"] ?? orderData.status, for: .normal)
            self.statusButton.setBackgroundColor(color: UIColor(named: "AppThemeColorNew") ?? .white, forState: .normal)
        }
        else if orderData.status == "claimed" {
            self.statusButton.setTitle(getLanguage["Claimed"] ?? orderData.status, for: .normal)
            self.statusButton.backgroundColor = UIColor(named: "appblackcolorNew")
            self.statusButton.setBackgroundColor(color: UIColor(named: "appblackcolorNew") ?? .white, forState: .normal)
        }
        else if orderData.status == "paid" {
            self.statusButton.setTitle(getLanguage["Paid"] ?? orderData.status, for: .normal)
            self.statusButton.setBackgroundColor(color: UIColor(named: "AppThemeColorNew") ?? .white, forState: .normal)
        }
        else if orderData.status == "shipped" {
            self.statusButton.setTitle(getLanguage["Item shipped"] ?? orderData.status, for: .normal)
            self.statusButton.setBackgroundColor(color: UIColor(named: "soldOutColor") ?? .white, forState: .normal)
        }
//        if orderData.rating != 0 && viewType == 0{
//            self.ratingView.rating = Double(orderData.rating)
//            self.ratingLabel.text = "\(orderData.rating ?? 0)"
//            ratingStackView.isHidden = false
//        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
