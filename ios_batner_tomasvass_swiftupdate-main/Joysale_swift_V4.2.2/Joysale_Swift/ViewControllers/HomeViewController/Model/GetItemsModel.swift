//
//  GetItemsModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 12/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class GetItemsModel{

    var ads : [String]!
    var result : GetItemsResult!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        ads = [String]()
        let adsArray = json["ads"].arrayValue
        for adsData in adsArray{
            ads.append(adsData.stringValue)
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = GetItemsResult(fromJson: resultJson)
        }
        status = json["status"].boolValue
    }
}
class GetItemsResult{

    var items : [ItemModel]!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        items = [ItemModel]()
        let itemsArray = json["items"].arrayValue
        for itemsJson in itemsArray{
            let value = ItemModel(fromJson: itemsJson)
            items.append(value)
        }
    }
}

class ItemModel{

    var bestOffer : Bool!
    var buyType : String!
    var categoryId : Int!
    var categoryName : String!
    var childCategoryId : String!
    var childCategoryName : String!
    var commentsCount : String!
    var countryId : String!
    var currencyCode : String!
    var currencyMode : String!
    var currencyPosition : String!
    var emailVerification : Bool!
    var exchangeBuy : String!
    var facebookVerification : Bool!
    var filters : [FilterModel]!
    var formattedPrice : String!
    var formattedShippingCost : String!
    var formattedTotalPrice : String!
    var id : Int!
    var instantBuy : String!
    var itemApprove : String!
    var itemCondition : String!
    var itemConditionId : String!
    var itemDescription : String!
    var itemStatus : String!
    var itemTitle : String!
    var latitude : Float!
    var liked : String!
    var likesCount : Int!
    var location : String!
    var longitude : Float!
    var makeOffer : String!
    var mobileNo : String!
    var mobileVerification : Bool!
    var paypalId : String!
    var photos : [PhotoModel]!
    var postedTime : Int!
    var price : String!
    var productUrl : String!
    var promotionType : String!
    var quantity : Int!
    var ratingUserCount : String!
    var report : String!
    var sellerId : String!
    var sellerImg : String!
    var sellerName : String!
    var sellerRating : String!
    var sellerUsername : String!
    var shippingCost : String!
    var shippingTime : String!
    var showSellerMobile : Bool!
    var size : String!
    var subcatId : String!
    var subcatName : String!
    var totalPrice : Int!
    var viewsCount : Int!
    var youtubeLink : String!
    var product_type : String!
    var stream_thumb:String!
    var video_id:String!
    var playback_duration:String!
    var stream_status:String!
    var stream_id:String!
    var follow_status:String!
    var publisher_id:String!
    var giving_away:String!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        giving_away = json["giving_away"].stringValue
        publisher_id = json["publisher_id"].stringValue
        follow_status = json["follow_status"].stringValue
       stream_id = json["video_id"].stringValue
        stream_status = json["stream_status"].stringValue
        playback_duration = json["playback_duration"].stringValue
        video_id = json["video_id"].stringValue
        stream_thumb = json["stream_thumbnail"].stringValue
        product_type =  json["product_type"].stringValue
        bestOffer = json["best_offer"].boolValue
        buyType = json["buy_type"].stringValue
        categoryId = json["category_id"].intValue
        categoryName = json["category_name"].stringValue
        childCategoryId = json["child_category_id"].stringValue
        childCategoryName = json["child_category_name"].stringValue
        commentsCount = json["comments_count"].stringValue
        countryId = json["country_id"].stringValue
        currencyCode = json["currency_code"].stringValue
        currencyMode = json["currency_mode"].stringValue
        currencyPosition = json["currency_position"].stringValue
        emailVerification = json["email_verification"].boolValue
        exchangeBuy = json["exchange_buy"].stringValue
        facebookVerification = json["facebook_verification"].boolValue
        filters = [FilterModel]()
        let filtersArray = json["filters"].arrayValue
        for filtersJson in filtersArray{
            let value = FilterModel(fromJson: filtersJson)
            filters.append(value)
        }
        formattedPrice = json["formatted_price"].stringValue
        formattedShippingCost = json["formatted_shipping_cost"].stringValue
        formattedTotalPrice = json["formatted_total_price"].stringValue
        id = json["id"].intValue
        instantBuy = json["instant_buy"].stringValue
        itemApprove = json["item_approve"].stringValue
        itemCondition = json["item_condition"].stringValue
        itemConditionId = json["item_condition_id"].stringValue
        itemDescription = json["item_description"].stringValue
//        if self.checkIfHTML(itemDescription) {
//            if !itemDescription.contains("</p>") {
//                itemDescription = "<p>\(itemDescription ?? "")</p>"
//            }
//            itemDescription = itemDescription.html2String
//        }
        
        itemStatus = json["item_status"].stringValue
        itemTitle = json["item_title"].stringValue.html2String
        latitude = json["latitude"].floatValue
        liked = json["liked"].stringValue
        likesCount = json["likes_count"].intValue
        location = json["location"].stringValue
        longitude = json["longitude"].floatValue
        makeOffer = json["make_offer"].stringValue
        mobileNo = json["mobile_no"].stringValue
        mobileVerification = json["mobile_verification"].boolValue
        paypalId = json["paypal_id"].stringValue
        photos = [PhotoModel]()
        let photosArray = json["photos"].arrayValue
        for photosJson in photosArray{
            let value = PhotoModel(fromJson: photosJson)
            photos.append(value)
        }
        postedTime = json["posted_time"].intValue
        price = json["price"].stringValue
        productUrl = json["product_url"].stringValue
        promotionType = json["promotion_type"].stringValue
        quantity = json["quantity"].intValue
        ratingUserCount = json["rating_user_count"].stringValue
        report = json["report"].stringValue
        sellerId = json["seller_id"].stringValue
        sellerImg = json["seller_img"].stringValue
        sellerName = json["seller_name"].stringValue
        sellerRating = json["seller_rating"].stringValue
        sellerUsername = json["seller_username"].stringValue
        shippingCost = json["shipping_cost"].stringValue
        shippingTime = json["shipping_time"].stringValue
        showSellerMobile = json["show_seller_mobile"].boolValue
        size = json["size"].stringValue
        subcatId = json["subcat_id"].stringValue
        subcatName = json["subcat_name"].stringValue
        totalPrice = json["total_price"].intValue
        viewsCount = json["views_count"].intValue
        youtubeLink = json["youtube_link"].stringValue
    }
    func checkIfHTML(_ desc: String) -> Bool {
        if desc.contains("<p>") || desc.contains("<a>") || desc.contains("</a>") || desc.contains("</p>") || desc.contains("href=") || desc.contains("<li>") || desc.contains("<ul>") || desc.contains("</div>") || desc.contains("</span>") || desc.contains("</ul>") {
            return true
        }
        return false
    }
}
class PhotoModel{

    var height : String!
    var itemUrlMain350 : String!
    var itemUrlMainOriginal : String!
    var width : String!
    var itemImage: String!
    var type: String!
    var mediaType: String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        height = json["height"].stringValue
        itemUrlMain350 = json["item_url_main_350"].stringValue
        itemUrlMainOriginal = json["item_url_main_original"].stringValue
        itemImage = json["item_image"].stringValue
        width = json["width"].stringValue
        type = json["type"].stringValue
        mediaType = json["media_type"].stringValue
    }
    init(height: String, itemUrlMain350: String, itemUrlMainOriginal: String, width: String) {
        self.height = height
        self.itemUrlMain350 = itemUrlMain350
        self.itemUrlMainOriginal = itemUrlMainOriginal
        self.width = width
    }
}

class FilterModel{

    var maxValue : String!
    var minValue : String!
    var parentId : String!
    var parentLabel : String!
    var childId : String!
    var childLabel : String!
    var type : String!
    var value : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        maxValue = json["max_value"].stringValue
        minValue = json["min_value"].stringValue
        parentId = json["parent_id"].stringValue
        parentLabel = json["parent_label"].stringValue
        childId = json["child_id"].stringValue
        childLabel = json["child_label"].stringValue
        type = json["type"].stringValue
        if type == "range" {
            value = json["value"].stringValue
        }
        else if type == "dropdown" {
                 value = json["child_label"].stringValue
         }
        else {
            value = "\(json["subparent_label"].stringValue) • \(json["child_label"].stringValue)"
        }
    }
}
