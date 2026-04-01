//
//  HomeViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 12/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class HomeViewModel {
    
    var getItemModel: GetItemsModel?
    
    public func getItems(type: String,price: String,search_key: String,category_id: String,subcategory_id:String, user_id:String,item_id:String,seller_id:String,sorting_id: String,offset: String,limit: String,posted_within: String, distance: String,distance_type:String,lang_type:String, filters:String, product_condition:String,child_category_id: String,lon: String, lat:String,search_type: String, promotionTags: String = "",selected_type:String = "", onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        
        var parameter: [String: Any] = ["type":type, "price":price, "search_key": search_key, "category_id": category_id, "subcategory_id": (subcategory_id == "viewall" ? "" : subcategory_id), "user_id":user_id, "item_id": item_id, "seller_id": seller_id, "sorting_id": sorting_id, "offset": offset, "limit": limit, "posted_within": posted_within, "distance": distance, "distance_type": distance_type, "lang_type": lang_type, "filters": filters, "product_condition": product_condition, "child_category_id": (child_category_id == "viewall" ? "" : child_category_id), "lat": lat, "lon": lon, "search_type": search_type,"selected_type":selected_type]
        if promotionTags != "" {
            parameter["ads"] = promotionTags
        }
    
        CallParsingFunction().postDataCall(subURl: GET_ITEMS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            self.getItemModel = rootClass
            success(self.getItemModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
