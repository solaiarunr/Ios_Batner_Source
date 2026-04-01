//
//  MyOrderSalesViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 06/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation

class MyOrderSalesViewModel {
    
    var resultModel: MyOrderSalesModel?
    var statusResultModel: TOSModel?
    var getTrackingDetails: GetTrackingDetails?
    
    public func myOrderSalesData(user_id: String, offset: String, limit: String, type: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "limit": limit, "offset": offset, "lang_type": DEFAULT_LANGUAGE_CODE]
        var subURL = MY_ORDERS_URL
        if type == "1" {
            subURL = MY_SALES_URL
        }
        CallParsingFunction().postDataCall(subURl: subURL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = MyOrderSalesModel.init(fromJson: response)
            self.resultModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func getOrderStatus(orderid: String, chstatus: String, subject: String, message:String,id: String, shippingdate: String, couriername: String, courierservice: String, trackid: String, notes: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["orderid":orderid, "chstatus": chstatus, "subject": subject, "message": message, "id": id, "shippingdate": shippingdate, "couriername": couriername, "courierservice": courierservice, "trackid": trackid, "notes": notes]
        CallParsingFunction().postDataCall(subURl: ORDER_STATUS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = MyOrderSalesModel.init(fromJson: response)
//            self.resultModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
        public func getTrackingDetails(orderid: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
            let parameter: [String: Any] = ["order_id":orderid]
            CallParsingFunction().postDataCall(subURl: GET_TRACKING_DETAILS_URL, params: parameter, onSuccess: { (response) in
                let rootClass = GetTrackingDetails.init(fromJson: response)
                //let shippingDate = rootClass.result.shippingdate
//                must changeable issue
//                let dummy = 1660134081
                
                if rootClass.status{
                    if rootClass.result.shippingdate != 0{
                        let shippingDate = rootClass.result.shippingdate
                       UserDefaultModule.shared.setDate(date: shippingDate!)
                    }
                }
            
                self.getTrackingDetails = rootClass
                success(rootClass.status ?? false)
            }) { (error) in
                failure(error?.localizedDescription ?? "")
            }
        }
    
//    public func getTrackingDetails(orderid: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
//        let parameter: [String: Any] = ["order_id":orderid]
//        CallParsingFunction().postDataCall(subURl: GET_TRACKING_DETAILS_URL, params: parameter, onSuccess: { (response) in
//            print(response)
//            let rootClass = GetTrackingDetails.init(fromJson: response)
//            self.getTrackingDetails = rootClass
//            success(rootClass.status ?? false)
//        }) { (error) in
//            failure(error?.localizedDescription ?? "")
//        }
//    }
    public func updateReview(user_id: String, seller_id: String, review_id: String, rating:String,review_title: String, review_des: String, order_id: String, review_type: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "seller_id": seller_id, "review_id": review_id, "rating": rating, "review_title": review_title, "review_des": review_des, "order_id": order_id, "review_type": review_type]
            CallParsingFunction().postDataCall(subURl: UPDATE_REVIEW_URL, params: parameter, onSuccess: { (response) in
                
                print(response)
                let rootClass = TOSModel.init(fromJson: response)
                self.statusResultModel = rootClass
                success(rootClass.status ?? false)
            }) { (error) in
                failure(error?.localizedDescription ?? "")
            }
        }
}
