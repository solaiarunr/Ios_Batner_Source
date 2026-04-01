 //
 //  ChatListModel.swift
 //  Joysale_Swift
 //
 //  Created by Hitasoft on 03/07/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import Foundation
 import SwiftyJSON


 class ChatListModel {

     var result : [ChatListResultModel]!
     var status : Bool!

     init(fromJson json: JSON!){
         if json.isEmpty{
             return
         }
         result = [ChatListResultModel]()
         let resultArray = json["result"].arrayValue
         for resultJson in resultArray{
             let value = ChatListResultModel(fromJson: resultJson)
             result.append(value)
         }
         status = json["status"].boolValue
     }
 }
 class ChatListResultModel {

     var chatId : Int!
     var fullName : String!
     var lastRepliedto : String!
     var message : String!
     var messageId : Int!
     var messageTime : Int!
     var messageType : String!
     var type : String!
     var userId : Int!
     var userImage : String!
     var userName : String!
    init(chatId : Int = 0, fullName : String = "", lastRepliedto : String = "", message : String = "", messageId : Int = 0,messageTime : Int = 0, messageType : String = "", type : String = "", userId : Int = 0, userImage : String = "", userName : String = "") {
        self.chatId = chatId
        self.fullName = fullName
        self.lastRepliedto = lastRepliedto
        self.message = message
        self.messageId = messageId
        self.messageTime = messageTime
        self.messageType = messageType
        self.type = type
        self.userId = userId
        self.userImage = userImage
        self.userName = userName
    }
     init(fromJson json: JSON!){
         if json.isEmpty{
             return
         }
         chatId = json["chatId"].intValue
         fullName = json["full_name"].stringValue
         lastRepliedto = json["last_repliedto"].stringValue
         message = json["message"].stringValue
         messageId = json["message_id"].intValue
         messageTime = json["message_time"].intValue
         messageType = json["messageType"].stringValue
         type = json["type"].stringValue
         userId = json["user_id"].intValue
         userImage = json["user_image"].stringValue
         userName = json["user_name"].stringValue
     }
    
 }

