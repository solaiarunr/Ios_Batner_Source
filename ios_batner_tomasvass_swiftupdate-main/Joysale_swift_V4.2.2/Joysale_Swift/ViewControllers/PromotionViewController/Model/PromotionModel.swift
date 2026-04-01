//
//  PromotionModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 20/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class PromotionModel{
    var result : [PromotionResultModel]!
    var status : Bool!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [PromotionResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = PromotionResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
class ItemPromotionModel{

    var result : PromotionResultModel!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].boolValue
        let resultArray = json["result"]
        result = PromotionResultModel(fromJson: resultArray)
    }
}
class PromotionResultModel{

    var currencyCode : String!
    var currencyMode : String!
    var currencyPosition : String!
    var currencySymbol : String!
    var formattedPaidAmount : String!
    var id : Int!
    var itemApprove : Int!
    var itemId : Int!
    var itemImage : String!
    var itemName : String!
    var paidAmount : Int!
    var promotionName : String!
    var status : String!
    var transactionId : String!
    var upto : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        currencyCode = json["currency_code"].stringValue
        currencyMode = json["currency_mode"].stringValue
        currencyPosition = json["currency_position"].stringValue
        currencySymbol = json["currency_symbol"].stringValue
        formattedPaidAmount = json["formatted_paid_amount"].stringValue
        id = json["id"].intValue
        itemApprove = json["item_approve"].intValue
        itemId = json["item_id"].intValue
        itemImage = json["item_image"].stringValue
        itemName = json["item_name"].stringValue.html2String
        paidAmount = json["paid_amount"].intValue
        promotionName = json["promotion_name"].stringValue
        status = json["status"].stringValue
        transactionId = json["transaction_id"].stringValue
        upto = json["upto"].stringValue
    }
    init(currencyCode : String, currencyMode : String, currencyPosition : String, currencySymbol: String, formattedPaidAmount : String, id: Int, itemApprove : Int, itemId : Int, itemImage : String, itemName : String, paidAmount : Int, promotionName : String, status : String, transactionId : String, upto : String) {
        self.currencyCode = currencyCode
        self.currencyMode = currencyMode
        self.currencyPosition = currencyPosition
        self.currencySymbol = currencySymbol
        self.formattedPaidAmount = formattedPaidAmount
        self.id = id
        self.itemApprove = itemApprove
        self.itemId = itemId
        self.itemImage = itemImage
        self.itemName = itemName
        self.paidAmount = paidAmount
        self.promotionName = promotionName
        self.status = status
        self.transactionId = transactionId
        self.upto = upto
    }
}
