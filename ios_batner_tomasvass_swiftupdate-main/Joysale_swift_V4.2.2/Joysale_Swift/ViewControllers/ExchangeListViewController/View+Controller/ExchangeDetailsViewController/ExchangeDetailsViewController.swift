 //
 //  ExchangeDetailsViewController.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 03/07/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import UIKit
 import NVActivityIndicatorView
 import SwiftyJSON
 import ImageSlideshow
 import SocketIO
 import AVFoundation
 import Contacts
 import ContactsUI
 import MobileCoreServices
 import Photos


 protocol ExchangeDetailsDelgate {
     func updateExchangeStatus(_ status: String)
 }
 class ExchangeDetailsViewController: UIViewController,PHPhotoLibraryChangeObserver {
     func photoLibraryDidChange(_ changeInstance: PHChange) {
         
     }
     @IBOutlet weak var textViewHeightConst: NSLayoutConstraint!
     @IBOutlet weak var sendStackView: UIStackView!
     @IBOutlet weak var bottomLoader: NVActivityIndicatorView!
     @IBOutlet weak var cancelButton: UIButton!
     @IBOutlet weak var acceptButton: UIButton!
     @IBOutlet weak var stackViewBottomConst: NSLayoutConstraint!
    
     @IBOutlet weak var messageStackView: UIStackView!
     @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var textView: UITextView!
     @IBOutlet weak var attachmentButton: UIButton!
     @IBOutlet weak var locationButton: UIButton!
     @IBOutlet weak var sendView: UIView!
     @IBOutlet weak var sendButton: UIButton!
     private var videoFetchResult: PHFetchResult<PHAsset>?
     var exchangeData: ExchangeListModel?
     var resModel = [ChatListResultModel]()
     var chatId = ""
     var receiverId = ""
     var imagePicker: ImagePicker!
     let callView = UIView()
     var isLoadingMore = false // flag
     private let refreshControl = UIRefreshControl()
     var lastContentOffset: CGFloat = 0
     var viewModel = ChatViewModel()
     var chatModelArray = [ChildChatModel]()
     var offSet = 0
     var exchangeDelgate: ExchangeDetailsDelgate?
     var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate? = nil
     let delegate = UIApplication.shared.delegate as! AppDelegate
    var contact_id = String()
    var recorder = JoysaleAudioRecorder.shared
  
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioduration = ""
    var selectedAudio = ""
    var audioPlayer = AVAudioPlayer()
    var timer = Timer()
    var counter = 0
    var imageString = ""
     
     override func viewDidLoad() {
         super.viewDidLoad()
         self.view.addSubview(indicatorView)
         self.configUI()
     }
     override var preferredStatusBarStyle : UIStatusBarStyle {
         return self.updateStatusBarStyle()
     }
     
     override func viewWillAppear(_ animated: Bool) {
         self.updateTheme(page: "present")
         self.navigationController?.isNavigationBarHidden = false
         NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
     }
     override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = false
         NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
         CURRENT_CHAT = ""
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
     func configUI() {
        self.acceptButton.config(color: UIColor(named: "green_color"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, title: "accept")
         self.cancelButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, title: "decline")
         self.textView.config(color: UIColor(named: "ThirdryTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "writemessage")
         self.tableView.register(UINib(nibName: "ChatSubTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatSubTableViewCell")
         self.navigationController?.isNavigationBarHidden = false
         self.imagePicker = ImagePicker(presentationController: self , delegate: self)
         self.navigationController?.NavigationBarWithBackButtonAndTitle(title: getLanguage["Exchange Details"] ?? "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
         self.sendView.cornerViewMiniumRadius()
         self.sendButton.cornerMiniumRadius()
         self.tableView.estimatedRowHeight = 70.0  //Give an approximation here
         self.textView.addDoneButtonOnKeyboard()
         self.tableView.rowHeight = UITableView.automaticDimension
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
         if #available(iOS 10.0, *) {
             self.tableView.refreshControl = refreshControl
         } else {
             self.tableView.addSubview(refreshControl)
         }
         if (exchangeData?.type ?? "") == "outgoing" {
             if (exchangeData?.status ?? "") == "Pending" {
                 self.cancelButton.setTitle(getLanguage["cancel"] ?? "", for: .normal)
                 self.acceptButton.isHidden = true
             }
             else {
                 self.cancelButton.setTitle(getLanguage["failed"] ?? "", for: .normal)
                 self.acceptButton.setTitle(getLanguage["success"] ?? "", for: .normal)
                 self.acceptButton.isHidden = false
             }
         }
         else if (exchangeData?.type ?? "") == "incoming" {
             if (exchangeData?.status ?? "") == "Pending" {
                 self.cancelButton.setTitle(getLanguage["decline"] ?? "", for: .normal)
                 self.acceptButton.setTitle(getLanguage["accept"] ?? "", for: .normal)
             }
             else {
                 self.cancelButton.setTitle(getLanguage["failed"] ?? "", for: .normal)
                 self.acceptButton.setTitle(getLanguage["success"] ?? "", for: .normal)
             }
             self.acceptButton.isHidden = false
         }
         CURRENT_CHAT = exchangeData?.exchangerName ?? ""
         SocketIOManager.sharedInstance.delegate = self
         SocketIOManager.sharedInstance.connect(true)
        self.loadData()
         self.getChatID()

     }
      @objc func keyboardWillShow(sender: NSNotification) {
         let info = sender.userInfo!
         let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         var newHeight = keyboardFrame.height
         if #available(iOS 11.0, *) {
             newHeight = keyboardFrame.height - view.safeAreaInsets.bottom + 10
         } else {
             newHeight = keyboardFrame.height + 10
         }
         self.stackViewBottomConst.constant = newHeight
         UIView.animate(withDuration: 0.5, animations: { () -> Void in
             self.view.layoutIfNeeded()
         })
         print(self.stackViewBottomConst.constant)
         self.viewDidLayoutSubviews()
     }
     @objc func keyboardWillHide(sender: NSNotification) {
         self.stackViewBottomConst.constant = 10
         print(self.stackViewBottomConst.constant)
         DispatchQueue.main.async {
             self.tableView.reloadData()
             if (self.chatModelArray.count - 1) > 0 {
                 self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
             }
         }
     }
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
     @IBAction func chatButtonAct(_ sender: UIButton) {
         if sender == attachmentButton {
             self.view.endEditing(true)
             let options = PHFetchOptions()
             options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
             options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
             self.videoFetchResult = PHAsset.fetchAssets(with: .video, options: options)
             PHPhotoLibrary.shared().register(self)
             self.imagePicker.present(from: sender)
         }
         else if sender == locationButton {
//             let pageObj = LocationViewController()
//             pageObj.delegate = self
//             pageObj.viewType = "chat"
//             self.navigationController?.pushViewController(pageObj, animated: true)
            
            // MARK: Mabbox Addon
            
            let pageObj = MapViewController()
            pageObj.delegate = self
            pageObj.viewType = "chat"
            self.navigationController?.pushViewController(pageObj, animated: true)
  
         }
         else {
 //            self.textView.resignFirstResponder()
             if self.textView.text != "" && textView.tag == 1{
                 self.sendChat(message: self.textView.text!, current_latitude: "", current_longitude: "", image_url: "", source_id: "\(self.exchangeData?.exchangeId ?? 0)", type: "normal", viewUrl: "", message_content: "1")
             }
             else {
                 let alert = UIAlertController(title: nil, message: getLanguage["type_your_message"] ?? "", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                 self.present(alert, animated: true, completion: nil)
             }
         }
     }
     func getChatID() {
         let itemViewModel = ItemDetailsViewModel()
         itemViewModel.getChatIdAct(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: "\(self.exchangeData?.exchangerId ?? 0)", onSuccess: { (success) in
             if success {
                 self.chatId = (itemViewModel.itemChatModel?.chatId ?? "")
             }
         }) { (failure) in
         }
     }
     func loadData() {
         Utility.shared.startAnimation(viewController: self)
         self.chatModelArray.removeAll()
         self.viewModel.getChatData(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: self.receiverId, type: "exchange", source_id: "\(self.exchangeData?.exchangeId ?? 0)", offset: "0", limit: "20", onSuccess: { (success) in
             if success {
                 self.chatModelArray = self.viewModel.chatModel?.chats ?? [ChildChatModel]()
                 self.tableView.reloadData()
                 DispatchQueue.main.async {
                     if (self.chatModelArray.count - 1) > 0 {
                         self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: true)
                     }
                 }
             }
             Utility.shared.stopAnimation(viewController: self)
         }, onFailure: { (failure) in
             Utility.shared.stopAnimation(viewController: self)
         })
     }
     func sendChat(message: String,  current_latitude: String, current_longitude: String, image_url: String, source_id: String, type: String, viewUrl: String, audioDuration: String = "", message_content: String = "1") {
         SocketIOManager.sharedInstance.messageTyping(message: "untype", senderId: "\(self.exchangeData?.exchangerUsername ?? "")", exchage_type: true, sourceId: "\(self.exchangeData?.exchangeId ?? 0)")
         
         //        self.textView.endEditing(true)
         let timeStamp = Date().timeIntervalSince1970
         self.textView.text = ""
 //        self.textViewDidChange(self.textView)
         self.textViewHeightConst.constant = 45
         self.textViewHeightConst.priority = .defaultHigh
         
        let messageVal = MessageModel(chatTime: (Int(timeStamp)), imageName: image_url, message: message, userImage: ADMIN_VIEW_MODEL.profileModel?.result.userImg ?? "", userName: ADMIN_VIEW_MODEL.profileModel?.result.userName ?? "", uploadImage: viewUrl, latitude: current_latitude, longitude: current_longitude, uploadAudio: viewUrl, image_url: viewUrl)
         let chatModel = ChildChatModel(type: type, receiver: (ADMIN_VIEW_MODEL.profileModel?.result.userName ?? ""), sender: (UserDefaultModule.shared.getUserData()?.userName ?? ""), message: messageVal, sourceID: source_id, itemImage: "", itemTitle: "", audioDuration: audioDuration)
         self.chatModelArray.append(chatModel)
         self.tableView.reloadData()
         DispatchQueue.main.async {
             if (self.chatModelArray.count - 1) > 0 {
                 self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: true)
                 
             }
         }
        SocketIOManager.sharedInstance.chatMessage(message: message, userImage: "", userName: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), type: type, messageContent: message_content, lat: current_latitude, lon: current_longitude, view_url: image_url, offerId: source_id, senderId: "\(self.exchangeData?.exchangerUsername ?? "")", exchage_type: true, chatTime: (Int(timeStamp)), audio_duration: "", chatURL: self.viewModel.chatModel?.chatUrl ?? "")
        self.viewModel.sendChatData(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), chat_id: self.chatId, type: type, message: message, source_id: source_id, current_latitude: current_latitude, current_longitude: current_longitude, image_url: viewUrl, chat_type: "exchange", timeStamp: (Int(timeStamp)), audio_url: image_url, created_date: "", audio_duration: "", onSuccess:{ (success) in
            Utility.shared.stopAnimation(viewController: self)
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
      }
    @IBAction func acceptDeclineButtonAct(_ sender: UIButton) {
         var status = ""
         
         if sender == acceptButton {
             if (self.exchangeData?.status ?? "") == "Pending" && (exchangeData?.type ?? "") != "outgoing" {
                 status = "accept"
             }
             else {
                 status = "success"
             }
         }
         else {
             if (self.exchangeData?.status ?? "") == "Pending" {
                 if (exchangeData?.type ?? "") == "outgoing" {
                     status = "cancel"
                 }
                 else {
                     status = "decline"
                 }
             }
             else {
                 status = "failed"
             }
         }
         Utility.shared.startAnimation(viewController: self)
         self.viewModel.updateExchangeStatus(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), exchange_id: "\(self.exchangeData?.exchangeId ?? 0)", status: status, onSuccess: { (success) in
             Utility.shared.stopAnimation(viewController: self)
             let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage["Exchange_updated_successfully"], preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: { (UIAlertAction) in
                 self.exchangeDelgate?.updateExchangeStatus(status)
                 self.navigationController?.popViewController(animated: true)
             }))
             if success {
                 var message = ""
                 if status == "accept" {
                     message = "offer_accepted"
                 }
                 else if status == "decline" {
                     message = "offer_declined"
                 }
                 else if status == "cancel" {
                     message = "exchange cancelled"
                 }
                 else if status == "failed" {
                     message = "failed"
                 }
                 alert.message = getLanguage[message] ?? status
             }
             else {
                 alert.message = getLanguage[self.viewModel.tosModel?.message ?? ""] ?? (self.viewModel.tosModel?.message ?? "")
             }
             self.present(alert, animated: true, completion: nil)
             
         }) { (failure) in
             Utility.shared.stopAnimation(viewController: self)
             let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: getLanguage["Status Already Updated"], preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
             self.present(alert, animated: true, completion: nil)
         }
     }
 }
 extension ExchangeDetailsViewController: customLocationDelegate{
    func locationAct(city: String, state: String, country: String, countryCode: String,lat: String, long: String, location: String){

        self.sendChat(message: "", current_latitude: lat, current_longitude: long, image_url: "", source_id: "\(self.exchangeData?.exchangeId ?? 0)", type: "share_location", viewUrl: "", message_content: "3")

    }
  }
 extension ExchangeDetailsViewController: UITextViewDelegate {
     func textViewDidChange(_ textView: UITextView) {
         SocketIOManager.sharedInstance.messageTyping(message: "type", senderId: "\(self.exchangeData?.exchangerUsername ?? "")", exchage_type: true, sourceId: "\(self.exchangeData?.exchangeId ?? 0)")
           textViewAct(textView)
     }
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
  
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
             SocketIOManager.sharedInstance.messageTyping(message: "untype", senderId: "\(self.exchangeData?.exchangerUsername ?? "")", exchage_type: true, sourceId: "\(self.exchangeData?.exchangeId ?? 0)")
         }
        if textView.text == "" {
            textView.text = getLanguage["writemessage"]
            textView.textColor = UIColor(named: "ThirdryTextColor")
            textView.tag = 0
            self.sendButton.isHidden = true
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
            }
        }
        else {
            if textView.text == "" && textView.tag == 1{
                //                textView.text = getLanguage["writemessage"]
                textView.textColor = UIColor(named: "ThirdryTextColor")
                textView.tag = 0
                self.sendButton.isHidden = true
            }
            else {
                self.sendButton.isHidden = false
                textView.textColor = UIColor(named: "AppTextColor")
            }
        }
    }
 }
 extension ExchangeDetailsViewController: UITableViewDelegate, UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.chatModelArray.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSubTableViewCell") as! ChatSubTableViewCell
          if self.chatModelArray.count > indexPath.row {
             cell.loadData(chatModel: self.chatModelArray[indexPath.row])
         }
        
        cell.languageButton.isHidden = true
         return cell
     }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if self.chatModelArray.count > indexPath.row {
             let chatModel = self.chatModelArray[indexPath.row]
             if chatModel.type == "share_location" {
                if let url = URL(string: "http://maps.google.com/?saddr=\(self.delegate.currentLocation?.location?.coordinate.latitude ?? 0),\(self.delegate.currentLocation?.location?.coordinate.longitude ?? 0)&daddr=\(chatModel.message.latitude ?? ""),\(chatModel.message.longitude ?? "")&directionsmode=driving")
                 {
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
//             else if chatModel.type == "image" {
//                 let fullScreenController = FullScreenSlideshowViewController()
//                 var imageSource = [SDWebImageSource]()
//
//                 imageSource.append(SDWebImageSource(urlString: chatModel.message.uploadImage ?? "", placeholder: UIImage(named: "profilelogo"))!)
//                 fullScreenController.backgroundColor = UIColor(white: 0, alpha: 0.7)
//                fullScreenController.closeButton.setImage(#imageLiteral(resourceName: "takeclose"), for: .normal)
//                 fullScreenController.closeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//                 fullScreenController.closeButton.tintColor = .black
//                 fullScreenController.inputs = imageSource
//                 fullScreenController.initialPage = indexPath.row
//
//                 fullScreenController.slideshow.currentPageChanged = { [weak self] page in
//                     if let cell = tableView.cellForRow(at: indexPath) as? ChatSubTableViewCell, let imageView = cell.chatImageView {
//                         self?.slideshowTransitioningDelegate?.referenceImageView = imageView
//                     }
//                 }
//                 present(fullScreenController, animated: true, completion: nil)
//             }
             
             
             else if chatModel.type == "image" {
                 let fullScreenController = FullScreenSlideshowViewController()
                 var imageSource = [SDWebImageSource]()
                 print("check one\(chatModel.message.uploadImage)")
                 imageSource.append(SDWebImageSource(urlString: chatModel.message.uploadImage ?? "", placeholder: #imageLiteral(resourceName: "profilelogo"))!)
                 
//                 print("check one\(chatModel.message.uploadImage)")
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
     
     
     
     func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         self.lastContentOffset = scrollView.contentOffset.y
     }
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
         if scrollView == self.tableView && self.lastContentOffset > scrollView.contentOffset.y {
             let contentOffset = scrollView.contentOffset.y
             if contentOffset <= 50 && !self.isLoadingMore {
                 self.refreshControl.beginRefreshing()
                 self.isLoadingMore = true
                 DispatchQueue.global(qos: .background).async {
                     self.offSet = self.chatModelArray.count
                     print("self.offSet\(self.offSet)")
                     self.viewModel.getChatData(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: self.receiverId, type: "exchange", source_id: "\(self.exchangeData?.exchangeId ?? 0)", offset: "\(self.offSet)", limit: "20", onSuccess: { (success) in
                         if success {
                             self.chatModelArray = ((self.viewModel.chatModel?.chats ?? [ChildChatModel]()) + self.chatModelArray)
                         }
//                        self.refreshControl.endRefreshing()
//                        self.tableView.reloadData()
//                        self.tableView.scrollToRow(at: IndexPath(row: ((self.chatModelArray.count) - ((self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count)), section: 0), at: .top, animated: false)
//
//                         DispatchQueue.main.async {
//                             self.isLoadingMore = false
//                            if (self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count > 0 {
//                                print("totalCount: \(self.chatModelArray.count) Perticular Count: \((self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count)")
//                                self.tableView.scrollToRow(at: IndexPath(row: ((self.chatModelArray.count) - ((self.viewModel.chatModel?.chats ?? [ChildChatModel]()).count)), section: 0), at: .top, animated: false)
//                            }
//                         }
                         DispatchQueue.main.async {
                                                    self.refreshControl.endRefreshing()
                                                    self.tableView.reloadData()
                                                    self.isLoadingMore = false
                                                    if self.textView.isFirstResponder {
                                                        DispatchQueue.main.async {
                                                            self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                                                        }
                                                    }
                                                }

                     }, onFailure: { (failure) in
                         self.refreshControl.endRefreshing()
                     })
                 }
             }
         }
     }
 }
 extension ExchangeDetailsViewController: ImageDelegate {
     
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
                   
                    print("View_urlView_url\(success["Image","View_url"].stringValue)")
                     self.imageString = success["Image","View_url"].stringValue
                    
                     self.sendChat(message: "", current_latitude: "", current_longitude: "", image_url: success["Image","View_url"].stringValue, source_id: "\(self.exchangeData?.exchangeId ?? 0)", type: "image", viewUrl: success["Image","Name"].stringValue, message_content: "2")
                     self.viewModel.getChatData(sender_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: self.receiverId, type: "exchange", source_id: "\(self.exchangeData?.exchangeId ?? 0)", offset: "0", limit: "20", onSuccess: { (success) in
                         if success {
                             self.chatModelArray = self.viewModel.chatModel?.chats ?? [ChildChatModel]()
                             self.tableView.reloadData()
                             DispatchQueue.main.async {
                                 if (self.chatModelArray.count - 1) > 0 {
                                     self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: true)
                                 }
                             }
                         }
                         Utility.shared.stopAnimation(viewController: self)
                     }, onFailure: { (failure) in
                         Utility.shared.stopAnimation(viewController: self)
                     })
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
 
 extension ExchangeDetailsViewController: SocketDelegate {
     func getSocketInfo(dict:JSON, type: String) {
         if type == "message" {
             self.viewModel.getChatData(sender_id:
                 (UserDefaultModule.shared.getUserData()?.user_id ?? ""), receiver_id: self.receiverId, type: "exchange", source_id: "\(self.exchangeData?.exchangeId ?? 0)", offset: "0", limit: "20", onSuccess: { (success) in
                     if success {
                         self.chatModelArray = self.viewModel.chatModel?.chats ?? [ChildChatModel]()
                     }
                     self.tableView.reloadData()
                     DispatchQueue.main.async {
                         if (self.chatModelArray.count - 1) > 0 {
                             self.tableView.scrollToRow(at: IndexPath(row: (self.chatModelArray.count - 1), section: 0), at: .bottom, animated: false)
                         }
                     }
             }, onFailure: { (failure) in
             })
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
 }
