//
//  CallViewModel.swift
//  Howzu_swift
//
//  Created by Hitasoft on 01/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON
class CallViewModel {
    
    var statusModel: CheckChatModel?
    
    public func makeCall(fromId: String,toId: String,room_id: String,chatId: String,type: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {

        
        var language = "";
        if(UserDefaultModule.shared.getAppLanguage().count > 2)
        {
            language   = String(UserDefaultModule.shared.getAppLanguage().lowercased().prefix(2));
        }
        let timeStamp = Date().timeIntervalSince1970

        let parameter: [String: Any] = ["fromId":fromId, "toId": toId, "chatId": chatId,"type": type, "room_id":room_id, "platform":"ios", "timestamp": (Int(timeStamp)),"language" : "\(language)"]

        CallParsingFunction().postDataCall(subURl: MAKE_CALL_URL, params: parameter, onSuccess: { (response) in
            print(response)
            //            let rootClass = PremiumListModel.init(fromJson: response)
            //            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
     public func missedCall(fromId: String,toId: String, chatId: String,type: String, room_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["senderId":fromId, "receiverId":toId, "room_id": room_id]
        
        //Params:       fromId=57, chat_id=42}

        CallParsingFunction().postDataCall(subURl: MISSED_CALL_URL, params: parameter, onSuccess: { (response) in
            print(response)
 //           let rootClass = UserLoginModel.init(fromJson: response)
 //           if (rootClass.status ?? false) {
//                self.endCall(sender_id: fromId, receiver_id: toId, room_id: room_id, type: "")
                self.endCall(sender_id: fromId, receiver_id: toId, room_id: room_id, type: "", trigger_type: "call", chatId: room_id)
  //          }
  //          success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func endCall(sender_id: String,receiver_id: String,room_id:String, type: String, trigger_type: String, chatId: String) {
        
        var language = "";
        if(UserDefaultModule.shared.getAppLanguage().count > 2)
        {
            language   = String(UserDefaultModule.shared.getAppLanguage().lowercased().prefix(2));
        }
        let parameter: [String: Any] = ["senderId":sender_id, "receiverId":receiver_id, "room_id": room_id, "chatId": chatId, "trigger_type": trigger_type]
        CallParsingFunction().postDataCall(subURl: END_CALL_URL, params: parameter, onSuccess: { (response) in
            print(response)
            
        }) { (error) in
        }
    }
}


class CheckChatModel {
    var call_status: String!
    var status: Bool!
    init(fromJson json: JSON!) {
        call_status = json["call_status"].stringValue
        status = json["status"].boolValue
    }
}
