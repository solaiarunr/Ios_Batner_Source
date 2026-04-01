//
//  ChatViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 30/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class ChatViewModel {
    
    var profileModel: ProfileModel?
    var tosModel: TOSModel?
    var itemChatModel: ItemDetailsChatModel?
    var chatModel: ChatModel?
    var chatListModel: ChatListModel?
    var itemModel: GetItemsModel?
    
    

    public func getMessages(user_id: String,offset: String,limit: String,  onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "offset":offset, "limit": limit]
        CallParsingFunction().postDataCall(subURl: MESSAGE_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ChatListModel.init(fromJson: response)
            self.chatListModel = rootClass
            success(self.chatListModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getChatData(sender_id: String,receiver_id: String,type: String, source_id: String, offset: String, limit: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["sender_id":sender_id, "receiver_id":receiver_id, "lang_type": DEFAULT_LANGUAGE_CODE, "type": type, "source_id": source_id, "offset": offset, "limit": limit]
    
        CallParsingFunction().postDataCall(subURl: GET_CHAT_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ChatModel.init(fromJson: response)
            self.chatModel = rootClass
            success(self.chatModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func offerStatusData(sender_id: String,offer_id: String,status: String, chat_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["sender_id":sender_id, "offer_id":offer_id, "lang_type": DEFAULT_LANGUAGE_CODE, "status": status, "chat_id": chat_id]
    
        CallParsingFunction().postDataCall(subURl: OFFER_STATUS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ProfileModel.init(fromJson: response)
            self.profileModel = rootClass
            success(self.profileModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func searchItemData(item_id: String,user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {

        let parameter: [String: Any] = ["item_id":item_id, "user_id":user_id, "lang_type": DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: SEARCH_BY_ITEM_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            self.itemModel = rootClass
            success(self.itemModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func sendChatData(sender_id: String,chat_id: String, type: String, message: String, source_id: String, current_latitude: String, current_longitude: String, image_url: String, chat_type: String,timeStamp: Int,audio_url: String,created_date: String, audio_duration: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
         

 
        let timeStamp = Date().timeIntervalSince1970
        var sourceID = source_id
        if source_id == "" {
            sourceID = "0"
        }
        var parameter: [String: Any] = ["sender_id":sender_id, "chat_id":chat_id, "type": type,"image_url": image_url, "message": message, "created_date": (Int(timeStamp)), "source_id": sourceID, "current_latitude": current_latitude, "current_longitude": current_longitude, "chat_type": chat_type,"audio_duration": audio_duration]

        if type == "audio_msg" {
            parameter["audio_url"] = audio_url
            parameter["audio_duration"] = audio_duration
        }
        else if type == "gif"{
            parameter["image_url"] = image_url
        }
        else if type == "image" {
            parameter["image_url"] = image_url
        }
        
         CallParsingFunction().postDataCall(subURl: SEND_CHAT_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ProfileModel.init(fromJson: response)
            self.profileModel = rootClass
            success(self.profileModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func chatActionData(user_id: String, action_id: String, action_value: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id": user_id,  "action_id": action_id, "action_value": action_value]
    
        CallParsingFunction().postDataCall(subURl: CHAT_ACTION_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = TOSModel.init(fromJson: response)
            self.tosModel = rootClass
            success(self.tosModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getChatIdAct(sender_id: String, receiver_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["receiver_id":receiver_id, "sender_id": sender_id]
        CallParsingFunction().postDataCall(subURl: GET_CHAT_ID_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ItemDetailsChatModel.init(fromJson: response)
            self.itemChatModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func updateExchangeStatus(user_id: String, exchange_id: String, status: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "exchange_id": exchange_id, "status": status]
        CallParsingFunction().postDataCall(subURl: EXCHANGE_STATUS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = TOSModel.init(fromJson: response)
            self.tosModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
