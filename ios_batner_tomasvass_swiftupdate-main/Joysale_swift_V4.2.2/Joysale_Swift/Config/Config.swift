//
//  Config.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 06/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import UIKit
let APP_NAME = "Batner"
let BUNDLE_NAME = "com.app.batner"
//clientfixes
let API_USER_NAME = "batner"
//let API_USER_NAME = "epinoy"
let API_PASSWORD = "0RWK9XM8"

//let GOOGLE_API_KEY = "AIzaSyA4RbguQyJaXQRSXvJlvt417CZOBO7YNF0"
let GOOGLE_API_KEY = "AIzaSyBjMozsh5Ikf4SB9tGAbKsM0_C9b8S0vQw"
let GOOGLE_CLIENT_KEY = "138993231704-ojcr1v5ok5dk31q4uac4481fq996hcja.apps.googleusercontent.com"
let GOOGLE_URL = "https://maps.google.com/maps/api/geocode/json?sensor=false"

/*
 var BASE_URL = "https://appservices.hitasoft.in/batner/"
 var chatURL = "https://appservices.hitasoft.in:2087"
 */


var BASE_URL = "https://batner.com/"
var chatURL = "https://batner.com:2087"
var APP_RTC_URL = "http://152.44.43.72:8080"




//API SERVICE
var SITE_URL = BASE_URL+"api/"
let UPLOAD_IMAGE_URL = (UserDefaultModule.shared.getbaseurlonly()?.appending("api/uploadimage")) ?? "https://batner.com/api/uploadimage"

let CHAT_IMAGE_URL = (UserDefaultModule.shared.getbaseurlonly()?.appending("images/message/")) ?? "https://batner.com/images/message/"
let UPLOAD_AUDIO_URL = (UserDefaultModule.shared.getbaseurlonly()?.appending("api/uploadaudio")) ?? "https://batner.com/api/uploadaudio"
let ADD_IMAGE_URL = (UserDefaultModule.shared.getbaseurlonly()?.appending("media/item")) ?? "https://batner.com/media/item"
let USER_URL = (UserDefaultModule.shared.getbaseurlonly()?.appending("media/user")) ?? "https://batner.com/media/user"
let INVITE_URL = "https://apps.apple.com/us/app/batner/id1355651901"
var REST_AUTH: [String : String] = ["api_username": "batner", "api_password": "0RWK9XM8"]
let MAP_URL = "https://maps.google.com/maps/api/staticmap?center="

var DEVICE_MODEs = ""


let DYNAMIC_LINK = "https://batner.page.link" // create it from firebase dynamic link section
let IOS_BUNDLE_ID = "com.app.batner"
let ANDROID_PACKAGE_NAME = "com.app.batner" // android app package name
let APP_STORE_ID = "1355651901" // get it from itunes connect once create the app


//let DEVICE_MODE = "0"
//let DEVICE_MODE = "1"
// Authentication URLS
let TOS_URL = "tos"
let LOGIN_URL = "login"
let SOCIAL_LOGIN_URL = "sociallogin"
let SIGNUP_URL = "signup"
let FORGOT_PASSWORD_URL = "forgetpassword"
let MOBILE_LOGIN_URL = "phonelogin"
// Profile URLS
let GET_PROFILE_URL = "profile"
let CHANGE_PASSWORD_URL = "changepassword"
let ADD_STRIPE_DETAILS_URL = "addstripedetails"
let GET_FOLLOWER_ID_URL = "Getfollowerid"
let FOLLOW_USER_URL = "Followuser"
let UNFOLLOW_USER_URL = "Unfollowuser"
let EDIT_PROFILE_URL = "Editprofile"
let FOLLOWER_DETAILS_URL = "Followersdetails"
let FOLLOWING_DETAILS_URL = "Followingdetails"
let GET_REVIEW_URL = "getreview"
let GET_ITEMS_URL = "getItems"
let ADMIN_DATAS_URL = "admindatas"
let GET_CATEGORY_URL = "getcategory"
let BRAINTREE_CLIENT_TOKEN_URL = "braintreeClientToken"
let GET_COUNT_DETAILS_URL = "getcountdetails"
// ItemDetails URLS
let GET_USER_PRODUCTS_URL = "getuserproducts"
let ITEM_LIKED_URL = "Itemlike"
let SOLD_ITEM_URL = "solditem"
let DELETE_PRODUCT_URL = "deleteproduct"
let REPORT_ITEM_URL = "reportitem"
let GET_CHAT_ID_URL = "getchatid"
let SEND_OFFER_REQ_URL = "Sendofferreq"
let GET_SHIPPING_ADDRESS_URL = "getShippingAddress"
let SET_DEFAULT_SHIPPING_URL = "setdefaultshipping"
let REMOVE_SHIPPING_URL = "removeshipping"
let BUYNOW_PAYMENT_URL = "buynowPayment"
let GET_INSIGHTS_URL = "getinsights"
let GET_COMMENTS_URL = "getcomments"
let DELETE_COMMENT_URL = "deletecomment"
let POST_COMMENT_URL = "postcomment"
let UPDATE_VIEW_URL = "updateview"
let ADD_SHIPPING_URL = "addshipping"
let CREATE_EXCHANGE_URL = "createexchange"
// Chat URLS
let MESSAGE_URL = "messages"
let GET_CHAT_URL = "getchat"
let OFFER_STATUS_URL = "offerstatus"
let SEARCH_BY_ITEM_URL = "searchbyitem"
let SEND_CHAT_URL = "sendchat"
let SAFETY_TIPS_URL = "SafetyTips"
let CHAT_ACTION_URL = "chataction"
// Exchange URLS
let MY_EXCHANGE_URL = "myexchanges"
let EXCHANGE_STATUS_URL = "exchangestatus"
let HELP_PAGE_URL = "helppage"
// My Orders & Sales URL
let MY_ORDERS_URL = "myorders"
let MY_SALES_URL = "mysales"
let ORDER_STATUS_URL = "orderstatus"
let UPDATE_REVIEW_URL = "updatereview"
let GET_TRACKING_DETAILS_URL = "gettrackdetails"
let BALLENCE_SHEET_URL = "balancesheet"
let NOTIFICATION_URL = "notification"
let GET_AD_WITH_US_URL = "getadwithus"
let GET_HISTORY_URL = "getadhistory"
let BANNER_AVAILABILITY_URL = "banneravailability"
let ADD_BANNER_URL = "addbanner"
// PROMOTION URL
let MY_PROMOTIONS_URL = "mypromotions"
let GET_PROMOTION_URL = "getpromotion"
let PROCESSING_PAYMENT_URL = "processingPayment"
let CHECK_PROMOTION_URL = "Checkpromotion"
// ADDPRODUCT
let PRODUCT_BEFORE_ADD_URL = "productbeforeadd"
let ADD_PRODUCT_URL = "addproduct"
// PUSH NOTIFICATION
let ADD_DEVICE_ID_URL = "adddeviceid"
let RESET_BADGE_URL = "resetbadge"
let PUSH_SIGNOUT_URL = "pushsignout"
// Socket
let MESSAGE_TYPEING_ON = "messageTyping"
let MESSAGE_ON = "message"
let EX_MESSAGE_TYPEING_ON = "exmessageTyping"
let EX_MESSAGE_ON = "exmessage"


let JOIN_EMIT = "join"
let MESSAGE_EMIT = "message"
let MESSAGE_TYPING_EMIT = "messageTyping"

let EXCHANGE_JOIN_EMIT = "exchangejoin"
let EX_MESSAGE_EMIT = "exmessage"
let EX_MESSAGE_TYPING_EMIT = "exmessageTyping"

// Addons
let POST_DETAILS_URL = "postdetails"
let Subcription_PAYMENT = "subscriptionPayment"
let subscribe_URL = "mysubscription"
let get_subcribe_plan = "getsubscription"

let SOLD_TO = "soldto"
let REVIEW_DETAILS = "reviewdetails"
// CALL URLS
let MAKE_CALL_URL = "makecall"
let CHECK_ROOM_URL = "checkroom"
let MISSED_CALL_URL = "missedcall"
let END_CALL_URL = "endcall"

let AWS_UPLOAD_URL = "awsupload" // Server side timeout error when upload 5 images. so use this api to save image name

let DELETE_ACCOUNT = "deleteaccount"

//MARK: Needs
var VIDEO_MAXIMUM_SIZE = 0
var VIDEO_MAXIMUM_DURATION = 60
var VIDEO_MINIMUM_DURATION = 3
var VIDEO_BASE_URL = ""
var VIDEO_UPLOAD_URL = ""
let VIDEO_THUMB_PATH = "/media/stream_thumbs/"


//MARK: Woovly Clone API's
let GET_HOME_HEADERS = "gethomeheaders"
let GET_SUB_HEADERS = "getinnerheaders"
var PRODUCT_SITE_URL = SITE_URL
let PRODUCT_LIST_API = "hts_myproducts"
let APP_DEFAULT_API = "hts_appdefaults"
let USER_INFO_API = "hts_getuserinfo"
let POST_VIDEO_API = "hts_postvideo"
let HTS_PRODUCT_VIDEOS = "hts_productvideos"
let HTS_VIDEOS = "hts_videos"
let UPLOAD_API = "hts_uploadstream"
let VIDEO_PATH = "/media/streams/"
let HTS_MY_VIDEOS = "hts_myvideos"


//customwork

let Country_list_Api = "countrylist"
let selectedcountry_Api = "selectedcountry"
let SearchUser_Api = "searchuser"
let VIDEOLINK = "share_videolink"

let AdStatusApi = "checkadstatus"
let Getadpremiumlist = "getadpremiumlist"
let Activeadplan_Api = "activeadplan"

let PremiumStatusApi = "checkpremiumstatus"
let PremiumlistApi = "getpremiumlist"
let Activepremiumplan = "activepremiumplan"


