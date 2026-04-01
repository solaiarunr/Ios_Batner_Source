//
//  ProductModel.swift
//  ProductsVideo
//
//  Created by APPLE on 07/11/22.
//

import Foundation
import SwiftyJSON

class ProductModel{
    
    var result : [GetItemsResult1]!
    var status : Bool!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        /*
        result = [GetItemsResult1]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = GetItemsResult1(fromJson: resultJson)
            result.append(value)
        }
        */
        
        result = [GetItemsResult1]()
        if let resultArray = json["result"].array {
            for resultJson in resultArray{
                let value = GetItemsResult1(fromJson: resultJson)
                result.append(value)
            }
        }
        else {
            if let resultArray = json["result"].dictionary {
                let value = GetItemsResult1(fromJson: json["result"])
                result.append(value)
             }
        }
        status = json["status"].boolValue
    }
    
    
}

class GetItemsResult1: Equatable{
    var product_image : String!
    var product_name : String!
    var product_id : String!
    var product_price : String!
    var product_currencysymbol : String!


    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        product_image = json["product_image"].stringValue
        product_name = json["product_name"].stringValue
        product_id = json["product_id"].stringValue
        product_price = json["product_price"].stringValue
        product_currencysymbol = json["currency_symbol"].stringValue

    }
    static func == (lhs: GetItemsResult1, rhs: GetItemsResult1) -> Bool {
        return lhs.product_id == rhs.product_id 
    }
    init(product_image: String, product_name: String, product_id: String, product_price: String, product_currencysymbol: String) {
        self.product_image = product_image
        self.product_name = product_name
        self.product_id = product_id
        self.product_price = product_price
        self.product_currencysymbol = product_currencysymbol
    }
    func copy() -> GetItemsResult1 {
        return GetItemsResult1(product_image: self.product_image, product_name: self.product_name, product_id: self.product_id,product_price: self.product_price ,product_currencysymbol: self.product_currencysymbol)
    }

}
extension Array where Element: Equatable {
  func uniqueElements() -> [Element] {
    var out = [Element]()

    for element in self {
      if !out.contains(element) {
        out.append(element)
      }
    }

    return out
  }
}
