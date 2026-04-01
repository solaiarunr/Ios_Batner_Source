 //
 //  FilterTableViewCell.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 13/06/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import UIKit
 import SwiftRangeSlider

 class FilterTableViewCell: UITableViewCell {

     @IBOutlet weak var destinationFilterImageView: UIImageView!
     @IBOutlet weak var homeFilterImageView: UIImageView!
     @IBOutlet weak var filterDescLabel: UILabel!
     @IBOutlet weak var distanceButtonLeadingConst: NSLayoutConstraint!
     @IBOutlet weak var distanceButton: UIButton!
     @IBOutlet weak var priceStackView: UIStackView!
     @IBOutlet weak var maximumPriceLabel: UILabel!
     @IBOutlet weak var minimumPriceLabel: UILabel!
     @IBOutlet weak var arrowImageView: UIImageView!
     @IBOutlet weak var distanceFilterStackView: UIStackView!
     @IBOutlet weak var titleStackView: UIStackView!
     @IBOutlet weak var priceSlider: RangeSlider!
     @IBOutlet weak var slider: CustomSlider!
     @IBOutlet weak var filterLabel: UILabel!
     
     override func awakeFromNib() {
         super.awakeFromNib()
         self.configUI()
         // Initialization code
     }
     func configUI() {
         self.filterDescLabel.isHidden = true
         self.distanceButton.cornerRoundRadius()
         self.distanceButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 10), align: .center, title: "")
         self.maximumPriceLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .right, text: "")
         self.filterDescLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .right, text: "")
         self.minimumPriceLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
         self.filterLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
     }
     func loadData(section: Int, row: Int, text: String) {
         self.titleStackView.isHidden = true
         self.filterDescLabel.isHidden = true
         self.distanceFilterStackView.isHidden = true
         self.priceStackView.isHidden = true
         self.arrowImageView.isHidden = true
         self.arrowImageView.image = #imageLiteral(resourceName: "InArrowImg").imageFlippedForRightToLeftLayoutDirection()
         self.arrowImageView.contentMode = .scaleAspectFit
         self.distanceButton.isHidden = true
         if section == 0 {
             if FILTER_DATA.location != "" {
                 self.filterLabel.text = FILTER_DATA.location
             }
             else{
//                 self.filterLabel.text = getLanguage["WorldWide"]
                 self.filterLabel.text = UserDefaultModule.shared.getcountryname()
             }
             self.titleStackView.isHidden = false
             self.arrowImageView.isHidden = false
         }
         else if section == 1 {
             self.distanceFilterStackView.isHidden = false
             self.slider.maximumValue = (Float(ADMIN_VIEW_MODEL.productBeforeModel?.result.distance ?? "0") ?? 0)
             print("\(FILTER_DATA.distance ?? "")")
            
             self.distanceButtonLeadingConst.constant = 0
             if ((Int(FILTER_DATA.distance) ?? 0) != 0 && FILTER_DATA.location != "" && FILTER_DATA.location.lowercased() != "WorldWide".lowercased()) || (FILTER_DATA.location != "" && FILTER_DATA.location.lowercased() != "WorldWide".lowercased() && !FILTER_DATA.isDistanceSlider) {
                 if (FILTER_DATA.location != "" && FILTER_DATA.location.lowercased() != "WorldWide".lowercased() && !FILTER_DATA.isDistanceSlider && FILTER_DATA.location.lowercased() != UserDefaultModule.shared.getcountryname()?.lowercased()) {
                    print("Distance \((ADMIN_VIEW_MODEL.productBeforeModel?.result.distance ?? "0"))")
                     FILTER_DATA.distance = (ADMIN_VIEW_MODEL.productBeforeModel?.result.distance ?? "0")
                 }
                 else {
//                    print("Distance1 \((ADMIN_VIEW_MODEL.productBeforeModel?.result.distance ?? "0"))")
//
//                    FILTER_DATA.distance = ""
                 }
                self.distanceButton.isHidden = false
                if FILTER_DATA.distance == ""{
                    self.distanceButton.isHidden = true
                }else{
                    self.distanceButton.setTitle("\(FILTER_DATA.distance ?? "") km", for: .normal)
                 }
                 self.slider.value = (Float(FILTER_DATA.distance) ?? 0)
                 let trackRect = self.slider.trackRect(forBounds: self.slider.frame)
                 let thumbRect = self.slider.thumbRect(forBounds: self.slider.bounds, trackRect: trackRect, value: roundf(self.slider.value))
                 if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                     self.distanceButtonLeadingConst.constant = self.slider.frame.width - thumbRect.minX
                 }
                 else {
                     self.distanceButtonLeadingConst.constant = thumbRect.minX
                 }
                 self.homeFilterImageView.tintColor = UIColor(named: "AppThemeColorNew")
                 self.destinationFilterImageView.tintColor = UIColor(named: "AppThemeColorNew")
             }
             else {
                
                 self.slider.value = 0
                 FILTER_DATA.distance = ""
                 self.distanceButton.isHidden = true
                 self.homeFilterImageView.tintColor = UIColor(named: "appblackcolor")
                 self.destinationFilterImageView.tintColor = UIColor(named: "appblackcolor")
                if FILTER_DATA.distance == ""{
                    self.distanceButton.isHidden = true
                }
             }
         }
         else if section == 2 {
             let rangeArray = FILTER_DATA.Price.components(separatedBy: "-")
             self.priceStackView.isHidden = false
             self.priceSlider.minimumValue = 0
             self.priceSlider.maximumValue = 5000
             if let lastVal = Int(rangeArray.last ?? ""), let firstVal = Int(rangeArray.first ?? "") {
                 self.priceSlider.lowerValue = Double(firstVal)
                 self.priceSlider.upperValue = Double(lastVal)
                 self.minimumPriceLabel.text = "\(firstVal)"
                 self.maximumPriceLabel.text = "\(lastVal)"
                 self.priceSlider.semanticContentAttribute = .unspecified
                 if lastVal >= 5000 {
                     self.maximumPriceLabel.text = "\(lastVal)+"
                 }
             }
             else {
                 self.priceSlider.lowerValue = 0
                 self.priceSlider.upperValue = 5000
                 self.minimumPriceLabel.text = "\(0)"
                 self.maximumPriceLabel.text = "\(5000)+"
             }
             if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                 self.priceSlider.transform = CGAffineTransform(scaleX: -1, y: 1)
             }
             else {
                 self.priceSlider.transform = .identity
             }
         }
         else if section == 3 {
             self.arrowImageView.isHidden = false
             self.titleStackView.isHidden = false
             if FILTER_DATA.Category_id != "",let categoryData = ADMIN_VIEW_MODEL.adminModel?.result.category.filter({$0.categoryId == (Int(FILTER_DATA.Category_id) ?? 0)}).first {
                 self.filterLabel.text = categoryData.categoryName
                 if FILTER_DATA.subcategory_id != "", let subCategory = categoryData.subcategory.filter({$0.subId == (Int(FILTER_DATA.subcategory_id) ?? 0)}).first {
                     self.filterLabel.text = "\(categoryData.categoryName ?? "") · \(subCategory.subName ?? "")"

                     if FILTER_DATA.child_category_id != "", let childCategory = subCategory.childCategory.filter({$0.childId == (Int(FILTER_DATA.child_category_id) ?? 0)}).first {
                         self.filterLabel.text = "\(categoryData.categoryName ?? "") · \(subCategory.subName ?? "") · \((childCategory.childName ?? ""))"
                     }
                 }
             }
             else {
                 self.filterLabel.text = getLanguage["all_category"]
             }
             
         }
         else {
             self.titleStackView.isHidden = false
             self.arrowImageView.isHidden = true
             self.filterLabel.text = getLanguage["all_category"]
             if section == 5 {
                 self.arrowImageView.isHidden = false
                 self.filterLabel.text = getLanguage[text]
                 if FILTER_DATA.product_condition != "" {
                     if let itemCondition = ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.filter({$0.id == Int(FILTER_DATA.product_condition ?? "0")}).first {
                         self.filterLabel.text = itemCondition.name
                     }
                     
                 }
             }
             else if section == 6 {
                 self.arrowImageView.contentMode = .scaleToFill
                 self.arrowImageView.image = #imageLiteral(resourceName: "checkicon")
                 self.filterLabel.text = getLanguage[text]
             }
             else if section == 7 {
                 self.arrowImageView.contentMode = .scaleToFill
                 self.arrowImageView.image = #imageLiteral(resourceName: "checkicon")
                 self.filterLabel.text = getLanguage[text]
             }
         }
     }
     func loadFilterData(_ filterData: ProductFilterModel) {
         let updatedFilter = Utility.shared.filterStringToDict(FILTER_DATA.filters)
         self.distanceButton.isHidden = true
         self.titleStackView.isHidden = true
         self.arrowImageView.image = #imageLiteral(resourceName: "InArrowImg").imageFlippedForRightToLeftLayoutDirection()
         self.arrowImageView.contentMode = .scaleAspectFit
         self.distanceFilterStackView.isHidden = true
         self.priceStackView.isHidden = true
         self.arrowImageView.isHidden = true
         self.filterDescLabel.isHidden = true
         self.filterLabel.text = filterData.label
         if filterData.type == "dropdown" || filterData.type == "multilevel" {
             self.arrowImageView.isHidden = false
             self.filterDescLabel.isHidden = false
             self.titleStackView.isHidden = false
             var text = [String]()
             var childValues = [String]()
             for filterArray in filterData.values {
                 if filterData.type == "multilevel" {
                     for value in updatedFilter.multilevel {
                         let childFilter = filterArray.parentValues.filter({$0.childId == value.id && value.catType == filterData.categoryType})
                         if childFilter.count > 0 {
                             if !childValues.contains(where: {i in (childFilter.contains(where: {$0.childName == i}))}) {
                                 let childArray = childFilter.map({$0.childName ?? ""})
                                 childValues.append(contentsOf: childArray)
                             }
                         }
                     }
                     text = childValues
                 }
                 else {
                     if updatedFilter.dropdown.contains(where: {$0.id == filterArray.parentId && $0.catType == filterData.categoryType}) {
                         text.append(filterArray.parentLabel)
                     }
                 }
             }
             self.filterDescLabel.text = text.joined(separator: ",")
         }
         else if filterData.type == "range" {
             self.titleStackView.isHidden = false
             self.priceStackView.isHidden = false
             self.priceSlider.minimumValue = Double(filterData.minValue) ?? 0
             self.priceSlider.maximumValue = Double(filterData.maxValue) ?? 0
             if let filterDict = updatedFilter.range.filter({$0.id == filterData.id}).first {
                 self.priceSlider.lowerValue = Double(filterDict.min_value ?? "0") ?? 0
                 self.priceSlider.upperValue = Double(filterDict.max_value ?? "0") ?? 0
                 self.maximumPriceLabel.text = (filterDict.max_value ?? "0")
                 self.minimumPriceLabel.text = (filterDict.min_value ?? "0")
             }
             else {
                 self.priceSlider.lowerValue = Double(filterData.minValue) ?? 0
                 self.priceSlider.upperValue = Double(filterData.maxValue) ?? 0
                 self.maximumPriceLabel.text = filterData.maxValue
                 self.minimumPriceLabel.text = filterData.minValue
             }
             if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                 self.priceSlider.transform = CGAffineTransform(scaleX: -1, y: 1)
             }
             else {
                 self.priceSlider.transform = .identity
             }
         }
     }
     func rangeSliderViewAct(value: String) {
         if value != "" {
             let rangeArray = value.components(separatedBy: "-")
             self.minimumPriceLabel.text = rangeArray.first
             self.maximumPriceLabel.text = rangeArray.last
         }
     }
     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)

         // Configure the view for the selected state
     }
     
 }

