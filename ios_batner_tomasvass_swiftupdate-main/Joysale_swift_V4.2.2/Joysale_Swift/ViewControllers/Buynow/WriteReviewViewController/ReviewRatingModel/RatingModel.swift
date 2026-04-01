//
//  RatingModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 06/06/21.
//  Copyright © 2021 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class RatingModel {

    var result : RatingResultModel!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = RatingResultModel(fromJson: resultJson)
        }
        status = json["status"].boolValue
    }
}
class RatingResultModel {

    var rating : Int!
    var reviewDes : String!
    var reviewId : Int!
    var reviewItemId : String!
    var reviewTitle : String!
    var reviewUserId : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        rating = json["rating"].intValue
        reviewDes = json["review_des"].stringValue
        reviewId = json["review_id"].intValue
        reviewItemId = json["review_itemId"].stringValue
        reviewTitle = json["review_title"].stringValue
        reviewUserId = json["review_userId"].stringValue
    }
}
