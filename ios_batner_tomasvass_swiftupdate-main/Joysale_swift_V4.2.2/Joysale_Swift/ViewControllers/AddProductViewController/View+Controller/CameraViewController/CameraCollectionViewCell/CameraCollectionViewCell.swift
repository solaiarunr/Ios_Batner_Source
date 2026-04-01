//
//  CameraCollectionViewCell.swift
//  Joyshorts_Swift
//
//  Created by Hitasoft on 23/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class CameraCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.cancelButton.isHidden = true
        self.itemImageView.updateborder(color: UIColor(named: "BackColorwhite") ?? .white, borderWidth: 1, radius: 5)
    }
}
