//
//  ThemeTableViewCell.swift
//  Joyshorts
//
//  Created by Vijai MacBook Pro on 04/05/23.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var wholeView: UIView!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var tickIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.themeLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.tickIcon.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
