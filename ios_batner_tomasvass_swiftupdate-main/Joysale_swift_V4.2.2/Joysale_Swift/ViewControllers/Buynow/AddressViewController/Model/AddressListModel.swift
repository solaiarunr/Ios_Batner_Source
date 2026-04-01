//
//  AddressListModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 26/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON


class AddressListModel {

    var result : [AddressListResultModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [AddressListResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray.reversed() {
            let value = AddressListResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
class AddressListResultModel {

    var address1 : String!
    var address2 : String!
    var city : String!
    var country : String!
    var countrycode : Int!
    var defaultshipping : Int!
    var name : String!
    var nickname : String!
    var phone : String!
    var shippingid : Int!
    var state : String!
    var zipcode : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        address1 = json["address1"].stringValue
        address2 = json["address2"].stringValue
        city = json["city"].stringValue
        country = json["country"].stringValue
        countrycode = json["countrycode"].intValue
        defaultshipping = json["defaultshipping"].intValue
        name = json["name"].stringValue
        nickname = json["nickname"].stringValue
        phone = json["phone"].stringValue
        shippingid = json["shippingid"].intValue
        state = json["state"].stringValue
        zipcode = json["zipcode"].stringValue
    }
}
