 //
 //  ChatSubTableViewCell.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 01/07/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import UIKit
 import GoogleMaps
 import GooglePlaces
 import MapboxStatic
import  MapboxMaps
 class ChatSubTableViewCell: UITableViewCell {

    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var buyNowButton: UIButton!
     @IBOutlet weak var acceptDeclineView: UIView!
     @IBOutlet weak var titleConst: NSLayoutConstraint!
     @IBOutlet weak var offerStatusLabel: UILabel!
     @IBOutlet weak var offerStatusStackView: UIStackView!
     @IBOutlet weak var widthConst: NSLayoutConstraint!
     @IBOutlet weak var offerImageView: UIImageView!
     @IBOutlet weak var declineButton: UIButton!
     @IBOutlet weak var acceptButton: UIButton!
     @IBOutlet weak var timeView: UIView!
     @IBOutlet weak var rightImageView: UIImageView!
     @IBOutlet weak var leftImageView: UIImageView!
     @IBOutlet weak var imageTimeLabel: UILabel!
     @IBOutlet weak var imageChatView: UIView!
     @IBOutlet weak var textStackView: UIStackView!
     @IBOutlet weak var chatImageView: UIImageView!
     @IBOutlet weak var timeLabel: UILabel!
     @IBOutlet weak var dateLabel: UILabel!
     @IBOutlet weak var messageLabel: UILabel!
     @IBOutlet weak var priceButton: UIButton!
     @IBOutlet weak var listImageView: UIImageView!
     @IBOutlet weak var titleLabel: UILabel!
     @IBOutlet weak var chatView: UIView!
     @IBOutlet weak var rightView: UIView!
     @IBOutlet weak var leftView: UIView!
     @IBOutlet weak var wholeStackView: UIStackView!
    var refreshChat: (() -> Void)?
    var viewModel: ChatListModel?
     override func awakeFromNib() {
         super.awakeFromNib()
         // Initialization code
     }
     func configUI() {

         self.titleConst.priority = .defaultLow
         self.acceptDeclineView.isHidden = true
         self.titleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
         self.offerStatusLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")

         self.messageLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
         self.priceButton.config(color: UIColor(named: "NameColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "")
         self.buyNowButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "instantbuy")
         self.buyNowButton.isHidden = true
         self.buyNowButton.cornerMiniumRadius()
         self.buyNowButton.backgroundColor = UIColor(named: "NameColor")

         self.chatImageView.cornerViewMiniumRadius()
         self.priceButton.cornerMiniumRadius()
//         self.priceButton.backgroundColor = UIColor(named: "whitecolor")
         self.listImageView.cornerViewMiniumRadius()
         self.dateLabel.config(color: UIColor(named: "ThirdryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .right, text: "")
         self.timeLabel.config(color: UIColor(named: "ThirdryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
         self.imageTimeLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
         self.acceptButton.config(color: UIColor(named: "NameColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "accept")
         self.declineButton.config(color: UIColor(named: "BlackTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "decline")
//         self.declineButton.config(color: UIColor(named: "AppTextColorNewforchat"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "decline")

         self.chatView.cornerViewMiniumRadius()
         self.imageChatView.cornerViewMiniumRadius()
         self.offerStatusStackView.isHidden = true
         self.imageChatView.isHidden = true
         self.chatImageView.contentMode = .scaleAspectFill
//        self.languageButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .right, title: "")
        self.languageButton.setImage(#imageLiteral(resourceName: "chat_translate-3"), for: .normal)
      }
     func loadOfferValue() {
         if self.offerStatusLabel.text?.contains("\(getLanguage["about"] ?? "")") ?? false {
             self.offerStatusLabel.textColor = UIColor(named: "AppThemeColorNew") ?? .white
             let attributedText = NSMutableAttributedString.getAttributedString(fromString: self.offerStatusLabel.text!)
             attributedText.apply(color: UIColor(named: "AppTextColor") ?? .white, subString: "\(getLanguage["about"] ?? "")")
             self.offerStatusLabel.attributedText = attributedText
         }
     }
     func loadData(chatModel: ChildChatModel) {
         self.configUI()
         self.leftView.isHidden = true
         self.rightView.isHidden = true
        self.languageButton.isHidden = true
         self.titleLabel.isHidden = true
         self.dateLabel.isHidden = false
         self.timeView.isHidden = true
         self.priceButton.isHidden = true
         self.listImageView.isHidden = true
         self.imageChatView.isHidden = true
         self.chatView.isHidden = false
         self.textStackView.isHidden = false
         self.messageLabel.text = chatModel.message.message
         self.timeLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(chatModel.message.chatTime ?? 0)", dateFormat: "hh:mm a")
         self.imageTimeLabel.text = self.timeLabel.text!
         self.listImageView.sd_setImage(with: URL(string: chatModel.itemImage ?? "")) { (image, error, cache, url) in
             if error != nil {
                 self.listImageView.image = #imageLiteral(resourceName: "applogo")
             }
         }
         if self.widthConst != nil {
             self.widthConst.isActive = true
             self.widthConst.constant = 0
         }
         self.titleConst.priority = .defaultLow
//         if chatModel.sender == (UserDefaultModule.shared.getUserData()?.userName ?? ""){
//             self.messageLabel.textColor = UIColor(named: "SecondaryTextColor")
//         }else{
             self.messageLabel.textColor = UIColor(named: "AppTextColor")
//         }
         if chatModel.type == "normal" || chatModel.type == ""{
             self.dateLabel.text = self.timeLabel.text!
         }
         if chatModel.type == "about" {
             if self.widthConst != nil {
                 self.widthConst.isActive = false
                
             }
             self.dateLabel.config(color: UIColor(named: "ThirdryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
             self.timeView.isHidden = false
             self.dateLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(chatModel.message.chatTime ?? 0)", dateFormat: "MMM dd, YYYY")
             self.offerStatusLabel.text = ""
             self.offerStatusLabel.text = "\(getLanguage["about"] ?? "") \(chatModel.itemTitle ?? "")"
             loadOfferValue()
             self.listImageView.isHidden = false
             self.titleLabel.isHidden = true
             self.offerStatusStackView.isHidden = false
             self.offerImageView.isHidden = true
            self.wholeStackView.alignment = .fill
         }
         else if chatModel.type == "offer" {
             self.offerStatusLabel.attributedText = nil
             self.titleConst.priority = .defaultHigh
             self.titleLabel.isHidden = false
             self.dateLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(chatModel.message.chatTime ?? 0)", dateFormat: "MMM dd, YYYY")
             self.listImageView.isHidden = false
             self.priceButton.isHidden = false
             self.priceButton.setTitle(chatModel.formattedOfferPrice, for: .normal)
             self.titleLabel.text = "   \(getLanguage["send_offer_req"] ?? "")  \(chatModel.itemTitle ?? "")"

             if chatModel.offerType == "sendreceive" {
                 self.titleLabel.textColor = UIColor(named: "whitecolor")
                 self.messageLabel.textColor = UIColor(named: "whitecolor")
                 self.dateLabel.textColor = UIColor(named: "whitecolor")

                 if chatModel.receiver == (UserDefaultModule.shared.getUserData()?.userName ?? "") && chatModel.offerStatus != 1 && chatModel.offerStatus != 2{
                     self.acceptDeclineView.isHidden = false
                 }
             }
             else if chatModel.offerType == "accept" && chatModel.offerStatus == 1 {
                 self.offerImageView.image = #imageLiteral(resourceName: "tick-green")
                 self.offerImageView.isHidden = false
                 self.offerStatusLabel.text = getLanguage["offer_accepted"]
                 if chatModel.sender == (UserDefaultModule.shared.getUserData()?.userName ?? "") && chatModel.instantBuy == 1 && chatModel.buynowStatus == 0 && BUYNOW_MODEL_FLAG {
                     self.dateLabel.config(color: UIColor(named: "ThirdryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
                     self.dateLabel.text = self.timeLabel.text!
                     self.buyNowButton.isHidden = false
                 }
             }
             else if chatModel.offerType == "decline" && chatModel.offerStatus == 2 {
                 self.offerImageView.image = #imageLiteral(resourceName: "Redclose")
                 self.offerStatusLabel.text = getLanguage["offer_declined"]
             }
         }
         else if chatModel.type == "gif" {
             self.dateLabel.text = self.timeLabel.text!
             self.imageChatView.isHidden = false
             self.chatView.isHidden = true
            self.chatImageView.contentMode = .scaleAspectFit
             self.chatImageView.sd_setImage(with: URL(string: chatModel.message.uploadImage ?? "")) { (image, error, cache, url) in
                 if error != nil {
                     self.chatImageView.image = #imageLiteral(resourceName: "applogo")
                 }
             }
         }
         else if chatModel.type == "image" {
            self.chatImageView.contentMode = .scaleAspectFill
             self.dateLabel.text = self.timeLabel.text!
             self.imageChatView.isHidden = false
             self.chatView.isHidden = true
            var imageURL = (chatModel.message.uploadImage ?? "")
            if !(chatModel.message.uploadImage ?? "").contains("http") {
                imageURL = CHAT_IMAGE_URL+imageURL
            }
             self.chatImageView.sd_setImage(with: URL(string: imageURL)) { (image, error, cache, url) in
                 if error != nil {
                     self.chatImageView.image = #imageLiteral(resourceName: "applogo")
                 }
             }
         }
         else if chatModel.type == "share_location" {
             self.dateLabel.text = self.timeLabel.text!
             self.imageChatView.isHidden = false
             self.chatView.isHidden = true

             let lat = chatModel.message.latitude ?? ""
             let lon = chatModel.message.longitude ?? ""

             let coordinates = CLLocationCoordinate2D(
                 latitude: CLLocationDegrees(lat) ?? 0,
                 longitude: CLLocationDegrees(lon) ?? 0
             )

             let camera = SnapshotCamera(lookingAtCenter: coordinates, zoomLevel: 12)

            
             guard let styleURL = URL(string: StyleURI.streets.rawValue) else {
                 print("Invalid style URL")
                 return
             }

             let options = SnapshotOptions(
                 styleURL: styleURL,
                 camera: camera,
                 size: CGSize(width: self.chatImageView.frame.width,
                              height: self.chatImageView.frame.height)
             )

             let marker = Marker(coordinate: coordinates, size: .medium, iconName: "circle")
             options.overlays = [marker]

             let snapshot = Snapshot(options: options, accessToken: MAPBOXACCESSTOKEN)
             self.chatImageView.image = snapshot.image
             self.chatImageView.contentMode = .scaleToFill
         }

         
         //solaimap
//         else if chatModel.type == "share_location" {
//            self.dateLabel.text = self.timeLabel.text!
//            self.imageChatView.isHidden = false
//            self.chatView.isHidden = true
//            let lat =  chatModel.message.latitude ?? ""
//            let lon =  chatModel.message.longitude ?? ""
//            
//            
//            let cameras = SnapshotCamera(
//                lookingAtCenter: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat) ?? 0, longitude: CLLocationDegrees(lon) ?? 0), zoomLevel: 12)
//            
//            let optioned = SnapshotOptions(styleURL: MGLStyle.streetsStyleURL, camera: cameras, size: CGSize(width: self.chatImageView.frame.width, height: self.chatImageView.frame.height))
//            let markerOverlay = Marker(
//                coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat) ?? 0, longitude: CLLocationDegrees(lon) ?? 0),
//                size: .medium,
//                iconName: "circle"
//            
//            )
//            optioned.overlays = [markerOverlay]
//            
//            let snapshots = Snapshot(options: optioned, accessToken: MAPBOXACCESSTOKEN)
//            chatImageView.image = snapshots.image
//  
////            let url = "https://maps.google.com/maps/api/staticmap?markers=color:red|\(chatModel.message.latitude ?? ""),\(chatModel.message.longitude ?? "")" + "&zoom=15&size=\(Int(self.chatImageView.frame.width))x\(Int(self.chatImageView.frame.height))&maptype=roadmap&key=\(GOOGLE_API_KEY)&sensor=false.jpg"
////            print("mapURL \(url)")
////            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
////            self.chatImageView.sd_setImage(with: URL(string: urlString)) { (image, error, cache, url) in
////                if error != nil {
////                    self.chatImageView.image = #imageLiteral(resourceName: "applogo")
////                }
////            }
//            self.chatImageView.contentMode = .scaleToFill
//            
//            
//         }
         if chatModel.type == "offer" {
             self.chatView.backgroundColor = UIColor(named: "NameColor")
             self.rightImageView.tintColor = UIColor(named: "NameColor")
             self.imageChatView.backgroundColor = UIColor(named: "NameColor")
             self.leftImageView.tintColor = UIColor(named: "NameColor")
             if (chatModel.offerStatus == 1 && chatModel.offerType == "accept") || (chatModel.offerStatus == 2 && chatModel.offerType == "decline"){
                 if self.widthConst != nil {
                     self.widthConst.isActive = true
                     self.widthConst.constant = -50
                 }
                 
                 self.titleLabel.isHidden = true
                 self.leftImageView.tintColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
                 self.chatView.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
                 self.imageChatView.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
//                 self.leftImageView.tintColor = UIColor(named: "whitecolor")
//                 self.chatView.backgroundColor = UIColor(named: "whitecolor")
//                 self.imageChatView.backgroundColor = UIColor(named: "whitecolor")
                 self.wholeStackView.alignment = .center
                 self.offerStatusStackView.isHidden = false
                 self.priceButton.isHidden = true
                 self.messageLabel.text = (self.priceButton.currentTitle ?? "")
             }
             else if chatModel.sender == (UserDefaultModule.shared.getUserData()?.userName ?? "") {
                 self.wholeStackView.alignment = .trailing
                 self.rightView.isHidden = false
                self.languageButton.isHidden = true
             }
             else {
                 self.wholeStackView.alignment = .leading
                 self.leftView.isHidden = false
                 self.languageButton.isHidden = false
             }
         }
         else if chatModel.sender == (UserDefaultModule.shared.getUserData()?.userName ?? "") && chatModel.type != "about" {
             self.wholeStackView.alignment = .trailing
             self.rightView.isHidden = false
            self.languageButton.isHidden = true
              self.chatView.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
             self.rightImageView.tintColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
             self.imageChatView.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
//              self.chatView.backgroundColor = UIColor(named: "declineColor")
//             self.rightImageView.tintColor = UIColor(named: "declineColor")
//             self.imageChatView.backgroundColor = UIColor(named: "declineColor")
         }
         else if chatModel.type != "about" {
             self.leftView.isHidden = false
             self.leftImageView.tintColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
//             self.leftImageView.tintColor = UIColor(named: "whitecolor")
            self.languageButton.isHidden = false
             self.chatView.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
//             self.chatView.backgroundColor = UIColor(named: "whitecolor")
             self.imageChatView.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
//             self.imageChatView.backgroundColor = UIColor(named: "whitecolor")
             self.wholeStackView.alignment = .leading
         }
         else if chatModel.sender != (UserDefaultModule.shared.getUserData()?.userName ?? "") && chatModel.type == "about" {
            self.languageButton.isHidden = false
             self.chatView.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
//            self.chatView.backgroundColor = UIColor(named: "whitecolor")
            self.wholeStackView.alignment = .fill
         }
         else {
             self.chatView.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
//             self.chatView.backgroundColor = UIColor(named: "whitecolor")
             self.wholeStackView.alignment = .fill
         }
     }
    
    @IBAction func languageButtonAct(_ sender: UIButton) {
        /*
        print("ChatTranslationTapped")
        SwiftGoogleTranslate.shared.translate(msg: self.messageLabel.text ?? "", callback: { translatedTxt in
            DispatchQueue.main.async {
                print("instanttranslatedtext \(translatedTxt)")
                self.messageLabel.text = translatedTxt
                self.refreshChat!()
            }
        })
         */
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)

         // Configure the view for the selected state
     }
 }

