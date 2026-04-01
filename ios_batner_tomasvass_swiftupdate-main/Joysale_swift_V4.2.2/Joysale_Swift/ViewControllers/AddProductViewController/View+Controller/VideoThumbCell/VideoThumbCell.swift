//
//  VideoThumbCell.swift
//  Joyshorts_Swift
//
//  Created by HTS on 30/12/22.
//

import UIKit

class VideoThumbCell: UITableViewCell {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var FullView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var changeBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }

    func configUI(){
        self.titleLbl.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "cover_image")
        self.changeBtn.config(color: UIColor.init(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .right, title: "change")
        self.ImageView.layer.cornerRadius = 4
        self.ImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
