//
//  AuthenticationViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 08/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation


class AuthenticationViewModel {
    
    var loginModel: LoginModel?
    var signupModel: SignupModel?
    
    public func login(email: String,password: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["email":email, "password":password]
    
        CallParsingFunction().postDataCall(subURl: LOGIN_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = LoginModel.init(fromJson: response)
            if rootClass.status {
                UserDefaultModule.shared.setUserData(rootClass)
//                UserDefaultModule.shared.saveLoginModel(rootClass)
                
                UserDefaultModule.shared.setAccessToken(token1: rootClass.token)
                DispatchQueue.main.async {
                    ADMIN_VIEW_MODEL.loadNotification(onSuccess: { (success) in
                    }) { (failure) in
                    }
                }
            }
            self.loginModel = rootClass
            success(self.loginModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func MobileLogin(phone: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["phone":phone]
    
        CallParsingFunction().postDataCall(subURl: MOBILE_LOGIN_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = LoginModel.init(fromJson: response)
            if rootClass.status {
                UserDefaultModule.shared.setUserData(rootClass)
                UserDefaultModule.shared.setAccessToken(token1: rootClass.token)
                DispatchQueue.main.async {
                    ADMIN_VIEW_MODEL.loadNotification(onSuccess: { (success) in
                    }) { (failure) in
                    }
                }
            }
            self.loginModel = rootClass
            success(self.loginModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func SocialLogin(type: String,id: String, first_name: String, last_name: String, email: String, image_url: String, country_name: String, state_name: String, city_name: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["type":type, "id":id, "first_name": first_name, "last_name": last_name, "email": email, "image_url": image_url, "country_name": country_name, "state_name": state_name, "city_name": city_name]
        
        CallParsingFunction().postDataCall(subURl: SOCIAL_LOGIN_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = LoginModel.init(fromJson: response)
            if rootClass.status {
                UserDefaultModule.shared.setUserData(rootClass)
                UserDefaultModule.shared.setAccessToken(token1: rootClass.token)
                DispatchQueue.main.async {
                    ADMIN_VIEW_MODEL.loadNotification(onSuccess: { (success) in
                    }) { (failure) in
                    }
                }
            }
            self.loginModel = rootClass
            success(self.loginModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func signUp(email: String, user_name:String, full_name: String ,password: String,country_name: String,state_name: String,city_name: String, is_location: Bool, phone: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        var parameter: [String: Any] = ["email":email, "full_name": full_name, "password":password, "user_name": user_name]
        
       // parameter["phone"] = phone
        
        if is_location {
            parameter["country_name"] = country_name
            parameter["state_name"] = state_name
            parameter["city_name"] = city_name
        }
        CallParsingFunction().postDataCall(subURl: SIGNUP_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = SignupModel.init(fromJson: response)
            self.signupModel = rootClass
            success(self.signupModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func ForgotEmail(email: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["email":email]
    
        CallParsingFunction().postDataCall(subURl: FORGOT_PASSWORD_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = LoginModel.init(fromJson: response)
            self.loginModel = rootClass
            success(self.loginModel?.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}

