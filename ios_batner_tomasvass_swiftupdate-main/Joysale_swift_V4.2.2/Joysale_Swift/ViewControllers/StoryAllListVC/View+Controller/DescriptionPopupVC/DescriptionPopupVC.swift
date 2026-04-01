//
//  DescriptionPopupVC.swift
//  Joysale_Swift
//
//  Created by HTS-676 on 13/05/25.
//  Copyright © 2025 Hitasoft. All rights reserved.
//

import UIKit

class DescriptionPopupVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topIndicatorView: UIView!
    
//    let minHeight: CGFloat = 100
//    var maxHeight: CGFloat = 500
    
    var contentString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("viewDidLoad")
        // Add pan gesture
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
//        contentView.isUserInteractionEnabled = true
//        contentView.addGestureRecognizer(panGesture)
//        heightConst.constant = self.view.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTheme(page: "present")
        debugPrint("contentString -->\(contentString)")
        
        textView.config(color: UIColor(named: "AppTextColor") ?? .black, font: REGULAR_FONT, align: .left, text: "")
        textView.text = contentString ?? "Hello"
        self.navigationController?.isNavigationBarHidden = true
        debugPrint("viewWillAppear")
//        adjustHeightBasedOnContent()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        debugPrint("viewDidLayoutSubviews")
        //setMaxheight
        let safeAreaTop = view.safeAreaInsets.top
        let safeAreaBottom = view.safeAreaInsets.bottom
        let totalSafeHeight = view.bounds.height - safeAreaTop - safeAreaBottom
//        maxHeight = totalSafeHeight - 80
        
//        topIndicatorView.invitecornerViewMiniumRadius(2)
//        contentView.specificTopCornerRadius(20)
    }
    
//    private func adjustHeightBasedOnContent(){
//        self.view.layoutIfNeeded()
//        let size = CGSize(width: textView.frame.width, height: .infinity)
//        let estimatedSize = textView.sizeThatFits(size)
//        heightConst.constant = (estimatedSize.height >= maxHeight) ? maxHeight : estimatedSize.height
//    }

    
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//            let translation = gesture.translation(in: view)
//            switch gesture.state {
//            case .changed:
//                let newHeight = heightConst.constant - translation.y // dragging up -> negative y -> increase height
//                guard (newHeight > minHeight) else {
//                    debugPrint("The page dismissed")
//                    self.dismiss(animated: true)
//                    return
//                }
//                heightConst.constant = min(max(newHeight, minHeight), maxHeight)
//                gesture.setTranslation(.zero, in: view) // reset
//            default:
//                break
//            }
//        }

}
