//
//  PreviewVCViewController.swift
//  ProductsVideo
//
//  Created by MAC BOOK on 08/11/22.
//

import UIKit
import PryntTrimmerView
import AVKit
import AVFoundation
import MobileCoreServices
import SwiftyJSON


protocol uploadDelegate1 {
    func updatecount(status: Bool)
}

class PreviewVC: AssetSelectionViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var processingCardview: UIView!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var processingLoader: UIActivityIndicatorView!
    @IBOutlet weak var processingView: UIView!
    
    @IBOutlet weak var previewThumbImageView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var selectedStartTimeTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var frameContainerView: UIView!
    @IBOutlet weak var imageFrameView: TrimmerView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    var delegate1: uploadDelegate1?
    
    var fileURL: String?
    var type = ""
    
    var selectedIDArray = [String]()
    
    private let videoGravity: AVLayerVideoGravity
    private var countdownTimer: Timer!
    private var player: AVPlayer?
    var videoLayer: AVPlayerLayer!
    private var outputURL: URL? = nil
    private var observer: NSKeyValueObservation?
    var seconds = Float64()
    var playerObserver : Any!
    var video_id: String?
    var isPlayerMute = Bool()
    var playbackTimeCheckerTimer: Timer?
    var startTime = 0.0;
    var endTime = 0.0;
    var asset: AVAsset!
    var thumbTime: CMTime!
    var thumbtimeSeconds: Int!
    var avplayer: AVPlayer?
//    var viewModel = CameraViewModel()
    let VIDEO_MAXIMUM_DURATIONS: Int = 60
    let VIDEO_MINIMUM_DURATIONS: Int = 3

    init(url: URL, videoGravity: AVLayerVideoGravity = .resizeAspect) {
        self.outputURL = url
        self.videoGravity = videoGravity
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.postButton.isUserInteractionEnabled = false
        print("selectedIDArray_PreviewVC:\(self.selectedIDArray)")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "AddhemeColorNew")!)
        imageFrameView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.updateStatusbarBackground()
    }
    
    func configUI() {
        self.updateStatusbarBackground()
        self.navigationController?.isNavigationBarHidden = true
        self.processingView.isHidden = true
        self.processingCardview.applyCardEffect()
        self.previewThumbImageView.cornerViewMiniumRadius()
        self.processingLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "Processing")
        self.postButton.config(color: .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "next")
        self.postButton.cornerMiniumRadius()
        imageFrameView.handleColor = UIColor.white
        imageFrameView.mainColor = UIColor.darkGray
        self.firstvideoplay()
        self.loadAsset()
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.imageFrameView.asset = self.asset
            self.positionBarStoppedMoving(CMTime.zero)
        })
        self.changeRTL()
    }
    
    func changeRTL(){
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.postButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.startTimeTextField.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.selectedStartTimeTextField.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.endTimeTextField.transform =  CGAffineTransform(scaleX: -1, y: 1)
            self.playImageView.transform =  CGAffineTransform(scaleX: -1, y: 1)
            self.previewView.transform =  CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLayoutSubviews() {
        self.videoLayer.frame = self.previewView.bounds
    }
    func loadAsset() {
        asset = AVURLAsset.init(url: self.outputURL!)
        
        thumbTime = asset.duration
        thumbtimeSeconds = Int(CMTimeGetSeconds(thumbTime))
        
        if let duration = self.player?.currentItem?.duration {
            self.endTime = duration.seconds
        }
        frameContainerView.isHidden = false
        self.imageFrameView.minDuration = 0.5
//        let videoDuration = Double(VIDEO_MAXIMUM_DURATIONS)

        self.imageFrameView.maxDuration = self.endTime // videoDuration/60
    }
    @objc func firstvideoplay()
    {
//            resetPlayer()

        self.player = AVPlayer(url: self.outputURL!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        videoLayer = AVPlayerLayer(player: self.player)
        videoLayer.frame = self.previewView.bounds
        videoLayer.videoGravity = videoGravity
        self.previewView.layer.addSublayer(videoLayer)
//        self.player?.play()
        if (player?.rate != 0 && player?.error == nil) {
            // print("playing")
        }
        self.asset = AVURLAsset.init(url: self.outputURL!)
//        if self.asset != nil {
//            self.loadAssetRandomly(asset: self.asset)
//        }
//        self.loadAsset()
        self.previewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playControl)))
//        self.registerNotificationCentersAndObservers()
        self.playerObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { time in
            self.seconds = CMTimeGetSeconds(time)
            self.findPlayerStatus()
        }
        self.observer = player?.currentItem?.observe(\.status, options:  [.new, .old], changeHandler: { (playerItem, change) in
            if self.player?.currentItem!.status == .readyToPlay {
//                self.player?.play()
//                self.startAudioPlayer()
                self.loaderView.isHidden = true
                self.playImageView.isHidden = true
            }
        })
    }
    @objc func playControl() {
        if self.playImageView.tag == 1 {
            self.playImageView.tag = 0
            if player != nil {
                if ((player?.currentTime().seconds ?? 0) > self.endTime){
                    let timescale = self.player?.currentItem?.asset.duration.timescale
                    let time = CMTimeMakeWithSeconds(self.startTime, preferredTimescale: timescale!)
                    self.player?.seek(to: time)
                }
                stopPlaybackTimeChecker()
                self.player?.pause()
                self.playImageView.isHidden = false
            }
        }
        else {
            startPlaybackTimeChecker()
            self.playImageView.tag = 1
            self.player?.play()
            self.playImageView.isHidden = true
        }
    }
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(self.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    @objc func onPlaybackTimeChecker() {

        guard let startTime = imageFrameView.startTime, let endTime = imageFrameView.endTime, let player = self.player else {
            return
        }

        let playBackTime = player.currentTime()
        imageFrameView.seek(to: playBackTime)

        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            imageFrameView.seek(to: startTime)
//            shaodowView.isHidden = false
            self.player?.pause()
            self.playImageView.isHidden = false

        }
    }
    func stopPlaybackTimeChecker() {

        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    @objc func findPlayerStatus() {
        switch self.player?.status {
        case .unknown:
            break
        case .readyToPlay:
            if self.seconds > 0 {
                if let durations = self.player?.currentItem?.duration {
                    let durationSeconds = CMTimeGetSeconds(durations)
                    if let currentItem = self.player?.currentTime()
                    {
                        let currentSec = CMTimeGetSeconds(currentItem)
                    }
                }
            }
        default:
            break
        }
    }
    @objc func itemDidFinishPlaying() {
        if let startTime = imageFrameView.startTime {
            player?.seek(to: startTime)
        }
        self.player?.pause()
        self.playImageView.tag = 0
        self.playImageView.isHidden = false

    }
        
    func jsonString(from object: [String]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

    @IBAction func postButtonAct(_ sender: UIButton) {
        self.player?.pause()
        self.playImageView.isHidden = false
        AVAsset(url: self.outputURL!).generateThumbnail { [weak self] (image) in
            DispatchQueue.main.async {
                guard let image = image else { return }
                guard let self = self else { return }
                guard let url = self.outputURL else { return }
                print("outputURL",self.outputURL)
                self.previewThumbImageView.image = image
             
                do {
                    let videoData = try Data(contentsOf: url)
                    if let delegate = UIApplication.shared.delegate as? AppDelegate {
                        //let duration = Int(((self.player?.currentItem?.duration.seconds ?? Double(0))*1000))
                        
                        let duration = Int(((self.endTime)*1000))
                        
                        print("urlvideo:\(url.lastPathComponent)")
                        
                        print("entTime:duration:\(duration)")
                        print("entTime:\(Int(self.endTime))")
                        
                        print("entTime.textin secs:\(self.secondsToHoursMinutesSeconds(Int(self.endTime)))")
                        
                        print("duration_selected:\(self.player?.currentItem?.duration.seconds)")
                        
                        if Int(self.endTime) >= self.VIDEO_MINIMUM_DURATIONS && Int(self.endTime) <= self.VIDEO_MAXIMUM_DURATIONS  {
                            let pageObj = CameraViewController()
                            pageObj.videoDuration = duration
                            pageObj.galleryType = self.type
                            pageObj.thumbVideoImage = image
                            pageObj.fileName = url.lastPathComponent
                            pageObj.videoData = videoData
                            self.navigationController?.pushViewController(pageObj, animated: true)
                        }else{
                            var message = ""
                            
                            if Int(self.endTime) < self.VIDEO_MINIMUM_DURATIONS{
                                message = "video_duration_should_be_min"
//                                let alert = UIAlertController(title: "", message: (getLanguage[message] ?? "") + " \(VIDEO_MINIMUM_DURATIONS/60) " + " \("minutes") ", preferredStyle: .alert)
//                                alert.addAction(UIAlertAction(title: (getLanguage["ok"] ?? ""), style: .cancel, handler: nil))
//                                self.present(alert, animated: true, completion: nil)
//                                let value = (self.secondsToHoursMinutesSeconds(Int(VIDEO_MINIMUM_DURATIONS)))
                                
                                let alert = UIAlertController(title: "", message: (getLanguage[message] ?? "") + " \(self.VIDEO_MINIMUM_DURATIONS) " + "\(getLanguage["seconds"] ?? "seconds")", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: (getLanguage["ok"] ?? ""), style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                alert.view.tintColor = UIColor(named: "DefaultBoxClr")
                        
                            }else if Int(self.endTime) > self.VIDEO_MAXIMUM_DURATIONS{
                                message = "video_duration_should_be_max"
//                                let alert = UIAlertController(title: "", message: (getLanguage[message] ?? "") + " \(VIDEO_MAXIMUM_DURATIONS/60) " + " \("minutes") ", preferredStyle: .alert)
//                                alert.addAction(UIAlertAction(title: (getLanguage["ok"] ?? ""), style: .cancel, handler: nil))
//                                self.present(alert, animated: true, completion: nil)
//
//                                let value = (self.secondsToHoursMinutesSeconds(Int(VIDEO_MINIMUM_DURATIONS)))
                                
                                let alert = UIAlertController(title: "", message: (getLanguage[message] ?? "") + " \(self.VIDEO_MAXIMUM_DURATIONS) " + "\(getLanguage["seconds"] ?? "seconds")", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: (getLanguage["ok"] ?? ""), style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                alert.view.tintColor = UIColor(named: "DefaultBoxClr")
                            }
                        }
//                        pageObj.modalPresentationStyle = .fullScreen
//                        self.present(pageObj, animated: true)
                       // delegate.initVC(initialView: pageObj)
                        
                    }
                }
                catch {
                    
                }
            }
        }
    
        /*
         //samples
        self.player?.pause()
        self.processingView.isHidden = false
        self.processingLoader.startAnimating()
        AVAsset(url: self.outputURL!).generateThumbnail { [weak self] (image) in

            DispatchQueue.main.async {
                guard let image = image else { return }
                guard let self = self else { return }
                guard let url = self.outputURL else { return }
                self.previewThumbImageView.image = image
                do {
                    self.progressView.isHidden = true
                    let videoData = try Data(contentsOf: url)
                    ProductsVideoParsing().postVideo(image: image, videoData: videoData, fileName: url.lastPathComponent) { status, progress in
                        print("Progress: \(progress)")
                        let progresspercent = Float(progress.fractionCompleted)*100
                        let aString: String = String(format: "%.0f", progresspercent) // "1"
                        
                        self.processingLabel.text = "Uploading \(aString)%"
                        self.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
                        self.progressView.isHidden = false
//                        self.pr
                    } onSuccess: { json in
                        self.postView(json["thumbnail"].stringValue, video: json["stream"].stringValue)
                        print("json: \(json)")
                    } onFailure: { error in
                        self.processingView.isHidden = true
                        self.processingLoader.stopAnimating()

                        print("error: \(error)")
                    }
                }
                catch {
                    
                }
            }
        }
        */
    }
    
    /*
    func postView(_ image: String, video: String) {
        let products = self.jsonString(from: self.selectedIDArray)
        let duration = Int(((self.player?.currentItem?.duration.seconds ?? Double(0))*1000))
        CameraViewModel().postVideo(user_id: USER_ID, products: (products ?? ""), duration: "\(duration)", type: self.type, stream: video, thumb: image) { status in
            self.processingView.isHidden = true
            self.processingLoader.stopAnimating()
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                let view = VideoListVC()
                view.isRootVC = true
                delegate.initVC(initialView: view)
            }
        } onFailure: { error in
            
        }
    }
    */
    
    @IBAction func closeButtonAct(_ sender: UIButton) {
        self.player?.pause()
       // self.dismiss(animated: true)
        self.playerObserver = nil
        self.observer?.invalidate()
        self.delegate1?.updatecount(status: true)
        self.navigationController?.popViewController(animated: true)
    }
    override func loadAsset(_ asset: AVAsset) {
        imageFrameView.asset = asset
        imageFrameView.delegate = self
        let videoDuration = Double(self.VIDEO_MAXIMUM_DURATIONS)
        self.imageFrameView.minDuration = 0.5
        self.imageFrameView.maxDuration = videoDuration/60
//        self.imageFrameView.moveri
        self.imageFrameView.moveRightHandle(to: CMTime(seconds: videoDuration, preferredTimescale: 1000))
        self.imageFrameView.moveLeftHandle(to: CMTime(seconds: 0, preferredTimescale: 1000))
//        addVideoPlayer(with: asset, playerView: firstPlayerView)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PreviewVC: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        self.player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        startPlaybackTimeChecker()
        print("postion 1")
        self.startTime = imageFrameView.startTime?.seconds ?? Double(0)
        self.endTime = imageFrameView.endTime?.seconds ?? Double(0)
        let startInTime = self.secondsToHoursMinutesSeconds(Int(self.startTime))
        let entTime = self.secondsToHoursMinutesSeconds(Int(self.endTime))
        let different = self.endTime - self.startTime
        let DiffTime = self.secondsToHoursMinutesSeconds(Int(different))
        self.selectedStartTimeTextField.text = DiffTime
        self.startTimeTextField.text = startInTime
        self.endTimeTextField.text = entTime
        self.postButton.isUserInteractionEnabled = true
        if self.playImageView.tag != 1 {
            self.playImageView.isHidden = true
            self.player?.play()
        }
    }
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
        return String(format:"%02d:%02d", (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        self.player?.pause()
        self.player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        let duration = (imageFrameView.endTime! - imageFrameView.startTime!).seconds
        self.startTime = imageFrameView.startTime?.seconds ?? Double(0)
        self.endTime = imageFrameView.endTime?.seconds ?? Double(0)
                
        let startInTime = self.secondsToHoursMinutesSeconds(Int(self.startTime))
        let entTime = self.secondsToHoursMinutesSeconds(Int(self.endTime))
        let different = self.endTime - self.startTime
        let DiffTime = self.secondsToHoursMinutesSeconds(Int(different))
        self.selectedStartTimeTextField.text = DiffTime
        self.startTimeTextField.text = startInTime
        self.endTimeTextField.text = entTime
        self.postButton.isUserInteractionEnabled = true
        self.playImageView.isHidden = false
    }

    func isAudioAvailable() -> Bool? {
        return self.player?.currentItem?.asset.tracks.filter({$0.mediaType == AVMediaType.audio}).count != 0
    }
}

/*
extension PreviewVC : selectedID{
    func selectedIDArray(ids: [String]) {
        print("here comes")
        self.selectedIDArray = ids
    }
}
*/
