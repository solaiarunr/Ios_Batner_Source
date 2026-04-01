//
//  SearchViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 15/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Stripe

protocol SearchDelegate {
    func updateSearchData(_ searchData: FilterDataModel)
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ProductindictorImg: UIImageView!
    @IBOutlet weak var NameindictorImg: UIImageView!
    
    @IBOutlet weak var NameNoitemStack: UIStackView!
    var searchArray = [String]()
    var nameArray = [String]()
    var updateFilterData: UpdateFilterModel?
    var viewType = 0
    var searchDelegate: SearchDelegate?
    var type = "product"
    // If VC from filterViewController FILTER_DATA value be updated
    var isFromFilter = false
    /*
     ViewType == 0 -> List Title Search || ViewType == 1 -> Category ||
     viewType == 2 -> Category Filter  || viewType == 3 -> Product Condition
     */
    var categoryFilter: ProductFilterModel?
    
    var viewModel = AdminViewModel()
    var selectedCategory: CategoryModel?
    var selectedSubIndex: Int!
    
    var isSearchFlag = false
    var filterCategory = [SubcategoryModel]()
    let delegate = UIApplication.shared.delegate as! AppDelegate

    var categoryData = FilterDataModel()
    let ProfileVM = ProfileViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubview(indicatorView)
        self.updateCategoryValues()
        self.noItemStackView.isHidden = true
        self.NameNoitemStack.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "no_search_history_found")
//        self.navigationController?.customNavigationBarView(title: "search", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        if self.viewType == 1 {
            self.title = (self.selectedCategory?.categoryName ?? "")
        }
        else if self.viewType == 2 {
            self.title = (self.categoryFilter?.label) ?? ""
        }
        else if self.viewType == 3 {
            self.title = getLanguage["itemcondition"] ?? ""
        }
//        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        self.tableView.register(UINib(nibName: "FilterHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterHeaderTableViewCell")
        self.searchTextField.cornerMiniumRadius()
        self.searchTextField.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "search", font: UIFont(name: APP_FONT_REGULAR, size: 15))
        self.searchTextField.textFieldWithRightView(title: "", image: #imageLiteral(resourceName: "search_btn"))
        self.searchArray = UserDefaultModule.shared.getSearcgResult()
        self.nameArray = UserDefaultModule.shared.getnameResult()
        self.tableView.estimatedSectionHeaderHeight = 45
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 10
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        if self.viewType == 1 {
            self.loadData()
        }
//        self.searchTextField.becomeFirstResponder()
    }
    
    

    func updateCategoryValues() {
        // Check is from FilterVC then update CategoryValue to FILTER_DATA
        if isFromFilter {
            self.categoryData = FILTER_DATA
        }
        else {
//            self.categoryData = ADD_EDIT_ITEM_MODEL
        }
    }
    
    
    @IBAction func ProductbtnTapped(_ sender: Any) {
        self.type = "product"
        self.noItemStackView.isHidden = true
        self.ProductindictorImg.isHidden = false
        self.NameindictorImg.isHidden = true
        self.tableView.reloadData()
    }
    
    
    @IBAction func UserbtnTapped(_ sender: Any) {
        if self.nameArray.count > 0 {
            self.noItemStackView.isHidden = true
        }else{
            self.noItemStackView.isHidden = false
        }
        self.type = "user"
        self.ProductindictorImg.isHidden = true
        self.NameindictorImg.isHidden = false
        self.tableView.reloadData()
    }
    
    
    
@IBAction func backbtnTapped(_ sender: Any) {
        if self.viewType == 2, let filters = self.updateFilterData {
            categoryData.filters = Utility.shared.filterDictToString(filters)
            self.searchDelegate?.updateSearchData(categoryData)
        } else {
            self.searchDelegate?.updateSearchData(categoryData)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    func loadInitialVC() {
        let vc = InitialViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.isFromList = true
        self.present(vc, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.updateTheme(page: "present")
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    func loadData() {
        if self.viewType != 0 {
            ADMIN_VIEW_MODEL.getAdminData(onSuccess: { (success) in
                StripeAPI.defaultPublishableKey = (ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? "")
                self.tableView.reloadData()
            }) { (failure) in
            }
        }
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
                if self.viewType == 2, let filters = self.updateFilterData {
                    categoryData.filters = Utility.shared.filterDictToString(filters)
                    self.searchDelegate?.updateSearchData(categoryData)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                self.searchDelegate?.updateSearchData(categoryData)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if self.viewType == 1 {
            var subCategorySet = [SubcategoryModel]()
            if let subCategoryArray = self.selectedCategory?.subcategory, subCategoryArray.count > 0 {
                subCategorySet = subCategoryArray
            }
            if subCategorySet.contains(where: {$0.subName.localizedCaseInsensitiveContains(sender.text!)}) {
                if subCategorySet.filter({i in filterCategory.contains(where: {i.subId == $0.subId})}).count == 0 {
                    let filterVal = subCategorySet.filter({$0.subName.localizedCaseInsensitiveContains(sender.text!)})
                    if let firstVal = filterVal.first {
                        filterCategory.append(firstVal)
                    }
                    
                }
            }
            if filterCategory.count > 0 && sender.text != "" {
                self.isSearchFlag = true
            }
            else {
                self.isSearchFlag = false
            }
            self.tableView.reloadData()
        }
    }
}
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewType == 0 {
            if self.type == "product"{
                if self.searchArray.count > 0 {
                    return (self.searchArray.count + 1)
                }
                return self.searchArray.count
            }else{
                if self.nameArray.count > 0 {
                    return (self.nameArray.count + 1)
                }
                return self.nameArray.count
            }
        }
        else if self.viewType == 1 {
            if selectedSubIndex != nil, section == selectedSubIndex {
                if let childCategory = self.selectedCategory?.subcategory[section] {
                    return childCategory.childCategory.count
                }
            }
        }
        else if self.viewType == 2 {
            if self.categoryFilter?.type == "multilevel" && selectedSubIndex != nil {
                return (self.categoryFilter?.values[section].parentValues.count ?? 0)
            }
            else {
                return 0
            }
        }
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.viewType == 0 {
            return 1
        }
        else {
            if !isSearchFlag {
                if self.viewType == 1{
                    return (self.selectedCategory?.subcategory.count ?? 0)
                }
                else if self.viewType == 2 {
                    return (self.categoryFilter?.values.count ?? 0)
                }
                else if self.viewType == 3 {
                    return (ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.count ?? 0)
                }
            }
            else {
                if self.viewType == 1{
                    return self.filterCategory.count
                }
                else if self.viewType == 2 {
                    
                }
                else {
                    
                }
                
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewType == 0 {
            return nil
        }
        else {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterHeaderTableViewCell") as! FilterHeaderTableViewCell
            cell.headerLabel.textColor = UIColor(named: "AppTextColor")
            cell.overAllView.backgroundColor = UIColor(named: "whitecolor")
            cell.checkImageView.isHidden = true
            cell.arrowImageView.isHidden = true
            if self.viewType == 1 {
                if self.isSearchFlag {
                    cell.headerLabel.text = self.filterCategory[section].subName ?? ""
                }
                else{
                    cell.headerLabel.text = self.selectedCategory?.subcategory[section].subName ?? ""

                }
                if (self.selectedCategory?.subcategory[section].childCategory.count ?? 0) > 0 {
                    cell.arrowImageView.isHidden = false
                }
                
                if self.selectedSubIndex == section {
                    cell.checkImageView.isHidden = false
                }
            }
            else if self.viewType == 2 {
                cell.headerLabel.text = self.categoryFilter?.values[section].parentLabel
                if self.updateFilterData?.dropdown.contains(where: {$0.id == self.categoryFilter?.values[section].parentId && $0.catType == self.categoryFilter?.categoryType}) ?? false {
                    cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
                }
                if (self.categoryFilter?.values[section].parentValues.count ?? 0) > 0 {
                    cell.arrowImageView.isHidden = false
                    if (self.updateFilterData?.dropdown.filter({i in (self.categoryFilter?.values[section].parentValues.contains(where: {i.id == $0.childId}) ?? false && i.catType == self.categoryFilter?.categoryType)}).count ?? 0) > 0 {
                        cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
                    }
                }
            }
            else if self.viewType == 3 {
                cell.arrowImageView.isHidden = false
                cell.headerLabel.text = ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition[section].name ?? ""
                if categoryData.product_condition == (cell.headerLabel.text!) {
                    cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
                }
            }
            cell.contentView.tag = section
            cell.contentView.isUserInteractionEnabled = true
            cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sectionHeaderAct(_:))))
            return cell
        }
    }
    @objc func sectionHeaderAct(_ tap: UITapGestureRecognizer) {
        let tapView = tap.view

        if self.viewType == 1 {
            self.selectedSubIndex = tapView?.tag ?? 0
            self.tableView.reloadData()
            categoryData.Category_id = "\(self.selectedCategory?.categoryId ?? 0)"
            if let subcategory = self.selectedCategory?.subcategory[selectedSubIndex] {
                categoryData.subcategory_id = "\(subcategory.subId ?? 0)"
                if subcategory.childCategory.count == 0 {
                    UserDefaultModule.shared.setFilterData(FILTER_DATA)
                    FILTER_DATA = categoryData
                    delegate.checkTheme()
                    delegate.setInitialViewController(initialView: TabbarController())
                }
            }
        }
        else if self.viewType == 2 {
            self.selectedSubIndex = tapView?.tag ?? 0
            if let values = self.categoryFilter?.values[self.selectedSubIndex] {
                if values.parentValues.count == 0 {
                    if !(self.updateFilterData?.dropdown.contains(where: {$0.id == values.parentId && $0.catType == (self.categoryFilter?.type ?? "")}) ?? false) {
                        self.updateFilterData?.dropdown.append(FilterSubModel(catType: (self.categoryFilter?.type ?? ""), id: values.parentId))
                    }
                }
            }
            self.tableView.reloadData()
            self.addRightView()
        }
        else if self.viewType == 3 {
            categoryData.product_condition = ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition[tapView?.tag ?? 0].name ?? ""
            self.searchDelegate?.updateSearchData(categoryData)
            self.navigationController?.popViewController(animated: true)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
        cell.searchStackView.spacing = 10
        if self.viewType == 0 {
            if self.type == "product"{
                if indexPath.row < self.searchArray.count {
                    cell.searchImageView.image = #imageLiteral(resourceName: "clock")
                    cell.searchLabel.text = self.searchArray[indexPath.row]
                }
                else {
                    cell.searchImageView.image = #imageLiteral(resourceName: "close-gray")
                    cell.searchLabel.text = getLanguage["Clear History"]
                }
            }else{
                if indexPath.row < self.nameArray.count {
                    cell.searchImageView.image = #imageLiteral(resourceName: "clock")
                    cell.searchLabel.text = self.nameArray[indexPath.row]
                }
                else {
                    cell.searchImageView.image = #imageLiteral(resourceName: "close-gray")
                    cell.searchLabel.text = getLanguage["Clear History"]
                }

            }
        }
        else if self.viewType == 1 {
            if let subcategory = self.selectedCategory?.subcategory[indexPath.section] {
                cell.loadCategoryData(subcategory.childCategory[indexPath.row].childName)
            }
        }
        else if self.viewType == 2 {
            if let value = self.categoryFilter?.values[indexPath.section] {
                cell.searchLabel.textColor = UIColor(named: "appblackcolor")
                cell.loadCategoryData(value.parentValues[indexPath.row].childName)
                if (self.updateFilterData?.dropdown.filter({i in (value.parentValues.contains(where: {i.id == $0.childId && i.catType == (self.categoryFilter?.categoryType ?? "")}))}).count ?? 0) > 0 {
                    cell.searchLabel.textColor = UIColor(named: "AppThemeColorNew")
                }
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.viewType == 0 {
            if self.type == "product"{
                if indexPath.row < self.searchArray.count {
                    categoryData.Search_key = self.searchArray[indexPath.row]
                    IS_FILTER_FOUND = true
                    self.searchDelegate?.updateSearchData(categoryData)
                    delegate.setInitialViewController(initialView: TabbarController())
//                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    IS_FILTER_FOUND = false
                    self.searchArray.removeAll()
                    UserDefaultModule.shared.setSearchResult(self.searchArray)
                    categoryData.Search_key = ""
                    self.tableView.reloadData()
                }
            }else{
                if indexPath.row < self.nameArray.count {
                    print("indexPathself",self.nameArray[indexPath.row])
                    if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                        //                    self.navigationController?.popViewController(animated: true)
                        Utility.shared.startAnimation(viewController: self)
                        self.ProfileVM.Otherusernamechecking(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", search_user: self.nameArray[indexPath.row], onSuccess: {(success) in
                            //                        self.tableView.reloadData()
                            if self.ProfileVM.otherprofileModel?.status == "true"{
                                self.ProfileVM.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: self.ProfileVM.otherprofileModel?.profile_id ?? "", onSuccess: { (success) in
                                    Utility.shared.stopAnimation(viewController: self)
                                    print(success)
                                    if success {
                                        let pageObj = ViewProfileViewController()
                                        pageObj.isfrom = "Searchpage"
                                        pageObj.userId = self.ProfileVM.otherprofileModel?.profile_id ?? ""
                                        self.navigationController?.pushViewController(pageObj, animated: true)
                                    }
                                }) { (failure) in
                                    Utility.shared.stopAnimation(viewController: self)
                                }
                            }else{
                                Utility.shared.stopAnimation(viewController: self)
                                let alertController = UIAlertController(title: getLanguage["alert"] ?? "alert", message: getLanguage["UserNotFound"] ?? "User Not Found", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: { (UIAlertAction) in
                                    //                                self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }, onFailure: { (failure) in
                            Utility.shared.stopAnimation(viewController: self)
                        })
                        
                    }else{
                        self.loadInitialVC()
                    }
                }
                else {
                    self.noItemStackView.isHidden = false
                    self.nameArray.removeAll()
                    UserDefaultModule.shared.setnameResult(self.nameArray)
                    self.tableView.reloadData()
                }
            }
            
        }
        else if self.viewType == 1 {
            if let subcategory = self.selectedCategory?.subcategory[selectedSubIndex], subcategory.childCategory.count > indexPath.row {
                categoryData.child_category_id = "\(subcategory.childCategory[indexPath.row].childId ?? 0)"
                FILTER_DATA = categoryData
                delegate.checkTheme()
                delegate.setInitialViewController(initialView: TabbarController())
            }
        }
        else if self.viewType == 2 {
            if let values = self.categoryFilter?.values[self.selectedSubIndex] {
                if values.parentValues.count > indexPath.row {
                    if !(self.updateFilterData?.dropdown.contains(where: {i in (values.parentValues[indexPath.row].childId == i.id && (self.categoryFilter?.categoryType ?? "") == i.catType)}) ?? false) {
                        self.updateFilterData?.dropdown.append(FilterSubModel(catType: (self.categoryFilter?.categoryType ?? ""), id: values.parentValues[indexPath.row].childId))
                    }
                }
            }
            self.addRightView()
        }
    }
    func addRightView() {
        if (self.updateFilterData?.dropdown.count ?? 0) > 0 {
            self.navigationController?.customRightBarButtonView(title: "", fColor: "AppThemeColorNew", fontName: UIFont(name: APP_FONT_BOLD, size: 12), imageName: "select-tick-white", isLeft: false, vc: self, transparantView: false)
        }
        else {
            self.navigationController?.customRightBarButtonView(title: "", fColor: "", fontName: UIFont(name: APP_FONT_BOLD, size: 12), imageName: "", isLeft: false, vc: self, transparantView: false)
        }
    }
}
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        if self.viewType == 1 {
            
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.placeholder = getLanguage["search"] ?? "search"
        if self.viewType == 0 {
            if textField.text != "" {
                if self.type == "product"{
                    self.searchArray.append(textField.text!)
                    IS_FILTER_FOUND = true
                    UserDefaultModule.shared.setSearchResult(self.searchArray)
                    categoryData.Search_key = textField.text!
                    self.searchDelegate?.updateSearchData(categoryData)
                    delegate.setInitialViewController(initialView: TabbarController())
//                    self.navigationController?.popViewController(animated: true)
                }else{
                    if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                        self.nameArray.append(textField.text!)
                        self.noItemStackView.isHidden = true
                        UserDefaultModule.shared.setnameResult(self.nameArray)
                        Utility.shared.startAnimation(viewController: self)
                        self.ProfileVM.Otherusernamechecking(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", search_user: textField.text!, onSuccess: {(success) in
                            self.tableView.reloadData()
                            if self.ProfileVM.otherprofileModel?.status == "true"{
                                self.ProfileVM.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: self.ProfileVM.otherprofileModel?.profile_id ?? "", onSuccess: { (success) in
                                    Utility.shared.stopAnimation(viewController: self)
                                    print(success)
                                    if success {
                                        let pageObj = ViewProfileViewController()
                                        pageObj.userId = self.ProfileVM.otherprofileModel?.profile_id ?? ""
                                        self.navigationController?.pushViewController(pageObj, animated: true)
                                    }
                                }) { (failure) in
                                }
                            }else{
                                self.tableView.reloadData()
                                Utility.shared.stopAnimation(viewController: self)
                                let alertController = UIAlertController(title: getLanguage["alert"] ?? "alert", message: getLanguage["UserNotFound"] ?? "User Not Found", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: { (UIAlertAction) in
                                    //                                self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }, onFailure: { (failure) in
                            Utility.shared.stopAnimation(viewController: self)
                        })
                    }else{
                        self.loadInitialVC()
                    }
//                    self.navigationController?.popViewController(animated: true)
                }
               
            }
        }
    }
}
