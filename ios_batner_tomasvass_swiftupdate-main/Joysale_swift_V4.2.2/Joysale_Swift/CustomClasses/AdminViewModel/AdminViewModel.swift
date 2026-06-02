//
//  AdminViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 17/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class AdminViewModel {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var adminModel: AdminDataModel?
    var productBeforeModel: ProductBeforeAddDataModel?
    var profileModel: ProfileModel?
    var getCountModel: GetCountModel?
    var postProductModel: FreePostModel?
    var subcribeDetailModel: SubscribeModel?
    var foraccesstoken: LoginModel?
    
    var addressListModel: AddressListModel?
    var ratingModel: RatingModel?
    
    var adModel: AdModel?
    var premiumModel:PremiumModel?
    public func getAdminData(onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: ADMIN_DATAS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = AdminDataModel.init(fromJson: response)
            self.adminModel = rootClass
            if rootClass.status {
                BUYNOW_MODEL_FLAG = ((self.adminModel?.result.buynow ?? "") == "disable") ? false : true
                PROMOTION_FLAG = ((self.adminModel?.result.promotion ?? "") == "disable") ? false : true
                EXCHANGE_MODEL_FLAG = ((self.adminModel?.result.exchange ?? "") == "disable") ? false : true
                PAID_BANNER_FLAG = ((self.adminModel?.result.paidBanner ?? "") == "disable") ? false : true
                EXCHANGE_MODEL_FLAG = ((self.adminModel?.result.exchange ?? "") == "disable") ? false : true
                chatURL = UserDefaultModule.shared.getchaturl() ?? "https://batner.com:2087"
//                print("sdfw",chatURL)
                BANNNER_ID = (self.adminModel?.result.googleAdsIos ?? "")
                MAPBOXACCESSTOKEN = (self.adminModel?.result.mapboxToken ?? "")
                APP_RTC_URL = (self.adminModel?.result.apprtcUrl ?? "")
                
          
                print("sdfnwfb",APP_RTC_URL)
                
            }
            if rootClass.status {
                if rootClass.result.siteMaintenance == "enable" {
                    self.delegate.initVC(initialView: SiteMaintananceViewController())
                }
                else {
                    success(self.adminModel?.status ?? false)
                }
            }
            else{
                success(self.adminModel?.status ?? false)
            }
            
        }) { (error) in
            failure(error?.localizedDescription ?? "")
            print("errorcomestrue:",error?.localizedDescription)
        }
    }
    public func getBraintreeToken(currency_code: String) {
        let parameter: [String: Any] = ["currency_code":currency_code]
        CallParsingFunction().postDataCall(subURl: BRAINTREE_CLIENT_TOKEN_URL, params: parameter, onSuccess: { (response) in
            let result = JSON(response)
            if result["status"].boolValue {
                BRAINTREE_TOKEN = result["token"].stringValue
            }
            print(response)
//
        }) { (error) in
        }
    }
    public func getCategoryData(onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: GET_CATEGORY_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = AdminDataModel.init(fromJson: response)
            
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    
    
    public func GetAdStatus(user_id:String,onSuccess success: @escaping (String) -> Void, onFailure failure: @escaping (String) -> Void) {
        //solai
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE,"user_id":user_id,"platform":"ios"]
    
        CallParsingFunction().postDataCall(subURl: AdStatusApi, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = AdModel.init(fromJson: response)
            self.adModel = rootClass
            success(rootClass.status ?? "false")
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    
    public func GetPremiumStatus(user_id:String,onSuccess success: @escaping (String) -> Void, onFailure failure: @escaping (String) -> Void) {
        //solai
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE,"user_id":user_id,"platform":"ios"]
    
        CallParsingFunction().postDataCall(subURl: PremiumStatusApi, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = PremiumModel.init(fromJson: response)
            self.premiumModel = rootClass
            success(rootClass.status ?? "false")
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    
    public func productBeforeAddData(lang_code: String = "",user_id: String = "", onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE,"user_id":user_id]
    
        CallParsingFunction().postDataCall(subURl: PRODUCT_BEFORE_ADD_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ProductBeforeAddDataModel.init(fromJson: response)
            self.productBeforeModel = rootClass
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
    public func reviewDetails(user_id: String, item_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "item_id": item_id]
        CallParsingFunction().postDataCall(subURl: REVIEW_DETAILS, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = RatingModel.init(fromJson: response)
            self.ratingModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
   
    public func getProfileData(user_id: String,user_name: String,profile_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["user_id":user_id, "user_name":user_name,"profile_id":profile_id]
    
        CallParsingFunction().postDataCall(subURl: GET_PROFILE_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ProfileModel.init(fromJson: response)
            self.profileModel = rootClass
            //UserDefaultModule.shared.setAccessToken(token1: self.foraccesstoken?.token ?? "")
            success(self.profileModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getSubscriData(user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
       
       let parameter: [String: Any] = ["user_id":user_id]
        CallParsingFunction().postDataCall(subURl: subscribe_URL, params: parameter, onSuccess: { (response) in
           print(response)
           let rootClass = SubscribeModel.init(fromJson: response)
            self.subcribeDetailModel = rootClass
           success(self.subcribeDetailModel?.status ?? false)
            print(rootClass)
          }) { (error) in
           failure(error?.localizedDescription ?? "")
       }
   }
     public func getProfileDetailCount(user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["user_id":user_id]
    
        CallParsingFunction().postDataCall(subURl: POST_DETAILS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = FreePostModel.init(fromJson: response)
            self.postProductModel = rootClass
            success(self.postProductModel?.status ?? false)
         }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
   
    public func loadLocationData(address: String, onSuccess success: @escaping (JSON) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["address": address, "key": GOOGLE_API_KEY]
        CallParsingFunction().getDataCall(subURl: GOOGLE_URL, params: parameter, onSuccess: { (response) in
            print(response)
            success(response)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func loadNotification(onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        UDID = (UIDevice.current.identifierForVendor?.uuidString ?? "")
        var DEVICE_MODE = ""
        #if DEBUG
         DEVICE_MODE = "0"
        #else
        DEVICE_MODE = "1"
       #endif
        
        let parameter: [String: Any] = ["deviceId": UDID, "userid": UserDefaultModule.shared.getUserData()?.user_id ?? "", "devicetype": "0", "deviceToken": (UserDefaultModule.shared.getFCMToken() ?? ""), "devicemode": DEVICE_MODE, "lang_type": DEFAULT_LANGUAGE_CODE, "device_name": "iPhone", "device_model": UIDevice.current.localizedModel, "device_os": UIDevice.current.systemVersion, "voip_token": (UserDefaultModule.shared.getPushToken() ?? "")]
        CallParsingFunction().postDataCall(subURl: ADD_DEVICE_ID_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ProfileModel.init(fromJson: response)
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getCountData(onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id": UserDefaultModule.shared.getUserData()?.user_id ?? ""]
        CallParsingFunction().postDataCall(subURl: GET_COUNT_DETAILS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetCountModel.init(fromJson: response)
            self.getCountModel = rootClass
            success(rootClass.status)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func resetBadge(deviceToken: String) {
        let parameter: [String: Any] = ["deviceToken": deviceToken]
        CallParsingFunction().postDataCall(subURl: RESET_BADGE_URL, params: parameter, onSuccess: { (response) in
            print(response)
        }) { (error) in
        }
    }
    public func pushSignout() {
        let parameter: [String: Any] = ["deviceId": UDID]
        CallParsingFunction().postDataCall(subURl: PUSH_SIGNOUT_URL, params: parameter, onSuccess: { (response) in
            print("Response123456:",response)
        }) { (error) in
        }
    }
}
