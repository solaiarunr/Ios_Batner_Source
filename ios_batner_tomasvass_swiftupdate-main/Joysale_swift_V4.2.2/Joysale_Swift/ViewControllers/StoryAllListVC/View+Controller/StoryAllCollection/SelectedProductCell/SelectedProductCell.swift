//
//  SelectedProductCell.swift
//  Joyshorts_Swift
//
//  Created by APPLE on 08/12/22.
//

import UIKit
    
class SelectedProductCell: UICollectionViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var productImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
    }
    
    func configUI() {
        self.shadowView.cornerViewMaxRadius()
        self.productLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 18), align: .left, text: "")
        self.productPrice.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.viewBtn.config(color: .white, font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .center, title: "")
        self.viewBtn.setTitle(getLanguage["view"], for: .normal)
        self.viewBtn.cornerMiniumRadius()
        self.productImageView.contentMode = .scaleAspectFill
    }
    
    func loadData(_ product: GetItemsResult1) {
        self.productImageView.sd_setImage(with: URL(string: (product.product_image ?? "")), placeholderImage: UIImage(named: "applogo"))
        self.productLabel.text = product.product_name
        if Float(product.product_price ?? "0") != 0 {
            self.productPrice.text = "\(product.product_currencysymbol ?? "None")\(" ")\(product.product_price ?? "None100")"
            self.productPrice.textColor = UIColor(named: "AppTextColor") ?? .white
        }
        else {
            self.productPrice.text = getLanguage["giving_away"]
            self.productPrice.textColor = UIColor(named: "AppThemeColorNew") ?? .white
        }
    }
}

