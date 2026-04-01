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
        self.Cornerview.clipsToBounds = true
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
