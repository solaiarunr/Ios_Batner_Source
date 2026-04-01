//
//  BannerHistoryModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class BannerHistoryModel {

    var adHistory : [AdHistoryModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        adHistory = [AdHistoryModel]()
        let adHistoryArray = json["ad_history"].arrayValue
        for adHistoryJson in adHistoryArray{
            let value = AdHistoryModel(fromJson: adHistoryJson)
            adHistory.append(value)
        }
        status = json["status"].boolValue
    }
}
class AdHistoryModel {

    var appBannerUrl : String!
    var approveStatus : String!
    var currencyCode : String!
    var currencyMode : String!
    var currencyPosition : String!
    var currencySymbol : String!
    var endDate : String!
    var formattedPrice : String!
    var postedDate : String!
    var price : String!
    var startDate : String!
    var transactionId : String!
    var webBannerUrl : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        appBannerUrl = json["app_banner_url"].stringValue
        approveStatus = json["approve_status"].stringValue
        currencyCode = json["currency_code"].stringValue
        currencyMode = json["currency_mode"].stringValue
        currencyPosition = json["currency_position"].stringValue
        currencySymbol = json["currency_symbol"].stringValue
        endDate = json["end_date"].stringValue
        formattedPrice = json["formatted_price"].stringValue
        postedDate = json["posted_date"].stringValue
        price = json["price"].stringValue
        startDate = json["start_date"].stringValue
        transactionId = json["transaction_id"].stringValue
        webBannerUrl = json["web_banner_url"].stringValue
    }
}
class AddBannerModel {

    var message : String!
    var noDates : [String]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        message = json["message"].stringValue
        noDates = [String]()
        let noDatesArray = json["no_dates"].arrayValue
        for noDatesJson in noDatesArray{
            noDates.append(noDatesJson.stringValue)
        }
        status = json["status"].boolValue
    }
}
