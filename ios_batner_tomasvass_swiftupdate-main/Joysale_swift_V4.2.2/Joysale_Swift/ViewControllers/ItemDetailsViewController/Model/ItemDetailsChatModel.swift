//
//  ItemDetailsChatModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 24/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class ItemDetailsChatModel {

    var chatId : String!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        chatId = json["chat_id"].stringValue
        status = json["status"].boolValue
    }

}

class SoldToAddonModel{
    
    var result : [SoldToResultModel]!
    var status : Bool!

 
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [SoldToResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = SoldToResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
 }
class SoldToResultModel {
    
    var fullName : String!
    var userId : Int!
    var userImage : String!
    var userName : String!

     init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        fullName = json["full_name"].stringValue
        userId = json["user_id"].intValue
        userImage = json["user_image"].stringValue
        userName = json["user_name"].stringValue
    }
  }



