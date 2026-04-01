//
//  CameraViewModel.swift
//  ProductsVideo
//
//  Created by MAC BOOK on 11/11/22.
//

import Foundation
import SwiftyJSON

//class CameraViewModel {
//    
//    var productmodel: ProductModel?
//    
//    public func postVideo(user_id: String,products: String,duration: String,type: String, stream: String, thumb: String, onSuccess success: @escaping (JSON) -> Void, onFailure failure: @escaping (String) -> Void) {
//        let param: [String: Any] = ["user_id": UserDefaultModule.shared.getUserData()?.user_id ?? "", "products": products, "devicetype": "1", "duration": duration, "type": type, "thumb": thumb, "stream": stream]
//        ProductsVideoParsing().postDetails(subURl: POST_VIDEO_API, params: param) { (response) in
//            print(response)
//            success(response)
//        } onFailure: { (error) in
//            failure(error?.localizedDescription ?? "")
//        }
//
//    }
//    public func getItems(user_id: String,offset: String,limit: String,search: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
//
////        ProductsVideoParsing().getDetails(subURl: "\(PRODUCT_LIST_API)/\(user_id)/\(offset)/\(limit)/\(search)", onSuccess: { (response) in
////            print(response)
////            let rootClass = ProductModel.init(fromJson: response)
////            self.productmodel = rootClass
////            success(self.productmodel?.status ?? false)
////        }) { (error) in
////            failure(error?.localizedDescription ?? "")
////        }
//    }
//    
//    
//}
