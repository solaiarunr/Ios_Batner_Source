//
//  CountrySearchCell.swift
//  Chobi
//
//  Created by HTS on 21/11/23.
//  Copyright © 2023 Hitasoft. All rights reserved.
//

import UIKit

class CountrySearchCell: UICollectionViewCell {
    @IBOutlet weak var fullview : UIView!
    @IBOutlet weak var countryImg : UIImageView!
    @IBOutlet weak var countryLbl : UILabel!
    @IBOutlet weak var countryCodeLbl : UILabel!
    @IBOutlet weak var tickiconimg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
    }
    
    func configUI(){
        self.fullview.backgroundColor = .clear
        self.countryImg.contentMode = .scaleAspectFill
        self.countryLbl.config(color: UIColor(named: "BlackColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .left, text: "")
        self.countryCodeLbl.config(color:  UIColor(named: "BlackColorNew"), font: liteBold, align: .right, text: "")
//        let bottomLine = CALayer()
//        bottomLine.frame = CGRect(x: 0, y: fullview.frame.height - 1, width: fullview.frame.width, height: 1)
//        bottomLine.backgroundColor = UIColor.lightGray.cgColor
//        fullview.layer.addSublayer(bottomLine)
    }
    override func layoutSubviews() {
        super.layoutSubviews()

//        // Remove old borders if needed
//        fullview.layer.sublayers?.removeAll(where: { $0.name == "bottomBorder" })
//
//        let bottomLine = CALayer()
//        bottomLine.name = "bottomBorder"
//        bottomLine.frame = CGRect(x: 0, y: fullview.frame.height - 1, width: fullview.frame.width, height: 1)
//        bottomLine.backgroundColor = UIColor.lightGray.cgColor
//        fullview.layer.addSublayer(bottomLine)
    }

}
