//
//  HomeCatogoryCollectionViewCell.swift
//  Joysale_Swift
//  Created by Hitasoft on 15/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class HomeCatogoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    var categoryData = [CategoryModel]()
    var homeVC: HomeViewController?
    var ADviewType = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
          // Initialization code
    }
    func configUI() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "NewCatogorycell", bundle: nil), forCellWithReuseIdentifier: "NewCatogorycell")
    }
    func loadCategoryData(_ categoryData: [CategoryModel]) {
        self.categoryData = categoryData
        self.collectionView.reloadData()
    }
}
extension HomeCatogoryCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCatogorycell", for: indexPath) as! NewCatogorycell
        cell.loadData(categoryData[indexPath.row], viewType: true, index: indexPath.row)
//        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 110)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        homeVC?.selectedCategoryAct(indexPath.row)
    }
}
//extension HomeCatogoryCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return categoryData.count + 1 // Adding one extra item manually
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCatogorycell", for: indexPath) as! NewCatogorycell
//        
//        if indexPath.row == 0 {
//            // Configure the manual list item differently
//            cell.categoryImageView.image =  UIImage(named: "locationGreen")
//            cell.categoryNameLabel.text = "Manual Entry"
//        } else {
//            // Load data normally for other items
//            cell.loadData(categoryData[indexPath.row - 1], viewType: true)
//        }
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 90, height: 125)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
//            // Handle manual list selection
//            print("Manual entry selected")
//            homeVC?.selectedCategorypage()
//        } else {
//            // Handle normal category selection
//            homeVC?.selectedCategoryAct(indexPath.row - 1)
//        }
//    }
//}
