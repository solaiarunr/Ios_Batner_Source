//
//  ProfileViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit    //fornewaddon
import Foundation

class CreditsViewModel {
    
  
    var creditModel: CreditModel?
    var promoModel: Promocodemodel?
    var ChangecodeModel: Changecodemodel?
    var boostitemModel: BoostitemModel?
  
    
    let delegate = UIApplication.shared.delegate as! AppDelegate  //fornewaddon

  
    public func getcreditData(user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id]
        
        CallParsingFunction().postDataCall(subURl: getcredits_api, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = CreditModel.init(fromJson: response)
            self.creditModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func applycodeApi(user_id: String, code: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "code": code]
        
        CallParsingFunction().postDataCall(subURl: applycode_api, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = Promocodemodel.init(fromJson: response)
            self.promoModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func ChangecodeApi(user_id: String, code: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "code": code]
        
        CallParsingFunction().postDataCall(subURl: changecode_api, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = Changecodemodel.init(fromJson: response)
            self.ChangecodeModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func BoostitemApi(user_id: String, item_id: String, boost_type: String, promotion_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        var parameter: [String: Any] = ["user_id":user_id]
        if boost_type == "top"{
            parameter = ["user_id":user_id, "item_id": item_id, "boost_type": boost_type, "promotion_id": promotion_id]
        }else{
            parameter = ["user_id":user_id, "item_id": item_id, "boost_type": boost_type]
        }
            
        
        CallParsingFunction().postDataCall(subURl: boostitem_api, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = BoostitemModel.init(fromJson: response)
            self.boostitemModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
 
}
