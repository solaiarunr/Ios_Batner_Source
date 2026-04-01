//
//  CommentTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 30/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
        self.profileImageView.cornerViewRadius()
        self.userNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.messageLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.dateLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .left, text: "")
        self.moreButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .right, title: "delete")
    }
    func loadData(_ commentData: CommentSubModel) {
        self.profileImageView.sd_setImage(with: URL(string: commentData.userImg ?? ""), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.userNameLabel.text = commentData.userName
        self.messageLabel.text = commentData.comment
        let dateString = Utility.shared.timeStampWithDateFormat(timeStamp: "\(commentData.commentTime ?? 0)", dateFormat: "EEE, dd MMM yy HH:mm:ss VVVV")
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEE, dd MMM yy HH:mm:ss VVVV"
        let date = dateFormatterGet.date(from: dateString)
        if let dateVal = date {
            self.dateLabel.text = Date().offset(from: dateVal)
        }
        if "\(commentData.userId ?? 0)" == "\(UserDefaultModule.shared.getUserData()?.user_id ?? "")" {
            self.moreButton.isHidden = false
        }
        else {
            self.moreButton.isHidden = true
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
