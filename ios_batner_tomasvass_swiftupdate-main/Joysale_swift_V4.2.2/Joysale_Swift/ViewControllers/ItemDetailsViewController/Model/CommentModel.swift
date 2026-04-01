//
//  CommentModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 30/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON


class CommentModel {

    var result : CommentResultModel!
    var status : Bool!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = CommentResultModel(fromJson: resultJson)
        }
        status = json["status"].boolValue
    }
}
class CommentResultModel{

    var comments : [CommentSubModel]!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        comments = [CommentSubModel]()
        let commentsArray = json["comments"].arrayValue
        for commentsJson in commentsArray{
            let value = CommentSubModel(fromJson: commentsJson)
            comments.append(value)
        }
    }
}
class CommentSubModel{

    var comment : String!
    var commentId : Int!
    var commentTime : Int!
    var userFullName : String!
    var userId : Int!
    var userImg : String!
    var userName : String!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        comment = json["comment"].stringValue
        commentId = json["comment_id"].intValue
        commentTime = json["comment_time"].intValue
        userFullName = json["user_full_name"].stringValue
        userId = json["user_id"].intValue
        userImg = json["user_img"].stringValue
        userName = json["user_name"].stringValue
    }
}
