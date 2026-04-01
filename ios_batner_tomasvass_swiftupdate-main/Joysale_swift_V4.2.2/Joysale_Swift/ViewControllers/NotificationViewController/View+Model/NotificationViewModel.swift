//
//  NotificationViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class NotificationViewModel {
    
    var notificationModel: NotificationModel?
    public func getNotificationData(user_id: String,offset: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "offset":offset, "limit": "20"]
    
        CallParsingFunction().postDataCall(subURl: NOTIFICATION_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = NotificationModel.init(fromJson: response)
            self.notificationModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
