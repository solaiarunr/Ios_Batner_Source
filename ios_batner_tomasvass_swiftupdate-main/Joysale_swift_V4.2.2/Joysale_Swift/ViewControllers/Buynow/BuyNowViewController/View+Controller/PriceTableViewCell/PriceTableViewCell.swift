//
//  PriceTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 27/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class PriceTableViewCell: UITableViewCell {

    @IBOutlet weak var priceDescLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    var stripe_currency = ["BIF","CLP","DJF","GNF","JPY","KMF","KRW","MGA","PYG","RWF","UGX","VND","VUV","XAF","XOF","XPF"];

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    
    func configUI() {
        self.priceTitleLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.priceDescLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .right, text: "")
    }
    func loadData(_ index: Int, item: ItemModel, price: String) {
        let currencyCode = item.currencyCode.components(separatedBy: "-")
        var cSymbol = ""
        if (currencyCode.count) > 1 {
            cSymbol = currencyCode[1]
        }
        var shippingCost = item.shippingCost ?? ""
        var priceData = price
        priceData = priceData.replacingOccurrences(of: ",", with: "")
        let totalVal = (Double(shippingCost) ?? 0)+(Double(priceData) ?? 0)
        var totalString = String(format: "%.2f", totalVal)
        if stripe_currency.contains(cSymbol) {
            priceData = String(format: "%.0f", (round((Double(priceData) ?? 0))))
            shippingCost = String(format: "%.0f", (round((Double(shippingCost) ?? 0))))
            let roundedtotalVal = (round((Double(priceData) ?? 0)))+(round((Double(shippingCost) ?? 0)))
            totalString = String(format: "%.0f", roundedtotalVal)
        }
        let currency = (item.currencyMode ?? "") == "symbol" ? (currencyCode.first ?? "") : (currencyCode.last ?? "")
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            
            if index == 0 {
                self.priceTitleLabel.text = getLanguage["Price"] ?? ""
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(currency) \(priceData)" : "\(priceData) \(currency)"
            }
            else if index == 1 {
                self.priceTitleLabel.text = getLanguage["shippingfee"] ?? ""
                self.priceDescLabel.text = item.formattedShippingCost
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(currency) \(shippingCost)" : "\(shippingCost) \(currency)"

            }
            else if index == 2 {
                self.priceTitleLabel.text = getLanguage["ordertotal"] ?? ""
                self.priceDescLabel.text = item.formattedTotalPrice
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(currency) \(totalString)" : "\(totalString) \(currency)"

            }
        }
        else {
            
            if index == 0 {
                self.priceTitleLabel.text = getLanguage["Price"] ?? ""
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(priceData) \(currency)" : "\(currency) \(priceData)"
            }
            else if index == 1 {
                self.priceTitleLabel.text = getLanguage["shippingfee"] ?? ""
                self.priceDescLabel.text = item.formattedShippingCost
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(shippingCost) \(currency)" : "\(currency) \(shippingCost) "

            }
            else if index == 2 {
                self.priceTitleLabel.text = getLanguage["ordertotal"] ?? ""
                self.priceDescLabel.text = item.formattedTotalPrice
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(totalString) \(currency)" : "\(currency) \(totalString) "
            }
        }
    }
    
    
    func loadDatavideo(_ index: Int, item: StoryListModel, price: String) {
        let currencyCode = item.currencyCode.components(separatedBy: "-")
        var cSymbol = ""
        if (currencyCode.count) > 1 {
            cSymbol = currencyCode[1]
        }
        var shippingCost = item.shippingCost ?? ""
        var priceData = price
        priceData = priceData.replacingOccurrences(of: ",", with: "")
        let totalVal = (Double(shippingCost) ?? 0)+(Double(priceData) ?? 0)
        var totalString = String(format: "%.2f", totalVal)
        if stripe_currency.contains(cSymbol) {
            priceData = String(format: "%.0f", (round((Double(priceData) ?? 0))))
            shippingCost = String(format: "%.0f", (round((Double(shippingCost) ?? 0))))
            let roundedtotalVal = (round((Double(priceData) ?? 0)))+(round((Double(shippingCost) ?? 0)))
            totalString = String(format: "%.0f", roundedtotalVal)
        }
        let currency = (item.currencyMode ?? "") == "symbol" ? (currencyCode.first ?? "") : (currencyCode.last ?? "")
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            
            if index == 0 {
                self.priceTitleLabel.text = getLanguage["Price"] ?? ""
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(currency) \(priceData)" : "\(priceData) \(currency)"
            }
            else if index == 1 {
                self.priceTitleLabel.text = getLanguage["shippingfee"] ?? ""
                self.priceDescLabel.text = item.formattedShippingCost
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(currency) \(shippingCost)" : "\(shippingCost) \(currency)"

            }
            else if index == 2 {
                self.priceTitleLabel.text = getLanguage["ordertotal"] ?? ""
                self.priceDescLabel.text = item.formattedTotalPrice
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(currency) \(totalString)" : "\(totalString) \(currency)"

            }
        }
        else {
            
            if index == 0 {
                self.priceTitleLabel.text = getLanguage["Price"] ?? ""
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(priceData) \(currency)" : "\(currency) \(priceData)"
            }
            else if index == 1 {
                self.priceTitleLabel.text = getLanguage["shippingfee"] ?? ""
                self.priceDescLabel.text = item.formattedShippingCost
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(shippingCost) \(currency)" : "\(currency) \(shippingCost) "

            }
            else if index == 2 {
                self.priceTitleLabel.text = getLanguage["ordertotal"] ?? ""
                self.priceDescLabel.text = item.formattedTotalPrice
                self.priceDescLabel.text = item.currencyPosition == "postfix" ? "\(totalString) \(currency)" : "\(currency) \(totalString) "
            }
        }
    }
    func loadOrderData(_ index: Int, item: OrderItemModel) {
        if index == 0 {
            self.priceTitleLabel.text = getLanguage["Price"] ?? ""
            self.priceDescLabel.text = item.formattedPrice
        }
        else if index == 1 {
            self.priceTitleLabel.text = getLanguage["shippingfee"] ?? ""
            self.priceDescLabel.text = item.formattedShippingCost
        }
        else if index == 2 {
            self.priceTitleLabel.text = getLanguage["ordertotal"] ?? ""
            self.priceDescLabel.text = item.formattedTotal
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
