//
//  StoryListModel.swift
//  ProductsVideo
//
//  Created by MAC BOOK on 12/11/22.
//

import Foundation
import SwiftyJSON

class StoryModel {
    var ads : [String]!
    var status: Bool!
    var newOffset: Int!
    var result: [StoryListModel]!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        self.status = json["status"].boolValue
        self.newOffset = json["new_offset"].intValue
        self.result = [StoryListModel]()
        let storyArray = json["result"].arrayValue
        for story in storyArray {
            let data = StoryListModel(fromJson: story)
            self.result.append(data)
        }
        ads = [String]()
        let adsArray = json["ads"].arrayValue
        for adsData in adsArray{
            ads.append(adsData.stringValue)
        }
    }
}
class StoryListModel {
    
    var streamThumbnail : String!
    //var products : [String]!
    var products : String!
    var shareLink : String!
    var videoType : String!
    var videoId : String!
    var playbackUrl : String!
    var publisherImage : String!
    var publisherId : String!
    var postedBy : String!
    var playbackDuration : String!
    var streamStatus: Int!
    var promotionType : String!
    
    var views_count: Int!
    var likesCount: Int!
    var commentsCount: Int!
    var liked: String!
    var share_link: String!
    var seller_image: String!
    
    var bestOffer : Bool!
    var buyType : String!
    var categoryId : Int!
    var categoryName : String!
    var childCategoryId : String!
    var childCategoryName : String!
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
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        streamThumbnail = json["stream_thumbnail"].stringValue
        /*
        products = [String]()
        let productArr = json["products"].arrayValue
        for product in productArr {
            self.products.append(product.stringValue)
        }
        */
        follow_status = json["follow_status"].stringValue
        seller_image = json["seller_image"].stringValue
        promotionType = json["promotion_type"].stringValue
        products = json["products"].stringValue
        shareLink = json["share_link"].stringValue
        videoType = json["video_type"].stringValue
        videoId = json["video_id"].stringValue
        publisherImage = json["publisher_image"].stringValue
        publisherId = json["publisher_id"].stringValue
        postedBy = json["posted_by"].stringValue
        playbackUrl = json["playback_url"].stringValue
        playbackDuration = json["playback_duration"].stringValue
        streamStatus = json["stream_status"].intValue
        
        views_count = json["views_count"].intValue
        likesCount = json["likes_count"].intValue
        commentsCount = json["comments_count"].intValue
        liked = json["liked"].stringValue
        
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
    
}
