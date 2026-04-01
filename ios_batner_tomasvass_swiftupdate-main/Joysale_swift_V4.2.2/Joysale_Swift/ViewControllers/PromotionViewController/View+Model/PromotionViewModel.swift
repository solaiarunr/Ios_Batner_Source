//
//  PromotionViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 20/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class PromotionViewModel {
    
    var premiumModel: PromotionModel?
    var getPromotionModel: GetPromotionModel?
    var getSubcriptionModel: GetSubcribtionModel?
    var checkoutModel: SignupModel?
    var itemPromotionResultModel: ItemPromotionModel?

    public func myPromotionData(user_id: String,type: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "type":type, "lang_type": DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: MY_PROMOTIONS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = PromotionModel.init(fromJson: response)
            self.premiumModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func getPromotionData( onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["lang_type": DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: GET_PROMOTION_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetPromotionModel.init(fromJson: response)
            self.getPromotionModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getSubcriptionData( onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["lang_type": DEFAULT_LANGUAGE_CODE, "user_id": UserDefaultModule.shared.getUserData()?.user_id ?? ""]
    
        CallParsingFunction().postDataCall(subURl: get_subcribe_plan, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetSubcribtionModel.init(fromJson: response)
            self.getSubcriptionModel = rootClass
             success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public  func subcriptionPayment(user_id: String,subscription_id: String,pay_nonce: String, currency_code: String,type: String, onSuccess success:@escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id": user_id, "lang_type": DEFAULT_LANGUAGE_CODE,"subscription_id":subscription_id,  "pay_nonce": pay_nonce, "currency_code": currency_code, "payment_type": type]
        CallParsingFunction().postDataCall(subURl: Subcription_PAYMENT, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SignupModel.init(fromJson: response)
            self.checkoutModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func processingPayment(user_id: String,item_id: String,promotion_id: String, currency_code: String, pay_nonce: String, payment_type: String,ios_id:String = "",price:String = "",currency_symbol:String = "", onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id": user_id, "lang_type": DEFAULT_LANGUAGE_CODE, "item_id": item_id, "promotion_id":promotion_id, "currency_code": currency_code, "pay_nonce": pay_nonce, "payment_type": payment_type,"inapp_id":ios_id,"price":price,"currency_symbol":currency_symbol]
        CallParsingFunction().postDataCall(subURl: PROCESSING_PAYMENT_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SignupModel.init(fromJson: response)
            self.checkoutModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func checkPromotionData(item_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["item_id":item_id, "lang_type": DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: CHECK_PROMOTION_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ItemPromotionModel.init(fromJson: response)
            self.itemPromotionResultModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
}
