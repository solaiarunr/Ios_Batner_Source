//
//  ExchangeListViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 03/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import MXSegmentedPager

class ExchangeListViewController: MXSegmentedPagerController {

    var titleArray = ["incoming", "outgoing", "success", "failed"]

    let incomeVC = MyExchangeViewController()
    let outgoingVC = MyExchangeViewController()
    let successVC = MyExchangeViewController()
    let failureVC = MyExchangeViewController()
    var exchangeVC = [MyExchangeViewController]()
    var selectedVC: MyExchangeViewController?
    
    var isTabbar = false
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
//        if self.segmentedPager.segmentedControl.selectedIndex == 0 {
//            self.incomeVC.loadData()
//        }
//        else if self.segmentedPager.segmentedControl.selectedIndex == 1 {
//            self.outgoingVC.loadData()
//        }
//        else if self.segmentedPager.segmentedControl.selectedIndex == 2 {
//            self.successVC.loadData()
//        }
//        else {
//            self.failureVC.loadData()
//        }
    }
    func reloadData() {
        if let selectedPage = self.selectedVC {
            selectedPage.loadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
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
                    self.delegate.initVC(initialView: TabbarController())
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    func configUI() {
        self.exchangeVC = [incomeVC, outgoingVC, successVC, failureVC]
        self.navigationController?.customNavigationBarView(title: "myexchange", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        segmentedPager.backgroundColor = UIColor(named: "BackGroundColor")
        segmentedPager.segmentedControl.backgroundColor = UIColor(named: "BackColorwhite")
        segmentedPager.segmentedControl.textColor = (UIColor(named: "AppTextColor") ?? .white)
        segmentedPager.segmentedControl.font = (UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 15))
        segmentedPager.segmentedControl.selectedTextColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        segmentedPager.segmentedControl.indicator.lineView.backgroundColor = (UIColor(named: "clearcolor") ?? .white)
        segmentedPager.parallaxHeader.height = 0
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.segmentedPager.segmentedControl.select(index: self.selectedIndex, animated: true)
        }
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            self.segmentedPager.segmentedControl.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.segmentedPager.pager.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.incomeVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.outgoingVC.view.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.successVC.view.transform  = CGAffineTransform(scaleX: -1, y: 1)
            self.failureVC.view.transform  = CGAffineTransform(scaleX: -1, y: 1)
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
        self.selectedVC = exchangeVC[index]
        let vc = exchangeVC[index]
        vc.exchangePager = self
        vc.view.tag = index
        vc.loadData()
        return vc
    }
}
