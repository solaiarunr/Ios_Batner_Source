//
//  ItemDetailsMapTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 22/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Cosmos
import SDWebImage

class ItemDetailsMapTableViewCell: UITableViewCell {

    @IBOutlet weak var topconst: NSLayoutConstraint!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var mailVerifyImageView: UIImageView!
    @IBOutlet weak var facebookVerifyImageView: UIImageView!
    @IBOutlet weak var mobileVerifyImageView: UIImageView!
    var isFirst = false // Load Map image first time Only
    var bgimage = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
 
 
        // Initialization code
    }
    
     func configUI() {
        self.locationLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.userNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.ratingLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.callButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.callButton.cornerMiniumRadius()
        self.callButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .center, title: "Call")
        self.userImageView.cornerViewRadius()
     }
    func loadData(_ itemDetails: ItemModel) {
        self.locationLabel.text = itemDetails.location
        self.userNameLabel.text = itemDetails.sellerUsername
        self.userImageView.sd_setImage(with: URL(string: itemDetails.sellerImg), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        
        self.ratingStackView.isHidden = false
        self.ratingView.rating = (Double(itemDetails.sellerRating) ?? 0)
        self.ratingLabel.text = "(\(itemDetails.ratingUserCount ?? ""))"
        self.ratingStackView.isHidden = !BUYNOW_MODEL_FLAG
        
        self.mobileVerifyImageView.image = itemDetails.mobileVerification ? #imageLiteral(resourceName: "mob-veri") : #imageLiteral(resourceName: "mob-unveri")
        self.facebookVerifyImageView.image = itemDetails.facebookVerification ? #imageLiteral(resourceName: "fac-veri") : #imageLiteral(resourceName: "social_facebook")
        if (ADMIN_VIEW_MODEL.adminModel?.result.emailVerification) == "enable"{
            if itemDetails.emailVerification == true{
                self.mailVerifyImageView.image =  #imageLiteral(resourceName: "mail-veri")
            }
        }else if (ADMIN_VIEW_MODEL.adminModel?.result.emailVerification) == "disable"{
            self.mailVerifyImageView.isHidden = true
        }
        
        //MARK: Mapbox Addons
        if Addons_Status{
            
        }
        else{

            if isFirst {
               /*
                let url = "\(MAP_URL)\(itemDetails.latitude ?? 0),\(itemDetails.longitude ?? 0)" + "&zoom=15&size=\(Int(self.contentView.frame.width))x\(Int(self.mapImageView.frame.height-50))&maptype=roadmap&key=\(GOOGLE_API_KEY)&sensor=false.jpg"
                isFirst = false
                print("mapURL \(url)")
                self.mapImageView.sd_setImage(with: URL(string: url)) { (image, error, cache, url) in
                    if error != nil {
                        self.mapImageView.image = #imageLiteral(resourceName: "profilelogo")
                    }
                }
                */
            }
        }
    }
     
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
