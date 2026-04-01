//
//  StripeModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 01/07/21.
//  Copyright © 2021 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON


class StripeDataModel{
    var status: Bool!
    var customer: String!
    var ephemeralKey: String!
    var paymentIntent: String!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].boolValue
        customer = json["customer"].stringValue
        ephemeralKey = json["ephemeralKey"].stringValue
        paymentIntent = json["paymentIntent"].stringValue
    }
    init(status: Bool = false,customer: String = "", ephemeralKey: String = "", paymentIntent: String = "") {
        self.status = status
        self.customer = customer
        self.ephemeralKey = ephemeralKey
        self.paymentIntent = paymentIntent
    }
}
