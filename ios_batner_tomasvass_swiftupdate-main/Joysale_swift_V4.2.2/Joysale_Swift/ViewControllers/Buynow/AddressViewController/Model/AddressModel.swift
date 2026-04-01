//
//  AddressModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 26/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class AddressModel {
    var title: String!
    var desc: String!
    var value: String!
    init(title: String, desc: String, value: String) {
        self.title = title
        self.desc = desc
        self.value = value
    }
}
class AddressResultModel {

    var message : String!
    var result : AddressListResultModel!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = AddressListResultModel(fromJson: resultJson)
        }
        message = json["result"].stringValue
        status = json["status"].boolValue
    }
}

