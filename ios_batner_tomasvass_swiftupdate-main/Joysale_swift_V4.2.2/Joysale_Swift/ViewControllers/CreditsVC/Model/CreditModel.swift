//
//  ReviewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class CreditModel {

    var history : [CreditResultModel]!
    var status : Bool!
    var balance : String!
    var referral_code : String!
    var referral_code_locked : String!
    var invite_url : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        history = [CreditResultModel]()
        let resultArray = json["history"].arrayValue
        for resultJson in resultArray{
            let value = CreditResultModel(fromJson: resultJson)
            history.append(value)
        }
        status = json["status"].boolValue
        balance = json["balance"].stringValue
        referral_code = json["referral_code"].stringValue
        referral_code_locked = json["referral_code_locked"].stringValue
        invite_url = json["invite_url"].stringValue
    }
}
class CreditResultModel {

    var amount : String!
    var type : String!
    var note : String!
    var created_at : String!
   
   

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        amount = json["amount"].stringValue
        type = json["type"].stringValue
        note = json["note"].stringValue
        created_at = json["created_at"].stringValue
       
    }
}


class Promocodemodel {

    var status : Bool!
    var message : String!
    var balance : String!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].boolValue
        message = json["message"].stringValue
        balance = json["balance"].stringValue
       
    }
}

class Changecodemodel {

    var status : Bool!
    var message : String!
    var code : String!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].boolValue
        message = json["message"].stringValue
        code = json["code"].stringValue
       
    }
}

class BoostitemModel {

    var status : Bool!
    var message : String!
    var new_balance : String!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].boolValue
        message = json["message"].stringValue
        new_balance = json["new_balance"].stringValue
       
    }
}
