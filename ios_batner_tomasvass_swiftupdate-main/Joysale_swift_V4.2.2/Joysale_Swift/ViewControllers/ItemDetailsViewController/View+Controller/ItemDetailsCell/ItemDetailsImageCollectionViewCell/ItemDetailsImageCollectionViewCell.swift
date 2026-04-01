//
//  ItemDetailsImageCollectionViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 22/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class ItemDetailsImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadData(_ photos: PhotoModel) {
        self.itemImageView.sd_setImage(with: URL(string: photos.itemUrlMainOriginal)) { (image, error, cache, url) in
            if error != nil {
                self.itemImageView.image = #imageLiteral(resourceName: "applogo")
            }
        }
    }

}
