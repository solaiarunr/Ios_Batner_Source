//
//  HomeViewVcModel.swift
//  Joyshorts_Swift
//
//  Created by HTS on 22/12/22.
//

import Foundation
import SwiftyJSON
import Alamofire

class HomeViewVcModel {
    
    var homeVcsModel: HomeVcModel?
  

    public func homeViewVcData(onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {

        var parameter: [String: Any] = ["lang_type" : DEFAULT_LANGUAGE_CODE,"user_id": UserDefaultModule.shared.getUserData()?.user_id ?? ""]
        
        CallParsingFunction().postDataCall(subURl: GET_HOME_HEADERS, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = HomeVcModel.init(fromJson: response)
            self.homeVcsModel = rootClass
            success(self.homeVcsModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
}
