//
//  HelpModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 09/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON


class TOSModel{

    var message : String!
    var status : Bool!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        message = json["message"].string ?? json["result"].stringValue
        status = json["status"].boolValue
    }
}
class HelpModel {

    var result : [HelpResultModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [HelpResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = HelpResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
class HelpResultModel {

    var pageContent : String!
    var pageName : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        pageContent = json["page_content"].stringValue
        pageName = json["page_name"].stringValue
    }
}
