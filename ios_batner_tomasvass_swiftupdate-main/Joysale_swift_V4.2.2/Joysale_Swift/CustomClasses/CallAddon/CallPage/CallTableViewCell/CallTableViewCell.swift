//
//  CallTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 08/06/21.
//  Copyright © 2021 Hitasoft. All rights reserved.
//

import UIKit

class CallTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var callImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configUI() {
        self.titleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 10), align: .left, text: "")
        self.timeLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 10), align: .left, text: "")
    }
    func loadData(chatModel: ChildChatModel) {
        self.timeLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(chatModel.message.chatTime ?? 0)", dateFormat: "hh:mm a")
        if chatModel.type == "audio" {
            self.titleLabel.text = getLanguage["missed_audio_call"] ?? ""
        }
        else if chatModel.type == "video" {
            self.titleLabel.text = getLanguage["missed_video_call"] ?? ""
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
