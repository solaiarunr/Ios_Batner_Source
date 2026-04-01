//
//  FilterHeaderTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 13/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class FilterHeaderTableViewCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var viewTopConst: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var overAllView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    var viewType = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.lineView.isHidden = true
        self.headerLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .left, text: "")
    }
//    override func layoutSubviews() {
//        if self.viewType == 1 {
//            self.overAllView.backgroundColor = UIColor(named: "whitecolor")
//        }
//        else {
//            self.overAllView.backgroundColor = UIColor(named: "clearcolor")
//        }
//    }
    
}
