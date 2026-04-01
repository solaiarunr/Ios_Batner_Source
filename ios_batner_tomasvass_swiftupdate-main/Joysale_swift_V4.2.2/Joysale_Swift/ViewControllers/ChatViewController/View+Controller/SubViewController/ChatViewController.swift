 //
 //  ChatViewController.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 11/06/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //
 
 import UIKit
 import SocketIO
 import SwiftyJSON
 import NVActivityIndicatorView
 import ImageSlideshow
 import MobileCoreServices
 import Photos
 import GiphyUISDK
class ChatViewController: UIViewController,PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    
    
    @IBOutlet weak var sendWholeView: UIView!
    @IBOutlet weak var smartReplyCollectionView: UICollectionView!
    @IBOutlet weak var textViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var sendStackView: UIStackView!
    @IBOutlet weak var bottomLoader: NVActivityIndicatorView!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var gifButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var callTitleLabel: UILabel!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var audioCallTextLabel: UILabel!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var videoCallTextLabel: UILabel!
     
     @IBOutlet weak var wholeStackView: UIStackView!
     
     private var videoFetchResult: PHFetchResult<PHAsset>?
    
    var viewModel = ChatViewModel()
    var itemDetails: ItemModel?
     var itemDetailsvideo: StoryListModel?
    
    // Audio Chat View
    var IS_AUDIO = false

    
    // Check chat From Itemdetails page or not
    var isFromItemDetails = false
    var chatId = ""
    var receiverId = ""
    var id = ""
    var userName = ""
    var isFound = true
    var imagePicker: ImagePicker!
    // Block & Block_by_me
    var block = false
    var blockedByMe = false
    var isfromtype = ""
    
    // Pagination
    var isLoadingMore = false // flag
    private let refreshControl = UIRefreshControl()
    var chatModelArray = [ChildChatModel]()
    var msgModel = [MessageModel]()
    var resModel = [ChatListResultModel]()
    var offSet = 0
    var lastContentOffset: CGFloat = 0
    var socketIOClient: SocketIOClient!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var chatDetailDict = NSDictionary()
    // Smart Reply
//    var smartReplyArray = [SmartReplySuggestion]()
    
    /*
    @IBOutlet weak var recordView: RecordView!
    @IBOutlet weak var recordButton: RecordButton!
    let recorderView = RecordView()
    var audioPlayer = AVAudioPlayer()
    var counter = 0
    var timer = Timer()
    var tag_value = Int()
    var currentAudioMsgID = String()
    var isAudioRecord = false
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
     */
    var tag12: IndexPath!
    var audioduration = ""


    //@IBOutlet weak var micButton: UIButton!
    var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TableViewLoadAnimation(0)
        self.view.addSubview(indicatorView)
        self.stackViewBottomConst.constant = 10
        //        self.textView.textAlignment = .
        self.configUI()
    }
 
    func changeIntoLTR() {
        self.sendWholeView.semanticContentAttribute = .forceLeftToRight
        self.sendStackView.semanticContentAttribute = .forceLeftToRight
    }
    override func viewDidLayoutSubviews() {
        self.changeIntoLTR()
    }
    func configUI() {
        self.navigationController?.isNavigationBarHidden = false
        self.collectionView.isHidden = true
        self.smartReplyCollectionView.isHidden = true
        self.NavigationBarButtonItem()
        // MARK: Emoji and Giphy Addon
        Giphy.configure(apiKey: GIPHY_KEY)
      //  self.gifButton.isHidden = true

        // Block Message View
        self.blockView.isHidden = true
        self.blockLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "")
        self.bottomLoader.isHidden = true
        ADMIN_VIEW_MODEL.profileModel = nil
        // Init imagePicker
        self.imagePicker = ImagePicker(presentationController: self , delegate: self)
        // self.sendView.cornerViewMiniumRadius()
        self.sendButton.cornerMiniumRadius()
        
        // Register Tableview Cell
        self.tableView.register(UINib(nibName: "ChatSubTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatSubTableViewCell")
        self.tableView.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
            // MARK: Audio and Video Call Addon
        self.tableView.register(UINib(nibName: "CallTableViewCell", bundle: nil), forCellReuseIdentifier: "CallTableViewCell")
        
        
        self.tableView.estimatedRowHeight = 70.0  //Give an approximation here
        self.tableView.rowHeight = UITableView.automaticDimension

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Add RefreshController
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        self.sendButton.setImage(#imageLiteral(resourceName: "send_icon_24").imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        
        self.callTitleLabel.config(color: UIColor(named: "AppTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "do you want to make a video or audio call")
        self.audioCallTextLabel.config(color: UIColor(named: "AppTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "video")
        self.videoCallTextLabel.config(color: UIColor(named: "AppTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "audio")
        self.callView.cornerViewMiniumRadius()
        self.callView.isHidden = true

        // Message TextView
        self.textView.config(color: UIColor(named: "ThirdryTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "writemessage")
        self.isFound = true
        self.textView.addDoneButtonOnKeyboard()
        self.loadData()
        
        // Smart Reply
        self.smartReplyCollectionView.isHidden = true
        self.smartReplyCollectionView.register(UINib(nibName: "SmartReplyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SmartReplyCollectionViewCell")

        self.collectionView.register(UINib(nibName: "HomeFilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeFilterCollectionViewCell")
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        SocketIOManager.sharedInstance.connect(false)
        // Audio Message
        self.configRecordView()
        self.callView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.callViewAct)))
        
    }
    @objc func callViewAct() {
        self.callView.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        CURRENT_CHAT = ""
//        self.stopAudioPlayer()
//        self.timer.invalidate()
    }
    func configRecordView() {
        /*
        // MARK: Voice Message Addon
        self.recordButton.cornerMiniumRadius()
        recordButton.setImage(UIImage(named: "microphone")?.withRenderingMode(.alwaysTemplate), for: .normal)
        recordButton.tintColor = .white
        IS_AUDIO = true
        self.recordButton.isHidden = !IS_AUDIO
        self.recordView.isHidden = true
        self.sendButton.isHidden = true
        
        recorderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recorderView)
        recorderView.trailingAnchor.constraint(equalTo: recordView.trailingAnchor, constant: -15).isActive = true
        recorderView.leadingAnchor.constraint(equalTo: recordView.leadingAnchor, constant: 15).isActive = true
        recorderView.topAnchor.constraint(equalTo: recordView.topAnchor, constant: 0).isActive = true
        recorderView.bottomAnchor.constraint(equalTo: recordView.bottomAnchor, constant: 0).isActive = true
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            recorderView.isArabic = true
        }
        else {
            recorderView.isArabic = false
        }
        recorderView.isSoundEnabled = true
        
        self.recordButton.recordView = recorderView
        recorderView.delegate = self
        recorderView.slideToCancelArrowImage = nil
        recorderView.slideToCancelText = getLanguage["slide_cancel"] ?? "slide_cancel"
        recorderView.durationTimerColor = UIColor(named: "BlackColor") ?? .white
        recorderView.slideToCancelTextColor = UIColor(named: "BlackColor") ?? .white
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
            }
        } catch {
            // failed to record!
        }
         */
    }
     override var preferredStatusBarStyle : UIStatusBarStyle {
         return self.updateStatusBarStyle()
     }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        self.navigationController?.isNavigationBarHidden = false
        self.callView.isHidden = true
        CURRENT_CHAT = (ADMIN_VIEW_MODEL.profileModel?.result.fullName ?? "")
        
    }
     /*
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var newHeight = keyboardFrame.height
        if #available(iOS 11.0, *) {
            newHeight = keyboardFrame.height - view.safeAreaInsets.bottom
//            newHeight = keyboardFrame.height - view.safeAreaInsets.bottom + 10
        } else {
            newHeight = keyboardFrame.height
//            newHeight = keyboardFrame.height + 10
        }
        wholeStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wholeStackView.topAnchor.constraint(equalTo: view.topAnchor),
            wholeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wholeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wholeStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: newHeight)
        ])
        
//        self.stackViewBottomConst.constant = newHeight
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            if !self.refreshControl.isRefreshing {
                
                     self.tableView.reloadData()
            
                self.changeIntoLTR()
                DispatchQueue.main.async {
                    if self.chatModelArray.count > 1 {
                        self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                        self.view.layoutIfNeeded()
                    }
                }
            }
            
        })
        print(self.stackViewBottomConst.constant)
        self.viewDidLayoutSubviews()
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        self.stackViewBottomConst.constant = 10
        print(self.stackViewBottomConst.constant)
        DispatchQueue.main.async {
            
                self.tableView.reloadData()
            
            self.changeIntoLTR()
            if (self.chatModelArray.count - 1) > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
            }
        }
    }
      */
     
     @objc func keyboardWillShow(sender: NSNotification) {
         guard let info = sender.userInfo,
               let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

         var newHeight = keyboardFrame.height
         if #available(iOS 11.0, *) {
             newHeight -= view.safeAreaInsets.bottom
         }

         // ✅ Use the existing IBOutlet constraint
         stackViewBottomConst.constant = newHeight

         UIView.animate(withDuration: 0.3) {
             self.view.layoutIfNeeded()
         }

         DispatchQueue.main.async {
             if self.chatModelArray.count > 1 {
                 self.tableView.scrollToRow(
                     at: IndexPath(row: self.chatModelArray.count - 1, section: 0),
                     at: .bottom,
                     animated: false
                 )
             }
         }
     }

     @objc func keyboardWillHide(sender: NSNotification) {
         self.stackViewBottomConst.constant = 10
         print(self.stackViewBottomConst.constant)
         DispatchQueue.main.async {
             
                 self.tableView.reloadData()
             
             self.changeIntoLTR()
             if (self.chatModelArray.count - 1) > 0 {
                 self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
             }
         }
     }

    func NavigationBarButtonItem() {
        // Back Button in NavigationBar
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "detail_back"), for: UIControl.State.normal)
        button.tintColor = UIColor(named: "whitecolor")
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.tag = 0
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        }
        else {
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        }
        
        button.addTarget(self, action: #selector(self.leftBarButtonAct(_:)), for: .touchUpInside)
        // User Image
        let button1: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button1.contentMode = .scaleAspectFit
        button1.imageView?.contentMode = .scaleAspectFill
        button1.setImage(#imageLiteral(resourceName: "applogo"), for: .normal)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "applogo"))
        button1.widthAnchor.constraint(equalToConstant: 35).isActive = true
        button1.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        print("image checking 1 \(ADMIN_VIEW_MODEL.profileModel?.result.userImg)")
        imageView.sd_setImage(with: URL(string: ADMIN_VIEW_MODEL.profileModel?.result.userImg ?? ""), placeholderImage: #imageLiteral(resourceName: "applogo")) { (image, error, cache, url) in
            print("image checking 2 \(image)")
            button1.setImage((image ?? #imageLiteral(resourceName: "applogo")), for: .normal)
            
        }
        button1.layer.cornerRadius = 17.5
        button1.clipsToBounds = true
        button1.tag = 1
        button1.addTarget(self, action: #selector(self.leftBarButtonAct(_:)), for: .touchUpInside)
        
        // User Name
        let button2: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button2.titleLabel?.lineBreakMode = .byTruncatingTail
        button2.titleLabel?.font = UIFont(name: APP_FONT_REGULAR, size: 16) ?? UIFont.systemFont(ofSize: 14)
        let fullName = ADMIN_VIEW_MODEL.profileModel?.result.fullName ?? ""
        let truncatedFullName = truncateText(fullName, maxLength: 20)
        button2.setTitle(truncatedFullName, for: .normal)
        
//        button2.setTitle((ADMIN_VIEW_MODEL.profileModel?.result.fullName ?? ""), for: .normal)
        print("name\(ADMIN_VIEW_MODEL.profileModel?.result.fullName)")
        CURRENT_CHAT = (ADMIN_VIEW_MODEL.profileModel?.result.fullName ?? "")
       
        button2.tag = 2
        button2.addTarget(self, action: #selector(self.leftBarButtonAct(_:)), for: .touchUpInside)
        
        button2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        // Add Left bar Button Items
        let stackview = UIStackView.init(arrangedSubviews: [button,button1, button2])
        stackview.distribution = .equalSpacing
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 8
        stackview.semanticContentAttribute = .forceLeftToRight
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: stackview)
       
        
    }
    func rightBarButtonItem() {
        // More Button
        let rbutton: UIButton = UIButton(type: UIButton.ButtonType.custom)
        rbutton.setImage(#imageLiteral(resourceName: "option"), for: UIControl.State.normal)
        rbutton.tintColor = UIColor(named: "whitecolor")
        rbutton.frame = CGRect(x: (self.view.frame.size.width - 30), y: 0, width: 12, height: 20)
        rbutton.tag = 0
        rbutton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        rbutton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        
        rbutton.addTarget(self, action: #selector(self.rightBarButtonTabbed), for: .touchUpInside)
        rbutton.imageView?.contentMode = .scaleAspectFit
        // MARK: Chat Transaltion Addon
        /*
        let rbutton1: UIButton = UIButton(type: UIButton.ButtonType.custom)
        rbutton1.setImage(#imageLiteral(resourceName: "chat_translate-3").imageFlippedForRightToLeftLayoutDirection(), for: UIControl.State.normal)
        rbutton1.tintColor = UIColor(named: "whitecolor")
        rbutton1.frame = CGRect(x: (self.view.frame.size.width - 75), y: 0, width: 12, height: 20)
        rbutton1.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        rbutton1.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        
        rbutton1.tag = 1
        rbutton1.addTarget(self, action: #selector(self.rightBarButtonTabbed), for: .touchUpInside)
        */
        
        // MARK: Audio and Vide Call ADDONS
        
        
        
        let rbutton2: UIButton = UIButton(type: UIButton.ButtonType.custom)
        rbutton2.setImage(#imageLiteral(resourceName: "phone-call"), for: UIControl.State.normal)
        rbutton2.tintColor = UIColor(named: "whitecolor")
        rbutton2.frame = CGRect(x: (self.view.frame.size.width - 150), y: 0, width: 12, height: 20)
        rbutton2.tag = 2
        rbutton2.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        
        rbutton2.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        rbutton2.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        
        rbutton2.addTarget(self, action: #selector(self.rightBarButtonTabbed), for: .touchUpInside)
        
        
        // Chat Translate ADDONS
        let rbutton3: UIButton = UIButton(type: UIButton.ButtonType.custom)
        rbutton3.setImage(#imageLiteral(resourceName: "carrier_call"), for: UIControl.State.normal)
        rbutton3.tintColor = UIColor(named: "whitecolor")
        rbutton3.frame = CGRect(x: (self.view.frame.size.width - 150), y: 0, width: 12, height: 20)
        rbutton3.tag = 3
        rbutton3.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        
        rbutton3.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        rbutton3.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        
        rbutton3.addTarget(self, action: #selector(self.rightBarButtonTabbed), for: .touchUpInside)
        if ((ADMIN_VIEW_MODEL.profileModel?.result.mobileNo ?? "") != "") && (ADMIN_VIEW_MODEL.profileModel?.result.showMobileNo ?? false) {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rbutton),  UIBarButtonItem(customView: rbutton3)]
           // self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rbutton), UIBarButtonItem(customView: rbutton2), UIBarButtonItem(customView: rbutton3)]

        }
        else {
            //self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rbutton), UIBarButtonItem(customView: rbutton2)]
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rbutton)]
        }
        let stackview = UIStackView.init(arrangedSubviews: [rbutton2,rbutton])
        stackview.distribution = .equalSpacing
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 10

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackview)
        
    }
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    @objc func rightBarButtonTabbed(_ sender: UIButton) {
        
//        if let recorder = audioRecorder, recorder.isRecording {
//            return
//        }
//        else {
            if sender.tag == 0 {
                // More Button Act
                var blockTitle = ""
                if (self.blockedByMe) {
                    blockTitle = "unblock_user"
                }
                else {
                    blockTitle = "block_user"
                }
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: getLanguage["safety_tips"] ?? "", style: .default, handler: { (UIAlertAction) in
                    let pageObj = HelpViewController()
                    pageObj.viewType = "safety_tips"
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }))
                if !(self.block) {
                    alert.addAction(UIAlertAction(title: getLanguage[blockTitle] ?? "", style: .default, handler: { (UIAlertAction) in
                        self.blockAct()
                    }))
                }
                
                alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else if sender.tag == 1 {
                // MARK: Translation
                /*
                let pageObj = TranslateViewController()
                pageObj.refreshPage = { (_ refresh: Bool) in
                    if refresh {
                        self.tableView.reloadData()
                        self.changeIntoLTR()
                    }
                }
                self.navigationController?.pushViewController(pageObj, animated: true)
                 */
            }
            else if sender.tag == 2{
                if !self.blockView.isHidden {
                    let alert = UIAlertController(title: nil, message: getLanguage["chat_block_message"] ?? "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    if self.callView.isHidden {
                        self.view.endEditing(true)
                        self.callView.isHidden = false
                    }
                    else {
                        self.view.endEditing(false)
                        self.callView.isHidden = true
                    }
                }
                
            }
            else if sender.tag == 3 {
                // Call Button Act
                if (ADMIN_VIEW_MODEL.profileModel?.result.mobileNo ?? "") != "" && self.blockView.isHidden{
                    if (self.block) {
                        let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: self.blockLabel.text!, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        if let callUrl = URL(string: "telprompt://+\(ADMIN_VIEW_MODEL.profileModel?.result.mobileNo ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), UIApplication.shared.canOpenURL(callUrl) {
                            UIApplication.shared.open(callUrl, options: [:], completionHandler: nil)
                        }
                        else {
                        }
                    }
                }
                else {
                    if !self.blockView.isHidden {
                        let alert = UIAlertController(title: nil, message: getLanguage["chat_block_message"] ?? "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
//        }
        
    }
    
    
    @IBAction func callButtonAct(_ sender: UIButton) {
//        stopAudioPlayer()
        let random_id = Utility.shared.random()
        let pageobj = CallViewController()
        pageobj.receiverId =  self.receiverId
        pageobj.receiverName = (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? "")
        pageobj.receiverImage = (ADMIN_VIEW_MODEL.profileModel?.result.userImg ?? "")
        pageobj.random_id = random_id
        pageobj.chatId = self.chatId
        pageobj.senderFlag = true
        pageobj.call_type = sender == videoCallButton ? "video" : "audio"
        pageobj.modalPresentationStyle = .fullScreen
        self.present(pageobj, animated: true, completion: nil)
    }
    @objc func cancelButtonTapped(){
        self.callView.isHidden = true
    }
    func blockAct() {
        if (self.blockedByMe) {
            self.blockUnBlockAct(type: "unblock")
        }
        else {
            let alert = UIAlertController(title: nil, message: getLanguage["block_msg"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["block"] ?? "block", style: .default, handler: { (UIAlertAction) in
               
                self.blockUnBlockAct(type: "block")
                
            }))
            alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
     func truncateText(_ text: String, maxLength: Int) -> String {
         if text.count > maxLength {
             let index = text.index(text.startIndex, offsetBy: maxLength)
             return text[..<index] + "..."
         } else {
             return text
         }
     }
    func blockUnBlockAct(type: String) {

        Utility.shared.startAnimation(viewController: self)
        self.viewModel.chatActionData(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), action_id: self.receiverId, action_value: type, onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            if (self.blockedByMe) {
                
                self.blockedByMe = false
                self.blockView.isHidden = true
                self.collectionView.isHidden = false
                self.loadSmartReply()
                self.sendWholeView.isHidden = false
                
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    @objc func leftBarButtonAct(_ sender: UIButton) {
        if sender.tag == 0 {
            // Back Button Act
            debugPrint("BackAct")
            self.navigationController?.popViewController(animated: true)
        }
        else {
            debugPrint("UserProfileAct")
            // User Image Act
            let pageObj = ViewProfileViewController()
            pageObj.userId = self.receiverId
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
    }
    func loadAdminProfileData() {
        
    }
    func loadData() {
        //solai
        let source_id = (isfromtype == "story") ? (self.itemDetailsvideo?.id ?? 0) : (self.itemDetails?.id ?? 0)
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.getChatData(sender_id:
                                    (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: self.receiverId, type: "normal", source_id: "\(source_id ?? 0)", offset: "0", limit: "20", onSuccess: { (success) in
            print("chkingpur", self.viewModel.chatModel?.status ?? false)
                                        if success {
                                            if self.offSet == 0 {
                                                self.chatModelArray.removeAll()
                                            }
                                            self.chatModelArray = self.viewModel.chatModel?.chats ?? [ChildChatModel]()
                                            self.isFound = false
                                        }
                                        self.block = self.viewModel.chatModel?.block ?? false
                                        print("muthukumar:\(self.block)")
                                        self.blockedByMe = self.viewModel.chatModel?.blockedByMe ?? false
                                        self.updateBlockView()
                                        Utility.shared.stopAnimation(viewController: self)
                                        if self.offSet == 0 {
                                            self.isFound = false
                                        }
                                        
                                        self.tableView.reloadData()
                                        
                                        self.changeIntoLTR()
                                        self.loadSmartReply()
                                        DispatchQueue.main.async {
                                            if (self.chatModelArray.count - 1) > 0 {
                                                self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                                            }
                                        }
                                    }, onFailure: { (failure) in
                                        Utility.shared.stopAnimation(viewController: self)
                                    })
        ADMIN_VIEW_MODEL.getProfileData(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), user_name: "",profile_id: self.receiverId, onSuccess: { (success) in
           // self.receiverId
            self.NavigationBarButtonItem()
            self.rightBarButtonItem()
            self.updateBlockView()
            
            SocketIOManager.sharedInstance.delegate = self
        }) { (failure) in
        }
        
    }
    func updateBlockView() {
        self.blockView.isHidden = true
        if (self.block || self.blockedByMe) {
            self.sendWholeView.isHidden = true
            self.collectionView.isHidden = true
            self.smartReplyCollectionView.isHidden = true
            self.blockView.isHidden = false
            self.blockLabel.text = (self.block) == true ? (getLanguage["other_block"] ?? "") : (getLanguage["youf_block"] ?? "")
        }
        else {
            self.collectionView.isHidden = false
            self.sendWholeView.isHidden = false
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func loadSmartReply() {
        self.smartReplyCollectionView.isHidden = true
        /*
        if IS_SMART_REPLY {
            smartReplyArray.removeAll()
            let userID = "\(UserDefaultModule.shared.getUserData()?.userName ?? "")"
            if userID != "\(chatModelArray.last?.sender ?? "")" {
                let message = TextMessage(text: "\(chatModelArray.last?.message.message ?? "")", timestamp: Date().timeIntervalSince1970, userID: "userId", isLocalUser: false)
                SmartReply.smartReply().suggestReplies(for: [message]) { result, error in
                    guard error == nil, let result = result else {
                        return
                    }
                    if (result.status == .notSupportedLanguage) {
                        // The conversation's language isn't supported, so
                        // the result doesn't contain any suggestions.
                    }
                    else if (result.status == .success) {
                        self.smartReplyArray = result.suggestions
                        if self.smartReplyArray.count > 0 {
                            self.smartReplyCollectionView.isHidden = !self.blockView.isHidden
                            DispatchQueue.main.async {
                                self.smartReplyCollectionView.reloadData()
                                if (self.chatModelArray.count - 1) > 0 {
                                    self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                                }
                            }
                        }
                        // Successfully suggested smart replies.
                        // ...
                    }
                }
                
            }
        }
  */
    }
    @IBAction func gifBtnAct(_ sender: UIButton) {
        let giphy = GiphyViewController()
        GiphyViewController.trayHeightMultiplier = 0.7
        giphy.shouldLocalizeSearch = true
        giphy.delegate = self
        giphy.dimBackground = true
        // Detect current system appearance
        if UserDefaultModule.shared.getTheme() == "Dark"{
            giphy.theme = GPHTheme(type: .dark)
        } else {
            giphy.theme = GPHTheme(type: .light)
        }
        giphy.mediaTypeConfig = [.emoji, .gifs, .stickers, .text]
        giphy.modalPresentationStyle = .overCurrentContext
        present(giphy, animated: true, completion: nil)
    }

    
    @IBAction func chatButtonAct(_ sender: UIButton) {
//        if sender == attachmentButton {
//            self.view.endEditing(true)
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            if let action = self.imagePicker.action(for: .camera, title: getLanguage["Take photo"] ?? "") {
//                alertController.addAction(action)
//            }
//            if let action = self.imagePicker.action(for: .photoLibrary, title: getLanguage["Photo library"] ?? "") {
//                alertController.addAction(action)
//            }
//            
//            alertController.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "cancel", style: .cancel, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
//        }
        
        if sender == attachmentButton {
            self.view.endEditing(true)
               let options = PHFetchOptions()
               options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
               options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
               self.videoFetchResult = PHAsset.fetchAssets(with: .video, options: options)
               PHPhotoLibrary.shared().register(self)
            self.imagePicker.present(from: sender)
            
//            imagePicker.presentPhotoLibrary(from: sender, fetchOptions: fetchOptions)
        }


        else if sender == locationButton {
//            let pageObj = LocationViewController()
//            pageObj.delegate = self
//            pageObj.viewType = "chat"
//            self.navigationController?.pushViewController(pageObj, animated: true)
            
            // MARK: Mabbox Addon
            
            let pageObj = MapViewController()
            pageObj.delegate = self
            pageObj.viewType = "chat"
            self.navigationController?.pushViewController(pageObj, animated: true)
  
        }
        else {
            if self.textView.tag != 0 && self.textView.text != ""{
                
                let id = (isfromtype == "story") ? (self.itemDetailsvideo?.id ?? 0) : (self.itemDetails?.id ?? 0)
                self.sendChat(message: self.textView.text!, current_latitude: "", current_longitude: "", image_url: "", source_id: self.isFromItemDetails ? "\(id ?? 0)" : "", type: "normal", viewUrl: "", message_content: "1")
            }
            else {
                let alert = UIAlertController(title: nil, message: getLanguage["type_your_message"] ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func sendChat(message: String,  current_latitude: String, current_longitude: String, image_url: String, source_id: String, type: String, viewUrl: String, audioDuration: String = "", message_content: String = "1") {
        SocketIOManager.sharedInstance.messageTyping(message: "untype", senderId: (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? ""), exchage_type: false)
        let timeStamp = Date().timeIntervalSince1970
        self.smartReplyCollectionView.isHidden = true
        self.textView.text = ""
        // self.textViewDidChange(self.textView)
        // self.textViewHeightConst.constant = 45
        // self.textViewHeightConst.priority = .defaultHigh
        var typeVal = type
        if type == "normal"{
            typeVal = isFromItemDetails == true ? "about" : "normal"
        }
        self.isFromItemDetails = false
        //        self.itemDetails?.id = nil
        let messageVal = MessageModel(chatTime: (Int(timeStamp)), imageName: image_url, message: message, userImage: ADMIN_VIEW_MODEL.profileModel?.result.userImg ?? "", userName: ADMIN_VIEW_MODEL.profileModel?.result.userName ?? "", uploadImage: image_url, latitude:current_latitude, longitude: current_longitude, uploadAudio:viewUrl, image_url: "")
        let photourl = (isfromtype == "story") ? (self.itemDetailsvideo?.photos.first?.itemUrlMain350 ?? "") : (self.itemDetails?.photos.first?.itemUrlMain350 ?? "")
        let itemTitle = (isfromtype == "story") ? (self.itemDetailsvideo?.itemTitle ?? "") : (self.itemDetails?.itemTitle ?? "")
                                                                            
        let chatModel = ChildChatModel(type: typeVal, receiver: (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? ""), sender: (UserDefaultModule.shared.getUserData()?.userName ?? ""), message: messageVal, sourceID: source_id, itemImage: photourl, itemTitle: itemTitle, audioDuration: audioDuration)
        self.chatModelArray.append(chatModel)
        
        self.tableView.reloadData()
        
        self.changeIntoLTR()
        DispatchQueue.main.async {
            SocketIOManager.sharedInstance.messageTyping(message: "untype", senderId: (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? ""), exchage_type: false)
            if (self.chatModelArray.count - 1) > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
            }
        }
        
        SocketIOManager.sharedInstance.chatMessage(message: message, userImage: (ADMIN_VIEW_MODEL.profileModel?.result.userImg ?? ""), userName: (UserDefaultModule.shared.getUserData()?.userName ?? ""), type: type, messageContent: message_content, lat: current_latitude, lon: current_longitude, view_url: image_url, offerId: "0", senderId: (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? ""), exchage_type: false, chatTime: (Int(timeStamp)), audio_duration: audioDuration, chatURL: self.viewModel.chatModel?.chatUrl ?? "")
      
        self.viewModel.sendChatData(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), chat_id: self.chatId, type: type, message: message, source_id: source_id, current_latitude: current_latitude, current_longitude: current_longitude, image_url: viewUrl, chat_type: "normal", timeStamp: (Int(timeStamp)), audio_url: image_url, created_date: "", audio_duration: audioDuration,onSuccess:{ (success) in
            if success {
               
            }
        }) { (failure) in
        }
        
    }
     
 }
 extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatModelArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = self.chatModelArray[indexPath.row]
        //   AudioTableViewCell
        /*
        if self.chatModelArray[indexPath.row].type == "audio_msg" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell") as! AudioTableViewCell
            cell.semanticContentAttribute = .forceLeftToRight
            cell.playBtn.setTitle(self.chatModelArray[indexPath.row].message.uploadAudio, for: .normal)
            if self.chatModelArray.count > indexPath.row {
                cell.loadData(chatModel: self.chatModelArray[indexPath.row])
            }
            cell.playBtn.tag = (indexPath.section * 10000) + indexPath.row
            cell.playBtn.addTarget(self, action: #selector(self.playAudio(_:)), for: .touchUpInside)
                cell.progressSlider.tag = (indexPath.section * 10000) + indexPath.row
                cell.progressSlider.addTarget(self, action: #selector(sliderAct(_:)), for: .valueChanged)
                let timeArray = (self.chatModelArray[indexPath.row].audioDuration ?? "").components(separatedBy: ":")
                if timeArray.count >= 2 {
                    let min = (Int(timeArray.first ?? "") ?? 0)*60
                    let sec = (Int(timeArray.last ?? "") ?? 0)
                    let total=min+sec
                    cell.progressSlider.maximumValue = Float(total)
                }
//                cell.progressSlider.clipsToBounds = true
                cell.progressSlider.minimumValue = 0
            cell.durationLbl.text = self.chatModelArray[indexPath.row].audioDuration
            if (self.chatModelArray[indexPath.row].audioDuration ?? "") == "" {
                cell.durationLbl.text = "00:00"
            }
            print("duration \(self.chatModelArray[indexPath.row].audioDuration ?? "")")
            cell.playBtn.isHidden = false
            cell.selectedBackgroundView?.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            if self.chatModelArray[indexPath.row].sender == (UserDefaultModule.shared.getUserData()?.userName ?? "") {
                cell.playBtn.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
            }
            return cell
            
        }
        */
    
         if self.chatModelArray[indexPath.row].type == "audio" || self.chatModelArray[indexPath.row].type == "video" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CallTableViewCell") as! CallTableViewCell
            if self.chatModelArray.count > indexPath.row {
                cell.loadData(chatModel: self.chatModelArray[indexPath.row])
            }
            cell.semanticContentAttribute = .forceLeftToRight
            return cell
        }
         
         
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSubTableViewCell") as! ChatSubTableViewCell
            cell.semanticContentAttribute = .forceLeftToRight
            cell.languageButton.tag = indexPath.row
            cell.acceptButton.addTarget(self, action: #selector(acceptButtonAct), for: .touchUpInside)
            cell.declineButton.addTarget(self, action: #selector(declineButtonAct(_:)), for: .touchUpInside)
            cell.buyNowButton.addTarget(self, action: #selector(buynowButtonAct), for: .touchUpInside)
            cell.acceptButton.tag = indexPath.row
            cell.declineButton.tag = indexPath.row
            cell.buyNowButton.tag = indexPath.row
        
            if self.chatModelArray.count > indexPath.row {
                cell.loadData(chatModel: self.chatModelArray[indexPath.row])
            }
        
            cell.listImageView.tag = indexPath.row
            cell.listImageView.isUserInteractionEnabled = true
            cell.listImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.listImageAct(_:))))
            cell.refreshChat = {
                self.tableView.beginUpdates()
                if self.chatModelArray.count > 1{
                    self.chatModelArray[indexPath.row].message.message = cell.messageLabel.text!
                }
                self.tableView.endUpdates()
            }
            cell.languageButton.isHidden = true
            /*
            if self.chatModelArray[indexPath.row].sender != (UserDefaultModule.shared.getUserData()?.userName ?? "") {
                if SwiftGoogleTranslate.shared.selectdLanguage.language.lowercased() == "none"  || SwiftGoogleTranslate.shared.selectdLanguage.language.lowercased() == "" {
                    cell.languageButton.isHidden = true
                }
            }
            */
            return cell
       }
    }
    
    @objc func sliderAct(_ sender: UISlider) {
        /*
        let currentValue: Float = Float(sender.value)
        if self.tag_value == sender.tag {
            audioPlayer.currentTime = TimeInterval(currentValue)
        }
  */
    }
    @objc func listImageAct(_ sender: UITapGestureRecognizer) {
        let chatModel = self.chatModelArray[sender.view?.tag ?? 0]
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.searchItemData(item_id: "\(chatModel.itemId ?? "0")", user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            if success {
                for i in  self.viewModel.itemModel?.result.items ?? [] {
                    if i.product_type == "video"{
                        let view = StoryAllList()
                        view.user_Img = i.sellerImg ?? ""
                        view.hts_product_id = "\(i.id ?? 0)"
                        view.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                        view.type = "after"
                        view.fromNav = "chat"
                        view.page_type = "chat"
                        view.videoID = i.stream_id ?? ""
                        self.navigationController?.pushViewController(view, animated: true)
                    }else{
                        if let itemModel = self.viewModel.itemModel?.result.items.first {
                            let pageObj = ItemDetailsViewController()
                            pageObj.itemDetails = itemModel
                            self.delegate.navigationController.pushViewController(pageObj, animated: true)
                        }
                    }
                }
                
                
            
            }
            
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.chatModelArray.count > indexPath.row {
            let chatModel = self.chatModelArray[indexPath.row]
            if chatModel.type == "share_location" {
               if let url = URL(string: "http://maps.google.com/?saddr=\(self.delegate.currentLocation?.location?.coordinate.latitude ?? 0),\(self.delegate.currentLocation?.location?.coordinate.longitude ?? 0)&daddr=\(chatModel.message.latitude ?? ""),\(chatModel.message.longitude ?? "")&directionsmode=driving") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
              /*
                let pageObj = MapViewController()
                pageObj.viewType = "visit"
                pageObj.lat = chatModel.message.latitude
                pageObj.long = chatModel.message.longitude ?? ""
                self.navigationController?.pushViewController(pageObj, animated: true)
               */
               
            }
            else if chatModel.type == "image" {
                let fullScreenController = FullScreenSlideshowViewController()
                var imageSource = [SDWebImageSource]()
                
                imageSource.append(SDWebImageSource(urlString: chatModel.message.uploadImage ?? "", placeholder: #imageLiteral(resourceName: "profilelogo"))!)
                fullScreenController.backgroundColor = UIColor(white: 0, alpha: 0.7)
                fullScreenController.closeButton.setImage(#imageLiteral(resourceName: "takeclose"), for: .normal)
                fullScreenController.closeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                fullScreenController.closeButton.tintColor = .black
                fullScreenController.inputs = imageSource
                fullScreenController.initialPage = indexPath.row
                
                fullScreenController.slideshow.currentPageChanged = { [weak self] page in
                    if let cell = tableView.cellForRow(at: indexPath) as? ChatSubTableViewCell, let imageView = cell.chatImageView {
                        self?.slideshowTransitioningDelegate?.referenceImageView = imageView
                    }
                }
                present(fullScreenController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func buynowButtonAct(_ sender: UIButton) {
        let index = sender.tag
        let chatModel = chatModelArray[index]
        if self.blockView.isHidden {
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.searchItemData(item_id: chatModel.itemId ?? "", user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), onSuccess: { (success) in
                if success {
                    if let itemModel = self.viewModel.itemModel?.result.items.first {
                        if itemModel.itemApprove ?? "0" == "0" {
                            Utility.shared.stopAnimation(viewController: self)
                            let alert = UIAlertController(title: nil, message: getLanguage["Product waiting for admin approval"] ?? "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            if itemModel.itemStatus == "onsale" {
                                itemModel.formattedPrice = chatModel.formattedOfferPrice
                                itemModel.formattedTotalPrice = chatModel.formattedTotalOfferPrice
                                itemModel.formattedShippingCost = chatModel.formattedShippingPrice
                                self.itemDetails = itemModel
                                self.loadAddressData(chatModel: chatModel)
                            }
                            else {
                                Utility.shared.stopAnimation(viewController: self)
                                
                                let alert = UIAlertController(title: nil, message: getLanguage["product_has_been_soldout_unexpectedly"] ?? "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    
                }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
    }
    func loadAddressData(chatModel: ChildChatModel) {
        //Buynow addons start

        let addressModel = AddressViewModel()
        addressModel.getShippingAddressAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), item_id: "\(self.itemDetails?.id ?? 0)", onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            if !success {
                let pageObj = AddressViewController()
                pageObj.itemDetails = self.itemDetails
                pageObj.viewType = 1
                pageObj.offerPayment = true
                pageObj.offerPrice = chatModel.offerPrice
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
            else {
                if addressModel.addressListModel?.result.count ?? 0 == 1 {
                    let pageObj = BuyNowViewController()
                    pageObj.addressDetails = addressModel.addressListModel?.result.first
                    pageObj.itemDetails = self.itemDetails
                    pageObj.offerPayment = true
                    pageObj.offerPrice = chatModel.offerPrice
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
                else {
                    let pageObj = AddressListViewController()
                    pageObj.isFromItemDetails = true
                    pageObj.itemDetails = self.itemDetails
                    pageObj.offerPayment = true
                    pageObj.offerPrice = chatModel.offerPrice
                    
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
            }
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
          
    }
    @objc func acceptButtonAct(_ sender: UIButton) {
        let index = sender.tag
        if self.blockView.isHidden {
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.offerStatusData(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), offer_id: "\(self.chatModelArray[index].offerId ?? 0)", status: "accept", chat_id: self.chatId, onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                self.loadData()
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
    }
    @objc func declineButtonAct(_ sender: UIButton) {
        let index = sender.tag
        if self.blockView.isHidden {
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.offerStatusData(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), offer_id: "\(self.chatModelArray[index].offerId ?? 0)", status: "decline", chat_id: self.chatId, onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                self.loadData()
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
    }
    func TableViewLoadAnimation(_ tag: Int) {
        self.scrollToBottom()
        if tag == 0 {
            self.bottomLoader.isHidden = true
            self.bottomLoader.stopAnimating()
        }
        else {
            self.bottomLoader.isHidden = false
            self.bottomLoader.startAnimating()
        }
    }
    func scrollToBottom(_ isFromLoadData: Bool = false) {
        DispatchQueue.main.async {
            if self.chatModelArray.count > 0 {
                let indexPath = IndexPath(
                    row: (self.chatModelArray.count-1),
                    section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                if isFromLoadData {
                    self.isFound = true
                }
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView && self.lastContentOffset > scrollView.contentOffset.y {
            let contentOffset = scrollView.contentOffset.y
            if contentOffset <= 50 && !self.isLoadingMore {
                self.isLoadingMore = true
                self.refreshControl.beginRefreshing()
                DispatchQueue.global(qos: .background).async {
                    self.offSet = self.chatModelArray.count
                    print("self.offSet\(self.offSet)")
                    let source_id = (self.isfromtype == "story") ? (self.itemDetailsvideo?.id ?? 0) : (self.itemDetails?.id ?? 0)
                    self.viewModel.getChatData(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: self.receiverId, type: "normal", source_id: "\(source_id ?? 0)", offset: "\(self.offSet)", limit: "20", onSuccess: { (success) in
                        if success {
                            if self.chatModelArray.count >= 20{
                                self.chatModelArray = ((self.viewModel.chatModel?.chats ?? [ChildChatModel]()) + self.chatModelArray)
                            }
                        }
                        self.refreshControl.endRefreshing()
                        
                        self.tableView.reloadData()
                        
//                        if (self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count > 0 {
//                            self.tableView.scrollToRow(at: IndexPath(row: ((self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count-1), section: 0), at: .top, animated: false)
//                        }
                        DispatchQueue.main.async {
                            if (self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count > 0 {
                                print("totalCount: \(self.chatModelArray.count) Perticular Count: \((self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count)")
                                if (self.chatModelArray.count) > ((self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count) {
                                    self.tableView.scrollToRow(at: IndexPath(row: ((self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count-1), section: 0), at: .top, animated: false)
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [weak self] in
                                self?.isLoadingMore = false
                            })
                        }
                    }, onFailure: { (failure) in
                        self.refreshControl.endRefreshing()
                    })
                }
            }
        }
    }
 }
 extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return (ADMIN_VIEW_MODEL.adminModel?.result.chatTemplate.count ?? 0)
        }
        else {
            return 0
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == self.collectionView {
            guard let cell: HomeFilterCollectionViewCell = Bundle.main.loadNibNamed("HomeFilterCollectionViewCell", owner: self,options: nil)?.first as? HomeFilterCollectionViewCell else {
                return CGSize.zero
            }
            cell.filterLabel.text = getLanguage[(ADMIN_VIEW_MODEL.adminModel?.result.chatTemplate[indexPath.row].name ?? "")] ?? (ADMIN_VIEW_MODEL.adminModel?.result.chatTemplate[indexPath.row].name ?? "")
            cell.cancelButton.isHidden = true
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            return CGSize(width: size.width, height: 50)
//        }
//        else {
//            guard let cell: SmartReplyCollectionViewCell = Bundle.main.loadNibNamed("SmartReplyCollectionViewCell", owner: self,options: nil)?.first as? SmartReplyCollectionViewCell else {
//                return CGSize.zero
//            }
//            cell.smartReplyLabel.text = self.smartReplyArray[indexPath.row].text
//            cell.setNeedsLayout()
//            cell.layoutIfNeeded()
//            let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//            return CGSize(width: size.width, height: 50)
//        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeFilterCollectionViewCell", for: indexPath) as! HomeFilterCollectionViewCell
            //            cell.hightConst.constant = 45
            cell.shadowView.cornerViewMiniumRadius()
            cell.isFromChat = true
            cell.shadowView.backgroundColor = UIColor(named: "AppThemeColorNew")
            cell.filterLabel.textColor = UIColor(named: "whitecolor")
            cell.filterLabel.text = getLanguage[(ADMIN_VIEW_MODEL.adminModel?.result.chatTemplate[indexPath.row].name ?? "")] ?? (ADMIN_VIEW_MODEL.adminModel?.result.chatTemplate[indexPath.row].name ?? "")
            cell.cancelButton.isHidden = true
            return cell
//        }
//        else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmartReplyCollectionViewCell", for: indexPath) as! SmartReplyCollectionViewCell
//            cell.smartReplyLabel.text = self.smartReplyArray[indexPath.row].text
//            return cell
//        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            
            let id = (isfromtype == "story") ? (self.itemDetailsvideo?.id ?? 0) : (self.itemDetails?.id ?? 0)
            self.sendChat(message: getLanguage[(ADMIN_VIEW_MODEL.adminModel?.result.chatTemplate[indexPath.row].name ?? "")] ?? (ADMIN_VIEW_MODEL.adminModel?.result.chatTemplate[indexPath.row].name ?? ""), current_latitude: "", current_longitude: "", image_url: "", source_id: self.isFromItemDetails ? "\(id ?? 0)" : "", type: "normal", viewUrl: "", message_content: "1")
        }
        else {
//            self.sendChat(message: getLanguage[self.smartReplyArray[indexPath.row].text] ?? self.smartReplyArray[indexPath.row].text, current_latitude: "", current_longitude: "", image_url: "", source_id: self.isFromItemDetails ? "\(self.itemDetails?.id ?? 0)" : "", type: "normal", viewUrl: "", message_content:"1")
        }
    }
 }
 extension ChatViewController: ImageDelegate {
    func didSelect(image: UIImage?) {
        self.navigationController?.isNavigationBarHidden = false
        
        if image != nil {
            DispatchQueue.main.async {
                if (self.chatModelArray.count - 1) > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                }
            }
            Utility.shared.startAnimation(viewController: self)
            CallParsingFunction().uploadImage(url: UPLOAD_IMAGE_URL, type: "chat", image: image, onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                DispatchQueue.main.async {
                    self.navigationController?.isNavigationBarHidden = false
                    self.sendChat(message: "", current_latitude: "", current_longitude: "", image_url: success["Image","View_url"].stringValue, source_id: "0", type: "image", viewUrl: success["Image","Name"].stringValue, message_content: "2")
                }
            }) { (failure) in
                
            }
        }
    }
    func convertToJSON(_ images: [String]) -> (String) {
        let data = try! JSONSerialization.data(withJSONObject: images, options:.prettyPrinted)
        let jsonStr  = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return (jsonStr ?? "")
    }
 }
//  extension ChatViewController: locationDelegate {
//     func locationAct(city: String, state: String, country: String,countryCode: String, lat: String, long: String, location: String) {
//          self.sendChat(message: "", current_latitude: lat, current_longitude: long, image_url: "", source_id: "", type: "share_location", viewUrl: "")
//      }
//  }
 extension ChatViewController: customLocationDelegate{
    func locationAct(city: String, state: String, country: String, countryCode: String,lat: String, long: String, location: String){
        print("lat \(lat), long \(lat)")
        self.sendChat(message: "", current_latitude: lat, current_longitude: long, image_url: "", source_id: "", type: "share_location", viewUrl: "", message_content: "3")
    }

 }
 // Text View Delegate
 extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        SocketIOManager.sharedInstance.messageTyping(message: "type", senderId: (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? ""), exchage_type: false)
        
        //         if textView.contentSize.height >= 100 {
        //             textView.isScrollEnabled = true
        //             self.textViewHeightConst.constant = textView.contentSize.height
        //             self.textViewHeightConst.priority = .defaultLow
        //         }
        //         else {
        //             textView.isScrollEnabled = false
        //             self.textViewHeightConst.constant = textView.contentSize.height
        //             self.textViewHeightConst.priority = .defaultLow
        //         }
        
        textViewAct(textView)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//                if text.containsEmoji {
//                    return false
//                }
        if textView.tag == 0 {
            textView.textColor = UIColor(named: "AppTextColor")
            textView.text = ""
            textView.tag = 1
        }
        if text == "\n" {
            if textView.text == "" {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewAct(textView)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        //        textViewAct(textView)
        textViewDidChange(textView)
        DispatchQueue.main.async {
            SocketIOManager.sharedInstance.messageTyping(message: "untype", senderId: (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? ""), exchage_type: false)
        }
        if textView.text == "" {
            textView.text = getLanguage["writemessage"]
            textView.textColor = UIColor(named: "ThirdryTextColor")
            textView.tag = 0
            self.sendButton.isHidden = IS_AUDIO
//            self.recordButton.isHidden = false
        }
    }
    func textViewAct(_ textView: UITextView) {
        if textView.tag == 0 {
            textView.textColor = UIColor(named: "AppTextColor")
            textView.text = ""
            textView.tag = 1
        }
        else if textView.isFirstResponder{
            if textView.text.count > 0 && textView.tag == 1{
                self.sendButton.isHidden = false
//                self.recordButton.isHidden = true
            }
        }
        else {
            if textView.text == "" && textView.tag == 1{
                //                textView.text = getLanguage["writemessage"]
                textView.textColor = UIColor(named: "ThirdryTextColor")
                textView.tag = 0
                self.sendButton.isHidden = IS_AUDIO
//                self.recordButton.isHidden = !IS_AUDIO
            }
            else {
                self.sendButton.isHidden = false
//                self.recordButton.isHidden = true
                textView.textColor = UIColor(named: "AppTextColor")
            }
        }
    }
 }
 extension ChatViewController: SocketDelegate {
   
    func getSocketInfo(dict:JSON, type: String) {
        if !(self.blockedByMe){
        // Load Data From Socket
        if type == "message" {
            if (dict["message","type"].stringValue) == "offer" {
                return
            }
            let messageVal = MessageModel(chatTime: (dict["message","chatTime"].intValue), imageName: (dict["message","userImage"].stringValue), message: (dict["message","message"].stringValue), userImage: (dict["message","userImage"].stringValue), userName: (dict["message","userName"].stringValue), uploadImage: (dict["message","view_url"].string ?? dict["message","item_image"].stringValue), latitude:(dict["message","lat"].stringValue), longitude: (dict["message","lon"].stringValue), uploadAudio:(dict["message","view_url"].string ?? dict["message","item_image"].stringValue), image_url: (dict["message","view_url"].string ?? dict["message","item_image"].stringValue))
            
            
            let chatModel = ChildChatModel(type: (dict["message","type"].stringValue), receiver: (UserDefaultModule.shared.getUserData()?.userName ?? ""), sender: (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? "") , message: messageVal, sourceID: (dict["message","offerId"].string ?? dict["message","offer_id"].stringValue), itemImage: (dict["message","view_url"].string ?? dict["message","item_image"].stringValue), itemTitle: (dict["message","view_url"].string ?? dict["message","item_image"].stringValue), audioDuration: "")
                
                

            
            // MARK: Chat Translation
            /*
            if SwiftGoogleTranslate.shared.selectdLanguage.language.lowercased() != "none" && SwiftGoogleTranslate.shared.selectdLanguage.language.lowercased() != "" {
                SwiftGoogleTranslate.shared.translate(msg: chatModel.message.message) { (message) in
                    if message != "error" {
                        chatModel.message.message = message
                        //                        data["message"] = message
                    }
                    DispatchQueue.main.async {
                        self.chatModelArray.append(chatModel)
                        self.tableView.reloadData()
                        DispatchQueue.main.async {
                            if (self.chatModelArray.count - 1) > 0 {
                                self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                            }
                        }
                    }
                }
            }
            else {
                self.chatModelArray.append(chatModel)
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    if (self.chatModelArray.count - 1) > 0 {
                        self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                    }
                }
            }
            */
            

            self.chatModelArray.append(chatModel)

            
            
            self.tableView.reloadData()
            
            DispatchQueue.main.async {
                if (self.chatModelArray.count - 1) > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                }
            }
            
            self.loadSmartReply()
        }
        else {
            if dict["message"].stringValue == "type"{
                self.bottomLoader.isHidden = false
                self.bottomLoader.startAnimating()
            }
            else {
                self.bottomLoader.stopAnimating()
                self.bottomLoader.isHidden = true
            }
        }
    }
//        self.loadSmartReply()
    }
    
 }
 // Add Ons Extension
 extension ChatViewController: JoyslaeAudioRecorderDelegate {
    func updateTimer(_ time: String) {
        //self.audioLabel.text = time
    }
 }
 
 extension ChatViewController: GiphyDelegate {
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        giphyViewController.dismiss(animated: true, completion: { [weak self] in
            let gifURL : String = media.url(rendition: .fixedWidth, fileType: .gif)!
            print(gifURL)
            //            self?.sendGif(gifURL)
            self?.sendChat(message: "", current_latitude: "", current_longitude: "", image_url: gifURL, source_id: "0", type: "gif", viewUrl: gifURL, message_content: "2")
            
            //            self?.uploadGif(url: gifURL)
        })
        GPHCache.shared.clear()
    }
    func didDismiss(controller: GiphyViewController?) {
        GPHCache.shared.clear()
    }
 }

 /*
 extension ChatViewController: RecordViewDelegate, AVAudioRecorderDelegate {
  func uploadAudioToServer(_ url : URL) {
      let audioFile = url
      guard let data = try? Data(contentsOf:audioFile) else { return }
      Utility.shared.startAnimation(viewController: self)
      CallParsingFunction().uploadAudio(url: UPLOAD_AUDIO_URL, type: "chat", audioData: data, onSuccess: { [self] (success) in
          if success["status"].boolValue {
              self.navigationController?.isNavigationBarHidden = false
              // self.micButton.isHidden = !VOICE_CHAT
              DispatchQueue.main.async {
                  self.tag12 = nil
                  _ = self.dowloadFile(audioString: success["Audio","View_url"].stringValue, message: "audiomsg")
              }
              self.sendChat(message: "", current_latitude: "", current_longitude: "", image_url: success["Audio","View_url"].stringValue, source_id: "0", type: "audio_msg", viewUrl: success["Audio","View_url"].stringValue, audioDuration: audioduration, message_content: "2")
          }
          
          Utility.shared.stopAnimation(viewController: self)
          self.tableView.reloadData()
          self.changeIntoLTR()
      }) { (failure) in
          Utility.shared.stopAnimation(viewController: self)
      }
  }
    func onStart() {
        print("onStart")
        self.stopAudioPlayer()
        isAudioRecord = true
        self.recordView.isHidden = false
        self.locationButton.isHidden = true
        self.attachmentButton.isHidden = true
        self.textView.isHidden = true
        self.gifButton.isHidden = true
        self.sendButton.isHidden = IS_AUDIO
        startRecording()
        
    }
    
    func onCancel() {
        tableView.isUserInteractionEnabled = true
        print("onCancel")
        isAudioRecord = false
        audioRecorder.stop()
        audioRecorder.deleteRecording()
        self.attachmentButton.isHidden = false
        self.textView.isHidden = false
        self.locationButton.isHidden = false
        self.gifButton.isHidden = false
        self.audioPlayer.stop()
        self.timer.invalidate()
    }
    
    func onFinished(duration: CGFloat) {
        print("onFinished")
        isAudioRecord = false
        if(duration > 0.09){
            self.recordView.isHidden = true
            self.attachmentButton.isHidden = false
            self.textView.isHidden = false
            self.locationButton.isHidden = false
            self.gifButton.isHidden = false
            let myIntValue = Int(duration)
            let min = myIntValue/60
            let sec = myIntValue%60
            var minstr="\(min)"
            var secstr="\(sec)"
            if(min<10){
                minstr = "0\(min)"
            }
            if(sec<10){
                secstr = "0\(sec)"
                
            }
            audioduration = minstr+":"+secstr
            finishRecording(success: false)
        }
        else{
            self.audioRecorder.stop()
            textView.resignFirstResponder()
            self.recordView.isHidden = true
            self.attachmentButton.isHidden = false
            self.textView.isHidden = false
            self.locationButton.isHidden = false
            self.sendButton.isHidden = IS_AUDIO
            self.recordButton.isHidden = false
            //            self.GifBtn.isHidden = false
            let alert = UIAlertController(title: getLanguage["alert"] ?? "alert", message: getLanguage["Hold to record, release to send."] ?? "Hold to record, release to send.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            tableView.isUserInteractionEnabled = true
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        do {
            print("recorder.url : \(recorder.url)")
            let audioData = try Data(contentsOf: recorder.url)
            print("REQUESTimgData : \(audioData)")
            let player = try AVAudioPlayer.init(data: audioData)
            DispatchQueue.main.async {
                if(player.duration > 0.09){
                    let requestDict = NSMutableDictionary()
                    requestDict.setValue(UserDefaultModule.shared.getUserData()?.user_id, forKey: "senderId")
                    requestDict.setValue("audio_msg", forKey: "chat_type")
                    requestDict.setValue(self.audioduration, forKey: "audio_duration")
                    SocketIOManager.sharedInstance.sendMsg(requestDict: requestDict)
                    self.uploadAudioToServer(recorder.url)
                }
                else {
                    self.audioRecorder.stop()
                }
            }
        } catch {
            print("Unable to load data: \(error)")
        }
    }
    func sendAudio(_ url: String) {
        // Send chat Act
        var data: [String: Any] = [:]
        data["chat_id"] = self.id
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = (Date().timeIntervalSince1970)
        let localDate = (epochDate + Double(timezoneOffset))
        data["date"] = localDate
        data["time"] = epochDate
        data["user_id"] = UserDefaultModule.shared.getUserData()?.user_id ?? ""
        let user_Image = self.viewModel.chatModel?.chats.first?.message
        data["user_image"] = user_Image?.userImage
        data["user_name"] = self.userName
        data["message"] = url
        data["audio_duration"] = self.audioduration
        data["chat_type"] = "audio"
        
        self.tableView.reloadData()
        self.changeIntoLTR()
        self.scrollToBottom()
    }
    
 }
 
 
 extension ChatViewController: AVAudioPlayerDelegate {
    func stopAudioPlayer() {

        if audioRecorder != nil {
            audioRecorder.stop()
        }

        if let cell = self.tableView.cellForRow(at: IndexPath(row: tag_value, section: 0)) as? AudioTableViewCell {
            cell.playBtn.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
            if audioPlayer != nil {
                audioPlayer.stop()
            }
            self.timer.invalidate()
//            cell.progressSlider.value = Float(0)//Float(audioPlayer.currentTime)
            //        cell1?.audioSlider counter = 0
        }

    }
    @objc func playAudio(_ sender: UIButton){
        if isAudioRecord{
            
        }else{
            DispatchQueue.main.async { [self] in
                print("sender title ======",sender.title(for: .normal) as Any)
                let column = sender.tag / 10000
                let row = sender.tag % 10000
                let indexPath = IndexPath.init(row: row, section: column)
                let cell = tableView.cellForRow(at: indexPath) as! AudioTableViewCell
                if let buttonTitle = sender.title(for: .normal) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if tag_value != sender.tag && counter != 0 {
                            stopAudioPlayer()
                        }
                        tag12 = indexPath
                        let wavtomp = buttonTitle.replacingOccurrences(of: " ", with: "")
                        print("wavtomp is =======",wavtomp)
                        
                        let urlstr = self.dowloadFile(audioString: wavtomp, message: "audiomsg")
                        let escapedString = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let audioURL = URL(string:escapedString!)
                        do {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: .mixWithOthers)
                            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                            try AVAudioSession.sharedInstance().setActive(true)
                            
                            let imageData = try Data(contentsOf: audioURL!)
                            audioPlayer = try AVAudioPlayer.init(data: imageData)
                            print("duration \(cell.progressSlider.value)")
                            currentAudioMsgID = urlstr
                        } catch {
                            print("Speaker error : \(error)")
                        }
                        //
                        print("play audio \(String(describing: audioURL))");
                        
                        audioPlayer.delegate = self
                        audioPlayer.volume = 10
                        if counter == 0 {
                            cell.loader.stopAnimating()
                            cell.playBtn.isHidden = false
                            cell.playBtn.setImage(UIImage.init(named: "pause2"), for: .normal)
                            //                        audioPlayer.prepareToPlay()
                            //                        self.chatDict[Key]?[indexPath.row].audioduration
                            print("Progress Val: \(cell.progressSlider.value)")
                            let currentValue: Float = Float(cell.progressSlider.value)
                            //                        cell.progressSlider.value = Float(audioPlayer.currentTime)
                            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer(_:)), userInfo: [cell.progressSlider.tag], repeats: true)
                            let shortStartDelay: TimeInterval = 0.01    // seconds
                            let now: TimeInterval = audioPlayer.deviceCurrentTime
                            let _: TimeInterval = now + TimeInterval(shortStartDelay)
                            audioPlayer.currentTime = TimeInterval(currentValue)
                            audioPlayer.play()
                            tag_value = sender.tag
                            counter = 1
                        }else{
                            if tag_value == sender.tag {
                                cell.loader.stopAnimating()
                                cell.playBtn.isHidden = false
                                audioPlayer.pause()
                                cell.playBtn.setImage(UIImage.init(named: "play-button"), for: .normal)
                                //                            cell.progressSlider.value = Float(audioPlayer.currentTime)
                                //                            cell.progressSlider.clipsToBounds = true
                                counter = 0
                            }else{
                                cell.loader.stopAnimating()
                                cell.playBtn.isHidden = false
                                //                            audioPlayer.prepareToPlay()
                                let currentValue: Float = Float(cell.progressSlider.value)
                                //                            audioPlayer.currentTime = TimeInterval(currentValue)
                                cell.playBtn.setImage(UIImage.init(named: "pause2"), for: .normal)
                                //                            cell.progressSlider.value = Float(audioPlayer.currentTime)
                                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUIWithTimer(_:)), userInfo: [cell.progressSlider.tag], repeats: true)
                                let now: TimeInterval = audioPlayer.deviceCurrentTime ?? 0
                                let timeDelayPlay: TimeInterval = now + TimeInterval(currentValue)
                                audioPlayer.currentTime = TimeInterval(currentValue)
                                audioPlayer.play()
                                tag_value = sender.tag
                                counter = 1
                            }
                        }
                    }
                }
            }
        }
    }
    @objc func updateUIWithTimer(_ timer: Timer){
        //            if info[0] as? Int ?? 0 == tag
        if tag12 != nil {
            print("Check player State")
            if audioPlayer.isPlaying {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: tag_value, section: 0)) as? AudioTableViewCell {
                    print("\(Float(audioPlayer.currentTime))")
//                    cell.progressSlider.setValue(Float(audioPlayer.currentTime), animated: true)
                    cell.progressSlider.value = Float(audioPlayer.currentTime)
                    print("\(cell.progressSlider.value)")

                    let myIntValue = Int(audioPlayer.currentTime)
                    let min = myIntValue/60
                    let sec = myIntValue%60
                    var minstr="\(min)"
                    var secstr="\(sec)"
                    if(min<10){
                        minstr = "0\(min)"
                    }
                    if(sec<10){
                        secstr = "0\(sec)"
                        
                    }
                    cell.durationLbl.text = minstr+":"+secstr
                    
                    if(audioPlayer.currentTime == audioPlayer.duration) {
                        print("stopTimer")
                        timer.invalidate()
                        //                timer = nil
                    }
                    audioPlayer.updateMeters()
//                    cell.progressSlider.clipsToBounds = true
                }
                
            }
            else {
                print("not Start Playing")
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("play done");
        timer.invalidate()
        counter = 0
        currentAudioMsgID = ""
        if let cell = self.tableView.cellForRow(at: IndexPath(row: tag_value, section: 0)) as? AudioTableViewCell {
            _ = cell.playBtn.tag / 10000
            let row = cell.playBtn.tag % 10000
            cell.playBtn.setImage(UIImage.init(named: "play-button"), for: .normal)
            self.tableView.reloadData()
            self.changeIntoLTR()
            cell.progressSlider.value = 0.0
            cell.durationLbl.text = self.chatModelArray[row].audioDuration
            tableView.isUserInteractionEnabled = true

        }
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("error playing \(String(describing: error?.localizedDescription))")
    }
    
    func onAnimationEnd() {
        self.recordView.isHidden = true
        //when Trash Animation is Finished
        print("onAnimationEnd")
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            tableView.isUserInteractionEnabled = false
//            NaviBarView.isUserInteractionEnabled = false
        } catch {
            finishRecording(success: false)
        }
    }
    func finishRecording(success: Bool) {
        tableView.isUserInteractionEnabled = true
        audioRecorder.stop()
        audioRecorder = nil
    }
    func dowloadFile(audioString:String, message: String) -> String {
        
        if let url = URL.init(string:audioString){
            
            // if let audioUrl = URL(string: "http://freetone.org/ring/stan/iPhone_5-Alarm.mp3") {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
            // Print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                // Print("The file already exists at path")
                return destinationUrl.absoluteString
                // if the file doesn't exist
            } else {
                if tag12 != nil {
                    if let cell = self.tableView.cellForRow(at: tag12) as? AudioTableViewCell {
                        cell.loader.startAnimating()
                        cell.playBtn.isHidden = true
                    }
                }

                // you can use NSURLSession.sharedSession to download the data asynchronously
                let group = DispatchGroup()
                group.enter()
                print("Hii")
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        group.leave()
                        // Print("File moved to documents folder \(destinationUrl)")
                    } catch let error as NSError {
                        group.leave()
                        print("localerror \(error)")
                    }
                }).resume()
                group.wait()
                print("Hello")
                return destinationUrl.absoluteString
            }
        }
        else {
            return ""
        }
    }
 }
  */
