//
//  ProductConditionViewController.swift
//  Joyshorts_Swift
//
//  Created by Hitasoft on 27/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Stripe
protocol ProductConditionDelegate {
    func updateFilterData(_ updateFilterData: UpdateFilterModel)
    func updateProductCondition(_ productCondition: String)
}

class ProductConditionViewController: UIViewController {

    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!
    @IBOutlet weak var searchFieldView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var borderView: UIView!
    var updateFilterData: UpdateFilterModel?
    var isProductCondition = true
    var isFromFilter = false
    var categoryFilter: ProductFilterModel?
    // If Filter Type is Multilevel then store subindex
    var selectedSubIndex: Int!
    var selectedProductCondition = ""
    var productDelegate: ProductConditionDelegate?
    var filterProductCondition = [ProductConditionModel]()
    var categoryFilterarray = [ProductValueModel]()
    private let refreshControl = UIRefreshControl()

    var parentFilter: ProductValueModel?
    var parentFilterArray = [ProductParentValueModel]()
    var isChildFilter = false
    
    var isSearchFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    /*
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    */
    func configUI() {
        self.view.addSubview(indicatorView)
        self.navigationController?.customNavigationBarView(title: "search", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        if isProductCondition {
            self.title = getLanguage["itemcondition"] ?? ""
        }
        else {
            if isChildFilter {
                self.title = self.parentFilter?.parentLabel ?? ""
            }
            else {
                self.title = categoryFilter?.label ?? ""
            }
        }
        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.noItemTitleLabel.isHidden = true
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "no search result found")


        
        self.navigationController?.customRightBarButtonView(title: "", fColor: "AppTextColor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        
        self.navLabel.config(color: UIColor(named: "BlackTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "search")
//          self.navView.backgroundColor = UIColor(named: "whitecolor")
        
        self.tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        self.tableView.register(UINib(nibName: "FilterHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterHeaderTableViewCell")
        self.searchTextField.cornerMiniumRadius()
        self.searchTextField.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "search", font: UIFont(name: APP_FONT_REGULAR, size: 15))
        self.searchTextField.textFieldWithRightView(title: "", image: #imageLiteral(resourceName: "search_btn"))
        
        self.tableView.estimatedSectionHeaderHeight = 45
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 10
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.searchTextField.addDoneButtonOnKeyboard()
        if isProductCondition {
            self.loadData()
        }
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refreshAct), for: .valueChanged)
        self.changeRTL()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
    func changeRTL(){
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
            self.navView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.navLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.searchFieldView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        self.loadSelectedFilter()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func refreshAct() {
        self.loadData()
    }
    func loadSelectedFilter() {
        if let FilterCategory = self.categoryFilter {
            for value in FilterCategory.values {
                if FilterCategory.type == "multilevel" {
                    if self.updateFilterData?.multilevel.contains(where: {i in (value.parentValues.contains(where: {$0.childId == i.id && i.catType == FilterCategory.categoryType}))}) ?? false && !isChildFilter{
                        self.addRightView()
                    }
                }
                else {
                    if self.updateFilterData?.dropdown.contains(where: {$0.id == value.parentId && $0.catType == FilterCategory.categoryType}) ?? false {
                        if self.isFromFilter {
                            self.addRightView()
                        }
                    }
                }
            }
        }
    }
    func loadData() {
        if isProductCondition {
            ADMIN_VIEW_MODEL.getAdminData(onSuccess: { (success) in
                StripeAPI.defaultPublishableKey = (ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? "")
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
             }) { (failure) in
                self.refreshControl.endRefreshing()
             }
        }
    }
    @IBAction func backButtonAct(_ sender: Any) {
        if !isProductCondition, let filters = self.updateFilterData {
            self.productDelegate?.updateFilterData(filters)
            self.navigationController?.popViewController(animated: true)
        }
    else {
        if isFromFilter == false {
            if let filters = self.updateFilterData {
                if isChildFilter {
                    self.productDelegate?.updateFilterData(filters)
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
        
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
                if !isProductCondition, let filters = self.updateFilterData {
                    self.productDelegate?.updateFilterData(filters)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                if isFromFilter == false {
                    if let filters = self.updateFilterData {
                        if isChildFilter {
                            self.productDelegate?.updateFilterData(filters)
                        }
                    }
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if self.isProductCondition {
            var tempProductModel = [ProductConditionModel]()
            if let productCondition = ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition {
                tempProductModel = productCondition
                self.filterProductCondition.removeAll()
            }
            let filterVal = tempProductModel.filter({$0.name.localizedCaseInsensitiveContains(sender.text!)})
            if filterVal.count > 0 {
                for filter in filterVal {
                    if !filterProductCondition.contains(where: {$0.id == filter.id}) {
                        filterProductCondition.append(filter)
                    }
                }
            }
            if filterProductCondition.count == 0 && self.searchTextField.text == "" {
                self.isSearchFlag = false
            }
            else {
                self.isSearchFlag = true
            }
            self.tableView.reloadData()
        }
        else {
            if isChildFilter {
                var tempProductModel = [ProductParentValueModel]()
                if let categoryFilter = self.parentFilter?.parentValues {
                    tempProductModel = categoryFilter
                    self.parentFilterArray.removeAll()
                }
                let filterVal = tempProductModel.filter({$0.childName.localizedCaseInsensitiveContains(sender.text!)})
                if filterVal.count > 0 {
                    for filter in filterVal {
                        if !parentFilterArray.contains(where: {$0.childId == filter.childId}) {
                            self.parentFilterArray.append(filter)
                        }
                    }
                }
                if parentFilterArray.count == 0 && self.searchTextField.text == "" {
                    self.isSearchFlag = false
                }
                else {
                    self.isSearchFlag = true
                }
                self.tableView.reloadData()
            }
            else {
                var tempProductModel = [ProductValueModel]()
                if let categoryFilter = self.categoryFilter?.values {
                    tempProductModel = categoryFilter
                    self.categoryFilterarray.removeAll()
                }
                let filterVal = tempProductModel.filter({$0.parentLabel.localizedCaseInsensitiveContains(sender.text!)})
                if filterVal.count > 0 {
                    for filter in filterVal {
                        if !categoryFilterarray.contains(where: {$0.parentId == filter.parentId}) {
                            self.categoryFilterarray.append(filter)
                        }
                    }
                }
                if categoryFilterarray.count == 0 && searchTextField.text == ""{
                    self.isSearchFlag = false
                }
                else {
                    self.isSearchFlag = true
                }
                self.tableView.reloadData()
            }
            
        }
    }
}
extension ProductConditionViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        self.noItemStackView.isHidden = false
        if self.isProductCondition {
            if isSearchFlag {
                return self.filterProductCondition.count
            }
            return (ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.count ?? 0)
        }
        else {
            if isChildFilter {
                if isSearchFlag {
                    return self.parentFilterArray.count
                }
                else {
                    return (self.parentFilter?.parentValues.count ?? 0)
                }
            }
            else {
                if isSearchFlag {
                    return self.categoryFilterarray.count
                }
                else {
                    return (self.categoryFilter?.values.count ?? 0)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.noItemStackView.isHidden = true
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterHeaderTableViewCell") as! FilterHeaderTableViewCell
        
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
            cell.headerLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
        }else{
            cell.headerLabel.transform = .identity
        }
        
        cell.overAllView.backgroundColor = UIColor(named: "whitecolorNew")
        cell.headerLabel.textColor = UIColor(named: "AppTextColor")
        cell.viewType = 1
        cell.checkImageView.isHidden = true
        cell.arrowImageView.isHidden = true
        if self.isProductCondition {
            cell.arrowImageView.isHidden = true
            if isSearchFlag {
                cell.headerLabel.text = getLanguage[self.filterProductCondition[section].name] ?? self.filterProductCondition[section].name
                if selectedProductCondition == "\(self.filterProductCondition[section].id ?? 0)" {
                    cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
                    cell.checkImageView.isHidden = false
                }
            }
            else {
                cell.headerLabel.text = getLanguage[(ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition[section].name ?? "")] ?? ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition[section].name ?? ""
                if selectedProductCondition == "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition[section].id ?? 0)" {
                    cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
                    cell.checkImageView.isHidden = false
                }
            }
        }
        else {
            if isChildFilter {
                let value = isSearchFlag ? self.parentFilterArray[section] : self.parentFilter?.parentValues[section]
                cell.headerLabel.text = value?.childName ?? ""
                if self.updateFilterData?.multilevel.contains(where: {$0.id == value?.childId && $0.catType == categoryFilter?.categoryType}) ?? false {
                    cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
                    cell.checkImageView.isHidden = false
                }
                else {
                    cell.headerLabel.textColor = UIColor(named: "AppTextColor")
                }
            }
            else {
                let value = isSearchFlag ? self.categoryFilterarray[section] : self.categoryFilter?.values[section]
                cell.headerLabel.text = value?.parentLabel ?? ""
                if self.updateFilterData?.dropdown.contains(where: {$0.id == value?.parentId && $0.catType == categoryFilter?.categoryType}) ?? false {
                    cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
                    cell.checkImageView.isHidden = false
                    self.addRightView()
                }
                if (value?.parentValues.count ?? 0) > 0 {
                    cell.arrowImageView.isHidden = false
                    if (self.updateFilterData?.multilevel.filter({i in (value?.parentValues.contains(where: {i.id == $0.childId && i.catType == categoryFilter?.categoryType}) ?? false)}).count ?? 0) > 0 {
                        cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
                        cell.checkImageView.isHidden = false
                        self.addRightView()
                    }
                }
            }

        }
        cell.contentView.tag = section
        cell.contentView.isUserInteractionEnabled = true
        cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sectionHeaderAct(_:))))
        return cell
    }
    @objc func sectionHeaderAct(_ tap: UITapGestureRecognizer) {
        let tapView = tap.view
        if self.isProductCondition {
            if isSearchFlag {
                self.selectedProductCondition = "\(self.filterProductCondition[tapView?.tag ?? 0].id ?? 0)"
            }
            else {
                self.selectedProductCondition = "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition[tapView?.tag ?? 0].id ?? 0)"
            }
            self.productDelegate?.updateProductCondition(self.selectedProductCondition)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            self.selectedSubIndex = tapView?.tag ?? 0
            if isChildFilter {
                let filterVal = isSearchFlag ? self.parentFilterArray[self.selectedSubIndex] : self.parentFilter?.parentValues[self.selectedSubIndex]
                if let values = filterVal {
                    if !(self.updateFilterData?.multilevel.contains(where: {$0.id == values.childId && $0.catType == (categoryFilter?.categoryType ?? "")}) ?? false) {
                        if !self.isFromFilter {
                            // Check child is from same parent or not
                            if let category = self.categoryFilter, let updatedData = self.updateFilterData {
                                
                                for cat in category.values {
                                    for value in cat.parentValues {
                                        updatedData.multilevel.removeAll(where: {$0.id == value.childId && $0.catType == category.categoryType})
                                    }
                                }
                            }
                        }
                        self.updateFilterData?.multilevel.append(FilterSubModel(catType: (categoryFilter?.categoryType ?? ""), id: values.childId))
                        self.tableView.reloadData()
                        DispatchQueue.main.async {
                            if let filter = self.updateFilterData {
                                self.productDelegate?.updateFilterData(filter)
                            }
                        }
                    }
                    else {
                        self.updateFilterData?.multilevel.removeAll(where: {$0.id == values.childId && $0.catType == (categoryFilter?.categoryType ?? "")})
                    }
                }
            }
            else {
                let filterVal = isSearchFlag ? self.categoryFilterarray[self.selectedSubIndex] : self.categoryFilter?.values[self.selectedSubIndex]
                if let values = filterVal {
                    if values.parentValues.count == 0 {
                        // Check if filter already contains the same value
                        if !(self.updateFilterData?.dropdown.contains(where: {$0.id == values.parentId && $0.catType ==  (self.categoryFilter?.categoryType ?? "")}) ?? false) {
                            // If filter from FilterViewController or not
                            if !self.isFromFilter {
                                // Check child is from same parent or not
                                if let category = self.categoryFilter, let updatedData = self.updateFilterData {
                                    for value in category.values {
                                        updatedData.dropdown.removeAll(where: {$0.id == value.parentId && $0.catType == category.categoryType})
                                    }
                                }
                            }
                            self.updateFilterData?.dropdown.append(FilterSubModel(catType: (categoryFilter?.categoryType ?? ""), id: values.parentId))
                            self.tableView.reloadData()
                            DispatchQueue.main.async {
                                if !self.isFromFilter {
                                    if let filter = self.updateFilterData {
                                        self.productDelegate?.updateFilterData(filter)
                                    }
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                        else {
                            self.updateFilterData?.dropdown.removeAll(where: {$0.id == values.parentId && $0.catType == (categoryFilter?.categoryType ?? "")})
                        }
                    }
                    else {
                        let pageObj = ProductConditionViewController()
                        pageObj.isProductCondition = false
                        pageObj.isChildFilter = true
                        pageObj.productDelegate = self
                        
                        pageObj.isFromFilter = self.isFromFilter
                        pageObj.updateFilterData = self.updateFilterData
                        pageObj.parentFilter = filterVal
                        pageObj.categoryFilter = self.categoryFilter
                        self.navigationController?.pushViewController(pageObj, animated: true)
                    }
                }
                self.addRightView()
            }
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
            cell.searchLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.searchImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.checkImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }else{
            cell.searchLabel.transform = .identity
            cell.searchImageView.transform = .identity
            cell.checkImageView.transform = .identity
        }
        return cell
    }
    func addRightView() {
        if (self.updateFilterData?.dropdown.count ?? 0) > 0 || (self.updateFilterData?.multilevel.count ?? 0) > 0 {
            if isFromFilter{
                self.navigationController?.customRightBarButtonView(title: "", fColor: "AppThemeColorNew", fontName: UIFont(name: APP_FONT_BOLD, size: 12), imageName: "select-tick-white", isLeft: false, vc: self, transparantView: false)
            }else{
//                self.navigationController?.customRightBarButtonView(title: "", fColor: "AppThemeColor", fontName: UIFont(name: APP_FONT_BOLD, size: 12), imageName: "", isLeft: false, vc: self, transparantView: false)
                self.navigationController?.navigationItem.rightBarButtonItem = nil
            }
         }
        else {
//            self.navigationController?.customRightBarButtonView(title: "", fColor: "", fontName: UIFont(name: APP_FONT_BOLD, size: 12), imageName: "", isLeft: false, vc: self, transparantView: false)
            self.navigationController?.navigationItem.rightBarButtonItem = nil
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.placeholder = getLanguage["search"] ?? "search"
    }
}
extension ProductConditionViewController: ProductConditionDelegate {
    func updateFilterData(_ updateFilterData: UpdateFilterModel) {
        if self.isFromFilter {
            self.updateFilterData = updateFilterData
//            FILTER_DATA.filters = Utility.shared.filterDictToString(updateFilterData)
            self.tableView.reloadData()
        }
        else {
            self.updateFilterData = updateFilterData
            ADD_EDIT_ITEM_MODEL.filters = Utility.shared.filterDictToString(updateFilterData)
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            if viewControllers.count >= 3 {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func updateProductCondition(_ productCondition: String) {
    }
}
