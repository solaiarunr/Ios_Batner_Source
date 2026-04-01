//
//  BannerViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 16/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class BannerViewModel {
    
    var bannerModel: BannerModel?
    var bannerHistoryModel: BannerHistoryModel?
    var tosModel: TOSModel?
    var addBannerModel: AddBannerModel?
    
    public func getAddData(user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "lang_type":DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: GET_AD_WITH_US_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = BannerModel.init(fromJson: response)
            self.bannerModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func getHistoryAct(user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "lang_type":DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: GET_HISTORY_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = BannerHistoryModel.init(fromJson: response)
            self.bannerHistoryModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func checkBannerAvailability(user_id: String, start_date: String, end_date: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "start_date":start_date, "end_date": end_date]
        CallParsingFunction().postDataCall(subURl: BANNER_AVAILABILITY_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = AddBannerModel.init(fromJson: response)
            self.addBannerModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func AddBanner(user_id: String, currency_code: String, nonce: String, price:String, app_banner_url: String, web_banner_url: String, app_banner_link: String, web_banner_link: String, start_date: String, end_date: String, payment_type: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "currency_code":currency_code, "nonce":nonce, "price": price, "app_banner_url": app_banner_url, "web_banner_url": web_banner_url, "app_banner_link": app_banner_link, "web_banner_link": web_banner_link, "start_date": start_date, "end_date": end_date, "payment_type": payment_type]
        CallParsingFunction().postDataCall(subURl: ADD_BANNER_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = TOSModel.init(fromJson: response)
            self.tosModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
