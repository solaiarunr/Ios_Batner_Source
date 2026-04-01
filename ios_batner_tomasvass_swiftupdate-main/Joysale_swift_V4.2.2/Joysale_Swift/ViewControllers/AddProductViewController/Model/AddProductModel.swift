//
//  AddProductModel.swift
//  Joyshorts_Swift
//
//  Created by Hitasoft on 24/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class AddProductImageModel {
    
    var isuploaded: Bool!
    var image: UIImage!
    var imageUrl: String!
    
    init(isUploaded: Bool, image: UIImage, imageUrl: String) {
        self.isuploaded = isUploaded
        self.image = image
        self.imageUrl = imageUrl
    }
    static func == (lhs: AddProductImageModel, rhs: AddProductImageModel) -> Bool {
        return lhs.isuploaded == rhs.isuploaded && lhs.image == rhs.image && lhs.imageUrl == rhs.imageUrl
    }
}

class AddPoductResultModel{

    var itemId : String!
    var message : String!
    var productUrl : String!
    var promotionType : String!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        itemId = json["item_id"].stringValue
        message = json["message"].stringValue
        productUrl = json["product_url"].stringValue
        promotionType = json["promotion_type"].stringValue
        status = json["status"].boolValue
    }
}
