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
    
    public func makeCall(toId: String,fromId: String,chatId: String, room_id: String, type: String,timestamp: Int,  onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
         var epocTime =  TimeInterval(timestamp)
        let myDate = NSDate(timeIntervalSince1970: epocTime)
        print("Converted Time:\(myDate)")
        let time_Stamp=myDate.timeIntervalSince1970
        print("timestamp:\(timestamp)")
        var language = "";
        if(UserDefaultModule.shared.getAppLanguage().count > 2)
        {
            language   = String(UserDefaultModule.shared.getAppLanguage().lowercased().prefix(2));
        }
                           let parameter: [String: Any] = ["toId":toId, "fromId": fromId, "chatId": chatId, "room_id":room_id, "platform":"ios","language" : "\(language)", "type": type,"timestamp" :(toGlobalTime(date: myDate)).description]
        
        CallParsingFunction().postDataCall(subURl: MAKE_CALL_URL, params: parameter, onSuccess: { (response) in
            print(response)
            //            let rootClass = PremiumListModel.init(fromJson: response)
            //            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
     public func missedCall(fromId: String,toId: String, chatId: String,type: String, room_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let timeStamp = Date().timeIntervalSince1970

        let parameter: [String: Any] = ["fromId":fromId, "toId":toId, "room_id": room_id, "chatId": chatId, "type": type, "chatTime": (Int(timeStamp))]
        
        CallParsingFunction().postDataCall(subURl: MISSED_CALL_URL, params: parameter, onSuccess: { (response) in
            print(response)
//            let rootClass = UserLoginModel.init(fromJson: response)
//            if (rootClass.status ?? false) {
//                self.endCall(sender_id: fromId, receiver_id: toId, room_id: room_id, type: "")
             self.endCall(toId: toId, fromId: fromId, room_id: room_id, type: "bye", chatId: chatId)
    //        }
     //       success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    func toGlobalTime(date: NSDate) -> String {
            let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: date as Date))
//        let date = Date(timeInterval: seconds, since: date as Date)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"///this is what you want to convert format
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
       formatter.locale = Locale(identifier: "en_US_POSIX")
        let timeStamp = formatter.string(from: date as Date)
        return timeStamp
        }
  
    public func endCall(toId: String,fromId: String,room_id:String, type: String, chatId: String) {
        
        var language = "";
        if(UserDefaultModule.shared.getAppLanguage().count > 2)
        {
            language   = String(UserDefaultModule.shared.getAppLanguage().lowercased().prefix(2));
        }
        let parameter: [String: Any] = ["fromId":fromId, "toId":toId, "room_id": room_id, "chatId": chatId, "type": "bye"]
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
