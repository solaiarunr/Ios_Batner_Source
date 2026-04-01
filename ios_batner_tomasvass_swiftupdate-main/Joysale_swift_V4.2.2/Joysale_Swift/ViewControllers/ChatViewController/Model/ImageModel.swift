//
//  ImageModel.swift
//  Meetdoc
//
//  Created by Hitasoft on 13/10/20.
//  Copyright © 2020 BTMani. All rights reserved.
//

import Foundation
import SwiftyJSON


class ImageModel {

    var result : ImageResultModel!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = ImageResultModel(fromJson: resultJson)
        }
        status = json["status"].boolValue
    }

}

class ImageResultModel {

    var image : String!
    var name : String!
    var isNew : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        image = json["image"].stringValue
        name = json["name"].stringValue
        isNew = false
    }

}
