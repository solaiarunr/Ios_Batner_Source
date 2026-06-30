//
//  Credithistorycell.swift
//  Joysale_Swift
//
//  Created by HTS-4533 on 26/06/26.
//  Copyright © 2026 Hitasoft. All rights reserved.
//

import UIKit

class Credithistorycell: UITableViewCell {
    
    @IBOutlet weak var msglbl: UILabel!
    @IBOutlet weak var typelbl: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var amtlbl: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.msglbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.typelbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.datelbl.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 13), align: .left, text: "")
        self.amtlbl.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .left, text: "")
        self.msglbl.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loaddata(history: CreditResultModel){
        self.msglbl.text = history.note
        self.typelbl.text = "type: \(history.type ?? "")"
        self.datelbl.text = history.created_at
        if history.type == "boost_spend"{
            self.amtlbl.config(color: UIColor(named: "redcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .left, text: "")
            self.amtlbl.text = "-\(history.amount ?? "")Kč"
        }else{
            self.amtlbl.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .left, text: "")
            self.amtlbl.text = "+\(history.amount ?? "")Kč"
        }
    }
}
