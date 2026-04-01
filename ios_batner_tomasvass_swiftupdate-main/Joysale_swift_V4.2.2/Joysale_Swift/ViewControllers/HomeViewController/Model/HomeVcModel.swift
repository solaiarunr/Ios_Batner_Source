//
//  HomeVcModel.swift
//  Joyshorts_Swift
//
//  Created by HTS on 22/12/22.
//

import Foundation
import SwiftyJSON

class HomeVcModel{
    var status : Bool!
    var result : [TopCategoryModel]!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [TopCategoryModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = TopCategoryModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
        
class TopCategoryModel{
    var category_id : String!
    var category_name : String!
    var category_image : String!
    var category_short_title : String!
    var category_short_desc : String!
    var bannerdata_count : Int!
    var subcategorydata_count : Int!
    var bannerData : [TopSubBannerModel]!
    var subcategory : [TopSubCategoryModel]!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        category_id = json["category_id"].stringValue
        category_name = json["category_name"].stringValue
        category_image = json["category_image"].stringValue
        category_short_title = json["category_short_title"].stringValue
        category_short_desc = json["category_short_desc"].stringValue
        bannerdata_count = json["bannerdata_count"].intValue
        subcategorydata_count = json["subcategorydata_count"].intValue
        
        subcategory = [TopSubCategoryModel]()
        let subcategoryArray = json["subcategory"].arrayValue
        for subcategoryJson in subcategoryArray{
            let value = TopSubCategoryModel(fromJson: subcategoryJson)
            subcategory.append(value)
        }
        
        bannerData = [TopSubBannerModel]()
        let bannerDataArray = json["bannerData"].arrayValue
        for bannerDataJson in bannerDataArray{
            let value = TopSubBannerModel(fromJson: bannerDataJson)
            bannerData.append(value)
        }
    }
    func checkIfHTML(_ desc: String) -> Bool {
        if desc.contains("<p>") || desc.contains("<a>") || desc.contains("</a>") || desc.contains("</p>") || desc.contains("href=") || desc.contains("<li>") || desc.contains("<ul>") || desc.contains("</div>") || desc.contains("</span>") || desc.contains("</ul>") {
            return true
        }
        return false
    }
}
    
class TopSubCategoryModel{
    var sub_id : String!
    var sub_name : String!
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        sub_id = json["sub_id"].stringValue
        sub_name = json["sub_name"].stringValue

    }
}
        
class TopSubBannerModel{
    var bannerImage : String!
    var bannerURL : String!
                
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        bannerImage = json["bannerImage"].stringValue
        bannerURL = json["bannerURL"].stringValue
    }
}
