//
//  ExchangeViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 29/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class ExchangeViewModel {
    
    var getItemModel: GetItemsModel?
    var exchangeMessageModel: TOSModel?
    
    public func getItems(type: String,price: String,search_key: String,category_id: String,subcategory_id:String, user_id:String,item_id:String,seller_id:String,sorting_id: String,offset: String,limit: String,posted_within: String, distance: String,distance_type:String,lang_type:String, filters:String, product_condition:String,child_category_id: String,lon: String, lat:String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
//        let sellerid = user_id == seller_id ? "" : seller_id
        
        let parameter: [String: Any] = ["type":type, "price":price, "search_key": search_key, "category_id": category_id, "subcategory_id": subcategory_id, "user_id":user_id, "item_id": item_id, "seller_id": seller_id, "sorting_id": sorting_id, "offset": offset, "limit": limit, "posted_within": posted_within, "distance": distance, "distance_type": distance_type, "lang_type": lang_type, "filters": filters, "product_condition": product_condition, "child_category_id": child_category_id, "lat": lat, "lon": lon]
    
        CallParsingFunction().postDataCall(subURl: GET_ITEMS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            self.getItemModel = rootClass
            success(self.getItemModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func createExchangeAct(user_id: String,myitem_id: String,exchangeitem_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "myitem_id":myitem_id, "exchangeitem_id": exchangeitem_id]
    
        CallParsingFunction().postDataCall(subURl: CREATE_EXCHANGE_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = TOSModel.init(fromJson: response)
            self.exchangeMessageModel = rootClass
            success(self.exchangeMessageModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
