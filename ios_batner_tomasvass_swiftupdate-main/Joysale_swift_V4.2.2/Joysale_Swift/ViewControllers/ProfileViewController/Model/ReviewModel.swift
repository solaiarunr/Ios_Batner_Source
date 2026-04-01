//
//  ReviewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReviewModel {

    var result : [ReviewResultModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [ReviewResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = ReviewResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
class ReviewResultModel {

    var createdDate : Int!
    var fullName : String!
    var itemId : Int!
    var itemName : String!
    var rating : Int!
    var reviewDes : String!
    var reviewId : Int!
    var reviewTitle : String!
    var userId : Int!
    var userImage : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        createdDate = json["created_date"].intValue
        fullName = json["full_name"].stringValue
        itemId = json["item_id"].intValue
        itemName = json["item_name"].stringValue
        rating = json["rating"].intValue
        reviewDes = json["review_des"].stringValue
        reviewId = json["review_id"].intValue
        reviewTitle = json["review_title"].stringValue
        userId = json["user_id"].intValue
        userImage = json["user_image"].stringValue
    }
}
