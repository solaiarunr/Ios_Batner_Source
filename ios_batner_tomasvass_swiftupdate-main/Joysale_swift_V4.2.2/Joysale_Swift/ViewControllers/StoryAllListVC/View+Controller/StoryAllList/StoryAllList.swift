//
//  StoryAllList.swift
//  Joyshorts_Swift
//
//  Created by APPLE on 14/12/22.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Firebase
//import FirebaseDynamicLinks
import GoogleMobileAds
protocol MoreDelegate {
    func MorebtnTapped()
}
class StoryAllList: UIViewController,UIScrollViewDelegate,playpassdelegate {
    //    func newstart(product_types:String,cell:StoryAllCollectionCell) {
    //        self.isPlayVideo = true
    //        self.startTimer()
    //    }
    
    func newstart(product_types:String, cell:StoryAllCollectionCell) {
        self.isPlayVideo = true
        self.stopAllPlayer(true)
        
        if let indexPath = self.collectionView.indexPath(for: cell) {
            // Scroll to selected cell (optional)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            
            // Highlight selected border (optional)
            self.collectionView.reloadItems(at: [indexPath])
            cell.thumbImageView.isHidden = false
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        self.startTimer()
    }
    
    
    func newstop(product_types:String,cell:StoryAllCollectionCell) {
        self.isPlayVideo = false
        self.stopAllPlayer(true)
        NotificationCenter.default.removeObserver(self)
    }
    @IBOutlet weak var Backview: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var noDataStackView: UIStackView!
    @IBOutlet weak var BannerView: UIView!
    var viewModel = StoryListViewModel()
    var storyModel = [StoryListModel]()
    var productModel = [GetItemsResult1]()
    var Uicollcell = UICollectionViewCell()
    var selectedProductModel = [GetItemsResult1]()
    //    var itemDetails: StoryListModel?
    var isStopPlayer = 0
    var currentPlayerIndex = IndexPath(item: 0, section: 0)
    var appdelegate = UIApplication.shared.delegate as? AppDelegate
    var isPlayVideo = true
    var timer: Timer?
    var progressTimer: Timer?
    private var loaderView = UIView()
    var MoreDelegate : MoreDelegate?
    /*
     var refreshControl = UIRefreshControl()
     */
    var beforeModel = [StoryListModel]()
    var afterModel = [StoryListModel]()
    var isFailed = false
    var viewModels = ProfileViewModel()
    var user_Img = ""
    var userId = ""
    var videoID = ""
    var type = ""
    var category_id = ""
    var subcategory_id = ""
    var child_category_id = ""
    var hts_product_id = ""
    var position = ""
    var before_position = ""
    var after_position = ""
    var fromNav = ""
    var search_type = ""
    var promotionTags = ""
    var ad_product = ""
    
    var getitemstype = ""
    var seller_id = ""
    var itemID = ""
    var relatedVideoID = ""
    var profileData: ProfileResultModel?
    
    var categoryFilterArray = [ProductFilterModel]()
    var updateFilterDict: UpdateFilterModel?
    var filterArray = [String]()
    
    var bottomPadding = CGFloat(0)
    var itemdetailsmodel = ItemDetailsViewModel()
    var isFromNotification = false
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var loadmorecount = 0
    var initialads = ""
    var initial = false
    var filtersort = ""
    var page_type = ""
    var bannerView1:GADBannerView!
    
    var selectedSearchType = ""
    
    var newOffset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Backview.layer.cornerRadius = Backview.frame.width / 2
        Backview.layer.masksToBounds = true
        self.loadFilterData()
        self.configUI()
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            self.bottomPadding = window?.safeAreaInsets.bottom ?? CGFloat(0)
            print("bottomPadding:\(self.bottomPadding)")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        self.updateStatusbarBackground()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.collectionView.isPagingEnabled = true
        self.loadFilterData()
        self.startTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateStatusbarBackground()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidLayoutSubviews() {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.updateTheme(page: "present")
        //        self.updateStatusbarBackground()
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        self.navigationController?.isNavigationBarHidden = false
        self.stopAllPlayer(true)
        self.isPlayVideo = false
        NotificationCenter.default.removeObserver(self)
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopAllPlayer(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        /*
         //before calling
         if self.fromNav != "" {
         print("count hint pull offset:\(self.beforeModel.count ?? 0)")
         self.type = "before"
         if (self.beforeModel.count ?? 0) % 10 == 0{
         self.loadData(self.beforeModel.count ?? 0,"before",self.fromNav ?? "")
         }else{
         self.stopAllLoader()
         }
         //            else{
         //                self.showToast(message: "No Videos Found", font: .systemFont(ofSize: 12.0),type: "before")
         //            }
         }
         else {
         
         }
         */
        if self.fromNav != "" {
            self.loadData(0,"after",self.fromNav ?? "", loadmore: "false")
        }
        else {
            
        }
        
    }
    
    func removeObservers() {
        print("laterdone")
        self.stopAllPlayer(true)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
    }
    
    func configUI() {
        self.collectionView.register(UINib(nibName: "StoryAllCollectionCell", bundle: nil), forCellWithReuseIdentifier: "StoryAllCollectionCell")
        /*
         refreshControl.tintColor = UIColor(named: "AppThemeColor")
         refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
         self.collectionView.refreshControl = refreshControl
         self.collectionView.addSubview(refreshControl)
         */
        self.collectionView.alwaysBounceVertical = true
        self.noDataStackView.isHidden = true
        self.noDataLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "No Videos")
        self.backButton.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        self.type = "after"
        self.loadData(0, "after",self.fromNav, loadmore: "false")
        self.changeRTL()
    }
    
    func changeRTL(){
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.noDataStackView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func startTimer() {
        // Player Timer
        if self.timer != nil {
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        // Progress Timer
        if self.progressTimer != nil {
            self.progressTimer = nil
        }
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgressTimer), userInfo: nil, repeats: true)
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
    
    func loadFilterData() {
        //        Load Filter Data
        FILTER_DATA = UserDefaultModule.shared.getFilterData()
        let keys = Array(FILTER_DATA.toDictionary().keys)
        self.filterArray = keys.sorted()
        
        self.updateFilterDict = Utility.shared.filterStringToDict(FILTER_DATA.filters)
        self.getFilterArray()
        if self.filterArray.count > 0 {
            self.search_type = ""
            /*
             self.promotionTags = ""
             */
        }else {
            
            self.search_type = "all"
            /*
             if (self.viewModel.storymodel?.ads.count ?? 0) > 0 {
             self.promotionTags = self.convertIntoJSONString(arrayObject: (self.viewModel.storymodel?.ads ?? [String]())) ?? ""
             }
             else {
             self.promotionTags = ""
             }
             */
            if (FILTER_DATA.distance != "" && FILTER_DATA.isDistanceSlider && FILTER_DATA.location.lowercased() !=  UserDefaultModule.shared.getcountryname()?.lowercased()) {
            }
            else {
            }
        }
        
        if self.initial {
            self.initial = false
            if (self.initialads) != ""{
                print("come here 1")
                self.promotionTags = self.initialads
            }else {
                print("come here 2")
                self.promotionTags = ""
            }
        }else{
            if (self.viewModel.storymodel?.ads.count ?? 0) > 0{
                print("come here 3")
                self.promotionTags = self.convertIntoJSONString(arrayObject: (self.viewModel.storymodel?.ads ?? [String]())) ?? ""
            }else {
                print("come here 4")
                self.promotionTags = ""
            }
        }
    }
    
    func loadData(_ offset: Int,_ type: String,_ page: String,loadmore : String) {
        if self.filterArray.count == 0 && (FILTER_DATA.location == "" || FILTER_DATA.location.lowercased() == "worldwide" || FILTER_DATA.location.lowercased() ==  UserDefaultModule.shared.getcountryname()?.lowercased()) {
            
            print("come here 5")
            
            self.search_type = "all"
            FILTER_DATA.lat = ""
            FILTER_DATA.long = ""
            /*//now - menntion
             if offset == 0 {
             self.promotionTags = ""
             }
             */
        }
        else if (FILTER_DATA.location == "" || FILTER_DATA.location.lowercased() == "worldwide" || FILTER_DATA.location.lowercased() ==  UserDefaultModule.shared.getcountryname()?.lowercased()) {
            FILTER_DATA.lat = ""
            FILTER_DATA.long = ""
        }
        else if FILTER_DATA.location.lowercased() != "worldwide" &&  FILTER_DATA.getSortID() == "1" && FILTER_DATA.Category_id == "" && FILTER_DATA.Price == "0-5000" && FILTER_DATA.posted_within == "" && FILTER_DATA.Search_key == ""{
            print("come here 6")
            self.search_type = "all"
            /*//now - menntion
             if offset == 0 {
             self.promotionTags = ""
             }
             */
        }
        else {
            print("come here 7")
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
        
        print("tetsing_offset:\(offset) tetsing_limit:\("20")  page:\(self.fromNav) type:\(type) loadmore:\(loadmore) afterpostion:\(self.after_position) postion:\(self.position) beforepostion:\(self.before_position)")
        print("getStoryData:\(userId)")
        print("getStoryData:\(UserDefaultModule.shared.getUserData()?.user_id ?? "")")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var url = ""
        // let requestDict = NSMutableDictionary.init()
        var requestDict = [String: Any]()
        
        if self.fromNav == "filterdata"{
            url = HTS_VIDEOS
            requestDict["ad_product"] = self.ad_product
            requestDict["loadmore"] = loadmore
            requestDict["user_id"] = self.userId
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "8"
            requestDict["video_id"] = self.videoID
            requestDict["scroll_type"] = type
            requestDict["hts_product_id"] = self.hts_product_id
            requestDict["position"] = self.position
            requestDict["before_position"] = self.before_position
            requestDict["after_position"] = self.after_position
            requestDict["type"] = self.getitemstype
            requestDict["lang_type"] = DEFAULT_LANGUAGE_CODE
            //            if self.promotionTags != "" {
            //                requestDict["ads"] = self.promotionTags
            //            }
            requestDict["price"] = FILTER_DATA.Price
            requestDict["search_key"] = FILTER_DATA.Search_key
            requestDict["category_id"] = self.category_id
            requestDict["subcategory_id"] = self.subcategory_id
            requestDict["item_id"] = FILTER_DATA.item_id
            requestDict["seller_id"] = FILTER_DATA.seller_id
            requestDict["sorting_id"] = FILTER_DATA.getSortID()
            requestDict["posted_within"] = FILTER_DATA.posted_within
            requestDict["distance"] = FILTER_DATA.distance
            requestDict["distance_type"] = FILTER_DATA.distance_type
            requestDict["filters"] = filterString
            requestDict["product_condition"] = "\(product_id)"
            requestDict["child_category_id"] = self.child_category_id
            requestDict["lat"] = FILTER_DATA.lat
            requestDict["lon"] = FILTER_DATA.long
            requestDict["search_type"] = self.search_type
            
            if self.selectedSearchType == "video" ||  self.selectedSearchType == "image" {
                requestDict["selected_type"] = self.selectedSearchType
                if self.selectedSearchType != "image" {
                    requestDict["page_type"] = "product_video"
                }
            } else {
                requestDict["selected_type"] = ""
                requestDict["page_type"] = "product_video"
            }
            
        }else if self.fromNav == "Home"{
            url = HTS_VIDEOS
            requestDict["loadmore"] = loadmore
            requestDict["user_id"] = self.userId
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "8"
            requestDict["video_id"] = self.videoID
            requestDict["scroll_type"] = type
            requestDict["hts_product_id"] = self.hts_product_id
            requestDict["position"] = self.position
            requestDict["before_position"] = self.before_position
            requestDict["after_position"] = self.after_position
            requestDict["type"] = self.getitemstype
            requestDict["lang_type"] = DEFAULT_LANGUAGE_CODE
            //            if self.promotionTags != "" {
            //                requestDict["ads"] = self.promotionTags
            //            }
            requestDict["price"] = ""
            requestDict["search_key"] = ""
            
            
            if self.filtersort == ""{
                requestDict["sorting_id"] = "1"
            }else if self.filtersort != ""{
                requestDict["sorting_id"] = self.filtersort
            }
            
            requestDict["posted_within"] = ""
            if self.getitemstype == "search"{
                requestDict["ad_product"] = self.ad_product
                
                requestDict["item_id"] = ""
                if self.category_id == "0"{
                    requestDict["category_id"] = ""
                }else{
                    requestDict["category_id"] = self.category_id
                }
                requestDict["subcategory_id"] = self.subcategory_id
                requestDict["child_category_id"] = self.child_category_id
                requestDict["seller_id"] = ""
                requestDict["distance"] = FILTER_DATA.distance
                requestDict["distance_type"] = FILTER_DATA.distance_type
                requestDict["lat"] = FILTER_DATA.lat
                requestDict["lon"] = FILTER_DATA.long
                requestDict["search_type"] = self.search_type
                
            }else if self.getitemstype == ""{
                requestDict["ad_product"] = ""
                requestDict["item_id"] = ""
                requestDict["category_id"] = self.category_id
                requestDict["subcategory_id"] = self.subcategory_id
                requestDict["child_category_id"] = ""
                requestDict["seller_id"] = ""
                requestDict["distance"] = ""
                requestDict["distance_type"] = ""
                requestDict["lat"] = ""
                requestDict["lon"] = ""
                requestDict["search_type"] = ""
                requestDict["related_videoid"] = self.relatedVideoID
            }
            else{
                requestDict["ad_product"] = self.ad_product
                if self.getitemstype == "moreitems" {
                    requestDict["item_id"] = self.itemID
                }else if self.getitemstype == "liked" {
                    requestDict["item_id"] = ""
                }
                requestDict["category_id"] = ""
                requestDict["subcategory_id"] = ""
                requestDict["child_category_id"] = ""
                requestDict["seller_id"] = self.seller_id
                requestDict["distance"] = ""
                requestDict["distance_type"] = ""
                requestDict["lat"] = ""
                requestDict["lon"] = ""
                requestDict["search_type"] = ""
            }
            requestDict["filters"] = ""
            requestDict["product_condition"] = ""
            
            if self.selectedSearchType == "video" ||  self.selectedSearchType == "image" {
                requestDict["selected_type"] = self.selectedSearchType
                if self.selectedSearchType != "image" {
                    requestDict["page_type"] = "product_video"
                }
            } else {
                requestDict["selected_type"] = ""
                requestDict["page_type"] = "product_video"
            }
            
        }
        else if fromNav == "profile"{
            url = HTS_MY_VIDEOS
            requestDict["related_videoid"] = self.relatedVideoID
            requestDict["user_id"] = self.userId
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "8"
            requestDict["video_id"] = self.videoID
            requestDict["scroll_type"] = type
            
            if self.selectedSearchType == "video" ||  self.selectedSearchType == "image" {
                requestDict["selected_type"] = self.selectedSearchType
                if self.selectedSearchType != "image" {
                    requestDict["page_type"] = "product_video"
                }
            } else {
                requestDict["selected_type"] = ""
                requestDict["page_type"] = "product_video"
            }
            
        }else if fromNav == "dynamicLink" {
            url = VIDEOLINK
            requestDict["user_id"] = self.userId
            requestDict["video_id"] = self.videoID
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "1"
            requestDict["lang_type"] = DEFAULT_LANGUAGE_CODE
            
        }
        else if fromNav == "chat" {
            url = HTS_VIDEOS
            requestDict["user_id"] = self.userId
            requestDict["hts_product_id"] = self.hts_product_id
            requestDict["video_id"] = self.videoID
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "1"
            requestDict["page_type"] = "chat"
            requestDict["lang_type"] = DEFAULT_LANGUAGE_CODE
            
        }
        else if fromNav == "notification" {
            url = HTS_VIDEOS
            requestDict["user_id"] = self.userId
            requestDict["hts_product_id"] = self.hts_product_id
            requestDict["video_id"] = self.videoID
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "1"
            requestDict["page_type"] = "notification"
            requestDict["lang_type"] = DEFAULT_LANGUAGE_CODE
        }
        else if fromNav == "exchange" {
            url = HTS_VIDEOS
            requestDict["user_id"] = self.userId
            requestDict["hts_product_id"] = self.hts_product_id
            requestDict["video_id"] = self.videoID
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "1"
            requestDict["page_type"] = "chat"
            requestDict["lang_type"] = DEFAULT_LANGUAGE_CODE
        }
        
        else{
            url = HTS_PRODUCT_VIDEOS
            requestDict["user_id"] = self.userId
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "8"
            
            if self.selectedSearchType == "video" ||  self.selectedSearchType == "image" {
                requestDict["selected_type"] = self.selectedSearchType
                if self.selectedSearchType != "image" {
                    requestDict["page_type"] = "product_video"
                }
            } else {
                requestDict["selected_type"] = ""
                requestDict["page_type"] = "product_video"
            }
        }
        
        
        self.viewModel.getStoryData(url: url,startRequest: requestDict) { success in
            self.stopAllPlayer()
            if offset == 0 {
                if self.fromNav != ""
                {
                    if type != "before"{
                        self.storyModel.removeAll()
                    }
                }
                else {
                    print("page empty")
                    self.storyModel.removeAll()
                }
            }
            if self.fromNav != ""
            {
                self.backButton.isHidden = false
                self.afterModel += self.viewModel.storyListArray
                self.storyModel = self.afterModel
                print("herecomes page is havig data:\(self.viewModel.storyListArray)")
                print("herecomes page is havig data model data:\(self.storyModel)")
                print("herecomes page is havig data stored data:\(self.storyModel.count)")
                if (self.viewModel.storymodel?.ads.count ?? 0) > 0 {
                    self.promotionTags = self.convertIntoJSONString(arrayObject: (self.viewModel.storymodel?.ads ?? [String]())) ?? ""
                }
                else {
                    self.promotionTags = ""
                }
                /*
                 self.collectionView.performBatchUpdates {
                 self.afterModel += self.viewModel.storyListArray
                 self.storyModel = self.beforeModel+self.afterModel
                 print("before model after: \(self.storyModel)")
                 } completion: { status in
                 if self.viewModel.storyListArray.count <= 0{
                 self.showToast(message: "No Videos Found", font: .systemFont(ofSize: 12.0),type: "after")
                 }else{
                 
                 }
                 }
                 */
            }
            else {
                print("page empty1")
                self.storyModel += self.viewModel.storyListArray
                /*
                 self.collectionView.performBatchUpdates {
                 self.storyModel += self.viewModel.storyListArray
                 } completion: { status in
                 if self.viewModel.storyListArray.count <= 0{
                 self.showToast(message: "No Videos Found", font: .systemFont(ofSize: 12.0),type: "after")
                 }else{
                 
                 }
                 }
                 */
            }
            dispatchGroup.leave()
            print("Status: \(self.viewModel.storymodel?.newOffset ?? 0)")
            if url == HTS_VIDEOS {
                print("self.viewModel.storymodel?.newOffset ?? 0: \(self.viewModel.storymodel?.ads.count)")
                self.newOffset += self.viewModel.storymodel?.newOffset ?? 0
            }
        } onFailure: { failure in
            dispatchGroup.leave()
            print("Failure: \(failure)")
        }
        dispatchGroup.enter()
        self.viewModel.loadAppDefaults { json in
            if json["status"].boolValue {
                //                VIDEO_MAXIMUM_DURATION = (json["video_max_duration"].intValue * 60)
                //                VIDEO_MINIMUM_DURATION = (json["video_min_duration"].intValue * 60)
                VIDEO_MAXIMUM_DURATION = (json["video_max_duration"].intValue)
                VIDEO_MINIMUM_DURATION = (json["video_min_duration"].intValue)
                VIDEO_MAXIMUM_SIZE = json["video_max_size"].intValue
                dispatchGroup.leave()
            }
        } onFailure: { failure in
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.stopAllLoader()
            self.loadmorecount = self.loadmorecount + 1
            self.collectionView.layoutSubviews()
            self.collectionView.reloadData()
            
            //self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.filterSelectedProduct()
            print("herecomes page is havig data1:\(self.storyModel.count)")
            if self.storyModel.count == 0 {
                print("herecomes page is havig data2:\(self.storyModel.count)")
                self.noDataStackView.isHidden = false
            }
            else {
                print("herecomes page is havig data3:\(self.storyModel.count)")
                self.noDataStackView.isHidden = true
            }
            self.loadFilterData()
        }
    }
    
    func stopAllLoader() {
        
    }
    
    
    
    @IBAction func backButtonAct(_ sender: UIButton) {
        NotificationCenter.default.removeObserver(self)
        
        if self.isFromNotification {
            let Tabbar = TabbarController()
            Tabbar.selectedIndex = 0
            delegate.initVC(initialView: Tabbar)
        }
        else if (self.fromNav == "Home" || self.fromNav == "profile") || self.fromNav == "filterdata"  && !self.isFromNotification{
            self.navigationController?.popViewController(animated: true)
        }else{
            if self.userId == "0" || self.userId == "" {
                self.tabBarController?.selectedIndex = 0
                self.tabBarController?.tabBar.isHidden = false
                self.tabBarController?.tabBar.isUserInteractionEnabled = true
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func pushView(_ topIndex: Int){
        print("topIndex:\(topIndex)")
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
            self.storyModel[topIndex].liked = "yes"
            self.storyModel[topIndex].likesCount = ((self.storyModel[topIndex].likesCount ?? 0) + 1)
            if let cell = self.collectionView.cellForItem(at: self.currentPlayerIndex) as? StoryAllCollectionCell {
                cell.likeLbl.text = String(self.storyModel[topIndex].likesCount ?? 0)
                print("likeLbl4")
                print("check_likeLbl.text:\(cell.likeLbl.text ?? "")")
            }
            self.itemdetailsmodel.itemLikedAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: self.storyModel[topIndex].products, onSuccess: { (success) in
                self.storyModel[topIndex].likesCount = self.itemdetailsmodel.likeModel?.likesCount
                print("check_api_like_story:\(self.storyModel[topIndex].likesCount ?? 0)")
                print("check_api_like_likemodel:\(self.itemdetailsmodel.likeModel?.likesCount ?? 0)")
            }) { (failure) in
            }
        }
        else {
            //  self.loadInitialVC()
        }
    }
    
    @objc func likeBtnAct(_ sender: UIButton) {
        print("check the button")
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
            if let cell = self.collectionView.cellForItem(at: self.currentPlayerIndex) as? StoryAllCollectionCell {
                cell.likeBtn.isUserInteractionEnabled = false
                if self.storyModel[sender.tag].publisherId != UserDefaultModule.shared.getUserData()?.user_id ?? ""{
                    if (self.storyModel[sender.tag].liked ?? "") == "yes" {
                        sender.setImage(#imageLiteral(resourceName: "newwhiteheart"), for: .normal)
                        sender.tintColor = UIColor.white
                        self.storyModel[sender.tag].liked = "no"
                        self.storyModel[sender.tag].likesCount = (self.storyModel[sender.tag].likesCount ?? 0) > 0 ? ((self.storyModel[sender.tag].likesCount ?? 0)-1) : 0
                        print("self.storyModel[sender.tag].likesCount_minus :\(self.storyModel[sender.tag].likesCount)")
                    }
                    else {
                        self.storyModel[sender.tag].liked = "yes"
                        sender.setImage(#imageLiteral(resourceName: "newwhiteheart"), for: .normal)
                        sender.tintColor = UIColor.init(named: "redcolor")
                        self.storyModel[sender.tag].likesCount = ((self.storyModel[sender.tag].likesCount ?? 0) + 1)
                        print("self.storyModel[sender.tag].likesCount_plus :\(self.storyModel[sender.tag].likesCount)")
                    }
                    // self.likeDelegate?.likeAct((Int(self.storyModel[sender.tag].products)), isLiked: (self.storyModel[sender.tag].liked ?? "")) //not needed
                    //self.collectionView.reloadData()
                    
                    cell.likeBtn.transform =
                    CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
                    UIView.animate(withDuration: 0.3 / 1.5, animations: {
                        cell.likeBtn.transform =
                        CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
                    }) { finished in
                        UIView.animate(withDuration: 0.3 / 2, animations: {
                            cell.likeBtn.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
                        }) { finished in
                            UIView.animate(withDuration: 0.3 / 2, animations: {
                                cell.likeBtn.transform = CGAffineTransform.identity
                            })
                        }
                    }
                    
                    cell.likeLbl.text = String(self.storyModel[sender.tag].likesCount ?? 0)
                    print("likeLbl5")
                    print("check_likeLbl.text:\(cell.likeLbl.text ?? "")")
                    //                }
                    self.itemdetailsmodel.itemLikedAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: self.storyModel[sender.tag].products, onSuccess: { (success) in
                        cell.likeBtn.isUserInteractionEnabled = true
                        self.storyModel[sender.tag].likesCount = self.itemdetailsmodel.likeModel?.likesCount
                        print("check_api_like_story:\(self.storyModel[sender.tag].likesCount ?? 0)")
                        print("check_api_like_likemodel:\(self.itemdetailsmodel.likeModel?.likesCount ?? 0)")
                    }) { (failure) in
                    }
                }
            }
        }
        else {
            self.loadInitialVC()
        }
    }
    
    
    
    @objc func cmntBtnAct(_ sender: UIButton) {
        if let cell = self.collectionView.cellForItem(at: currentPlayerIndex) as? StoryAllCollectionCell {
            cell.cmntBtn.isUserInteractionEnabled = false
        }
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
            var itemDetails : ItemModel?
            let chatViewModel = ChatViewModel()
            if UserDefaultModule.shared.getUserData()?.user_id != nil{
                chatViewModel.searchItemData(item_id: self.storyModel[sender.tag].products ?? "0", user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), onSuccess: { (success) in
                    if success {
                        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                            print(success)
                            if success {
                                if let profileData = self.viewModels.profileModel?.result {
                                    self.profileData = profileData
                                    if self.profileData?.verification.mobNo == false{
                                        self.showAlerts()
                                    }else{
                                        if let itemModel = chatViewModel.itemModel?.result.items.first {
                                            itemDetails = itemModel
                                            let pageObj = CommentViewController()
                                            pageObj.intercmntdel = self
                                            pageObj.fromPage = "story"
                                            pageObj.itemModel = itemDetails
                                            NotificationCenter.default.removeObserver(self)
                                            self.navigationController?.pushViewController(pageObj, animated: true)
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }) { (failure) in
                        }
                    }
                }) { (failure) in
                }
            }
        }else{
            self.loadInitialVC()
        }
    }
    @objc func profileBtnAct(_ sender: UIButton) {
        if let cell = self.collectionView.cellForItem(at: currentPlayerIndex) as? StoryAllCollectionCell {
            cell.profileBtn.isUserInteractionEnabled = true
        }
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
            if (self.storyModel[sender.tag].publisherId ?? "") == UserDefaultModule.shared.getUserData()?.user_id{
                //                let pageObj = MenuPage()
                //                pageObj.from = "videoposted"
                //                pageObj.isfromTabbar = false
                //                self.navigationController?.pushViewController(pageObj, animated: true)
            }else{
                let pageObj = ViewProfileViewController()
                pageObj.isTabBar = false
                pageObj.userId = "\(self.storyModel[sender.tag].publisherId ?? "")"
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
        }else{
            self.loadInitialVC()
        }
    }
    
    func loadInitialVC() {
        let vc = InitialViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.isFromList = true
        self.present(vc, animated: true, completion: nil)
    }
    func editProductAct(tag:StoryListModel){
        
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" == tag.sellerId ?? "" {
            let product_type = tag.product_type
            let pageObj = AddProductViewController()
            pageObj.isEditFlag = true
            pageObj.stream_thumb =  tag.stream_thumb ?? ""
            pageObj.video_id =  tag.video_id ?? ""
            pageObj.isskip = product_type ?? ""
            let itemtype = tag.photos.map { $0.type }.joined(separator: ",")
            let productImage = tag.photos
                .filter { $0.type == "image" }        // only images
                .map { $0.itemImage }
                .joined(separator: ",")
            
            let currencyArray = (tag.currencyCode ?? "").components(separatedBy: "-")
            var formattedCurrency = (tag.currencyCode ?? "")
            if currencyArray.count > 0 {
                formattedCurrency = currencyArray.count > 1 ? "\(currencyArray[1])-\(currencyArray[0])" : (tag.currencyCode ?? "")
            }
            
            let addEditModel = AddEditViewModel(
                item_id: "\(tag.id ?? 0)",
                item_name: tag.itemTitle ?? "",
                item_des: (tag.itemDescription.html2String ?? ""),
                price: "\(tag.price ?? "0")",
                size: tag.size ?? "",
                category: "\(tag.categoryId ?? 0)",
                subcategory: tag.subcatId ?? "",
                chat_to_buy: "0",
                exchange_to_buy: (tag.exchangeBuy ?? "0") == "0" ? false : true,
                currency: "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.currency.filter({$0.symbol == formattedCurrency}).first?.symbol ?? "")",
                lat: "\(tag.latitude ?? 0)",
                lon: "\(tag.longitude ?? 0)",
                address: tag.location ?? "",
                shipping_time: tag.shippingTime ?? "",
                remove_img: "",
                product_img: productImage,
                shipping_detail: "",
                item_condition: "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.filter({$0.name == (tag.itemCondition ?? "")}).first?.id ?? 0)",
                make_offer: Int(tag.makeOffer ?? "0") ?? 0,
                instant_buy: tag.instantBuy ?? "0" == "0" ? false : true,
                paypal_id: "",
                shipping_cost: tag.shippingCost ?? "",
                country_id: (tag.countryId ?? ""),
                giving_away: (tag.price ?? "0") == "0" ? true : false,
                sold: (tag.itemStatus ?? "") == "sold" ? true : false,
                filters: changeFilterDict(
                    categoryId: tag.categoryId ?? 0,
                    subCategoryId: tag.subcatId ?? "0",
                    childCategoryId: tag.childCategoryId ?? "0",
                    filters: tag.filters
                ),
                youtube_link: tag.youtubeLink ?? "",
                child_category: "\(tag.childCategoryId ?? "0")"
            )
            
            ADD_EDIT_ITEM_MODEL = addEditModel
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
        
    }
    
    func changeFilterDict(categoryId: Int, subCategoryId: String, childCategoryId: String, filters: [FilterModel]?) -> String {
        guard let filterArr = filters else { return "" }
        
        var filterRangeArray = [FilterRangeModel]()
        var filterDropDownArray = [FilterSubModel]()
        var filterMultiLevelArray = [FilterSubModel]()
        
        let filterArray = Utility.shared.getFilterFromCategory(category: "\(categoryId)", subCategory: subCategoryId, childCategory: childCategoryId)
        
        for filter in filterArr {
            for prodFilter in filterArray {
                if prodFilter.type == filter.type {
                    if prodFilter.type == "dropdown" {
                        filterDropDownArray.append(FilterSubModel(catType: prodFilter.categoryType, id: filter.childId))
                    } else if filter.type == "multilevel" {
                        filterMultiLevelArray.append(FilterSubModel(catType: prodFilter.categoryType, id: filter.childId))
                    } else {
                        let range = FilterRangeModel(max_value: filter.value, id: filter.parentId, min_value: filter.value)
                        filterRangeArray.append(range)
                    }
                }
            }
        }
        
        let updateArray = UpdateFilterModel(range: filterRangeArray, dropdown: filterDropDownArray, multilevel: filterMultiLevelArray)
        return Utility.shared.filterDictToString(updateArray)
    }
    
    func showAlerts() {
        let alertController = UIAlertController(title: "Batner", message: "Kindly Verify Your Mobile Number", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
                let pageObj = EditProfileViewController()
                pageObj.profileData = self.viewModels.profileModel?.result
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    func soldItemAct(_ itemID: String, value: String,tag:StoryListModel) {
        // ****** Review & Ratings Addons **** //
        /*
         if !((self.buyNowButton.titleLabel?.text ?? "") == (getLanguage["back_to_sale"] ?? "back_to_sale")){
         Utility.shared.startAnimation(viewController: self)
         self.viewModel.getSoldToAddon(user_id:(UserDefaultModule.shared.getUserData()?.user_id ?? "") , item_id: "\(self.itemDetails?.id ?? 0)", onSuccess: { (success) in
         print(self.viewModel.soldToModel?.result.first?.userId ?? "")
         if self.viewModel.soldToModel?.result.first?.userId != nil{
         if (self.viewModel.soldToModel?.result.count ?? 0) > 0 {
         let pageObj = SoldOutViewController()
         pageObj.refreshSold = { sold in
         print("Sold \(sold)")
         self.itemDetails?.itemStatus = sold
         self.setBottonButton()
         }
         pageObj.itemId = "\(self.itemDetails?.id ?? 0)"
         self.itemDetails?.itemStatus = self.itemDetails?.itemStatus ?? "" == "sold" ? "onsale" : "sold"
         self.navigationController?.pushViewController(pageObj, animated: true)
         }
         }
         else {
         Utility.shared.startAnimation(viewController: self)
         self.viewModel.soldItemAct(value: value, item_id: itemID, onSuccess: { (success) in
         self.itemDetails?.itemStatus = self.itemDetails?.itemStatus ?? "" == "sold" ? "onsale" : "sold"
         if self.itemDetails?.itemStatus ?? "" == "onsale" {
         self.itemDetails?.promotionType = "Normal"
         }
         self.configUI()
         Utility.shared.stopAnimation(viewController: self)
         }) { (failure) in
         Utility.shared.stopAnimation(viewController: self)
         }
         }
         Utility.shared.stopAnimation(viewController: self)
         }) { (failure) in
         Utility.shared.stopAnimation(viewController: self)
         }
         }
         else{
         */
        let soldTitle = (tag.itemStatus ?? "") == "onsale" ? getLanguage["mark_as_sold"] ?? "" : getLanguage["back_to_sale"] ?? ""
        
        let alert = UIAlertController(title: nil, message: soldTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: { (UIAlertAction) in
            Utility.shared.startAnimation(viewController: self)
            self.itemdetailsmodel.soldItemAct(value: value, item_id: itemID, onSuccess: { (success) in
                tag.itemStatus = tag.itemStatus ?? "" == "sold" ? "onsale" : "sold"
                if tag.itemStatus ?? "" == "onsale" {
                    tag.promotionType = "Normal"
                }
                self.configUI()
                Utility.shared.stopAnimation(viewController: self)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        //   }
    }
    
    func deleteProductAct(Itemid: String) {
        let alert = UIAlertController(title: getLanguage["alert"], message: getLanguage["Do you want to surely delete this product?"], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .default, handler: { (UIAlertAction) in
            Utility.shared.startAnimation(viewController: self)
            self.itemdetailsmodel.deleteProductAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: Itemid, onSuccess: { (success) in
                self.navigationController?.popViewController(animated: true)
                Utility.shared.stopAnimation(viewController: self)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }))
        alert.addAction(UIAlertAction(title: getLanguage["cancel"], style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func exchangeAct(tag:StoryListModel) {
        if tag.itemStatus ?? "" == "sold" {
            let alert = UIAlertController(title: nil, message: getLanguage["Product already sold out"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let pageObj = ExchangeViewController()
            pageObj.itemDetailsvideo = tag
            pageObj.isfromtype = "story"
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
    }
    
    @objc func chatButtonAct(_ sender: UIButton) {
        let playerData = self.storyModel[sender.tag]
        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            if success {
                if let profileData = self.viewModels.profileModel?.result {
                    self.profileData = profileData
                    if self.profileData?.verification.mobNo == false{
                        self.showAlerts()
                    }else{
                        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                            if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (playerData.sellerId ?? "") {
                                let pageObj = InsightViewController()
                                pageObj.isfromtype = "story"
                                pageObj.itemDatavideo = playerData
                                self.navigationController?.pushViewController(pageObj, animated: true)
                            }
                            else {
                                self.view.endEditing(true)
                                Utility.shared.startAnimation(viewController: self)
                                self.itemdetailsmodel.getChatIdAct(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: (playerData.sellerId ?? ""), onSuccess: { (success) in
                                    Utility.shared.stopAnimation(viewController: self)
                                    
                                    if success {
                                        let pageObj = ChatViewController()
                                        pageObj.receiverId = playerData.sellerId ?? ""
                                        pageObj.isFromItemDetails = true
                                        pageObj.chatId = (self.itemdetailsmodel.itemChatModel?.chatId ?? "")
                                        pageObj.itemDetailsvideo = playerData
                                        pageObj.isfromtype = "story"
                                        self.navigationController?.pushViewController(pageObj, animated: true)
                                    }
                                }) { (failure) in
                                    Utility.shared.stopAnimation(viewController: self)
                                }
                            }
                        }
                        else {
                            self.loadInitialVC()
                        }
                        
                    }
                    
                }
            }
        }) { (failure) in
        }
        
    }
    @objc func MakebtnTapped(_ sender: UIButton) {
        let playerData = self.storyModel[sender.tag]
        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            if success {
                if let profileData = self.viewModels.profileModel?.result {
                    self.profileData = profileData
                    if self.profileData?.verification.mobNo == false{
                        self.showAlerts()
                    }else{
                        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != ""{
                            let pageObj = ExchangeOfferViewController()
                            pageObj.itemDetailsvideo = playerData
                            pageObj.isfromtype = "story"
                            pageObj.modalPresentationStyle = .overCurrentContext
                            pageObj.modalTransitionStyle = .crossDissolve
                            self.navigationController?.present(pageObj, animated: true, completion: nil)
                        }
                        else {
                            self.loadInitialVC()
                        }
                    }
                }
            }
        }) { (failure) in
        }
    }
    
    @objc func buyNowAct(_ sender: UIButton) {
        let playerData = self.storyModel[sender.tag]
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (playerData.sellerId ?? "") {
            if (playerData.itemStatus ?? "") == "sold" {
                self.soldItemAct("\(playerData.id ?? 0)", value: "0",tag:playerData)
            }
            else {
                if (playerData.promotionType ?? "") == "Normal" {
                    let pageObj = CreatePromotionViewController()
                    pageObj.itemID = "\(playerData.id ?? 0)"
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
                else {
                    let pageObj = MyPromotionDetailViewController()
                    pageObj.isFromItemDetails = true
                    pageObj.itemDetailsvideo = playerData
                    pageObj.isfromtype = "story"
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
            }
        }
        else {
            if (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
                if BUYNOW_MODEL_FLAG && (playerData.itemApprove ?? "") == "1" {
                    Utility.shared.startAnimation(viewController: self)
                    self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                        print(success)
                        if success {
                            Utility.shared.stopAnimation(viewController: self)
                            if let profileData = self.viewModels.profileModel?.result {
                                self.profileData = profileData
                                if self.profileData?.verification.mobNo == false{
                                    self.showAlerts()
                                }else{
                                    let addressModel = AddressViewModel()
                                    addressModel.getShippingAddressAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(playerData.id ?? 0)", onSuccess: { (success) in
                                        Utility.shared.stopAnimation(viewController: self)
                                        if !success {
                                            let pageObj = AddressViewController()
                                            pageObj.itemDetailsvideo = playerData
                                            pageObj.isfromtype = "story"
                                            pageObj.viewType = 1
                                            self.navigationController?.pushViewController(pageObj, animated: true)
                                        }
                                        else {
                                            if addressModel.addressListModel?.result.count ?? 0 == 1 {
                                                let pageObj = BuyNowViewController()
                                                pageObj.isfromtype = "story"
                                                pageObj.addressDetails = addressModel.addressListModel?.result.first
                                                pageObj.itemDetailsvideo = playerData
                                                self.navigationController?.pushViewController(pageObj, animated: true)
                                            }
                                            else {
                                                let pageObj = AddressListViewController()
                                                pageObj.isfromtype = "story"
                                                pageObj.itemDetailsvideo = playerData
                                                pageObj.isFromItemDetails = true
                                                self.navigationController?.pushViewController(pageObj, animated: true)
                                            }
                                        }
                                    }) { (failure) in
                                        Utility.shared.stopAnimation(viewController: self)
                                    }
                                    
                                    
                                }
                                
                            }
                        }
                    }) { (failure) in
                    }
                    
                    
                }
            }
            else {
                self.loadInitialVC()
            }
        }
    }
    @objc func CallbtnAct(_ sender: UIButton) {
        let playerDataviacall = self.storyModel[sender.tag]
        if (playerDataviacall.mobileNo ?? "") != "" && (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
            if let callUrl = URL(string: "telprompt://+\(playerDataviacall.mobileNo ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), UIApplication.shared.canOpenURL(callUrl) {
                UIApplication.shared.open(callUrl, options: [:], completionHandler: nil)
            }
            else {
            }
        }
        else{
            self.loadInitialVC()
        }
    }
    @objc func ExchangebtnAct(_ sender: UIButton) {
        let ExchageplayerData = self.storyModel[sender.tag]
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
            self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                print(success)
                if success {
                    if let profileData = self.viewModels.profileModel?.result {
                        self.profileData = profileData
                        if self.profileData?.verification.mobNo == false{
                            self.showAlerts()
                        }else{
                            self.exchangeAct(tag:ExchageplayerData)
                            
                        }
                        
                    }
                }
            }) { (failure) in
            }
        }
        else {
            self.loadInitialVC()
        }
    }
    @objc func MoreBtnAct(_ sender: UIButton) {
        //solai
        
        let playerData = self.storyModel[sender.tag]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (playerData.sellerId ?? "") {
            // Add Edit option first
            alert.addAction(UIAlertAction(title: getLanguage["edit_product"] ?? "Edit", style: .default, handler: { _ in
                if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                    self.editProductAct(tag:playerData) // Call your edit action method
                } else {
                    self.loadInitialVC()
                }
            }))
            
            var soldValue = 0
            var soldTitle = ""
            
            if (playerData.itemStatus ?? "") == "onsale" {
                soldTitle = getLanguage["mark_as_sold"] ?? ""
                soldValue = 1
            } else {
                soldTitle = getLanguage["back_to_sale"] ?? ""
                soldValue = 0
            }
            
            alert.addAction(UIAlertAction(title: soldTitle, style: .default, handler: { _ in
                if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                    self.soldItemAct("\(playerData.id ?? 0)", value: "\(soldValue)",tag:playerData)
                } else {
                    self.loadInitialVC()
                }
            }))
            
            alert.addAction(UIAlertAction(title: getLanguage["delete_product"] ?? "", style: .default, handler: { _ in
                if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                    self.deleteProductAct(Itemid:"\(playerData.id ?? 0)")
                } else {
                    self.loadInitialVC()
                }
            }))
        }
        
        else {
            if (playerData.exchangeBuy ?? "") == "1" && EXCHANGE_MODEL_FLAG {
                alert.addAction(UIAlertAction(title: getLanguage["create_exchange"], style: .default, handler: { (UIAlertAction) in
                    self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                        print(success)
                        if success {
                            if let profileData = self.viewModels.profileModel?.result {
                                self.profileData = profileData
                                if self.profileData?.verification.mobNo == false{
                                    self.showAlerts()
                                }else{
                                    if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                                        self.exchangeAct(tag: playerData)
                                    }
                                    else {
                                        self.loadInitialVC()
                                    }
                                }
                            }
                        }
                    }) { (failure) in
                    }
                    
              
                }))
            }
            var reportTitle = ""
            var reportVal = 0
            if playerData.report ?? "" == "yes" {
                reportTitle = getLanguage["undo_report"] ?? ""   //oldcode
                //new addon
                // reportTitle = getLanguage["reported_new"] ?? ""
                reportVal = 1
                
            }
            else {
                reportTitle = getLanguage["report_product"] ?? ""
                reportVal = 0
            }
            alert.addAction(UIAlertAction(title: reportTitle, style: .default, handler: { (UIAlertAction) in
                if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                    self.reportAct(reportVal,tag: playerData)   //oldcode
                    //new addon
                    //                        if self.playerData..report ?? "" == "no"{
                    //                          self.reportAct(reportVal)
                    //                        }else{
                    //                            self.view.makeToast(getLanguage["reported_new1"])
                    //                        }
                }
                else {
                    self.loadInitialVC()
                }
            }))
            
        }
        alert.addAction(UIAlertAction(title: getLanguage["cancel"], style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func reportAct(_ reportVal: Int,tag:StoryListModel) {
        var reportTitle = ""
        if reportVal == 0 {
            reportTitle = getLanguage["Did you like to report this item?"] ?? ""
        }
        else {
            reportTitle = getLanguage["Did you like to undo report this item?"] ?? ""
        }
        let alert = UIAlertController(title: getLanguage["alert"], message: reportTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .default, handler: { (UIAlertAction) in
            Utility.shared.startAnimation(viewController: self)
            self.itemdetailsmodel.reportItemAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(tag.id ?? 0)", onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                var reportMessage = (self.itemdetailsmodel.alertModel?.message ?? "")
                
                if success {
                    if tag.report ?? "" == "yes" {
                        tag.report = "no"
                    }
                    else {
                        tag.report = "yes"
                    }
                    if reportMessage == "Reported Successfully" {
                        reportMessage = "reported_successfully"
                    }
                    else {
                        reportMessage = "unreported_successfully"
                    }
                }
                self.showAlert(getLanguage[reportMessage] ?? reportMessage)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }))
        alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func showAlert(_ message: String) {
        let reportAlert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        reportAlert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
        self.present(reportAlert, animated: true, completion: nil)
    }
    @objc func shareBtnAct(_ sender: UIButton) {
        
        if let cell = self.collectionView.cellForItem(at: currentPlayerIndex) as? StoryAllCollectionCell {
            cell.avPlayer?.pause()
            cell.playImageView.isHidden = false
        }
        let stream_id = self.storyModel[sender.tag].videoId ?? ""
        let item = self.storyModel[sender.tag]
                if item.product_type == "image" {
                    let text = (item.productUrl ?? "")
                    let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
                    if vc.popoverPresentationController != nil{
                        popoverPresentationController?.sourceView = self.view
                        popoverPresentationController?.sourceRect = self.view.bounds
                    }
                    if let cell = self.collectionView.cellForItem(at: self.currentPlayerIndex) as? StoryAllCollectionCell {
                        cell.playImageView.isHidden = true
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }else{
                    let invite_link = "videos?stream/\(stream_id)"
                    guard let link = URL(string: "\(UserDefaultModule.shared.getbaseurlonly() ?? "https://batner.com/")\(invite_link)") else { return }
                    print("printing the link:\(link)")
                        DispatchQueue.main.async {
                            var share_content = ""
                            var subject_content = getLanguage["subject_video_product"] ?? ""
                            if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                                share_content = "\(UserDefaultModule.shared.getUserData()?.fullName ?? "") \(getLanguage["shared_video_product"] ?? "") (\(link))"
                            } else{
                                share_content = "\(getLanguage["shared_video_product"] ?? "") (\(link))"
                            }
                            let imageToShare = [share_content] as [Any]
                            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                            activityViewController.popoverPresentationController?.sourceView = self.view
                            self.present(activityViewController, animated: true, completion: nil)
                            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                if let cell = self.collectionView.cellForItem(at: self.currentPlayerIndex) as? StoryAllCollectionCell {
                                    cell.avPlayer?.play()
                                    cell.playImageView.isHidden = true
                                }
                            }
                        }
                }
    }
    
    //    @objc func shareBtnAct(_ sender: UIButton) {
    //        //        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
    //                    if let cell = self.collectionView.cellForItem(at: currentPlayerIndex) as? StoryAllCollectionCell {
    //                        print("stop the pause 4")
    //                        cell.avPlayer?.pause()
    //                        cell.playImageView.isHidden = false
    //                    }
    //                    let stream_id = self.storyModel[sender.tag].videoId ?? ""
    //                    let invite_link = "videos?stream_id=\(stream_id)"
    //                    guard let link = URL(string: "\(BASE_URL)\(invite_link)") else { return }
    //                    let dynamicLinksDomainURIPrefix = DYNAMIC_LINK
    //                    let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
    //                    linkBuilder?.iOSParameters?.customScheme = IOS_BUNDLE_ID
    //                    linkBuilder?.iOSParameters?.appStoreID = APP_STORE_ID
    //                    linkBuilder!.iOSParameters = DynamicLinkIOSParameters(bundleID: IOS_BUNDLE_ID)
    //                    linkBuilder!.androidParameters = DynamicLinkAndroidParameters(packageName: ANDROID_PACKAGE_NAME)
    //                    linkBuilder!.shorten() { url, warnings, error in
    //                        //share link generated
    //                        DispatchQueue.main.async {
    //                            let text = (url?.absoluteString ?? "")
    //                            var share_content = ""
    //                            if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
    //                                 share_content = "\(UserDefaultModule.shared.getUserData()?.fullName ?? "") \(getLanguage["shared_video_product"] ?? "") \(text)"
    //                            } else{
    //                                 share_content = "\(getLanguage["shared_video_product"] ?? "") \(text)"
    //                            }
    //                            let imageToShare = [share_content] as [Any]
    //                            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
    //                            activityViewController.popoverPresentationController?.sourceView = self.view
    //                            self.present(activityViewController, animated: true, completion: nil)
    //                            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
    //                                   if let cell = self.collectionView.cellForItem(at: self.currentPlayerIndex) as? StoryAllCollectionCell {
    //                                       cell.avPlayer?.play()
    //                                       cell.playImageView.isHidden = true
    //                                   }
    //                            }
    //                        }
    //                    }
    //        //        }else{
    //        //            self.loadInitialVC()
    //        //        }
    //            }
}

extension StoryAllList: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.storyModel.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
        //        return self.collectionView.frame.size
    }
    
    func configCell(_ cell: StoryAllCollectionCell, model: StoryListModel) {
        cell.collectionView.isHidden = true
        cell.progressView.setProgress(0, animated: false)
        cell.sliderView.setValue(0, animated: false)
        cell.loadData(model, products: self.selectedProductModel)
        DispatchQueue.main.async {
            cell.imagelistcv.reloadData()
        }
        cell.collectionView.isHidden = true
        print("the print check for 1")
        //        cell.loadProducts()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryAllCollectionCell", for: indexPath) as! StoryAllCollectionCell
        cell.collectionView.isHidden = true
        cell.playpassdelegate = self
        cell.descriptionDelegate = self
        cell.checkAdStatusAndLoadBanner()
        
        print("the print check for 2 \(indexPath.item)")
        cell.viewAct = self
        self.view.bringSubviewToFront(cell.sliderView)
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
            cell.playerView.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.thumbImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.likeView.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.cmntView.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.shareView.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.playImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.urgentstatusLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.adstatusLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        if self.storyModel.indices.contains(indexPath.item) {
            let url = "\(UserDefaultModule.shared.getstreamurl() ?? "https://batner.com:5003")\(VIDEO_THUMB_PATH)\(self.storyModel[indexPath.item].streamThumbnail ?? "")"
            print("thumbImageView: \(url)")
            cell.thumbImageView.sd_setImage(with: URL(string: url), placeholderImage: nil)
            // self.currentPlayerIndex = IndexPath(item: (indexPath.item), section: 0)
            print("self.currentPlayerIndex_cellforrowat:\(self.currentPlayerIndex)")
            
            
            cell.publisherId = self.self.storyModel[indexPath.item].publisherId
            let item = self.storyModel[indexPath.item]
            cell.tempData = item
            
            
            let iOSVideo = item.playbackUrl ?? ""
            if let escapedUrl = iOSVideo.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed){
                //            let videoURL = HLSVideoCache.shared.reverseProxyURL(from: URL(string: escapedUrl)!)!
                print("escapedUrl: \(escapedUrl)")
                if let url = URL(string: escapedUrl) {
                    let playerItem = AVPlayerItem(url: url)
                    cell.avPlayer = AVPlayer(playerItem: playerItem)
                    print("playback errorrr : \(cell.avPlayer?.currentItem?.error?.localizedDescription) - \(playerItem.error?.localizedDescription) - \(cell.avPlayer?.error?.localizedDescription)")
                    
                    cell.avPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] time in
                        
                        guard let player = cell.avPlayer else { return }
                        
                        let totalSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
                        let currentSeconds = CMTimeGetSeconds(player.currentTime())
                        
                        let totalTimeString = self?.formatTime(seconds: totalSeconds)
                        let currentTimeString = self?.formatTime(seconds: currentSeconds)
                        
                        cell.videoTimeLabel.text = "\(currentTimeString ?? "00:00") / \(totalTimeString ?? "00:00")"
                    }
                    //                    let status: AVPlayerItem.Status
                    //                    switch status {
                    //                    case .readyToPlay:
                    //                        break
                    //                            // Player item is ready to play.
                    //                        case .failed:
                    //                        handleErrorWithMessage(cell.avPlayer.currentItem?.error?.localizedDescription, error:cell.avPlayer.currentItem?.error)
                    //                        case .unknown:
                    //                            break
                    //                            // Player item is not yet ready.
                    //                        }
                }
            }
            if cell.avPlayer != nil {
                cell.playerLayer = AVPlayerLayer(player: cell.avPlayer!)
                if(item.videoType != "gallery") {
                    /*old code solai change
                     cell.thumbImageView.contentMode = .scaleAspectFill
                     cell.playerLayer?.videoGravity = .resizeAspectFill
                     cell.playerLayer?.contentsGravity = .resizeAspectFill
                     */
                    cell.thumbImageView.contentMode = .scaleAspectFit
                    cell.playerLayer?.contentsGravity = .resizeAspectFill
                    cell.playerLayer?.videoGravity = .resizeAspect      // Video aspect ratio
                } else {
                    cell.thumbImageView.contentMode = .scaleAspectFit
                    cell.playerLayer?.videoGravity = .resizeAspect
                }
                cell.playerLayer?.frame = cell.playerView.bounds
                cell.playerLayer?.masksToBounds = true
                if let layer = cell.playerLayer {
                    cell.playerView.layer.addSublayer(layer)
                }
            }
            cell.collectionView.isHidden = true
            print("the print check for 3")
            self.configCell(cell, model: item)
            cell.playImageView.isHidden = true
            if UIDevice.current.hasNotch {
                cell.bottomConst.constant = bottomPadding
            }else{
                cell.bottomConst.constant = 30
            }
            cell.storyVC = self
            cell.timeprocess()
            cell.reloadVideo = "no"
            cell.profileBtn.isUserInteractionEnabled = true
            cell.cmntBtn.isUserInteractionEnabled = true
            cell.likeBtn.tag = indexPath.item
            cell.cmntBtn.tag = indexPath.item
            cell.profileBtn.tag = indexPath.item
            cell.shareBtn.tag = indexPath.item
            cell.tempIndex = indexPath.item
            cell.MoreBtn.tag = indexPath.item
            cell.Exchangebtn.tag = indexPath.item
            cell.CallBtnTap.tag = indexPath.item
            cell.chatButton.tag = indexPath.item
            cell.buyNowButton.tag = indexPath.item
            cell.MakeAnOfferbtn.tag = indexPath.item
            cell.profileImg.sd_setImage(with: URL(string: self.storyModel[indexPath.item].seller_image), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
            cell.profileImg.cornerViewRadius()
            cell.profileView.cornerViewRadius()
            cell.likeBtn.bringSubviewToFront(self.view)
            //            if self.storyModel[indexPath.item].publisherId != UserDefaultModule.shared.getUserData()?.user_id ?? ""{
            //                cell.likeStack.isHidden = false
            //            }else{
            //                cell.likeStack.isHidden = true
            //            }
            cell.likeBtn.addTarget(self, action: #selector(self.likeBtnAct(_:)), for: .touchUpInside)
            cell.cmntBtn.addTarget(self, action: #selector(self.cmntBtnAct(_:)), for: .touchUpInside)
            cell.shareBtn.addTarget(self, action: #selector(self.shareBtnAct(_:)), for: .touchUpInside)
            cell.profileBtn.addTarget(self, action: #selector(self.profileBtnAct(_:)), for: .touchUpInside)
            cell.MoreBtn.addTarget(self, action: #selector(self.MoreBtnAct(_:)), for: .touchUpInside)
            cell.Exchangebtn.addTarget(self, action: #selector(self.ExchangebtnAct(_:)), for: .touchUpInside)
            cell.CallBtnTap.addTarget(self, action: #selector(self.CallbtnAct(_:)), for: .touchUpInside)
            cell.chatButton.addTarget(self, action: #selector(self.chatButtonAct(_:)), for: .touchUpInside)
            cell.buyNowButton.addTarget(self, action: #selector(self.buyNowAct(_:)), for: .touchUpInside)
            cell.MakeAnOfferbtn.addTarget(self, action: #selector(self.MakebtnTapped(_:)), for: .touchUpInside)
            cell.imageBtn.tag = indexPath.item
            
            cell.storyAllDelegate = self
            
            
            if self.storyModel[indexPath.item].publisherId != UserDefaultModule.shared.getUserData()?.user_id ?? ""{
                if self.storyModel[indexPath.item].makeOffer == "0" {
                    cell.MakeAnOfferbtn.isHidden = false
                }else{
                    cell.MakeAnOfferbtn.isHidden = true
                }
            }else{
                cell.MakeAnOfferbtn.isHidden = true
            }
            
            //newforcell
            
            
            
        }
        
        if ((storyModel.count-3 == indexPath.item))  {
            print("story value -3 value")
            if self.fromNav != "" {
                let offset : Int = self.loadmorecount * 8
                if(self.storyModel.count == 0){
                    self.type = "after"
                    self.loadData1(0,"after",self.fromNav, loadmore: "true")
                }else{
                    if (self.storyModel.count%8 == 0 || self.viewModel.storyListArray.count >= 8){
                        self.type = "after"
                        self.loadData1(self.newOffset,"after",self.fromNav, loadmore: "true")
                    }
                }
            }else{
                let offset : Int = self.loadmorecount * 8
                if(self.storyModel.count == 0){
                    self.type = "after"
                    self.loadData1(0,"after",self.fromNav, loadmore: "true")
                }else{
                    if (self.storyModel.count%8 == 0 || self.viewModel.storyListArray.count >= 8){
                        self.type = "after"
                        self.loadData1(self.newOffset,"after",self.fromNav, loadmore: "true")
                    }
                }
            }
        }
        cell.productAct = { [weak self] id in
            guard let self = self else {
                return
            }
            print("item_id_itemdetails:\(Int(id) ?? 0)")
            let pageObj = ItemDetailsViewController()
            pageObj.itemID = Int(id) ?? 0
            pageObj.video_id = self.storyModel[indexPath.item].videoId
            pageObj.stream_thumb = self.storyModel[indexPath.item].streamThumbnail
            pageObj.interLikedel = self
            pageObj.intercmntdel = self
            NotificationCenter.default.removeObserver(self)
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
        if indexPath.item == 0 {
            if self.storyModel[indexPath.item].product_type != "video" {
                let newitem = self.storyModel[indexPath.item]
                cell.imageSelectedAct(photos: newitem.photos[0], index: indexPath.item)
            }
        }
        return cell
    }
    
    func formatTime(seconds: Double) -> String {
        guard seconds.isFinite else {
            return "00:00" // Handle infinite or NaN values gracefully
        }
        
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    func handleErrorWithMessage(_ message: String?, error: Error? = nil) {
        print("Error occured with message: \(message), error: \(error).")
    }
    func stopAllPlayer(_ isStopAll: Bool = false) {
        print("Stop All Player Called:: \(isStopAll)")
        for index in 0..<storyModel.count {
            print("stopped av player2")
            if index != currentPlayerIndex.row || isStopAll{
                print("stopped av player0")
                for item in 0..<storyModel.count {
                    let index = IndexPath(item: item, section: 0)
                    
                    // if let cell = collectionView.cellForRow(at: index) as? StoryAllCollectionCell
                    if let cell = collectionView!.cellForItem(at: index)  as? StoryAllCollectionCell{
                        print("stopped av player1")
                        
                        cell.collectionView.isHidden = true
                        if (cell.avPlayer?.isPlaying ?? true) {
                            print("stop the pause 1")
                            cell.avPlayer?.pause()
                        }
                    }
                }
                
                
            }
        }
        self.isStopPlayer = currentPlayerIndex.item
        
    }
    
    func filterSelectedProduct() {
        if self.storyModel.count > currentPlayerIndex.item {
            if let products = self.storyModel[currentPlayerIndex.item].products {
                print("storyModel.currentPlayerIndex.products:\(products)")
                self.selectedProductModel.removeAll()
                if let product = self.productModel.filter({$0.product_id == products}).first {
                    self.selectedProductModel.append(product)
                }
            }
        }
        print("storyModel.currentPlayerIndex.selectedProductModel:\(selectedProductModel)")
    }
    
    @objc func updateTimer() {
        if self.isStopPlayer != currentPlayerIndex.row{
            self.stopAllPlayer()
            self.isStopPlayer = currentPlayerIndex.row
        }
        if let cell = self.collectionView.cellForItem(at: currentPlayerIndex) as? StoryAllCollectionCell {
            if let vc = self.appdelegate?.window?.visibleViewController() {
                //             if vc is StoryAllList {
                //                 self.isPlayVideo = true
                //             }
            }
            if (self.viewIfLoaded != nil) && (self.view.window != nil) {
                if cell.playImageView.isHidden {
                    
                    if let status = cell.avPlayer?.currentItem?.status, status != .failed {
                        self.isFailed = false
                        if let status = cell.avPlayer?.currentItem?.status, status == .readyToPlay {
                            cell.thumbImageView.isHidden = true
                        }
                        
                        if self.isPlayVideo {
                            if !(cell.avPlayer?.isPlaying ?? false) {
                                self.filterSelectedProduct()
                                //                             cell.loadProducts()
                                print("PlayerSate:: \(cell.avPlayer?.isPlaying ?? false)")
                                if !cell.isSliding {
                                    cell.avPlayer?.playImmediately(atRate: 1.0)
                                }
                                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.avPlayer?.currentItem, queue: .main) { (_) in
                                    cell.playImageView.isHidden = true
                                    cell.avPlayer?.seek(to: .zero)
                                    print("end time for you")
                                    cell.resetZoom()
                                    cell.reloadVideo = "yes"
                                }
                            }
                        }
                    }
                    else if !isFailed{
                        self.isFailed.toggle()
                        print("Player Failed")
                        cell.playerLayer = nil
                        cell.avPlayer = nil
                        if self.storyModel.count > currentPlayerIndex.item {
                            self.configCell(cell, model: self.storyModel[currentPlayerIndex.row])
                        }
                    }
                }
                else {
                    if (cell.avPlayer?.isPlaying ?? false) {
                        print("stop the pause 2")
                        cell.avPlayer?.pause()
                    }
                }
            }
            else {
                if (cell.avPlayer?.isPlaying ?? false) {
                    print("stop the pause 3")
                    cell.avPlayer?.pause()
                }
            }
        }
    }
    @objc func updateProgressTimer() {
        var playerCell: StoryAllCollectionCell?
        playerCell = self.collectionView.cellForItem(at: currentPlayerIndex) as? StoryAllCollectionCell
        
        if let cell = playerCell {
            if let status = cell.avPlayer?.currentItem?.status, status == .readyToPlay {
                cell.thumbImageView.isHidden = true
            }
            if (self.viewIfLoaded != nil) && (self.view.window != nil) {
                if cell.playImageView.isHidden {
                    if let status = cell.avPlayer?.currentItem?.status, status == .readyToPlay {
                        if let currentDuration = cell.avPlayer?.currentItem?.currentTime(), let duration = cell.avPlayer?.currentItem?.duration {
                            let currentSeconds = CMTimeGetSeconds(currentDuration)
                            let totalSeconds = CMTimeGetSeconds(duration)
                            let progress: Float = Float(currentSeconds/totalSeconds)
                            if currentDuration.seconds > 0.1 {
                                cell.progressView.setProgress(progress, animated: false)
                                cell.sliderView.setValue(progress, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        if collectionView == self.collectionView {
            print("Stop Player")
            self.stopAllPlayer(true)
            self.isPlayVideo = true
        }
    }
    
    func loadData1(_ offset: Int,_ type: String,_ page: String,loadmore : String) {
        if self.filterArray.count == 0 && (FILTER_DATA.location == "" || FILTER_DATA.location.lowercased() == "worldwide" || FILTER_DATA.location.lowercased() ==  UserDefaultModule.shared.getcountryname()?.lowercased()) {
            
            self.search_type = "all"
            FILTER_DATA.lat = ""
            FILTER_DATA.long = ""
            if offset == 0 {
                self.promotionTags = ""
            }
        }
        else if (FILTER_DATA.location == "" || FILTER_DATA.location.lowercased() == "worldwide" || FILTER_DATA.location.lowercased() ==  UserDefaultModule.shared.getcountryname()?.lowercased()) {
            FILTER_DATA.lat = ""
            FILTER_DATA.long = ""
        }
        else if FILTER_DATA.location.lowercased() != "worldwide" &&  FILTER_DATA.getSortID() == "1" && FILTER_DATA.Category_id == "" && FILTER_DATA.Price == "0-5000" && FILTER_DATA.posted_within == "" && FILTER_DATA.Search_key == ""{
            self.search_type = "all"
            if offset == 0 {
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
        
        print("loaddata1_offest:\(offset) loaddata1_limit:\("8")  page:\(self.fromNav) type:\(type) loadmore:\(loadmore) afterpostion:\(self.after_position) postion:\(self.position) beforepostion:\(self.before_position)")
        print("getStoryData:\(userId)")
        print("getStoryData:\(UserDefaultModule.shared.getUserData()?.user_id ?? "")")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var url = ""
        // let requestDict = NSMutableDictionary.init()
        var requestDict = [String: Any]()
        
        if self.fromNav == "filterdata"{
            url = HTS_VIDEOS
            requestDict["ad_product"] = self.ad_product
            requestDict["loadmore"] = loadmore
            requestDict["user_id"] = self.userId
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "8"
            requestDict["video_id"] = self.videoID
            requestDict["scroll_type"] = type
            requestDict["hts_product_id"] = self.hts_product_id
            requestDict["position"] = self.position
            requestDict["before_position"] = self.before_position
            requestDict["after_position"] = self.after_position
            requestDict["type"] = self.getitemstype
            requestDict["lang_type"] = DEFAULT_LANGUAGE_CODE
            //            if self.promotionTags != "" {
            //                requestDict["ads"] = self.promotionTags
            //            }
            requestDict["price"] = FILTER_DATA.Price
            requestDict["search_key"] = FILTER_DATA.Search_key
            requestDict["category_id"] = self.category_id
            requestDict["subcategory_id"] = self.subcategory_id
            requestDict["item_id"] = FILTER_DATA.item_id
            requestDict["seller_id"] = FILTER_DATA.seller_id
            requestDict["sorting_id"] = FILTER_DATA.getSortID()
            requestDict["posted_within"] = FILTER_DATA.posted_within
            requestDict["distance"] = FILTER_DATA.distance
            requestDict["distance_type"] = FILTER_DATA.distance_type
            requestDict["filters"] = filterString
            requestDict["product_condition"] = "\(product_id)"
            requestDict["child_category_id"] = self.child_category_id
            requestDict["lat"] = FILTER_DATA.lat
            requestDict["lon"] = FILTER_DATA.long
            requestDict["search_type"] = self.search_type
            
        }else if self.fromNav == "Home"{
            url = HTS_VIDEOS
            requestDict["loadmore"] = loadmore
            requestDict["user_id"] = self.userId
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "8"
            requestDict["video_id"] = self.videoID
            requestDict["scroll_type"] = type
            requestDict["hts_product_id"] = self.hts_product_id
            requestDict["position"] = self.position
            requestDict["before_position"] = self.before_position
            requestDict["after_position"] = self.after_position
            requestDict["type"] = self.getitemstype
            requestDict["lang_type"] = DEFAULT_LANGUAGE_CODE
            //            if self.promotionTags != "" {
            //                requestDict["ads"] = self.promotionTags
            //            }
            requestDict["price"] = ""
            requestDict["search_key"] = ""
            
            if self.filtersort == ""{
                requestDict["sorting_id"] = "1"
            }else if self.filtersort != ""{
                requestDict["sorting_id"] = self.filtersort
            }
            
            
            requestDict["posted_within"] = ""
            if self.getitemstype == "search"{
                requestDict["ad_product"] = self.ad_product
                
                requestDict["item_id"] = ""
                if self.category_id == "0"{
                    requestDict["category_id"] = ""
                }else{
                    requestDict["category_id"] = self.category_id
                }
                requestDict["subcategory_id"] = self.subcategory_id
                requestDict["child_category_id"] = self.child_category_id
                requestDict["seller_id"] = ""
                requestDict["distance"] = FILTER_DATA.distance
                requestDict["distance_type"] = FILTER_DATA.distance_type
                requestDict["lat"] = FILTER_DATA.lat
                requestDict["lon"] = FILTER_DATA.long
                requestDict["search_type"] = self.search_type
                
            }else if self.getitemstype == ""{
                requestDict["ad_product"] = ""
                requestDict["item_id"] = ""
                requestDict["category_id"] = self.category_id
                requestDict["subcategory_id"] = self.subcategory_id
                requestDict["child_category_id"] = ""
                requestDict["seller_id"] = ""
                requestDict["distance"] = ""
                requestDict["distance_type"] = ""
                requestDict["lat"] = ""
                requestDict["lon"] = ""
                requestDict["search_type"] = ""
                requestDict["related_videoid"] = self.relatedVideoID
            }
            else{
                requestDict["ad_product"] = self.ad_product
                if self.getitemstype == "moreitems"{
                    requestDict["item_id"] = self.itemID
                }else if self.getitemstype == "liked"{
                    requestDict["item_id"] = ""
                }
                requestDict["category_id"] = ""
                requestDict["subcategory_id"] = ""
                requestDict["child_category_id"] = ""
                requestDict["seller_id"] = self.seller_id
                requestDict["distance"] = ""
                requestDict["distance_type"] = ""
                requestDict["lat"] = ""
                requestDict["lon"] = ""
                requestDict["search_type"] = ""
            }
            requestDict["filters"] = ""
            requestDict["product_condition"] = ""
        }
        else if fromNav == "profile"{
            url = HTS_MY_VIDEOS
            requestDict["related_videoid"] = self.relatedVideoID
            requestDict["user_id"] = self.userId
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "8"
            requestDict["video_id"] = self.videoID
            requestDict["scroll_type"] = type
        }else{
            url = HTS_PRODUCT_VIDEOS
            requestDict["user_id"] = self.userId
            requestDict["offset"] = "\(offset)"
            requestDict["limit"] = "8"
        }
        if self.selectedSearchType == "video" ||  self.selectedSearchType == "image" {
            requestDict["selected_type"] = self.selectedSearchType
            requestDict["page_type"] = "product_video"
        } else {
            requestDict["selected_type"] = ""
            requestDict["page_type"] = "product_video"
        }
        
        self.viewModel.getStoryData(url: url,startRequest: requestDict) { success in
            
            self.stopAllPlayer()
            if self.fromNav != ""
            {
                self.backButton.isHidden = false
                /*
                 self.afterModel += self.viewModel.storyListArray
                 // self.storyModel = self.beforeModel+self.afterModel
                 self.storyModel = self.afterModel
                 */
                self.storyModel += self.viewModel.storyListArray
                print("herecomes page is havig loaddata1:\(self.viewModel.storyListArray)")
                print("herecomes page is havig data model loaddata1:\(self.storyModel)")
                print("herecomes page is havig data stored loaddata1:\(self.storyModel.count)")
                if (self.viewModel.storymodel?.ads.count ?? 0) > 0 {
                    self.promotionTags = self.convertIntoJSONString(arrayObject: (self.viewModel.storymodel?.ads ?? [String]())) ?? ""
                }
                else {
                    self.promotionTags = ""
                }
                
                //   self.collectionView.performBatchUpdates {
                if self.viewModel.storyListArray.count > 0{
                    self.loadmorecount = self.loadmorecount + 1
                    self.collectionView.reloadData()
                    //    self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                }
                /*
                 self.afterModel += self.viewModel.storyListArray
                 self.storyModel = self.beforeModel+self.afterModel
                 print("before model after: \(self.storyModel)")
                 */
                /*
                 } completion: { status in
                 if self.viewModel.storyListArray.count <= 0{
                 self.showToast(message: "No Videos Found", font: .systemFont(ofSize: 12.0),type: "after")
                 }else{
                 
                 }
                 }
                 */
            }
            else {
                print("page empty1")
                self.storyModel += self.viewModel.storyListArray
                self.collectionView.performBatchUpdates {
                    if self.viewModel.storyListArray.count > 0{
                        self.loadmorecount = self.loadmorecount + 1
                        self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                    }
                } completion: { status in
                    if self.viewModel.storyListArray.count <= 0{
                        self.showToast(message: "No Videos Found", font: .systemFont(ofSize: 12.0),type: "after")
                    }else{
                        
                    }
                }
            }
            
            dispatchGroup.leave()
            print("Status: \(success)")
            if url == HTS_VIDEOS {
                print("self.viewModel.storymodel?.newOffset ?? 0: \(self.viewModel.storymodel?.ads.count)")
                self.newOffset += self.viewModel.storymodel?.newOffset ?? 0
            }
        } onFailure: { failure in
            dispatchGroup.leave()
            print("Failure: \(failure)")
        }
        self.stopAllLoader()
        self.filterSelectedProduct()
        self.loadFilterData()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingFinished(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        scrollingFinished(scrollView: scrollView)
    }
    
    func scrollingFinished(scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        if collectionView == self.collectionView {
            print("cell for item scroll at")
            for cell in self.collectionView.visibleCells {
                
                if let index = self.collectionView.indexPath(for: cell) {
                    if let cell1 = cell as? StoryAllCollectionCell {
                        cell1.countTimer.invalidate()
                        cell1.collectionView.isHidden = true
                        cell1.playerView.isHidden = false
                        cell1.sliderView.isHidden = false
                        
                        print("the print check for 4")
                        if checkVisibilityOfCell(cell: cell1, indexPath: index) {
                            currentPlayerIndex = index
                            cell1.selectedindex = 0
                            cell1.imagelistcv.reloadData()
                            print("storyModel.count-1 : \(storyModel.count-1) currentPlayerIndex.item : \(currentPlayerIndex.item)")
                            //                                if ((self.viewModel.storyListArray.count-1 == currentPlayerIndex.item)){
                            //                                    print("story value -1 value")
                            //                                    self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                            //                                }
                            if ((storyModel.count-3 == currentPlayerIndex.item))  {
                                print("story value -3 value")
                                if self.fromNav != "" {
                                    
                                    let offset : Int = self.loadmorecount * 8
                                    if(self.storyModel.count == 0){
                                        self.type = "after"
                                        self.loadData1(0,"after",self.fromNav, loadmore: "true")
                                    }else{
                                        //if self.afterModel.count >= 20
                                        if (self.storyModel.count%8 == 0 || self.viewModel.storyListArray.count >= 8){
                                            self.type = "after"
                                            self.loadData1(offset,"after",self.fromNav, loadmore: "true")
                                        }
                                    }
                                }else{
                                    let offset : Int = self.loadmorecount * 8
                                    if(self.storyModel.count == 0){
                                        self.type = "after"
                                        self.loadData1(0,"after",self.fromNav, loadmore: "true")
                                    }else{
                                        //if self.storyModel.count >= 20
                                        if (self.storyModel.count%8 == 0 || self.viewModel.storyListArray.count >= 8){
                                            self.type = "after"
                                            self.loadData1(self.newOffset,"after",self.fromNav, loadmore: "true")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
            if let cell = self.collectionView.cellForItem(at: indexPath) as? StoryAllCollectionCell {
                if self.storyModel[indexPath.item].product_type != "video" {
                    let newitem = self.storyModel[indexPath.item]
                    cell.imageSelectedAct(photos: newitem.photos[0], index: indexPath.item)
                }
            }
        }
    }
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    //       guard let collectionView = scrollView as? UICollectionView else { return }
    //        if collectionView == self.collectionView {
    //            print("cell for item scroll at")
    //                for cell in self.collectionView.visibleCells {
    //
    //                    if let index = self.collectionView.indexPath(for: cell) {
    //                        if let cell1 = cell as? StoryAllCollectionCell {
    //                            cell1.countTimer.invalidate()
    //                            cell1.collectionView.isHidden = true
    //                            if checkVisibilityOfCell(cell: cell1, indexPath: index) {
    //                                 currentPlayerIndex = index
    //
    //                                print("storyModel.count-1 : \(storyModel.count-1) currentPlayerIndex.item : \(currentPlayerIndex.item)")
    ////                                if ((self.viewModel.storyListArray.count-1 == currentPlayerIndex.item)){
    ////                                    print("story value -1 value")
    ////                                    self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
    ////                                }
    //                                if ((storyModel.count-3 == currentPlayerIndex.item))  {
    //                                    print("story value -3 value")
    //                                if self.fromNav != "" {
    //                                    let offset : Int = self.loadmorecount * 8
    //                                    if(self.storyModel.count == 0){
    //                                        self.type = "after"
    //                                        self.loadData1(0,"after",self.fromNav, loadmore: "true")
    //                                    }else{
    //                                        //if self.afterModel.count >= 20
    //                                        if (self.storyModel.count%8 == 0 || self.viewModel.storyListArray.count >= 8){
    //                                            self.type = "after"
    //                                            self.loadData1(offset,"after",self.fromNav, loadmore: "true")
    //                                        }
    //                                    }
    //                                }else{
    //                                    let offset : Int = self.loadmorecount * 8
    //                                    if(self.storyModel.count == 0){
    //                                        self.type = "after"
    //                                        self.loadData1(0,"after",self.fromNav, loadmore: "true")
    //                                    }else{
    //                                        //if self.storyModel.count >= 20
    //                                        if (self.storyModel.count%8 == 0 || self.viewModel.storyListArray.count >= 8){
    //                                            self.type = "after"
    //                                            self.loadData1(offset,"after",self.fromNav, loadmore: "true")
    //                                        }
    //                                    }
    //                                }
    //                              }
    //                            }
    //                        }
    //                    }
    //                }
    //
    //        }
    //
    //    }
    
    //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //       guard let collectionView = scrollView as? UICollectionView else { return }
    //        if collectionView == self.collectionView {
    //          for cell in self.collectionView.visibleCells {
    //             if let index = self.collectionView.indexPath(for: cell) {
    //                if let cell1 = cell as? StoryAllCollectionCell {
    //                   if checkVisibilityOfCell(cell: cell1, indexPath: index) {
    //                      cell1.playImageView.isHidden = true
    //                      currentPlayerIndex = index
    //                       if ((storyModel.count-1 == currentPlayerIndex.item)) {
    //                         self.isPlayVideo = true
    //                      }
    //                      else {
    //                          self.isPlayVideo = true
    //                          cell1.avPlayer?.seek(to: .zero)
    //                          cell1.reloadVideo = "no"
    //                          cell1.timeprocess()
    //                          if index.row == 0 {
    //                             self.collectionView.alwaysBounceVertical = false
    //                          }
    //                          else {
    //                             self.collectionView.alwaysBounceVertical = false
    //                          }
    //                      }
    //                      break
    //                   }
    //                }
    //             }
    //          }
    //       }
    //    }
    
    func checkVisibilityOfCell(cell: StoryAllCollectionCell, indexPath: IndexPath) -> Bool {
        // compute the frame of the cell
        if let cellRect = (self.collectionView.layoutAttributesForItem(at: indexPath)?.frame) {
            // it is visible iff the bounds of the cell are contained wholly in a collectionview
            let completelyVisible = self.collectionView.bounds.contains(cellRect)
            // update the cell accordingly
            if completelyVisible {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*
         if self.productModel.count > indexPath.item {
         self.productAct!(self.productModel[indexPath.item].product_id)
         }
         */
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

public extension UICollectionView {
    
    /// VisibleCells in the order they are displayed on screen.
    var orderedVisibleCells: [UICollectionViewCell] {
        return indexPathsForVisibleItems.sorted().compactMap { cellForItem(at: $0) }
    }
    /// Gets the currently visibleCells of a section.
    ///
    /// - Parameter section: The section to filter the cells.
    /// - Returns: Array of visible UICollectionViewCells in the argument section.
    func visibleCells(in section: Int) -> [UICollectionViewCell] {
        return visibleCells.filter { indexPath(for: $0)?.section == section }
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension UIViewController {
    func showToast(message : String, font: UIFont,type : String) {
        
        if type == "after"{
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-230, width: 150, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            //toastLabel.backgroundColor = UIColor.init(named: "AppThemeColor")
            toastLabel.textColor = UIColor.white
            toastLabel.font = font
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }else if type == "before"{
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y:self.view.frame.minX + 50 , width: 150, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            //toastLabel.backgroundColor = UIColor.init(named: "AppThemeColor")
            toastLabel.textColor = UIColor.white
            toastLabel.font = font
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
    
}

extension StoryAllList: InterLikeDelegate,InterCommentDelegate{
    func likeAct(_ id: Int, isLiked: String, count : Int) {
        self.storyModel.filter({$0.products == "\(id)"}).first?.liked = isLiked
        self.storyModel.filter({$0.products == "\(id)"}).first?.likesCount = count
        self.collectionView.reloadData()
    }
    
    func commentAct(_ id: Int, count : String) {
        self.storyModel.filter({$0.products == "\(id)"}).first?.commentsCount = Int(count)
        self.collectionView.reloadData()
    }
}

extension StoryAllList: itemDetailDelegate{
    func viewBtnAct(_ id: String, tag: Int,cell: StoryAllCollectionCell) {
        let pageObj = ItemDetailsViewController()
        pageObj.itemID = Int(id) ?? 0
        pageObj.video_id = self.storyModel[tag].videoId
        pageObj.stream_thumb = self.storyModel[tag].streamThumbnail
        pageObj.interLikedel = self
        pageObj.intercmntdel = self
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
}


extension StoryAllList: GADBannerViewDelegate{
    /// Tells the delegate an ad request loaded an ad.
    //    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    //        print("adViewDidReceiveAd")
    //        bannerView.isHidden = false
    //        bannerView.alpha = 0
    //        UIView.animate(withDuration: 1, animations: {
    //            bannerView.alpha = 1
    //        })
    //    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            bannerView.isHidden = false
        })
    }
    
    /// Tells the delegate an ad request failed.
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.BannerView.isHidden = true
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
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

extension StoryAllList: DescriptionPopDelegate{
    func showpopup(txt: String){
        debugPrint("showpopCalled")
        let pageObj = DescriptionPopupVC()
        pageObj.contentString = txt
        if #available(iOS 15.0, *) {
            if let sheet = pageObj.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                present(pageObj, animated: true, completion: nil)
            }
        } else {
            pageObj.modalPresentationStyle = .formSheet
            present(pageObj, animated: true, completion: nil)
        }
    }
}

extension StoryAllList: storyAllDelegate {
    
    func imageBtnAct(tag: Int, selectedTag: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var mediaItems: [MediaType] = []
            let item = self.storyModel[tag]
            if let photos = item.photos {
                for photo in photos {
                    if photo.type != "video" {
                        if let imageUrlStr = photo.itemUrlMainOriginal,
                           let imageUrl = URL(string: imageUrlStr) {
                            mediaItems.append(.image(imageUrl))
                        } else if let fallbackImageUrlStr = photo.itemUrlMain350,
                                  let fallbackImageUrl = URL(string: fallbackImageUrlStr) {
                            mediaItems.append(.image(fallbackImageUrl))
                        }
                    }
                }
            }
            
            let vc = ImageAndVideoVC()
            vc.items = mediaItems
            vc.index = tag
            vc.startIndex = selectedTag - 1
            vc.closeAct = { [weak self] in
                //                guard let self = self else { return }
                //                let targetIndexPath = IndexPath(item: tag, section: 0)
                //                self.collectionView.scrollToItem(at: targetIndexPath, at: .centeredHorizontally, animated: false)
                //                self.collectionView.reloadItems(at: [IndexPath(item: tag, section: 0)])
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                //                    if let cell = self.collectionView.cellForItem(at: targetIndexPath) as? StoryAllCollectionCell {
                //                        if self.storyModel[tag].product_type != "video" {
                //                            let imageTag = selectedTag == 0 ? 0 : selectedTag - 1
                //                            let newitem = self.storyModel[tag]
                //                            cell.itemimagevieew.image = nil
                //                            cell.imageSelectedAct(photos: newitem.photos[imageTag], index: tag)
                //                            cell.selectedindex = imageTag
                //                            cell.imagelistcv.reloadData()
                //                        }
                //                    } else {
                //                        print("Cell still not found — maybe index is wrong or reload issue")
                //                    }
                //                }
            }
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
}
