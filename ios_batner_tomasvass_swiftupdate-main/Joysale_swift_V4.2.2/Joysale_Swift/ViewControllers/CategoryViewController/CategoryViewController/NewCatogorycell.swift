//
//  NewCatogorycell.swift
//  Joysale_Swift
//
//  Created by HTS-PRO-2018 on 12/03/25.
//  Copyright © 2025 Hitasoft. All rights reserved.
//

import UIKit

class NewCatogorycell: UICollectionViewCell {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var Boxview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.categoryNameLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_BOLD, size: 12), align: .center, text: "")
    }

    
    
//    func loadData(_ categoryData: CategoryModel, viewType: Bool) {
//        self.categoryImageView.sd_setImage(with: URL(string: categoryData.categoryImg), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
//        self.categoryNameLabel.text = (categoryData.categoryName ?? "")
//        self.layoutIfNeeded()
//    }
    func loadData(_ categoryData: CategoryModel, viewType: Bool, index: Int?) {
        if let index = index, index == 0 {
            let dark = "https://appservices.hitasoft.in/batner/backend/web/uploads/darktheme2.png"
            let light   = "https://appservices.hitasoft.in/batner/backend/web/uploads/Component2.png"
            if UserDefaultModule.shared.getTheme() == "Dark"{
                self.categoryImageView.sd_setImage(
                    with: URL(string: dark),
                    placeholderImage: #imageLiteral(resourceName: "applogo"),
                    completed: nil
                )
            }else{
                self.categoryImageView.sd_setImage(
                    with: URL(string: light),
                    placeholderImage: #imageLiteral(resourceName: "applogo"),
                    completed: nil
                )

            }
            
        } else {
            self.categoryImageView.sd_setImage(
                with: URL(string: categoryData.categoryImg),
                placeholderImage: #imageLiteral(resourceName: "applogo"),
                completed: nil
            )
        }
        
        self.categoryNameLabel.text = categoryData.categoryName ?? ""
        self.layoutIfNeeded()
    }

    func loadCategoryData(_ categoryData: CategoryModel, index: Int) {
        self.loadData(categoryData, viewType: false,index:index)
        
    }
    override func layoutIfNeeded() {
        self.Boxview.layer.cornerRadius = 5 
        self.Boxview.clipsToBounds = true
    }
}
