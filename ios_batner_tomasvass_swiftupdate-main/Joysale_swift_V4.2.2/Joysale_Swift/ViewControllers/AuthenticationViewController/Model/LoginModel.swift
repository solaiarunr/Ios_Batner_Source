//
//  LoginModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 10/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON


class LoginModel: Codable {

    var email : String!
    var fullName : String!
    var photo : String!
    var rating : String!
    var ratingUserCount : String!
    var status : Bool!
    var user_id : String!
    var userName : String!
    var message : String!
    var userImage : String!
    var token : String!   //fornewaddon

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        email = json["email"].stringValue
        fullName = json["full_name"].stringValue
        photo = json["photo"].stringValue
        rating = json["rating"].stringValue
        ratingUserCount = json["rating_user_count"].stringValue
        status = json["status"].boolValue
        user_id = json["user_id"].stringValue
        userName = json["user_name"].stringValue
        message = json["message"].stringValue
        userImage = json["user_image"].stringValue
        token = json["access_token"].stringValue   //fornewaddon
    }
    
    init(email: String, fullName: String, photo: String, rating: String, ratingUserCount: String, status: Bool = true, userId: String, userName: String, message: String = "") {
        self.email = email
        self.fullName = fullName
        self.photo = photo
        self.rating = rating
        self.ratingUserCount = ratingUserCount
        self.status = status
        self.user_id = userId
        self.userName = userName
        self.message = message
        self.userImage = photo
       // self.token = token    //issue
    }

}

class SignupModel {

    var message : String!
    var status : Bool!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        message = json["message"].string ?? json["result"].stringValue
        status = json["status"].boolValue
    }
}

class SocialDataModel: Codable {
    var fName: String!
    var lName: String!
    var email: String!
    var id: String!
    var image: String!
    init(fName: String, email: String, id: String, image: String, lName: String) {
        self.fName = fName
        self.lName = lName
        self.email = email
        self.id = id
        self.image = image
    }
}
