 //
 //  GetPromotionModel.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 22/07/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import Foundation
 import SwiftyJSON

 class GetPromotionModel {

     var result : GetPromotionResultModel!
     var status : Bool!

     init(fromJson json: JSON!){
         if json.isEmpty{
             return
         }
         let resultJson = json["result"]
         if !resultJson.isEmpty{
             result = GetPromotionResultModel(fromJson: resultJson)
         }
         status = json["status"].boolValue
     }
 }
 class GetPromotionResultModel {

     var currencyCode : String!
     var currencyMode : String!
     var currencyPosition : String!
     var currencySymbol : String!
     var formattedUrgent : String!
     var otherPromotions : [OtherPromotionModel]!
     var urgent : Int!
    

     init(fromJson json: JSON!){
         if json.isEmpty{
             return
         }
         currencyCode = json["currency_code"].stringValue
         currencyMode = json["currency_mode"].stringValue
         currencyPosition = json["currency_position"].stringValue
         currencySymbol = json["currency_symbol"].stringValue
         formattedUrgent = json["formatted_urgent"].stringValue
         otherPromotions = [OtherPromotionModel]()
         let otherPromotionsArray = json["other_promotions"].arrayValue
         for otherPromotionsJson in otherPromotionsArray{
             let value = OtherPromotionModel(fromJson: otherPromotionsJson)
             otherPromotions.append(value)
         }
         urgent = json["urgent"].intValue
     }
 }
 class GetSubcribtionModel {

     var result : GetSubcriptionResultModel!
     var status : Bool!

     init(fromJson json: JSON!){
         if json.isEmpty{
             return
         }
         let resultJson = json["result"]
         if !resultJson.isEmpty{
             result = GetSubcriptionResultModel(fromJson: resultJson)
         }
         status = json["status"].boolValue
     }
 }
 class GetSubcriptionResultModel {
     
     var currencyCode : String!
     var currencySymbol : String!
     var subscriptions : [Subscription]!

     
     init(fromJson json: JSON!){
         if json.isEmpty{
             return
         }
         currencyCode = json["currency_code"].stringValue
         currencySymbol = json["currency_symbol"].stringValue
         subscriptions = [Subscription]()
         let subscriptionsArray = json["subscriptions"].arrayValue
         for subscriptionsJson in subscriptionsArray{
             let value = Subscription(fromJson: subscriptionsJson)
             subscriptions.append(value)
         }
     }
 }
 class Subscription{

     var id : Int!
     var listcount : Int!
     var name : String!
     var price : String!
    var subscription_price : String!

     
     init(fromJson json: JSON!){
         if json.isEmpty{
             return
         }
         id = json["id"].intValue
         listcount = json["listcount"].intValue
         name = json["name"].stringValue
         price = json["price"].stringValue
        subscription_price = json["subscription_price"].stringValue
     }
 }
 class OtherPromotionModel {

     var days : Int!
     var formattedPrice : String!
     var id : Int!
     var name : String!
     var price : String!
     var ios_id : String!
     
     

     init(fromJson json: JSON!){
         if json.isEmpty{
             return
         }
         days = json["days"].intValue
         formattedPrice = json["formatted_price"].stringValue
         id = json["id"].intValue
         name = json["name"].stringValue
         price = json["price"].stringValue
         ios_id = json["ios_id"].stringValue
     }
 }

