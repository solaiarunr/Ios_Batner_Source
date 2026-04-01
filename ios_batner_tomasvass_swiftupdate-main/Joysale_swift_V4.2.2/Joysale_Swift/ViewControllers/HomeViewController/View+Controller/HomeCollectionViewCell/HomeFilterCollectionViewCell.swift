//
//  HomeFilterCollectionViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 15/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class HomeFilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    var isFromChat = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.filterLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "")
        self.cancelButton.cornerRoundRadius()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
//        self.hightConst.constant = 30
        self.shadowView.cornerViewRadius()
    }
    override func layoutSubviews() {
//        if isFromChat {
//            self.shadowView.cornerViewMiniumRadius()
//        }
//        else {
//            self.shadowView.cornerViewRadius()
//        }
    }
}
