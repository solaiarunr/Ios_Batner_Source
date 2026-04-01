//
//  BannerModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class BannerModel {

    var result : [BannerResultModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [BannerResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = BannerResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
class BannerResultModel {

    var adDescription : String!
    var adImage : String!
    var currencyCode : String!
    var currencyMode : String!
    var currencyPosition : String!
    var currencySymbol : String!
    var formattedPricePerDay : String!
    var pricePerDay : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        adDescription = json["ad_description"].stringValue
        adImage = json["ad_image"].stringValue
        currencyCode = json["currency_code"].stringValue
        currencyMode = json["currency_mode"].stringValue
        currencyPosition = json["currency_position"].stringValue
        currencySymbol = json["currency_symbol"].stringValue
        formattedPricePerDay = json["formatted_price_per_day"].stringValue
        pricePerDay = json["price_per_day"].stringValue
    }
}
