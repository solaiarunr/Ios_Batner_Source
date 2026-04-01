//
//  HelpViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 09/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import WebKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var webStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    var viewModel = HelpViewModel()
    var helpResult: HelpResultModel?
    var viewType = ""
    var isFromHelp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        
        // Do any additional setup after loading the view.
    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        if self.viewType == "" {
//            return .default
//        }
//          return .lightContent
//    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        if viewType != "" {
            self.navigationController?.isNavigationBarHidden = false
        }
        else {
            self.navigationController?.isNavigationBarHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
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
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }

    func configUI() {
        self.tableView.register(UINib(nibName: "HelpTableViewCell", bundle: nil), forCellReuseIdentifier: "HelpTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 0
        self.denyButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, title: "deny")

        self.denyButton.setBorder(color: UIColor(named: "AppThemeColorNew"))
        self.denyButton.backgroundColor = UIColor(named: "Locationcolorsetup")
        self.acceptButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_BOLD, size: 15), align: .center, title: "accept")
        self.acceptButton.setTitle("Accept", for: .normal)
        self.textView.config(color: UIColor(named: "AppTextColor") ?? .black, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.textView.dataDetectorTypes = .link
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor.blue ]

        self.acceptButton.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.view.addSubview(indicatorView)
        if !UserDefaultModule.shared.getAppFirst() {
            Utility.shared.startAnimation(viewController: self)
        }
        self.acceptButton.cornerMiniumRadius()
        if viewType == "" {
        }
        else {
            self.navigationController?.customNavigationBarView(title: getLanguage[self.viewType] ?? self.viewType, fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
            self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 17), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        }
        self.loadData()
    }
    func loadData() {
        self.textView.isHidden = false
        self.webStackView.isHidden = false
        self.tableView.isHidden = true

        if !isFromHelp {
            if viewType == "safety_tips" {
                self.headerView.isHidden = true
                self.bottomView.isHidden = true
                self.viewModel.getSaftyTips(onSuccess: { (success) in
                    print(success)
                    let attributedString = NSAttributedString(
                        string: (self.viewModel.tosModel?.message ?? "").html2String,
                        attributes: [
                            NSAttributedString.Key.font: UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 14),
                            NSAttributedString.Key.foregroundColor: UIColor(named: "AppTextColor") ?? .black // Explicitly set text color
                        ]
                    )
                    self.textView.attributedText = attributedString
                    DispatchQueue.main.async {
                        self.textView.setContentOffset(CGPoint.zero, animated: false)
                    }
                    Utility.shared.stopAnimation(viewController: self)
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }
            else if viewType == "help" {
                self.headerView.isHidden = false
                self.bottomView.isHidden = false
                self.webStackView.isHidden = true
                self.tableView.isHidden = false
                self.viewModel.getHelpPageData(onSuccess: { (success) in
                    self.tableView.reloadData()
                    Utility.shared.stopAnimation(viewController: self)
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }
            else {
                self.viewModel.getTOSData(onSuccess: { (success) in
                    print(success)
                    let attributedString = NSAttributedString(
                        string: (self.viewModel.tosModel?.message ?? "").html2String,
                        attributes: [
                            NSAttributedString.Key.font: UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 14),
                            NSAttributedString.Key.foregroundColor: UIColor(named: "AppTextColor") ?? .black // Explicitly set text color
                        ]
                    )
                    self.textView.attributedText = attributedString
                    DispatchQueue.main.async {
                        self.textView.setContentOffset(CGPoint.zero, animated: false)
                    }
                    Utility.shared.stopAnimation(viewController: self)
                }) { (failure) in
                    Utility.shared.stopAnimation(viewController: self)
                }
            }
        }
        else {
            self.headerView.isHidden = true
            self.bottomView.isHidden = true
            if DEFAULT_LANGUAGE_CODE == "en" {
                let data = (self.helpResult?.pageContent ?? "").data(using: .utf8)!
                let attributedString = try? NSMutableAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil
                )
                attributedString?.addAttributes([
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "AppTextColor") ?? .black // Explicitly set text color
                ], range: NSRange(location: 0, length: attributedString?.length ?? 0))

                self.textView.attributedText = attributedString
            }
            else {
                self.textView.linkTextAttributes = [
                    .foregroundColor: UIColor.blue,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
                self.textView.attributedText = NSAttributedString(
                    string: (self.helpResult?.pageContent ?? "").html2String,
                    attributes: [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.systemFont(ofSize: 14),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "AppTextColor") ?? .black // Explicitly set text color
                    ]
                )
            }

            DispatchQueue.main.async {
                self.textView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }

    @IBAction func acceptButtonAct(_ sender: Any) {
//        UserDefaultModule.shared.setAppFirst(true)
        let delegate = UIApplication.shared.delegate as! AppDelegate

        FILTER_DATA.city = "\(delegate.currentLocation?.subLocality ?? "")"
        FILTER_DATA.state = "\(delegate.currentLocation?.administrativeArea ?? "")"
        FILTER_DATA.country = "\(delegate.currentLocation?.country ?? "")"
        if FILTER_DATA.city != "" && FILTER_DATA.state != "" && FILTER_DATA.country != "" {
//            FILTER_DATA.location = "\(FILTER_DATA.city ?? ""), \(FILTER_DATA.state ?? ""), \(FILTER_DATA.country ?? "")"
//            FILTER_DATA.lat = "\(delegate.currentLocation?.location?.coordinate.latitude ?? 0)"
//            FILTER_DATA.long = "\(delegate.currentLocation?.location?.coordinate.longitude ?? 0)"
        }
        if FILTER_DATA.location != "" && FILTER_DATA.location.lowercased() != "worldwide" && FILTER_DATA.location.lowercased() != UserDefaultModule.shared.getcountryname() {
            FILTER_DATA.distance = "\(Int(ADMIN_VIEW_MODEL.productBeforeModel?.result.distance ?? "200") ?? 200)"
            FILTER_DATA.distance_type = "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.searchType ?? "")"
            FILTER_DATA.isDistanceSlider = false
        }
        UserDefaultModule.shared.setFilterData(FILTER_DATA)
        let vc = CountrySearchVC()
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.pushViewController(vc, animated: true)
//        self.navigationController?.present(vc, animated: true)
//        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func denyButtonAct(_ sender: UIButton) {
        exit(0);
    }
}
extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.viewModel.helpModel?.result.count ?? 0)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if UserDefaultModule.shared.getTheme() == "Dark"{
            footerView.backgroundColor = UIColor(named: "BackGroundColorNew")
        }else{
            footerView.backgroundColor = #colorLiteral(red: 0.9567790627, green: 0.9569163918, blue: 0.956749022, alpha: 1)
        }
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell") as! HelpTableViewCell
        cell.textLabel?.text = (self.viewModel.helpModel?.result[indexPath.section].pageName ?? "")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pageObj = HelpViewController()
        pageObj.isFromHelp = true
        pageObj.viewType = (self.viewModel.helpModel?.result[indexPath.section].pageName ?? "")
        pageObj.helpResult = self.viewModel.helpModel?.result[indexPath.section]
        self.navigationController?.pushViewController(pageObj, animated: true)
    }
}
