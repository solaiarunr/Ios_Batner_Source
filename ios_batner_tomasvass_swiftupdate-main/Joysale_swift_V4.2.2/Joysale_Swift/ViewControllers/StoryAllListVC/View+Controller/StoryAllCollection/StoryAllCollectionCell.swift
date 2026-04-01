//
//  StoryAllCollectionCell.swift
//  Joyshorts_Swift
//
//  Created by APPLE on 14/12/22.
//

import UIKit
import AVFoundation
import Lottie
import GoogleMobileAds
import SDWebImage
protocol itemDetailDelegate {
    func viewBtnAct(_ id: String, tag: Int,cell: StoryAllCollectionCell)
}
protocol playpassdelegate {
    func newstart(product_types:String,cell: StoryAllCollectionCell)
    func newstop(product_types:String,cell: StoryAllCollectionCell)
}

protocol DescriptionPopDelegate: AnyObject{
    func showpopup(txt: String)
}

protocol storyAllDelegate {
    func imageBtnAct(tag: Int, selectedTag: Int)
}

class StoryAllCollectionCell: UICollectionViewCell,UIScrollViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var collectioStack: UIStackView!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var cmntView: UIView!
    @IBOutlet weak var cmntBtn: UIButton!
    @IBOutlet weak var cmntLbl: UILabel!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var shareLbl: UILabel!
    @IBOutlet weak var urgentstatusView: UIView!
    @IBOutlet weak var urgentstatusLbl: UILabel!
    @IBOutlet weak var adstatusView: UIView!
    @IBOutlet weak var adstatusLbl: UILabel!
    @IBOutlet weak var videoTimeLabel: UILabel!
    @IBOutlet var lottiEAnimation: LottieAnimationView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var likeStack: UIStackView!
    @IBOutlet weak var callStack: UIStackView!
    @IBOutlet weak var itemconditionlbl: UIButton!
    @IBOutlet weak var prroducttitlename: UILabel!
    @IBOutlet weak var prroductprice: UILabel!
    @IBOutlet weak var DesTv: UITextView!
    @IBOutlet weak var DesTvHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var DaysCountLbl: UILabel!
    @IBOutlet weak var Locationbtn: UIButton!
    @IBOutlet weak var imagelistcv: UICollectionView!
    @IBOutlet weak var itemimagevieew: UIImageView!
    @IBOutlet weak var MoreBtn: UIButton!
    @IBOutlet weak var ExchangeStack: UIStackView!
    @IBOutlet weak var Exchangebtn: UIButton!
    @IBOutlet weak var CallBtnTap: UIButton!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var PlusImgView: UIImageView!
    @IBOutlet weak var BannerView: UIView!
    @IBOutlet weak var ExchageLbl: UILabel!
    @IBOutlet weak var MoreLbl: UILabel!
    @IBOutlet weak var NewShareLbl: UILabel!
    @IBOutlet weak var CallLbl: UILabel!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var MakeAnOfferbtn: UIButton!
    @IBOutlet weak var NeedStack: UIStackView!
    
    @IBOutlet weak var layerview: UIStackView!
    
    @IBOutlet weak var MoreBtnNew: UIButton!
    
    @IBOutlet weak var DesLblew: UILabel!
    
    @IBOutlet weak var MoreViewCorner: UIView!
    
    @IBOutlet weak var MoreBtnNewview: UIView!
    
    
 
    
    //
    var bannerView1:GADBannerView!
    let collapsedHeight: CGFloat = 60  // Approx. height for 3 lines
    let maxExpandedHeight: CGFloat = 300
    let maxLines = 3  // Limit to 3 lines before "More
    var isExpanded = false
    var playpassdelegate: playpassdelegate?
    var storyAllDelegate: storyAllDelegate?
    var selectedindex = 0
    var fullText = ""
    var storyVC: StoryAllList?
    var tempData: StoryListModel!
    var tempIndex : Int!
    var publisherId = ""
    var avPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var productModel = [GetItemsResult1]()
    var productID = [String]()
    var productAct: ((String) -> ())?
    var countTimer = Timer()
    var startTime = 0
    var reloadVideo = "no"
    var product_types = ""
    var isDescriptionExpanded = false
    var fullDescriptionText: String = ""
    private var likeDoubleTap = UITapGestureRecognizer()
    var lastScale: CGFloat = 1.0
    var lastCenter: CGPoint = .zero
    var lastTranslation: CGPoint = .zero
    var currentTransform: CGAffineTransform = .identity
    var pinchStartImageCenter: CGPoint = .zero
    var pichCenter: CGPoint = .zero
    var minScale: CGFloat = 1.0
    var maxScale: CGFloat = 3.0
    var frameActual: CGRect = .zero
    var viewAct: itemDetailDelegate?
    var isSliding = false
    let colorurgent1 =  UIColor().hexValue(hex: "#ED213A")
    let colorurgent =  UIColor().hexValue(hex: "#93291E")
    let colorad1 =  UIColor().hexValue(hex: "#4CFA40")
    let colorad =  UIColor().hexValue(hex: "#2CA153")
    var  itemDetails : StoryListModel!
    var parentViewController = StoryAllList()
    
    weak var descriptionDelegate: DescriptionPopDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.collectionView.isHidden = true
        print("the print check for 5")
        // Initialization code
        self.avPlayer?.automaticallyWaitsToMinimizeStalling = false
        let tapGesture = UITapGestureRecognizer(target: self,
                                            action: #selector(self.gestureAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.playerView.addGestureRecognizer(tapGesture)
        self.lottiEAnimation.isHidden = true
        // Zoom image
        let pinchGetsture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchActionZoomImage))
        pinchGetsture.delegate = self
        playerView?.addGestureRecognizer(pinchGetsture)

        let stackViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStackViewTap(_:)))
        collectioStack.addGestureRecognizer(stackViewTapGesture)
        collectioStack.isUserInteractionEnabled = true
        // Move image
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panActionmoveImage))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        playerView?.addGestureRecognizer(panGesture)
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))         //MARK: Custom Work
//        playerView.addGestureRecognizer(pinchGesture)
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        panGesture.maximumNumberOfTouches = 2
//        panGesture.minimumNumberOfTouches = 2
//        playerView.addGestureRecognizer(panGesture)
        playerView.isUserInteractionEnabled = true
        if UserDefaultModule.shared.getUserData()?.user_id ?? "" != "" {
//            noneedlike
//            likeDoubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapLike))
//            likeDoubleTap.numberOfTapsRequired = 2
//            self.playerView.addGestureRecognizer(likeDoubleTap)
//            tapGesture.require(toFail: likeDoubleTap)
        }
        self.progressView.isHidden = true
        self.setupSlider()          //MARK: Custom Work
        self.configUI()
      
        
    }
    func loadBannerView() {
        print("loadBannerViewchk")
//        if (ADMIN_VIEW_MODEL.adminModel?.result.googleAds ?? "").lowercased() == "enable" {
            // Clear old banner if it exists
            self.bannerView1?.removeFromSuperview()

            // Create banner view
            bannerView1 = GADBannerView(adSize: GADAdSizeBanner)
            bannerView1.translatesAutoresizingMaskIntoConstraints = false
            bannerView1.adUnitID = BANNNER_ID
            bannerView1.rootViewController = self.parentViewController
            bannerView1.delegate = self
            bannerView1.load(GADRequest())

            // Add to view and apply constraints
            BannerView.addSubview(bannerView1)
            NSLayoutConstraint.activate([
                bannerView1.leadingAnchor.constraint(equalTo: BannerView.leadingAnchor),
                bannerView1.trailingAnchor.constraint(equalTo: BannerView.trailingAnchor),
                bannerView1.topAnchor.constraint(equalTo: BannerView.topAnchor),
                bannerView1.bottomAnchor.constraint(equalTo: BannerView.bottomAnchor)
            ])

            // Unhide banner container
            self.BannerView.isHidden = false
//        }
    }
    
    func checkAdStatusAndLoadBanner() {
        if Ad_Status {
            self.loadBannerView()
        }else{
            self.BannerView.isHidden = true
        }
    }
    



    @objc func handleStackViewTap(_ sender: UITapGestureRecognizer) {
        // Handle stackView tap - redirect to the second view
        print("Stack view tapped")
        // Check if the tap was on the subView
        let location = sender.location(in: self.collectioStack)
        if !collectionView.frame.contains(location) {
            print("Stack view tapped 1")
        }else{
//            self.redirectToPause()
        }
    }


    func redirectToPause() {
        
        if self.collectionView.isHidden{
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                           animations: {
                self.collectionView.isHidden = false
                print("the print check for 6")
            }, completion: nil)
            self.timeprocess()
        }else{
        }
        if self.avPlayer?.isPlaying ?? false{
            self.avPlayer?.pause()
            self.playImageView.isHidden = false
        }else{
            self.avPlayer?.play()
            self.playImageView.isHidden = true
        }
    }
    

    @objc func doubleTapLike() {
        if self.publisherId != UserDefaultModule.shared.getUserData()?.user_id ?? ""{
            
            if (self.tempData.liked ?? "") == "yes"{
                UIView.animate(withDuration: 0.4, delay: 0.1, animations: {
                    self.lottiEAnimation.isHidden = false
                }, completion: {_ in
                    self.lottiEAnimation.play{ (finished) in
                        UIView.animate(withDuration: 1, animations: {
                            self.lottiEAnimation.isHidden = true
                        })
                    }
                })
            }else{
                self.likeBtn.tintColor = UIColor.init(named: "redcolor")
                UIView.animate(withDuration: 0.4, delay: 0.1, animations: {
                    self.lottiEAnimation.isHidden = false
                }, completion: {_ in
                    self.lottiEAnimation.play{ (finished) in
                        UIView.animate(withDuration: 1, animations: {
                            self.lottiEAnimation.isHidden = true
                        })
                    }
                })
                
                self.likeBtn.transform =
                CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
                UIView.animate(withDuration: 0.3 / 1.5, animations: {
                    self.likeBtn.transform =
                    CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
                }) { finished in
                    UIView.animate(withDuration: 0.3 / 2, animations: {
                        self.likeBtn.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
                    }) { finished in
                        UIView.animate(withDuration: 0.3 / 2, animations: {
                            self.likeBtn.transform = CGAffineTransform.identity
                        })
                    }
                }
                if !playImageView.isHidden{
                    playImageView.isHidden = false
                }
                self.storyVC?.pushView(self.tempIndex)
            }
        }
    }
    
    @objc func gestureAction(_ sender: UITapGestureRecognizer) {
        print("cjsvc lsdlvsdcvdsjvcjlsdvcjldsvjcvsjvcsvd")
        if self.collectionView.isHidden{
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                           animations: {
                self.collectionView.isHidden = false
                print("the print check for 6")
            }, completion: nil)
            self.timeprocess()
        }else{
        }
        if self.avPlayer?.isPlaying ?? false{
            self.avPlayer?.pause()
            self.playImageView.isHidden = false
        }else{
            self.avPlayer?.play()
            self.playImageView.isHidden = true
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.countTimer.invalidate()
//        self.collectionView.isHidden = false
    
    }

    @objc func updateTimer()  {
        DispatchQueue.main.async {
            print("time_manage:\(self.startTime)")
            self.startTime += 1
            if self.startTime % 5 == 0{
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut],
                               animations: {
                    self.collectionView.isHidden = true
                    print("the print check for 7")
                    self.countTimer.invalidate()
                }, completion: nil)
                
            }
        }
    }
    func setupSlider() {
        // Set the maximum value of the slider (representing 100% progress)
        sliderView.maximumValue = 1.0
        sliderView.minimumValue = 0.0
        sliderView.value = 0.0
        
        // Set a smaller thumb image
        if let thumbImage = UIImage(named: "dry-clean-new") {
            let thumbSize = CGSize(width: 10, height: 10) // Make it smaller as needed
            let resizedThumbImage = thumbImage.resizedImage(targetSize: thumbSize)
            sliderView.setThumbImage(resizedThumbImage, for: .normal)
            sliderView.setThumbImage(resizedThumbImage, for: .highlighted)
        }
        
//        sliderView.thumbTintColor = UIColor(named: "AppThemeColor") // only affects default thumb, not image
       sliderView.minimumTrackTintColor = UIColor(named: "AppThemeColorNew")

        // Add targets
        sliderView.addTarget(self, action: #selector(videoSliderValueChanged), for: .valueChanged)
        sliderView.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        sliderView.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)
        sliderView.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpOutside)
    }

    @IBAction func sliderTouchDown(_ sender: UISlider) {
         pausePlayer()
         isSliding = true
     }

     @IBAction func sliderTouchUp(_ sender: UISlider) {
         playPlayer()
         isSliding = false
     }
    
    @IBAction func imageBtnAct(_ sender: UIButton) {
        self.storyAllDelegate?.imageBtnAct(tag: sender.tag, selectedTag: self.selectedindex)
    }

     func pausePlayer() {
         self.avPlayer?.pause()
     }

     func playPlayer() {
         self.avPlayer?.play()
     }
    @objc func videoSliderValueChanged(sender: UISlider) {
        progressValueChanged(sender.value)
    }
    
    func progressValueChanged(_ sliderValue: Float) {
        // Update video playback time based on slider value
        self.avPlayer?.pause()
        let currentTime = Double(sliderValue) * (self.avPlayer?.currentItem?.duration.seconds ?? 0)
        let time = CMTime(seconds: currentTime, preferredTimescale: 600)
        self.avPlayer?.seek(to: time)
        print("-->Working<--")
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       // self.timeprocess()
    }
    override func layoutSubviews() {
        self.playerLayer?.frame = self.playerView.bounds
    }
    override func layoutIfNeeded() {
        self.playerLayer?.frame = self.playerView.bounds
    }
    func configUI() {
        self.collectionView.register(UINib(nibName: "SelectedProductCell", bundle: nil), forCellWithReuseIdentifier: "SelectedProductCell")
        self.playImageView.isHidden = true
        self.progressView.setProgress(0, animated: false)
        self.sliderView.setValue(0, animated: false)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.contentView.bringSubviewToFront(self.collectionView)
        self.likeLbl.config(color: .white, font: UIFont(name: APP_FONT_BOLD, size: 13), align: .center, text: "")
        self.cmntLbl.config(color: .white, font: UIFont(name: APP_FONT_BOLD, size: 13), align: .center, text: "")
        self.shareLbl.config(color: .white, font: UIFont(name: APP_FONT_BOLD, size: 13), align: .center, text: "share")
        self.MoreBtnNew.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, title: "More")
        self.likeLbl.text = "1"
        print("likeLbl1")
        self.cmntLbl.text = "1"
        self.collectionView.isHidden = true
        print("the print check for 8")
        
        self.urgentstatusView.isHidden = true
        self.adstatusView.isHidden = true
        self.urgentstatusView.cornerViewMiniumRadius()
        self.adstatusView.cornerViewMiniumRadius()
        
        self.urgentstatusLbl.config(color: .white, font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .center, text: "")
        self.adstatusLbl.config(color: UIColor.white, font: UIFont(name: APP_FONT_REGULAR, size: 12), align: .center, text: "")

        
        self.urgentstatusLbl.text = getLanguage["ad"] ?? ""
      //  self.urgentstatusView.addGradientTag(firstColor: colorurgent, secondColor: colorurgent1)
        
        self.adstatusLbl.text = getLanguage["ad"] ?? ""
//        self.adstatusLbl.text = getLanguage["ad"] ?? ""
//        self.adstatusView.addGradientTag(firstColor: colorad, secondColor: colorad1)
        
        self.adstatusView.backgroundColor = UIColor(named: "newurgentcolor")
        self.urgentstatusView.backgroundColor = UIColor(named: "newurgentcolor")
        
        itemconditionlbl.contentEdgeInsets = .zero
        itemconditionlbl.titleEdgeInsets = .zero
        itemconditionlbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        itemconditionlbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        itemconditionlbl.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        itemconditionlbl.sizeToFit()
       self.itemconditionlbl.layer.cornerRadius = 5
//        itemconditionlbl.layer.cornerRadius = itemconditionlbl.frame.height / 1.5
        self.itemconditionlbl.clipsToBounds = true
        self.itemconditionlbl.config(color: UIColor(named: "greencolortxt"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.center, title: "")
        //solai
        self.imagelistcv.register(UINib(nibName: "PhotocellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotocellCollectionViewCell")
        self.imagelistcv.delegate = self
        self.imagelistcv.dataSource = self
        
        self.prroducttitlename.config(color: UIColor(named: "greencolortxt"), font: UIFont(name: APP_FONT_BOLD, size: 14), align:.left, text: "")
        self.prroductprice.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 20), align:.left, text: "")
    
        DesTv.delegate = self
        self.DesTv.textColor = UIColor(named: "greencolortxt")
        self.DaysCountLbl.font = UIFont(name: APP_FONT_REGULAR, size: 14)
        self.DaysCountLbl.textColor = UIColor(named: "greencolorbold")
        
        self.DesLblew.textColor = UIColor(named: "greencolortxt")
        self.DesLblew.font = UIFont(name: APP_FONT_REGULAR, size: 14)
       
        
        Locationbtn.contentHorizontalAlignment = .right
        Locationbtn.titleLabel?.lineBreakMode = .byTruncatingTail // Truncate long text with "..."
        Locationbtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        // Adjust space between image and title
        let spacing: CGFloat = 3 // Set the desired spacing
        Locationbtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        Locationbtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        
       self.Locationbtn.layer.cornerRadius = 5
//        Locationbtn.layer.cornerRadius = Locationbtn.frame.height / 1.8
        self.Locationbtn.clipsToBounds = true
        self.Locationbtn.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.center, title: "")
        self.buyNowButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "instantbuy")
        self.buyNowButton.backgroundColor = UIColor(named: "ShadowGreen")
        self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
        self.chatButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 16), align: .center, title: "chat")
        self.NewShareLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "share")
        self.CallLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "Call")
        self.ExchageLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "Exchange")
        self.MoreLbl.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align:.left, text: "More")
//        self.setTextViewPadding(self.DesTv, centerVertically: true)
        
        self.imageBtn.setTitle("", for: .normal)
        self.imageBtn.backgroundColor = .clear
        
        self.selectedindex = 0
        DispatchQueue.main.async {
            print("swdw23we44",self.selectedindex)
            self.imagelistcv.reloadData()
        }
    }

    func setTextViewPadding(_ textView: UITextView, top: CGFloat = 8, left: CGFloat = 12, bottom: CGFloat = 8, right: CGFloat = 12, removeLinePadding: Bool = true, centerVertically: Bool = false) {
        if removeLinePadding {
            textView.textContainer.lineFragmentPadding = 0
        }

        if centerVertically {
            // Calculate required height
            let size = CGSize(width: textView.frame.width - left - right, height: .infinity)
            let contentHeight = textView.sizeThatFits(size).height
            let availableHeight = textView.bounds.height
            let verticalInset = max(0, (availableHeight - contentHeight) / 2)

            textView.textContainerInset = UIEdgeInsets(top: verticalInset, left: left, bottom: verticalInset, right: right)
        } else {
            textView.textContainerInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
    }



    override func prepareForReuse() {
        super.prepareForReuse()
        // Clear the old image immediately
        self.itemimagevieew.image = nil
        self.itemimagevieew.sd_cancelCurrentImageLoad()
        self.itemimagevieew.sd_imageTransition = .flipFromTop
        // Reset any other reusable content
        self.productModel.removeAll()
        self.collectionView.reloadData()
        self.playerView.layer.sublayers = nil
        self.progressView.setProgress(0, animated: false)
        self.sliderView.setValue(0, animated: false)
    }
    func loadData(_ playerData: StoryListModel, products: [GetItemsResult1]) {
        self.itemDetails = playerData
        self.configUI()
      print("aftercul")
            if playerData.promotionType != "Normal"  {
                if playerData.promotionType == "Urgent" {
                    self.adstatusView.isHidden = true
                    self.urgentstatusView.isHidden = false
                }
                else if playerData.promotionType == "Ad" {
                    self.urgentstatusView.isHidden = true
                    self.adstatusView.isHidden = false
                }
            }
            else {
                self.urgentstatusView.isHidden = true
                self.adstatusView.isHidden = true
            }

        
        if (playerData.liked ?? "") == "yes"{
            self.likeBtn.setImage(#imageLiteral(resourceName: "newwhiteheart"), for: .normal)
            self.likeBtn.tintColor = UIColor.init(named: "redcolor")
        }else{
            self.likeBtn.setImage(#imageLiteral(resourceName: "newwhiteheart"), for: .normal)
            self.likeBtn.tintColor = UIColor.white
        }
        
        self.likeLbl.text = "\(playerData.likesCount ?? 0)"
        print("likeLbl2")
        self.cmntLbl.text = "\(playerData.commentsCount ?? 0)"
//        self.profileImg.sd_setImage(with: URL(string: (playerData.publisherImage ?? "")), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
        self.profileView.cornerViewRadius()
        /*
        self.productID = playerData.products
        */
        self.productID.removeAll()
        self.productID.append(playerData.products)
        print("self.productID:\(self.productID)")
        self.itemconditionlbl.setTitle(playerData.itemCondition, for: .normal)
        DesTv.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        DesTv.layer.cornerRadius = 5
        DesTv.clipsToBounds = true
        
        MoreViewCorner.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        MoreViewCorner.layer.cornerRadius = 5
        MoreViewCorner.clipsToBounds = true
        self.prroducttitlename.text = playerData.itemTitle
        layerview.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layerview.layer.cornerRadius = 5
        layerview.clipsToBounds = true
        self.DesLblew.text = playerData.itemDescription ?? ""
        self.fullDescriptionText = playerData.itemDescription ?? ""
        print("fullDescriptionTextcount",self.fullDescriptionText.count)
        DispatchQueue.main.async {
            if self.fullDescriptionText.count > 15 {
                // Show "More" button when text length > 15
                self.MoreBtnNewview.isHidden = false
            
            } else {
                // Hide "More" button when text length ≤ 15
                self.MoreBtnNewview.isHidden = true
             
            }
        }
        
      
/*
        let rawText = playerData.itemDescription ?? ""
        let decodedText = rawText.decodedEmojiSafe

        // Update UI on main thread
        DispatchQueue.main.async {
            self.DesLblew.text = decodedText
            self.fullDescriptionText = decodedText
            self.DesLblew.numberOfLines = 0 // allow multi-line

            // Force layout so label calculates intrinsic size
            self.DesLblew.setNeedsLayout()
            self.DesLblew.layoutIfNeeded()

            // Use NSString length to count characters safely including emojis
            let characterCount = (decodedText as NSString).length
            print("Character count:", characterCount)

            if characterCount > 15 {
                self.MoreBtnNewview.isHidden = false
            } else {
                self.MoreBtnNewview.isHidden = true
            }

            // Ensure layout updates after visibility change
            self.MoreBtnNewview.superview?.layoutIfNeeded()
        }

*/
        self.DesTv.text = self.fullDescriptionText
        print("Mspandi",self.fullDescriptionText)
        
 
        let dateString = Utility.shared.timeStampWithDateFormat(timeStamp: "\(playerData.postedTime ?? 0)", dateFormat: "EEE, dd MMM yy HH:mm:ss VVVV")
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEE, dd MMM yy HH:mm:ss VVVV"
        let date = dateFormatterGet.date(from: dateString)
        if let dateVal = date {
            self.DaysCountLbl.text = Date().offset(from: dateVal)
        }
        self.Locationbtn.setTitle(playerData.location, for: .normal)
        
        if (playerData.photos.count ?? 0) >= 1 {
            self.imagelistcv.isHidden = false
        }
        else {
            self.imagelistcv.isHidden = true
        }
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (playerData.sellerId ?? "") {
            self.MakeAnOfferbtn.isHidden = true
        }else{
            if playerData.makeOffer   == "0"{
                self.MakeAnOfferbtn.isHidden = false
            }else{
                self.MakeAnOfferbtn.isHidden = true
            }
        }
        
           
        
        if playerData.follow_status  == "true" || ((UserDefaultModule.shared.getUserData()?.user_id ?? "") == (playerData.publisherId ?? "")) {
            self.PlusImgView.isHidden = true
        }else{
            self.PlusImgView.isHidden = false
        }
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (playerData.publisherId ?? "") {
            self.ExchangeStack.isHidden = true
        }else{
            if (playerData.exchangeBuy ?? "") == "1" && EXCHANGE_MODEL_FLAG {
                self.ExchangeStack.isHidden = false
            }else{
                self.ExchangeStack.isHidden = true
            }
          
        }
        if playerData.totalPrice == 0 {
            self.prroductprice.textColor  = UIColor(named: "AppThemeColorNew")
            self.prroductprice.text = "Giving away"
        }else{
            self.prroductprice.text = playerData.formattedPrice
        }
        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (playerData.publisherId ?? "") {
            self.callStack.isHidden  =  true
        }else{
            if playerData.mobileVerification ?? false && playerData.showSellerMobile ?? false {
                self.callStack.isHidden = false
            }
            else {
                self.callStack.isHidden = true
            }
        }
        self.setButton(playerData: playerData)
        
      
    }
    @IBAction func MoreAction(_ sender: Any) {
        self.descriptionDelegate?.showpopup(txt: self.fullDescriptionText)
    }
    func setButton(playerData:StoryListModel){
        print("weneedplayerdaya",playerData)
        print("itemStatuscosodw",playerData.itemStatus ?? "")
        print("UserDefaultModulecheck1",UserDefaultModule.shared.getUserData()?.user_id ?? "")
        print("UserDefaultModulecheck2",playerData.sellerId ?? "")

        if (UserDefaultModule.shared.getUserData()?.user_id ?? "") == (playerData.sellerId ?? "") {

            var isBuyNowVisible = false
            var isItemSold = false

            if (playerData.itemStatus ?? "") == "onsale" {
                if (playerData.promotionType ?? "") != "Normal" {
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
            } else if (playerData.itemStatus ?? "") == "sold" {
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
                if playerData.makeOffer == "0" {
                    if (playerData.instantBuy ?? "") == "1" && (playerData.itemStatus ?? "") == "onsale" {
                        print("statneed")
                        self.buyNowButton.isHidden = false
                        self.MakeAnOfferbtn.backgroundColor = UIColor(named: "MakeofferNewcolor")
                        self.buyNowButton.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
                        self.buyNowButton.setTitleColor(UIColor(named: "BlackColorNew"), for: .normal)
                        self.MakeAnOfferbtn.setTitleColor(UIColor(named: "BlackColorNew"), for: .normal)
                        self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
                        self.chatButton.setTitleColor(UIColor(named: "whitecolor"), for: .normal)
                        self.chatButton.setTitle(getLanguage["chat"] ?? "", for: .normal)
                        self.chatButton.layer.cornerRadius = 0
                        self.MakeAnOfferbtn.layer.cornerRadius = 5
                        self.MakeAnOfferbtn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] // topLeft, bottomLeft
                        self.MakeAnOfferbtn.clipsToBounds = true
                        // Corner radius: right side only
                        self.buyNowButton.layer.cornerRadius = 5
                        self.buyNowButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // topRight, bottomRight
                        self.buyNowButton.clipsToBounds = true
                        
                    }else{
                        self.MakeAnOfferbtn.backgroundColor = UIColor(named: "MakeofferNewcolor")
                        self.MakeAnOfferbtn.setTitleColor(UIColor(named: "BlackColorNew"), for: .normal)
                        self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
                        self.chatButton.setTitleColor(UIColor(named: "whitecolor"), for: .normal)
                        self.chatButton.setTitle(getLanguage["chat"] ?? "", for: .normal)
                        self.buyNowButton.isHidden = true
                        self.MakeAnOfferbtn.layer.cornerRadius = 5
                        self.MakeAnOfferbtn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] // topLeft, bottomLeft
                        self.MakeAnOfferbtn.clipsToBounds = true
                        
                        // Corner radius: right side only
                        self.chatButton.layer.cornerRadius = 5
                        self.chatButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // topRight, bottomRight
                        self.chatButton.clipsToBounds = true
                    }
                    
                } else {
                    if (playerData.instantBuy ?? "") == "1" && (playerData.itemStatus ?? "") == "onsale" {
                        
                        self.buyNowButton.isHidden = false
                        self.buyNowButton.backgroundColor = UIColor(named: "whitetranss")?.withAlphaComponent(0.6)
                        self.buyNowButton.setTitleColor(UIColor(named: "BlackColorNew"), for: .normal)
                        self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
                        self.chatButton.setTitleColor(UIColor(named: "whitecolor"), for: .normal)
                        self.chatButton.setTitle(getLanguage["chat"] ?? "", for: .normal)
                        self.chatButton.layer.cornerRadius = 5
                        self.chatButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] // topLeft, bottomLeft
                        self.chatButton.clipsToBounds = true
                        // Corner radius: right side only
                        self.buyNowButton.layer.cornerRadius = 5
                        self.buyNowButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // topRight, bottomRight
                        self.buyNowButton.clipsToBounds = true
                        
                        
                    }else{
                        self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
                        self.chatButton.setTitleColor(UIColor(named: "whitecolor"), for: .normal)
                        self.chatButton.setTitle(getLanguage["chat"] ?? "", for: .normal)
                        self.buyNowButton.isHidden = true
                        self.chatButton.layer.cornerRadius = 5
                        self.chatButton.layer.maskedCorners = [
                            .layerMinXMinYCorner,
                            .layerMinXMaxYCorner,
                            .layerMaxXMinYCorner,
                            .layerMaxXMaxYCorner
                        ]
                        self.chatButton.clipsToBounds = true
                        
                    }
                    
                    
                }
                
            }else{
                
                
                               if playerData.makeOffer == "0" {
//                                   self.MakeAnOfferbtn.backgroundColor = UIColor(named: "whitecolor")?.withAlphaComponent(0.3)
                                   self.MakeAnOfferbtn.backgroundColor = UIColor(named: "MakeofferNewcolor")
                                   self.MakeAnOfferbtn.setTitleColor(UIColor(named: "BlackColorNew"), for: .normal)
                                   self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
                                   self.chatButton.setTitleColor(UIColor(named: "whitecolor"), for: .normal)
                                   self.chatButton.setTitle(getLanguage["chat"] ?? "", for: .normal)
                                   self.buyNowButton.isHidden = true
                
                                   // Corner radius: left side only
                                   self.MakeAnOfferbtn.layer.cornerRadius = 5
                                   self.MakeAnOfferbtn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] // topLeft, bottomLeft
                                   self.MakeAnOfferbtn.clipsToBounds = true
                
                                   // Corner radius: right side only
                                   self.chatButton.layer.cornerRadius = 5
                                   self.chatButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // topRight, bottomRight
                                   self.chatButton.clipsToBounds = true
                
                               } else {
                                   self.chatButton.backgroundColor = UIColor(named: "ShadowGreen")
                                   self.chatButton.setTitleColor(UIColor(named: "whitecolor"), for: .normal)
                                   self.chatButton.setTitle(getLanguage["chat"] ?? "", for: .normal)
                                   self.buyNowButton.isHidden = true
                                   self.chatButton.layer.cornerRadius = 5
                                    self.chatButton.layer.maskedCorners = [
                                        .layerMinXMinYCorner,
                                        .layerMinXMaxYCorner,
                                        .layerMaxXMinYCorner,
                                        .layerMaxXMaxYCorner
                                    ]
                                    self.chatButton.clipsToBounds = true
                               }
            }
        }
        
        
    }
   
    

    func loadProducts() {
        self.collectionView.isHidden = true
        let viewModel = StoryListViewModel()
        viewModel.getItems(user_id: tempData.publisherId ?? "", offset: "0", limit: "20", productID: self.productID) { status in
            self.collectionView.isHidden = true
            self.productModel = viewModel.productmodel?.result ?? [GetItemsResult1]()
            self.reloadProducts(products: self.productModel)
        } onFailure: { failure in
            self.collectionView.isHidden = true
        }
        print("the print check for 9")
    }
    func reloadProducts(products: [GetItemsResult1]) {
        self.productModel = products
        if self.productModel.count == 0 {
            self.collectionView.isHidden = true
        }
        else {
            if self.reloadVideo == "no"{
                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                                   animations: {
                        self.collectionView.isHidden = false
                        print("the print check for 10")
                        self.timeprocess()
                    }, completion: nil)
                })
            }else if self.reloadVideo == "yes"{
                if self.startTime % 5 == 0{
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut],
                                   animations: {
                        self.collectionView.isHidden = true
                        print("the print check for 11")
                        self.countTimer.invalidate()
                    }, completion: nil)
                }
            }else{
                
            }
        }
        self.playerLayer?.frame = self.playerView.bounds
        DispatchQueue.main.async {
            self.playerLayer?.frame = self.playerView.bounds
        }
        self.collectionView.reloadData()
        
    }
    /*
    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        guard playerLayer != nil else {
            return
        }
        
        var currentScale: CGFloat = (self.playerLayer?.transform.m11)!
        let newScale = min(max(currentScale * recognizer.scale, 1.0), 2.0)
        
        switch recognizer.state {
        case .changed:
            let scaleTransform = CGAffineTransform(scaleX: newScale, y: newScale)
            self.playerLayer?.setAffineTransform(scaleTransform)
        case .ended, .cancelled:
            currentScale = newScale
        default:
            break
        }
    }
    */
    func timeprocess(){
        self.countTimer.invalidate()
        self.startTime = 0
        self.updateTimer()
        self.countTimer = Timer.scheduledTimer(timeInterval: 1.0, target:self,selector:#selector(self.updateTimer), userInfo: nil, repeats: true)
    }
}

//extension StoryAllCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.productModel.count
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.collectionView.frame.width/1.6, height: self.collectionView.frame.height - 60)
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedProductCell", for: indexPath) as! SelectedProductCell
//        
//        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
//            cell.productLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
//            cell.productPrice.transform = CGAffineTransform(scaleX: -1, y: 1)
//            cell.viewBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
//            cell.productImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
//        }
//        
//        cell.viewBtn.tag = indexPath.item
//        cell.viewBtn.addTarget(self, action: #selector(self.viewBtnTap(_:)), for: .touchUpInside)
//        // In your cellForRowAt method
//        cell.productImageView.tag = indexPath.item
//        cell.productLabel.tag = indexPath.item
//
//        // Create separate gesture recognizers for image and label
//        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTap_Gest(_:)))
//        let labelTapGesture = UITapGestureRecognizer(target: self, action: #selector(labelViewTap_Gest(_:)))
//
//        // Add gesture recognizers
//        cell.productImageView.addGestureRecognizer(imageTapGesture)
//        cell.productLabel.addGestureRecognizer(labelTapGesture)
//
//        // Enable user interaction on both views
//        cell.productImageView.isUserInteractionEnabled = true
//        cell.productLabel.isUserInteractionEnabled = true        
//        cell.loadData(self.productModel[indexPath.item])
//        return cell
//    }
//    @objc func imageViewTap_Gest(_ sender: UITapGestureRecognizer) {
//        if let tappedImageView = sender.view as? UIImageView {
//            let tag = tappedImageView.tag
//            print("ImageView tapped, tag: \(tag)")
//            // Pass the action with product_id and tag
//            self.viewAct?.viewBtnAct(self.productModel[tag].product_id, tag: tag, cell: self)
//        }
//    }
//
//    @objc func labelViewTap_Gest(_ sender: UITapGestureRecognizer) {
//        if let tappedLabel = sender.view as? UILabel {
//            let tag = tappedLabel.tag
//            print("Label tapped, tag: \(tag)")
//            // Pass the action with product_id and tag
//            self.viewAct?.viewBtnAct(self.productModel[tag].product_id, tag: tag, cell: self)
//        }
//    }
//
//    @objc func viewBtnTap(_ Sender: UIButton) {
//        self.viewAct?.viewBtnAct(self.productModel[Sender.tag].product_id, tag: Sender.tag, cell: self)
////        self.productAct!(self.productModel[Sender.tag].product_id)
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 0)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 5
//    }
//}


extension StoryAllCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("itemDetails?.photos.co",(self.itemDetails?.photos.count ?? 0))
        return (self.itemDetails?.photos.count ?? 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotocellCollectionViewCell", for: indexPath) as! PhotocellCollectionViewCell
        print("reloadchkprocess")

        if let photos = self.itemDetails?.photos[indexPath.row] {
            cell.loadData(photos)
        }
        
        print("selectedindex",selectedindex)
        print("selectedindex2",indexPath.item)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photos = self.itemDetails?.photos[indexPath.row] {
            if photos.type == "video"{
//                self.playImageView.isHidden = false
                self.playerView.isHidden = false
                self.itemimagevieew.isHidden = true
                self.playpassdelegate?.newstart(product_types:photos.type,cell:self)
                self.sliderView.isHidden = false
                
            }else{
                self.imageSelectedAct(photos: photos, index: indexPath.item)
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
    
    func imageSelectedAct(photos: PhotoModel, index: Int) {
        print("print the index now \(index)")
        self.playImageView.isHidden = true
        self.sliderView.isHidden = true
        self.playerView.isHidden = true
        self.playpassdelegate?.newstop(product_types:photos.type,cell:self)
        let placeholderImage = UIImage(named: "applogo") // add one to assets
        self.itemimagevieew.sd_imageTransition = .flipFromTop
//        let cleaned = raw.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
//                           .replacingOccurrences(of: "\\/", with: "/")
        self.itemimagevieew.sd_setImage(with: URL(string: photos.itemUrlMainOriginal), placeholderImage: placeholderImage)
//        self.itemimagevieew.sd_setImage(
//            with: URL(string: photos.itemUrlMainOriginal),
//            placeholderImage: #imageLiteral(resourceName: "product_gallery"),
//            options: .refreshCached,
//            completed: { [weak self] (image, error, cache, url) in
//                if error != nil {
//                    self?.itemimagevieew.isHidden = false
//                    self?.itemimagevieew.image = image
//                }
//            }
//        )

    }
    
}
extension StoryAllCollectionCell {
    
    private var cumulativeScale: CGFloat {
        get {
            return playerView.transform.a
        }
        set {
            playerView.transform = CGAffineTransform(scaleX: newValue, y: newValue)
        }
    }
    
    @objc func resetZoom() {
        cumulativeScale = 1.0
    }

//    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
//        // Inside handlePinchGesture method
//        /*
//        switch recognizer.state { 
//        case .began, .changed:
//            cumulativeScale *= recognizer.scale
//            recognizer.scale = 1.0
//
//        case .ended:
//            // Optional: Reset zoom after pinch gesture ends
//            resetZoom()
//
//        default:
//            break
//        }
//        */
//        switch recognizer.state {
//        case .began, .changed:
//            cumulativeScale *= recognizer.scale
//            recognizer.scale = 1.0
//
//        default:
//            break
//        }
//    }
//    // Image zoom in and zoom out
    
    @objc func pinchActionZoomImage(gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizer.State.began { // Begin pinch
            // Store current transfrom of UIImageView
            self.currentTransform = playerView.transform
            
            // Store initial loaction of pinch action
            self.pinchStartImageCenter = playerView.center
            
            let touchPoint1 = gesture.location(ofTouch: 0, in: playerView)
            let touchPoint2 = gesture.location(ofTouch: 1, in: playerView)
            
            // Get mid point of two touch
            self.pichCenter = CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2, y: (touchPoint1.y + touchPoint2.y) / 2)
            lastScale = gesture.scale
        } else if gesture.state == UIGestureRecognizer.State.changed { // Pinching in progress
            // Calculate the new scale
            let pinchCenter = CGPoint(x: gesture.location(in: playerView).x - playerView.bounds.midX,
                                      y: gesture.location(in: playerView).y - playerView.bounds.midY)
            
            let currentScale = sqrt(abs(playerView.transform.a * playerView.transform.d - playerView.transform.b * playerView.transform.c))
            var newScale = gesture.scale * currentScale
            
            // Apply the maximum zoom limit
            let maxScale: CGFloat = 3.0
            if newScale < minScale {
                newScale = minScale
            }
            if newScale > maxScale {
                newScale = maxScale
            }
            
            let transform = playerView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: newScale / currentScale, y: newScale / currentScale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            playerView.transform = transform
            
            gesture.scale = 1 // Reset gesture scale
            
        }
        if gesture.state == UIGestureRecognizer.State.ended { // End pinch
            // Get current scale

            let currentScale = sqrt(abs(playerView.transform.a * playerView.transform.d - playerView.transform.b * playerView.transform.c))
            if currentScale <= self.minScale {
                self.resetZoom()
            }
        }
    }
    
    @objc func panActionmoveImage(gesture: UIPanGestureRecognizer) {
        
        // Store current transfrom of UIImageView
        let transform = playerView.transform
        
        // Initialize imageView.transform
        playerView.transform = CGAffineTransform.identity
        
        // Move UIImageView
        let point: CGPoint = gesture.translation(in: playerView)
        let movedPoint = CGPoint(x: playerView.center.x + point.x,
                                 y: playerView.center.y + point.y)
        playerView.center = movedPoint
        
        // Revert imageView.transform
        playerView.transform = transform
        
        // Reset translation
        gesture.setTranslation(CGPoint.zero, in: playerView)
        
    }
//    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
//        guard recognizer.numberOfTouches == 2 else { return }
//        
//        let touch1 = recognizer.location(ofTouch: 0, in: recognizer.view)
//        let touch2 = recognizer.location(ofTouch: 1, in: recognizer.view)
//        let centerPoint = CGPoint(x: (touch1.x + touch2.x) / 2, y: (touch1.y + touch2.y) / 2)
//        
//        switch recognizer.state {
//        case .began:
//            lastScale = 1.0
//            lastCenter = centerPoint
//            
//        case .changed:
//            let currentScale = recognizer.view?.transform.a ?? 1.0
//            let newScale = currentScale * recognizer.scale
//            
//            let minimumScale: CGFloat = 1.0
//            let maximumScale: CGFloat = 3.0
//            
//            if newScale >= minimumScale && newScale <= maximumScale {
//                recognizer.view?.transform = CGAffineTransform(scaleX: newScale, y: newScale)
//                recognizer.scale = 1.0
//                
//                let newCenterX = recognizer.view!.center.x + (centerPoint.x - lastCenter.x) * recognizer.scale
//                let newCenterY = recognizer.view!.center.y + (centerPoint.y - lastCenter.y) * recognizer.scale
//                
//                recognizer.view?.center = CGPoint(x: newCenterX, y: newCenterY)
//                
//                lastScale = newScale
//                lastCenter = centerPoint
//            }
//            
//        default:
//            break
//        }
//    }

//    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
//        guard recognizer.numberOfTouches == 2 else { return } // Check for two touches
//
//        let translation = recognizer.translation(in: playerView)
//        
//        // Set maximum allowed translation in both x and y directions
//        let maxTranslationX: CGFloat = 10.0 // Example value for maximum allowed translation in X direction
//        let maxTranslationY: CGFloat = 10.0 // Example value for maximum allowed translation in Y direction
//        
//        let limitedTranslationX = min(maxTranslationX, max(-maxTranslationX, translation.x))
//        let limitedTranslationY = min(maxTranslationY, max(-maxTranslationY, translation.y))
//        
//        switch recognizer.state {
//        case .changed:
//            // Apply limited translation to the view's center
//            playerView.center = CGPoint(x: playerView.center.x + limitedTranslationX, y: playerView.center.y + limitedTranslationY)
//            recognizer.setTranslation(.zero, in: playerView) // Reset translation
//            
//        default:
//            break
//        }
//    }



}
extension UIImage {
    func resizedImage(targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}


extension StoryAllCollectionCell: GADBannerViewDelegate{
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
extension String {
    var decodedEmojiSafe: String {
        // Replace numeric HTML entities like &#128512; with actual characters
        var text = self
        let pattern = "&#(\\d+);"

        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) ?? []

        for match in matches.reversed() {
            if match.numberOfRanges > 1,
               let range = Range(match.range(at: 1), in: text),
               let codePoint = UInt32(text[range]) {
                
                let scalar = UnicodeScalar(codePoint)
                text.replaceSubrange(Range(match.range, in: text)!, with: String(scalar!))
            }
        }
        return text
    }
}
