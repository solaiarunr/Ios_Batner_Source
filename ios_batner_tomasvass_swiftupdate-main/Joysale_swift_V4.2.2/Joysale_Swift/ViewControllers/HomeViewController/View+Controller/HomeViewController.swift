//
//  HomeViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import GoogleMobileAds
import CoreLocation
import Stripe
class HomeViewController: UIViewController, customLocationDelegate {
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!
    @IBOutlet weak var bottomLoader: UIActivityIndicatorView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var NewNoitemStack: UIView!
    
    @IBOutlet weak var NoItemTiTleLblNew: UILabel!
    
    
    @IBOutlet weak var newLabel: UILabel!
    var bannerView1:GADBannerView!
    var viewModel = HomeViewModel()
    var isviewVisible = true
    var filterArray = [String]()
    var updateFilterDict: UpdateFilterModel?
    var categoryFilterArray = [ProductFilterModel]()
    private let refreshControl = UIRefreshControl()
    var lastContentOffset: CGFloat = 0
    var isLoadingMore = false // flag
    
    var itemModel = [ItemModel]()
    var offset = 0
    var isFound = true
    var search_type = ""
    var promotionTags = ""
    var passLikes = ""
    var getItemId = Int()
//    var selected_type_value = "image"
    var selected_type_value = "all"
    
    // Timer for Banner
    var timer: Timer?
    
    var ADviewType = String()
    var refreshFilter: ((_ refresh: Bool) -> Void)?
    let delegateapp = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(indicatorView)
        Utility.shared.startAnimation(viewController: self)
        self.configUI()
        self.loadAdminData()
        self.getCurrentLocation()
        self.checkAdStatusAndLoadBannerApiCall()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
           return self.updateStatusBarStyle()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callHomeAPI()
    }

    func callHomeAPI() {
        self.loadAdminData()
       
    }

    

 

    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme()
        self.loadFilterData()
        self.startTimer()
        

    }
    func getCurrentLocation() {
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() == .authorizedAlways) {
//            self.loadData()
            self.loadData(selected_type:self.selected_type_value)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.stopTimer()
    }
    func loadFilterData() {
        //        Load Filter Data
        FILTER_DATA = UserDefaultModule.shared.getFilterData()
        self.locationView.isHidden = false
        //        self.locationLabel.text = FILTER_DATA.location == "" ? "Worldwide" : FILTER_DATA.location
        self.locationLabel.text = FILTER_DATA.location == "" ? UserDefaultModule.shared.getcountryname() : FILTER_DATA.location
        
        let keys = Array(FILTER_DATA.toDictionary().keys)
        self.filterArray = keys.sorted()
        
        self.updateFilterDict = Utility.shared.filterStringToDict(FILTER_DATA.filters)
        self.getFilterArray()
        if self.filterArray.count > 0 {
            self.search_type = ""
            self.promotionTags = ""
            self.filterCollectionView.isHidden = false
        }
        else {
            self.search_type = "all"
            if (self.viewModel.getItemModel?.ads.count ?? 0) > 0 {
                self.promotionTags = self.convertIntoJSONString(arrayObject: (self.viewModel.getItemModel?.ads ?? [String]())) ?? ""
            }
           
            else {
                self.promotionTags = ""
            }
            if (FILTER_DATA.distance != "" && FILTER_DATA.isDistanceSlider && FILTER_DATA.location.lowercased() != UserDefaultModule.shared.getcountryname()?.lowercased()) {
            }
            else {
                self.filterCollectionView.isHidden = true
            }
        }
        DispatchQueue.main.async {
            self.filterCollectionView.reloadData()
            self.collectionView.reloadData()
        }
    }
    func configUI() {
        
        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.NoItemTiTleLblNew.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "noItem")
        
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "noItem")
        self.collectionView.register(UINib(nibName: "HomeCatogoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCatogoryCollectionViewCell")
        self.collectionView.register(UINib(nibName: "ProductSelectionCell", bundle: nil), forCellWithReuseIdentifier: "ProductSelectionCell")
        self.filterCollectionView.register(UINib(nibName: "HomeFilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeFilterCollectionViewCell")
        if let flowLayout = self.filterCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        self.collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        self.collectionView.register(UINib(nibName: "HomeHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeHeaderCollectionViewCell")
        self.locationView.cornerViewRadius()
        self.locationLabel.config(color: UIColor(named: "ThemeTextColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .center, text: "WorldWide")
        self.locationView.isUserInteractionEnabled = true
        if #available(iOS 10.0, *) {
            self.collectionView.refreshControl = refreshControl
        } else {
            self.collectionView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refreshAct), for: .valueChanged)
        self.collectionView.alwaysBounceVertical = true
        self.locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.locationViewAct)))
        
        
        /**** Addons******/
        
//        self.loadBannerAddOns()
        self.setupBalanceLabel()
    }
    
    func setupBalanceLabel() {
        let amount = "$ 12334.134 "
        let currency = "USD"

        let fullText = amount + currency

        let attributedString = NSMutableAttributedString(string: fullText)

        // Attributes for the amount
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor.black
        ], range: NSRange(location: 0, length: amount.count))

        // Attributes for the currency
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.gray
        ], range: NSRange(location: amount.count, length: currency.count))

        self.newLabel.attributedText = attributedString
    }
    
    func loadBannerAddOns() {
//       self.bannerView.isHidden = true
//        if (ADMIN_VIEW_MODEL.adminModel?.result.googleAds ?? "").lowercased() == "enable" {
            // MARK: Banner Ads AddOn
            bannerView1 = GADBannerView(adSize: GADAdSizeBanner)
            bannerView1.translatesAutoresizingMaskIntoConstraints = false
            bannerView.addSubview(bannerView1)
            bannerView1.leftAnchor.constraint(equalTo: bannerView.leftAnchor, constant: 0).isActive = true
            bannerView1.rightAnchor.constraint(equalTo: bannerView.rightAnchor, constant: 0).isActive = true
            bannerView1.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 0).isActive = true
            bannerView1.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 0).isActive = true
            print("self.chkbanneridhome2",BANNNER_ID)
            self.bannerView1.frame  = self.bannerView.bounds
            self.bannerView.isHidden = false
            self.bannerView1.adUnitID = BANNNER_ID
            self.bannerView1.rootViewController = self
            self.bannerView1.load(GADRequest())
            self.bannerView1.delegate = self
//       }
        
    }
    func checkAdStatusAndLoadBanner() {
        if Ad_Status {
            self.loadBannerAddOns()
        }else{
            self.bannerView.isHidden = true
            
        }
    }
    
    func checkAdStatusAndLoadBannerApiCall() {
        print("didcall1")
        ADMIN_VIEW_MODEL.GetAdStatus(user_id:UserDefaultModule.shared.getUserData()?.user_id ?? "",onSuccess: { (success) in
            if success == "true" {
                print("ADMIN_VIEW_MODELsytta",ADMIN_VIEW_MODEL.adModel?.adstatus ?? "")
                if ADMIN_VIEW_MODEL.adModel?.adstatus == "enable"{
                    print("solaienable")
                    Ad_Status = true
                }else{
                    print("disenable")
                    Ad_Status = false
                }
            }else{
            }
        }, onFailure: { (failure) in
            Ad_Status = true  
        })
         
        }
    
    @objc func locationViewAct() {
        // MARK: Mabbox Addon
        
        let pageObj = MapViewController()
        pageObj.delegate = self
        pageObj.isFromHome = true
        pageObj.locationString = FILTER_DATA.location
        print("sdwdke123",FILTER_DATA.location)
        self.navigationController?.pushViewController(pageObj, animated: true)
        
        //        let pageObj = LocationViewController()
        //        pageObj.delegate = self
        //        pageObj.locationString = FILTER_DATA.location
        //        self.navigationController?.pushViewController(pageObj, animated: true)
    }
    @objc func refreshAct() {
        self.offset = 0
        self.isFound = true
        if self.filterArray.count > 0 {
            self.search_type = ""
        }
        else {
            self.search_type = "all"
            self.promotionTags = ""
        }
        self.loadAdminData()
    }
    func convertIntoJSONString(arrayObject: [String]) -> String? {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: arrayObject, options: [])
            if  let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                return jsonString as String
            }
            
        } catch let error as NSError {
            print("Array convertIntoJSON - \(error.description)")
        }
        return nil
    }
    func loadAdminData() {
        ADMIN_VIEW_MODEL.getAdminData(onSuccess: { (success) in
            StripeAPI.defaultPublishableKey = (ADMIN_VIEW_MODEL.adminModel?.result.stripePublicKey ?? "")
            BANNNER_ID = (ADMIN_VIEW_MODEL.adminModel?.result.googleAdsIos ?? "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.checkAdStatusAndLoadBanner()
            }

            self.collectionView.reloadData()
            self.collectionView.bringSubviewToFront(self.refreshControl)
//            self.loadBannerAddOns()
        }) { (failure) in
            print("Msdcking",failure)
            
            self.collectionView.reloadData()
        }
        self.loadData(selected_type:self.selected_type_value)
    }
    
    
   
    func loadData(selected_type:String = "") {
        let type = selected_type.isEmpty ? "all" : selected_type
        if !indicatorView.isAnimating {
            self.refreshControl.layoutIfNeeded()
            self.refreshControl.beginRefreshing()
            self.locationView.isHidden = true
        }
        else {
            self.refreshControl.endRefreshing()
        }
        if self.filterArray.count == 0 && (FILTER_DATA.location == "" || FILTER_DATA.location.lowercased() == "worldwide" || FILTER_DATA.location.lowercased() == UserDefaultModule.shared.getcountryname()?.lowercased()) {
            self.search_type = "all"
            FILTER_DATA.lat = ""
            FILTER_DATA.long = ""
            if self.offset == 0 {
                self.promotionTags = ""
            }
        }
        else if (FILTER_DATA.location == "" || FILTER_DATA.location.lowercased() == "worldwide" || FILTER_DATA.location.lowercased() == UserDefaultModule.shared.getcountryname()?.lowercased()) {
            FILTER_DATA.lat = ""
            FILTER_DATA.long = ""
        }
        else if FILTER_DATA.location.lowercased() != "worldwide" &&  FILTER_DATA.getSortID() == "1" && FILTER_DATA.Category_id == "" && FILTER_DATA.Price == "0-5000" && FILTER_DATA.posted_within == "" && FILTER_DATA.Search_key == ""{
            self.search_type = "all"
            if self.offset == 0 {
                self.promotionTags = ""
            }
        }
        else {
            self.search_type = ""
            self.promotionTags = ""
        }
        self.updateFilterDict = Utility.shared.filterStringToDict(FILTER_DATA.filters)
        let multiString = (self.updateFilterDict?.multilevel.map({$0.id ?? ""}) ?? [String]())
        let dropDownString = (self.updateFilterDict?.dropdown.map({$0.id ?? ""}) ?? [String]())
        
        var rangeString: [Dictionary<String, String>] = []
        if let rangeModel = self.updateFilterDict?.range {
            for range in rangeModel {
                rangeString.append(range.toDictionary())
            }
        }
        let filterDict = ["dropdown": dropDownString, "multilevel": multiString, "range": rangeString] as [String : Any]
        let filterString = Utility.shared.filterRangeString(filterDict)
        let product_id = ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.filter({$0.id == Int(FILTER_DATA.product_condition)}).first?.id ?? 0
        
        
        print(FILTER_DATA.distance ?? "")
        if FILTER_DATA.distance == ""{
            FILTER_DATA.distance = "\(ADMIN_VIEW_MODEL.adminModel?.result.distance ?? "")"
            FILTER_DATA.distance_type = "\(ADMIN_VIEW_MODEL.adminModel?.result.distanceType ?? "")"
            print(FILTER_DATA.distance ?? "")
        }
        self.viewModel.getItems(type: "search", price: FILTER_DATA.Price, search_key: FILTER_DATA.Search_key, category_id: FILTER_DATA.Category_id, subcategory_id: FILTER_DATA.subcategory_id, user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", item_id: FILTER_DATA.item_id, seller_id: FILTER_DATA.seller_id, sorting_id: FILTER_DATA.getSortID(), offset: "\(self.offset)", limit: "20", posted_within: FILTER_DATA.posted_within, distance: FILTER_DATA.distance, distance_type: FILTER_DATA.distance_type, lang_type: DEFAULT_LANGUAGE_CODE, filters: filterString, product_condition: "\(product_id)", child_category_id: FILTER_DATA.child_category_id, lon: FILTER_DATA.long, lat: FILTER_DATA.lat,search_type: search_type,promotionTags: self.promotionTags,selected_type:type == "all" ? "" : type, onSuccess: { (success) in
            if self.offset == 0 {
                self.itemModel.removeAll()
            }
            if !success {
                self.isFound = false
                if self.itemModel.count == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            else {
                
                if self.viewModel.getItemModel?.result != nil {
                    self.itemModel += self.viewModel.getItemModel!.result.items
                    if (self.viewModel.getItemModel?.ads.count ?? 0) > 0 {
                        self.promotionTags = self.convertIntoJSONString(arrayObject: (self.viewModel.getItemModel?.ads ?? [String]())) ?? ""
                    }
                    else {
                        self.promotionTags = ""
                    }
                }
                else {
                    self.isFound = false
                }
                if self.itemModel.count == 0 {
                    self.NewNoitemStack.isHidden = false
                }
                else {
                    self.NewNoitemStack.isHidden = true
                }
            }
            self.refreshControl.endRefreshing()
            self.bottomLoader.stopAnimating()
            Utility.shared.stopAnimation(viewController: self)
            self.collectionView.reloadData()
            self.loadFilterData()
            
        }) { (failure) in
            self.refreshControl.endRefreshing()
            self.bottomLoader.stopAnimating()
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    func startTimer() {
        if timer != nil {
            timer = nil
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(self.timerAct), userInfo: nil, repeats: true)
    }
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    @objc func timerAct() {
        print("hiiiisolai\(ADMIN_VIEW_MODEL.adminModel?.result.bannerData.count)")
        if let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? HomeHeaderCollectionViewCell {
            cell.itemCount += 1
            print("count \(cell.bannerData.count)")
            if cell.bannerData.count > 0 && cell.pageControll.currentPage < (cell.bannerData.count - 1) {
                cell.pageControll.currentPage += 1
                print("change position \(cell.pageControll.currentPage)")
                cell.collectionView.layoutIfNeeded()
                cell.collectionView.setContentOffset(CGPoint.init(x: cell.pageControll.currentPage * Int(self.view.frame.size.width), y: 0), animated: true)
                //                cell.collectionView.scrollToItem(at: IndexPath(item: (cell.pageControll.currentPage), section: 0), at: .left, animated: true)
            }
            else {
                print("change zero")
                cell.pageControll.currentPage = 0
                cell.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
            }
        }
    }
    func getFilterArray() {
        if FILTER_DATA.Category_id != "", let category = ADMIN_VIEW_MODEL.productBeforeModel?.result.category.filter({$0.categoryId == (FILTER_DATA.Category_id)}).first {
            self.categoryFilterArray = category.filters
            if FILTER_DATA.subcategory_id != "", let subCategory = category.subcategory.filter({$0.subId == FILTER_DATA.subcategory_id}).first {
                self.categoryFilterArray = (self.categoryFilterArray + subCategory.filters)
                if FILTER_DATA.child_category_id != "",let childCategory = subCategory.childCategory.filter({$0.childId == FILTER_DATA.child_category_id}).first {
                    self.categoryFilterArray = (self.categoryFilterArray + childCategory.filters)
                }
            }
        }
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            if self.noItemStackView.isHidden {
                if section == 0 || section == 1 {
                    if (ADMIN_VIEW_MODEL.adminModel?.result.bannerData.count ?? 0) > 0 && section == 0{
                        return 1
                    }
                    else if (ADMIN_VIEW_MODEL.adminModel?.result.category.count ?? 0) > 0 && section == 1{
                        return 1
                    }
                }
                else if  section == 2{
                    return 1
                }
                else if  section == 3{
                    return self.itemModel.count
                }
            }
            return 0
        }
        else {
            if section == 0 {
                return self.filterArray.count
            }
            else {
                return ((self.updateFilterDict?.dropdown.count ?? 0) + (self.updateFilterDict?.multilevel.count ?? 0) + (self.updateFilterDict?.range.count ?? 0))
            }
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionView {
            return 4
        }
        else {
            return 2
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeHeaderCollectionViewCell", for: indexPath) as! HomeHeaderCollectionViewCell
                if ADMIN_VIEW_MODEL.adminModel?.result.bannerData.first?.bannerImage != ""{
                    cell.loadData(ADMIN_VIEW_MODEL.adminModel?.result.bannerData ?? [BannerDatumModel]())
                    cell.homeVC = self
                }
                return cell
            }
            else if indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCatogoryCollectionViewCell", for: indexPath) as! HomeCatogoryCollectionViewCell
                cell.loadCategoryData(ADMIN_VIEW_MODEL.adminModel?.result.category ?? [CategoryModel]())
                cell.homeVC = self
                return cell
            }  else if indexPath.section == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductSelectionCell", for: indexPath) as! ProductSelectionCell
                cell.Imagebtn.tag = indexPath.item
                cell.videobtn.tag = indexPath.item
                cell.Allbtn.tag = indexPath.item
                cell.videobtn.addTarget(self, action: #selector(self.Videobtntapped(_:)), for: .touchUpInside)
                cell.Imagebtn.addTarget(self, action: #selector(self.ImagebtnTapped(_:)), for: .touchUpInside)
                cell.Allbtn.addTarget(self, action: #selector(self.AllbtnTapped(_:)), for: .touchUpInside)
                cell.loadCategoryData(categoryData: ADMIN_VIEW_MODEL.adminModel?.status ?? false)
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
                if self.itemModel.count > indexPath.row{
                    cell.loadData(self.itemModel[indexPath.row])
                }
                if FILTER_DATA.getSortID() == "2"{
                    if self.itemModel.count > indexPath.row && self.itemModel.count % 20 == 0 {
                        if indexPath.row == (self.itemModel.count - 1) && self.isFound {
                            self.offset = self.itemModel.count
                            self.bottomLoader.startAnimating()
                            self.loadData(selected_type:self.selected_type_value)
//                            self.loadData()
                        }
                    }
                }else{
                    print("indexPathrowss",indexPath.row)
                    if self.itemModel.count > indexPath.row && self.itemModel.count % 20 == 0 {
                        if indexPath.row == (self.itemModel.count - 1) && self.isFound {
                            self.offset = self.itemModel.count
                            self.bottomLoader.startAnimating()
//                            self.loadData()
                            self.loadData(selected_type:self.selected_type_value)
                        }
                    }
                }
                
                return cell
            }
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeFilterCollectionViewCell", for: indexPath) as! HomeFilterCollectionViewCell
            cell.isFromChat = false
            cell.filterLabel.text = ""
            if indexPath.section == 0 {
                if self.filterArray.count > indexPath.row {
                    cell.filterLabel.text = FILTER_DATA.toDictionary()[self.filterArray[indexPath.row]]
                }
                else {
                    cell.filterLabel.text = "\(getLanguage["within"] ?? "within") \(Int(FILTER_DATA.distance ?? "") ?? 0) \(FILTER_DATA.distance_type ?? "")"
                }
                cell.cancelButton.tag = (indexPath.row * 10) + indexPath.section
            }
            else {
                for filterVal in self.categoryFilterArray {
                    if (self.updateFilterDict?.dropdown.count ?? 0) > indexPath.row {
                        if let filter = filterVal.values.filter({$0.parentId == (self.updateFilterDict?.dropdown[indexPath.row].id ?? "") && (self.updateFilterDict?.dropdown[indexPath.row].catType ?? "") == filterVal.categoryType}).first {
                            cell.filterLabel.text = filter.parentLabel
                            cell.cancelButton.tag = (((Int(self.updateFilterDict?.dropdown[indexPath.row].id ?? "") ?? 0)*10) + indexPath.section)
                        }
                    }
                    else if (self.updateFilterDict?.multilevel.count ?? 0) > (indexPath.row - ((self.updateFilterDict?.dropdown.count ?? 0))) {
                        let row = (indexPath.row - ((self.updateFilterDict?.dropdown.count ?? 0)))
                        for multiFilter in filterVal.values {
                            let childFilter = multiFilter.parentValues.filter({$0.childId == (self.updateFilterDict?.multilevel[row].id ?? "") && filterVal.categoryType == (self.updateFilterDict?.multilevel[row].catType ?? "")})
                            for childVal in childFilter {
                                if childVal.childId == (self.updateFilterDict?.multilevel[row].id ?? "") {
                                    cell.filterLabel.text = childVal.childName
                                    cell.cancelButton.tag = (((Int(self.updateFilterDict?.multilevel[row].id ?? "") ?? 0) * 10) + indexPath.section)
                                }
                            }
                        }
                    }
                    else {
                        let row = (indexPath.row - (((self.updateFilterDict?.dropdown.count ?? 0)+(self.updateFilterDict?.multilevel.count ?? 0))))
                        if (self.updateFilterDict?.range.count ?? 0) > row {
                            if self.updateFilterDict?.range[row].id == filterVal.id {
                                //                                cell.filterLabel.text = filterVal.label
                                cell.filterLabel.text = "\(self.updateFilterDict?.range[row].min_value ?? "")-\(self.updateFilterDict?.range[row].max_value ?? "")"
                                cell.cancelButton.tag = ((Int(self.updateFilterDict?.range[row].id ?? "") ?? 0)*10 + indexPath.section)
                            }
                        }
                    }
                }
            }
            cell.cancelButton.addTarget(self, action: #selector(self.cancelButtonAct(_:)), for: .touchUpInside)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = self.selected_type_value.isEmpty ? "all" : selected_type_value
        if collectionView == self.collectionView && indexPath.section == 3 {
            if self.itemModel.count > indexPath.row {
//                if type == "image"{
//                    let pageObj = ItemDetailsViewController()
//                    pageObj.itemDetails = self.itemModel[indexPath.row]
//                    pageObj.likeDelegate = self
//                    self.navigationController?.pushViewController(pageObj, animated: true)
//                }else{
                    let view = StoryAllList()
                    view.filtersort = "0"
                    view.selectedSearchType = self.selected_type_value
                    view.initial = true
                    view.initialads = self.promotionTags
                    if self.itemModel[indexPath.row].promotionType == "Ad"{
                       view.ad_product = "true"
                    }else{
                       view.ad_product = "false"
                    }
                    view.hts_product_id = "\(self.itemModel[indexPath.row].id ?? 0)"
                    view.getitemstype = "search"
                    if indexPath.item == 0{
                        view.position = "\(indexPath.item)"
                        view.before_position = "\(0)"
                        view.after_position = "\((indexPath.item) + 1)" // api end after position based results
//                        view.after_position = "\(indexPath.item + 1)"
                    }else{
                        view.position = "\(indexPath.item)"
                        view.before_position = "\((indexPath.item) - 1)"
//                        view.after_position = "\((indexPath.item) + 1)"
                        view.after_position = "\((indexPath.item) + 1)"
                    }
                    view.user_Img = self.itemModel[indexPath.row].sellerImg ?? ""
                    view.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                    view.fromNav = "Home"
                    view.type = "after"
                    view.videoID = self.itemModel[indexPath.row].stream_id ?? ""
                    view.user_Img = self.itemModel[indexPath.row].sellerImg ?? ""
                
                    view.category_id = FILTER_DATA.Category_id
                    view.subcategory_id = (FILTER_DATA.subcategory_id.lowercased() == "viewall") ? "" : FILTER_DATA.subcategory_id
//                    view.search_type = self.selected_type_value
                
                    self.navigationController?.pushViewController(view, animated: true)
       
                }
                    
//            }
                    
        }
    }
    
    @objc func bannerURLAct(_ url: String) {
        if let bannerURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            if UIApplication.shared.canOpenURL(bannerURL) {
                UIApplication.shared.open(bannerURL, options: [:], completionHandler: nil)
            }
        }
        else {
        }
    }
    
   

    
    @objc func Videobtntapped(_ sender: UIButton) {
        // Prevent duplicate action if already selected
        guard selected_type_value != "video" else { return }
        self.itemModel.removeAll()
        var view = sender.superview
        while let currentView = view, !(currentView is ProductSelectionCell) {
            view = currentView.superview
        }
        if let cell = view as? ProductSelectionCell,
           let indexPath = collectionView.indexPath(for: cell) {
            cell.videobtn.config(color: UIColor(named: "AppThemeColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "Pro_video")
            cell.Imagebtn.config(color: UIColor(named: "BlackColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "Pro_Audio")
            cell.Allbtn.config(color: UIColor(named: "BlackColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "all")
            cell.ImageborderLbl.backgroundColor = UIColor(named: "")
            cell.AllborderLbl.backgroundColor = UIColor(named: "")
            cell.VideoborderLbl.backgroundColor = UIColor(named: "AppThemeColorNew")
            self.loadData(selected_type: "video")
            self.selected_type_value = "video"
            print("Video button tapped at item: \(indexPath.item)")
        }
    }

    @objc func ImagebtnTapped(_ sender: UIButton) {
        // Prevent duplicate action if already selected
        guard selected_type_value != "image" else { return }
        self.itemModel.removeAll()
        var view = sender.superview
        while let currentView = view, !(currentView is ProductSelectionCell) {
            view = currentView.superview
        }

        if let cell = view as? ProductSelectionCell,
           let indexPath = collectionView.indexPath(for: cell) {
            print("Image button tapped at item: \(indexPath.item)")
            cell.videobtn.config(color: UIColor(named: "BlackColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "Pro_video")
            cell.Allbtn.config(color: UIColor(named: "BlackColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "all")
            cell.Imagebtn.config(color: UIColor(named: "AppThemeColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "Pro_Audio")
            cell.ImageborderLbl.backgroundColor = UIColor(named: "AppThemeColorNew")
            cell.VideoborderLbl.backgroundColor = UIColor(named: "")
            cell.AllborderLbl.backgroundColor = UIColor(named: "")
            self.loadData(selected_type: "image")
            self.selected_type_value = "image"
        }
    }
    
    @objc func AllbtnTapped(_ sender: UIButton) {
        guard selected_type_value != "all" else { return }
        self.itemModel.removeAll()
        var view = sender.superview
        while let currentView = view, !(currentView is ProductSelectionCell) {
            view = currentView.superview
        }

        if let cell = view as? ProductSelectionCell,
           let indexPath = collectionView.indexPath(for: cell) {
            print("Image button tapped at item: \(indexPath.item)")
            cell.videobtn.config(color: UIColor(named: "BlackColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "Pro_video")
            cell.Imagebtn.config(color: UIColor(named: "BlackColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "Pro_Audio")
            cell.Allbtn.config(color: UIColor(named: "AppThemeColorNew"),
                                 font: UIFont(name: APP_FONT_BOLD, size: 17),
                                 align: .center, title: "all")
            cell.ImageborderLbl.backgroundColor = UIColor(named: "")
            cell.AllborderLbl.backgroundColor = UIColor(named: "AppThemeColorNew")
            cell.VideoborderLbl.backgroundColor = UIColor(named: "")
            self.loadData(selected_type: "all")
            self.selected_type_value = "all"
        }
    }

    @objc func cancelButtonAct(_ sender: UIButton) {
        self.loadadmindata()
        let section = sender.tag % 10
        let row = sender.tag / 10
        if section == 0 && self.filterArray.count > row {
            if self.filterArray[row] == "type" {
                FILTER_DATA.type = ""
            }
            if self.filterArray[row] == "Price" {
                FILTER_DATA.Price = "0-5000"
            }
            if self.filterArray[row] == "Search_key" {
                FILTER_DATA.Search_key = ""
            }
            if self.filterArray[row] == "Category" {
                FILTER_DATA.Category_id = ""
                FILTER_DATA.subcategory_id = ""
                FILTER_DATA.child_category_id = ""
                FILTER_DATA.product_condition = ""
                FILTER_DATA.filters = ""
            }
            if self.filterArray[row] == "sorting_id" {
                FILTER_DATA.sorting_id = ""
            }
            if self.filterArray[row] == "posted_within" {
                FILTER_DATA.posted_within = ""
            }
            if self.filterArray[row] == "distance" {
                FILTER_DATA.distance = ""
                FILTER_DATA.isDistanceSlider = false
            }
            if self.filterArray[row] == "product_condition" {
                FILTER_DATA.product_condition = ""
            }
            if self.filterArray[row] == "location" {
                FILTER_DATA.location = ""
                FILTER_DATA.lat = ""
                FILTER_DATA.long = ""
            }
            let keys = Array(FILTER_DATA.toDictionary().keys)
            self.filterArray = keys
            self.updateFilterDict = Utility.shared.filterStringToDict(FILTER_DATA.filters)
        }
        else {
            if section == 0 {
                FILTER_DATA.distance = ""
                FILTER_DATA.isDistanceSlider = false
            }
            else {
                if self.updateFilterDict?.dropdown.contains(where: {$0.id == "\(row)"}) ?? false {
                    self.updateFilterDict?.dropdown.removeAll(where: {$0.id == "\(row)"})
                }
                else if self.updateFilterDict?.multilevel.contains(where: {$0.id == "\(row)"}) ?? false {
                    self.updateFilterDict?.multilevel.removeAll(where: {$0.id == "\(row)"})
                }
                else if self.updateFilterDict?.range.contains(where: {$0.id == "\(row)"}) ?? false {
                    self.updateFilterDict?.range.removeAll(where: {$0.id == "\(row)"})
                }
                if let updateFilter = self.updateFilterDict {
                    FILTER_DATA.filters = Utility.shared.filterDictToString(updateFilter)
                }
            }
        }
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        self.offset = 0
        self.isFound = true
        self.noItemStackView.isHidden = true
        self.itemModel.removeAll()
        if self.filterArray.count == 0 {
            if (FILTER_DATA.distance != "" && FILTER_DATA.isDistanceSlider && FILTER_DATA.location.lowercased() != UserDefaultModule.shared.getcountryname()?.lowercased()) {
            }
            else {
                self.refreshFilter!(true)
                self.filterCollectionView.isHidden = true
            }
        }
        self.filterCollectionView.reloadData()
        self.collectionView.reloadData()
//        self.loadData()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.loadData(selected_type:self.selected_type_value)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            var widthMode = (self.collectionView.frame.width/2 - 15)
            var heightMode = CGFloat(255)
            if indexPath.section == 0 || indexPath.section == 1 {
                widthMode = self.collectionView.frame.width
                if indexPath.section == 0 {
                    heightMode = 200
                }
                else {
                    heightMode = 125
                }
            }
            else if indexPath.section == 2 {
                return CGSize(width: self.collectionView.frame.width, height:  50)
            }
            else if indexPath.section == 3 {
                heightMode = 320
            }
            return CGSize(width: widthMode, height: heightMode)
        }
        else {
            return CGSize(width: 70, height: 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 3 {
            return UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 10)
        } else if section == 2 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.contentOffset.y < 150 {
            self.locationView.isHidden = false
            self.isviewVisible = false
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.isviewVisible = true
                self.locationView.isHidden = true
            }
        }
        else if self.locationView.isHidden == true && self.isviewVisible == true {
            self.locationView.isHidden = false
            //            UIView.transition(with: self.locationView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            //                self.locationView.isHidden = false
            //            }) { (bool) in
            //                self.isviewVisible = false
            //                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            //                    self.isviewVisible = true
            //                    self.locationView.isHidden = true
            //                }
            //            }
        } 
    }
    
    @objc func SelectedCategorypage() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let Tabbar = TabbarController()
        Tabbar.selectedIndex = 1
        delegate.initVC(initialView: Tabbar)
        
    }
    @objc func selectedCategoryAct(_ selectedIndex: Int) {
        if selectedIndex == 0{
            self.SelectedCategorypage()
        }else{
            if ADMIN_VIEW_MODEL.adminModel?.result.category[selectedIndex].subcategory.count ?? 0 > 0 {
                let pageObj = CategoryViewController()
                let selectedCategory = ADMIN_VIEW_MODEL.adminModel?.result.category[selectedIndex]
                pageObj.selectedcatName = ADMIN_VIEW_MODEL.adminModel?.result.category[selectedIndex].categoryName ?? ""
                pageObj.CategoryDetails = CategoryDetailsModel(Category_id: "\(selectedCategory?.categoryId ?? 0)", subcategory_id: "", child_category_id: "")
                
                if "\(selectedCategory?.categoryId ?? 0)" == FILTER_DATA.Category_id {
                    pageObj.CategoryDetails = CategoryDetailsModel(Category_id: "\(selectedCategory?.categoryId ?? 0)", subcategory_id: FILTER_DATA.subcategory_id, child_category_id: FILTER_DATA.child_category_id)
                }
                pageObj.subCategory = selectedCategory?.subcategory ?? [SubcategoryModel]()
                pageObj.delegate = self
                pageObj.categoryViewType = 2
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
            else {
                
                FILTER_DATA.subcategory_id = ""
                FILTER_DATA.child_category_id = ""
                FILTER_DATA.filters = ""
                FILTER_DATA.Category_id = "\(ADMIN_VIEW_MODEL.adminModel?.result.category[selectedIndex].categoryId ?? 0)"
                UserDefaultModule.shared.setFilterData(FILTER_DATA)
                self.loadFilterData()
                self.itemModel.removeAll()
                indicatorView.startAnimating()
//                self.loadData()
                self.loadData(selected_type:self.selected_type_value)
                
            }
        }
       
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView && self.lastContentOffset > scrollView.contentOffset.y {
            let contentOffset = scrollView.contentOffset.y
            if contentOffset <= 50 && !self.isLoadingMore {
                //                self.refreshControl.beginRefreshing()
                //                self.isLoadingMore = true
                DispatchQueue.global(qos: .background).async {
                    //                    self.offSet = self.chatModelArray.count
                    //                    print("self.offSet\(self.offSet)")
                }
            }
        }
        
    }
}
extension HomeViewController: SearchDelegate, CategoryDelegate {
    
    func loadadmindata() {
        print("Msdsolaichking")
        self.loadAdminData()
    }
    
    func updateSearchData(_ searchData: FilterDataModel) {
        FILTER_DATA = searchData
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        self.itemModel.removeAll()
        self.collectionView.reloadData()
        self.offset = 0
        self.isFound = true
        self.loadFilterData()
//        self.loadData()
        self.loadAdminData()
        self.loadData(selected_type:self.selected_type_value)
    }
    func updateCategoryData(_ searchData: CategoryDetailsModel) {
       
        FILTER_DATA.Category_id = searchData.Category_id
        FILTER_DATA.subcategory_id = searchData.subcategory_id
        FILTER_DATA.child_category_id = searchData.child_category_id
        FILTER_DATA.filters = ""
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        self.itemModel.removeAll()
        self.collectionView.reloadData()
        self.offset = 0
        self.isFound = true
        self.loadFilterData()
        self.loadAdminData()
//        self.loadData()
        self.loadData(selected_type:self.selected_type_value)
    }
    func locationAct(city: String, state: String, country: String,  countryCode: String, lat: String, long: String, location: String) {
        print("dxknde",location)
        if location == "worldwide" {
            FILTER_DATA.distance = ""
        }
        FILTER_DATA.location = location
        FILTER_DATA.city = city
        FILTER_DATA.state = state
        FILTER_DATA.lat = lat
        FILTER_DATA.long = long
        FILTER_DATA.country = country
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        self.itemModel.removeAll()
        self.collectionView.reloadData()
        self.offset = 0
        self.isFound = true
        self.loadFilterData()
        self.loadAdminData()
//        self.loadData()
        self.loadData(selected_type:self.selected_type_value)
    }
}
extension HomeViewController: likeDelegate{
    func likeAct(_ id: Int, isLiked: String) {
        self.itemModel.filter({$0.id == id}).first?.liked = isLiked
        self.collectionView.reloadData()
    }
}

extension HomeViewController: GADBannerViewDelegate{
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        bannerView.isHidden = false
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    /// Tells the delegate an ad request failed.
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        self.bannerView.isHidden = true
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
}


