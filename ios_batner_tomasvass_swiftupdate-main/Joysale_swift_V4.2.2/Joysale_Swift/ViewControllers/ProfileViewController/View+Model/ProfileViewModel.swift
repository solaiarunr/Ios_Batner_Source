//
//  ProfileViewModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit    //fornewaddon
import Foundation

class ProfileViewModel {
    
    var profileModel: ProfileModel?
    var followerModel: FollowerModel?
    var followerListModel: FollowerListModel?
    var followingListModel: FollowerListModel?
    var reviewModel: ReviewModel?
    var tosModel: TOSModel?
    var stripeModel: StripeModel?
    var otherprofileModel: OtherProfileModel?
    
    let delegate = UIApplication.shared.delegate as! AppDelegate  //fornewaddon

    public func getProfileData(user_id: String,user_name: String,profile_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "user_name":user_name,"profile_id":profile_id]
    
        CallParsingFunction().postDataCall(subURl: GET_PROFILE_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ProfileModel.init(fromJson: response)
            self.profileModel = rootClass
            if rootClass.status {
                if "\(self.profileModel?.result.userId ?? 0)" == (UserDefaultModule.shared.getUserData()?.user_id ?? "") {
                    STRIPE_DETAILS = self.profileModel?.result.stripeDetails
                    let loginModel = LoginModel(email: (self.profileModel?.result.email ?? ""), fullName: (self.profileModel?.result.fullName ?? ""), photo: (self.profileModel?.result.userImg ?? ""), rating: (self.profileModel?.result.rating ?? ""), ratingUserCount: (self.profileModel?.result.ratingUserCount ?? ""), userId: "\(self.profileModel?.result.userId ?? 0)", userName: (self.profileModel?.result.userName ?? ""))
                    //token: (UserDefaultModule.shared.getAccessToken() ?? "")
                    if rootClass.status {
                        UserDefaultModule.shared.setUserData(loginModel)
                        if let location = self.profileModel?.result.location{
                            UserDefaultModule.shared.setLocation(location)
                        }
                    }
                }
            }
            success(self.profileModel?.status ?? false)
            
            
            /*
            //fornewaddon
            let auth = response["status_code"].stringValue
            let auth1 = response["status"].stringValue
            print("forchecking:\(auth)")
            if (auth == "401" && auth1 == "false"){
                ADMIN_VIEW_MODEL.pushSignout()
                let fcmToken = UserDefaultModule.shared.getFCMToken()
                let voipToken = UserDefaultModule.shared.getPushToken()

                let appFirst = UserDefaultModule.shared.getAppFirst()
                let appLanguage = UserDefaultModule.shared.getAppLanguage()
                let domain = Bundle.main.bundleIdentifier
                 UserDefaults.standard.removePersistentDomain(forName: domain ?? "")
                UserDefaults.standard.synchronize()
                UserDefaultModule.shared.setAppFirst(appFirst)
                UserDefaultModule.shared.setFCMToken(fcm_token: fcmToken ?? "")
                UserDefaultModule().setAppLanguage(language: appLanguage)
                UserDefaults.standard.set(APP_RTC_URL, forKey: "web_rtc_web")
                UserDefaultModule().setPushToken(fcm_token: voipToken ?? "")
                self.delegate.initVC(initialView: InitialViewController())
            }
            else{
                
            }
            */
            
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getFollowedUserId(user_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        
        let parameter: [String: Any] = ["user_id":user_id]
    
        CallParsingFunction().postDataCall(subURl: GET_FOLLOWER_ID_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = FollowerModel.init(fromJson: response)
            self.followerModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func Otherusernamechecking(user_id: String,search_user:String, onSuccess success: @escaping (String) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id,"search_user":search_user]
        CallParsingFunction().postDataCall(subURl: SearchUser_Api, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = OtherProfileModel.init(fromJson: response)
            self.otherprofileModel = rootClass
            success(rootClass.status ?? "false")
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func followUser(user_id: String,follow_id: String,type: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        var followURL = UNFOLLOW_USER_URL
        if type == "follow" {
            followURL = FOLLOW_USER_URL
        }
        let parameter: [String: Any] = ["user_id":user_id, "follow_id": follow_id]
    
        CallParsingFunction().postDataCall(subURl: followURL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = FollowerModel.init(fromJson: response)
//            self.followerModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getFollwerData(user_id: String,offset: String,profile_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "offset": offset, "limit": "20","profile_id":profile_id]
        
        CallParsingFunction().postDataCall(subURl: FOLLOWER_DETAILS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = FollowerListModel.init(fromJson: response)
            self.followerListModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getFollowingData(user_id: String,offset: String,profile_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "offset": offset, "limit": "20","profile_id":profile_id]
        
        CallParsingFunction().postDataCall(subURl: FOLLOWING_DETAILS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = FollowerListModel.init(fromJson: response)
            self.followingListModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func getReviewDeta(user_id: String,offset: String,profile_id: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "offset": offset, "limit": "20","profile_id": profile_id]
        
        CallParsingFunction().postDataCall(subURl: GET_REVIEW_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = ReviewModel.init(fromJson: response)
            self.reviewModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    
    public func changePassword(user_id: String,old_password: String, new_password: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "old_password": old_password, "new_password": new_password]
        
        CallParsingFunction().postDataCall(subURl: CHANGE_PASSWORD_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = TOSModel.init(fromJson: response)
            self.tosModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func stripeDetails(user_id: String,stripe_privatekey: String, stripe_publickey: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        let parameter: [String: Any] = ["user_id":user_id, "stripe_privatekey": stripe_privatekey, "stripe_publickey": stripe_publickey]
        CallParsingFunction().postDataCall(subURl: ADD_STRIPE_DETAILS_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = StripeModel.init(fromJson: response)
            self.stripeModel = rootClass
            success(rootClass.status ?? false)
        }) { (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
    public func editProfileData(user_id: String,email: String, full_name: String, first_name: String, last_name: String,mobile_no: String, isFromFB: Int, show_mobile_no: Bool, user_img: String,fb_profileurl: String, facebook_id: String, fb_phone: String, country_name: String, city_name: String, state_name: String, onSuccess success: @escaping (Bool) -> Void, onFailure failure: @escaping (String) -> Void) {
        var userImage = user_img
        if let url = URL(string: userImage) {
            userImage = url.lastPathComponent
        }
        var parameter: [String: Any] = ["user_id":user_id]
        if isFromFB == 1 {
            parameter = ["user_id": user_id, "fb_email": email, "fb_firstname": full_name, "fb_lastname": last_name, "fb_phone": fb_phone, "fb_profileurl": fb_profileurl, "full_name": full_name, "user_img": userImage, "facebook_id": facebook_id, "country_name": country_name, "city_name": city_name, "state_name": state_name]
        }
        else if isFromFB == 2 {
            parameter["mobile_no"] = mobile_no
            parameter["show_mobile_no"] = "\(show_mobile_no)"
        }
        else {
            parameter = ["user_id":user_id, "full_name": full_name, "user_img": userImage, "facebook_id": facebook_id, "country_name": country_name, "city_name": city_name, "state_name": state_name, "show_mobile_no": "\(show_mobile_no)"]
        }

        CallParsingFunction().postDataCall(subURl: EDIT_PROFILE_URL, params: parameter, onSuccess: { (response) in
            print(response)
            let rootClass = TOSModel.init(fromJson: response)
            self.tosModel = rootClass
            success(rootClass.status ?? false)
        }){ (error) in
            failure(error?.localizedDescription ?? "")
        }
    }
}
