//
//  ExchangeCollectionViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 29/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Lottie

class ExchangeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var exchangeImageView: UIImageView!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var DurationLbl: UILabel!
    @IBOutlet weak var Playbackbtn: UIImageView!
    @IBOutlet weak var processingAnimationView: LottieAnimationView!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var processingView: UIView!
    let colorTop =  UIColor().hexValue(hex: "#FFFFFF")
    let colorBottom =  UIColor().hexValue(hex: "#808080")
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
    override func layoutSubviews() {
        self.processingView.addGradientBackground(firstColor: colorTop, secondColor: colorBottom)
//        self.GradientView.addGradientBackground(firstColor: topColor, secondColor: bottomColor)
    }
    func configUI() {
        self.buttonStackView.isHidden = true
        self.selectedView.isHidden = true
        self.processingView.addGradientBackground(firstColor: colorTop, secondColor: colorBottom)
//        self.statusButton.cornerMiniumRadius(2)
//        self.statusButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .center, title: "")
        self.dateButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .right, title: "")
        self.DurationLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.dateButton.layer.insertSublayer(gradientLayer, at: 0)
        self.processingAnimationView.backgroundColor = .clear
        self.processingAnimationView.loopMode = .loop
        self.processingAnimationView.play{ (finished) in
        }
        self.processingView.isHidden = true
        self.processingLabel.config(color: UIColor.white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "optimize")
    }
    func loadData(_ item: ItemModel) {
        if item.product_type  == "video"{
            self.Playbackbtn.isHidden = false
        }else{
            self.Playbackbtn.isHidden = true
        }
        self.processingAnimationView.play{ (finished) in
        }
        self.exchangeImageView.sd_setImage(with: URL(string: item.photos?.first?.itemUrlMain350 ?? "")) { (image, error, cache, url) in
            if error != nil {
                self.exchangeImageView.image = #imageLiteral(resourceName: "applogo")
            }
        }
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

    func loadListLikeData(_ itemData: ItemModel) {
//        self.exchangeImageView.sd_cancelCurrentImageLoad()
//        self.exchangeImageView.image = nil
        
    
        if itemData.product_type  == "video"{
            if (itemData.stream_status ?? "0") == "1" {
                self.processingView.isHidden = true
            }
            else {
                self.processingView.isHidden = false
            }
            self.Playbackbtn.isHidden = false
            self.DurationLbl.isHidden = false
            if let thumbPath = itemData.stream_thumb, !thumbPath.isEmpty {
                print("📸 Thumb URL:", thumbPath)
                if let thumbURL = URL(string: thumbPath) {
                    self.exchangeImageView.sd_setImage(with: thumbURL, placeholderImage: UIImage(named: "product_placeholder_video")) { [weak self] image, error, _, _ in
                        guard let self = self else { return }
                        if let image = image, image.size.width > 0 {
                            // ✅ Image loaded successfully
                            // Reload tableView/cell here if needed
                        } else {
                            print("❌ Failed to load image:", error?.localizedDescription ?? "Unknown error")
                        }
                    }
                } else {
                    print("❌ Invalid URL: \(thumbPath)")
                }
            } else {
                print("❌ Missing or empty stream_thumb")
                self.exchangeImageView.image = UIImage(named: "product_placeholder_video")
            }


        }else{
            self.processingView.isHidden = true
            self.Playbackbtn.isHidden = true
            self.DurationLbl.isHidden = true
            self.exchangeImageView.sd_setImage(with: URL(string: itemData.photos?.first?.itemUrlMain350 ?? "")) { (image, error, cache, url) in
                if error != nil {
                    print("error?.localizedDescription \(error?.localizedDescription ?? "")")
    //                self.exchangeImageView.image = #imageLiteral(resourceName: "applogo")
                }
            }
        }
        
  
      
        let formattedtime = convertToExtendedTimeFormat(itemData.playback_duration)
        self.DurationLbl.text = formattedtime
        if itemData.itemStatus == "onsale" {
            if itemData.promotionType != "Normal" && PROMOTION_FLAG {
//                self.statusButton.setTitle(itemData.promotionType, for: .normal)
                if itemData.promotionType == "Urgent" {
                    self.statusButton.setBackgroundImage(UIImage(named: "Urgentimg"), for: .normal)
                    self.statusButton.setTitle(getLanguage[""] ?? "", for: .normal)
//                    self.statusButton.setBackgroundColor(color: UIColor(named: "UrgentColor") ?? .white, forState: .normal)
                }
                else if itemData.promotionType == "Ad" {
                    self.statusButton.setBackgroundImage(UIImage(named: "adimg"), for: .normal)
                    self.statusButton.setTitle(getLanguage[""] ?? "", for: .normal)
//                    self.statusButton.setBackgroundColor(color: UIColor(named: "NameColor") ?? .white, forState: .normal)

                }
            }
            else {
                self.statusButton.setBackgroundImage(UIImage(named: ""), for: .normal)
                self.statusButton.setTitle("", for: .normal)
                self.statusButton.setBackgroundColor(color: UIColor(named: "clearcolor") ?? .white, forState: .normal)
            }
        }
        else if itemData.itemStatus == "sold" {
            self.statusButton.setTitle(getLanguage["sold"] ?? "", for: .normal)
            self.statusButton.setBackgroundColor(color: UIColor(named: "soldOutColor") ?? .white, forState: .normal)
        }
        let dateString = Utility.shared.timeStampWithDateFormat(timeStamp: "\(itemData.postedTime ?? 0)", dateFormat: "EEE, dd MMM yy HH:mm:ss VVVV")
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEE, dd MMM yy HH:mm:ss VVVV"
        let date = dateFormatterGet.date(from: dateString)
        if let dateVal = date {
            self.dateButton.setTitle(Date().offset(from: dateVal), for: .normal)
        }
        self.dateButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.dateButton.bounds.width, height: self.dateButton.bounds.height)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.exchangeImageView.image = nil
    }
}
