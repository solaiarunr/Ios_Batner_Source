//
//  CountrylistViewModel.swift
//  Joysale_Swift
//
//  Created by HTS-PRO-2018 on 27/03/25.
//  Copyright © 2025 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
class CountrylistViewModel {
    var countrylistModel:CountrylistModel!
    
    var getselectedCountrylist :GetselectedCountrylist!
    public func getcountrylist(lang_code: String = "", onSuccess success: @escaping (String) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE]

        CallParsingFunction().postDataCall(subURl: Country_list_Api, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = CountrylistModel.init(fromJson: response)
            self.countrylistModel = rootClass
            success(rootClass.status ?? "true")
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    
    
    public func getselectedcountrylist(lang_code: String = "",country_code:String,country_name:String, onSuccess success: @escaping (String) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE,"country_code":country_code,"country_name":country_name]

        CallParsingFunction().postDataCall(subURl: selectedcountry_Api, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = GetselectedCountrylist.init(fromJson: response)
            self.getselectedCountrylist = rootClass
            success(rootClass.status ?? "true")
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
}



