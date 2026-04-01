//
//  ItemDetailsViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 22/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
class ItemDetailsViewModel {
    var likeModel: ItemlikeModel?
    var getItemModel: GetItemsModel?
    var relatedProductModel: GetItemsModel?
    var itemChatModel: ItemDetailsChatModel?
    var checkoutModel: SignupModel?
    var alertModel: SignupModel?
    var insightsModel: InsightsModel?
    var commentModel: CommentModel?
    var soldToModel: SoldToAddonModel?
    
    public func getUserProductsData(category_id: String, subcategory_id: String, user_id: String, product_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE, "category_id": category_id, "subcategory_id": subcategory_id, "user_id": user_id, "product_id": product_id]
        CallParsingFunction().postDataCall(subURl: GET_USER_PRODUCTS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            self.getItemModel = rootClass
            success(self.getItemModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func updateViewCount(item_id: String, user_id: String) {
        
        let parameter: [String: Any] = ["item_id": item_id,"user_id": user_id]
        CallParsingFunction().postDataCall(subURl: UPDATE_VIEW_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SignupModel.init(fromJson: response)
            self.alertModel = rootClass
        }) { (error) in
        }
    }
    public func getItems(type: String,price: String,search_key: String,category_id: String,subcategory_id:String, user_id:String,item_id:String,seller_id:String,sorting_id: String,offset: String,limit: String,posted_within: String, distance: String,distance_type:String,lang_type:String, filters:String, product_condition:String,child_category_id: String,lon: String, lat:String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["type":type, "price":price, "search_key": search_key, "category_id": category_id, "subcategory_id": subcategory_id, "user_id":user_id, "item_id": item_id, "seller_id": seller_id, "sorting_id": sorting_id, "offset": offset, "limit": limit, "posted_within": posted_within, "distance": distance, "distance_type": distance_type, "lang_type": DEFAULT_LANGUAGE_CODE, "filters": filters, "product_condition": product_condition, "child_category_id": child_category_id, "lat": lat, "lon": lon]
        
        CallParsingFunction().postDataCall(subURl: GET_ITEMS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            self.relatedProductModel = rootClass
            success(self.relatedProductModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func itemLikedAct(user_id: String, item_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["user_id":user_id, "item_id": item_id]
        CallParsingFunction().postDataCall(subURl: ITEM_LIKED_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            //            self.getItemModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func soldItemAct(value: String, item_id: String,buyer_id: String = "", onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        var parameter: [String: Any] = ["value":value, "item_id": item_id]
        if buyer_id != "" {
            parameter["buyer_id"] = buyer_id
        }
        CallParsingFunction().postDataCall(subURl: SOLD_ITEM_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            //            self.getItemModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func getSoldToAddon(user_id: String, item_id: String,  onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "item_id": item_id]
        CallParsingFunction().postDataCall(subURl: SOLD_TO, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SoldToAddonModel.init(fromJson: response)
            self.soldToModel = rootClass
             success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func soldItemAddonAct(value: String, item_id: String, buyer_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["value":value, "item_id": item_id, "buyer_id" : buyer_id]
        CallParsingFunction().postDataCall(subURl: SOLD_ITEM_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            //            self.getItemModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    
    public func deleteProductAct(user_id: String, item_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["user_id":user_id, "item_id": item_id]
        CallParsingFunction().postDataCall(subURl: DELETE_PRODUCT_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetItemsModel.init(fromJson: response)
            //            self.getItemModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func reportItemAct(user_id: String, item_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["user_id":user_id, "item_id": item_id]
        CallParsingFunction().postDataCall(subURl: REPORT_ITEM_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SignupModel.init(fromJson: response)
            self.alertModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getChatIdAct(sender_id: String, receiver_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["receiver_id":receiver_id, "sender_id": sender_id]
        CallParsingFunction().postDataCall(subURl: GET_CHAT_ID_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ItemDetailsChatModel.init(fromJson: response)
            self.itemChatModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func sendofferRequest(sender_id: String, source_id: String, chat_id: String, message: String, offer_price: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let chat_time = Date().timeIntervalSince1970
        let parameter: [String: Any] = ["sender_id":sender_id, "source_id": source_id, "chat_id": chat_id, "created_date": "\(Int(chat_time))", "message": message, "offer_price": offer_price, "lang_type": DEFAULT_LANGUAGE_CODE]
        CallParsingFunction().postDataCall(subURl: SEND_OFFER_REQ_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ItemDetailsChatModel.init(fromJson: response)
//            self.itemChatModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func paymentAct(user_id: String, item_id: String, shipping_id:String, merchant_id:String, currency_code:String, nonce:String, item_price:String, shipping_fee:String, order_total:String, offer_id:String, payment_type:String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "item_id": item_id, "shipping_id": shipping_id, "merchant_id": merchant_id, "currency_code": currency_code, "nonce": nonce, "item_price": item_price, "shipping_fee": shipping_fee, "order_total": order_total, "offer_id": offer_id, "payment_type": payment_type, "lang_type": DEFAULT_LANGUAGE_CODE]
        CallParsingFunction().postDataCall(subURl: BUYNOW_PAYMENT_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SignupModel.init(fromJson: response)
            self.checkoutModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getInsightsData(user_id: String, product_id: String,  onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "product_id": product_id,"lang_type": DEFAULT_LANGUAGE_CODE]
        CallParsingFunction().postDataCall(subURl: GET_INSIGHTS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = InsightsModel.init(fromJson: response)
            self.insightsModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getComments(item_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["item_id":item_id]
        CallParsingFunction().postDataCall(subURl: GET_COMMENTS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = CommentModel.init(fromJson: response)
            self.commentModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func deleteComment(item_id: String, comment_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["item_id":item_id ,"comment_id": comment_id, "user_id": (UserDefaultModule.shared.getUserData()?.user_id ?? "")]
        CallParsingFunction().postDataCall(subURl: DELETE_COMMENT_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SignupModel.init(fromJson: response)
            self.alertModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func postComment(item_id: String, comment: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["item_id":item_id ,"comment": comment, "user_id": "\(UserDefaultModule.shared.getUserData()?.user_id ?? "")"]
        CallParsingFunction().postDataCall(subURl: POST_COMMENT_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SignupModel.init(fromJson: response)
            self.alertModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
