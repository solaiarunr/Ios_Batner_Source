//
//  HelpViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 09/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class HelpViewModel {
    
    var tosModel: TOSModel?
    var helpModel: HelpModel?
    
    public func getTOSData(onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":""]
    
        CallParsingFunction().postDataCall(subURl: TOS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = TOSModel.init(fromJson: response)
            self.tosModel = rootClass
            success(self.tosModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getSaftyTips(onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: SAFETY_TIPS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = TOSModel.init(fromJson: response)
            self.tosModel = rootClass
            success(self.tosModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getHelpPageData(onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["lang_type":DEFAULT_LANGUAGE_CODE]
    
        CallParsingFunction().postDataCall(subURl: HELP_PAGE_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = HelpModel.init(fromJson: response)
            self.helpModel = rootClass
            success(self.helpModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
