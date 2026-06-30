//
//  ProfileModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON


class ProfileModel {
    var result : ProfileResultModel!
    var status : Bool!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = ProfileResultModel(fromJson: resultJson)
        }
        status = json["status"].boolValue
    }

}
class SubscribeModel{
    
    var result : [SubscribeResultModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [SubscribeResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = SubscribeResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }

}
class FreePostModel{
    
    var result : [ProductDetailModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [ProductDetailModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = ProductDetailModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }

}


class SubscribeResultModel{
     var paidAmount : Int!
    var status : String!
    var totalPost : Int!
    var transactionId : String!
    var subscriptionPlan: String!
    var currentStatus: String!
    var availablePosts: String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        paidAmount = json["paid_amount"].intValue
        status = json["status"].stringValue
        totalPost = json["total_post"].intValue
        transactionId = json["transaction_id"].stringValue
        subscriptionPlan = json["subscription_plan"].stringValue
        currentStatus = json["current_status"].stringValue
        availablePosts = json["available_posts"].stringValue
    }
 
}
class ProductDetailModel{

var balancePost : String!
var freepost : String!
var subscriptionEnable : Int!
var totalPost : String!
 
init(fromJson json: JSON!){
    if json.isEmpty{
        return
    }
    balancePost = json["balance_post"].stringValue
    freepost = json["freepost"].stringValue
    subscriptionEnable = json["subscription_enable"].intValue
    totalPost = json["total_post"].stringValue
}
 }


class ProfileResultModel{

    var city : String!
    var country : String!
    var email : String!
    var facebookId : String!
    var fullName : String!
    var location : String!
    var mobileNo : String!
    var rating : String!
    var ratingUserCount : String!
    var credit_balance : String!
    var can_access : Bool!
    var referral_code_locked : Bool!
    var showMobileNo : Bool!
    var state : String!
    var stripeDetails : StripeDetailModel!
    var userId : Int!
    var userImg : String!
    var userName : String!
    var verification : VerificationModel!
    var emailVerification : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        city = json["city"].stringValue
        emailVerification = json["email_verification"].stringValue
        country = json["country"].stringValue
        email = json["email"].stringValue
        facebookId = json["facebook_id"].stringValue
        fullName = json["full_name"].stringValue
        location = json["location"].stringValue
        mobileNo = json["mobile_no"].stringValue.replacingOccurrences(of: "+", with: "")
        rating = json["rating"].stringValue
        ratingUserCount = json["rating_user_count"].stringValue
        credit_balance = json["credit_balance"].stringValue
        can_access = json["can_access"].boolValue
        referral_code_locked = json["referral_code_locked"].boolValue
        showMobileNo = json["show_mobile_no"].boolValue
        state = json["state"].stringValue
        let stripeDetailsJson = json["stripe_details"]
        if !stripeDetailsJson.isEmpty{
            stripeDetails = StripeDetailModel(fromJson: stripeDetailsJson)
        }
        userId = json["user_id"].intValue
        userImg = json["user_img"].stringValue
        userName = json["user_name"].stringValue
        let verificationJson = json["verification"]
        if !verificationJson.isEmpty{
            verification = VerificationModel(fromJson: verificationJson)
        }
    }

}
class VerificationModel{

    var email : Bool!
    var facebook : Bool!
    var mobNo : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        email = json["email"].boolValue
        facebook = json["facebook"].boolValue
        mobNo = json["mob_no"].boolValue
    }

}
class StripeDetailModel{

    var stripePrivatekey : String!
    var stripePublickey : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        stripePrivatekey = json["stripe_privatekey"].stringValue
        stripePublickey = json["stripe_publickey"].stringValue
    }

}
class FollowerModel {

    var result : [String]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [String]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            result.append(resultJson.stringValue)
        }
        status = json["status"].boolValue
    }
}
class StripeModel {

    var result : StripeResultModel!
    var status : Bool!
    var url:String!
    var returnurl:String!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = StripeResultModel(fromJson: resultJson)
        }
        status = json["status"].boolValue
        url = json["url"].stringValue
        returnurl = json["returnurl"].stringValue
    }
}
class StripeResultModel {
     var stripePrivatekey : String!
    var stripePublickey : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        stripePrivatekey = json["stripe_privatekey"].stringValue
        stripePublickey = json["stripe_publickey"].stringValue
    }
}
class  OtherProfileModel{

    var status : String!
    var profile_id : String!
    var message : String!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].stringValue
        profile_id = json["profile_id"].stringValue
        message = json["message"].stringValue
    }

}
