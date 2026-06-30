//
//  ItemDetailsViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 19/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//



import UIKit
import YoutubePlayer_in_WKWebView
import FBSDKShareKit
import ImageSlideshow
import GoogleMobileAds
import MapboxStatic
import AVKit


protocol likeDelegate {
    func likeAct(_ id: Int, isLiked: String)
}
protocol InterLikeDelegate {
    func likeAct(_ id: Int, isLiked: String, count : Int)
}
protocol InterCommentDelegate {
    func commentAct(_ id: Int, count : String)
}

class ItemDetailsViewController: UIViewController,UITextViewDelegate,MoreDelegate {
    func MorebtnTapped() {
        
    }
    
    func locationAct(city: String, state: String, country: String,countryCode: String, lat: String, long: String, location: String) {
        
    }
    
    @IBOutlet weak var youtubeLabel: UILabel!
    @IBOutlet weak var youtubeView: UIView!
    @IBOutlet weak var playerView: WKYTPlayerView!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var topViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alertmainview: UIView!
    @IBOutlet weak var AlertView: UIView!
    @IBOutlet weak var Morelbl: UILabel!
    @IBOutlet weak var imagelistcv: UICollectionView!
    @IBOutlet weak var itemimagevieew: UIImageView!
    @IBOutlet weak var itemconditionlbl: UIButton!
    @IBOutlet weak var Locationbtn: UIButton!
    @IBOutlet weak var prroducttitlename: UILabel!
    @IBOutlet weak var prroductprice: UILabel!
    @IBOutlet weak var DaysCountLbl: UILabel!
    @IBOutlet weak var Profileimageview: UIImageView!
    @IBOutlet weak var Newlikebtn: UIButton!
    @IBOutlet weak var NewlikecountLbl: UILabel!
    @IBOutlet weak var NewCommandbtn: UIButton!
    @IBOutlet weak var NewCommandcountLbl: UILabel!
    @IBOutlet weak var NewSharebtn: UIButton!
    @IBOutlet weak var NewShareCountLbl: UILabel!
    @IBOutlet weak var NewCallbtn: UIButton!
    @IBOutlet weak var NewCallLbl: UILabel!
    @IBOutlet weak var NewMorebtn: UIButton!
    @IBOutlet weak var NewMoreLbl: UILabel!
    @IBOutlet weak var CallStackView: UIStackView!
    @IBOutlet weak var BannerView: UIView!
    @IBOutlet weak var ExchangeStack: UIStackView!
    @IBOutlet weak var NewExchangeLbl: UILabel!
    @IBOutlet weak var DesTv: UITextView!
    @IBOutlet weak var DesTvHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var WholeView: UIView!
    @IBOutlet weak var PlusImgView: UIImageView!
    @IBOutlet weak var itemImageBtn: UIButton!
    @IBOutlet weak var MoreBtnNew: UIButton!
    @IBOutlet weak var DesLblew: UILabel!
    @IBOutlet weak var MoreViewCorner: UIView!
    @IBOutlet weak var MoreBtnNewview: UIView!
    let moreButton = UIButton()
    var itemDetails: ItemModel?
    var viewModel = ItemDetailsViewModel()
    var itemModel: GetItemsModel?
    var likeDelegate: likeDelegate?
    var profileData: ProfileResultModel?
    var isDescriptionExpanded = false
    var fullDescriptionText: String = ""

    var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate? = nil
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var getLikeData = ""
    var getLikeId = Int()
    var soldTitle = ""
    var bannerView1:GADBannerView!
    var refreshLike: (() -> Void)?
    var snapshotImage = #imageLiteral(resourceName: "profilelogo")
    
    var viewModels = ProfileViewModel()
    
    var isExpanded = false
    var navfrom = ""
    var selectedindex = 0
    var fullText = ""
    var interLikedel: InterLikeDelegate?
    var intercmntdel: InterCommentDelegate?
    
    var itemID = 0
    var video_id = ""
    var stream_thumb = ""
    
    
       let collapsedHeight: CGFloat = 60  // Approx. height for 3 lines
    let maxExpandedHeight: CGFloat = 300
    let maxLines = 3  // Limit to 3 lines before "More
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
         self.checkAdStatusAndLoadBanner()
        Morelbl.numberOfLines = maxLines
        Morelbl.isUserInteractionEnabled = true
        //            r
        //              updateLabel()
        Locationbtn.contentHorizontalAlignment = .right
        Locationbtn.titleLabel?.lineBreakMode = .byTruncatingTail // Truncate long text with "..."
        Locationbtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        // Adjust space between image and title
        let spacing: CGFloat = 3 // Set the desired spacing
        Locationbtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        Locationbtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        
        itemconditionlbl.contentEdgeInsets = .zero
        itemconditionlbl.titleEdgeInsets = .zero
        itemconditionlbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        itemconditionlbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        itemconditionlbl.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        itemconditionlbl.sizeToFit()
        DesTv.delegate = self
        self.DesTv.textColor = UIColor(named: "greencolortxt")
        
    }
    func setDescriptionText() {
        guard let textView = self.DesTv else { return }
        // Set basic text view properties
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = []
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = .zero

        let description = fullDescriptionText
        let maxLength = 40
        print("swder", description.count)

        // Check if the text should be truncated based on the maxLength or presence of line breaks
        let shouldShowMore = description.count > maxLength || description.contains("\n")

        let displayText: String
//        if isDescriptionExpanded || !shouldShowMore {
//            // Show the full description with 'Less' if it's expanded or within maxLength
//            displayText = description + (shouldShowMore ? " Less" : "")
//        } else {
            // Truncate the description to `maxLength` and replace newlines with spaces
            let index = description.index(description.startIndex, offsetBy: min(description.count, maxLength))
            let shortenedRaw = String(description[..<index])
            let cleaned = shortenedRaw.replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression)
            let shortenedText = cleaned.replacingOccurrences(of: "\n", with: " ")
            displayText = shortenedText + "...More"
//        }

        // Create an attributed string with a specified font and color
        let attributedString = NSMutableAttributedString(string: displayText)
        let fullRange = NSRange(location: 0, length: attributedString.length)
        let font = UIFont(name: APP_FONT_REGULAR, size: 14) ?? UIFont.systemFont(ofSize: 14)
        attributedString.addAttribute(.font, value: font, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "greencolortxt") ?? UIColor.green, range: fullRange)

        // Highlight "More" or "Less" with theme color and make it clickable
        if displayText.contains("More") || displayText.contains("Less") {
            let linkText = "More"
//            let linkText = isDescriptionExpanded ? "Less" : "More"
            let linkColor = UIColor(named: "AppThemeColorNew") ?? UIColor.blue
            let linkRange = (displayText as NSString).range(of: linkText)
            
            attributedString.addAttribute(.foregroundColor, value: linkColor, range: linkRange)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: linkRange)
            attributedString.addAttribute(.link, value: "action://toggle", range: linkRange)
        }

        // Assign the attributed string to the text view
        textView.attributedText = attributedString
        textView.linkTextAttributes = [:] // Disable default link styling
        textView.delegate = self

        // Adjust text view height based on whether the description is expanded or not
        if isDescriptionExpanded {
            let size = CGSize(width: textView.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
//            DesTvHeightConstraint.constant = estimatedSize.height
            self.openPopVC()
        } else {
//            DesTvHeightConstraint.constant = 20
        }

        self.view.layoutIfNeeded()
    }
    
    
    @IBAction func MoreAction(_ sender: Any) {
        self.openPopVC()
    }
    
    
    func openPopVC(){
        debugPrint("showpopCalled")
        let pageObj = DescriptionPopupVC()
        pageObj.contentString = self.fullDescriptionText
        /*if #available(iOS 16.0, *) {
            if let sheet = pageObj.sheetPresentationController {
                let customDetent = UISheetPresentationController.Detent.custom { context in
                    return 390
                }
                sheet.detents = [customDetent]
                sheet.prefersGrabberVisible = true
                sheet.selectedDetentIdentifier = .medium
                present(pageObj, animated: true, completion: nil)
            }
        } else */
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
//        debugPrint("fullDescriptionText -->\(fullDescriptionText)")
//        self.present(pageObj, animated: true)
    }


    func setTextViewPadding(_ textView: UITextView, top: CGFloat = 8, left: CGFloat = 12, bottom: CGFloat = 8, right: CGFloat = 12, removeLinePadding: Bool = true) {
        textView.textContainerInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        if removeLinePadding {
            textView.textContainer.lineFragmentPadding = 0
        }
    }



    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        self.updateTheme(page: "present")
        self.updateStatusbarBackgroundnew(Color: UIColor.clear)
        self.NewCommandcountLbl.text = self.itemDetails?.commentsCount
        self.tableView.reloadData()
        self.checkAdStatusAndLoadBanner()
    }
    func setStatusBarBackgroundColor999(color: UIColor) {
        if #available(iOS 13.0, *) {
            if let statusBarFrame = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame {
                let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.backgroundColor = color
                statusBarView.tag = 999  // optional: so you can remove/reuse it later
                UIApplication.shared.windows.first?.addSubview(statusBarView)
            }
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func okbtnclick(_ sender: Any) {
        
    }
    @IBAction func Backbtnclick(_ sender: Any) {
        if navfrom == "dynamiclink"{
            let Tabbar = TabbarController()
            Tabbar.selectedIndex = 0
            delegate.initVC(initialView: Tabbar)
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
      
    }
    func configUI() {
        MoreViewCorner.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        MoreViewCorner.layer.cornerRadius = 5
        MoreViewCorner.clipsToBounds = true
        self.DesLblew.textColor = UIColor(named: "greencolortxt")
        self.DesLblew.font = UIFont(name: APP_FONT_REGULAR, size: 14)
        self.MoreBtnNew.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, title: "More")
        self.WholeView.isHidden  = true
        indicatorView.startAnimating()
        self.alertmainview.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.AlertView.layer.cornerRadius = 10
        self.youtubeView.isHidden = true
        self.playerView.isHidden = true
        self.playerView.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.NavigationBarWithBackButtonAndTitle(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.rightNavigationBarButtonItem()
        tableView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 40
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        //        self.tableView.sectionfoot
        self.buyNowButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "instantbuy")
        self.buyNowButton.backgroundColor = UIColor(named: "ShadowGreen")
        self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
        self.chatButton.config(color: UIColor(named: "AppThemeColor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "chat")
        self.pageView.cornerViewRadius()
        self.photoLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.youtubeLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "play_video")
        //        self.chatButton.setBorder(color: UIColor(named: "AppThemeColor"))
        
        self.collectionView.register(UINib(nibName: "ItemDetailsImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemDetailsImageCollectionViewCell")
        self.imagelistcv.register(UINib(nibName: "PhotocellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotocellCollectionViewCell")
        self.tableView.register(UINib(nibName: "itemDetailsImageTableViewCell", bundle: nil), forCellReuseIdentifier: "itemDetailsImageTableViewCell")
        self.tableView.register(UINib(nibName: "ItemDetailsMapTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemDetailsMapTableViewCell")
        self.tableView.register(UINib(nibName: "ItemDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemDetailsTableViewCell")
        self.tableView.register(UINib(nibName: "FilterHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterHeaderTableViewCell")
        self.getYoutubeId()
        self.imagelistcv.delegate = self
        self.imagelistcv.dataSource = self
        self.itemconditionlbl.layer.cornerRadius = 5
        self.itemconditionlbl.clipsToBounds = true
        self.Locationbtn.layer.cornerRadius = 5
        self.Locationbtn.clipsToBounds = true
        self.Profileimageview.roundedImage()
        self.itemconditionlbl.config(color: UIColor(named: "greencolortxt"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.center, title: "")
        self.prroducttitlename.config(color: UIColor(named: "greencolortxt"), font: UIFont(name: APP_FONT_BOLD, size: 14), align:.left, text: "")
        self.prroductprice.config(color: UIColor(named: "greencolortxt"), font: UIFont(name: APP_FONT_BOLD, size: 20), align:.left, text: "")
        self.Locationbtn.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.center, title: "")
//                self.DaysCountLbl.config(color: UIColor(named: "greencolorbold"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "")
        self.NewlikecountLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "")
        self.NewCommandcountLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "")
        
        self.NewShareCountLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "share")
        self.NewCallLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "Call")
        self.NewExchangeLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "Exchange")
        
        self.DaysCountLbl.font = UIFont(name: APP_FONT_REGULAR, size: 14)
        self.DaysCountLbl.textColor = UIColor(named: "greencolorbold")
        DispatchQueue.main.async {
            self.loadData()
        }
        self.setBottonButton()
        
    
        
        // load Images
        if (self.itemDetails?.photos.count ?? 0) > 1 {
            self.imagelistcv.isHidden = false
            self.pageView.isHidden = false
            self.photoLabel.text = "1/\(self.itemDetails?.photos.count ?? 0)"
        }
        else {
            self.pageView.isHidden = true
            self.imagelistcv.isHidden = true
        }
        
        if let firstPhoto = self.itemDetails?.photos.first,
           let imageUrl = URL(string: firstPhoto.itemUrlMainOriginal) {
            
            self.itemimagevieew.sd_setImage(with: imageUrl) { (image, error, cache, url) in
                if error != nil {
                    self.itemimagevieew.image = UIImage(named: "applogo") // Default image on error
                }
            }
        }
        
        self.itemImageBtn.setTitle("", for: .normal)
        
        let lat =  itemDetails?.latitude ?? 0
        let lon =  itemDetails?.longitude ?? 0
        
//        DispatchQueue.main.async {
//            let cameras = SnapshotCamera(
//                lookingAtCenter: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)), zoomLevel: 12)
//            let optioned = SnapshotOptions(styleURL: MGLStyle.streetsStyleURL, camera: cameras, size: CGSize(width: self.view.frame.width, height: 255))
//            let snapshots = Snapshot(options: optioned, accessToken: MAPBOXACCESSTOKEN)
//            self.snapshotImage = snapshots.image ?? #imageLiteral(resourceName: "applogo")
//        }
        
        
    }
    

    /*
     
    
    func loadBannerView() {
        self.BannerView.isHidden = true
        if (ADMIN_VIEW_MODEL.adminModel?.result.googleAds ?? "").lowercased() == "enable" {
            // MARK: Banner Ads AddOn
            bannerView1 = GADBannerView(adSize: GADAdSizeBanner)
            bannerView1.translatesAutoresizingMaskIntoConstraints = false
            bannerView1.frame = self.BannerView.frame
            BannerView.addSubview(bannerView1)
            self.BannerView.isHidden = false
            self.BannerView.contentMode = .scaleToFill
            self.bannerView1.contentMode = .scaleToFill
            self.bannerView1.adUnitID = BANNNER_ID
            self.bannerView1.rootViewController = self
            self.bannerView1.load(GADRequest())
            self.bannerView1.delegate = self
        }
    }
     */
    func checkAdStatusAndLoadBanner() {
        if Ad_Status {
            self.loadBannerView()
        }else{
            self.BannerView.isHidden = true
        }
    }
    func loadBannerView() {
            bannerView1 = GADBannerView(adSize: GADAdSizeBanner)
            bannerView1.translatesAutoresizingMaskIntoConstraints = false
        BannerView.addSubview(bannerView1)
            bannerView1.leftAnchor.constraint(equalTo: BannerView.leftAnchor, constant: 0).isActive = true
            bannerView1.rightAnchor.constraint(equalTo: BannerView.rightAnchor, constant: 0).isActive = true
            bannerView1.topAnchor.constraint(equalTo: BannerView.topAnchor, constant: 0).isActive = true
            bannerView1.bottomAnchor.constraint(equalTo: BannerView.bottomAnchor, constant: 0).isActive = true
        self.BannerView.isHidden = false
            self.bannerView1.frame  = self.BannerView.bounds
            self.bannerView1.adUnitID = BANNNER_ID
            self.bannerView1.rootViewController = self
            self.bannerView1.load(GADRequest())
            self.bannerView1.delegate = self
 
    }
    
    func rightNavigationBarButtonItem() {
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" == itemDetails?.sellerId ?? "" {
            button.setImage(#imageLiteral(resourceName: "editBtn"), for: UIControl.State.normal)
            button.tintColor = UIColor(named: "whitecolor")
        }
        else {
            print(self.getLikeData)
            if (itemDetails?.liked ?? "") == "yes"{
                button.setImage(#imageLiteral(resourceName: "like"), for: UIControl.State.normal)
            }
            else{
                button.setImage(#imageLiteral(resourceName: "unlike"), for: UIControl.State.normal)
            }
        }
        button.tag = 0
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.addTarget(self, action: #selector(self.rightBarButtonAct(_:)), for: .touchUpInside)
        
        let button1: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button1.setImage(#imageLiteral(resourceName: "share"), for: UIControl.State.normal)
        button1.tag = 1
        button1.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button1.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button1.addTarget(self, action: #selector(self.rightBarButtonAct(_:)), for: .touchUpInside)
        
        let button2: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button2.setImage(#imageLiteral(resourceName: "option"), for: UIControl.State.normal)
        button2.tintColor = UIColor(named: "whitecolor") ?? .white
        button2.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button2.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button2.tag = 2
        button2.addTarget(self, action: #selector(self.rightBarButtonAct(_:)), for: .touchUpInside)
        let stackview = UIStackView.init(arrangedSubviews: [button,button1, button2])
        stackview.distribution = .equalSpacing
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 15
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackview)
    }
    func getYoutubeId() {
        if (self.itemDetails?.youtubeLink ?? "") != "" {
            do {
                let regex = try NSRegularExpression(pattern: "(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)", options: NSRegularExpression.Options.caseInsensitive)
                let match = regex.firstMatch(in: (self.itemDetails?.youtubeLink ?? ""), options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange(location: 0, length: (self.itemDetails?.youtubeLink ?? "").lengthOfBytes(using: .utf8)))
                let range = match?.range(at: 0)
                let youTubeID = ((self.itemDetails?.youtubeLink ?? "") as NSString).substring(with: range!)
                print(youTubeID)
                if youTubeID != "" {
                    let playerVars = ["origin": "https://youtu.be", "playsinline": "0"]
                    self.youtubeView.isHidden = false
                    self.playerView.load(withVideoId: youTubeID, playerVars: playerVars)
                }
            } catch {
            }
        }
    }
    @objc func rightBarButtonAct(_ sender: UIButton) {
        
        if sender.tag == 0 {
            if UserDefaultModule.shared.getUserData()?.user_id ?? "" == itemDetails?.sellerId ?? "" {
                let pageObj = AddProductViewController()
                pageObj.isEditFlag = true
                pageObj.video_id =  itemDetails?.video_id ?? ""
                let productImage = itemDetails?.photos.map({$0.itemImage}).joined(separator: ",") ?? ""
                let currencyArray = (itemDetails?.currencyCode ?? "").components(separatedBy: "-")
                let product_type = itemDetails?.product_type
                pageObj.stream_thumb =  itemDetails?.stream_thumb ?? ""
                pageObj.isskip = product_type ?? ""
                var formattedCurrency = (itemDetails?.currencyCode ?? "")
                if currencyArray.count > 0 {
                    formattedCurrency = currencyArray.count > 1 ? "\(currencyArray[1])-\(currencyArray[0])" : (itemDetails?.currencyCode ?? "")
                }
                
                let addEditModel = AddEditViewModel(item_id: "\(itemDetails?.id ?? 0)", item_name: itemDetails?.itemTitle ?? "", item_des: (itemDetails?.itemDescription.html2String ?? ""), price: "\(itemDetails?.price ?? "0")", size: itemDetails?.size ?? "", category: "\(itemDetails?.categoryId ?? 0)", subcategory: itemDetails?.subcatId ?? "", chat_to_buy: "0", exchange_to_buy: (itemDetails?.exchangeBuy ?? "0") == "0" ? false : true, currency: "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.currency.filter({$0.symbol == formattedCurrency}).first?.symbol ?? "")", lat: "\(itemDetails?.latitude ?? 0)", lon: "\(itemDetails?.longitude ?? 0)", address: itemDetails?.location ?? "", shipping_time: itemDetails?.shippingTime ?? "", remove_img: "", product_img: productImage, shipping_detail: "", item_condition: "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.filter({$0.name == (itemDetails?.itemCondition ?? "")}).first?.id ?? 0)", make_offer: Int(itemDetails?.makeOffer ?? "0") ?? 0, instant_buy: itemDetails?.instantBuy ?? "0" == "0" ? false : true, paypal_id: "", shipping_cost: itemDetails?.shippingCost ?? "", country_id: (itemDetails?.countryId ?? ""), giving_away: (itemDetails?.price ?? "0") == "0" ? true : false, sold: (itemDetails?.itemStatus ?? "") == "sold" ? true : false, filters: changeFilterDict(), youtube_link: itemDetails?.youtubeLink ?? "", child_category: "\(itemDetails?.childCategoryId ?? "0")")
                ADD_EDIT_ITEM_MODEL = addEditModel
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
            else {
                if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                    if (self.itemDetails?.liked ?? "") == "yes" {
                        sender.setImage(#imageLiteral(resourceName: "unlike"), for: .normal)
                        self.itemDetails?.liked = "no"
                        self.itemDetails?.likesCount = (self.itemDetails?.likesCount ?? 0) > 0 ? ((self.itemDetails?.likesCount ?? 0)-1) : 0
                    }
                    else {
                        self.itemDetails?.liked = "yes"
                        sender.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                        self.itemDetails?.likesCount = ((self.itemDetails?.likesCount ?? 0) + 1)
                    }
                    self.likeDelegate?.likeAct((self.itemDetails?.id ?? 0), isLiked: (self.itemDetails?.liked ?? ""))
                    self.tableView.reloadData()
                    self.viewModel.itemLikedAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetails?.id ?? 0)", onSuccess: { (success) in
                    }) { (failure) in
                    }
                }
                else {
                    self.loadInitialVC()
                }
            }
        }
        else if sender.tag == 1 {
            let text = (self.itemDetails?.productUrl ?? "")
            let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
            if vc.popoverPresentationController != nil{
                popoverPresentationController?.sourceView = self.view
                popoverPresentationController?.sourceRect = self.view.bounds
            }
            self.present(vc, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (itemDetails?.sellerId ?? "") {
                var soldValue = 0
                if (itemDetails?.itemStatus ?? "") == "onsale" {
                    soldTitle = getLanguage["mark_as_sold"] ?? ""
                    soldValue = 1
                }
                else {
                    soldTitle = getLanguage["back_to_sale"] ?? ""
                    soldValue = 0
                }
                alert.addAction(UIAlertAction(title: soldTitle, style: .default, handler: { (UIAlertAction) in
                    if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                        self.soldItemAct("\(self.itemDetails?.id ?? 0)", value: "\(soldValue)")
                    }
                    else {
                        self.loadInitialVC()
                    }
                }))
                alert.addAction(UIAlertAction(title: (getLanguage["delete_product"] ?? ""), style: .default, handler: { (UIAlertAction) in
                    if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                        self.deleteProductAct()
                    }
                    else {
                        self.loadInitialVC()
                    }
                }))
            }
            else {
                if (self.itemDetails?.makeOffer ?? "") == "0" {
                    alert.addAction(UIAlertAction(title: getLanguage["make_an_offer"], style: .default, handler: { (UIAlertAction) in
                        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                            print(success)
                            if success {
                                if let profileData = self.viewModels.profileModel?.result {
                                    self.profileData = profileData
//                                    if self.profileData?.verification.mobNo == false{
//                                        self.showAlerts()
//                                    }else{
                                    let canProceed = (self.profileData?.can_access == true) ||
                                                     (self.profileData?.verification.mobNo == true)

                                    if !canProceed {
                                        self.showAlerts()
                                        return
                                    }
                                        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != ""{
                                            let pageObj = ExchangeOfferViewController()
                                            pageObj.itemDetails = self.itemDetails
                                            pageObj.modalPresentationStyle = .overCurrentContext
                                            pageObj.modalTransitionStyle = .crossDissolve
                                            self.navigationController?.present(pageObj, animated: true, completion: nil)
                                        }
                                        else {
                                            self.loadInitialVC()
                                        }
                                  //  }
                                }
                            }
                        }) { (failure) in
                        }
                    }))
                }
                if (self.itemDetails?.exchangeBuy ?? "") == "1" && EXCHANGE_MODEL_FLAG {
                    alert.addAction(UIAlertAction(title: getLanguage["create_exchange"], style: .default, handler: { (UIAlertAction) in
                        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                            print(success)
                            if success {
                                if let profileData = self.viewModels.profileModel?.result {
                                    self.profileData = profileData
//                                    if self.profileData?.verification.mobNo == false{
//                                        self.showAlerts()
//                                    }else{
                                    let canProceed = (self.profileData?.can_access == true) ||
                                                     (self.profileData?.verification.mobNo == true)

                                    if !canProceed {
                                        self.showAlerts()
                                        return
                                    }
                                        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                                            self.exchangeAct()
                                        }
                                        else {
                                            self.loadInitialVC()
                                        }
                                  //  }
                                }
                            }
                        }) { (failure) in
                        }
                    }))
                }
                var reportTitle = ""
                var reportVal = 0
                if itemDetails?.report ?? "" == "yes" {
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
                        self.reportAct(reportVal)   //oldcode
                        //new addon
                        //                        if self.itemDetails?.report ?? "" == "no"{
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
    
    
    func loadInitialVC() {
        let vc = InitialViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.isFromList = true
        self.present(vc, animated: true, completion: nil)
    }
    func changeFilterDict() -> String {
        if let filterArr = self.itemDetails?.filters {
            var filterRangeArray = [FilterRangeModel]()
            var filterDropDownArray = [FilterSubModel]()
            var filterMultiLevelArray = [FilterSubModel]()
            
            let filterArray = Utility.shared.getFilterFromCategory(category: "\(self.itemDetails?.categoryId ?? 0)", subCategory: "\(self.itemDetails?.subcatId ?? "0")", childCategory: "\(self.itemDetails?.childCategoryId ?? "0")")
            //1616610600
            for filter in filterArr {
                for prodFilter in filterArray {
                    if prodFilter.type == filter.type {
                        if prodFilter.type == "dropdown" {
                            filterDropDownArray.append(FilterSubModel(catType: prodFilter.categoryType, id: filter.childId))
                        }
                        else if filter.type == "multilevel" {
                            filterMultiLevelArray.append(FilterSubModel(catType: prodFilter.categoryType, id: filter.childId))
                        }
                        else {
                            let range = FilterRangeModel(max_value: filter.value, id: filter.parentId, min_value: filter.value)
                            filterRangeArray.append(range)
                        }
                    }
                }
            }
            
            let updateArray = UpdateFilterModel(range: filterRangeArray, dropdown: filterDropDownArray, multilevel: filterMultiLevelArray)
            return Utility.shared.filterDictToString(updateArray)
        }
        return ""
    }
    
    func exchangeAct() {
        if self.itemDetails?.itemStatus ?? "" == "sold" {
            let alert = UIAlertController(title: nil, message: getLanguage["Product already sold out"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
            self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                print(success)
                if success {
                    if let profileData = self.viewModels.profileModel?.result {
                        self.profileData = profileData
//                        if self.profileData?.verification.mobNo == false{
//                            self.showAlerts()
//                        }else{
                        let canProceed = (self.profileData?.can_access == true) ||
                                         (self.profileData?.verification.mobNo == true)

                        if !canProceed {
                            self.showAlerts()
                            return
                        }
                            let pageObj = ExchangeViewController()
                            pageObj.itemDetails = self.itemDetails
                            self.navigationController?.pushViewController(pageObj, animated: true)
                       // }
                        
                    }
                }
            }) { (failure) in
            }
        }
    }
    func reportAct(_ reportVal: Int) {
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
            self.viewModel.reportItemAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetails?.id ?? 0)", onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                var reportMessage = (self.viewModel.alertModel?.message ?? "")
                
                if success {
                    if self.itemDetails?.report ?? "" == "yes" {
                        self.itemDetails?.report = "no"
                    }
                    else {
                        self.itemDetails?.report = "yes"
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
    func showAlertsmake() {
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
    

    func deleteProductAct() {
        let alert = UIAlertController(title: getLanguage["alert"], message: getLanguage["Do you want to surely delete this product?"], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .default, handler: { (UIAlertAction) in
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.deleteProductAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetails?.id ?? 0)", onSuccess: { (success) in
                self.navigationController?.popViewController(animated: true)
                Utility.shared.stopAnimation(viewController: self)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }))
        alert.addAction(UIAlertAction(title: getLanguage["cancel"], style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func soldItemAct(_ itemID: String, value: String) {
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
        let soldTitle = (itemDetails?.itemStatus ?? "") == "onsale" ? getLanguage["mark_as_sold"] ?? "" : getLanguage["back_to_sale"] ?? ""
        
        let alert = UIAlertController(title: nil, message: soldTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: { (UIAlertAction) in
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
        }))
        self.present(alert, animated: true, completion: nil)
        //   }
    }
    func loadData() {
        let group = DispatchGroup()
        group.enter()
        self.viewModel.getUserProductsData(category_id: "\(self.itemDetails?.categoryId ?? 0)", subcategory_id: "\(self.itemDetails?.subcatId ?? "0")", user_id: self.itemDetails?.sellerId ?? "", product_id: "\(self.itemDetails?.id ?? 0)", onSuccess: { (success) in
           
            group.leave()
        }) { (failure) in
            group.leave()
        }
        group.enter()
        self.viewModel.getItems(type: "moreitems", price: "", search_key: "", category_id: "", subcategory_id: "", user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetails?.id ?? 0)", seller_id: (self.itemDetails?.sellerId ?? ""), sorting_id: "1", offset: "0", limit: "50", posted_within: "", distance: "", distance_type: "", lang_type: DEFAULT_LANGUAGE_CODE, filters: "", product_condition: "", child_category_id: "", lon: "", lat: "", onSuccess: { (success) in
            group.leave()
        }) { (failure) in
            group.leave()
        }
        group.enter()
        indicatorView.stopAnimating()
        self.WholeView.isHidden  = false
        let chatViewModel = ChatViewModel()
        if UserDefaultModule.shared.getUserData()?.user_id != nil{
            chatViewModel.searchItemData(item_id: "\(self.itemDetails?.id ?? 0)", user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), onSuccess: { (success) in
                if success {
                    //solai
                  
                    if let itemModel = chatViewModel.itemModel?.result.items.first {
                        let productURL = self.itemDetails?.productUrl ?? ""
                        let totalPrice = self.itemDetails?.formattedTotalPrice ?? "0"
                        self.itemDetails = itemModel
                        print("asdfsdgjh",itemModel.publisher_id ?? "")
                        self.itemDetails?.productUrl = productURL
                        self.itemDetails?.formattedTotalPrice = totalPrice
                        self.itemconditionlbl.setTitle(self.itemDetails?.itemCondition, for: .normal)
                        self.Locationbtn.setTitle(self.itemDetails?.location, for: .normal)
                        self.prroducttitlename.text  = self.itemDetails?.itemTitle
                        if self.itemDetails?.totalPrice == 0 {
                            self.prroductprice.textColor  = UIColor(named: "AppThemeColorNew")
                            self.prroductprice.text = "Giving away"
                        }else{
                            self.prroductprice.text = self.itemDetails?.formattedPrice
                        }
                        
                        
                        self.DesTv.font =  UIFont(name: APP_FONT_REGULAR, size: 14)
                        self.fullDescriptionText = self.itemDetails?.itemDescription ?? ""
                        self.DesLblew.text = self.itemDetails?.itemDescription ?? ""
                        self.DesTv.text = self.fullDescriptionText
                        
                        print("fullDescriptionTextcount",self.fullDescriptionText.count)
//                         DispatchQueue.main.async {
                            if self.fullDescriptionText.count > 15 {
                                // Show "More" button when text length > 15
                                print("fullDescriptionTextcount3")
                                self.MoreBtnNewview.isHidden = false
                            } else {
                                print("fullDescriptionTextcount4")
                                // Hide "More" button when text length ≤ 15
                                self.MoreBtnNewview.isHidden = true
                            }
//                        }
                        
                        print("Mspandi",self.fullDescriptionText)
//                        self.setDescriptionText()
                        
                        let dateString = Utility.shared.timeStampWithDateFormat(timeStamp: "\(self.itemDetails?.postedTime ?? 0)", dateFormat: "EEE, dd MMM yy HH:mm:ss VVVV")
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "EEE, dd MMM yy HH:mm:ss VVVV"
                        let date = dateFormatterGet.date(from: dateString)
                        if let dateVal = date {
                            self.DaysCountLbl.text = Date().offset(from: dateVal)
                        }
                        
                        if let imageUrl = URL(string:  self.itemDetails?.sellerImg ?? "") {
                            self.Profileimageview.sd_setImage(with: imageUrl) { (image, error, cache, url) in
                                if error != nil {
                                    self.Profileimageview.image = UIImage(named: "applogo") // Default image on error
                                }
                            }
                        }
                        self.Profileimageview.isUserInteractionEnabled = true
                        self.Profileimageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewUserAct(_:))))
                        if (self.itemDetails?.liked ?? "") == "yes"{
                            self.Newlikebtn.setImage(#imageLiteral(resourceName: "newhfillimg"), for: UIControl.State.normal)
                        }
                        else{
                            self.Newlikebtn.setImage(#imageLiteral(resourceName: "newhimg"), for: UIControl.State.normal)
                        }
                        self.NewlikecountLbl.text = "\(self.itemDetails?.likesCount  ?? 0)"
                        if self.itemDetails?.commentsCount ?? "0" == "" || self.itemDetails?.commentsCount ?? "0" == nil {
                            self.NewCommandcountLbl.text =  "0"
                        }else{
                            self.NewCommandcountLbl.text =  self.itemDetails?.commentsCount ?? "0"
                        }
                        
                        
                        
                        if self.itemDetails?.follow_status  == "true" || ((UserDefaultModule.shared.getUserData()?.user_id ?? "") == (self.itemDetails?.sellerId ?? "")) {
                            self.PlusImgView.isHidden = true
                        }else{
                            self.PlusImgView.isHidden = false
                        }
                        
                        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (self.itemDetails?.sellerId ?? "") {
                            self.ExchangeStack.isHidden = true
                        }else{
                            if (self.itemDetails?.exchangeBuy ?? "") == "1" && EXCHANGE_MODEL_FLAG {
                                self.ExchangeStack.isHidden = false
                            }else{
                                self.ExchangeStack.isHidden = true
                            }
                        }
                        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (self.itemDetails?.sellerId ?? "") {
                            self.CallStackView.isHidden = true
                        }else{
                            if self.itemDetails?.mobileVerification ?? false && self.itemDetails?.showSellerMobile ?? false {
                                self.CallStackView.isHidden = false
                            }
                            else {
                                self.CallStackView.isHidden = true
                            }
                        }
                    }
                }
                group.leave()
            }) { (failure) in
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
            self.collectionView.reloadData()
            DispatchQueue.main.async {
                self.viewModel.updateViewCount(item_id: "\(self.itemDetails?.id ?? 0)", user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""))
            }
        }
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "action://toggle" {
            isDescriptionExpanded.toggle()
            setDescriptionText()
            return false
        }
        return true
    }

    
    func setBottonButton() {
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (self.itemDetails?.sellerId ?? "") {
            /*
            if (itemDetails?.itemStatus ?? "") == "onsale" {
                if (self.itemDetails?.promotionType ?? "") != "Normal" {
                    self.buyNowButton.setTitle(getLanguage["Promotion Details"] ?? "", for: .normal)
                }
                else {
                    if (ADMIN_VIEW_MODEL.adminModel?.result.promotion ?? "") == "enable"{
                        self.buyNowButton.setTitle(getLanguage["promote_your_product"] ?? "", for: .normal)
                    }else{
                        self.buyNowButton.isHidden = true
                        self.chatButton.layer.cornerRadius = 4
                        self.chatButton.clipsToBounds = true
                    }
                }
            }
            else {
                if (itemDetails?.itemStatus ?? "") == "sold" {
                    self.buyNowButton.setTitle(getLanguage["back_to_sale"] ?? "", for: .normal)
                }
            }
            self.chatButton.setTitle(getLanguage["insights"] ?? "", for: .normal)
            self.chatButton.specificCornerRadiusright(radius: 4)
            self.buyNowButton.specificCornerRadiusleft(radius: 4)
            self.chatButton.setTitleColor(UIColor(named: "BlackColorNew"), for: .normal)
            self.chatButton.backgroundColor = UIColor(named: "ShadowWhite")
            
             */
            var isBuyNowVisible = false
            var isItemSold = false

                if (itemDetails?.itemStatus ?? "") == "onsale" {
                if (itemDetails?.promotionType ?? "") != "Normal" {
                    self.buyNowButton.setTitle(getLanguage["Promotion Details"] ?? "", for: .normal)
                    isBuyNowVisible = true
                } else {
                    if (ADMIN_VIEW_MODEL.adminModel?.result.promotion ?? "") == "enable" {
                        self.buyNowButton.setTitle(getLanguage["promote_your_product"] ?? "", for: .normal)
                        isBuyNowVisible = true

                        // Promote button: right-side rounded corners
                        self.buyNowButton.layer.cornerRadius = 5
                        self.buyNowButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                        self.buyNowButton.clipsToBounds = true
                    } else {
                        isBuyNowVisible = false
                        self.buyNowButton.isHidden = true
                    }
                }
            } else if (itemDetails?.itemStatus ?? "") == "sold" {
                self.buyNowButton.setTitle(getLanguage["back_to_sale"] ?? "", for: .normal)
                isBuyNowVisible = true
                isItemSold = true
            }

            // Final button visibility
            self.buyNowButton.isHidden = !isBuyNowVisible

            // Set up chatButton (Insights)
            self.chatButton.setTitle(getLanguage["insights"] ?? "", for: .normal)
            self.chatButton.setTitleColor(UIColor(named: "BlackColorNew"), for: .normal)
            self.chatButton.backgroundColor = UIColor(named: "ShadowWhite")

            if isItemSold {
                // Right corners only for sold state
                self.buyNowButton.layer.cornerRadius = 5
                self.buyNowButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                // Left corners only for sold state
                self.chatButton.layer.cornerRadius = 5
                self.chatButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else if isBuyNowVisible {
                // Left corners only when buyNowButton is visible
                self.chatButton.layer.cornerRadius = 5
                self.chatButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else {
                // All corners when only chatButton is shown
                self.chatButton.layer.cornerRadius = 5
                self.chatButton.layer.maskedCorners = [
                    .layerMinXMinYCorner,
                    .layerMinXMaxYCorner,
                    .layerMaxXMinYCorner,
                    .layerMaxXMaxYCorner
                ]
            }

            self.chatButton.clipsToBounds = true
            
            
        }
        else{
            if BUYNOW_MODEL_FLAG {
                if (self.itemDetails?.instantBuy ?? "") == "1" && (self.itemDetails?.itemStatus ?? "") == "onsale" {
                    self.chatButton.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
                    self.chatButton.setTitleColor(UIColor(named: "BlackColorNew"), for: .normal)
                    
                    self.buyNowButton.isHidden = false
                    self.chatButton.layer.cornerRadius = 4
                    self.chatButton.clipsToBounds = true
                    
                    
                    self.chatButton.layer.cornerRadius = 5
                    self.chatButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] // topLeft, bottomLeft
                    self.chatButton.clipsToBounds = true
                    
                    // Corner radius: right side only
                    self.buyNowButton.layer.cornerRadius = 5
                    self.buyNowButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // topRight, bottomRight
                    self.buyNowButton.clipsToBounds = true

                    
                    
                }
                else {
                    self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
                    self.chatButton.setTitleColor(UIColor(named: "whitecolor"), for: .normal)
                    self.buyNowButton.isHidden = true
                    self.chatButton.layer.cornerRadius = 4
                    self.chatButton.clipsToBounds = true
                }
            }
            else {
                self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
                self.chatButton.setTitleColor(UIColor(named: "whitecolor"), for: .normal)
                self.buyNowButton.isHidden = true
                self.chatButton.layer.cornerRadius = 4
                self.chatButton.clipsToBounds = true
            }
        }
        
    }
    
    @IBAction func youtubeButtonAct(_ sender: UIButton) {
        if sender.tag == 0 {
            self.playerView.isHidden = false
            self.playerView.playVideo()
        }
    }
    
    @IBAction func NewlikebtnTapped(_ sender: Any) {
        print("wderth",self.itemDetails?.publisher_id)
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
            if self.itemDetails?.sellerId ?? "" != UserDefaultModule.shared.getUserData()?.user_id ?? ""{
                
                if (self.itemDetails?.liked ?? "") == "yes" {
                    Newlikebtn.setImage(#imageLiteral(resourceName: "newhimg"), for: .normal)
                    self.itemDetails?.liked = "no"
                    self.itemDetails?.likesCount = (self.itemDetails?.likesCount ?? 0) > 0 ? ((self.itemDetails?.likesCount ?? 0)-1) : 0
                    self.NewlikecountLbl.text = "\(self.itemDetails?.likesCount  ?? 0)"
                }
                else {
                    self.itemDetails?.liked = "yes"
                    Newlikebtn.setImage(#imageLiteral(resourceName: "newhfillimg"), for: .normal)
                    self.itemDetails?.likesCount = ((self.itemDetails?.likesCount ?? 0) + 1)
                    self.NewlikecountLbl.text = "\(self.itemDetails?.likesCount ?? 0)"
                }
                self.likeDelegate?.likeAct((self.itemDetails?.id ?? 0), isLiked: (self.itemDetails?.liked ?? ""))
                self.tableView.reloadData()
                self.viewModel.itemLikedAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetails?.id ?? 0)", onSuccess: { (success) in
                    
                }) { (failure) in
                }

                
            }
        }
        else {
            self.loadInitialVC()
        }
    }
    
    
    
    
    @IBAction func NewExchangeTapped(_ sender: Any) {
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
            self.exchangeAct()
        }
        else {
            self.loadInitialVC()
        }
    }
    
    @IBAction func Newsharebtntapped(_ sender: Any) {
        let text = (self.itemDetails?.productUrl ?? "")
        
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
        if vc.popoverPresentationController != nil{
            popoverPresentationController?.sourceView = self.view
            popoverPresentationController?.sourceRect = self.view.bounds
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func NewCommandTapped(_ sender: Any) {
        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            if success {
                if let profileData = self.viewModels.profileModel?.result {
                    self.profileData = profileData
//                    if self.profileData?.verification.mobNo == false{
//                        self.showAlerts()
//                    }else{
                    let canProceed = (self.profileData?.can_access == true) ||
                                     (self.profileData?.verification.mobNo == true)

                    if !canProceed {
                        self.showAlerts()
                        return
                    }
                        let pageObj = CommentViewController()
                        pageObj.itemVC = self
                        pageObj.itemModel = self.itemDetails
                        self.navigationController?.pushViewController(pageObj, animated: true)
                   // }
                    
                }
            }
        }) { (failure) in
        }
    }
    
    
    @IBAction func NewCallTapped(_ sender: Any) {
        if (itemDetails?.mobileNo ?? "") != "" && (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
            if let callUrl = URL(string: "telprompt://+\(itemDetails?.mobileNo ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), UIApplication.shared.canOpenURL(callUrl) {
                UIApplication.shared.open(callUrl, options: [:], completionHandler: nil)
            }
            else {
            }
        }
        else{
            self.loadInitialVC()
        }
    }
    @IBAction func NewMoreTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (itemDetails?.sellerId ?? "") {
            // Add Edit option first
            alert.addAction(UIAlertAction(title: getLanguage["edit_product"] ?? "Edit", style: .default, handler: { _ in
                if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                    self.editProductAct() // Call your edit action method
                } else {
                    self.loadInitialVC()
                }
            }))
            
            var soldValue = 0
            var soldTitle = ""
            
            if (itemDetails?.itemStatus ?? "") == "onsale" {
                soldTitle = getLanguage["mark_as_sold"] ?? ""
                soldValue = 1
            } else {
                soldTitle = getLanguage["back_to_sale"] ?? ""
                soldValue = 0
            }
            
            alert.addAction(UIAlertAction(title: soldTitle, style: .default, handler: { _ in
                if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                    self.soldItemAct("\(self.itemDetails?.id ?? 0)", value: "\(soldValue)")
                } else {
                    self.loadInitialVC()
                }
            }))
            
            alert.addAction(UIAlertAction(title: getLanguage["delete_product"] ?? "", style: .default, handler: { _ in
                if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                    self.deleteProductAct()
                } else {
                    self.loadInitialVC()
                }
            }))
        }
        
        else {
            if (self.itemDetails?.makeOffer ?? "") == "0" {
                alert.addAction(UIAlertAction(title: getLanguage["make_an_offer"], style: .default, handler: { (UIAlertAction) in
                    self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                        print(success)
                        if success {
                            if let profileData = self.viewModels.profileModel?.result {
                                self.profileData = profileData
//                                if self.profileData?.verification.mobNo == false{
//                                    self.showAlerts()
//                                }else{
                                let canProceed = (self.profileData?.can_access == true) ||
                                                 (self.profileData?.verification.mobNo == true)

                                if !canProceed {
                                    self.showAlerts()
                                    return
                                }
                                    if UserDefaultModule.shared.getUserData()?.user_id ?? "" != ""{
                                        let pageObj = ExchangeOfferViewController()
                                        pageObj.itemDetails = self.itemDetails
                                        pageObj.modalPresentationStyle = .overCurrentContext
                                        pageObj.modalTransitionStyle = .crossDissolve
                                        self.navigationController?.present(pageObj, animated: true, completion: nil)
                                    }
                                    else {
                                        self.loadInitialVC()
                                    }
                              //  }
                            }
                        }
                    }) { (failure) in
                    }
                }))
            }
            if (self.itemDetails?.exchangeBuy ?? "") == "1" && EXCHANGE_MODEL_FLAG {
                alert.addAction(UIAlertAction(title: getLanguage["create_exchange"], style: .default, handler: { (UIAlertAction) in
                    if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                        self.exchangeAct()
                    }
                    else {
                        self.loadInitialVC()
                    }
                }))
            }
            var reportTitle = ""
            var reportVal = 0
            if itemDetails?.report ?? "" == "yes" {
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
                    self.reportAct(reportVal)   //oldcode
                    //new addon
                    //                        if self.itemDetails?.report ?? "" == "no"{
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
    
    func editProductAct(){
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" == itemDetails?.sellerId ?? "" {
            let product_type = itemDetails?.product_type
            let pageObj = AddProductViewController()
            pageObj.isEditFlag = true
            pageObj.stream_thumb =  itemDetails?.stream_thumb ?? ""
            pageObj.video_id =  itemDetails?.video_id ?? ""
            pageObj.isskip = product_type ?? ""
            let productImage = itemDetails?.photos.map({$0.itemImage}).joined(separator: ",") ?? ""
            let currencyArray = (itemDetails?.currencyCode ?? "").components(separatedBy: "-")
            var formattedCurrency = (itemDetails?.currencyCode ?? "")
            if currencyArray.count > 0 {
                formattedCurrency = currencyArray.count > 1 ? "\(currencyArray[1])-\(currencyArray[0])" : (itemDetails?.currencyCode ?? "")
            }
            
            let addEditModel = AddEditViewModel(item_id: "\(itemDetails?.id ?? 0)", item_name: itemDetails?.itemTitle ?? "", item_des: (itemDetails?.itemDescription.html2String ?? ""), price: "\(itemDetails?.price ?? "0")", size: itemDetails?.size ?? "", category: "\(itemDetails?.categoryId ?? 0)", subcategory: itemDetails?.subcatId ?? "", chat_to_buy: "0", exchange_to_buy: (itemDetails?.exchangeBuy ?? "0") == "0" ? false : true, currency: "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.currency.filter({$0.symbol == formattedCurrency}).first?.symbol ?? "")", lat: "\(itemDetails?.latitude ?? 0)", lon: "\(itemDetails?.longitude ?? 0)", address: itemDetails?.location ?? "", shipping_time: itemDetails?.shippingTime ?? "", remove_img: "", product_img: productImage, shipping_detail: "", item_condition: "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.filter({$0.name == (itemDetails?.itemCondition ?? "")}).first?.id ?? 0)", make_offer: Int(itemDetails?.makeOffer ?? "0") ?? 0, instant_buy: itemDetails?.instantBuy ?? "0" == "0" ? false : true, paypal_id: "", shipping_cost: itemDetails?.shippingCost ?? "", country_id: (itemDetails?.countryId ?? ""), giving_away: (itemDetails?.price ?? "0") == "0" ? true : false, sold: (itemDetails?.itemStatus ?? "") == "sold" ? true : false, filters: changeFilterDict(), youtube_link: itemDetails?.youtubeLink ?? "", child_category: "\(itemDetails?.childCategoryId ?? "0")")
            ADD_EDIT_ITEM_MODEL = addEditModel
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
    }
    
    
    
    @IBAction func buyNowButtonAct(_ sender: UIButton) {
        
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (self.itemDetails?.sellerId ?? "") {
            if (itemDetails?.itemStatus ?? "") == "sold" {
                self.soldItemAct("\(self.itemDetails?.id ?? 0)", value: "0")
            }
            else {
                if (self.itemDetails?.promotionType ?? "") == "Normal" {
                    let pageObj = CreatePromotionViewController()
                    pageObj.itemID = "\(self.itemDetails?.id ?? 0)"
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
                else {
                    let pageObj = MyPromotionDetailViewController()
                    pageObj.isFromItemDetails = true
                    pageObj.itemDetails = self.itemDetails
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
            }
        }
        else {
             if sender.tag == 0 {
             if (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
             if BUYNOW_MODEL_FLAG && (self.itemDetails?.itemApprove ?? "") == "1" {
                 self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
                     Utility.shared.startAnimation(viewController: self)
                     print(success)
                     if success {
                         Utility.shared.stopAnimation(viewController: self)
                         if let profileData = self.viewModels.profileModel?.result {
                             self.profileData = profileData
//                             if self.profileData?.verification.mobNo == false{
//                                 self.showAlerts()
//                             }else{
                             let canProceed = (self.profileData?.can_access == true) ||
                                              (self.profileData?.verification.mobNo == true)
                             if !canProceed {
                                 self.showAlerts()
                                 return
                             }
                                 Utility.shared.stopAnimation(viewController: self)
                                 let addressModel = AddressViewModel()
                                 addressModel.getShippingAddressAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetails?.id ?? 0)", onSuccess: { (success) in
                                 Utility.shared.stopAnimation(viewController: self)
                                 if !success {
                                 let pageObj = AddressViewController()
                                 pageObj.itemDetails = self.itemDetails
                                 pageObj.viewType = 1
                                 self.navigationController?.pushViewController(pageObj, animated: true)
                                 }
                                 else {
                                 if addressModel.addressListModel?.result.count ?? 0 == 1 {
                                 let pageObj = BuyNowViewController()
                                 pageObj.addressDetails = addressModel.addressListModel?.result.first
                                 pageObj.itemDetails = self.itemDetails
                                 self.navigationController?.pushViewController(pageObj, animated: true)
                                 }
                                 else {
                                 let pageObj = AddressListViewController()
                                 pageObj.itemDetails = self.itemDetails
                                 pageObj.isFromItemDetails = true
                                 self.navigationController?.pushViewController(pageObj, animated: true)
                                 }
                                 }
                                 }) { (failure) in
                                 Utility.shared.stopAnimation(viewController: self)
                                 }
                            // }
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
             else {
             
             }
        }
    }
    
    @IBAction func chatButtonAct(_ sender: UIButton) {
        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            if success {
                if let profileData = self.viewModels.profileModel?.result {
                    self.profileData = profileData
//                    if self.profileData?.verification.mobNo == false{
//                        self.showAlerts()
//                    }else{
                    let canProceed = (self.profileData?.can_access == true) ||
                                     (self.profileData?.verification.mobNo == true)

                    if !canProceed {
                        self.showAlerts()
                        return
                    }
                        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
                            if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (self.itemDetails?.sellerId ?? "") {
                                let pageObj = InsightViewController()
                                pageObj.itemData = self.itemDetails
                                self.navigationController?.pushViewController(pageObj, animated: true)
                            }
                            else {
                                self.view.endEditing(true)
                                Utility.shared.startAnimation(viewController: self)
                                self.viewModel.getChatIdAct(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: (self.itemDetails?.sellerId ?? ""), onSuccess: { (success) in
                                    Utility.shared.stopAnimation(viewController: self)
                                    
                                    if success {
                                        let pageObj = ChatViewController()
                                        pageObj.receiverId = self.itemDetails?.sellerId ?? ""
                                        pageObj.isFromItemDetails = true
                                        pageObj.chatId = (self.viewModel.itemChatModel?.chatId ?? "")
                                        pageObj.itemDetails = self.itemDetails
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
                        
                 //   }
                    
                }
            }
        }) { (failure) in
        }
        
    }
}
extension ItemDetailsViewController: UITableViewDelegate, UITableViewDataSource, itemDetailsImageDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return (self.itemDetails?.filters.count ?? 0)
        }
        else if section == 5 && (self.viewModel.relatedProductModel?.result == nil) {
            return 0
        }
        else if section == 6 && (self.viewModel.getItemModel?.result == nil)
        {
            return 0
        }
        
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || (section == 1 && (self.itemDetails?.filters.count ?? 0)>0) || (section == 6 && (self.viewModel.getItemModel?.result != nil)) || (section == 5 && (self.viewModel.relatedProductModel?.result != nil)) {
            return UITableView.automaticDimension
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 3 {
            
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            self.bannerView1.frame = footerView.bounds
            footerView.addSubview(self.bannerView1)
            return footerView
            
        }
        else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 5 || indexPath.section == 6 {
            return 255
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterHeaderTableViewCell") as! FilterHeaderTableViewCell
        cell.viewTopConst.constant = 0
        cell.viewBottomConst.constant = 0
        cell.headerLabel.font = UIFont(name: APP_FONT_BOLD, size: 16)
        if section == 1 {
            cell.viewType = 1
            cell.overAllView.backgroundColor = UIColor(named: "whitecolor")
            cell.headerLabel.text = (getLanguage["details"] ?? "").capitalized
        }
        else if section == 2 {
            cell.viewType = 1
            cell.overAllView.backgroundColor = UIColor(named: "whitecolor")
            cell.headerLabel.text = (getLanguage["description"] ?? "").capitalized
        }
        else if (section == 5 && (self.viewModel.relatedProductModel?.result != nil)) {
            cell.overAllView.backgroundColor = UIColor(named: "clearcolor")
            cell.viewType = 0
            cell.headerLabel.text = "\(getLanguage["more_items_from"] ?? "") \(self.itemDetails?.sellerUsername ?? "")"
            cell.viewTopConst.constant = 10
        }
        else if (section == 6 && (self.viewModel.getItemModel?.result != nil)) {
            cell.viewTopConst.constant = 0
            cell.overAllView.backgroundColor = UIColor(named: "clearcolor")
            cell.viewType = 0
            cell.headerLabel.text = (getLanguage["related_products"] ?? "").capitalized
        }
        //        cell.viewBottomConst.constant = 10
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemDetailsMapTableViewCell") as! ItemDetailsMapTableViewCell
            if let itemDetails = self.itemDetails{
                cell.loadData(itemDetails)
                if itemDetails.mobileVerification && itemDetails.showSellerMobile {
                    cell.callButton.isHidden = false
                }
                else {
                    cell.callButton.isHidden = true
                }
                
                DispatchQueue.main.async {
                    cell.mapImageView.image = self.snapshotImage
                }
                
            }
            
            cell.callButton.addTarget(self, action: #selector(self.callButtonAct(_:)), for: .touchUpInside)
            cell.mapImageView.isUserInteractionEnabled = true
            cell.mapImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.directionGestureAct)))
            cell.userImageView.isUserInteractionEnabled = true
            cell.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewUserAct(_:))))
            return cell
        }
        else if indexPath.section == 5 || indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemDetailsImageTableViewCell") as! itemDetailsImageTableViewCell
            cell.delegate = self
            if indexPath.section == 5 && self.viewModel.relatedProductModel?.result != nil {
                cell.loadData(self.viewModel.relatedProductModel?.result.items ?? [ItemModel]())
            }
            else if indexPath.section == 6 && self.viewModel.getItemModel?.result != nil{
                cell.loadData(self.viewModel.getItemModel?.result.items ?? [ItemModel]())
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemDetailsTableViewCell") as! ItemDetailsTableViewCell
            if let itemDetails = self.itemDetails{
                cell.loadData(index: indexPath, item: itemDetails)
            }
            if soldTitle == getLanguage["back_to_sale"] ?? ""{
                cell.adButton.isHidden = true
            }
            cell.facebookButton.tag = 0
            cell.twitterButton.tag = 1
            cell.whatsappButton.tag = 2
            cell.moreButton.tag = 3
            cell.commentButton.addTarget(self, action: #selector(self.commentButtonAct), for: .touchUpInside)
            cell.facebookButton.addTarget(self, action: #selector(self.shareAct(_:)), for: .touchUpInside)
            cell.twitterButton.addTarget(self, action: #selector(self.shareAct(_:)), for: .touchUpInside)
            cell.whatsappButton.addTarget(self, action: #selector(self.shareAct(_:)), for: .touchUpInside)
            cell.moreButton.addTarget(self, action: #selector(self.shareAct(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    @objc func directionGestureAct()  {
        /*if let url = URL(string: "http://maps.google.com/?saddr=\(self.delegate.currentLocation?.location?.coordinate.latitude ?? 0),\(self.delegate.currentLocation?.location?.coordinate.longitude ?? 0)&daddr=\(itemDetails?.latitude ?? 0),\(itemDetails?.longitude ?? 0)&directionsmode=driving"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }*/
        let pageObj = MapViewController()
//        pageObj.delegate = self
        pageObj.viewType = "visit"
        pageObj.lat = "\(itemDetails?.latitude ?? 0)"
        pageObj.long = "\(itemDetails?.longitude ?? 0)"
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
    
    @IBAction func imageAct(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var mediaItems: [MediaType] = []
            if let photos = self.itemDetails?.photos {
                for photo in photos {
                    if photo.mediaType == "video",
                       let videoUrlStr = photo.itemUrlMainOriginal,
                       let videoUrl = URL(string: videoUrlStr) {
                        mediaItems.append(.video(videoUrl))
                    } else if let imageUrlStr = photo.itemUrlMainOriginal,
                              let imageUrl = URL(string: imageUrlStr) {
                        mediaItems.append(.image(imageUrl))
                    } else if let fallbackImageUrlStr = photo.itemUrlMain350,
                              let fallbackImageUrl = URL(string: fallbackImageUrlStr) {
                        mediaItems.append(.image(fallbackImageUrl))
                    }
                }
            }
            
            let vc = ImageAndVideoVC()
            vc.items = mediaItems
            vc.startIndex = self.selectedindex
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    @objc func callButtonAct(_ sender: UIButton) {
        if (itemDetails?.mobileNo ?? "") != "" && (UserDefaultModule.shared.getUserData()?.user_id ?? "") != "" {
            if let callUrl = URL(string: "telprompt://+\(itemDetails?.mobileNo ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), UIApplication.shared.canOpenURL(callUrl) {
                UIApplication.shared.open(callUrl, options: [:], completionHandler: nil)
            }
            else {
            }
        }
        else{
            self.loadInitialVC()
        }
    }
    //    @objc func callButtonAct(_ sender: UIButton) {
    //        if let phoneNumber = itemDetails?.mobileNo, !phoneNumber.isEmpty {
    //            // Replace "sms" with "sms:" if you want to open the Messages app directly
    //            if let messageUrl = URL(string: "sms:\(phoneNumber)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""),
    //               UIApplication.shared.canOpenURL(messageUrl) {
    //                UIApplication.shared.open(messageUrl, options: [:], completionHandler: nil)
    //            } else {
    //                // Handle if the device can't open Messages app
    //                print("Cannot open Messages app")
    //            }
    //        } else {
    //            // Handle if mobile number is not available
    //            print("No mobile number available")
    //        }
    //    }
    @objc func commentButtonAct() {
        self.viewModels.getProfileData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", user_name: "",profile_id: "", onSuccess: { (success) in
            print(success)
            if success {
                if let profileData = self.viewModels.profileModel?.result {
                    self.profileData = profileData
//                    if self.profileData?.verification.mobNo == false{
//                        self.showAlerts()
//                    }else{
                    let canProceed = (self.profileData?.can_access == true) ||
                                     (self.profileData?.verification.mobNo == true)

                    if !canProceed {
                        self.showAlerts()
                        return
                    }
                        let pageObj = CommentViewController()
                        pageObj.itemVC = self
                        pageObj.itemModel = self.itemDetails
                        self.navigationController?.pushViewController(pageObj, animated: true)
                 //   }
                    
                }
            }
        }) { (failure) in
        }
        
        
    }
    @objc func shareAct(_ sender: UIButton) {
        let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
        let message = "\(itemDetails?.itemTitle ?? "") \n \(itemDetails?.productUrl ?? "")"
        
        if let url = URL(string: (itemDetails?.productUrl ?? "")) {
            if sender.tag == 0 {
                if let fbURL = URL(string: "fb://"), UIApplication.shared.canOpenURL(fbURL) {
                    let content = ShareLinkContent()
                    content.contentURL = url
                    content.quote = (itemDetails?.itemTitle ?? "")
                    let dialog = ShareDialog()
                    dialog.fromViewController = self
                    dialog.shareContent = content
                    dialog.mode = .shareSheet
                    dialog.show()
                }
                else {
                    alert.message = getLanguage["Facebook not installed"] ?? ""
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else if sender.tag == 1 {
                if let twitterURL = URL(string: "twitter://post?message=\(message)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""), UIApplication.shared.canOpenURL(twitterURL) {
                    UIApplication.shared.open(twitterURL, options: [:], completionHandler: nil)
                }
                else {
                    alert.message = getLanguage["twitter_installed"] ?? ""
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else if sender.tag == 2 {
                if let whatsAppUrl = URL(string: "whatsapp://send?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), UIApplication.shared.canOpenURL(whatsAppUrl) {
                    UIApplication.shared.open(whatsAppUrl, options: [:], completionHandler: nil)
                }
                else {
                    alert.message = getLanguage["whatsapp_installed"] ?? ""
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                let textToShare = [(itemDetails?.productUrl ?? "")]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    @objc func viewUserAct(_ sender: UITapGestureRecognizer) {
        let pageObj = ViewProfileViewController()
        pageObj.userId = "\(self.itemDetails?.sellerId ?? "")"
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let y = 300 - (scrollView.contentOffset.y + 300)
            let height = min(max(y, 0), 400)
            topViewHeightConst.constant = height
            //            self.collectionView.reloadData()
            if self.topViewHeightConst.constant < 10 {
                self.pageView.isHidden = true
                self.collectionView.isHidden = true
                self.topView.isHidden = true
                self.youtubeView.isHidden = true
                self.navigationController?.NavigationBarWithBackButtonAndTitle(title: (self.itemDetails?.itemTitle ?? ""), fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
                
            }
            else {
                if ((self.itemDetails?.photos.count ?? 0) > 1) {
                    self.pageView.isHidden = false
                }
                self.navigationController?.NavigationBarWithBackButtonAndTitle(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
                if (self.itemDetails?.youtubeLink ?? "") != "" {
                    self.youtubeView.isHidden = false
                }
                self.collectionView.isHidden = false
                self.topView.isHidden = false
            }
        }
        else if scrollView == collectionView {
            
        }
    }
    func didSelectAct(_ itemModel: ItemModel) {
        let pageObj = ItemDetailsViewController()
        pageObj.itemDetails = itemModel
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
}
extension ItemDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.itemDetails?.photos.count ?? 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotocellCollectionViewCell", for: indexPath) as! PhotocellCollectionViewCell
        
        if let photos = self.itemDetails?.photos[indexPath.row] {
            cell.loadData(photos)
        }
        if  indexPath.item == selectedindex {
            cell.Cornerview.layer.borderColor = UIColor(named: "AppThemeColorNew")?.cgColor
            cell.Cornerview.layer.borderWidth = 1.5 //
        }else{
            cell.Cornerview.layer.borderColor = UIColor.clear.cgColor
            cell.Cornerview.layer.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 45, height: 45)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.photoLabel.text = "\(indexPath.row + 1)/\(self.itemDetails?.photos.count ?? 0)"
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photos = self.itemDetails?.photos[indexPath.row] {
            self.itemimagevieew.sd_setImage(with: URL(string: photos.itemUrlMainOriginal)) { (image, error, cache, url) in
                if error != nil {
                    self.itemimagevieew.image = #imageLiteral(resourceName: "applogo")
                }
            }
        }
        selectedindex = indexPath.item
        DispatchQueue.main.async {
            self.imagelistcv.reloadData()
        }
        
        
        
        /*
         let fullScreenController = FullScreenSlideshowViewController()
         if let imageArr = self.itemDetails?.photos.map({$0.itemUrlMainOriginal}) {
         var imageSource = [SDWebImageSource]()
         for img in imageArr {
         if let image = SDWebImageSource(urlString: img ?? "", placeholder: #imageLiteral(resourceName: "applogo")) {
         imageSource.append(image)
         }
         else {
         imageSource.append(SDWebImageSource(urlString: self.itemDetails?.photos.first?.itemUrlMain350 ?? "", placeholder: #imageLiteral(resourceName: "profilelogo"))!)
         }
         }
         let pageIndicatorLabel = LabelPageIndicator()
         pageIndicatorLabel.textColor = UIColor(named: "whitecolor")
         pageIndicatorLabel.widthAnchor
         pageIndicatorLabel.textAlignment = .center
         fullScreenController.slideshow.pageIndicator = pageIndicatorLabel
         fullScreenController.slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .customBottom(padding: 20))
         
         fullScreenController.slideshow.circular = false
         fullScreenController.backgroundColor = UIColor(white: 0, alpha: 0.7)
         fullScreenController.closeButton.setImage(#imageLiteral(resourceName: "takeclose"), for: .normal)
         fullScreenController.closeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
         fullScreenController.closeButton.tintColor = .black
         fullScreenController.inputs = imageSource
         fullScreenController.initialPage = indexPath.row
         
         fullScreenController.slideshow.currentPageChanged = { [weak self] page in
         if let cell = collectionView.cellForItem(at: indexPath) as? ItemDetailsImageCollectionViewCell, let imageView = cell.itemImageView {
         self?.slideshowTransitioningDelegate?.referenceImageView = imageView
         }
         }
         present(fullScreenController, animated: true, completion: nil)
         }
         */
        
        
    }
    
}
extension ItemDetailsViewController: WKYTPlayerViewDelegate {
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        if state == .playing {
            playerView.isHidden = false
        }
        else if state == .paused {
            playerView.isHidden = true
        }
    }
}

//extension ItemDetailsViewController: GADBannerViewDelegate{
//    //banner view delegate
//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        bannerView.isHidden = false
//        bannerView.isHidden = false
//        UIView.animate(withDuration: 1, animations: {
//            self.bannerView.isHidden = false
//        })
//    }
//
//    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
////        self.bannerViews.isHidden = true
////        bannerView.isHidden = true
//        print("BANNER ERROR \(error.localizedDescription)")
//    }
//}


extension ItemDetailsViewController: GADBannerViewDelegate{
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


