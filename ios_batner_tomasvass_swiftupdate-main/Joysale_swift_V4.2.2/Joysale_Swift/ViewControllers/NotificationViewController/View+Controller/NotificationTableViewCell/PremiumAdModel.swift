//
//  PremiumAdModel.swift
//  Joysale_Swift
//  Created by HTS-PRO-2018 on 07/11/25.
//  Copyright © 2025 Hitasoft. All rights reserved.

import Foundation
import SwiftyJSON

class PremiumAdModel {
    var status: Bool = false
    var adPremiumList: [AdPremium] = []
    
    init(from json: JSON) {
        self.status = json["status"].boolValue
        for item in json["result"]["ad_premiumlist"].arrayValue {
            let ad = AdPremium(from: item)
            self.adPremiumList.append(ad)
        }
    }
}

class AdPremium {
    var id: String = ""
    var name: String = ""
    var price: String = ""
    var days: String = ""
    var formattedPrice: String = ""
    var inAppId: String = ""
    
    init(from json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.price = json["price"].stringValue
        self.days = json["days"].stringValue
        self.formattedPrice = json["formatted_price"].stringValue
        self.inAppId = json["ios_id"].stringValue
    }
}




class PremiumPromoModel {
    var status: Bool = false
    var PromoPremiumList: [PromoPremium] = []
    
    init(from json: JSON) {
        self.status = json["status"].boolValue
        for item in json["result"]["ad_premiumlist"].arrayValue {
            let ad = PromoPremium(from: item)
            self.PromoPremiumList.append(ad)
        }
    }
}

class PromoPremium {
    var id: String = ""
    var name: String = ""
    var price: String = ""
    var days: String = ""
    var formattedPrice: String = ""
    var inAppId: String = ""
    
    init(from json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.price = json["price"].stringValue
        self.days = json["days"].stringValue
        self.formattedPrice = json["formatted_price"].stringValue
        self.inAppId = json["ios_id"].stringValue
    }
}

class Activeadplan {
    var status: Bool = false
    var message: String = ""
    
    init(from json: JSON) {
        self.status = json["status"].boolValue
        self.message = json["message"].stringValue
    }
}

class ActivePromoplan {
    var status: Bool = false
    var message: String = ""
    
    init(from json: JSON) {
        self.status = json["status"].boolValue
        self.message = json["message"].stringValue
    }
}

