 //
 //  CallViewController.swift
 //  Howzu_swift
 //
 //  Created by Hitasoft on 04/05/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import UIKit
 import AVFoundation
 import AudioToolbox
 import SwiftyJSON
 import CallKit
 import Toast_Swift
 import SocketIO

 class CallViewController: ARDVideoCallViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

     @IBOutlet weak var enlargeButton: UIButton!
     @IBOutlet weak var buttonStackView: UIStackView!
     @IBOutlet weak var callEndButton: UIButton!
     @IBOutlet weak var cameraSpeakerButton: UIButton!
     @IBOutlet weak var endCallButton: UIButton!
     @IBOutlet weak var muteButton: UIButton!
     @IBOutlet weak var callButton: UIButton!
     @IBOutlet weak var timerLabel: UILabel!
     @IBOutlet weak var statusLabel: UILabel!
     @IBOutlet weak var userNameLabel: UILabel!
     @IBOutlet weak var receiverImageView: UIImageView!
     @IBOutlet weak var userImageview: UIImageView!
     @IBOutlet weak var propertiesView: UIView!
     @IBOutlet weak var preview: UIView!
     @IBOutlet weak var containerView: UIView!
     
     var call_type : String!
     var chatId: String!
     var random_id :String!
     var receiverId : String!
     var senderFlag: Bool!
     var previewAdded: Bool!
     var hideEnabled = Bool()
//     var chatData = [ChatListResultModel]()
     var room_id :String!
     var viewType :String!
     var av_Player : AVAudioPlayer!
     var poorConnection : Bool = false
     var timerStart : Bool = false
     var countTimer = Timer()
     var startTime = 0
     var muteFlag : Bool = false
     var call_status :String!
     var speakerMode : Bool!
     var blockedMe = false
 //    var localCallDB = CallStorage()
     var captureSession = AVCaptureSession()
     var previewLayer:CALayer!
     var captureDevice:AVCaptureDevice!
     var platform = String()
     var userData: LoginModel?
     var viewModel = CallViewModel()
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var receiverName = ""
    var receiverImage = ""
     
    override func viewDidLoad() {
         super.viewDidLoad()
        
        self.userData = UserDefaultModule.shared.getUserData()
        self.customUI()
         self.configWebRTC()
         self.initialSetup()
         self.appDelegate.isAlreadyInCall = true
         // Do any additional setup after loading the view.
     }
     override func viewDidAppear(_ animated: Bool) {
         if call_type == "video" {
             self.cameraSpeakerButton.isUserInteractionEnabled = false
             UIApplication.shared.isIdleTimerDisabled = true
//             self.videoPreview()
             self.containerView.bringSubviewToFront(self.propertiesView)
 //            self.view.bringSubviewToFront(enlargeBtn)
         }
     }
     override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
     }

     override func viewWillDisappear(_ animated: Bool) {
         av_Player.stop()
         NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(automaticallyDisConnectCall), object: nil)
         NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(makeRinging), object: nil)

         UIApplication.shared.isIdleTimerDisabled = false
     }
     func customUI() {
        
         self.buttonStackView.spacing = ((self.buttonStackView.frame.width - (self.callButton.frame.width / 2) * 5) / 5)
         self.receiverImageView.cornerViewRadius()
         self.callButton.cornerViewRadius()
         self.muteButton.cornerViewRadius()
         self.endCallButton.cornerViewRadius()
         self.callEndButton.cornerViewRadius()
         self.cameraSpeakerButton.cornerViewRadius()
        self.userNameLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "")
        self.statusLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "")
        self.timerLabel.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "")
 
         NotificationCenter.default.addObserver(self, selector: #selector(backgroundNotify), name: UIApplication.didEnterBackgroundNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(activeNotify), name: UIApplication.didBecomeActiveNotification, object: nil)

     }
    @objc func activeNotify(_ notification: Notification) {
        if self.call_status == "connected" {
            if self.call_type == "video" {
                SocketIOManager.sharedInstance.RTCMessage(userData?.user_id ?? "", receiver_id: self.receiverId, type: "away", room_id: self.room_id)
            }
        }
    }
    @objc func backgroundNotify(_ notification: Notification) {
        if self.call_status == "connected" {
            if self.call_type == "video" {
                SocketIOManager.sharedInstance.RTCMessage(userData?.user_id ?? "", receiver_id: self.receiverId, type: "online", room_id: self.room_id)
            }
        }
    }
     func initialSetup() {
        
         self.enlargeButton.frame = CGRect.init(x: FULL_WIDTH - 150, y: FULL_HEIGHT - 260, width: 150, height: 150)
         hideEnabled = false
         call_status = "waiting"
         self.delegate = self
        // self.blockedMe = (self.chatData?.block ?? false)
        self.userNameLabel.text = self.receiverName ?? ""
        if self.receiverImage != ""{
            self.receiverImageView.sd_setImage(with: URL(string: (self.receiverImage )), placeholderImage: #imageLiteral(resourceName: "profileicon"))
         }else{
             self.receiverImageView.image = #imageLiteral(resourceName: "profileicon")
         }
         self.userImageview.image = UIImage(named: "call_bg")
//        self.userImageview.sd_setImage(with: URL(string: (self.userData?.userImage ?? "")), placeholderImage: #imageLiteral(resourceName: "profileicon"))
         self.performSelector(inBackground: #selector(self.makeRinging), with: nil)
         if(senderFlag){
             let del = UIApplication.shared.delegate as! AppDelegate
             del.callKitPopup = true
             del.currentCallerID = receiverId
             room_id = Utility.shared.random()
             self.join(toNextRoom: room_id, platform: platform, calltype: call_type)
 //            self.enableCallKit()
             self.makeCallToReceiver()
         }else{
             if self.viewType == "2" {
                 self.join(toNextRoom: room_id, platform: platform, calltype: call_type)
             }
        }
        self.showPreview()
         //call ui changes method
         self.setUIDesigns()
     }
     func enableCallKit() {
         self.appDelegate.baseUUId = UUID()
         let update = CXCallUpdate()
         let username = self.userNameLabel.text!
         update.remoteHandle = CXHandle(type: .generic, value: username)
         if call_type == "video" {
             update.hasVideo = true
         }
         else {
             update.hasVideo = false
         }
         self.appDelegate.provider.configuration.maximumCallsPerCallGroup = 1
         self.appDelegate.provider.reportNewIncomingCall(with: self.appDelegate.baseUUId, update: update, completion: { error in })
         self.appDelegate.callKitPopup = true
     }
     func setUIDesigns() {
         //sender receiver based ui changes
         self.callEndButton.isHidden = true
         if senderFlag {
             self.callButton.isHidden = true
             self.cameraSpeakerButton.isHidden = false
             self.muteButton.isHidden = false
         }else{
             if viewType == "2" {
                 self.callButton.isHidden = true
                 self.cameraSpeakerButton.isHidden = false
                 self.muteButton.isHidden = false
             }else{
                 self.callButton.isHidden = false
                 self.cameraSpeakerButton.isHidden = true
                 self.muteButton.isHidden = true
             }
         }
         //call type based ui changes
         if call_type == "audio" {
             self.cameraSpeakerButton.tintColor = UIColor(named: "WhiteColor") ?? .white
             self.cameraSpeakerButton.setImage(#imageLiteral(resourceName: "speaker"), for: .normal)
             self.speakerMode = false
             self.speakerOff()
             self.containerView.isHidden = false
             self.statusLabel.text = getLanguage["audio_calling"]
         }else{
             //            self.container.isHidden = true
             self.userImageview.isHidden = true
             self.preview.backgroundColor = .clear
             self.containerView.backgroundColor = .clear
             self.propertiesView.backgroundColor = .clear
             self.receiverImageView.isHidden = true
             self.speakerMode = true
             self.speakerOn()
             self.statusLabel.text = getLanguage["video_calling"]
         }
         if viewType == "2" {
             self.statusLabel.text = "Connecting...."
         }
         self.view.bringSubviewToFront(containerView)
         self.view.bringSubviewToFront(enlargeButton)
         
     }
     
     @IBAction func enlargeButtonAct(_ sender: UIButton) {
         self.enlargeView()
         DispatchQueue.main.async {
             self.propertiesView.isHidden = false
             self.view.bringSubviewToFront(self.containerView)
             self.view.bringSubviewToFront(self.enlargeButton)
         }
     }
     func initiateCallToReceiver() {
         if self.senderFlag {
             
         }
     }
     @objc func makeRinging(){
         var audioName = String()
         var audioType = String()
         
         if senderFlag{
             audioName = "sound2"
             audioType = "caf"
         }else{
             audioName = "RingTone"
             audioType = "mp3"
         }
         
         let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: audioName, ofType: audioType)!)
         let session = AVAudioSession.sharedInstance()
         
         var availbleInput = NSArray()
         availbleInput = AVAudioSession.sharedInstance().availableInputs! as NSArray
         var port = AVAudioSessionPortDescription()
         port = availbleInput.object(at: 0) as! AVAudioSessionPortDescription
         
         var _: Error?
         try? session.setPreferredInput(port)
         
         try? session.setCategory(AVAudioSession.Category.playback, mode: .default, options: [])

         if call_type == "video" {
             try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
             speakerMode = true
             self.speakerOn()

         } else {
             try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
         }
         try? session.setActive(true)
         try! av_Player = AVAudioPlayer(contentsOf: alertSound)
         av_Player!.prepareToPlay()
         av_Player.numberOfLoops = -1
        if senderFlag{
         av_Player!.play()
        }
     }
     func makeCallToReceiver()  {
        let timeStamp = Date().timeIntervalSince1970

        self.viewModel.makeCall(toId: self.receiverId, fromId: UserDefaultModule().getUserData()?.user_id ?? "", chatId: self.chatId, room_id: self.room_id, type: self.call_type,timestamp: (Int(timeStamp)), onSuccess: {(success) in
        }) { (failure) in
        }
//        self.perform(#selector(self.automaticallyDisConnectCall), with: nil, afterDelay: 30.0)
     }
     @objc func automaticallyDisConnectCall(){
         if (call_status == "waiting"){
             SocketIOManager.sharedInstance.endCall(self.room_id)
             self.missCallAlert()
             self.disconnectCall()
         }
     }

     func missCallAlert() {
         if senderFlag {
             if call_status == "waiting" {
                self.viewModel.missedCall(fromId: UserDefaultModule().getUserData()?.user_id ?? "", toId: self.receiverId, chatId: self.chatId, type: self.call_type, room_id: self.room_id, onSuccess: { (sucess) in
                  }) { (failure) in
                 }
             }
         }
     }
     @IBAction func cameraSpeakerButtonAct(_ sender: UIButton) {
         if call_type == "audio"{
             self.cameraSpeakerButton.setImage(#imageLiteral(resourceName: "speaker"), for: .normal)
             if speakerMode {
                 speakerMode = false
                 self.cameraSpeakerButton.backgroundColor = UIColor(named: "lightWhite") ?? .white
                 self.cameraSpeakerButton.tintColor = UIColor(named: "WhiteColor") ?? .white
                 self.speakerOff()
             }
             else {
                 speakerMode = true
                 cameraSpeakerButton.backgroundColor = UIColor(named: "WhiteColor") ?? .white
                 self.cameraSpeakerButton.tintColor = UIColor(named: "AppTextColor") ?? .white
                 self.speakerOn()
             }
         }
         else {
             self.switchCamera()
             speakerMode = true
             self.speakerOn()
         }
     }
     @IBAction func endCallButtonAct(_ sender: UIButton) {
         self.missCallAlert()
         SocketIOManager.sharedInstance.endCall(self.room_id)
         self.disconnectCall()
     }
     
     @IBAction func muteButtonAct(_ sender: UIButton) {
         if muteFlag {
             muteFlag = false
             muteButton.backgroundColor = UIColor(named: "lightWhite") ?? .white
             self.muteButton.tintColor = UIColor(named: "WhiteColor") ?? .white
             self.muteOn()
         }
         else{
             muteFlag = true
             muteButton.backgroundColor = UIColor(named: "WhiteColor") ?? .white
             self.muteButton.tintColor = UIColor(named: "AppTextColor") ?? .white
             self.muteOff()
         }
     }
     @IBAction func callAttendButtonAct(_ sender: UIButton) {
         self.viewType = "2"
         self.initialSetup()
         
     }
     //set timer count
     @objc func updateTimer()  {
         self.startTime += 1
         DispatchQueue.main.async {
             if !self.poorConnection{
                 self.statusLabel.text = self.timeString(time: TimeInterval(self.startTime))
             }
         }
     }
     func timeString(time:TimeInterval)-> String {
         let hours = Int(time) / 3600
         let minutes = Int(time) / 60 % 60
         let seconds = Int(time) % 60
         return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
     }
 }
 extension CallViewController: SocketDelegate,ARDVideoCallViewControllerDelegate {
     func getSocketInfo(dict: JSON, type: String) {
         self.appDelegate.isAlreadyInCall = false
         self.dismiss(animated: false, completion: nil)
     }
     
    
     //apprtc state delegate
     func streamDetails(_ state: Int) {
          print("ICE STATE \(state)")
         if state == 2 { // CONNECTED STATE
             
             call_status = "connected"
             av_Player.stop()
             self.statusLabel.textColor = .white
             self.poorConnection = false
                 if call_type == "audio"{
                     self.updateTimer()
                     if !self.timerStart{
                         self.countTimer = Timer.scheduledTimer(timeInterval: 1.0, target:self,selector:#selector(self.updateTimer), userInfo: nil, repeats: true)
                         self.timerStart = true
                     }
                 }else{
                     let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideProperties(sender:)))
                     self.view.addGestureRecognizer(tap)
//                         self.captureSession.stopRunning()
                         self.preview.isHidden = true
                         self.userNameLabel.isHidden = true
                         self.statusLabel.text = ""
                     speakerMode = true
                     self.speakerOn()
                     self.cameraSpeakerButton.isUserInteractionEnabled = true
                    self.videoCallView.enlargeEnable = false
                    self.videoCallView.remoteVideoView.isHidden = false
                    self.videoCallView.localVideoView.frame = CGRect.init(x: FULL_WIDTH - 150, y: 40, width: 150, height: 150)
                    self.videoCallView.remoteVideoView.frame = CGRect.init(x: 0 , y: 0, width: FULL_WIDTH, height: FULL_HEIGHT)

                    self.view.bringSubviewToFront(self.containerView)

                  }
         }else if state == 4{
             self.poorConnection = false
         }else if state == 5{ // SLOW CONNECTION
             self.poorConnection = true
             self.statusLabel.textColor = .white
             self.statusLabel.isHidden = false
             self.statusLabel.text = "Poor Network! Connecting..."
//            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
//                if self.call_status == "connected" {
//                }
//                else {
//                    self.call_status = "disconnected"
//                    self.disconnectMissedCall()
//                }
//            }
         }else if state == 6{ // DISCONNECTED STATE
             UIApplication.shared.keyWindow?.rootViewController?.view.hideToast()
             if call_status == "connected" {
                 call_status = "disconnected"
                 self.disconnectCall()
             }
             else {
                 call_status = "disconnected"
                 self.disconnectMissedCall()
             }
         }
     }
     //handle
     @objc func hideProperties(sender: UITapGestureRecognizer? = nil) {
         // handling code
         UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
             if self.hideEnabled {
                 self.hideEnabled = false
                 self.propertiesView.frame.origin.y = 0
             }else{
                 self.hideEnabled = true
                 self.propertiesView.frame.origin.y = 200
             }
         }, completion: nil)
     }
     func disconnectCall() {
         self.countTimer.invalidate()
 //        SocketIOManager.sharedInstance.disconnect()
         av_Player.stop()
         if !senderFlag {
             let appDelegate = UIApplication.shared.delegate as! AppDelegate
             appDelegate.endCall()
         }else{
             let del = UIApplication.shared.delegate as! AppDelegate
             del.callKitPopup = false
         }
         self.hangup()
         self.appDelegate.isAlreadyInCall = false
         self.dismiss(animated: false, completion: nil)
         UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(getLanguage["call_end"])

     }
     func disconnectMissedCall() {
         self.countTimer.invalidate()
         if av_Player != nil{
             av_Player.stop()
         }
         if !senderFlag {
             let appDelegate = UIApplication.shared.delegate as! AppDelegate
             appDelegate.endCall()
         }else{
             let del = UIApplication.shared.delegate as! AppDelegate
             del.callKitPopup = false
         }
         self.hangup()
         self.appDelegate.isAlreadyInCall = false
         self.dismiss(animated: false, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(getLanguage["call_decline"])
 
         //missed call view
         if (call_status == "waiting" && !senderFlag){
             let callerId = receiverId as String
             let time = NSDate().timeIntervalSince1970
 //            self.localCallDB.addNewCall(call_id: random_id, contact_id: callerId, status: "missed", call_type: call_type, timestamp: "\(time.rounded().clean)", unread_count: "1")
         }
         
     }
     func getSocketInfo(dict: [String : Any], type: String) {
         self.appDelegate.isAlreadyInCall = false
         self.dismiss(animated: false, completion: nil)
         
     }
     //show preview camera screen
     func videoPreview(){
 //        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
             self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
             let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
             self.captureDevice = availableDevices.first
             do {
                 let captureDeviceInput = try AVCaptureDeviceInput(device: self.captureDevice)
                 self.captureSession.addInput(captureDeviceInput)
             } catch {
                 print("error.localizedDescription in Call \(error.localizedDescription)")
             }
             let pL = AVCaptureVideoPreviewLayer(session: self.captureSession)
             pL.videoGravity = .resizeAspectFill
             self.previewLayer = pL
             self.previewLayer.frame = CGRect.init(x: 0, y: 0, width: FULL_WIDTH, height: FULL_HEIGHT)
             self.preview.layer.addSublayer(self.previewLayer)
             self.previewAdded = true
             
             let dataOutput = AVCaptureVideoDataOutput()
             dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
             dataOutput.alwaysDiscardsLateVideoFrames = true
             if self.captureSession.canAddOutput(dataOutput) {
                 self.captureSession.addOutput(dataOutput)
             }
     //            self.captureSession.commitConfiguration()
             self.captureSession.startRunning()

 //        }
     }
 }


