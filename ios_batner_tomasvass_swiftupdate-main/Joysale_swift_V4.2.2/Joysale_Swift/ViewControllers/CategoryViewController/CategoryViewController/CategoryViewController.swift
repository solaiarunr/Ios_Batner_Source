//
//  CategoryViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 25/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Stripe

protocol CategoryDelegate {
    func updateCategoryData(_ searchData: CategoryDetailsModel)
    func loadadmindata()
}
class CategoryViewController: UIViewController {
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionViewConst: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var delegate: CategoryDelegate?
//    var ResultFromModel = AdminResultModel()
    var CategoryDetails = CategoryDetailsModel()
    var subCategory = [SubcategoryModel]()
    var filterCategory = [SubcategoryModel]()
    var categoryViewType = 0
    
    var categoryIndex: Int = 0
    var subCategoryIndex: Int?
    var childCategoryIndex: Int?
    var isSearchFlag = false
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var isFromFilter = true
    var adminResult: AdminResultModel!
    var bannerView1: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func configUI() {
        
        self.view.addSubview(indicatorView)
        self.categoryCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        self.tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        self.tableView.register(UINib(nibName: "ViewAllTableViewCell", bundle: nil), forCellReuseIdentifier: "ViewAllTableViewCell")
        self.tableView.register(UINib(nibName: "FilterHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterHeaderTableViewCell")
        self.searchTextField.cornerMiniumRadius()
        self.searchTextField.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "search", font: UIFont(name: APP_FONT_REGULAR, size: 17))
        self.searchTextField.textFieldWithRightView(title: "", image: #imageLiteral(resourceName: "search_btn"))

        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 45
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 10
        
        self.collectionViewConst.priority = .defaultHigh
        self.loadCategoryIndex()
        self.searchView.isHidden = true
        if self.categoryViewType == 0 {
            self.tableView.isHidden = true
            self.collectionViewConst.priority = .defaultLow
        }
        else if self.categoryViewType == 2 {
            self.collectionViewConst.priority = .defaultLow
            self.categoryCollectionView.isHidden = true
            self.tableView.isHidden = false
            self.searchView.isHidden = false
            if self.subCategory.count > (self.subCategoryIndex ?? 0) {
                self.navigationController?.customNavigationBarView(title: (self.subCategory[subCategoryIndex ?? 0].subName ?? ""), fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
            }
        }
        else {
            self.navigationController?.customNavigationBarView(title: "category", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        }
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.searchTextField.addDoneButtonOnKeyboard()
        self.loadData()
        self.checkAdStatusAndLoadBanner()
        /*** Addons */
//       self.loadBannerView()
    }
    func checkAdStatusAndLoadBanner() {
        if Ad_Status {
            self.loadBannerView()
        }else{
            self.bannerView.isHidden = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
//        self.loadBannerView()
        self.checkAdStatusAndLoadBanner()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
            }
            else {
                self.delegate?.loadadmindata()
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
        group.enter()
        ADMIN_VIEW_MODEL.productBeforeAddData(onSuccess: { (success) in
            group.leave()
        }) { (failure) in
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            self.loadCategoryIndex()
         }
    }
    func loadBannerView() {
//        self.bannerView.isHidden = true
        
//        if (ADMIN_VIEW_MODEL.adminModel?.result.googleAds ?? "").lowercased() == "enable" {
            // MARK: Banner Ads AddOn
            bannerView1 = GADBannerView(adSize: GADAdSizeBanner)
            bannerView1.translatesAutoresizingMaskIntoConstraints = false
            bannerView.addSubview(bannerView1)
            bannerView1.leftAnchor.constraint(equalTo: bannerView.leftAnchor, constant: 0).isActive = true
            bannerView1.rightAnchor.constraint(equalTo: bannerView.rightAnchor, constant: 0).isActive = true
            bannerView1.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 0).isActive = true
            bannerView1.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 0).isActive = true
            
            self.bannerView1.frame  = self.bannerView.bounds
            self.bannerView.isHidden = false
            self.bannerView1.adUnitID = BANNNER_ID
            self.bannerView1.rootViewController = self
            self.bannerView1.load(GADRequest())
            self.bannerView1.delegate = self
//        }
 
    }
    func loadCategoryIndex() {
        //solai
        if let result = ADMIN_VIEW_MODEL.adminModel?.result {
            // Filter out categories where categoryId == 0
            self.adminResult = result
            self.adminResult.category = self.adminResult.category.filter { $0.categoryId != 0 }
            
            // Check if Category_id is empty and set it to the first categoryId
            if (self.CategoryDetails.Category_id ?? "0") == "" {
                self.CategoryDetails.Category_id = "\(self.adminResult.category.first?.categoryId ?? 0)"
            }
            
            // Find the index of the selected category
            self.categoryIndex = self.adminResult.category.firstIndex(where: { $0.categoryId == (Int(self.CategoryDetails.Category_id ?? "0")) }) ?? 0
            
            // If the category exists, set the subcategories
            if self.adminResult.category.count > self.categoryIndex {
                self.subCategory = self.adminResult.category[self.categoryIndex].subcategory
            }
            
            // Reset the filter category array and determine the subcategory index
            self.filterCategory.removeAll()
            self.subCategoryIndex = self.subCategory.firstIndex(where: { $0.subId == (Int(self.CategoryDetails.subcategory_id ?? "")) })
            
            // Find the child category index if the subcategory exists
            if let subIndex = self.subCategoryIndex, self.subCategory.count > subIndex {
                self.childCategoryIndex = self.subCategory[subIndex].childCategory.firstIndex(where: { $0.childId == (Int(self.CategoryDetails.child_category_id ?? "")) })
            }
        }
        
        // Reload the collection view and table view
        self.categoryCollectionView.reloadData()
        self.tableView.reloadData()
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        var subCategorySet = [SubcategoryModel]()
        if let category = self.adminResult.category {
            if self.categoryIndex < category.count {
                self.subCategory = category[self.categoryIndex].subcategory
                self.filterCategory.removeAll()
            }
        }
        
        if subCategory.count > 0 {
            subCategorySet = subCategory
        }
        let filterVal = subCategorySet.filter({$0.subName.localizedCaseInsensitiveContains(sender.text!)})
        if filterVal.count > 0 {
            for filter in filterVal {
                if filterCategory.filter({$0.subId == filter.subId}).count == 0 {
                    filterCategory.append(filter)
                }
            }
        }
        if filterCategory.count == 0 && self.searchTextField.text == "" {
            self.isSearchFlag = false
        }
        else {
            self.isSearchFlag = true
        }
        self.tableView.reloadData()
    }
}
extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.adminResult.category.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell

        cell.highlightedView.isHidden = true
        cell.highlightedImageView.isHidden = true
        cell.categoryStackView.spacing = 10
        cell.categoryTopConst.constant = 15
        
//        if let category = self.adminResult.category[indexPath.row] {
//            cell.loadData(category, viewType: false)
//        }
        
       let category = self.adminResult.category[indexPath.row]
            cell.loadData(category, viewType: false)
            if self.CategoryDetails.Category_id != nil {
                if self.categoryViewType == 1 && "\(category.categoryId ?? 0)" == self.CategoryDetails.Category_id {
                    cell.highlightedView.isHidden = false
                    cell.highlightedImageView.isHidden = false
                }
            }
//        }
        if self.categoryViewType == 1 && self.categoryIndex == indexPath.row {
            cell.highlightedView.isHidden = false
            cell.highlightedImageView.isHidden = false
            cell.categoryImageView.layer.cornerRadius = 37.5
            cell.categoryImageView.clipsToBounds = true
            cell.categoryImageView.contentMode = .scaleToFill
        }
        else {
            cell.categoryImageView.layer.cornerRadius = 35
            cell.categoryImageView.clipsToBounds = true
            cell.categoryImageView.contentMode = .scaleToFill
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell: CategoryCollectionViewCell = Bundle.main.loadNibNamed("CategoryCollectionViewCell", owner: self,options: nil)?.first as? CategoryCollectionViewCell else {
            return CGSize.zero
        }
        cell.categoryImageView.image = #imageLiteral(resourceName: "profilelogo")
        cell.categoryNameLabel.text = ""
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if self.categoryViewType == 0 {
            if (self.adminResult.category.count) % 2 == 1 {
                if indexPath.row == ((self.adminResult.category.count) - 1) {
                    return CGSize(width: (collectionView.frame.width), height: 140)
                }
                else {
                    return CGSize(width: (collectionView.frame.width / 2), height: 140)
                }
            }
            else {
                return CGSize(width: (collectionView.frame.width / 2), height: 140)
            }

        }
        else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.CategoryDetails.Category_id = "\(self.adminResult.category[indexPath.row].categoryId ?? 0)"
        self.CategoryDetails.subcategory_id = ""
        self.CategoryDetails.child_category_id = ""

            if (self.adminResult.category[indexPath.row].subcategory.count ?? 0) > 0 {
                if self.categoryViewType == 0 {
                    let pageObj = CategoryViewController()
                    pageObj.CategoryDetails = self.CategoryDetails
                    pageObj.subCategory = self.subCategory
                    pageObj.delegate = self
                    pageObj.categoryViewType = 2
                    self.categoryIndex = indexPath.row
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
                else {
                    self.categoryIndex = indexPath.row
                    self.subCategoryIndex = nil
                    self.categoryCollectionView.reloadData()
                    self.tableView.reloadData()
                }
            }
            else {
                if self.categoryViewType == 1 {
                    self.backToHomePage()
                }
                else {
                    delegate?.updateCategoryData(self.CategoryDetails)
                    self.tabBarController?.selectedIndex = 0
                }
            }
        }
}
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = isFromFilter ? section-1 : section
        if section == 0 && isFromFilter{
            return 1
        }
        else {
            if (currentSection < self.subCategory.count) {
                if subCategoryIndex != nil, currentSection == subCategoryIndex {
                    if self.subCategory[currentSection].childCategory.count > 0 {
                        return isFromFilter ? (self.subCategory[currentSection].childCategory.count + 1) : self.subCategory[currentSection].childCategory.count
                    }
                    else {
                        return self.subCategory[currentSection].childCategory.count
                    }
                }
            }
        }
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if let category = self.adminResult.category {
            if self.isSearchFlag {
                if self.subCategory.count > 0 {
                    return isFromFilter ? self.filterCategory.count+1 : self.filterCategory.count
                }
            }
            else {
                if self.categoryIndex < category.count {
                    self.subCategory = category[self.categoryIndex].subcategory
                    self.filterCategory.removeAll()
                    if self.subCategory.count > 0 {
                        return isFromFilter ? (self.subCategory.count + 1) : self.subCategory.count
                    }
                }
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && isFromFilter{
            return 0
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && isFromFilter{
            return nil
        }
        else {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterHeaderTableViewCell") as! FilterHeaderTableViewCell
            cell.lineView.isHidden = false
            cell.viewBottomConst.constant = 0
            let currentSection = isFromFilter ? section-1 : section
            cell.overAllView.backgroundColor = UIColor(named: "clearcolor")
            cell.checkImageView.isHidden = true
            cell.arrowImageView.isHidden = true
            cell.headerLabel.textColor = UIColor(named: "AppTextColor")
            if self.isSearchFlag {
                cell.headerLabel.text = self.filterCategory[currentSection].subName ?? ""
                if self.filterCategory[currentSection].childCategory.count > 0 {
                    cell.arrowImageView.isHidden = false
                }
            }
            else {
                cell.headerLabel.text = self.subCategory[currentSection].subName ?? ""
                if self.subCategory[currentSection].childCategory.count > 0 {
                    cell.arrowImageView.isHidden = false
                }
            }
            
            
            if (self.subCategoryIndex == currentSection) {
                cell.checkImageView.isHidden = false
                cell.headerLabel.textColor = UIColor(named: "AppThemeColorNew")
            }
            cell.contentView.tag = currentSection
            cell.contentView.isUserInteractionEnabled = true
            cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sectionHeaderAct(_:))))
            return cell
        }
    }
    @objc func sectionHeaderAct(_ tap: UITapGestureRecognizer) {
        let tapView = tap.view
        self.subCategoryIndex = tapView?.tag ?? 0
        
        // Get Selected Sub Category
        var selectedSub: SubcategoryModel?
        if self.isSearchFlag {
            selectedSub = self.filterCategory[self.subCategoryIndex ?? 0]
        }
        else {
            selectedSub = self.subCategory[self.subCategoryIndex ?? 0]
        }
        if let sub = selectedSub {
            self.CategoryDetails.subcategory_id = "\(sub.subId ?? 0)"
            self.CategoryDetails.child_category_id = ""
            if sub.childCategory.count > 0 {
                self.tableView.reloadData()
            }
            else {
                self.backToHomePage()
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && self.isFromFilter{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAllTableViewCell") as! ViewAllTableViewCell
            cell.checkImageView.isHidden = true
            if self.CategoryDetails.subcategory_id == "viewall" {
                cell.checkImageView.isHidden = false
                cell.viewAllButton.setTitleColor(UIColor(named: "AppThemeColorNew"), for: .normal)
            }
            else {
                cell.viewAllButton.setTitleColor(UIColor(named: "appblackcolor"), for: .normal)
            }
            cell.viewAllButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
            return cell
        }
        else {
            let currentSection = isFromFilter ? (indexPath.section - 1) : indexPath.section
            let currentRow = isFromFilter ? (indexPath.row - 1) : indexPath.row
            if indexPath.row == 0 && isFromFilter{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAllTableViewCell") as! ViewAllTableViewCell
                cell.checkImageView.isHidden = true
                cell.viewAllButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 18.5, bottom: 5, right: 18.5)
                if self.CategoryDetails.child_category_id == "viewall" {
                    cell.checkImageView.isHidden = false
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
                cell.checkImageView.isHidden = true
                cell.searchStackView.spacing = 10
                cell.searchLabel.textColor = UIColor(named: "appblackcolor")
                if self.isSearchFlag {
                    
                    if self.filterCategory[currentSection].childCategory.count > currentRow {
                        cell.loadCategoryData(self.filterCategory[currentSection].childCategory[currentRow].childName)
                        if "\(self.filterCategory[currentSection].childCategory[currentRow].childId ?? 0)" == self.CategoryDetails.child_category_id {
                            cell.checkImageView.isHidden = false
                        }
                    }
                }
                else {
                    cell.loadCategoryData(self.subCategory[currentSection].childCategory[currentRow].childName)
                    if "\(self.subCategory[currentSection].childCategory[currentRow].childId ?? 0)" == self.CategoryDetails.child_category_id {
                        cell.checkImageView.isHidden = false
                    }
                }
                cell.viewType = 0
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && isFromFilter{
            
            self.CategoryDetails.subcategory_id = "viewall"
            self.CategoryDetails.child_category_id = ""
            self.backToHomePage()
        }
        else {
            let currentSection = isFromFilter ? (indexPath.section-1) : indexPath.section
            let currentRow = isFromFilter ? (indexPath.row-1) : indexPath.row
            if indexPath.row == 0 && isFromFilter{
                self.CategoryDetails.child_category_id = "viewall"
                self.backToHomePage()
            }
            else{
                if self.isSearchFlag {
                    self.CategoryDetails.child_category_id = "\(self.filterCategory[currentSection].childCategory[currentRow].childId ?? 0)"
                }
                else {
                    self.CategoryDetails.child_category_id = "\(self.subCategory[currentSection].childCategory[currentRow].childId ?? 0)"
                }
                self.backToHomePage()
            }
        }
    }
    func backToHomePage() {
        delegate?.updateCategoryData(self.CategoryDetails)
        delegate?.loadadmindata()
        self.navigationController?.popViewController(animated: true)
    }
}
extension CategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.placeholder = getLanguage["search"] ?? "search"
    }
}
extension CategoryViewController: CategoryDelegate {
    func loadadmindata() {
        
    }
    
    func updateCategoryData(_ searchData: CategoryDetailsModel) {
        self.CategoryDetails = searchData
        delegate?.updateCategoryData(self.CategoryDetails)
        self.tabBarController?.selectedIndex = 0
    }
}

extension CategoryViewController: GADBannerViewDelegate{
    //banner view delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            bannerView.isHidden = false
        })
    }
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.bannerView.isHidden = true
        print("BANNER ERROR \(error.localizedDescription)")
    }
}

