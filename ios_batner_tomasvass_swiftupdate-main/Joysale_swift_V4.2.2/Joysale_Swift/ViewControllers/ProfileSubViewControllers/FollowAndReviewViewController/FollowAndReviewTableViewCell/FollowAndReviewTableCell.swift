//
//  FollowAndReviewTableCell.swift
//  Joysale_Swift
//
//  Created by MAC pro 2.9Ghz on 14/12/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Cosmos

class FollowAndReviewTableCell: UITableViewCell {
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var reviewStackView: UIStackView!
    @IBOutlet weak var reviewDescLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var reviewView: CosmosView!
    @IBOutlet weak var userNameLabel: UILabel!
    var followStatus = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.configUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configUI() {
        self.followButton.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.followButton.cornerMiniumRadius()
        self.userImageView.cornerViewRadius()
        self.userNameLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .left, text: "")
        self.descLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.reviewView.rating = 0
        self.titleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.reviewDescLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.reviewStackView.isHidden = true
        self.reviewView.isHidden = true
    }
    
    func loadData(_ followData: FollowerResultModel, follwedArray: [String]) {
        self.reviewStackView.isHidden = true
        self.reviewView.isHidden = true
        self.wholeStackView.alignment = .center
        
        self.userNameLabel.text = followData.fullName
        self.userImageView.sd_setImage(with: URL(string: followData.userImage), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.descLabel.text = followData.userName
        self.followButton.isHidden = false
        if "\(followData.userId ?? 0)"  != (UserDefaultModule.shared.getUserData()?.user_id ?? "") {
            if follwedArray.contains(where: {$0 == "\(followData.userId ?? 0)"}) {
                self.followButton.setImage(#imageLiteral(resourceName: "Follow"), for: .normal)
                self.followButton.backgroundColor = UIColor(named: "AppThemeColorNew")
                self.followButton.tintColor = UIColor(named: "whitecolor")
                self.followStatus = "follow"
            }
            else {
                self.followStatus = "unfollow"
                self.followButton.setImage(#imageLiteral(resourceName: "unFollow"), for: .normal)
                self.followButton.backgroundColor = UIColor(named: "FollwerButtonColor")
//                self.followButton.tintColor = UIColor(named: "lightWhite")
            }
        }
        else {
            self.followButton.isHidden = true
        }
    }
    
    func loadReviewData(_ reviewData: ReviewResultModel) {
        self.followButton.isHidden = true
        self.userNameLabel.text = reviewData.fullName
        self.reviewStackView.isHidden = false
        self.reviewView.isHidden = false
        self.wholeStackView.alignment = .top
        self.userImageView.sd_setImage(with: URL(string: reviewData.userImage), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.reviewView.rating = Double(reviewData.rating)
        self.descLabel.text = reviewData.itemName + " \(getLanguage["on"] ?? "on") " + Utility.shared.timeStampWithDateFormat(timeStamp: "\(reviewData.createdDate ?? 0)", dateFormat: "MMM dd, YYYY")
        self.titleLabel.text = reviewData.reviewTitle
        self.reviewDescLabel.text = reviewData.reviewDes
    }
    
    override func layoutSubviews() {
        if self.followStatus == "follow" {
            self.followButton.setImage(#imageLiteral(resourceName: "Follow"), for: .normal)
            self.followButton.backgroundColor = UIColor(named: "AppThemeColorNew")
            self.followButton.tintColor = UIColor(named: "whitecolor")
        }
        else {
            self.followButton.setImage(#imageLiteral(resourceName: "unFollow"), for: .normal)
            self.followButton.backgroundColor = UIColor(named: "FollwerButtonColor")
            self.followButton.tintColor = UIColor(named: "lightWhite")
        }
    }
}
