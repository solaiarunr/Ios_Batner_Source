//
//  FilterViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import SwiftRangeSlider
import Stripe
protocol FilterDelegate {
    func filterAct(_ filterData: FilterDataModel)
}

class FilterViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var filterTitleArray = ["location", "Distance", "Price", "Categories","advance_search", "itemcondition", "Posted_within", "Sort_by"]
    var filterData = [ProductFilterModel]()
    var updateFilterData: UpdateFilterModel?
    var filterDelegate: FilterDelegate?
    var isFromFilter = false
    let delegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }

    func configUI() {
        if (ADMIN_VIEW_MODEL.adminModel?.result.promotion ?? "") == "disable" {
            SORTBYARRAY = ["popular", "hightolow", "lowtohigh"]
        }
        else {
            SORTBYARRAY = ["popular", "urgent", "hightolow", "lowtohigh"]
        }
        self.saveButton.cornerMiniumRadius()
        self.view.addSubview(indicatorView)
        self.navigationController?.customRightBarButtonView(title: "cancel", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 15), imageName: "", isLeft: true, vc: self, transparantView: true)
        self.navigationController?.customNavigationBarView(title: "filter", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "reset", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 15), imageName: "", isLeft: false, vc: self, transparantView: false)

        self.tableView.register(UINib(nibName: "FilterTableViewCell", bundle: nil), forCellReuseIdentifier: "FilterTableViewCell")
        self.tableView.register(UINib(nibName: "FilterHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterHeaderTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        self.saveButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, title: "save")
        self.tableView.scrollsToTop = true
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        if FILTER_DATA.Category_id != "", let category = ADMIN_VIEW_MODEL.productBeforeModel?.result.category.filter({$0.categoryId == (FILTER_DATA.Category_id)}).first {
            filterData = category.filters
            if FILTER_DATA.subcategory_id != "", let subCategory = category.subcategory.filter({$0.subId == FILTER_DATA.subcategory_id}).first {
                filterData = (filterData + subCategory.filters)
                if FILTER_DATA.child_category_id != "",let childCategory = subCategory.childCategory.filter({$0.childId == FILTER_DATA.child_category_id}).first {
                    filterData = (filterData + childCategory.filters)
                }
            }
        }
        self.updateFilterData = Utility.shared.filterStringToDict(FILTER_DATA.filters)
        self.tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
                FILTER_DATA = FilterDataModel()
                UserDefaultModule.shared.setFilterData(FILTER_DATA)
                self.filterDelegate?.filterAct(FILTER_DATA)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.filterDelegate?.filterAct(FILTER_DATA)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func loadData() {
        let group = DispatchGroup()
        group.enter()
        
        ADMIN_VIEW_MODEL.getAdminData(onSuccess: { (success) in
            StripeAPI.defaultPublishableKey = (ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? "")
            group.leave()
        }) { (failure) in
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.updateFilterData = Utility.shared.filterStringToDict(FILTER_DATA.filters)
            self.tableView.reloadData()
        }
    }
    @IBAction func saveButtonAct(_ sender: UIButton) {
        if (FILTER_DATA.location != "" && FILTER_DATA.location.lowercased() != "WorldWide".lowercased() && !FILTER_DATA.isDistanceSlider && FILTER_DATA.location.lowercased() != UserDefaultModule.shared.getcountryname()?.lowercased()) {
            FILTER_DATA.isDistanceSlider = true
        }
  
        
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        //print("newissue1:\(UserDefaultModule.shared.getFilterData().distance ?? "0")")
        self.filterDelegate?.filterAct(FILTER_DATA)
        //print("newissue2:\(UserDefaultModule.shared.getFilterData().distance ?? "0")")
        delegate.setInitialViewController(initialView: TabbarController())
//        self.navigationController?.popViewController(animated: true)
    }
}
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            return self.filterData.count
        }
        else if section == 5 {
            if let category = ADMIN_VIEW_MODEL.productBeforeModel?.result.category.filter({$0.categoryId == FILTER_DATA.Category_id}).first, category.productCondition == "enable" {
                return 1
            }
            return 0
        }
        else if section == 6 {
            return POSTEDARRAY.count
        }
        else if section == 7
        {
            return SORTBYARRAY.count
        }
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filterTitleArray.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            if self.filterData.count == 0 {
                return 0
            }
        }
        else if section == 5 {
            if let category = ADMIN_VIEW_MODEL.productBeforeModel?.result.category.filter({$0.categoryId == FILTER_DATA.Category_id}).first {
                return category.productCondition != "enable" ? 0 : 40
            }
            else {
                return 0
            }
        }
        return 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterHeaderTableViewCell") as! FilterHeaderTableViewCell
        cell.headerLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        cell.overAllView.backgroundColor = UIColor(named: "BackGroundColorNew")
        cell.lineView.isHidden = false
        cell.viewBottomConst.constant = 0
        cell.lineView.backgroundColor = UIColor(named: "clearcolor")
        cell.headerLabel.text = (getLanguage[filterTitleArray[section]] ?? "").uppercased()
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell") as! FilterTableViewCell
        cell.priceSlider.tag = ((indexPath.section*1000)+indexPath.row)
        cell.priceSlider.addTarget(self, action: #selector(self.rangeSliderAct(_:)), for: .valueChanged)
        cell.slider.tag = ((indexPath.section*10)+indexPath.row)
        cell.slider.addTarget(self, action: #selector(self.distanceSliderAct(_:)), for: .valueChanged)

        if indexPath.section == 6 {
            cell.loadData(section: indexPath.section, row: indexPath.row, text: POSTEDARRAY[indexPath.row])
            if POSTEDARRAY[indexPath.row] == FILTER_DATA.posted_within {
                cell.arrowImageView.isHidden = false
            }
            else {
                cell.arrowImageView.isHidden = true
            }
        }
        else if indexPath.section == 7 {
            cell.loadData(section: indexPath.section, row: indexPath.row, text: SORTBYARRAY[indexPath.row])
            cell.arrowImageView.isHidden = true
            if SORTBYARRAY[indexPath.row] == (FILTER_DATA.sorting_id ?? "") {
                cell.arrowImageView.isHidden = false
            }
        }
        else if indexPath.section == 4 {
            cell.loadFilterData(self.filterData[indexPath.row])
        }
        else if indexPath.section == 5 {
            cell.loadData(section: indexPath.section, row: indexPath.row, text: "itemcondition")
        }
        else {
            cell.loadData(section: indexPath.section, row: indexPath.row, text: "")
        }
        return cell
    }
    @objc func distanceSliderAct(_ sender: UISlider) {
        if FILTER_DATA.location != "" && FILTER_DATA.location != "worldwide" && FILTER_DATA.location.lowercased() != UserDefaultModule.shared.getcountryname()?.lowercased() {
            let section = (sender.tag / 10)
             
            if section == 1 {
                //print("checking:\(sender.value)")
                if sender.value == 0.0{
                    sender.value = 1.0
                }
                FILTER_DATA.distance = "\(Int(sender.value))"
                //print("newissue:\(FILTER_DATA.distance ?? "")")
            }
            
            FILTER_DATA.isDistanceSlider = true
            FILTER_DATA.distance_type = (ADMIN_VIEW_MODEL.adminModel?.result.distanceType ?? "")

        }
        else {
            
            sender.setValue(0, animated: true)
            FILTER_DATA.distance = ""
            let alert = UIAlertController(title: getLanguage["error"] ?? "error", message: getLanguage["select_location"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
//        self.tableView.reloadData()
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    }
    @objc func rangeSliderAct(_ sender: RangeSlider) {
        let section = (sender.tag / 1000)
        let row = (sender.tag % 1000)
        let minVal = Int(sender.lowerValue)
        let maxVal = Int(sender.upperValue)
        if section == 2 {
            
            FILTER_DATA.Price = "\(minVal)-\(maxVal)"
            if #available(iOS 15.0, *) {
                self.tableView.reconfigureRows(at: [IndexPath(row: row, section: section)])
            } else {
                self.tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
            }
        }
        else if section == 4 {
            if row < self.filterData.count {
                let filterDict = self.filterData[row]
                if filterDict.type == "range" {
                    self.updateFilterData?.range.removeAll(where: {$0.id == filterDict.id})
                    self.updateFilterData?.range.append(FilterRangeModel(max_value: "\(maxVal)", id: filterDict.id, min_value: "\(minVal)"))
                    if let updateFilter = self.updateFilterData {
                        FILTER_DATA.filters = Utility.shared.filterDictToString(updateFilter)
                    }
                }
                if #available(iOS 15.0, *) {
                    self.tableView.reconfigureRows(at: [IndexPath(row: row, section: section)])
                } else {
                    self.tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
                }
            }
            
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // MARK: Mabbox Addon
            
            let pageObj = MapViewController()
            pageObj.locationString = FILTER_DATA.location
            pageObj.lat = FILTER_DATA.lat
            pageObj.isFromHome = true
            pageObj.long = FILTER_DATA.long
            pageObj.delegate = self
            pageObj.viewType = "filter"
            self.navigationController?.pushViewController(pageObj, animated: true)
 
            
//            let pageObj = LocationViewController()
//            pageObj.locationString = FILTER_DATA.location
//            pageObj.delegate = self
//            pageObj.viewType = "filter"
//            self.navigationController?.pushViewController(pageObj, animated: true)
        }
        if indexPath.section == 3 {
            let pageObj = CategoryViewController()
            pageObj.CategoryDetails = CategoryDetailsModel(Category_id: FILTER_DATA.Category_id, subcategory_id: FILTER_DATA.subcategory_id, child_category_id: FILTER_DATA.child_category_id)
            pageObj.delegate = self
            pageObj.categoryViewType = 1
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
        else if indexPath.section == 4 {
            if self.filterData[indexPath.row].type != "range" {
                let pageObj = ProductConditionViewController()
                pageObj.isProductCondition = false
                pageObj.isFromFilter = true
                pageObj.productDelegate = self
                pageObj.updateFilterData = self.updateFilterData
                pageObj.categoryFilter = self.filterData[indexPath.row]
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
        }
        else if indexPath.section == 5 {
            let pageObj = ProductConditionViewController()
            pageObj.isFromFilter = true
            pageObj.productDelegate = self
            pageObj.selectedProductCondition = FILTER_DATA.product_condition
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
        else if indexPath.section == 6 || indexPath.section == 7{
            if indexPath.section == 6 {
                FILTER_DATA.posted_within = POSTEDARRAY[indexPath.row]
            }
            else {
                FILTER_DATA.sorting_id = SORTBYARRAY[indexPath.row]
            }
            self.tableView.reloadData()
        }
        
    }
}
extension FilterViewController: SearchDelegate, CategoryDelegate, ProductConditionDelegate, customLocationDelegate {
    func loadadmindata() {
        
    }
    // locationDelegate
    
    // Update Location Data
    func locationAct(city: String, state: String, country: String, countryCode: String,lat: String, long: String, location: String) {
        if location == "worldwide" || location.lowercased() == UserDefaultModule.shared.getcountryname()?.lowercased(){
            print("hii")
            FILTER_DATA.distance = ""
        }
        FILTER_DATA.location = location
        FILTER_DATA.city = city
        FILTER_DATA.state = state
        FILTER_DATA.country = country
        FILTER_DATA.lat = lat
        FILTER_DATA.long = long
        self.tableView.reloadData()
    }
    func updateSearchData(_ searchData: FilterDataModel) {
        FILTER_DATA = searchData
    }
    func updateCategoryData(_ searchData: CategoryDetailsModel) {
        FILTER_DATA.Category_id = searchData.Category_id
        FILTER_DATA.subcategory_id = searchData.subcategory_id
        FILTER_DATA.child_category_id = searchData.child_category_id
        FILTER_DATA.filters = ""
        self.updateFilterData = Utility.shared.filterStringToDict(FILTER_DATA.filters)
        self.tableView.reloadData()
    }
    // UpdateProductCondition & Filter
    func updateFilterData(_ updateFilterData: UpdateFilterModel) {
        self.updateFilterData = updateFilterData
        FILTER_DATA.filters = Utility.shared.filterDictToString(updateFilterData)
        self.tableView.reloadData()
    }
    
    func updateProductCondition(_ productCondition: String) {
        FILTER_DATA.product_condition = productCondition
        self.tableView.reloadData()
    }
}

