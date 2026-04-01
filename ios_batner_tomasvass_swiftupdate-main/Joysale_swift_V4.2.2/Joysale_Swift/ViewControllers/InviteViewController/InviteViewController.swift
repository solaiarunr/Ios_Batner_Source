//
//  InviteViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 25/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import FBSDKShareKit
import MessageUI

class InviteViewController: UIViewController {

    @IBOutlet weak var messengerButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var appLogoImageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func configUI() {
        self.popupView.layer.cornerRadius = 15
        self.appLogoImageview.cornerViewRadius()
        self.logoImageView.cornerViewRadius()
        self.titleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_BOLD, size: 17), align: .center, text: "Invite friends")
        self.descLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .center, text: "Invite Message")
        self.messengerButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_BOLD, size: 14), align: .center, title: "Invite via Messanger")
        self.messengerButton.backgroundColor = UIColor(named: "MessengerColor")
        self.messengerButton.invitecornerViewMiniumRadius(10)
        self.whatsappButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_BOLD, size: 14), align: .center, title: "Invite via Whatsapp")
        self.whatsappButton.invitecornerViewMiniumRadius(10)
        self.mailButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_BOLD, size: 14), align: .center, title: "Invite via Email")
        self.mailButton.invitecornerViewMiniumRadius(10)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapAct)))
    }
    @objc func tapAct() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func messengerButtonAct(_ sender: UIButton) {
        let content = ShareLinkContent()
        content.contentURL = URL(string: INVITE_URL)!
        content.quote = (getLanguage["invite_friend"] ?? "")
        let dialog = MessageDialog(content: content, delegate: self)
        guard dialog.canShow else {
            let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            alert.message = getLanguage["messenger not installed"] ?? ""
            self.present(alert, animated: true, completion: nil)
            return
        }
        dialog.show()
    }
    @IBAction func mailShareAct(_ sender: UIButton) {
        let titleURL = "\(getLanguage["Invite from"] ?? "") \(APP_NAME)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let inviteURL = "<h4>\(getLanguage["invite_friend"] ?? "") \(APP_NAME): <a href='\(INVITE_URL)'>\(UserDefaultModule.shared.getbaseurlonly() ?? "https://batner.com/")</h4>".html2String.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let url = "googlegmail://co?subject=\(titleURL)&body=\(inviteURL)"
        print("ShareURL \(url)")
        if let whatsAppUrl = URL(string: url), UIApplication.shared.canOpenURL(whatsAppUrl) {
            UIApplication.shared.open(whatsAppUrl, options: [:], completionHandler: nil)
        }
        else if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("\(getLanguage["Invite from"] ?? "") \(APP_NAME)")
            let message = "<h4>\(getLanguage["invite_friend"] ?? "") \(APP_NAME): <a href='\(INVITE_URL)'>\(UserDefaultModule.shared.getbaseurlonly() ?? "https://batner.com/")</h4>"
            mail.setMessageBody(message, isHTML: true)
            self.present(mail, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: getLanguage["failed"] ?? "", message: getLanguage["InviteAlert"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func whatsAppShareAct(_ sender: UIButton) {
        let url = "whatsapp://send?text=\(getLanguage["invite_friend"] ?? "") \(INVITE_URL)"
        let shareURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let whatsAppUrl = URL(string: shareURL), UIApplication.shared.canOpenURL(whatsAppUrl) {
            UIApplication.shared.open(whatsAppUrl, options: [:], completionHandler: nil)
        }
        else {
            let alert = UIAlertController(title: getLanguage["alert"] ?? "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            alert.message = getLanguage["whatsapp_installed"] ?? ""
            self.present(alert, animated: true, completion: nil)
        }
    }
}
extension InviteViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: getLanguage["Message Cancelled"] ?? "", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
        switch result {
        case .cancelled:
            alert.title = getLanguage["Message Cancelled"] ?? ""
        case .sent:
            alert.title = getLanguage["Success!!"] ?? ""
            alert.message = getLanguage["App Invite send successfully"] ?? ""
        case .saved:
            break;
        case .failed:
            break;
        @unknown default:
            break;
        }
        self.present(alert, animated: true, completion: nil)
    }
}
extension InviteViewController: SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        
    }
}
