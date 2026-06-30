//
//  CreatePromotionViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 22/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import MXSegmentedPager

class CreatePromotionViewController: MXSegmentedPagerController,PromotionLoadDelegate, MXPagerViewDelegate {
    func promotionPageLoaded() {
        print("promotionPageLoadedpass")
        Buttonstate = false
        segmentedPager.segmentedControl.isUserInteractionEnabled = false
        segmentedPager.pager.isScrollEnabled = false
    }
    func promotionPageLoadedActive(){
        Buttonstate = true
        print("promotionPageLoadedpass")
        segmentedPager.segmentedControl.isUserInteractionEnabled = true
        segmentedPager.pager.isScrollEnabled = true
    }
    
    
    let adVC = PromotionOptionViewController()
    let urgentVC = PromotionOptionViewController()
    var titleArray = ["advertisement", "urgent"]
    var promotionArr = [PromotionOptionViewController]()
    var itemID = ""
    var isTabBar = false
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var Buttonstate = true
    var profilemodel : ProfileResultModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.barButtonAction(_:)),
            name: Notification.Name("BarButtonAction"),
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name("BarButtonAction"),
            object: nil
        )
    }
    
    @objc func barButtonAction(_ notification: Notification) {
        if Buttonstate{
            print(notification)
            if let isLeft = notification.userInfo?["isLeft"] as? Int {
                print(isLeft)
                if isLeft == 1 {
                    // Left button action
                } else {
                    if isTabBar {
                        delegate.initVC(initialView: TabbarController())
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }else{
            print("Noaction")
        }
       
    }
    
    func configUI() {
        // ✅ Advertisement first, Urgent second
        self.promotionArr = [adVC, urgentVC]
        
        self.navigationController?.customNavigationBarView(
            title: "create_promotion",
            fColor: "whitecolor",
            fontName: UIFont(name: APP_FONT_REGULAR, size: 20),
            vc: self
        )
        
        self.navigationController?.customRightBarButtonView(
            title: "",
            fColor: "whitecolor",
            fontName: UIFont(name: APP_FONT_REGULAR, size: 18),
            imageName: "detail_back",
            isLeft: true,
            vc: self,
            transparantView: false
        )
        
        segmentedPager.backgroundColor = UIColor(named: "BackGroundColor")
        segmentedPager.segmentedControl.backgroundColor = UIColor(named: "whitecolorNEW")
        segmentedPager.segmentedControl.textColor = (UIColor(named: "AppTextColor") ?? .white)
        segmentedPager.segmentedControl.font = (UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 15))
        segmentedPager.segmentedControl.selectedTextColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        segmentedPager.segmentedControl.indicator.lineView.backgroundColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        segmentedPager.parallaxHeader.height = 0
        segmentedPager.pager.delegate = self
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.segmentedPager.segmentedControl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.segmentedPager.pager.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.adVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.urgentVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return getLanguage[titleArray[index]] ?? ""
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didScrollWith parallaxHeader: MXParallaxHeader) {
        // Optional: Handle scroll if needed
    }
    
    override func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        return titleArray.count
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = promotionArr[index]
        vc.itemID = self.itemID
        vc.Prodelegate = self
        vc.profilemodel = profilemodel
        vc.view.tag = index
        return vc
    }
    
    func pagerView(_ pagerView: MXPagerView, willMoveToPage page: UIView, at index: Int) {
           print("Will move to page: \(index)")
       }

       func pagerView(_ pagerView: MXPagerView, didMoveToPage page: UIView, at index: Int) {
           print("Did move to page: \(index)")
           promotionArr[index].pageDidChange(index: index)

       }
    
}
