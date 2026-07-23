//
//  PhotocellCollectionViewCell.swift
//  Joysale_Swift
//
//  Created by HTS-PRO-2018 on 25/03/25.
//  Copyright © 2025 Hitasoft. All rights reserved.
//

import UIKit

class PhotocellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var playbackimageview: UIImageView!
    @IBOutlet weak var Cornerview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.Cornerview.layer.cornerRadius = 6
        self.Cornerview.clipsToBounds = false
        self.Cornerview.backgroundColor = .clear
        self.imageview.layer.cornerRadius = 6
        self.imageview.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.Cornerview.refreshUpdateBorder()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.setSelectionBorder(false)
    }

    func setSelectionBorder(_ selected: Bool) {
        if selected {
            self.Cornerview.updateborder(
                color: UIColor(named: "AppThemeColorNew") ?? .systemGreen,
                borderWidth: 2,
                radius: 6
            )
        } else {
            self.Cornerview.clearUpdateBorder()
            self.Cornerview.layer.cornerRadius = 6
        }
    }
    func loadData(_ photos: PhotoModel) {
        self.imageview.sd_setImage(with: URL(string: photos.itemUrlMainOriginal)) { (image, error, cache, url) in
            if error != nil {
                self.imageview.image = #imageLiteral(resourceName: "applogo")
            }
        }
        
        if photos.type == "video"{
            self.playbackimageview.isHidden = false
        }else{
            self.playbackimageview.isHidden = true
        }
    }


}
