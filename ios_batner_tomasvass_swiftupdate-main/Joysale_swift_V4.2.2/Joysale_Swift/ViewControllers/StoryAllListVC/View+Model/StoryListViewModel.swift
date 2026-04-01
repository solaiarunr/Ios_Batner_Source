//
//  StoryListViewModel.swift
//  ProductsVideo
//
//  Created by MAC BOOK on 12/11/22.
//

import Foundation
import SwiftyJSON

class StoryListViewModel {
    
    var storyListArray = [StoryListModel]()
    var storymodel: StoryModel?
    var productmodel: ProductModel?
    
    public func getStoryData(url:String,startRequest:[String: Any], onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {

        ProductsVideoParsing().postDetails(subURl: url, params: startRequest as! Parameters) { (response) in
            print(response)
            let rootClass = StoryModel.init(fromJson: response)
            self.storymodel = rootClass
            self.storyListArray = rootClass.result
            success(rootClass.status)
        } onFailure: { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    /*
    public func getStoryData(user_id: String,offset: String,limit: String, isOwnVideo: Bool, videoID: String = "", scroll_type: String = "",fromNav : String = "",hts_product_id:String,position: String,before_position:String,after_position:String,type: String,price: String,search_key: String,category_id: String,subcategory_id:String,item_id:String,seller_id:String,sorting_id: String,posted_within: String, distance: String,distance_type:String,lang_type:String, filters:String, product_condition:String,child_category_id: String,lon: String, lat:String,search_type: String, promotionTags: String = "", onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {

        var url = ""
        var parameter = [String: Any]()
        if fromNav == "Home"{
            url = HTS_VIDEOS
         //   parameter = ["user_id":user_id, "offset":offset, "limit": limit,"type":type,"video_id":videoID]
            parameter = ["user_id":user_id,
                         "offset":offset,
                         "limit": limit,
                         "video_id":videoID,
                         "scroll_type":scroll_type,
                         "hts_product_id": hts_product_id,
                         "position": position,
                         "before_position": before_position,
                         "after_position": after_position,
                         "type":type,
                         "price":price,
                         "search_key": search_key,
                         "category_id": category_id,
                         "subcategory_id": (subcategory_id == "viewall" ? "" : subcategory_id),
                         "item_id": item_id,
                         "seller_id": seller_id,
                         "sorting_id": sorting_id,
                         "posted_within": posted_within,
                         "distance": distance,
                         "distance_type": distance_type,
                         "lang_type": lang_type,
                         "filters": filters,
                         "product_condition": product_condition,
                         "child_category_id": (child_category_id == "viewall" ? "" : child_category_id),
                         "lat": lat,
                         "lon": lon,
                         "search_type": search_type
                        ]
            if promotionTags != "" {
                parameter["ads"] = promotionTags
            }
            
        }else if fromNav == "profile"{
            if isOwnVideo {
                print("unique ideeeee")
                url = HTS_MY_VIDEOS
                parameter = ["user_id":user_id, "video_id": videoID, "scroll_type":type, "offset": offset, "limit": limit]
            }
        }
        else{
            url = HTS_PRODUCT_VIDEOS
            parameter = ["user_id":user_id, "offset":offset, "limit": limit]
        }
        ProductsVideoParsing().postDetails(subURl: url, params: parameter) { (response) in
            print(response)
            let rootClass = StoryModel.init(fromJson: response)
            self.storymodel = rootClass
            self.storyListArray = rootClass.result
            success(rootClass.status)
        } onFailure: { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    
   */
    
    
/*
    public func getStoryData(user_id: String,offset: String,limit: String, isOwnVideo: Bool, videoID: String = "", scroll_type: String = "",fromNav : String = "",category_id: String,subcategory_id: String,child_category_id:String ,hts_product_id: String,position : String,before_position:String ,after_position:String ,onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
    
        var url = ""
        var parameter = [String: Any]()
        if fromNav == "Home"{
            url = HTS_VIDEOS
         //   parameter = ["user_id":user_id, "offset":offset, "limit": limit,"type":type,"video_id":videoID]

            parameter = ["price":FILTER_DATA.Price ?? "", "search_key": FILTER_DATA.Search_key ?? "", "item_id": FILTER_DATA.item_id ?? "", "seller_id": FILTER_DATA.seller_id ?? "", "sorting_id": FILTER_DATA.getSortID(), "posted_within": FILTER_DATA.posted_within ?? "", "distance": FILTER_DATA.distance ?? "", "distance_type": FILTER_DATA.distance_type ?? "", "lang_type": DEFAULT_LANGUAGE_CODE, "lat":  FILTER_DATA.long ?? "", "lon":  FILTER_DATA.long ?? "","user_id":user_id, "offset":offset, "limit": limit,"type":scroll_type,"video_id":videoID,"hts_product_id":hts_product_id,"position":position,"before_position":before_position,"after_position":after_position,"category_id": category_id, "subcategory_id": (subcategory_id == "viewall" ? "" : subcategory_id),"child_category_id": (child_category_id == "viewall" ? "" : child_category_id),"type":"search"]
            
        }else if fromNav == "profile"{
            if isOwnVideo {
                print("unique ideeeee")
                url = HTS_MY_VIDEOS
                parameter = ["user_id":user_id, "video_id": videoID, "type":type, "offset": offset, "limit": limit]
            }
        }
        else{
            url = HTS_PRODUCT_VIDEOS
            parameter = ["user_id":user_id, "offset":offset, "limit": limit]
        }
//        let parameter: [String: Any] = ["user_id":email, "password":password]

        ProductsVideoParsing().postDetails(subURl: url, params: parameter) { (response) in
            print(response)
            let rootClass = StoryModel.init(fromJson: response)
            self.storyListArray = rootClass.result
            success(rootClass.status)
        } onFailure: { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
 */
    public func getItems(user_id: String,offset: String,limit: String,productID: [String], onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let products = self.jsonString(from: productID)
        let param: [String: Any] = ["user_id": user_id, "offset": offset, "limit": limit, "search": "", "productId": products ?? ""]
        ProductsVideoParsing().postDetails(subURl: PRODUCT_LIST_API, params: param) { (response) in
            print(response)
            let rootClass = ProductModel.init(fromJson: response)
            self.productmodel = rootClass
            success(self.productmodel?.status ?? false)
        } onFailure: { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    func jsonString(from object: [String]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    public func loadAppDefaults(onSuccess success: @escaping (JSON) -> Void, onFailure failure: @escaping (String) -> Void) {

        ProductsVideoParsing().getDetails(subURl: APP_DEFAULT_API, onSuccess: { (response) in
            print(response)
            success(response)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
