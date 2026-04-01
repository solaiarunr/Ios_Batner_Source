//
//  CountrylistModel.swift
//  Joysale_Swift
//
//  Created by HTS-PRO-2018 on 27/03/25.
//  Copyright © 2025 Hitasoft. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CountrylistModel{
    
    var result : [CountrylistArrModel]!
    var status : String!
    
    init(fromJson json:JSON){
        if json.isEmpty{
            return
        }
        status =  json["status"].stringValue
        result =  [CountrylistArrModel]()
        let  resultarr =  json["country_list"].arrayValue
        for resultjson in resultarr {
            let value = CountrylistArrModel(fromJson: resultjson)
            result.append(value)
        }
        
    }
    
    
}

class  CountrylistArrModel {
    var flag_image  : String!
    var country_code  : String!
    var country_name  : String!
    var site_url:String!
    init(fromJson json:JSON){
        if json.isEmpty{
            return
        }
        flag_image =  json["flag_image"].stringValue
        country_code =  json["country_code"].stringValue
        country_name =  json["country_name"].stringValue
        site_url =  json["site_url"].stringValue
        
    }
    
    
}


class  GetselectedCountrylist {
    var status : String!
    var country_code  : String!
    var country_name  : String!
    var site_url: String!
    var chat_url: String!
    var stream_url: String!
    
    init(fromJson json:JSON){
        if json.isEmpty{
            return
        }
        status =  json["status"].stringValue
        country_code =  json["country_code"].stringValue
        country_name =  json["country_name"].stringValue
        site_url = json["site_url"].stringValue
        chat_url = json["chat_url"].stringValue
        stream_url = json["stream_url"].stringValue
        
    }
    

    
}
