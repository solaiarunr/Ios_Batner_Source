//
//  AddressListTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 26/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class AddressListTableViewCell: UITableViewCell {

    @IBOutlet weak var sellerLineView: UIView!
    @IBOutlet weak var sellerDetailsStackView: UIStackView!
    @IBOutlet weak var deliveredLabel: UILabel!
    @IBOutlet weak var deliveredTitleLabel: UILabel!
    @IBOutlet weak var deliveredStackView: UIStackView!
    
    @IBOutlet weak var shippingAddressLabel: UILabel!
    @IBOutlet weak var shippingAddressTitleLabel: UILabel!
    @IBOutlet weak var shippingAddressStackView: UIStackView!
    
    @IBOutlet weak var paymentTypeStackView: UIStackView!
    @IBOutlet weak var paymentTypeTitleLabel: UILabel!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    
    @IBOutlet weak var orderStackView: UIStackView!
    @IBOutlet weak var orderIdTitleLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var transactionIdTitleLabel: UILabel!
    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var orderDataTitleLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    
    @IBOutlet weak var sellerStackView: UIStackView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerNameTitleLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var addr2Label: UILabel!
    @IBOutlet weak var addr1Label: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dafaultLabel: UILabel!
    
    var isFromBuyNowPage = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
        self.deliveredTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "deliverydate")
        self.deliveredTitleLabel.text = self.deliveredTitleLabel.text?.uppercased() ?? ""
        self.deliveredLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")

        self.shippingAddressTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "shippeddate")
        self.shippingAddressTitleLabel.text = self.shippingAddressTitleLabel.text?.uppercased() ?? ""
        self.shippingAddressLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")

        self.paymentTypeTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "paymenttype")
        self.paymentTypeLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")

        self.orderIdTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "ORDER ID")
        self.orderIdLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")

        self.transactionIdTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "Transaction_id")
        self.transactionIdLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")

        self.orderDataTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "orderdate")
        self.orderDateLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .left, text: "")
        
        self.sellerNameTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "sellername")
        self.sellerNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")

        self.dafaultLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "default")
        self.userNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.fullNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.addr1Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.addr2Label.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.cityLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.stateLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.countryLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.mobileNumberLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.changeButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "change")
        self.sellerDetailsStackView.isHidden = false
        self.sellerLineView.isHidden = false

        self.sellerStackView.isHidden = false
        self.changeButton.isHidden = true
        self.changeButton.cornerMiniumRadius()
        self.changeButton.backgroundColor = UIColor(named: "TransparentBlack")
    }
    func loadData(addressResult: AddressListResultModel) {
        self.dafaultLabel.isHidden = true
        if isFromBuyNowPage == true{
            self.sellerDetailsStackView.isHidden = false
            self.sellerLineView.isHidden = false
        }
        else{
            self.sellerDetailsStackView.isHidden = true
            self.sellerLineView.isHidden = true
        }
         if addressResult.defaultshipping == 1 {
            self.dafaultLabel.isHidden = false
        }
        self.orderStackView.isHidden = true
        self.paymentTypeStackView.isHidden = true
        self.userNameLabel.text = addressResult.nickname
        self.fullNameLabel.text = addressResult.name
        self.addr1Label.text = addressResult.address1
        self.addr2Label.text = addressResult.address2
        self.cityLabel.text = addressResult.city
        self.stateLabel.text = addressResult.state
        self.countryLabel.text = addressResult.country
        self.mobileNumberLabel.text = addressResult.phone
    }
    func loadBuyNowData(_ sellerName: String, addressResult: AddressListResultModel) {
        self.sellerDetailsStackView.isHidden = false
        self.sellerLineView.isHidden = false
        self.orderStackView.isHidden = true
        self.paymentTypeStackView.isHidden = true
        self.sellerStackView.isHidden = false
        self.sellerNameLabel.text = sellerName
        self.changeButton.isHidden = false
        self.moreButton.isHidden = true
        self.loadData(addressResult: addressResult)
        self.dafaultLabel.isHidden = false
        self.dafaultLabel.text = getLanguage["deliveryaddress"] ?? ""
    }
    func loadOrderSalesData(_ orderData: MyOrderResultModel, viewType: Int) {
        self.sellerDetailsStackView.isHidden = false
        self.sellerLineView.isHidden = false
        self.loadData(addressResult: orderData.shippingaddress)
        self.shippingAddressStackView.isHidden = true
        self.deliveredStackView.isHidden = true
        self.orderStackView.isHidden = false
        self.paymentTypeStackView.isHidden = false
        self.sellerStackView.isHidden = false
        self.changeButton.isHidden = true
        self.moreButton.isHidden = true
        self.dafaultLabel.isHidden = false
        self.dafaultLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "deliveryaddress")
        
        if viewType == 1 {
            self.sellerNameTitleLabel.text = getLanguage["buyername"] ?? ""
        }
        self.sellerNameLabel.text = orderData.orderitems.buyerName
        self.paymentTypeLabel.text = orderData.paymentType
        self.orderIdLabel.text = "\(orderData.orderid ?? 0)"
        self.transactionIdLabel.text = orderData.transactionId
        self.orderDateLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(orderData.saledate ?? 0)", dateFormat: "MMM dd, YYYY")
        if orderData.trackingdetails != nil {
            if orderData.status == "paid" || orderData.status == "delivered" || orderData.status == "shipped" || orderData.status == "claimed" {
                self.shippingAddressStackView.isHidden = false
                self.shippingAddressLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(orderData.trackingdetails.shippingdate ?? 0)", dateFormat: "MMM dd, YYYY")
            }
        }
        if orderData.status == "paid" || orderData.status == "delivered" {
            if (orderData.deliverydate ?? 0) > 0 {
                self.deliveredLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(orderData.deliverydate ?? 0)", dateFormat: "MMM dd, YYYY")
            }
            else {
                self.deliveredLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(Int(Date().timeIntervalSince1970))", dateFormat: "MMM dd, YYYY")

            }
            self.deliveredStackView.isHidden = false
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
