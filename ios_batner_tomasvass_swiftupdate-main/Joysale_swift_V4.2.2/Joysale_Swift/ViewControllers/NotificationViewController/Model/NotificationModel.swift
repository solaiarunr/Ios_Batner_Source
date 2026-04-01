//
//  NotificationModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class NotificationModel {

    var result : [NotificationResultModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [NotificationResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = NotificationResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
class NotificationResultModel {

    var eventTime : Int!
    var itemId : Int!
    var itemImage : String!
    var itemTitle : String!
    var message : String!
    var type : String!
    var userId : Int!
    var userImage : String!
    var userName : String!
    var paidAmount: String!
    var promotionDays: String!
    var expireDate: String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        eventTime = json["event_time"].intValue
        itemId = json["item_id"].intValue
        itemImage = json["item_image"].stringValue
        itemTitle = json["item_title"].stringValue.html2String
        message = json["message"].stringValue
        type = json["type"].stringValue
        userId = json["user_id"].intValue
        userImage = json["user_image"].stringValue
        userName = json["user_name"].stringValue
        paidAmount = json["paid_amount"].stringValue
        promotionDays = json["promotion_days"].stringValue
        expireDate = json["expire_date"].stringValue
    }
}
