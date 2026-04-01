//
//  CameraViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 23/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import AssetsPickerViewController
import Photos
import PhotosUI
import BBMetalImage
class CameraViewController: UIViewController {

    @IBOutlet weak var navigationStackView: UIStackView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var splashButton: UIButton!
    @IBOutlet weak var camChangeButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var qrCodeFrameView: UIView?
    var defaultVideoDevice: AVCaptureDevice?
    var imageArray = [AddProductImageModel]()
    var selectedImageArray = [AddProductImageModel]()
    var addProductVC: AddProductViewController?
    var isTabBar = true
    let motionManager = CMMotionManager()
    var orientationLast = UIInterfaceOrientation(rawValue: 0)
    private var flashMode: AVCaptureDevice.FlashMode = .off
    var removedArray = [AddProductImageModel]()
  
    
    var thumbVideoImage = UIImage()
    var videoData: Data!
    var fileName : String!
    var videoDuration : Int!
    var galleryType : String?
    var isSkip = ""
   // var viewModel = AdminViewModel()
    //var value = "false"
    var getFreePost = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.loadSubScriptionData()
        //        self.captureButton.isUserInteractionEnabled = false
        self.configUI()
        
       
    }
    
   
    func stopCamera() {
        captureSession?.stopRunning()
        captureSession = nil
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.motionManager.stopAccelerometerUpdates()
        self.stopCamera()

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateTheme(page: "present")
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "AddhemeColorNew")!)
        self.initializeMotionManager()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true

        if captureSession == nil {
            // If it was torn down, set it up again
            self.moveToCamera()
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.initCaptureDevice()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    func configUI() {
        
        self.galleryButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 20), align: .center, title: "gallery")
        self.nextButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 20), align: .center, title: "next")

        self.collectionView.register(UINib(nibName: "CameraCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CameraCollectionViewCell")
//        if #available(iOS 13.0, *) {
//            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIScene.didActivateNotification, object: nil)
//
//        } else {
//            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
//        }
        self.moveToCamera()
    }
    @objc func didBecomeActive(_ notification: Notification) {
        // code to execute
        self.captureSession?.startRunning()
    }
    @objc func willResignActive(_ notification: Notification) {
        // code to execute
        self.captureSession?.stopRunning()
    }
    func initializeMotionManager() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.gyroUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData, error) in
            if error == nil {
                self.outputAccelertionData(accelerometerData!.acceleration)
            }
        }
        
    }
    func outputAccelertionData(_ acceleration: CMAcceleration) {
        var orientationNew = UIInterfaceOrientation(rawValue: 0)
        if (acceleration.x >= 0.75) {
            orientationNew = .landscapeLeft
        }
        else if (acceleration.x <= -0.75) {
            orientationNew = .landscapeRight
        }
        else if (acceleration.y <= -0.75) {
            orientationNew = .portrait
        }
        else if (acceleration.y >= 0.75) {
            orientationNew = .portraitUpsideDown
        }
        else {
            return
        }
        if orientationNew == orientationLast {
            return
        }
        orientationLast = orientationNew
    }

    func initCaptureDevice() {
        var isAvailable = true
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            isAvailable = false
        case .restricted:
            isAvailable = false
        case .authorized:
            isAvailable = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    isAvailable = true
                } else {
                    //access denied
                    isAvailable = false
                }
            })
        default:
            isAvailable = false
        }
        if !isAvailable {
            let alert = UIAlertController(title: nil, message: (getLanguage["Not have permission to access camera"] ?? ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["allow"] ?? "allow", style: .default, handler: { (UIAlertAction) in
                self.navigationController?.isNavigationBarHidden = false
                self.tabBarController?.selectedIndex = 0
                self.tabBarController?.tabBar.isHidden = false
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func moveToCamera() {
       
        if defaultVideoDevice == nil {
            guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
//                fatalError("No video device found")
                return
            }
            defaultVideoDevice = captureDevice
        }
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
            let input = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            // Initialize the captureSession object
            captureSession = AVCaptureSession()
            
            // Set the input devcie on the capture session
            captureSession?.addInput(input)
            
            // Get an instance of ACCapturePhotoOutput class
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            
            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)
            //            self.captureButton.isUserInteractionEnabled = true
            // Initialize a AVCaptureMetadataOutput object and set it as the input device
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewView.layer.addSublayer(videoPreviewLayer!)
            videoPreviewLayer?.frame = self.previewView.bounds
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            //start video capture
            captureSession?.startRunning()
            videoPreviewLayer?.frame = self.previewView.bounds

            //Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.captureButton.isUserInteractionEnabled = true
            }
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
    }
    override func viewDidLayoutSubviews() {
        //self.loadSubScriptionData()
        videoPreviewLayer?.frame = self.previewView.bounds
        if let previewLayer = videoPreviewLayer ,(previewLayer.connection?.isVideoOrientationSupported)! {
            previewLayer.connection?.videoOrientation = .portrait
        }
    }
    @IBAction func captureButtonAct(_ sender: UIButton) {
        // Make sure capturePhotoOutput is valid
        self.nextButton.isUserInteractionEnabled = false
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = self.flashMode
//        let previewPixelType = photoSettings.availablePreviewPhotoPixelFormatTypes.first!
//        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
//                             kCVPixelBufferWidthKey as String: self.previewView.frame.width,
//                             kCVPixelBufferHeightKey as String: self.previewView.frame.height] as [String : Any]
//        photoSettings.previewPhotoFormat = previewFormat
        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    /*
    func loadSubScriptionData(){
        
        let group = DispatchGroup()
        group.enter()
        
        self.viewModel.getProfileDetailCount(user_id:  UserDefaultModule.shared.getUserData()?.user_id ?? "", onSuccess:{ (val) in
            print(val)
            if self.viewModel.postProductModel?.status ?? false{
                let res = self.viewModel.postProductModel?.result.first
                self.getFreePost = res!.subscriptionEnable
                if self.getFreePost != 0{
                    self.value = "false"
                }else{
                    self.value = "true"
                }
            }
            group.leave()
        })
        { (failure) in
            self.value = "true"
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            if self.value == "true" {

            }
            else {
                
            }
        }
         
    }
    */
    @IBAction func nextButtonAct(_ sender: UIButton) {
        //self.loadSubScriptionData()

     //   if self.value == "true" {
        
        if self.selectedImageArray.count <= 15 && self.selectedImageArray.count > 0 {
            if isTabBar {
//                self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
            
                self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
                let pageObj = AddProductViewController()
                pageObj.thumbVideoImage = self.thumbVideoImage
                pageObj.fileName = self.fileName
                pageObj.videoData = self.videoData
                pageObj.videoDuration = self.videoDuration
                pageObj.galleryType = "camera"
                pageObj.isskip = self.isSkip
                pageObj.imageArray = self.selectedImageArray
                self.navigationController?.pushViewController(pageObj, animated: true)
            }
            else {
                self.addProductVC?.imageArray = self.selectedImageArray
//                self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
               self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
                let uploadedArray = self.imageArray.filter({$0.isuploaded == true})
                for uploadedImage in uploadedArray {
                    if !self.selectedImageArray.contains(where: {$0.imageUrl == uploadedImage.imageUrl}) {
                        removedArray.append(uploadedImage)
                    }
                }
                self.addProductVC?.removeArray = removedArray
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            let alert = UIAlertController(title: nil, message: getLanguage["only 5 images are allowed to add"] ?? "", preferredStyle: .alert)

            if self.selectedImageArray.count == 0 {
                alert.message =  getLanguage["Please Select images to continue"] ?? ""
            }
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            
          /*
        }
        else{
            if self.value == "false"{
            let alert = UIAlertController(title: nil, message: getLanguage["please_subscribe"] ?? "", preferredStyle:UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                UIAlertAction in
                NSLog("OK Pressed")
                let newObj = SubscribePlanPage()
                self.navigationController?.pushViewController(newObj, animated: true)
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            }
            
        }
 */
        
    }
    
    @IBAction func galleryButtonAct(_ sender: UIButton) {
        let picker = AssetsPickerViewController()
        picker.pickerDelegate = self
        picker.pickerConfig.assetIsShowCameraButton = false
        picker.pickerConfig.selectedAssets = [PHAsset]()
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: true)]
        picker.pickerConfig.assetFetchOptions = [
            .smartAlbum: options,
            .album: options
        ]
        picker.navigationBar.barTintColor = UIColor(named: "AppThemeColor") ?? .white
        picker.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: APP_FONT_REGULAR, size: 20) ?? UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor(named: "whitecolor") ?? .black]
        picker.navigationBar.tintColor = UIColor(named: "whitecolor") ?? .white
        picker.modalPresentationStyle = .fullScreen
//        self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
        present(picker, animated: true, completion: nil)
    }

    @IBAction func closeButtonAct(_ sender: UIButton) {
//        self.navigationController?.isNavigationBarHidden = false
        if isTabBar {
              self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
            self.imageArray.removeAll()
            self.selectedImageArray.removeAll()
            self.collectionView.reloadData()
            let Tabbar = TabbarController()
            Tabbar.selectedIndex = 0
            delegate.initVC(initialView: Tabbar)
            
        }
        else {
           self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
//            self.setStatusBarBackgroundColor(color: UIColor(named: "AppThemeColor") ?? .black)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func changeCameraButtonAct(_ sender: UIButton) {
        captureSession?.stopRunning()
        self.videoPreviewLayer?.removeFromSuperlayer()
        // Choose the back dual camera if available, otherwise default to a wide angle camera.
        if sender.tag == 1 {
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            }

            else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                defaultVideoDevice = backCameraDevice
            }
            self.splashButton.isHidden = false
            sender.tag = 0
        }
        else {
            if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                defaultVideoDevice = frontCameraDevice
//                self.splashButton.isHidden = true
//                self.splashButton.tintColor = UIColor(named: "whitecolor")
//                self.flashMode = .off
            }
            sender.tag = 1
        }
        self.moveToCamera()
    }
    
    @IBAction func flashButtonAct(_ sender: UIButton) {
        
//        if (defaultVideoDevice?.position ?? AVCaptureDevice.Position.front) == AVCaptureDevice.Position.back {
//        print(defaultVideoDevice?.hasFlash ?? false)
        if (defaultVideoDevice?.hasFlash ?? false) {
            if (self.flashMode == .auto || self.flashMode == .off) {
                sender.tintColor = UIColor(named: "AppThemeColor")
                self.flashMode = .on
            }
            else {
                sender.tintColor = UIColor(named: "whitecolor")
                self.flashMode = .off
            }
        }
        else {
            let alert = UIAlertController(title: nil, message: getLanguage["front_camera_doesnt_flash"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CameraViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCollectionViewCell", for: indexPath) as! CameraCollectionViewCell
        if self.imageArray[indexPath.row].isuploaded {
            if !self.imageArray[indexPath.row].imageUrl.contains("http") {
                cell.itemImageView.sd_setImage(with: URL(string: "\(ADD_IMAGE_URL)/\(ADD_EDIT_ITEM_MODEL.item_id ?? "")/\(self.imageArray[indexPath.item].imageUrl ?? "")"), placeholderImage: nil , completed: nil)
            }
            else {
                cell.itemImageView.sd_setImage(with: URL(string: self.imageArray[indexPath.item].imageUrl), placeholderImage: #imageLiteral(resourceName: "applogo") , completed: nil)
            }
        }
        else {
            cell.itemImageView.image = self.imageArray[indexPath.row].image
        }
        if self.selectedImageArray.filter({$0 == self.imageArray[indexPath.item]}).count > 0 {
            cell.selectedView.isHidden = false
        }
        else {
            cell.selectedView.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedImageArray.filter({$0 == self.imageArray[indexPath.item]}).count > 0 {
            self.selectedImageArray.removeAll(where: {$0 == self.imageArray[indexPath.item]})
        }
        else {
            self.selectedImageArray.append(self.imageArray[indexPath.item])
        }
        self.collectionView.reloadData()
   
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
}
extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        
        if let image = capturedImage {
            if let cropImage = cropToPreviewLayer(originalImage: image) {
                self.rotateImage(cropImage)
            }
            else {
                self.rotateImage(image)
            }
        }
    }
    private func cropToPreviewLayer(originalImage: UIImage) -> UIImage? {
        guard let cgImage = originalImage.cgImage else { return nil }

        let outputRect = self.videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: self.videoPreviewLayer?.bounds ?? self.previewView.bounds)

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: ((outputRect?.origin.x ?? self.previewView.frame.origin.x) * width), y: ((outputRect?.origin.y ?? self.previewView.frame.origin.y) * height), width: ((outputRect?.size.width ?? self.previewView.frame.width) * width), height: ((outputRect?.size.height ?? self.previewView.frame.height) * height))

        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: originalImage.imageOrientation)
        }

        return nil
    }
    func rotateImage(_ image: UIImage) {
        var nextImage = image
        if orientationLast == UIInterfaceOrientation.portrait {
            nextImage = image
        }
        else {
            if orientationLast == UIInterfaceOrientation.portraitUpsideDown{
                nextImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
            }
            else if orientationLast == UIInterfaceOrientation.landscapeRight {
                nextImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
            }
            else if orientationLast == UIInterfaceOrientation.landscapeLeft {
                nextImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
            }
            else {
                nextImage = image
            }
        }
        self.nextButton.isUserInteractionEnabled = true
        let imageModel = AddProductImageModel(isUploaded: false, image: nextImage, imageUrl: "")
        self.imageArray.append(imageModel)
        self.selectedImageArray.append(imageModel)
        self.collectionView.reloadData()
    }
}

extension CameraViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
            }
        }
    }
}
extension CameraViewController: ImageDelegate {
    func didSelect(image: UIImage?) {
        if let selectedImage = image {
            let imageModel = AddProductImageModel(isUploaded: false, image: selectedImage, imageUrl: "")
            self.imageArray.append(imageModel)
            self.selectedImageArray.append(imageModel)
            self.collectionView.reloadData()
        }
    }
}
extension CameraViewController: AssetsPickerViewControllerDelegate {
    
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {}
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {}
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        let imageManager = {
            return PHCachingImageManager()
        }()
        for i in 0..<assets.count {
            imageManager.requestImageData(for: assets[i], options: nil) { (data,message, imageOrientation, info) in
                if let imageData = data, let image = UIImage(data: imageData) {
                self.imageArray.append(AddProductImageModel(isUploaded: false, image: image, imageUrl: ""))
               self.selectedImageArray.append(AddProductImageModel(isUploaded: false, image: image, imageUrl: ""))
                    if i == (assets.count-1) {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
        // do your job with selected assets
    }
    func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        if controller.selectedAssets.count >= 15 {
            let alert = UIAlertController(title: nil, message: getLanguage["only 5 images are allowed to add"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            controller.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {
    }
    func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {
    }
    
}
