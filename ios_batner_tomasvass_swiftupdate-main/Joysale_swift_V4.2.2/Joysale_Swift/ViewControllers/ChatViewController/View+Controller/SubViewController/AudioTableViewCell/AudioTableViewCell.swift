//
//  AudioTableViewCell.swift`
//  Joysale_Swift
//
//  Created by Hitasoft on 18/08/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class AudioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var durationLbl: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var leftImageView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.loader.isHidden = true
        self.durationLbl.config(color: UIColor(named: "ThirdryTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .right, text: "")
        self.timeLabel.config(color: UIColor(named: "ThirdryTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.durationLbl.text = "00.00"
        self.containerView.cornerViewMiniumRadius()
        playBtn.setImage(#imageLiteral(resourceName: "play-button").imageFlippedForRightToLeftLayoutDirection(), for: UIControl.State.normal)
        playBtn.tintColor = UIColor(named: "AppTextColor")
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    func loadData(chatModel: ChildChatModel)  {
        self.timeLabel.text = Utility.shared.timeStampWithDateFormat(timeStamp: "\(chatModel.message.chatTime ?? 0)", dateFormat: "hh:mm a")
        self.leftView.isHidden = true
        self.rightView.isHidden = true
        if chatModel.sender == (UserDefaultModule.shared.getUserData()?.userName ?? ""){//sender
//            durationLbl.textColor = UIColor.black
            self.containerView.backgroundColor = UIColor(named: "declineColor") ?? .white
            self.rightImageView.tintColor = UIColor(named: "declineColor")
            self.wholeStackView.alignment = .trailing
          
            self.rightView.isHidden = false
            self.progressSlider.setThumbImage(UIImage(named:"dry-clean"), for: .normal)
            self.progressSlider.setThumbImage(UIImage(named:"dry-clean"), for: .highlighted)
        }
        else{//receiver
            self.progressSlider.setThumbImage(UIImage(named:"dry-clean-2"), for: .normal)
            self.progressSlider.setThumbImage(UIImage(named:"dry-clean-2"), for: .highlighted)
            self.containerView.backgroundColor = UIColor(named: "whitecolor") ?? .white
            self.leftImageView.tintColor = UIColor(named: "whitecolor")
//            durationLbl.textColor = UIColor.black
            self.wholeStackView.alignment = .leading
            self.leftView.isHidden = false
        }
        self.checkDownload()
    }
    func checkDownload() {
        if let buttonTitle = self.playBtn.title(for: .normal) {
            let wavtomp = buttonTitle.replacingOccurrences(of: " ", with: "")
            print("wavtomp is =======",wavtomp)
            self.checkFile(wavtomp)
        }
    }
    func checkFile(_ audioString:String) {
        if let url = URL.init(string:audioString){
            // if let audioUrl = URL(string: "http://freetone.org/ring/stan/iPhone_5-Alarm.mp3") {
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
            // Print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                self.playBtn.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
                // Print("The file already exists at path")
                // if the file doesn't exist
            } else {
                self.playBtn.setImage(#imageLiteral(resourceName: "download"), for: .normal)
            }
        }
        else {
            self.playBtn.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)

        }
    }
}
 
 
