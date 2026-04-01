//
//  MyExchangeTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 03/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class MyExchangeTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var myProductImageView: UIImageView!
    @IBOutlet weak var exchangeStatusButton: UIButton!
    @IBOutlet weak var exchangerImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.userImageView.contentMode = .scaleAspectFill
        self.myProductImageView.contentMode = .scaleAspectFill
        self.exchangerImageView.contentMode = .scaleAspectFill
        
        self.userImageView.cornerViewRadius()
        self.myProductImageView.cornerViewRadius()
        self.exchangerImageView.cornerViewRadius()
        self.userNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .left, text: "")
        self.dateLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.exchangeStatusButton.cornerMiniumRadius()
        self.exchangeStatusButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "")
        self.exchangeStatusButton.backgroundColor = UIColor(named: "AppThemeColorNew")
    }
    func loadData(_ exchangeData: ExchangeListModel) {
        self.userNameLabel.text = exchangeData.exchangerName
        self.userImageView.sd_setImage(with: URL(string: exchangeData.exchangerImage), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.dateLabel.text = exchangeData.exchangeTime
        self.myProductImageView.sd_setImage(with: URL(string: exchangeData.myProduct.itemImage), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.exchangerImageView.sd_setImage(with: URL(string: exchangeData.exchangeProduct.itemImage), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.exchangeStatusButton.setTitle(getLanguage[exchangeData.status.lowercased()], for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
