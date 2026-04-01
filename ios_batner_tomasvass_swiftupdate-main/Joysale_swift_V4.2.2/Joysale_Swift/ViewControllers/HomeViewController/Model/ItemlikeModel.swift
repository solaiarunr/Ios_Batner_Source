//
//  ItemlikeModel.swift
//  Joyshorts_Swift
//
//  Created by HTS on 05/01/23.
//

import Foundation
import SwiftyJSON

class ItemlikeModel{

    var likesCount : Int!
    var result : String!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }

        status = json["status"].boolValue
        result = json["result"].stringValue
        likesCount = json["likes_count"].intValue
    }
}
