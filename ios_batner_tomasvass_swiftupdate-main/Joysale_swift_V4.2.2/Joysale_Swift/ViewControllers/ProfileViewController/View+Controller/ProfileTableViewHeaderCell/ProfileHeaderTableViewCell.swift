//
//  ProfileHeaderTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Cosmos

class ProfileHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewStackView: UIStackView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.profileImageview.cornerViewRadius()
        self.userNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_BOLD, size: 20), align: .left, text: "username")
        self.ratingLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "5")
    }
    func loadData(_ profileResult: ProfileResultModel?) {
        self.profileImageview.sd_setImage(with: URL(string: (profileResult?.userImg ?? "")), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.userNameLabel.text = profileResult?.fullName
        self.ratingView.rating = Double(profileResult?.rating ?? "0") ?? Double(0)
        self.ratingLabel.text = "(\(profileResult?.ratingUserCount ?? "0"))"
        self.reviewStackView.isHidden = !BUYNOW_MODEL_FLAG
    }
}
