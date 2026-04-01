//
//  FilterModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 15/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation


class FilterDataModel: Codable {
    var type: String!
    var Price: String!
    var Search_key: String!
    var Category_id: String!
    var subcategory_id: String!
    var user_id: String!
    var item_id: String!
    var seller_id: String!
    var sorting_id: String!
    var posted_within: String!
    var distance: String!
    var isDistanceSlider: Bool!
    var distance_type: String!
    var filters: String!
    var product_condition: String!
    var child_category_id: String!
    var location: String!
    var city: String!
    var state: String!
    var country: String!
    var lat: String!
    var long: String!
    init(type: String = "", Price: String = "0-5000", Search_key: String = "", Category_id: String = "", subcategory_id: String = "", user_id: String = "", item_id: String = "", seller_id: String = "", sorting_id: String = "1", posted_within: String = "", distance: String = "", distance_type: String = "", filters: String = "", product_condition: String = "", child_category_id: String = "", location: String = "", lat: String = "", long: String = "", city: String = "", state: String = "", country: String = "", isDistanceSlider: Bool = false) {
        self.type = type
        self.Price = Price
        self.Search_key = Search_key
        self.Category_id = Category_id
        self.subcategory_id = subcategory_id
        self.user_id = user_id
        self.item_id = item_id
        self.seller_id = seller_id
        self.sorting_id = sorting_id
        self.posted_within = posted_within
        self.distance = distance
        self.distance_type = distance_type
        self.filters = filters
        self.product_condition = product_condition
        self.child_category_id = child_category_id
        self.location = location
        self.lat = lat
        self.long = long
        self.city = location
        self.state = lat
        self.country = long
        self.isDistanceSlider = isDistanceSlider
    }
    static func == (lhs: FilterDataModel, rhs: FilterDataModel) -> Bool {
        return lhs.type == rhs.type && lhs.Price == rhs.Price && lhs.Search_key == rhs.Search_key && lhs.Category_id == rhs.Category_id && lhs.subcategory_id == rhs.subcategory_id && lhs.child_category_id == rhs.child_category_id && lhs.sorting_id == rhs.sorting_id && lhs.posted_within == rhs.posted_within && lhs.distance == rhs.distance && lhs.product_condition == rhs.product_condition
    }
    func toDictionary() -> [String:String]
    {
        var dictionary = [String:String]()
        
        if type != "" {
            dictionary["type"] = type
        }
        if Price == "0-0" {
            dictionary["Price"] = getLanguage["giving_away"] ?? "giving_away"
        }
        else if Price != "0-5000" {
            dictionary["Price"] = Price
            let priceArr = Price.components(separatedBy: "-")
            if priceArr.count > 1 {
                if priceArr[1] == "5000" {
                    dictionary["Price"] = "\(priceArr[0])-5000+"
                }
            }
        }
        if Search_key != "" {
            dictionary["Search_key"] = Search_key
        }
        if Category_id != "" {
            let category = ADMIN_VIEW_MODEL.productBeforeModel?.result.category.filter({$0.categoryId == Category_id}).first
            if subcategory_id != "" && subcategory_id != "viewall"{
                let subCategory = category?.subcategory.filter({$0.subId == subcategory_id}).first
                if child_category_id != "" && child_category_id != "viewall"{
                    let childCategory = subCategory?.childCategory.filter({$0.childId == child_category_id}).first
                    dictionary["Category"] = childCategory?.childName
                }
                else {
                    dictionary["Category"] = subCategory?.subName ?? ""
                }
            }
            else {
                dictionary["Category"] = category?.categoryName
            }
        }
        if sorting_id != "" && sorting_id != "1" {
            dictionary["sorting_id"] = getLanguage[sorting_id] ?? sorting_id
        }
        if posted_within != "" {
            dictionary["posted_within"] = getLanguage[posted_within] ?? ""
        }
        if distance != "" && self.isDistanceSlider{
            dictionary["distance"] = "\(getLanguage["within"] ?? "within") \(Int(distance ?? "") ?? 0) \(distance_type ?? "")"
        }
        if product_condition != "" {
            let productCodition = ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.filter({$0.id == Int(product_condition)}).first?.name ?? ""
            dictionary["product_condition"] = productCodition 
        }
//        if location != "" && location != "worldwide"{
//            dictionary["location"] = location
//        }
        return dictionary
    }
    func getSortID() -> String {
        if sorting_id == "popular" {
            return "2"
        }
        else if sorting_id == "hightolow" {
            return "3"
        }
        else if sorting_id == "lowtohigh" {
            return "4"
        }
        else if sorting_id == "urgent" {
            return "5"
        }
        else {
            return "1"
        }
    }
}
class CategoryDetailsModel {
    var Category_id: String!
    var subcategory_id: String!
    var child_category_id: String!
    init(Category_id: String = "", subcategory_id: String = "",  child_category_id: String = "") {
        self.Category_id = Category_id
        self.subcategory_id = subcategory_id
        self.child_category_id = child_category_id
    }
}

class UpdateFilterModel: Codable {
    var range = [FilterRangeModel]()
    var dropdown = [FilterSubModel]()
    var multilevel = [FilterSubModel]()
    init(range: [FilterRangeModel] = [FilterRangeModel](), dropdown: [FilterSubModel], multilevel: [FilterSubModel]) {
        self.range = range
        self.dropdown = dropdown
        self.multilevel = multilevel
    }
}
class FilterSubModel: Codable {
    var id: String!
    var catType: String!
    init(catType: String, id: String) {
        self.id = id
        self.catType = catType
    }
}
class FilterRangeModel: Codable {
    var max_value: String!
    var id: String!
    var min_value: String!
    init(max_value: String, id: String, min_value: String) {
        self.max_value = max_value
        self.id = id
        self.min_value = min_value
    }
    func toDictionary() -> [String:String]
    {
        var dictionary = [String:String]()
        if max_value != "" {
            dictionary["max_value"] = max_value
        }
        if min_value != "" {
            dictionary["min_value"] = min_value
        }
        if id != "" {
            dictionary["id"] = id
        }
        return dictionary
    }
}


class AddEditViewModel {
    
    var item_id: String!
    var item_name: String!
    var item_des: String!
    var price: String!
    var size: String!
    var category: String!
    var subcategory: String!
    var chat_to_buy: String!
    var exchange_to_buy: Bool!
    var currency: String!
    var lat: String!
    var lon: String!
    var address: String!
    var shipping_time: String!
    var remove_img: String!
    var state: String!
    var product_img: String!
    var shipping_detail: String!
    var item_condition: String!
    var make_offer: Int!
    var instant_buy: Bool!
    var paypal_id: String!
    var shipping_cost: String!
    var country_id: String!
    var giving_away: Bool!
    var sold: Bool!
    var filters: String!
    var youtube_link: String!
    var child_category: String!
    init(item_id: String = "0", item_name: String = "", item_des: String = "", price: String = "", size: String = "0", category: String = "", subcategory: String = "", chat_to_buy: String = "0", exchange_to_buy: Bool = false, currency: String = "", lat: String = "", lon: String = "", address: String = "", shipping_time: String = "", remove_img: String = "", product_img: String = "", shipping_detail: String = "", item_condition: String = "", make_offer: Int = 0, instant_buy: Bool = false, paypal_id: String = "", shipping_cost: String = "", country_id: String = "", giving_away: Bool = false, sold: Bool = false, filters: String = "", youtube_link: String = "", child_category: String = "", state:String = "") {
        self.item_id = item_id
        self.item_name = item_name
        self.item_des = item_des
        self.price = price
        self.size = size
        self.category = category
        self.subcategory = subcategory
        self.chat_to_buy = chat_to_buy
        self.exchange_to_buy = exchange_to_buy
        self.currency = currency
        self.lat = lat
        self.lon = lon
        self.address = address
        self.shipping_time = shipping_time
        self.remove_img = remove_img
        self.product_img = product_img
        self.shipping_detail = shipping_detail
        self.item_condition = item_condition
        self.make_offer = make_offer
        self.instant_buy = instant_buy
        self.paypal_id = paypal_id
        self.shipping_cost = shipping_cost
        self.country_id = country_id
        self.giving_away = giving_away
        self.sold = sold
        self.filters = filters
        self.youtube_link = youtube_link
        self.child_category = child_category
        self.state = state
    }
}
