//
//  LanguageViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 15/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
//    var languageArray = ["english","french" ,"arabic"]
//    var languageCode = ["en","fr", "ar"]
    var languageArray = ["english"]
    var languageCode = ["en"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
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
    func configUI() {
        self.navigationController?.customNavigationBarView(title: "language", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.tableView.register(UINib(nibName: "LanguageTableViewCell", bundle: nil), forCellReuseIdentifier: "LanguageTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionFooterHeight = 50
    }
}
extension LanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.languageArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell") as! LanguageTableViewCell
        cell.titleLabel.text = (getLanguage[self.languageArray[indexPath.section]] ?? "").capitalized
        cell.checkImageView.isHidden = true
        if UserDefaultModule.shared.getAppLanguage().lowercased() == self.languageArray[indexPath.section] {
            cell.checkImageView.isHidden = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DEFAULT_LANGUAGE_CODE = self.languageCode[indexPath.section]
      
        UserDefaults.standard.set([DEFAULT_LANGUAGE_CODE], forKey: "AppleLanguages")
        UserDefaultModule.shared.setAppLanguage(language: self.languageArray[indexPath.section].capitalized)
        Utility.shared.configureLanguage()
        Utility.shared.startAnimation(viewController: self)
        self.tableView.reloadData()
        ADMIN_VIEW_MODEL.loadNotification(onSuccess: { (success) in
        Utility.shared.stopAnimation(viewController: self)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.setInitialViewController(initialView: TabbarController())
            delegate.checkTheme()
        }) { (failure) in
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }
}
