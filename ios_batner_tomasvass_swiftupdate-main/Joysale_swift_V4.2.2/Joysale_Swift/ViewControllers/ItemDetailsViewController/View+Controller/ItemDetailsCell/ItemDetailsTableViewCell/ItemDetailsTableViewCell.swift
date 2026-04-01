 //
 //  ItemDetailsTableViewCell.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 22/06/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import UIKit
 import Cosmos

 class ItemDetailsTableViewCell: UITableViewCell {
     
     @IBOutlet weak var textView: UITextView!
     @IBOutlet weak var adButton: UIButton!
     @IBOutlet weak var commentButton: UIButton!
     @IBOutlet weak var ratingLabel: UILabel!
     @IBOutlet weak var ratingView: CosmosView!
     @IBOutlet weak var ratingStackView: UIStackView!
     @IBOutlet weak var shareStackView: UIStackView!
     @IBOutlet weak var commentLabel: UILabel!
     @IBOutlet weak var likeLabel: UILabel!
     @IBOutlet weak var viewLabel: UILabel!
     @IBOutlet weak var itemDetailsStackView: UIStackView!
     @IBOutlet weak var dateLabel: UILabel!
     @IBOutlet weak var productConditionButton: UIButton!
     @IBOutlet weak var priceLabel: UILabel!
     @IBOutlet weak var itemNameLabel: UILabel!
     @IBOutlet weak var detailsDescriptionStackView: UIStackView!
     
     @IBOutlet weak var detailsValueLabel: UILabel!
     @IBOutlet weak var detailsTitleLabel: UILabel!
     @IBOutlet weak var moreButton: UIButton!
     @IBOutlet weak var whatsappButton: UIButton!
     @IBOutlet weak var twitterButton: UIButton!
     @IBOutlet weak var facebookButton: UIButton!
     @IBOutlet weak var viewLikeCommentStackView: UIStackView!
     
     // item Description
     var item_description = ""
     
     override func awakeFromNib() {
         super.awakeFromNib()
         self.configUI()
         // Initialization code
     }
     func configUI() {
         self.ratingStackView.isHidden = true
         self.itemDetailsStackView.isHidden = true
         self.viewLikeCommentStackView.isHidden = true
         self.detailsDescriptionStackView.isHidden = true
         self.adButton.cornerMiniumRadius(2)
         
         self.adButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "")
         self.itemNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 22), align: .left, text: "")
         self.priceLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_BOLD, size: 18), align: .left, text: "")
         self.dateLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
       //  self.descriptionLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
         self.textView.config(color: UIColor(named: "AppTextColor") ?? .black, font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")

         self.productConditionButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, title: "")
         self.productConditionButton.cornerMiniumRadius()
         self.detailsTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
         self.detailsValueLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
         self.viewLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "views")
         self.commentLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "likes")
         self.likeLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "comments")
         
     }
     
     func loadData(index: IndexPath, item: ItemModel) {
         self.itemDetailsStackView.isHidden = true
         self.viewLikeCommentStackView.isHidden = true
         self.detailsDescriptionStackView.isHidden = true
        // self.descriptionLabel.isHidden = true
         self.textView.isHidden = true
         self.adButton.isHidden = true
         if index.section == 0 {
             self.itemDetailsStackView.isHidden = false
             self.itemNameLabel.text = item.itemTitle
  
             if Float(item.price ?? "0") != 0 {
                 self.priceLabel.text = item.formattedPrice
             }
             else {
                 self.priceLabel.text = getLanguage["giving_away"]
             }
             let dateString = Utility.shared.timeStampWithDateFormat(timeStamp: "\(item.postedTime ?? 0)", dateFormat: "EEE, dd MMM yy HH:mm:ss VVVV")
             let dateFormatterGet = DateFormatter()
             dateFormatterGet.dateFormat = "EEE, dd MMM yy HH:mm:ss VVVV"
             let date = dateFormatterGet.date(from: dateString)
             if let dateVal = date {
                 self.dateLabel.text = Date().offset(from: dateVal)
             }
             if item.itemCondition != "" {
                 self.productConditionButton.setTitle((getLanguage[item.itemCondition] ?? item.itemCondition), for: .normal)
                 self.productConditionButton.isHidden = false
             }
             else {
                 self.productConditionButton.isHidden = true
             }
             if item.itemStatus == "onsale" {
                 if item.promotionType != "Normal" && PROMOTION_FLAG {
                     self.adButton.setTitle(item.promotionType, for: .normal)
                     if item.promotionType == "Urgent" {
                         self.adButton.setTitle(getLanguage["urgent"] ?? "", for: .normal)
                         self.adButton.isHidden = false
                         self.adButton.backgroundColor = UIColor(named: "UrgentColor")
                     }
                     else if item.promotionType == "Ad" {
                         self.adButton.isHidden = false
                         self.adButton.setTitle(getLanguage["ad"] ?? "", for: .normal)
                         self.adButton.backgroundColor = UIColor(named: "NameColor")
                     }
                 }
                 else {
                     self.adButton.isHidden = true
                 }
             }
             else if item.itemStatus == "sold" {
                 self.adButton.isHidden = false
                 self.adButton.setTitle(getLanguage["sold"] ?? "", for: .normal)
                 self.adButton.backgroundColor = UIColor(named: "soldOutColor")
             }else{
                self.adButton.isHidden = true
             }
         }
         else if index.section == 1 {
              self.detailsDescriptionStackView.isHidden = false
                  self.detailsValueLabel.isHidden = false
                self.detailsTitleLabel.isHidden = false
              if item.filters[index.row].value != ""  && item.filters[index.row].value != " • "{
                self.detailsTitleLabel.text = item.filters[index.row].parentLabel
                self.detailsValueLabel.text = item.filters[index.row].value
            }
             else{
                self.detailsValueLabel.isHidden = true
                self.detailsTitleLabel.isHidden = true
            }
            }
         else if index.section == 2 {
            // self.descriptionLabel.isHidden = false
             self.textView.isHidden = false
             self.item_description = item.itemDescription
                 //.replacingOccurrences(of: "\n", with: "<br>")
              self.item_description = self.item_description.html2String
             self.loadItemDescription()
            // self.descriptionLabel.isUserInteractionEnabled = true
             self.textView.isUserInteractionEnabled = true
            // self.descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.descTapAct(_:))))
         }
         else {
             self.viewLikeCommentStackView.isHidden = false
             self.viewLabel.text = "\(item.viewsCount ?? 0) \((getLanguage["views"] ?? ""))"
             self.likeLabel.text = "\(item.likesCount ?? 0) \(getLanguage["likes"] ?? "")"
             self.commentLabel.text = "\(Int(item.commentsCount) ?? 0) \((getLanguage["comments"] ?? ""))"
         }
     }
     @objc func descTapAct(_ gesture: UITapGestureRecognizer) {
 //        let text = descriptionLabel.text!
 //
 //        let read_more = (text as NSString).range(of: "\(getLanguage["read_more"] ?? "")")
 //        let read_less = (text as NSString).range(of: "\(getLanguage["read_less"] ?? "")")
 //        if gesture.didTapAttributedTextInLabel(label: self.descriptionLabel, inRange: read_more) || gesture.didTapAttributedTextInLabel(label: self.descriptionLabel, inRange: read_less){
            // self.descriptionLabel.tag = self.descriptionLabel.tag == 0 ? 1 : 0
             self.loadItemDescription()
 //        }
     }
     func loadItemDescription() {
        self.textView.text = self.item_description
        self.textView.dataDetectorTypes = .link
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor.blue ]
 
      //      }
     //    self.tableView?.beginUpdates()
     //    self.tableView?.endUpdates()
     }
     func loadBuyNowData(_ item: ItemModel) {
         self.itemDetailsStackView.isHidden = true
         self.viewLikeCommentStackView.isHidden = true
         self.detailsDescriptionStackView.isHidden = true
        // self.descriptionLabel.isHidden = true
         self.textView.isHidden = true
         self.itemDetailsStackView.isHidden = false
         self.shareStackView.isHidden = true
         self.productConditionButton.isHidden = true
         self.dateLabel.isHidden = true
         self.itemNameLabel.text = item.itemTitle
         if Float(item.price ?? "0") != 0 {
             self.priceLabel.text = item.formattedPrice
         }
         else {
             self.priceLabel.text = getLanguage["giving_away"]
         }
     }
     func loadBuyNowDataVideo(_ item: StoryListModel) {
         self.itemDetailsStackView.isHidden = true
         self.viewLikeCommentStackView.isHidden = true
         self.detailsDescriptionStackView.isHidden = true
        // self.descriptionLabel.isHidden = true
         self.textView.isHidden = true
         self.itemDetailsStackView.isHidden = false
         self.shareStackView.isHidden = true
         self.productConditionButton.isHidden = true
         self.dateLabel.isHidden = true
         self.itemNameLabel.text = item.itemTitle
         if Float(item.price ?? "0") != 0 {
             self.priceLabel.text = item.formattedPrice
         }
         else {
             self.priceLabel.text = getLanguage["giving_away"]
         }
     }
   
     func loadOrderData(_ item: MyOrderResultModel, viewType: Int) {
         self.itemDetailsStackView.isHidden = true
         self.viewLikeCommentStackView.isHidden = true
         self.detailsDescriptionStackView.isHidden = true
         self.textView.isHidden = true
         self.itemDetailsStackView.isHidden = false
         self.shareStackView.isHidden = true
         self.productConditionButton.isHidden = false
         self.dateLabel.isHidden = true
         self.itemNameLabel.text = item.orderitems.itemname
         
         if (Float(item.orderitems.price) ?? 0) != 0 {
             self.priceLabel.text = item.orderitems.formattedPrice
         }
         else {
             self.priceLabel.text = getLanguage["giving_away"]
         }

         if item.status == "cancelled" {
             self.productConditionButton.setTitle(getLanguage["Order Canceled"] ?? item.status, for: .normal)
             self.productConditionButton.setBackgroundColor(color: UIColor(named: "redcolor") ?? .white, forState: .normal)
         }
         else if item.status == "pending" {
             self.productConditionButton.setTitle(getLanguage["Pending"] ?? item.status, for: .normal)
             self.productConditionButton.backgroundColor = UIColor(named: "appblackcolorNew")
         }
         else if item.status == "processing" {
             self.productConditionButton.setTitle(getLanguage["Under Processing"] ?? item.status, for: .normal)
             self.productConditionButton.setBackgroundColor(color: UIColor(named: "appblackcolorNew") ?? .white, forState: .normal)
         }
         else if item.status == "delivered" {
             self.productConditionButton.setTitle(getLanguage["Item delivered"] ?? item.status, for: .normal)
             self.productConditionButton.setBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .white, forState: .normal)
         }
         else if item.status == "claimed" {
             self.productConditionButton.setTitle(getLanguage["Claimed"] ?? item.status, for: .normal)
             self.productConditionButton.setBackgroundColor(color: UIColor(named: "appblackcolorNew") ?? .white, forState: .normal)
         }
         else if item.status == "paid" {
             self.productConditionButton.setTitle(getLanguage["Paid"] ?? item.status, for: .normal)
             self.productConditionButton.setBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .white, forState: .normal)
         }
         else if item.status == "shipped" {
             self.productConditionButton.setTitle(getLanguage["Item shipped"] ?? item.status, for: .normal)
             self.productConditionButton.setBackgroundColor(color: UIColor(named: "soldOutColor") ?? .white, forState: .normal)
         }
     }
  
     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)
         // Configure the view for the selected state
     }
 }

 extension UITapGestureRecognizer {

     func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
         // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
         let layoutManager = NSLayoutManager()
         let textContainer = NSTextContainer(size: CGSize.zero)
         let textStorage = NSTextStorage(attributedString: label.attributedText!)

         // Configure layoutManager and textStorage
         layoutManager.addTextContainer(textContainer)
         textStorage.addLayoutManager(layoutManager)

         // Configure textContainer
         textContainer.lineFragmentPadding = 0.0
         textContainer.lineBreakMode = label.lineBreakMode
         textContainer.maximumNumberOfLines = label.numberOfLines
         let labelSize = label.bounds.size
         textContainer.size = labelSize

         // Find the tapped character location and compare it to the specified range
         let locationOfTouchInLabel = self.location(in: label)
         let textBoundingBox = layoutManager.usedRect(for: textContainer)
         let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
         let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
         let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
         return NSLocationInRange(indexOfCharacter, targetRange)
     }

 }
 extension NSMutableAttributedString {

     public func setAsLink(textToFind:String, linkURL:String) -> Bool {

         let foundRange = self.mutableString.range(of: textToFind)
         if foundRange.location != NSNotFound {
             self.addAttribute(.link, value: linkURL, range: foundRange)
             return true
         }
         return false
     }
 }

