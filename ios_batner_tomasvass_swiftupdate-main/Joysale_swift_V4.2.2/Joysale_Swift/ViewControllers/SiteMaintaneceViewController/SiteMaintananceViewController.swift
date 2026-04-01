//
//  SiteMaintananceViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 28/09/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class SiteMaintananceViewController: UIViewController {

    @IBOutlet weak var maintananceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    func configUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.maintananceLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 20), align: .center, text: "")
        self.maintananceLabel.text = getLanguage[ADMIN_VIEW_MODEL.adminModel?.result.siteMaintenanceText ?? ""] ?? ADMIN_VIEW_MODEL.adminModel?.result.siteMaintenanceText ?? ""
//        self.setStatusBarBackgroundColor(color: UIColor(named: "BackGroundColor") ?? .black)
        self.updateStatusbarBackgroundnew(Color: UIColor(named: "appcolor")!)
    }

    @IBAction func closeButtonAct(_ sender: UIButton) {
        exit(0)
    }

}
