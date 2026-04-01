//
//  Utility.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 08/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

class Utility: NSObject {
    static let shared = Utility()
    var countryList: [[String: String]] = []
    var sectionsTitles: [String] = []
    var sections: [String: [[String: String]]] = [:]
    func configureLanguage(){
        if let  Path = Bundle.main.path(forResource: UserDefaultModule.shared.getAppLanguage().capitalized, ofType: "json"){
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: Path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                 if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
                    UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
                    UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
                }
                else {
                    UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
                    UIView.appearance().semanticContentAttribute = .forceLeftToRight
                    UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
                }
                
                UserDefaultModule.shared.setDefaultLanguage(LanguageDict: jsonResult as! Dictionary<String, String>)
            }catch{
                // handle error
                print(error)
            }
        }
    }
    
    func getCountryData(){
        if let fileUrl = Bundle.main.url(forResource: "CountryList", withExtension: "plist"), let data = try? Data(contentsOf: fileUrl) {
            if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String : String]] {
                let sorted = (result.sorted { item1, item2 -> Bool in
                    let name1 = item1["name"]
                    let name2 = item2["name"]
                    return name1! < name2!
                })
                countryList = sorted
                var dict: [String : [[String : String]]] = [:]
                
                for country in sorted {
                    let key = String(describing: country["name"]!.first!)
                    var arrKV = dict[key]
                    if arrKV == nil {
                        arrKV = []
                    }
                    arrKV?.append(country)
                    dict[key] = arrKV
                }
                sections = dict
                sectionsTitles = dict.keys.sorted().flatMap { $0 }
            }
        }
    }
    func setBadge(vc: UIViewController) {
        if let tabItems = vc.tabBarController?.tabBar.items as? [UITabBarItem] {
            // In this case, we want to modify the badge number of the third tab:
            let home = tabItems[0]
            let category = tabItems[1]
            let camera = tabItems[2]
            let chat = tabItems[3]
            let profile = tabItems[4]
            
            // Make sure to replace these lines with your actual data source for badge values
            let chatCount = ADMIN_VIEW_MODEL.getCountModel?.chatCount ?? 0
            let notificationCount = ADMIN_VIEW_MODEL.getCountModel?.notificationCount ?? 0
            
            print("Chat Count: \(chatCount)")
            print("Notification Count: \(notificationCount)")
            
            chat.badgeValue = chatCount > 0 ? "\(chatCount)" : nil
            profile.badgeValue = notificationCount > 0 ? "\(notificationCount)" : nil
            
            print("Setting Chat Badge Value: \(chat.badgeValue ?? "nil")")
            print("Setting Profile Badge Value: \(profile.badgeValue ?? "nil")")
            
            chat.badgeColor = chatCount > 0 ? UIColor.red : nil
            profile.badgeColor = notificationCount > 0 ? UIColor.yellow : nil
            print("Setting Chat Badge Color: \(chat.badgeColor == nil ? "Cleared" : "Red")")
            print("Setting Profile Badge Color: \(profile.badgeColor == nil ? "Cleared" : "Yellow")")
              }
        }
//    

    
    func startAnimation(viewController:UIViewController) {
        if !indicatorView.isAnimating {
            indicatorView.startAnimating()
            UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = false
            viewController.view.isUserInteractionEnabled =  false
        }
        else {
            indicatorView.stopAnimating()
            DispatchQueue.main.async {
                indicatorView.startAnimating()
                UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = false
                viewController.view.isUserInteractionEnabled =  false
                
            }
        }
    }
    //get random number
    func random() -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< 10 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        let userData = UserDefaultModule.shared.getUserData()
        return "\(userData?.user_id ?? "")\(randomString)"
    }
    //MARK: Convert string to double
    func convertToDouble(string:String) -> Double {
        let doubleValue = Double()
        if let distance = Double(string) {
            return distance
        } else {
            // Print("Not a valid string for conversion")
        }
        return doubleValue
    }
    
    //regisert for push services
    func registerPushServices()  {
        if UserDefaultModule().getUserData()?.user_id != "" {
            var DEVICE_MODE = ""
            #if DEBUG
             DEVICE_MODE = "0"
            #else
            DEVICE_MODE = "1"
           #endif
            let parameter: [String: Any] = ["deviceId": UIDevice.current.identifierForVendor!.uuidString, "userid": (UserDefaultModule().getUserData()?.user_id ?? ""), "devicetype": "0", "deviceToken": (UserDefaultModule.shared.getFCMToken() ?? ""), "devicemode": DEVICE_MODE, "lang_type": DEFAULT_LANGUAGE_CODE, "device_name": "iPhone", "device_model": UIDevice.current.localizedModel, "device_os": UIDevice.current.systemVersion, "voip_token": (UserDefaultModule.shared.getPushToken() ?? "")]
            
            CallParsingFunction().postDataCall(subURl: ADD_DEVICE_ID_URL, params: parameter, onSuccess: { (result) in
                print(result)
            }) { (error) in
                print(error?.localizedDescription ?? "")
            }
        }
    }
    func timeStampWithDateFormat(timeStamp: String, dateFormat: String) -> String {
        let timeStampValue = Double(timeStamp)
        //to convert in regular format
        let stampdate = Date(timeIntervalSince1970: timeStampValue!)
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = dateFormat
        let finalDate = dateFormatterGet.string(from: stampdate)
        return finalDate
    }
    func stopAnimation(viewController:UIViewController)
    {
        indicatorView.stopAnimating()
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.view.isUserInteractionEnabled = true
            viewController.view.isUserInteractionEnabled =  true
        }
    }
    
    // Get Filter
    func filterStringToDict(_ filter: String) -> UpdateFilterModel {
        if filter != "" {
            let data = Data(filter.utf8)
            do {
                // make sure this JSON is in the format we expect
                let decodedSentences = try JSONDecoder().decode(UpdateFilterModel.self, from: data)
                print(decodedSentences)
                return decodedSentences
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        return UpdateFilterModel(range: [FilterRangeModel](), dropdown: [FilterSubModel](), multilevel: [FilterSubModel]())
    }
    func filterDictToString(_ filterData: UpdateFilterModel) -> String {
        do {
            let jsonData = try JSONEncoder().encode(filterData)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            return jsonString
        } catch {
            print(error)
        }
        return ""
    }
    func filterRangeString(_ filterData: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: filterData, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            return jsonString
        } catch {
            print(error)
        }
        return ""
    }
    func dictToStringConversion(_ filterData: [[String: String]]) -> String {
        do {
            //            let jsonData = try JSONEncoder().encode(filterData)
            let jsonData = try JSONSerialization.data(withJSONObject: filterData, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            return jsonString
        } catch {
            print(error)
        }
        return ""
    }
    
    func getFilterFromCategory(category: String, subCategory: String, childCategory: String) -> [ProductFilterModel] {
        var categoryFilterArray = [ProductFilterModel]()
        if category != "", let category = ADMIN_VIEW_MODEL.productBeforeModel?.result.category.filter({$0.categoryId == category}).first {
            categoryFilterArray = category.filters
            if subCategory != "", let subCategory = category.subcategory.filter({$0.subId == subCategory}).first {
                categoryFilterArray = (categoryFilterArray + subCategory.filters)
                if childCategory != "",let childCategory = subCategory.childCategory.filter({$0.childId == childCategory}).first {
                    categoryFilterArray = (categoryFilterArray + childCategory.filters)
                }
            }
        }
        return categoryFilterArray
    }
    //MARK: Check string is empty
    func checkEmptyWithString(value:String) -> Bool {
        if  (value == "") || (value == "NULL") || (value == "(null)") || (value == "<null>") || (value == "Json Error") || (value == "0") || (value.isEmpty) ||  value.trimmingCharacters(in: .whitespaces).isEmpty || value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty  {
            return true
        }
        return false
    }
    
    func timerInAppLanguage(count: String) -> String{
        let countArr = count.map({String($0)})
        print(countArr)
        var countLan = ""
        let countLanArr = getLanguage["count"] as? NSArray ?? ["0","1","2","3","4","5","6","7","8","9","."]
        // let countLanArr = (Utility.shared.getLanguage()?.value(forKey: "count")) as? NSArray ?? ["0","1","2","3","4","5","6","7","8","9","."]
        for count in countArr {
            if count == ":" || count == "."{
                countLan = countLan + count
            }
            else {
                countLan = countLan + (countLanArr[Int(count) ?? 0] as? String ?? "")
            }
        }
        return countLan
    }
}

extension UINavigationController {
    func NavigationBarWithBackButtonAndTitle(title: String, fColor: String, fontName: UIFont?, imageName: String?, isLeft: Bool, vc: UIViewController, transparantView: Bool) {
        let barButton = UIButton(type: UIButton.ButtonType.custom)
        barButton.addTarget(self, action: #selector(barButtonAct(_:)), for: .touchUpInside)
        barButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        barButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            barButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        }
        else {
            barButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        }
        
        barButton.setImage(UIImage(named: imageName ?? "detail_back")?.imageFlippedForRightToLeftLayoutDirection(), for: .normal)
        barButton.contentMode = .scaleToFill
        barButton.tintColor = UIColor(named: fColor)
        vc.navigationItem.leftBarButtonItem = nil
        if title == "" {
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: barButton)
        }
        else {
            let barButton1 = UIButton(type: UIButton.ButtonType.custom)
            barButton1.titleLabel?.lineBreakMode = .byTruncatingTail
            barButton1.titleLabel?.font = fontName ?? UIFont.systemFont(ofSize: 14)
            barButton1.contentHorizontalAlignment = .leading
            barButton1.setTitleColor(UIColor(named: fColor) ?? .white, for: .normal)
            if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
                barButton1.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
            }
            else {
                barButton1.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
            }
            barButton1.setTitle(getLanguage[title] ?? title, for: .normal)
            barButton1.tag = 0
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            barButton1.widthAnchor.constraint(equalToConstant: (screenWidth - 185)).isActive = true
            barButton1.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            vc.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: barButton), UIBarButtonItem(customView: barButton1)]
        }
        self.clearLineInNavigationBar()
        //        vc.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
    }
    
    func clearLineInNavigationBar() {
        let navigationBar = self.navigationBar
        navigationBar.barTintColor = UIColor(named: "AppThemeColorNew") ?? .white
        //        if #available(iOS 13.0, *) {
        //            let navigationBarAppearence = UINavigationBarAppearance()
        //            navigationBarAppearence.shadowColor = .clear
        //            navigationBar.scrollEdgeAppearance = navigationBarAppearence
        //
        //        } else {
        //
        //            // Fallback on earlier versions
        //        }
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    func customRightBarButtonView(title: String, fColor: String, fontName: UIFont?, imageName: String?, isLeft: Bool, vc: UIViewController, transparantView: Bool) {
        let barButton = UIButton(type: UIButton.ButtonType.custom)
        barButton.addTarget(self, action: #selector(barButtonAct(_:)), for: .touchUpInside)
        barButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            barButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        }
        else {
            barButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        }
        
        if (imageName != "" && imageName != nil){
            let image = isLeft == true ? UIImage(named: imageName!) : UIImage(named: imageName!)
            barButton.setImage(image, for: .normal)
            barButton.tintColor = UIColor(named: fColor)
        }
        else {
            barButton.titleLabel?.font = fontName ?? UIFont.systemFont(ofSize: 14)
            barButton.contentHorizontalAlignment = .trailing
            barButton.setTitleColor(UIColor(named: fColor) ?? .white, for: .normal)
            barButton.setTitle(getLanguage[title] ?? "", for: .normal)
        }
        // Mentioned Right Or Left Button
        if isLeft {
            barButton.tag = 0
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: barButton)
        }
        else {
            barButton.tag = 1
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
        }
        self.clearLineInNavigationBar()
    }
    
    @objc func barButtonAct(_ sender: UIButton) {
        let imageDataDict:[String: Int] = ["isLeft": sender.tag]
        NotificationCenter.default.post(name: Notification.Name("BarButtonAction"), object: nil, userInfo: imageDataDict)
    }
    func customNavigationBarView(title: String, fColor: String, fontName: UIFont?, vc: UIViewController) {
        vc.title = getLanguage[title] ?? title
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fontName ?? UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor(named: fColor) ?? .black]
      
        
    }
    //    open override var preferredStatusBarStyle: UIStatusBarStyle {
    //       return topViewController?.preferredStatusBarStyle ?? .default
    //    }
    var previousViewController: UIViewController? {
        return viewControllers.count > 1 ? viewControllers[viewControllers.count - 2] : nil
    }
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
extension Date {
    /// Returns the amount of years from another date
    var age: Int { Calendar.current.dateComponents([.year], from: self, to: Date()).year! }
    
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
//    func offset(from date: Date) -> String {
//        if years(from: date)   > 0 { return "\(getLanguage["ago"] ?? "")\(years(from: date)) \(getLanguage["Year ago"] ?? "")"   }
//        if months(from: date)  > 0 { return "\(getLanguage["ago"] ?? "") \(months(from: date)) \(getLanguage["month ago"] ?? "")"  }
//        //        if weeks(from: date)   > 0 { return "\(getLanguage["ago"] ?? "") \(weeks(from: date))w"   }
//        if days(from: date)    > 0 { return "\(getLanguage["ago"] ?? "") \(days(from: date)) \(getLanguage["daysago"] ?? "")"    }
//        if hours(from: date)   > 0 { return "\(getLanguage["ago"] ?? "") \(hours(from: date)) \(getLanguage["hoursago"] ?? "")"   }
//        if minutes(from: date) > 0 { return "\(getLanguage["ago"] ?? "") \(minutes(from: date)) \(getLanguage["aminuteago"] ?? "")" }
//        if seconds(from: date) > 0 { return "\(getLanguage["ago"] ?? "") \(seconds(from: date)) \(getLanguage["justnow"] ?? "")" }
//        return "\(getLanguage["ago"] ?? "") 1 \(getLanguage["justnow"] ?? "")"
//    }
    func offset(from date: Date) -> String {
        if years(from: date) > 0 { return "\(years(from: date)) \(getLanguage["Year ago"] ?? "year ago")" }
        if months(from: date) > 0 { return "\(months(from: date)) \(getLanguage["month ago"] ?? "month ago")" }
        // if weeks(from: date) > 0 { return "\(weeks(from: date))w" }
        if days(from: date) > 0 { return "\(days(from: date)) \(getLanguage["daysago"] ?? "days ago")" }
        if hours(from: date) > 0 { return "\(hours(from: date)) \(getLanguage["hoursago"] ?? "hours ago")" }
        if minutes(from: date) > 0 { return "\(minutes(from: date)) \(getLanguage["aminuteago"] ?? "minutes ago")" }
        if seconds(from: date) > 0 { return "\(seconds(from: date)) \(getLanguage["justnow"] ?? "just now")" }
        
        return "1 \(getLanguage["justnow"] ?? "just now")"
    }

    func offsetFrom(date: Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self)
        
        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + " " + seconds
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
    
extension Date {
    func timeAgoDisplay() -> String {
        if #available(iOS 13.0, *) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: self, relativeTo: Date())
        } else {
            // Fallback on earlier versions
            let calendar = Calendar.current
            let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
            let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
            let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            
            if minuteAgo < self {
                let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
                return "\(diff) sec ago"
            } else if hourAgo < self {
                let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
                return "\(diff) min ago"
            } else if dayAgo < self {
                let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
                return "\(diff) hrs ago"
            } else if weekAgo < self {
                let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
                return "\(diff) days ago"
            }
            let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
            return "\(diff) weeks ago"
        }
    }
}
extension CGFloat {
    func SecondsFromTimer() -> String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        let timeVal = String(format: "%02i:%02i", minutes, seconds)
        let dateString = Utility.shared.timerInAppLanguage(count: timeVal)
        return dateString
    }
}
extension Utility{
    
    //MARK: JoyShorts
    
    
    //MARK: Network rechability
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
        
    }
}
