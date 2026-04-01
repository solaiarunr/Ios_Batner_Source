//
//  HelpTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 04/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class HelpTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.textLabel?.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
