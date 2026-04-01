//
//  ChatModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 30/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChatModel {

    var block : Bool!
    var blockedByMe : Bool!
    var chatId : Int!
    var chatUrl : String!
    var chats : [ChildChatModel]!

    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        block = json["block"].boolValue
        blockedByMe = json["blocked_by_me"].boolValue
        chatId = json["chat_id"].intValue
        chatUrl = json["chat_url"].stringValue
        chats = [ChildChatModel]()
        let chatsArray = json["chats"]["chats"].arrayValue.reversed()
        for chatsJson in chatsArray{
            let value = ChildChatModel(fromJson: chatsJson)
            chats.append(value)
        }
        status = json["status"].boolValue
    }
}
class ChildChatModel {

    var buynowStatus : Int!
    var chatId : Int!
    var currencyMode : String!
    var currencyPosition : String!
    var formattedOfferPrice : String!
    var formattedShippingPrice : String!
    var formattedTotalOfferPrice : String!
    var instantBuy : Int!
    var itemId : String!
    var itemImage : String!
    var itemStatus : String!
    var itemTitle : String!
    var message : MessageModel!
    var offerCurrency : String!
    var offerCurrencyCode : String!
    var offerId : Int!
    var offerPrice : String!
    var offerStatus : Int!
    var offerType : String!
    var receiver : String!
    var sellerId : Int!
    var sender : String!
    var totalOfferPrice : String!
    var type : String!
    var audioDuration : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        buynowStatus = json["buynow_status"].intValue
        chatId = json["chat_id"].intValue
        currencyMode = json["currency_mode"].stringValue
        currencyPosition = json["currency_position"].stringValue
        audioDuration = json["audio_duration"].stringValue
        formattedOfferPrice = json["formatted_offer_price"].stringValue
        formattedShippingPrice = json["formatted_shipping_price"].stringValue
        formattedTotalOfferPrice = json["formatted_total_offer_price"].stringValue
        instantBuy = json["instant_buy"].intValue
        itemId = json["item_id"].stringValue
        itemImage = json["item_image"].stringValue
        itemStatus = json["item_status"].stringValue
        itemTitle = json["item_title"].stringValue.html2String
        let messageJson = json["message"]
        if !messageJson.isEmpty{
            message = MessageModel(fromJson: messageJson)
        }
        offerCurrency = json["offer_currency"].stringValue
        offerCurrencyCode = json["offer_currency_code"].stringValue
        offerId = json["offer_id"].intValue
        offerPrice = json["offer_price"].stringValue
        offerStatus = json["offer_status"].intValue
        offerType = json["offer_type"].stringValue
        receiver = json["receiver"].stringValue
        sellerId = json["seller_id"].intValue
        sender = json["sender"].stringValue
        totalOfferPrice = json["total_offer_price"].stringValue
        type = json["type"].stringValue
    }
    init(type: String, receiver: String, sender: String, message: MessageModel, sourceID: String, itemImage: String, itemTitle: String, audioDuration: String) {
        self.itemId = sourceID
        self.message = message
        self.receiver = receiver
        self.sender = sender
        self.type = type
        self.itemImage = itemImage
        self.itemTitle = itemTitle
        self.audioDuration = audioDuration
     }
}

class MessageModel {
    
    var chatTime : Int!
    var imageName : String!
    var message : String!
    var userImage : String!
    var userName : String!
    var uploadImage: String!
    var uploadAudio: String!
    var latitude: String!
    var longitude: String!
    var image_url: String!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        chatTime = json["chatTime"].intValue
        imageName = json["imageName"].stringValue
        message = json["message"].stringValue
        userImage = json["userImage"].stringValue
        userName = json["userName"].stringValue
        uploadImage = json["upload_image"].stringValue
        uploadAudio = json["upload_audio"].stringValue
        latitude = json["latitude"].stringValue
        longitude = json["longitude"].stringValue
        image_url = json["image_url"].stringValue
    }
    init(chatTime: Int, imageName: String, message: String, userImage: String, userName: String, uploadImage: String, latitude: String, longitude: String, uploadAudio: String,image_url: String) {
        self.chatTime = chatTime
        self.imageName = imageName
        self.message = message
        self.userImage = userImage
        self.userName = userName
        self.uploadImage = uploadImage
        self.latitude = latitude
        self.longitude = longitude
        self.uploadAudio = uploadAudio
        self.image_url = image_url
    }
}
