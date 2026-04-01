//
//  FollowerModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class FollowerListModel {

    var result : [FollowerResultModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [FollowerResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = FollowerResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
class FollowerResultModel {

    var fullName : String!
    var status : String!
    var userId : Int!
    var userImage : String!
    var userName : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        fullName = json["full_name"].stringValue
        status = json["status"].stringValue
        userId = json["user_id"].intValue
        userImage = json["user_image"].stringValue
        userName = json["user_name"].stringValue
    }
}
