//
//  MyPromotionViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 20/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import MXSegmentedPager

class MyPromotionViewController: MXSegmentedPagerController {
    
    let urgentVC = MyPromotionSubViewController()
    let adVC = MyPromotionSubViewController()
    let expiredVC = MyPromotionSubViewController()
    var titleArray = ["urgent", "advertisement", "expired"]
    var promotionArr = [MyPromotionSubViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)

        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
       self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)

        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
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
        self.promotionArr = [urgentVC, adVC, expiredVC]
        self.navigationController?.customNavigationBarView(title: "my_promotions", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        segmentedPager.backgroundColor = UIColor(named: "BackGroundColor")
        segmentedPager.segmentedControl.backgroundColor = UIColor(named: "BackColorwhite")
        segmentedPager.segmentedControl.textColor = (UIColor(named: "AppTextColor") ?? .white)
        segmentedPager.segmentedControl.font = (UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 15))
        segmentedPager.segmentedControl.selectedTextColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        segmentedPager.segmentedControl.indicator.lineView.backgroundColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        segmentedPager.parallaxHeader.height = 0
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.segmentedPager.segmentedControl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.segmentedPager.pager.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.urgentVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.adVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.expiredVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return getLanguage[titleArray[index]] ?? ""
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didScrollWith parallaxHeader: MXParallaxHeader) {
    }
    override func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        return titleArray.count
    }
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = promotionArr[index]
        vc.view.tag = index
        return vc
    }
}
