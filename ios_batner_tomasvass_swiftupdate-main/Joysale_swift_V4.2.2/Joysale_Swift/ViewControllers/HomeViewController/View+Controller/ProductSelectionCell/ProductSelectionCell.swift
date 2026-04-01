//
//  ProductSelectionCell.swift
//  Joysale_Swift
//
//  Created by HTS-PRO-2018 on 13/03/25.
//  Copyright © 2025 Hitasoft. All rights reserved.
//

import UIKit

class ProductSelectionCell: UICollectionViewCell {
    @IBOutlet weak var videobtn: UIButton!
    @IBOutlet weak var Imagebtn: UIButton!
    @IBOutlet weak var Allbtn: UIButton!
    @IBOutlet weak var WholeView: UIStackView!
    @IBOutlet weak var ImageborderLbl: UILabel!
    @IBOutlet weak var VideoborderLbl: UILabel!
    @IBOutlet weak var AllborderLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.videobtn.config(color: UIColor(named: "BlackColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 17), align: .center, title: "Pro_video")
        self.Imagebtn.config(color: UIColor(named: "BlackColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 17), align: .center, title: "Pro_Audio")
        self.Allbtn.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 17), align: .center, title: "all")
    }
    
    func loadCategoryData(categoryData:Bool) {
        if categoryData == true {
            self.WholeView.isHidden = false
        }else{
            self.WholeView.isHidden = true
        }
        
    }
}
