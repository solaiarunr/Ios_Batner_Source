//
//  ThemeViewController.swift
//  Joyshorts
//
//  Created by Vijai MacBook Pro on 04/05/23.
//

import UIKit

class ThemeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    let themeArray = ["Light", "Dark", "System Default"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ThemeTableViewCell", bundle: nil), forCellReuseIdentifier: "ThemeTableViewCell")
        self.tableView.separatorStyle = .none
        self.titleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 20), align: .left, text: "theme")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.updateTheme(page: "present")
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
           return self.updateStatusBarStyle()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.themeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeTableViewCell") as! ThemeTableViewCell
        cell.themeLabel.text = (getLanguage[self.themeArray[indexPath.row]] ?? "")
        if UserDefaultModule.shared.getTheme() == "" || UserDefaultModule.shared.getTheme() == nil {
            UserDefaultModule.shared.setTheme(theme: "Dark")
        }
        let iconCheck = UserDefaultModule.shared.getTheme()
        if iconCheck == self.themeArray[indexPath.row] {
            cell.tickIcon.isHidden = false
        } else {
            cell.tickIcon.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        UserDefaultModule.shared.setTheme(theme: self.themeArray[indexPath.row])
        DispatchQueue.main.async {
            delegate.checkTheme()
            let pageObj = TabbarController()
            pageObj.selectedIndex = 0
            delegate.initVC(initialView: pageObj)
        }
    }
    
    @IBAction func backButtonAct(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
