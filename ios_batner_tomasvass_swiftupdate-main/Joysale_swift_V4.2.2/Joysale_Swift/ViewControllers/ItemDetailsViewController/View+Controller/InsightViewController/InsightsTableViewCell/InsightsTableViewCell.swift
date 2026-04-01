//
//  InsightsTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 31/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class InsightsTableViewCell: UITableViewCell {

    @IBOutlet weak var subStackView: UIStackView!
    @IBOutlet weak var engageMentImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var engagementDescLabel: UILabel!
    @IBOutlet weak var engagementTitleLabel: UILabel!
    @IBOutlet weak var totalDescLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var uniqueDescLabel: UILabel!
    @IBOutlet weak var uniqueLabel: UILabel!
    @IBOutlet weak var engagementSubStackView: UIStackView!
    @IBOutlet weak var engagementStackView: UIStackView!
    @IBOutlet weak var viewStackView: UIStackView!
    @IBOutlet weak var popularButton: UIButton!
    @IBOutlet weak var popularLabel: UILabel!
    @IBOutlet weak var popularView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
//        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 8)
        progressBar.progress = 0.0
        progressBar.layer.cornerRadius = 5
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 5
        progressBar.subviews[1].clipsToBounds = true
        
        self.popularLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_BOLD, size: 18), align: .left, text: "popularity_low")
        self.popularButton.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 16), align: .center, title: "promote")
        self.popularButton.cornerMiniumRadius()
        self.popularButton.backgroundColor = UIColor(named: "whitecolorNEW")
        self.uniqueLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "unique_views")
        self.uniqueDescLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "")
        self.totalLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "total_views")
        self.totalDescLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "")
        self.engagementTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .left, text: "engagements")
        self.engagementDescLabel.config(color: UIColor(named: "green_color"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "reach_more")
        self.titleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "engagements")
        self.countLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .right, text: "engagements")
    }
    func loadData(_ insightData: InsightsModel, itemDetails: ItemModel, index: IndexPath) {
        self.popularView.isHidden = true
        self.viewStackView.isHidden = true
        self.engagementStackView.isHidden = true
        self.engagementSubStackView.isHidden = true
        self.engagementDescLabel.config(color: UIColor(named: "green_color"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "reach_more")
        self.subStackView.axis = .vertical

        if index.section == 0 {
            if index.row == 0 {
                self.popularView.isHidden = false
                if insightData.popularityLevel == "low" {
                    self.popularLabel.text = getLanguage["popularity_low"] ?? ""
                }
                else {
                    self.popularLabel.text = getLanguage["popularity_high"] ?? ""
                }
                if PROMOTION_FLAG {
                    if itemDetails.promotionType != "Normal" {
                        self.popularButton.setTitle(getLanguage["already_promoted"] ?? "", for: .normal)
                    }
                    else {
                        self.popularButton.setTitle(getLanguage["promote"] ?? "", for: .normal)
                    }
                }
                else {
                    self.popularButton.isHidden = true
                }
                if itemDetails.itemStatus != "onsale" {
                    self.popularButton.setTitle(getLanguage["soldout"] ?? "", for: .normal)
                }
            }
        }
        else if index.section == 1 {
            self.viewStackView.isHidden = false
            self.uniqueDescLabel.text = insightData.uniqueViews
            self.totalDescLabel.text = insightData.totalViews
        }
        else if index.section == 2 {
            self.engagementStackView.isHidden = false
            self.engageMentImageView.isHidden = false
        }
        else if index.section == 3{
            self.engagementDescLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .right, text: "reach_more")
            self.subStackView.axis = .horizontal
            self.engagementStackView.isHidden = false
            self.engageMentImageView.isHidden = true
            if index.row == 0 {
                self.engagementTitleLabel.text = getLanguage["likes"] ?? ""
                self.engagementDescLabel.text = insightData.likes
            }
            else if index.row == 1 {
                self.engagementTitleLabel.text = getLanguage["comments"] ?? ""
                self.engagementDescLabel.text = insightData.comments
            }
            else if index.row == 2 {
                self.engagementTitleLabel.text = getLanguage["offer_request"] ?? ""
                self.engagementDescLabel.text = insightData.offerRequest
            }
            else if index.row == 3 {
                self.engagementTitleLabel.text = getLanguage["exchange_request"] ?? ""
                self.engagementDescLabel.text = insightData.exchangeRequest
            }
        }
        else if index.section == 4 {
            self.progressBar.isHidden = false
            self.engagementSubStackView.isHidden = false
            self.titleLabel.text = insightData.mostVisitedcity[index.row].cityName
            self.countLabel.text = insightData.mostVisitedcity[index.row].cityCount
            self.progressBar.setProgress(((Float(insightData.mostVisitedcity[index.row].percentage) ?? 0)/Float(100)), animated: true)
        }
    }
    
    
    
    func loadDatavideo(_ insightData: InsightsModel, itemDetails: StoryListModel, index: IndexPath) {
        self.popularView.isHidden = true
        self.viewStackView.isHidden = true
        self.engagementStackView.isHidden = true
        self.engagementSubStackView.isHidden = true
        self.engagementDescLabel.config(color: UIColor(named: "green_color"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "reach_more")
        self.subStackView.axis = .vertical

        if index.section == 0 {
            if index.row == 0 {
                self.popularView.isHidden = false
                if insightData.popularityLevel == "low" {
                    self.popularLabel.text = getLanguage["popularity_low"] ?? ""
                }
                else {
                    self.popularLabel.text = getLanguage["popularity_high"] ?? ""
                }
                if PROMOTION_FLAG {
                    if itemDetails.promotionType != "Normal" {
                        self.popularButton.setTitle(getLanguage["already_promoted"] ?? "", for: .normal)
                    }
                    else {
                        self.popularButton.setTitle(getLanguage["promote"] ?? "", for: .normal)
                    }
                }
                else {
                    self.popularButton.isHidden = true
                }
                if itemDetails.itemStatus != "onsale" {
                    self.popularButton.setTitle(getLanguage["soldout"] ?? "", for: .normal)
                }
            }
        }
        else if index.section == 1 {
            self.viewStackView.isHidden = false
            self.uniqueDescLabel.text = insightData.uniqueViews
            self.totalDescLabel.text = insightData.totalViews
        }
        else if index.section == 2 {
            self.engagementStackView.isHidden = false
            self.engageMentImageView.isHidden = false
        }
        else if index.section == 3{
            self.engagementDescLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .right, text: "reach_more")
            self.subStackView.axis = .horizontal
            self.engagementStackView.isHidden = false
            self.engageMentImageView.isHidden = true
            if index.row == 0 {
                self.engagementTitleLabel.text = getLanguage["likes"] ?? ""
                self.engagementDescLabel.text = insightData.likes
            }
            else if index.row == 1 {
                self.engagementTitleLabel.text = getLanguage["comments"] ?? ""
                self.engagementDescLabel.text = insightData.comments
            }
            else if index.row == 2 {
                self.engagementTitleLabel.text = getLanguage["offer_request"] ?? ""
                self.engagementDescLabel.text = insightData.offerRequest
            }
            else if index.row == 3 {
                self.engagementTitleLabel.text = getLanguage["exchange_request"] ?? ""
                self.engagementDescLabel.text = insightData.exchangeRequest
            }
        }
        else if index.section == 4 {
            self.progressBar.isHidden = false
            self.engagementSubStackView.isHidden = false
            self.titleLabel.text = insightData.mostVisitedcity[index.row].cityName
            self.countLabel.text = insightData.mostVisitedcity[index.row].cityCount
            self.progressBar.setProgress(((Float(insightData.mostVisitedcity[index.row].percentage) ?? 0)/Float(100)), animated: true)
        }
    }
override func layoutSubviews() {
    super.layoutSubviews()
//    self.progressBar.subviews.forEach { subview in
//        subview.layer.masksToBounds = true
//        subview.layer.cornerRadius = 5
//    }
}
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
