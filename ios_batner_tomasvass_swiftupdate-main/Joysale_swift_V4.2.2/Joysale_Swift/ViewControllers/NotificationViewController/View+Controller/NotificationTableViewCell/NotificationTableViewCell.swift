//
//  NotificationTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nextArrowImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.userImageView.cornerViewRadius()
        self.messageLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.dateLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.amountLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
    }
    func loadData(_ result: NotificationResultModel) {
        DispatchQueue.main.async {
            self.userImageView.sd_setImage(with: URL(string: result.userImage), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        }
        var username = ""
        var content = ""
        var amount = ""
        var temp = ""
        var message = ""
        if result.userName != "" {
            username = result.userName
        }
        if result.type == "admin" {
            username = APP_NAME
            content = getLanguage["a_post"] ?? ""
            message = result.message
        }
        else if result.type == "adminpayment" {
            username = APP_NAME
            content = ""
            message = result.message
        }
        else if result.type == "banner" {
            if result.message.contains("approved your banner. Banner Id :".lowercased()) {
                message = result.message.replacingOccurrences(of: "approved your banner. Banner Id :", with: (getLanguage["approved your banner. Banner Id :"] ?? ""))
            }
            else {
                message = result.message
            }
        }
        else if result.type == "like" {
            content = getLanguage["liked_your_product"] ?? ""
            message = result.itemTitle.html2String
        }
        else if result.type == "add" {
            if result.message.contains("added a product".lowercased()) {
                content = getLanguage["addedProduct"] ?? ""
            }
            else {
                content = result.message
            }
            message = result.itemTitle.html2String
        }
        else if result.type == "follow" {
            content = getLanguage["start_following_you"] ?? result.message
        }
        else if result.type == "myoffer" {
            if result.message.uppercased() == "CONTACTED YOU ON YOUR PRODUCT" {
                content = ((getLanguage["contacted_you_on_your_product"] ?? "")+" \(result.itemTitle.html2String)")
            }
            else {
                let resArray = result.message.components(separatedBy: ":")
                if resArray.count >= 2 {
                    amount = resArray[1]
                }
                if result.message.contains("sent offer request on your product".lowercased()) {
                    content = (getLanguage["sent_offer_request"] ?? "") + "\(result.itemTitle.html2String)"
                }
                else {
                    content = (getLanguage["successed_your_exchange_request_on"] ?? "") + "\(result.itemTitle.html2String)"
                }
            }
        }
        else if result.type == "review" {
            content = ((getLanguage[result.message] ?? result.message) + " \(result.itemTitle.html2String).")
//            message = getLanguage["Write a review1"] ?? "Write a review"
        }
        else if result.type == "promotion_active" {
            username = ""
            content = result.message
            message = "\(result.paidAmount ?? "") \(result.promotionDays ?? "")"
        }
        else if result.type == "promotion_expired" {
            username = ""
            content = result.message
            message = "\(result.itemTitle.html2String) \(result.expireDate ?? "")"
        }
        else if result.type == "exchange" {
            if result.message.contains("declined your exchange request on") {
                content = getLanguage["declined_your_exchange_request_on"] ?? ""
            }
            else if result.message.contains("successed your exchange request on") {
                content = getLanguage["successed_your_exchange_request_on"] ?? ""
            }
            else if result.message.contains("accepted your exchange request on") {
                content = getLanguage["accepted_your_exchange_request_on"] ?? ""
            }
            else if result.message.contains("canceled your exchange request on") {
                content = getLanguage["canceled_your_exchange_request_on"] ?? ""
            }
            else if result.message.contains("sent exchange request to your product") {
                content = getLanguage["sent_exchange_request_to_your_product"] ?? ""
            }
            else if result.message.contains("failed your exchange request on") {
                content = getLanguage["failed_your_exchange_request_on"] ?? ""
            }
            message = result.itemTitle.html2String
        }
        else if result.type == "comment" {
            content = getLanguage["comment_on_your_product"] ?? ""
            message = result.itemTitle.html2String
        }
        else if result.type == "order" {
            var orderID = ""
            if result.message.contains("stripe credentials") {
                let placeOrderStr = result.message.replacingOccurrences(of: "placed an order in your shop, Order Id :", with: "")
               // orderID = placeOrderStr.replacingOccurrences(of: "Still You didn't add the stripe credentials.Please add it for getting the amount.", with: "")
                content = "\(getLanguage["placed_an_order_in_your_shop"] ?? "")  \(getLanguage["add_stripe_details"] ?? "")"
            }
            else if result.message.contains("added tracking details for your order. Order Id :") {
                if result.message.contains("added tracking details for your order. Order Id :") {
                    orderID = result.message.replacingOccurrences(of: "added tracking details for your order. Order Id :", with: "")
                    content = "\(getLanguage["added tracking details for your order. Order Id :"] ?? "") \(orderID)"
                }
            }
            else if result.message.contains("your order has been cancelled Order Id :") {
                orderID = result.message.replacingOccurrences(of: "your order has been cancelled Order Id :", with: "")
                content = "\(getLanguage["your order has been cancelled Order Id :"] ?? "") \(orderID)"
            }
            else if result.message.contains("has marked your order as delivered. Order Id :") {
                orderID = result.message.replacingOccurrences(of: "has marked your order as delivered. Order Id :", with: "")
                content = "\(getLanguage["has marked your order as delivered. Order Id :"] ?? "") \(orderID)"
            }
            else if result.message.contains("your order has been marked as delivered Order Id :") {
                orderID = result.message.replacingOccurrences(of: "your order has been marked as delivered Order Id :", with: "")
                content = "\(getLanguage["your order has been marked as delivered Order Id :"] ?? "") \(orderID)"
            }
            else if result.message.contains("your order has been marked as shipped Order Id :") {
                orderID = result.message.replacingOccurrences(of: "your order has been marked as shipped Order Id :", with: "")
                content = "\(getLanguage["your order has been marked as shipped Order Id :"] ?? "") \(orderID)"
            }
            else if result.message.contains("your order has been marked as processing Order Id :") {
                orderID = result.message.replacingOccurrences(of: "your order has been marked as processing Order Id :", with: "")
                content = "\(getLanguage["your order has been marked as processing Order Id :"] ?? "") \(orderID)"
            }
            else if result.message.contains("placed an order in your shop, Order Id :") {
                orderID = result.message.replacingOccurrences(of: "placed an order in your shop, Order Id :", with: "")
                content = "\(getLanguage["placed_an_order_in_your_shop"] ?? "") \(orderID)"
            }
            else if result.message.contains("made a purchase on your item") {
                content = "\(getLanguage["made a purchase on your item"] ?? "") \(orderID)"
            }
            else {
                content = result.message
            }
            if result.itemTitle != "Json Error" {
                content = "\(content) \(result.itemTitle.html2String)"
            }
        }
        temp = "\(username) \(content) \(message)"
        self.messageLabel.text = temp
        let string = NSMutableAttributedString(string: temp)
        string.setColorForText(username, with: UIColor(named: "NameColor") ?? .white)
        string.setColorForText(content, with: UIColor(named: "SecondaryTextColor") ?? .white)
        string.setColorForText(message, with: UIColor(named: "AppTextColor") ?? .white)
        self.messageLabel.attributedText = string
        self.amountLabel.text = amount
        if amount == "" {
            self.amountLabel.isHidden = true
        }
        else {
            self.amountLabel.isHidden = false
        }
        self.dateLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(result.eventTime ?? 0)", dateFormat: "MMM dd, YYYY")
        if result.type.lowercased() != "ADMIN".lowercased() && result.type != "adminpayment" {
            self.nextArrowImageView.isHidden = false
        }
        else {
            self.nextArrowImageView.isHidden = true
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension NSMutableAttributedString {
    func setColorForText(_ textToFind: String?, with color: UIColor) {
        let range:NSRange?
        if let text = textToFind{
            range = self.mutableString.range(of: text, options: .caseInsensitive)
        }else{
            range = NSMakeRange(0, self.length)
        }
        if range!.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range!)
        }
    }
    func setColorWithFont(_ textToFind: String?, with color: UIColor, font: UIFont) {
        let range:NSRange?
        if let text = textToFind{
            range = self.mutableString.range(of: text, options: .caseInsensitive)
        }else{
            range = NSMakeRange(0, self.length)
        }
        if range!.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range!)
            addAttribute(NSAttributedString.Key.font, value: font, range: range!)
        }
    }
    class func getAttributedString(fromString string: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string)
    }
    
    func apply(attribute: [NSAttributedString.Key: Any], subString: String)  {
        if let range = self.string.range(of: subString) {
            self.apply(attribute: attribute, onRange: NSRange(range, in: self.string))
        }
    }
    
    func apply(attribute: [NSAttributedString.Key: Any], onRange range: NSRange) {
        if range.location != NSNotFound {
            self.setAttributes(attribute, range: range)
        }
    }
    func apply(color: UIColor, subString: String) {
      
      if let range = self.string.range(of: subString) {
        self.apply(color: color, onRange: NSRange(range, in:self.string))
      }
    }
    
    // Apply color on given range
    func apply(color: UIColor, onRange: NSRange) {
      self.addAttributes([NSAttributedString.Key.foregroundColor: color],
                         range: onRange)
    }
    
}

