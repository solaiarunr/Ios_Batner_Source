//
//  ProductsVideoParsing.swift
//  Joyshorts_Swift
//
//  Created by APPLE on 22/11/22.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit
import SystemConfiguration

public typealias Params = [String: Any]
public var isAlertPresent = false
class ProductsVideoParsing {
    public func postVideo(image:UIImage?, videoData: Data, fileName: String,editflag: Bool, loading: @escaping (Bool, Progress) -> Void, onSuccess success: @escaping (JSON) -> Void, onFailure failure: @escaping (_ error: Error?) -> Void) {
        let fixedImage = image?.fixedOrientation()
        var imageData = fixedImage!.jpegData(compressionQuality: 0.5)!
        let BaseUrl = URL(string: "\(UserDefaultModule.shared.getstreamurl() ?? "https://batner.com:5003/")api/\(UPLOAD_API)")
        print("URL\(BaseUrl)")
//        let headers: HTTPHeaders = [
//            "Content-type": "multipart/form-data"
//        ]
        if Utility().isConnectedToNetwork() {
            let response  = AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData, withName: "thumb" , fileName: "file.jpg", mimeType: "image/jpeg")
                if editflag {
 
                }else{
                    // 🔍 slow
                    let fileExt = (fileName as NSString).pathExtension.lowercased()
                    print("📂 Video file name: \(fileName)")
                    print("📂 Video extension: \(fileExt)")
                    print("📏 Video data size: \(videoData.count / 1024) KB")
                    multipartFormData.append(videoData, withName:"stream" ,fileName:fileName , mimeType: "video/mp4")
                }
                print("mutlipartFormData: \(multipartFormData)")
            }, to: BaseUrl!, usingThreshold: UInt64.init(), method: .post, headers: nil)
                .uploadProgress(closure: { (progress) in
                    print("Progress: \(progress)")
                    loading(false, progress)
                })
                .response { response in
                    if let data = response.data{
                        print("Data:: \(data)")
                        let jsonResponse = try? JSON.init(data: data)
                        print("RESPONSE : \(jsonResponse)")
                        if jsonResponse != nil {
                            success(jsonResponse!)
                        }
                        else {
                            failure(response.error)
                        }
                        //handle the response however you like
                    }
                    else {
                        failure(nil)
                        print("Error123")
                    }
                }
        }
        else {
            self.showAlert()
        }
    }
    

    
    public func getDetails(subURl: String, onSuccess success: @escaping (JSON) -> Void, onFailure failure: @escaping (_ error: Error?) -> Void)
    {
    
        let PRODUCT_SITE_URL = (UserDefaultModule.shared.getbaseurlonly()?.appending("api/")) ?? "https://batner.com/api/"
        
        let BaseUrl = URL(string: PRODUCT_SITE_URL+subURl)
        print("BASE URL + subURL : \(PRODUCT_SITE_URL+subURl)")
        
        if Utility().isConnectedToNetwork() {
            AF.request(BaseUrl!, method: .post, parameters: nil, headers: nil).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("JSON: \(json) \n \((PRODUCT_SITE_URL+subURl))")
                    if json["status"].stringValue == "error" {
                        
                    }else if json["status"].stringValue == "401"{
                       
                    }
                    else {
                        success(json)
                    }
                case .failure(let error):
                    print(error)
                    failure(error)
                }
            }
        }
        else {
            self.showAlert()
        }
        
    }
    
    public func postDetails(subURl: String,params: Params, onSuccess success: @escaping (JSON) -> Void, onFailure failure: @escaping (_ error: Error?) -> Void)
    {
        var PRODUCT_SITE_URL = (UserDefaultModule.shared.getbaseurlonly()?.appending("api/")) ?? "https://batner.com/api/"

        var parameters = params
        parameters.merge(REST_AUTH){(_, new) in new}
        let BaseUrl = URL(string: PRODUCT_SITE_URL+subURl)
        print("headerforauth:\(UserDefaultModule.shared.getAccessToken() ?? "")")
        print("BASE URL + subURL : \(PRODUCT_SITE_URL+subURl)")
        print("Param : \(parameters)")
        
    
        if Utility().isConnectedToNetwork() {
            AF.request(BaseUrl!, method: .post, parameters: parameters, headers: nil).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("JSON: \(json) \n \((PRODUCT_SITE_URL+subURl))")
                    if json["status"].stringValue == "error" {
                        
                    }else if json["status"].stringValue == "401"{
                       
                    }
                    else {
                        success(json)
                    }
                case .failure(let error):
                    print(error)
                    failure(error)
                }
            }
        }
        else {
            self.showAlert()
        }
        
    }
    
    func showAlert() {
        DispatchQueue.main.async { [] in
            if !Utility().isConnectedToNetwork() {
                if !isAlertPresent {
                    let alert = UIAlertController(title: nil, message: "Could not connect to Batner. Please check your network connection and try again.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
