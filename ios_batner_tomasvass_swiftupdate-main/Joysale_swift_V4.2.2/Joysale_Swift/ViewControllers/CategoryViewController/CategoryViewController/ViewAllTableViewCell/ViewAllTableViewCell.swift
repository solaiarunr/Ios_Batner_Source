//
//  ViewAllTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 30/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class ViewAllTableViewCell: UITableViewCell {

    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var viewAllButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI()
    {
        self.viewAllButton.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_BOLD, size: 16), align: .left, title: "view_all")
        self.viewAllButton.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
