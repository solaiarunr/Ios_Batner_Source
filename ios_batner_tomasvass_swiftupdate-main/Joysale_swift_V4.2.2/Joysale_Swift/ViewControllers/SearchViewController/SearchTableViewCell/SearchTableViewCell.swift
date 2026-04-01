//
//  SearchTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 15/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var searchStackView: UIStackView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchImageView: UIImageView!
    var viewType = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.searchLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .left, text: "")
    }
    func loadCategoryData(_ name: String) {
        self.searchLabel.text = name
        self.searchImageView.image = nil
        self.searchStackView.spacing = 0
        self.viewType = 1
    }
    override func layoutSubviews() {
        if self.viewType == 1 {
            self.backgroundColor = UIColor(named: "whitecolor")
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
