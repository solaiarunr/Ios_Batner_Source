//
//  SmartReplyCollectionViewCell.swift
//  Meetdoc
//
//  Created by Hitasoft on 25/01/21.
//  Copyright © 2021 BTMani. All rights reserved.
//

import UIKit

class SmartReplyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var smartReplyLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.smartReplyLabel.config(color: UIColor(named: "AppThemeColorNew"), font: REGULAR_FONT, align: .center, text: "")
     }
    override func layoutSubviews() {
        self.shadowView.setViewMinBorder(color: UIColor(named: "AppThemeColorNew") ?? .black)
    }
}
