 //
 //  ChatListTableViewCell.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 03/07/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import UIKit

 class ChatListTableViewCell: UITableViewCell {

     @IBOutlet weak var dateLabel: UILabel!
     @IBOutlet weak var messageLabel: UILabel!
     @IBOutlet weak var userNameLabel: UILabel!
     @IBOutlet weak var userImageView: UIImageView!
     
     override func awakeFromNib() {
         super.awakeFromNib()
         self.configUI()
         // Initialization code
     }
     func configUI() {
         self.userImageView.cornerViewRadius()
         self.messageLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
         self.userNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
         self.dateLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
         self.userImageView.contentMode = .scaleAspectFill
     }
     func loadData(_ chatModel: ChatListResultModel) {
         DispatchQueue.main.async { [] in
         self.userImageView.sd_setImage(with: URL(string: chatModel.userImage ?? ""), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
         if chatModel.type == "normal" {
             self.messageLabel.text = chatModel.message
         }
         else if chatModel.message.hasSuffix("gif"){
            self.messageLabel.text = getLanguage["send_an_gif"]
         }
           else {
             self.messageLabel.text = getLanguage[chatModel.type ?? ""] ?? chatModel.type.capitalized
         }
         self.userNameLabel.text = chatModel.fullName
         let dateString = Utility.shared.timeStampWithDateFormat(timeStamp: "\(chatModel.messageTime ?? 0)", dateFormat: "EEE, dd MMM yy HH:mm:ss VVVV")
         let dateFormatterGet = DateFormatter()
         dateFormatterGet.dateFormat = "EEE, dd MMM yy HH:mm:ss VVVV"
         let date = dateFormatterGet.date(from: dateString)
         if let dateVal = date {
             self.dateLabel.text = Date().offset(from: dateVal)
         }
         if chatModel.lastRepliedto == "0" || chatModel.lastRepliedto != "\(UserDefaultModule.shared.getUserData()?.user_id ?? "")" {
             self.messageLabel.textColor = UIColor(named: "AppTextColor")
             self.messageLabel.font = UIFont(name: APP_FONT_REGULAR, size: 15)
             self.userNameLabel.font = UIFont(name: APP_FONT_REGULAR, size: 15)
             self.userNameLabel.textColor = UIColor(named: "AppTextColor")
             self.dateLabel.textColor = UIColor(named: "AppTextColor")
         }
         else {
             self.messageLabel.textColor = UIColor(named: "BlackColorNew")
             self.userNameLabel.textColor = UIColor(named: "BlackColorNew")
             self.dateLabel.textColor = UIColor(named: "BlackColorNew")
             self.messageLabel.font = UIFont(name: APP_FONT_BOLD, size: 15)
             self.userNameLabel.font = UIFont(name: APP_FONT_BOLD, size: 15)
         }
     }
     }
     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)

         // Configure the view for the selected state
     }
     
 }

