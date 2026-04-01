//
//  AddressViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 26/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class AddressViewModel {
    
    var resultModel: AddressResultModel?
    var addressListModel: AddressListModel?
    
    public func addShippingAddress(user_id: String, full_name: String, nick_name: String, country_id: String,country_name: String,  state: String, address1: String, address2: String, city: String, zip_code: String, phone_no:String, defaultAddress:String, shipping_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "full_name": full_name, "nick_name": nick_name, "country_id": country_id, "country_name": country_name, "state": state, "address1": address1, "address2": address2, "city": city, "zip_code": zip_code, "phone_no": phone_no, "default": defaultAddress, "shipping_id": shipping_id]
        CallParsingFunction().postDataCall(subURl: ADD_SHIPPING_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = AddressResultModel.init(fromJson: response)
            self.resultModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getShippingAddressAct(user_id: String, item_id: String,  onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "item_id": item_id]
        CallParsingFunction().postDataCall(subURl: GET_SHIPPING_ADDRESS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = AddressListModel.init(fromJson: response)
            self.addressListModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func setDefaultAddress(user_id: String, shipping_id: String,  onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "shipping_id": shipping_id]
        CallParsingFunction().postDataCall(subURl: SET_DEFAULT_SHIPPING_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = AddressListModel.init(fromJson: response)
//            self.addressListModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func deleteAddress(user_id: String, shipping_id: String,  onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "shipping_id": shipping_id]
        CallParsingFunction().postDataCall(subURl: REMOVE_SHIPPING_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = AddressListModel.init(fromJson: response)
            //            self.addressListModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
