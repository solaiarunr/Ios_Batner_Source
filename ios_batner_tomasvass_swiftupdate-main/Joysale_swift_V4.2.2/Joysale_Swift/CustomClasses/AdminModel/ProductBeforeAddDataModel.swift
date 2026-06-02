//
//  ProductBeforeAddDataModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 18/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProductBeforeAddDataModel {

    var result : ProductResultModel!
    var status : Bool!
   

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = ProductResultModel(fromJson: resultJson)
        }
        status = json["status"].boolValue
      
    }
}

class ProductResultModel {
    var stripeverifystatus : String!
    var category : [ProductCategoryModel]!
    var country : [ProductCountryModel]!
    var currency : [ProductCurrencyModel]!
    var distance : String!
    var givingAway : String!
    var productCondition : [ProductConditionModel]!
    var searchType : String!
    var shipDeliveryTime : [ShipDeliveryTimeModel]!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        stripeverifystatus = json["stripeverifystatus"].stringValue
        category = [ProductCategoryModel]()
        let categoryArray = json["category"].arrayValue
        for categoryJson in categoryArray{
            let value = ProductCategoryModel(fromJson: categoryJson)
            category.append(value)
        }
        country = [ProductCountryModel]()
        let countryArray = json["country"].arrayValue
        for countryJson in countryArray{
            let value = ProductCountryModel(fromJson: countryJson)
            country.append(value)
        }
        currency = [ProductCurrencyModel]()
        let currencyArray = json["currency"].arrayValue
        for currencyJson in currencyArray{
            let value = ProductCurrencyModel(fromJson: currencyJson)
            currency.append(value)
        }
        distance = json["distance"].stringValue
        givingAway = json["giving_away"].stringValue
        productCondition = [ProductConditionModel]()
        let productConditionArray = json["product_condition"].arrayValue
        for productConditionJson in productConditionArray{
            let value = ProductConditionModel(fromJson: productConditionJson)
            productCondition.append(value)
        }
        searchType = json["search_type"].stringValue
        shipDeliveryTime = [ShipDeliveryTimeModel]()
        let shipDeliveryTimeArray = json["shipDeliveryTime"].arrayValue
        for shipDeliveryTimeJson in shipDeliveryTimeArray{
            let value = ShipDeliveryTimeModel(fromJson: shipDeliveryTimeJson)
            shipDeliveryTime.append(value)
        }
    }
}
class ShipDeliveryTimeModel {

    var id : String!
    var time : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].stringValue
        time = json["Time"].stringValue
    }
}
class ProductConditionModel: Codable {

    var id : Int!
    var name : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].intValue
        name = json["name"].stringValue
    }
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
class ProductCurrencyModel {

    var id : Int!
    var symbol : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].intValue
        symbol = json["symbol"].stringValue
    }
}
class ProductCountryModel {

    var countryCode : String!
    var countryId : Int!
    var countryName : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        countryCode = json["country_code"].stringValue
        countryId = json["country_id"].intValue
        countryName = json["country_name"].stringValue
    }
}
class ProductCategoryModel {

    var categoryId : String!
    var categoryImg : String!
    var categoryName : String!
    var exchangeBuy : String!
    var filters : [ProductFilterModel]!
    var instantBuy : String!
    var makeOffer : String!
    var productCondition : String!
    var subcategory : [ProductSubcategoryModel]!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        categoryId = json["category_id"].stringValue
        categoryImg = json["category_img"].stringValue
        categoryName = json["category_name"].stringValue
        exchangeBuy = (ADMIN_VIEW_MODEL.adminModel?.result.exchange ?? "") == "disable" ? "disable" : json["exchange_buy"].stringValue
        filters = [ProductFilterModel]()
        let filtersArray = json["filters"].arrayValue
        for filtersJson in filtersArray{
            let value = ProductFilterModel(fromJson: filtersJson, catType: "category")
            filters.append(value)
        }
        instantBuy = (ADMIN_VIEW_MODEL.adminModel?.result.buynow ?? "") == "disable" ? "disable" : json["instant_buy"].stringValue
        makeOffer = json["make_offer"].stringValue
        productCondition = json["product_condition"].stringValue
        subcategory = [ProductSubcategoryModel]()
        let subcategoryArray = json["subcategory"].arrayValue
        for subcategoryJson in subcategoryArray{
            let value = ProductSubcategoryModel(fromJson: subcategoryJson)
            subcategory.append(value)
        }
    }
}
class ProductSubcategoryModel {

    var childCategory : [ProductChildCategoryModel]!
    var filters : [ProductFilterModel]!
    var subId : String!
    var subName : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        childCategory = [ProductChildCategoryModel]()
        let childCategoryArray = json["child_category"].arrayValue
        for childCategoryJson in childCategoryArray{
            let value = ProductChildCategoryModel(fromJson: childCategoryJson)
            childCategory.append(value)
        }
        filters = [ProductFilterModel]()
        let filtersArray = json["filters"].arrayValue
        for filtersJson in filtersArray{
            let value = ProductFilterModel(fromJson: filtersJson, catType: "sub")
            filters.append(value)
        }
        subId = json["sub_id"].stringValue
        subName = json["sub_name"].stringValue
    }
}
class ProductChildCategoryModel {

    var childId : String!
    var childName : String!
    var filters : [ProductFilterModel]!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        childId = json["child_id"].stringValue
        childName = json["child_name"].stringValue
        filters = [ProductFilterModel]()
        let filtersArray = json["filters"].arrayValue
        for filtersJson in filtersArray{
            let value = ProductFilterModel(fromJson: filtersJson, catType: "child")
            filters.append(value)
        }
    }
}

class ProductFilterModel {

    var id : String!
    var label : String!
    var type : String!
    var minValue : String!
    var maxValue : String!
    var values : [ProductValueModel]!
    var categoryType : String!

    init(fromJson json: JSON!, catType: String){
        if json.isEmpty{
            return
        }
        categoryType = catType
        id = json["id"].stringValue
        label = json["label"].stringValue
        type = json["type"].stringValue
        minValue = json["min_value"].stringValue
        maxValue = json["max_value"].stringValue
        values = [ProductValueModel]()
        let valuesArray = json["values"].arrayValue
        for valuesJson in valuesArray{
            let value = ProductValueModel(fromJson: valuesJson)
            values.append(value)
        }
    }
}
class ProductValueModel {

    var parentId : String!
    var parentLabel : String!
    var parentValues : [ProductParentValueModel]!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        parentId = json["parent_id"].string ?? json["id"].stringValue
        parentLabel = json["parent_label"].string ?? json["name"].stringValue
        parentValues = [ProductParentValueModel]()
        let parentValuesArray = json["parent_values"].arrayValue
        for parentValuesJson in parentValuesArray{
            let value = ProductParentValueModel(fromJson: parentValuesJson)
            parentValues.append(value)
        }
    }
}
class ProductParentValueModel {

    var childId : String!
    var childName : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        childId = json["child_id"].stringValue
        childName = json["child_name"].stringValue
    }
}
