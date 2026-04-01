//
//  CategoryCollectionViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 12/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryTopConst: NSLayoutConstraint!
    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var highlightedImageView: UIImageView!
    @IBOutlet weak var highlightedView: UIView!
    @IBOutlet weak var verticalLineView: UIView!
    @IBOutlet weak var horizontalLineView: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.categoryNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, text: "")
        self.categoryImageView.layer.cornerRadius = 0
    }
    func loadData(_ categoryData: CategoryModel, viewType: Bool) {
       self.categoryImageView.sd_setImage(with: URL(string: categoryData.categoryImg), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.categoryNameLabel.text = (categoryData.categoryName ?? "")
        self.horizontalLineView.isHidden = viewType
        self.verticalLineView.isHidden = viewType
        self.categoryImageView.layer.cornerRadius = self.categoryImageView.frame.height / 2
        self.categoryImageView.clipsToBounds = true
        self.categoryImageView.contentMode = .scaleToFill
        self.layoutIfNeeded()
    }
    func loadCategoryData(_ categoryData: CategoryModel, index: Int) {
        self.loadData(categoryData, viewType: false)
        self.horizontalLineView.isHidden = false
        self.verticalLineView.isHidden = false
        if index%2 == 0 {
            self.verticalLineView.isHidden = false
        }
        else {
            self.verticalLineView.isHidden = true
        }

        
    }
    override func layoutIfNeeded() {
        self.categoryImageView.layer.cornerRadius = self.categoryImageView.frame.height / 2
        self.categoryImageView.clipsToBounds = true
        self.categoryImageView.contentMode = .scaleToFill
    }
}
