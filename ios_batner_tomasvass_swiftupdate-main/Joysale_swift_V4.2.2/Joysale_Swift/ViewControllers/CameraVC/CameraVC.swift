//
//  CameraVC.swift
//  ProductsVideo
//
//  Created by MAC BOOK on 07/11/22.
//

import UIKit
import BBMetalImage
import PhotosUI
import AVKit
import AssetsPickerViewController

class CameraVC: UIViewController {

    
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var reshootButton: UIButton!
    @IBOutlet weak var cancelTitleLabel: UILabel!
    @IBOutlet weak var filterPropertyStackView: UIStackView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var recordDoneButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var cameraPropertyStackView: UIStackView!
    @IBOutlet weak var wholeFilterStackView: UIStackView!
    @IBOutlet weak var filterCancelButton: UIButton!
    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var filterStackView: UIStackView!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var timerimageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var flashStackView: UIStackView!
    @IBOutlet weak var flashImageView: UIImageView!
    @IBOutlet weak var flashLabel: UILabel!
    @IBOutlet weak var flipStackView: UIStackView!
    @IBOutlet weak var flipLabel: UILabel!
    @IBOutlet weak var flipImageView: UIImageView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var galleryStackView: UIStackView!
    @IBOutlet weak var galleryLabel: UILabel!
    @IBOutlet weak var timerCountLabel: UILabel!
    
    private var camera: BBMetalCamera!
    private var metalView: BBMetalView!
    private var videoWriter: BBMetalVideoWriter!
    private var type: FilterType!
    private var filterSelectedIndex = IndexPath(row: 0, section: 0)

    private var selectedAssetIdentifiers = [String]()
    private var selectedAssetIdentifierIterator: IndexingIterator<[String]>?
    private var currentAssetIdentifier: String?

    private var timerCount = 5
    private var timerStatus = false
    private var totalTime = 0
    var isTabBar = true
    var isTapCamera = false
    private var videoRecordingIsPause = false
    
    var selectedIDArray = [String]()
    
    var isCameraEnabled = false
    var isAudioEnabled = false
    private var videoFetchResult: PHFetchResult<PHAsset>?

    let VIDEO_MAXIMUM_DURATIONS: Int = 60
    let VIDEO_MINIMUM_DURATIONS: Int = 3
    
    private var filePath: String {
        get {
            return NSTemporaryDirectory() + "poststory.mp4"
        }
    }
    private var url: URL {
        get {
            return URL(fileURLWithPath: filePath)
        }
    }
    private var countdownTimer: Timer!

    private var filter: BBMetalBaseFilter? {
        guard let filterType = type else { return nil}
        switch filterType {
        case .brightness: return BBMetalBrightnessFilter(brightness: 0.15)
        case .exposure: return BBMetalExposureFilter(exposure: 0.5)
        case .contrast: return BBMetalContrastFilter(contrast: 1.5)
        case .saturation: return BBMetalSaturationFilter(saturation: 2)
        case .gamma: return BBMetalGammaFilter(gamma: 1.5)
        case .levels: return BBMetalLevelsFilter(minimum: .red)
        case .colorMatrix:
            var matrix: matrix_float4x4 = .identity
            matrix[0][1] = 1
            matrix[2][1] = 1
            matrix[3][1] = 1
            return BBMetalColorMatrixFilter(colorMatrix: matrix)
        case .rgba: return BBMetalRGBAFilter(red: 1.2)
        case .hue: return BBMetalHueFilter(hue: 90)
        case .vibrance: return BBMetalVibranceFilter(vibrance: 1)
        case .whiteBalance: return BBMetalWhiteBalanceFilter(temperature: 7000)
        case .highlightShadow: return BBMetalHighlightShadowFilter(shadows: 0.5, highlights: 0.5)
        case .highlightShadowTint: return BBMetalHighlightShadowTintFilter(shadowTintColor: .blue,
                                                                           shadowTintIntensity: 0.5,
                                                                           highlightTintColor: .red,
                                                                           highlightTintIntensity: 0.5)
        case .colorInversion: return BBMetalColorInversionFilter()
        case .monochrome: return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.7, green: 0.6, blue: 0.5), intensity: 1)
        case .falseColor: return BBMetalFalseColorFilter()
        case .haze: return BBMetalHazeFilter(distance: 0.2)
        case .luminance: return BBMetalLuminanceFilter()
        case .luminanceThreshold: return BBMetalLuminanceThresholdFilter(threshold: 0.6)
        case .erosion: return BBMetalErosionFilter(pixelRadius: 2)
        case .rgbaErosion: return BBMetalRGBAErosionFilter(pixelRadius: 2)
        case .dilation: return BBMetalDilationFilter(pixelRadius: 2)
        case .rgbaDilation: return BBMetalRGBADilationFilter(pixelRadius: 2)
        case .chromaKey: return BBMetalChromaKeyFilter(colorToReplace: .blue)
        case .crop: return BBMetalCropFilter(rect: BBMetalRect(x: 0.25, y: 0.5, width: 0.5, height: 0.5))
        case .resize: return BBMetalResizeFilter(size: BBMetalSize(width: 0.5, height: 0.8))
        case .rotate: return BBMetalRotateFilter(angle: -120, fitSize: true)
        case .flip: return BBMetalFlipFilter(horizontal: true, vertical: true)
        case .sharpen: return BBMetalSharpenFilter(sharpeness: 0.5)
        case .unsharpMask: return BBMetalUnsharpMaskFilter(intensity: 4)
        case .gaussianBlur: return BBMetalGaussianBlurFilter(sigma: 3)
        case .boxBlur: return BBMetalBoxBlurFilter(kernelWidth: 25, kernelHeight: 65)
        case .zoomBlur: return BBMetalZoomBlurFilter(blurSize: 3, blurCenter: BBMetalPosition(x: 0.35, y: 0.55))
        case .motionBlur: return BBMetalMotionBlurFilter(blurSize: 5, blurAngle: 30)
        case .tiltShift: return BBMetalTiltShiftFilter()
        case .pixellate: return BBMetalPixellateFilter()
        case .polarPixellate: return BBMetalPolarPixellateFilter(pixelSize: BBMetalSize(width: 0.05, height: 0.07), center: BBMetalPosition(x: 0.35, y: 0.55))
        case .polkaDot: return BBMetalPolkaDotFilter()
        case .halftone: return BBMetalHalftoneFilter()
        case .crosshatch: return BBMetalCrosshatchFilter(crosshatchSpacing: 0.01)
        case .sketch: return BBMetalSketchFilter()
        case .thresholdSketch: return BBMetalThresholdSketchFilter(threshold: 0.15)
        case .toon: return BBMetalToonFilter()
        case .posterize: return BBMetalPosterizeFilter()
        case .kuwahara: return BBMetalKuwaharaFilter()
        case .swirl: return BBMetalSwirlFilter(center: BBMetalPosition(x: 0.35, y: 0.55), radius: 0.25)
        case .convolution3x3: return BBMetalConvolution3x3Filter(convolution: simd_float3x3(rows: [SIMD3<Float>(-1, 0, 1),
                                                                                                   SIMD3<Float>(-2, 0, 2),
                                                                                                   SIMD3<Float>(-1, 0, 1)]))
        case .emboss: return BBMetalEmbossFilter(intensity: 1)
        case .sobelEdgeDetection: return BBMetalSobelEdgeDetectionFilter()
        case .bilateralBlur: return BBMetalBilateralBlurFilter()
        case .beauty: return BBMetalBeautyFilter()
        }
    }
    private var video_id: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.cameraPermission()
        self.micophonePermission()
       
  
//        if self.isCameraEnabled && isAudioEnabled {
            self.configUI()
//        }
        let options = PHFetchOptions()
           options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
           options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
           self.videoFetchResult = PHAsset.fetchAssets(with: .video, options: options)

           PHPhotoLibrary.shared().register(self)
        print("selectedIDArray_CameraVC:\(self.selectedIDArray)")
    }
    
    @objc func appWillEnterForeground() {
        self.cameraPermission()
        self.micophonePermission()
    }

    @objc func appDidEnterBackground() {
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
//        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        self.updateTheme(page: "present")
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "AddhemeColorNew")!)
        self.checkAndSetup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
   
        self.tabBarController?.tabBar.isHidden = true
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "AddhemeColorNew")!)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        self.turnOffTorch()
        camera?.stop()
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
       }
    
    @IBAction func ShipbtnTapped(_ sender: Any) {
        self.isTapCamera = true
        let pageObj = CameraViewController()
        pageObj.isTabBar = true
        pageObj.isSkip = "image"
        self.navigationController?.pushViewController(pageObj, animated: true)
        
    }
    
    

    func cameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (videoGranted: Bool) in
            DispatchQueue.main.async {
                self.isCameraEnabled = videoGranted
                print("print::1:")
                if !videoGranted {
                    self.permissionAlert(type: "camera")
                }
                self.checkAndSetup()
            }
        }
    }

    func micophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { (audioGranted: Bool) in
            DispatchQueue.main.async {
                print("print::2:")
                self.isAudioEnabled = audioGranted
                if !audioGranted {
                    self.permissionAlert(type: "microphone")
                }
                self.checkAndSetup()
            }
        }
    }

//    func checkAndSetup() {
//        if self.isCameraEnabled && self.isAudioEnabled {
//            self.setup()
//            DispatchQueue.main.async {
//                self.camera.start()
//            }
//        }
//    }
    
    func checkAndSetup() {
        if isCameraEnabled && isAudioEnabled {
            if camera == nil {   // ✅ Only create once
                setup()
            }
            camera?.start()       // ✅ Start safely
        }
    }

    
    func permissionAlert(type: String) {
        var message = ""
        if type == "camera" {
            message = "camera_permission"
        } else {
            message = "mic_permission"
        }
        let alert = UIAlertController(title: "", message: getLanguage[message], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (UIAlertAction) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        alert.view.tintColor = UIColor(named: "DefaultBoxClr")
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func configUI() {
        
        print("joker:\(self.recordButton.tag)")
        recordButton.setImage(#imageLiteral(resourceName: "product_start"), for: .normal)
        self.tabBarController?.tabBar.isHidden = true
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "AddhemeColorNew")!)
        self.cancelView.isHidden = true
        self.progressView.isHidden = true
        self.recordDoneButton.isHidden = true
        self.wholeFilterStackView.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        
        self.filterLabel.config(color: .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "filter")
        self.timerLabel.config(color: .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "timer")
        self.flashLabel.config(color: .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "flash")
        self.cancelTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "Discard current recording progress?")
        self.timerCountLabel.config(color: .white, font: UIFont(name: APP_FONT_BOLD, size: 35), align: .center, text: "")
        self.flipLabel.config(color: .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "flip")
        self.galleryLabel.config(color: .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "gallery")
        self.filterTitleLabel.config(color: .white, font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, text: "portrait")
        
        self.reshootButton.config(color: UIColor.init(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, title: "reshoot")
        self.cancelButton.config(color: UIColor.init(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, title: "cancel")
        self.exitButton.config(color: UIColor.init(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, title: "exit")
        

        self.flashStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.flashAct(_:))))
        self.flipStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.flipAct(_:))))
        self.galleryStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.galleryAct(_:))))
        self.filterStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.filterAct)))
        self.timerStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.timerAct)))
        self.collectionView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
        self.timerCountLabel.isHidden = true
        if self.isCameraEnabled && isAudioEnabled {
                   self.setup()
            
                  
        }
   
        self.changeRTL()
    }
    
    func changeRTL(){
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
            self.topStackView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.bottomView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.flipLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.galleryLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.filterLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timerLabel.transform =  CGAffineTransform(scaleX: -1, y: 1)
            self.flashLabel.transform =  CGAffineTransform(scaleX: -1, y: 1)
            self.galleryImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.flipImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.filterImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.flashImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.timerimageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.recordDoneButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.filterTitleLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.cancelView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.cancelTitleLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.reshootButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.exitButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.cancelButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    func turnOffTorch() {
        self.recordButton.isUserInteractionEnabled = true
        self.recordDoneButton.isUserInteractionEnabled = true
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                self.flashImageView.image = UIImage(named: "newfalsh")
                device.torchMode = AVCaptureDevice.TorchMode.off
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    func setup() {
        metalView = BBMetalView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        view.addSubview(metalView)
        view.sendSubviewToBack(metalView)
        videoWriter = BBMetalVideoWriter(url: url, frameSize: BBMetalIntSize(width: 1080, height: 1920))
        camera = BBMetalCamera(sessionPreset: .hd1920x1080)
        camera.audioConsumer = videoWriter
        camera.add(consumer: metalView)
        camera.add(consumer: videoWriter)
    }
    @objc func filterAct() {
        self.wholeFilterStackView.isHidden = !self.wholeFilterStackView.isHidden
        self.cameraPropertyStackView.isHidden = !self.wholeFilterStackView.isHidden
    }
    @IBAction func closeButtonAct(_ sender: UIButton) {

        
        if recordDoneButton.tag == 0{
            self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
            self.navigationController?.isNavigationBarHidden = false
            self.tabBarController?.selectedIndex = 0
            self.tabBarController?.tabBar.isHidden = false
           
        }else{
            self.cancelView.isHidden = false
        }
     
        

        
    }
    @IBAction func recordButtonAct(_ sender: UIButton) {
        print("print the record tag \(self.recordDoneButton.tag)")
        print("print the checking 1")
        guard recordDoneButton.tag == 0 else {
            print("print the checking 2")
            self.recordButton.isUserInteractionEnabled = false
            self.recordDoneButton.isUserInteractionEnabled = false
            return self.videoRecorderFinish()
        }
        
        if recordDoneButton.tag == 0 {
            print("print the checking 10")
            recordDoneButton.tag = 1
            self.topStackView.isHidden = false
            self.filterPropertyStackView.isHidden = true
            self.bottomView.isHidden = false
            self.cameraPropertyStackView.isHidden = false
            self.flipLabel.isHidden = true
            self.flipImageView.isHidden = true
            self.flipStackView.isHidden = false
            self.galleryStackView.isHidden = true
            self.recordDoneButton.isHidden = false
            self.progressView.isHidden = false
            
        }
        self.validateButtons()
         startVideoRecord()
     }
    
    func validateButtons() {
        if NSDecimalNumber(decimal: Decimal(self.totalTime)/60000).floatValue > 0.03 {
            print("print the checking 11")
            self.recordDoneButton.isEnabled = true
            self.recordDoneButton.alpha = 1.0
            self.recordButton.isEnabled = true
            self.recordButton.alpha = 1.0
        } else {
            print("print the checking 12")
            self.recordDoneButton.isEnabled = false
            self.recordDoneButton.alpha = 0.3
            self.recordButton.isEnabled = false
            self.recordButton.alpha = 0.3
        }
    }
    
    @IBAction func cancelButtonsAct(_ sender: UIButton) {
        if sender == reshootButton {
            self.cancelView.isHidden = true
            self.totalTime = 0
            self.recordDoneButton.tag = 1
            self.progressView.setProgress(0, animated: true)
            self.recordButton.isEnabled = false
            self.recordButton.alpha = 0.3
            self.recordDoneButton.isEnabled = false
            self.recordDoneButton.alpha = 0.3
            videoWriter.finish { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.startCamera()
                    self.recordButton.isEnabled = true
                    self.recordButton.alpha = 1.0
//                    self.closeButton.isEnabled = true
                }
            }
        }
        else if sender == cancelButton {
            self.cancelView.isHidden = true

        }
        else {
            videoWriter.finish { [weak self] in
                
            }
            self.cancelView.isHidden = true

            self.camera.resetBenchmark()
            self.camera.start()
            
            recordButton.tag = 0
            recordButton.setImage(#imageLiteral(resourceName: "product_start"), for: .normal)
            
            self.progressView.setProgress(0, animated: true)
            self.recordButton.isEnabled = true
            self.recordButton.alpha = 1.0
            stopProgressView()
            
            recordDoneButton.tag = 0
            self.recordDoneButton.isEnabled = false
            self.recordDoneButton.alpha = 0.3
           
            self.totalTime = 0
            self.topStackView.isHidden = false
            self.filterPropertyStackView.isHidden = false
            self.bottomView.isHidden = false
            self.wholeFilterStackView.isHidden = true
            self.cameraPropertyStackView.isHidden = false
            self.progressView.isHidden = true
           
            self.recordDoneButton.isHidden = true
            self.flipStackView.isHidden = false
            self.flipLabel.isHidden = false
            self.flipImageView.isHidden = false
            self.galleryStackView.isHidden = false
            self.recordButton.isHidden = false
            self.timerCountLabel.isHidden = true
            
            self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
            self.navigationController?.isNavigationBarHidden = false
            self.tabBarController?.selectedIndex = 0
            self.tabBarController?.tabBar.isHidden = false
//            
//            self.navigationController?.navigationBar.isHidden = false
//            self.tabBarController?.selectedIndex = 0
//            self.tabBarController?.tabBar.isHidden = false
//            self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
            
           // self.dismiss(animated: true)
        }
    }
    @IBAction func filterCancelButtonAct(_ sender: UIButton) {
        self.wholeFilterStackView.isHidden = true
        self.cameraPropertyStackView.isHidden = false
    }
    @objc func flashAct(_ sender: UITapGestureRecognizer) {
        guard camera.position == .back else { return }
        if flashImageView.tag == 0 {
            flashImageView.tag = 1
            toggleFlash()
        } else {
            flashImageView.tag = 0
            toggleFlash()
        }
    }
    @objc func timerAct() {
        self.recordButton.isHidden = true
        if self.timerCountLabel.isHidden {
            timerStatus = true
            self.validateButtons()
            self.recordDoneButton.tag = 1
            self.timerCountLabel.isHidden = false
            self.timerCount = 5
            self.hideControls()
            self.timerCountAnimation()
        }
    }
    func timerCountAnimation() {
        if self.timerCount > 0 {
            self.timerCountLabel.text = "\(timerCount)"
            self.timerCountLabel.font = .systemFont(ofSize: 125)
            self.timerCountLabel.transform = self.timerCountLabel.transform.scaledBy(x: 0.25, y: 0.25)
            UIView.animate(withDuration: 1, animations: {
                self.timerCountLabel.transform = self.timerCountLabel.transform.scaledBy(x: 4, y: 4)
            }) { (Bool) in
                self.timerCount -= 1
                self.timerCountAnimation()
            }
        } else {
            self.timerCountLabel.isHidden = true
            if timerStatus {
                self.topStackView.isHidden = false
                self.filterPropertyStackView.isHidden = true
                self.bottomView.isHidden = false
                self.flipStackView.isHidden = false
                self.flipLabel.isHidden = true
                self.flipImageView.isHidden = true
                self.galleryStackView.isHidden = true
                self.recordButton.isHidden = false
                self.recordDoneButton.isHidden = false
                self.progressView.isHidden = false
                startVideoRecord()
            }
        }
    }
    func videoRecorderFinish() {
        print("print the checking 3")
        stopProgressView()
        if !videoRecordingIsPause {
            print("print the checking 5")
            videoFinish()
        } else {
            print("print the checking 6")
            if !isTapCamera{
                self.videoMerge()
            }
            
        }
    }
    func showPreview() {
    }
    func videoMerge() {
        print("Success")
        print("print the checking 7")
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            print("print the video url \(self.videoWriter.url)")
            let vc = PreviewVC(url: self.videoWriter.url)
            vc.selectedIDArray = self.selectedIDArray
            vc.type = "camera"
            vc.delegate1 = self
            /*
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
             */
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    func stopProgressView() {
        print("print the checking 4")
        if countdownTimer != nil {
            countdownTimer.invalidate()
            countdownTimer = nil
        }
        self.totalTime = 0
        self.recordDoneButton.tag = 0
    }
    func startVideoRecord() {
        print("print the checking 13")
        if recordButton.tag == 0 {
            videoStart()
        } else {
            videoFinish()
        }
    }
    func videoStart() {
        print("print the checking 14")
        recordButton.tag = 1
        recordButton.setImage(#imageLiteral(resourceName: "product_pause"), for: .normal)
        if videoRecordingIsPause {
            videoRecordingIsPause = false
        }
        startCamera()
    }
    func startCamera() {
        UIApplication.shared.isIdleTimerDisabled = true
        try? FileManager.default.removeItem(at: videoWriter.url)
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.startTimer()
            }
            self.videoWriter.start()
        }
    }
    
    func videoFinish() {
        print("print the checking 8 & 15")
        stopCamera()
        videoRecordingIsPause = true
        recordButton.tag = 0
        recordButton.setImage(#imageLiteral(resourceName: "product_start"), for: .normal)
        if countdownTimer != nil {
            countdownTimer.invalidate()
            countdownTimer = nil
        }
    }
    
    func stopCamera() {
        print("print the checking 9 & 16")
        UIApplication.shared.isIdleTimerDisabled = false

        videoWriter.finish { [weak self] in
            print("print the checking 10 & 16")
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("print the checking File manager \(FileManager.default) filepath \(self.filePath) url:\(self.url)")
                
                if FileManager.default.fileExists(atPath: self.filePath) {
                    print("print the checking 11 & 16")
                    if !self.isTapCamera{
                        self.videoMerge()
                    }
                }
            }
        }
    }
    
    
    
    func hideControls() {
        self.topStackView.isHidden = true
        self.bottomView.isHidden = true
    }
    func unHideControls() {
        self.topStackView.isHidden = false
        self.bottomView.isHidden = false
    }
    @objc func flipAct(_ sender: UITapGestureRecognizer) {
        self.switchCamera {
            if camera.position == .back {
                self.flashLabel.isHidden = false
                self.flashImageView.isHidden = false
                if self.flashImageView.tag == 1 {
                    toggleFlash()
                }
            } else {
                self.flashLabel.isHidden = true
                self.flashImageView.isHidden = true
            }
        }
    }
    func switchCamera(finished: () -> Void) {
        camera.switchCameraPosition()
        finished()
    }
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                self.flashImageView.image = UIImage(named: "newfalsh")
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    self.flashImageView.image = UIImage(named: "selectedflash")
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }

            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    /*
    @objc func galleryAct(_ sender: UITapGestureRecognizer) {
        let picker = AssetsPickerViewController()
        picker.pickerDelegate = self
        picker.pickerConfig.assetIsShowCameraButton = false
        picker.pickerConfig.selectedAssets = [PHAsset]()
        picker.pickerConfig.assetsMaximumSelectionCount = 1
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: true)]
        picker.pickerConfig.assetFetchOptions = [
            .smartAlbum: options,
            .album: options
        ]
        picker.navigationBar.barTintColor = UIColor(named: "AppThemeColor") ?? .white
        picker.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: APP_FONT_REGULAR, size: 20) ?? UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor(named: "whitecolor") ?? .black]
        picker.navigationBar.tintColor = UIColor(named: "whitecolor") ?? .white
        picker.modalPresentationStyle = .fullScreen
        self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
        present(picker, animated: true, completion: nil)
    }
     */
    
    @objc func galleryAct(_ sender: UITapGestureRecognizer) {
        // Build fetch options that return only videos
        let videoFetchOptions = PHFetchOptions()
        videoFetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        videoFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Configure the picker
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.assetIsShowCameraButton = false
        pickerConfig.assetsMinimumSelectionCount = 1
        pickerConfig.assetsMaximumSelectionCount = 1
        
        // IMPORTANT: keys are PHAssetCollectionType (albums / smart albums)
        pickerConfig.assetFetchOptions = [
            .smartAlbum: videoFetchOptions,
            .album: videoFetchOptions
        ]
        
        let picker = AssetsPickerViewController()
        picker.pickerConfig = pickerConfig
        picker.pickerDelegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
    }
  
    @objc func galleryActold(_ sender: UITapGestureRecognizer) {
        if checkLibrary() {
            if #available(iOS 14.0, *) {
                var configuration = PHPickerConfiguration(photoLibrary: .shared())
                // Set the filter type according to the user’s selection.
                configuration.filter = PHPickerFilter.videos
                // Set the mode to avoid transcoding, if possible, if your app supports arbitrary image/video encodings.
                configuration.preferredAssetRepresentationMode = .current
                // Set the selection behavior to respect the user’s selection order.
                if #available(iOS 15.0, *) {
                    configuration.selection = .default
    //                configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers
                } else {
                    // Fallback on earlier versions
                }
                // Set the selection limit to enable multiselection.
                configuration.selectionLimit = 1
                // Set the appearance for UIBarButtonItem
                
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                picker.view.tintColor = UIColor(named: "AppThemeColor")
                self.present(picker, animated: true)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    func checkLibrary()-> Bool {
        if #available(iOS 14.0, *) {
            var status = false
            let accessLevel: PHAccessLevel = .readWrite
            let photos = PHPhotoLibrary.authorizationStatus(for: accessLevel)
//            let photos = PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            switch photos {
            case .authorized, .limited:
                status = true
            case .notDetermined:
                var isAuthorized = false
                PHPhotoLibrary.requestAuthorization { newStatus in
                    if #available(iOS 14, *) {
                        isAuthorized = (newStatus == .authorized || newStatus == .limited)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                return isAuthorized
            case .denied:
                let alert = UIAlertController(title: nil, message: getLanguage["Not have permission to access Photo Libreary"] ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (UIAlertAction) in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                self.present(alert, animated: true)
                break
            default:
                break
            }
            if status {
                return true
            }
            else {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{
                        
                    } else {
                        
                    }
                })
                return false
            }
        }else{
            return false
        }
    }
}
extension CameraVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilterList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic"{
            cell.filterLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell.filterImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }else{
            cell.filterLabel.transform = .identity
            cell.filterImageView.transform = .identity
        }
        
        
        cell.loadData(indexPath.item, selected: filterSelectedIndex.item)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 95)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath != filterSelectedIndex {
            if let cell = collectionView.cellForItem(at: filterSelectedIndex) as? FilterCollectionViewCell {
                cell.filterImageView.layer.borderWidth = 0
                cell.filterImageView.layer.borderColor = UIColor.clear.cgColor
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
                cell.filterImageView.layer.borderWidth = 2
                cell.filterImageView.layer.borderColor = PRIMARY_COLOR.cgColor
                filterSelectedIndex = indexPath
            }
            if FilterList.indices.contains(indexPath.row){
                self.type = FilterList[indexPath.row].1
                print(FilterList[indexPath.row].0)
                camera.removeAllConsumers()
                if let filter = self.filter {
                    camera.add(consumer: filter).add(consumer: metalView)
                    filter.add(consumer: videoWriter)
                } else {
                    camera.add(consumer: metalView)
                    camera.willTransmitTexture = nil
                    camera.add(consumer: videoWriter)
                }
              
            }
        }
    }
    func startTimer() {
        if countdownTimer == nil {
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let audioDurationSeconds = self.VIDEO_MAXIMUM_DURATIONS
                print("audioDurationSeconds:\(audioDurationSeconds)")
                
                let audioDurationSeconds1 = self.VIDEO_MINIMUM_DURATIONS
                print("audioDurationSeconds1:\(audioDurationSeconds1)")
                
                let timeToPercentage = Decimal(self.totalTime)/Decimal(audioDurationSeconds)
                print("timeToPercentage:\(timeToPercentage)")
                
                let timeToPercentage1 = Decimal(self.totalTime)/Decimal(audioDurationSeconds1)
                print("timeToPercentage1:\(timeToPercentage1)")
                
                let minimum = Decimal(audioDurationSeconds1)/Decimal(audioDurationSeconds1)
                print("minimum:\(minimum)")
                
                if NSDecimalNumber(decimal: timeToPercentage1).floatValue >= (NSDecimalNumber(decimal: minimum).floatValue) {
                    self.recordDoneButton.isEnabled = true
                    self.recordDoneButton.alpha = 1.0
                    self.recordButton.isEnabled = true
                    self.recordButton.alpha = 1.0
                }
                self.progressView.setProgress(NSDecimalNumber(decimal: timeToPercentage).floatValue, animated: true)
                print("total time:\(self.totalTime) : \(NSDecimalNumber(decimal: timeToPercentage1).floatValue) : \(NSDecimalNumber(decimal: minimum).floatValue)")
                if self.totalTime <= audioDurationSeconds-2 {
                    self.totalTime += 1
                } else {
                    self.videoRecorderFinish()
                }
                
                /*
                let audioDurationSeconds = VIDEO_MAXIMUM_DURATION
                let timeToPercentage = Decimal(self.totalTime)/Decimal(audioDurationSeconds)
                if NSDecimalNumber(decimal: timeToPercentage).floatValue > 0.03 {
                    self.recordDoneButton.isEnabled = true
                    self.recordButton.isEnabled = true
                }
                self.progressView.setProgress(NSDecimalNumber(decimal: timeToPercentage).floatValue, animated: true)
                print("total time:\(self.totalTime) : \(NSDecimalNumber(decimal: timeToPercentage).floatValue)")
                if self.totalTime <= audioDurationSeconds-2 {
                    self.totalTime += 1
                } else {
                    self.videoRecorderFinish()
                }
                */
                
            }
        }
    }
    func reloadAssetsPicker() {
        // Dismiss if a picker is already being shown
        if let picker = self.presentedViewController as? AssetsPickerViewController {
            picker.dismiss(animated: false) {
                self.presentFreshPicker()
            }
        } else {
            // If no picker is open, just present directly
            presentFreshPicker()
        }
    }

    private func presentFreshPicker() {
        let videoFetchOptions = PHFetchOptions()
        videoFetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        videoFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let config = AssetsPickerConfig()
        config.assetIsShowCameraButton = false
        config.assetsMinimumSelectionCount = 1
        config.assetsMaximumSelectionCount = 1
        config.assetFetchOptions = [
            .smartAlbum: videoFetchOptions,
            .album: videoFetchOptions
        ]
        
        let picker = AssetsPickerViewController()
        picker.pickerConfig = config
        picker.pickerDelegate = self
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true, completion: nil)
    }


}



//extension CameraVC: AssetsPickerViewControllerDelegate {
//    // MARK: - AssetsPickerViewControllerDelegate
////    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
////        guard let asset = assets.first else { return }
////        
////        asset.getVideoURL { [weak self] localURL in
////            guard let self = self, let localURL = localURL else { return }
////            
////            print("Sandbox FileURL: \(localURL)")
////            
////            if !(self.isTapCamera ?? false) {
////                let vc = PreviewVC(url: localURL)
////                vc.selectedIDArray = self.selectedIDArray ?? []
////                vc.delegate1 = self
////                vc.type = "gallery"
////                self.navigationController?.pushViewController(vc, animated: true)
////            }
////        }
////    }
//
//    
//    
//    
//    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
//        guard let asset = assets.first else { return }
//        
//        asset.getVideoURL { [weak self] localURL in
//            guard let self = self, let localURL = localURL else { return }
//            
//            print("Sandbox FileURL: \(localURL)")
//            
//            if !(self.isTapCamera ?? false) {
//                let vc = PreviewVC(url: localURL)
//                vc.selectedIDArray = self.selectedIDArray ?? []
//                vc.delegate1 = self
//                vc.type = "gallery"
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//    }
//
//    
//       
//       func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
//           // handle permission denial if needed
//       }
//       
//       func assetsPickerDidCancel(controller: AssetsPickerViewController) {
//           controller.dismiss(animated: true, completion: nil)
//       }
//}



extension CameraVC: AssetsPickerViewControllerDelegate {
    
    // MARK: - Called whenever user taps a cell (live selection)
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        // ❌ Don’t handle here if you only want after Done
        // Just leave this empty or use for selection UI if needed
    }
    
    // MARK: - Called when user cancels (Done/Cancel button closes picker)
    func assetsPicker(controller: AssetsPickerViewController, didDismissByCancelling byCancel: Bool) {
        if byCancel { return }  // User tapped Cancel → do nothing
        
        // ✅ User tapped Done → handle selected assets
        let selectedAssets = controller.selectedAssets
        handlePickedAssets(selectedAssets)
    }
    
    // MARK: - Permission denied
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        // You can show an alert here if needed
        print("Cannot access photo library")
    }
    
    // MARK: - Central asset handler
    private func handlePickedAssets(_ assets: [PHAsset]) {
        guard let asset = assets.first else { return }
        
        asset.getVideoURL { [weak self] localURL in
            guard let self = self, let localURL = localURL else { return }
            
            print("Sandbox FileURL: \(localURL)")
            
            if !(self.isTapCamera ?? false) {
                let vc = PreviewVC(url: localURL)
                vc.selectedIDArray = self.selectedIDArray ?? []
                vc.delegate1 = self
                vc.type = "gallery"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}



@available(iOS 14.0, *)
extension CameraVC: PHPickerViewControllerDelegate/*, AssetsPickerViewControllerDelegate */{
    /*
    func getAssetResource(for asset: PHAsset) -> PHAssetResource? {
        return PHAssetResource.assetResources(for: asset).first
    }
    func getAssetURL(for asset: PHAsset, completion: @escaping (URL?) -> Void) {
        guard let resource = getAssetResource(for: asset) else {
            completion(nil)
            return
        }
        
        let fileManager = FileManager.default
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryFileName = UUID().uuidString
        let temporaryFilePath = (temporaryDirectory as NSString).appendingPathComponent(temporaryFileName)
        let temporaryFileURL = URL(fileURLWithPath: temporaryFilePath)
        
        PHAssetResourceManager.default().writeData(for: resource, toFile: temporaryFileURL, options: nil) { error in
            if let error = error {
                print("Error writing asset resource to file: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(temporaryFileURL)
            }
        }
    }
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        dismiss(animated: true)
        // Usage example
        if let asset = assets.first {
            getAssetURL(for: asset) { url in
                if let url = url {
                    // Use the URL here
                    print("Asset URL: \(url)")
                    DispatchQueue.main.async {
                        let vc = PreviewVC(url: url)
                        vc.selectedIDArray = self.selectedIDArray
                        vc.delegate1 = self
                        vc.type = "gallery"
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                } else {
                    print("Failed to get asset URL.")
                }
            }
        }

        
    }
     */
    /// - Tag: ParsePickerResults
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let result = results.first else { return }
        if let ident = result.assetIdentifier {
            let result1 = PHAsset.fetchAssets(withLocalIdentifiers: [ident], options: nil)
            if result1.firstObject != nil {
                let provider = result.itemProvider
                let progress: Progress?
                if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    progress = provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                        do {
                            guard let url = url, error == nil else {
                                throw error ?? NSError(domain: NSFileProviderErrorDomain, code: -1, userInfo: nil)
                            }
                            let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                            try? FileManager.default.removeItem(at: localURL)
                            try FileManager.default.copyItem(at: url, to: localURL)
                            DispatchQueue.main.async {
                                if !(self?.isTapCamera ?? false) {
                                    print("FileURL: \(localURL)")
                                    let vc = PreviewVC(url: localURL)
                                    vc.selectedIDArray = self?.selectedIDArray ?? [String]()
                                    vc.delegate1 = self
                                    vc.type = "gallery"
                                    /*
                                     vc.modalPresentationStyle = .fullScreen
                                     self?.present(vc, animated: true, completion: nil)
                                     */
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        } catch let catchedError {
                            DispatchQueue.main.async {
                                print("ERROR")
                                //                                self?.handleCompletion(assetIdentifier: assetIdentifier, object: nil, error: catchedError)
                            }
                        }
                    }
                }
            }else{
                let alert = UIAlertController(title: "", message: getLanguage["You don't have the access for this Video"], preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .default, handler: nil))
                alert.view.tintColor = UIColor(named: "DefaultBoxClr")
                self.present(alert, animated: true)
                print("This FileURL don't have access")
            }
        }
    }
}

extension CameraVC : uploadDelegate1 {
    func updatecount(status: Bool){
        
        self.cancelView.isHidden = true
        
        self.camera.resetBenchmark()
        self.camera.start()
        recordButton.tag = 0
        recordButton.setImage(#imageLiteral(resourceName: "product_start"), for: .normal)
        self.progressView.setProgress(0, animated: true)
        self.recordButton.isEnabled = true
        self.recordButton.alpha = 1.0
        stopProgressView()
        
        recordDoneButton.tag = 0
        self.recordDoneButton.isEnabled = false
        self.recordDoneButton.alpha = 0.3
       
        self.totalTime = 0
        self.topStackView.isHidden = false
        self.filterPropertyStackView.isHidden = false
        self.bottomView.isHidden = false
        self.wholeFilterStackView.isHidden = true
        self.cameraPropertyStackView.isHidden = false
        self.progressView.isHidden = true
       
        self.recordDoneButton.isHidden = true
        self.flipStackView.isHidden = false
        self.flipLabel.isHidden = false
        self.flipImageView.isHidden = false
        self.galleryStackView.isHidden = false
        self.recordButton.isHidden = false
        self.timerCountLabel.isHidden = true
        
    }
}




extension PHAsset {
    func getVideoURL(completion: @escaping (URL?) -> Void) {
        let resources = PHAssetResource.assetResources(for: self)
        guard let resource = resources.first else {
            completion(nil)
            return
        }
        
        let fileName = resource.originalFilename
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // Remove old file if exists
        try? FileManager.default.removeItem(at: outputURL)
        
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHAssetResourceManager.default().writeData(for: resource, toFile: outputURL, options: options) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Export error: \(error)")
                    completion(nil)
                } else {
                    completion(outputURL)
                }
            }
        }
    }
}
extension CameraVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = videoFetchResult,
              let changes = changeInstance.changeDetails(for: fetchResult) else {
            return
        }
        DispatchQueue.main.async {
            // Keep the updated fetch result
            self.videoFetchResult = changes.fetchResultAfterChanges
            // Now refresh your picker / gallery preview
            self.reloadAssetsPicker()
        }
    }

}


