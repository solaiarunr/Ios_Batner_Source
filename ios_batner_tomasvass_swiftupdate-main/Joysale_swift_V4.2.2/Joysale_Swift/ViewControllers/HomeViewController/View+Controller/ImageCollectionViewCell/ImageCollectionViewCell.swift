//
//  ImageCollectionViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 12/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var Durationlbl: UILabel!
    
    @IBOutlet weak var PlayBackImg: UIImageView!
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear]
        gradient.startPoint = CGPoint(x: 0.3, y: 1)
        gradient.endPoint = CGPoint(x: 0.3, y: 0)
        return gradient
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
//        self.statusButton.cornerMiniumRadius(2)
        self.shadowView.cornerViewMiniumRadiuslight()
        self.priceLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_BOLD, size: 14), align: .left, text: "")
        self.productTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.locationLabel.config(color: UIColor(named: "ThirdryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "")
//        self.statusButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .center, title: "")
        self.dateButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .right, title: "")
        self.Durationlbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
    }
    func convertToExtendedTimeFormat(_ durationString: String?) -> String {
        guard let durationString = durationString,
              let durationMs = Double(durationString),
              durationMs > 0 else {
            return "00:00"
        }

        let totalSeconds = Int(durationMs / 1000)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    func loadData(_ itemData: ItemModel) {
        if itemData.product_type  == "video"{
            self.PlayBackImg.isHidden = false
            self.Durationlbl.isHidden = false
            if let thumbPath = itemData.stream_thumb, !thumbPath.isEmpty {


                if let thumbURL = URL(string: thumbPath) {
                    self.profileImageView.sd_setImage(with: thumbURL, placeholderImage: UIImage(named: "product_placeholder_video")) { [weak self] image, error, _, _ in
                        guard let self = self else { return }
                        if let image = image, image.size.width > 0 {
                            // ✅ Image loaded successfully
                            // Reload tableView/cell here if needed
                        } else {
                            print("❌ Failed to load image:", error?.localizedDescription ?? "Unknown error")
                        }
                    }
                } else {
//                    print("❌ Invalid URL: \(thumbURLString)")
                }
            } else {
                print("❌ Missing or empty stream_thumb")
                self.profileImageView.image = UIImage(named: "product_placeholder_video")
            }
        }else{
            if itemData.photos.count > 0 {
                self.profileImageView.sd_setImage(with: URL(string: itemData.photos?.first?.itemUrlMain350 ?? ""), placeholderImage: nil , completed: nil)
            }
            else {
                self.profileImageView.image = #imageLiteral(resourceName: "profilelogo")
            }
            self.PlayBackImg.isHidden = true
            self.Durationlbl.isHidden = true
        }
        let formattedtime = convertToExtendedTimeFormat(itemData.playback_duration)
        self.Durationlbl.text = formattedtime
 

        if itemData.itemStatus == "onsale" {
            if itemData.promotionType != "Normal" && PROMOTION_FLAG {
                self.statusButton.isHidden = false
//                self.statusButton.setTitle(itemData.promotionType, for: .normal)
                if itemData.promotionType == "Urgent" {
                    self.statusButton.setBackgroundImage(UIImage(named: "Urgentimg"), for: .normal)
                    self.statusButton.setTitle(getLanguage[""] ?? "", for: .normal)
                }
                else if itemData.promotionType == "Ad" {
                    self.statusButton.setBackgroundImage(UIImage(named: "adimg"), for: .normal)
                    self.statusButton.setTitle(getLanguage[""] ?? "", for: .normal)
                }
            }
            else {
                self.statusButton.setBackgroundImage(UIImage(named: ""), for: .normal)
                self.statusButton.isHidden = true
                self.statusButton.setTitle("", for: .normal)
            }
        }
        else if itemData.itemStatus == "sold" {
            self.statusButton.setTitle(getLanguage["sold"] ?? "", for: .normal)
            self.statusButton.setBackgroundColor(color: UIColor(named: "soldOutColor") ?? .white, forState: .normal)
        }
        if Float(itemData.price ?? "0") != 0 {
            self.priceLabel.text = itemData.formattedPrice
            self.priceLabel.textColor = UIColor(named: "AppTextColor") ?? .white
        }
        else {
            self.priceLabel.text = getLanguage["giving_away"]
            self.priceLabel.textColor = UIColor(named: "AppThemeColorNew") ?? .white
        }
        let dateString = Utility.shared.timeStampWithDateFormat(timeStamp: "\(itemData.postedTime ?? 0)", dateFormat: "EEE, dd MMM yy HH:mm:ss VVVV")
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEE, dd MMM yy HH:mm:ss VVVV"
        let date = dateFormatterGet.date(from: dateString)
        if let dateVal = date {
            self.dateButton.setTitle(Date().offset(from: dateVal), for: .normal)
        }
//        self.priceLabel.sizeToFit()
        self.productTitleLabel.text = itemData.itemTitle
        self.locationLabel.text = itemData.location
        self.imageViewHeightConst.constant = self.frame.width
        self.dateButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    override func layoutSubviews() {
        self.imageViewHeightConst.constant = self.frame.width
        self.dateButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.dateButton.bounds.width, height: self.dateButton.bounds.height)
    }
}
