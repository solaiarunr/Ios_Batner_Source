//
//  StripeViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 01/07/21.
//  Copyright © 2021 Hitasoft. All rights reserved.
//

import Foundation

class StripeDataViewModel {
    
    var stripeModel: StripeDataModel?
    
    public func getStripeDetails(amount: String,currency: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["amount": amount, "currency":currency]
        CallParsingFunction().postDataCall(subURl: BALLENCE_SHEET_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = StripeDataModel.init(fromJson: response)
            self.stripeModel = rootClass
             success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
