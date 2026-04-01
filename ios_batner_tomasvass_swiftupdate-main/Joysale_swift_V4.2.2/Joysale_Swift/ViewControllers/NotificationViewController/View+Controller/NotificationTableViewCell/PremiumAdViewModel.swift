//
//  PremiumAdViewModel.swift
//  Joysale_Swift
//
//  Created by HTS-PRO-2018 on 07/11/25.
//  Copyright © 2025 Hitasoft. All rights reserved.
//

import Foundation

class PremiumAdViewModel {
    var premiumAdModel: PremiumAdModel?
    var activeadplan: Activeadplan?
    var activePromoplan: ActivePromoplan?
    var premiumPromoModel: PremiumPromoModel?
    public func getAdpremiumdata(user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "lang_type": DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: Getadpremiumlist, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = PremiumAdModel.init(from: response)
            self.premiumAdModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    
    public func getpremiumdata(user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "lang_type": DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: PremiumlistApi, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = PremiumPromoModel.init(from: response)
            self.premiumPromoModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func activeaddplan(user_id: String,adplan_id:String,inapp_id:String,purchase_token:String,price:String,currency_symbol:String,currency_code:String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "lang_type": DEFAULT_LANGUAGE_CODE,"adplan_id":adplan_id,"inapp_id":inapp_id,"platform":"ios","purchase_token":purchase_token,"price":price,"currency_symbol":currency_symbol,"currency_code":currency_code]
    
        CallParsingFunction().postDataCall(subURl: Activeadplan_Api, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = Activeadplan.init(from: response)
            self.activeadplan = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    
    
    public func activepromoplan(user_id: String,adplan_id:String,inapp_id:String,purchase_token:String = "",price:String,currency_symbol:String,currency_code:String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "lang_type": DEFAULT_LANGUAGE_CODE,"adplan_id":adplan_id,"inapp_id":inapp_id,"platform":"ios","purchase_token":purchase_token,"price":price,"currency_symbol":currency_symbol,"currency_code":currency_code]
        CallParsingFunction().postDataCall(subURl: Activepremiumplan, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ActivePromoplan.init(from: response)
            self.activePromoplan = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }

    
}

