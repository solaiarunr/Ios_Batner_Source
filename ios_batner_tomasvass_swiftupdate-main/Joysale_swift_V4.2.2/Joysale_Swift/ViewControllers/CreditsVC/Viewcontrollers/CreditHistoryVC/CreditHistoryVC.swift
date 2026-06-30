//
//  CreditHistoryVC.swift
//  Joysale_Swift
//
//  Created by HTS-4533 on 26/06/26.
//  Copyright © 2026 Hitasoft. All rights reserved.
//

import UIKit

class CreditHistoryVC: UIViewController {
    
    @IBOutlet weak var translbl: UILabel!
    @IBOutlet weak var tableview: UITableView!
    var historymodel = [CreditResultModel]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
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

    func config(){
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.navigationController?.customNavigationBarView(title: "credit", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.translbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.tableview.register(UINib(nibName: "Credithistorycell", bundle: nil), forCellReuseIdentifier: "Credithistorycell")
    }
    

   
}

extension CreditHistoryVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historymodel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Credithistorycell") as! Credithistorycell
        cell.loaddata(history: self.historymodel[indexPath.row])
        return cell
    }
    
    
}
