//
//  BannerListTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class BannerListTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.statusLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.durationLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 17), align: .left, text: "")
        self.dateLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
    }
    
    func loadData(_ result: AdHistoryModel) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: (result.postedDate ?? "0"))  {
            formatter.dateFormat = "MMM dd, YYYY"
            let postedDate = formatter.string(from: date)
            print(date)  // Prints:  2018-12-10 06:00:00 +0000
            self.dateLabel.text = (getLanguage["posted_on"] ?? "") + " \(postedDate)"
        }
        else {
            self.dateLabel.text = (getLanguage["posted_on"] ?? "")
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let startDate = formatter.date(from: (result.startDate ?? "0")),let endDate = formatter.date(from: (result.endDate ?? "0")) {
            formatter.dateFormat = "MMM dd, YYYY"
            let sDate = formatter.string(from: startDate)
            let lDate = formatter.string(from: endDate)
            self.durationLabel.text = "\(sDate) \(getLanguage["on"] ?? "") \(lDate)"
        }
        if result.approveStatus == "approved" {
            self.statusLabel.text = getLanguage["approved"] ?? ""
            self.statusLabel.textColor = UIColor(named: "green_color")
        }
        else if result.approveStatus == "Pending" {
            self.statusLabel.text = getLanguage["pending"] ?? ""
            self.statusLabel.textColor = UIColor(named: "bluecolor")
        }
        else {
            self.statusLabel.text = result.approveStatus
            self.statusLabel.textColor = UIColor(named: "redcolor")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
