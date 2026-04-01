//
//  MyOrderSegmentViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 06/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import MXSegmentedPager

class MyOrderSegmentViewController: MXSegmentedPagerController {

    
    let myOrderVC = MyOrderSalesViewController()
    let salesVC = MyOrderSalesViewController()
    var MyOrderArray = [MyOrderSalesViewController]()
    var titleArray = ["myorders", "mysales"]
    var isTabbar = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
//        self.segmentedPager.segmentedControl.removeAll()
//        self.segmentedPager.reloadData()
//        self.segmentedPager.segmentedControl.layoutSubviews()
        if self.segmentedPager.segmentedControl.selectedIndex == 0 {
            self.myOrderVC.loadData()
        }
        else {
            self.salesVC.loadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
            }
            else {
                if isTabbar {
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.initVC(initialView: TabbarController())
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }
        }
    }
    func configUI() {
        self.MyOrderArray = [myOrderVC, salesVC]
        self.navigationController?.customNavigationBarView(title: "myordersale", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        segmentedPager.backgroundColor = UIColor(named: "BackGroundColor")
        segmentedPager.segmentedControl.backgroundColor = UIColor(named: "whitecolorNEW")
        segmentedPager.segmentedControl.textColor = (UIColor(named: "AppTextColor") ?? .white)
        segmentedPager.segmentedControl.font = (UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 15))
        segmentedPager.segmentedControl.selectedTextColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        segmentedPager.segmentedControl.indicator.lineView.backgroundColor = (UIColor(named: "clearcolor") ?? .white)
        segmentedPager.parallaxHeader.height = 0
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.segmentedPager.segmentedControl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.segmentedPager.pager.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.myOrderVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.salesVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
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
        let vc = MyOrderArray[index]
        vc.view.tag = index
        return vc
    }
}
