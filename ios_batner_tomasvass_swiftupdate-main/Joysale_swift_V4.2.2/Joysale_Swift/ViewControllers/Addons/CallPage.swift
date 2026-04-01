//
//  CallPage.swift
//  Joysale_Swift
//
//  Created by MAC pro 2.9Ghz on 10/02/21.
//  Copyright © 2021 Hitasoft. All rights reserved.
//

import UIKit
import MZTimerLabel
import AVFoundation

class CallPage: UIViewController {

    @IBOutlet weak var preview: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var userImgView: UIImageView!
    
    @IBOutlet weak var countDownLbl: MZTimerLabel!
    
    @IBOutlet weak var receiverImgView: UIImageView!
    
    @IBOutlet weak var receiverNameLbl: UILabel!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    @IBOutlet weak var ongoingPropertiesView: UIView!
    
    @IBOutlet weak var inComingcutBtn: UIButton!
    @IBOutlet weak var attenBtn: UIButton!
    @IBOutlet weak var incomingPropertiesView: UIView!
    @IBOutlet weak var cameraspeakerBtn: UIButton!
    @IBOutlet weak var ongoingCutBtn: UIButton!
    @IBOutlet weak var muteBtn: UIButton!
    
    
    var ishideProperties: Bool
    var isMute: Bool
    var isSpeaker: Bool
    var isHeadphonePlugged: Bool
    let enlargeBtn: UIButton? = nil
    var roomIdArray: [AnyHashable]?
    
    var av_Player: AVAudioPlayer?
    var previewlayer: AVCaptureVideoPreviewLayer?
    var videoDataOutput: AVCaptureVideoDataOutput?
    var manager: SocketIOManager?
   // var socket: SocketIOClient?
    
    
    var callType: String?
    var isSender = false
    var chatDict: [AnyHashable : Any]?
    var platform: String?
    var room_id: String?
    var call_status: String?
    var view_From: String?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        
    }
    func configUI(){
        isHeadphonePlugged = false
        ishideProperties = false
        isMute = false
        isSpeaker = false
        call_status = "waiting";
        self.configWebRTC()
        
    }
    
    func configDesign(){
        self.muteBtn.layer.cornerRadius = self.muteBtn.frame.size.height/2
        self.muteBtn.clipsToBounds = true
        
        self.inComingcutBtn.layer.cornerRadius = self.inComingcutBtn.frame.size.height/2
        self.inComingcutBtn.clipsToBounds = true
        
        self.attenBtn.layer.cornerRadius = self.attenBtn.frame.size.height/2
        self.attenBtn.clipsToBounds = true
        
        self.cameraspeakerBtn.layer.cornerRadius = self.cameraspeakerBtn.frame.size.height/2
        self.cameraspeakerBtn.clipsToBounds = true
        
        self.ongoingCutBtn.layer.cornerRadius = self.ongoingCutBtn.frame.size.height/2
        self.ongoingCutBtn.clipsToBounds = true
        
        self.receiverImgView.layer.cornerRadius = self.receiverImgView.frame.size.height/2;
        self.receiverImgView.clipsToBounds = true;
//        [self.receiverImgView sd_setImageWithURL:[NSURL URLWithString:[_chatDict objectForKey:@"user_image"]]placeholderImage:[UIImage imageNamed:@"user_placeholder.jpg"]];
        
        [_receiverNameLbl setTextAlignment:NSTextAlignmentCenter]
        [_receiverNameLbl setFont:[UIFont fontWithName:appFontRegular size:20]]
        [_receiverNameLbl setText:[_chatDict objectForKey:@"user_name"]]
        [_receiverNameLbl setTextColor:green_color]
        
        [_statusLbl setTextAlignment:NSTextAlignmentCenter]
        [_statusLbl setFont:[UIFont fontWithName:appFontRegular size:16]]
        [_statusLbl setText:@"Ringing..."]
        [_statusLbl setTextColor:green_color]
        
        [_countDownLbl setTextAlignment:NSTextAlignmentCenter]
        [_countDownLbl setFont:[UIFont fontWithName:appFontRegular size:16]]
        [_countDownLbl setTextColor:green_color]
        _countDownLbl.hidden =  true
        
        if ([[[[NSUserDefaults standardUserDefaults]objectForKey:@"peoples"]objectForKey:@"user_image"] rangeOfString:@"http"].location == NSNotFound){
          //[self.userImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",UserimageURL,[[[NSUserDefaults standardUserDefaults]objectForKey:@"peoples"]objectForKey:@"user_image"]]] placeholderImage:[UIImage imageNamed:@"user_placeholder.jpg"]];
            [self.userImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"photo"]]]placeholderImage:[UIImage imageNamed:@"profilelogo.png"]];
        }else{
            [self.userImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"user_placeholder.jpg"]];
        }
        [self.userImgView sd_setImageWithURL:[NSURL URLWithString:[delegate.receiverdataArray objectAtIndex:2]]placeholderImage:[UIImage imageNamed:@"profilelogo.png"]];
        
        _muteBtn.hidden = true;
        _cameraspeakerBtn.hidden = true;
        
        //set view based on the sender , receiver
        if (isSender) {
            self.incomingPropertiesView.isHidden = true
            self.ongoingPropertiesView.isHidden = false
        }else{
            self.incomingPropertiesView.isHidden = false
            self.ongoingPropertiesView.isHidden = true
        }
        
        //set view based on the view type
        if self.callType == "audio"{
            self.userImgView.isHidden = false
            self.preview.isHidden = true
            self.cameraspeakerBtn.setImage(#imageLiteral(resourceName: <#T##String#>), for: .normal)
        }
        else{
             self.setupPreviewScreen()
            self.userImgView.isHidden = true
            self.preview.isHidden = false
            self.cameraspeakerBtn.setImage(#imageLiteral(resourceName: <#T##String#>), for: .normal)
          }
        
        if let containerView = containerView {
            view.bringSubviewToFront(containerView)
        }
    }
    func configWebRTC(){
        
    }
    func setupPreviewScreen(){
        
    }
    @IBAction func CutBtnTapped(_ sender: UIButton) {
    }
    
    @IBAction func muteBtnTapped(_ sender: UIButton) {
    }
    
    
    @IBAction func cameraspeakerBtnAct(_ sender: UIButton) {
    }
    
    @IBAction func attenBtnTapped(_ sender: UIButton) {
    }
    
    
    @IBAction func inComingCutBtnAct(_ sender: UIButton) {
    }
    
    
}
