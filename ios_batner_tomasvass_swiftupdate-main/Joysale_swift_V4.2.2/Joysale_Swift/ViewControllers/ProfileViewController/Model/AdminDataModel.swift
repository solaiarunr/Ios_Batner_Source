//
//  AdminDataModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON


class AdminDataModel {

    var result : AdminResultModel!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = AdminResultModel(fromJson: resultJson)
        }
        status = json["status"].boolValue
    }

}
class AdminResultModel{
    
    var adminCurrencyCode : String!
    var adminPaymentType : String!
    var banner : String!
    var bannerData : [BannerDatumModel]!
    var block : String!
    var buynow : String!
    var category : [CategoryModel]!
    var chatTemplate : [ChatTemplateModel]!
    var distance : String!
    var distanceType : String!
    var emailVerification : String!
    var exchange : String!
    var facebookAppid : String!
    var facebookSecret : String!
    var givingAway : String!
    var paidBanner : String!
    var priceRange : PriceRangeModel!
    var promotion : String!
    var siteMaintenance : String!
    var siteMaintenanceText : String!
    var stripePublicKey : String!
    var socketUrl : String!
    var googleAds : String!
    var googleAdsAndroid : String!
    var mapboxToken : String!
    var googleAdsIos : String!
    var apprtcUrl : String!

     
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        adminCurrencyCode = json["admin_currency_code"].stringValue
        adminPaymentType = json["admin_payment_type"].stringValue
        banner = json["banner"].stringValue
        bannerData = [BannerDatumModel]()
        let bannerDataArray = json["bannerData"].arrayValue
        for bannerDataJson in bannerDataArray{
            let value = BannerDatumModel(fromJson: bannerDataJson)
            bannerData.append(value)
        }
        block = json["block"].stringValue
        buynow = json["buynow"].stringValue
        category = [CategoryModel]()
        let categoryArray = json["category"].arrayValue
        for categoryJson in categoryArray{
            let value = CategoryModel(fromJson: categoryJson)
            category.append(value)
        }
        chatTemplate = [ChatTemplateModel]()
        let chatTemplateArray = json["chat_template"].arrayValue
        for chatTemplateJson in chatTemplateArray{
            let value = ChatTemplateModel(fromJson: chatTemplateJson)
            chatTemplate.append(value)
        }
        distance = json["distance"].stringValue
        distanceType = json["distance_type"].stringValue
        emailVerification = json["email_verification"].stringValue
        exchange = json["exchange"].stringValue
        facebookAppid = json["facebook_appid"].stringValue
        facebookSecret = json["facebook_secret"].stringValue
        givingAway = json["giving_away"].stringValue
        paidBanner = json["paid_banner"].stringValue
        let priceRangeJson = json["price_range"]
        if !priceRangeJson.isEmpty{
            priceRange = PriceRangeModel(fromJson: priceRangeJson)
        }
        promotion = json["promotion"].stringValue
        siteMaintenance = json["site_maintenance"].stringValue
        siteMaintenanceText = json["site_maintenance_text"].stringValue
        stripePublicKey = json["stripePublicKey"].stringValue
        socketUrl = json["socket_url"].stringValue
        googleAds = json["google_ads"].stringValue
        googleAdsAndroid = json["google_ads_android"].stringValue
        mapboxToken = json["mapbox_token"].stringValue
        googleAdsIos = json["google_ads_ios"].stringValue
        apprtcUrl = json["apprtc_url"].stringValue
    }
      
}

class AdModel{

    var status : String!
    var  adstatus: String!
    var plan_days:String!
    var expiry_date:String!
    var plan_name:String!
    var ad_desc:String!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].stringValue
        adstatus = json["adstatus"].stringValue
        plan_days = json["plan_days"].stringValue
        expiry_date = json["expiry_date"].stringValue
        plan_name = json["plan_name"].stringValue
        ad_desc = json["ad_desc"].stringValue
    }

}

class PremiumModel{

    var status : String!
    var  premiumstatus: String!
    var plan_days:String!
    var expiry_date:String!
    var plan_name:String!
    var premium_desc:String!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].stringValue
        premiumstatus = json["premiumstatus"].stringValue
        plan_days = json["plan_days"].stringValue
        expiry_date = json["expiry_date"].stringValue
        plan_name = json["plan_name"].stringValue
        premium_desc = json["premium_desc"].stringValue
    }

}

 

class PriceRangeModel{

    var afterDecimalNotation : String!
    var beforeDecimalNotation : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        afterDecimalNotation = json["after_decimal_notation"].stringValue
        beforeDecimalNotation = json["before_decimal_notation"].stringValue
    }

}
class ChatTemplateModel {

    var name : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        name = json["name"].stringValue
    }

}
class CategoryModel {

    var categoryId : Int!
    var categoryImg : String!
    var categoryName : String!
    var subcategory : [SubcategoryModel]!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        categoryId = json["category_id"].intValue
        categoryImg = json["category_img"].stringValue
        categoryName = json["category_name"].stringValue
        subcategory = [SubcategoryModel]()
        let subcategoryArray = json["subcategory"].arrayValue
        for subcategoryJson in subcategoryArray{
            let value = SubcategoryModel(fromJson: subcategoryJson)
            subcategory.append(value)
        }
    }

}
class SubcategoryModel: Equatable{

    var subId : Int!
    var subName : String!
    var childCategory : [ChildCategoryModel]!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        subId = json["sub_id"].intValue
        subName = json["sub_name"].stringValue
        childCategory = [ChildCategoryModel]()
        let childCategoryArray = json["child_category"].arrayValue
        for childCategoryJson in childCategoryArray{
            let value = ChildCategoryModel(fromJson: childCategoryJson)
            childCategory.append(value)
        }
    }
    static func ==(lhs: SubcategoryModel, rhs: SubcategoryModel) -> Bool {
        return lhs.subId == rhs.subId && lhs.subName == rhs.subName
    }
}
class ChildCategoryModel{

    var childId : Int!
    var childName : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        childId = json["child_id"].intValue
        childName = json["child_name"].stringValue
    }
}

class BannerDatumModel{

    var bannerImage : String!
    var bannerURL : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        bannerImage = json["bannerImage"].stringValue
        bannerURL = json["bannerURL"].stringValue
    }

}

class GetCountModel{

    var chatCount : Int!
    var notificationCount : Int!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        chatCount = json["result"]["chatCount"].intValue
        notificationCount = json["result"]["notificationCount"].intValue
        status = json["status"].boolValue
    }
}
