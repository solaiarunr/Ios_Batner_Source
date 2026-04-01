//
//  MyOrderSalesModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 06/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON

class MyOrderSalesModel {

    var result : [MyOrderResultModel]!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        result = [MyOrderResultModel]()
        let resultArray = json["result"].arrayValue
        for resultJson in resultArray{
            let value = MyOrderResultModel(fromJson: resultJson)
            result.append(value)
        }
        status = json["status"].boolValue
    }
}
class MyOrderResultModel {

    var cancel : Bool!
    var claim : Bool!
    var createdDate : Int!
    var deliverydate : Int!
    var formattedPrice : String!
    var invoice : String!
    var orderid : Int!
    var orderitems : OrderItemModel!
    var paymentType : String!
    var price : String!
    var rating : Int!
    var reviewDes : String!
    var reviewId : Int!
    var reviewTitle : String!
    var saledate : Int!
    var shippingaddress : AddressListResultModel!
    var status : String!
    var trackingdetails : TrackingdetailModel!
    var transactionId : String!
    var sellerStatus : String!
    
    var userstatus : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        claim = json["claim"].boolValue
        cancel = json["cancel"].boolValue

        createdDate = json["created_date"].intValue
        deliverydate = json["deliverydate"].intValue
        formattedPrice = json["formatted_price"].stringValue
        invoice = json["invoice"].stringValue
        orderid = json["orderid"].intValue
        let orderitemsJson = json["orderitems"]
        if !orderitemsJson.isEmpty{
            orderitems = OrderItemModel(fromJson: orderitemsJson)
        }
        paymentType = json["payment_type"].stringValue
        price = json["price"].stringValue
        rating = json["rating"].intValue
        reviewDes = json["review_des"].stringValue
        reviewId = json["review_id"].intValue
        reviewTitle = json["review_title"].stringValue
        saledate = json["saledate"].intValue
        let shippingaddressJson = json["shippingaddress"]
        if !shippingaddressJson.isEmpty{
            shippingaddress = AddressListResultModel(fromJson: shippingaddressJson)
        }
        status = json["status"].stringValue
        let trackingdetailsJson = json["trackingdetails"]
        if !trackingdetailsJson.isEmpty{
            trackingdetails = TrackingdetailModel(fromJson: trackingdetailsJson)
        }
        transactionId = json["transaction_id"].stringValue
        sellerStatus = json["seller_status"].stringValue
        userstatus = json["userstatus"].stringValue
    }
}
class GetTrackingDetails{

    var result : TrackingdetailModel!
    var status : Bool!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let resultJson = json["result"]
        if !resultJson.isEmpty{
            result = TrackingdetailModel(fromJson: resultJson)
        }
        status = json["status"].boolValue
    }
}
class TrackingdetailModel {

    var couriername : String!
    var courierservice : String!
    var id : Int!
    var notes : String!
    var shippingdate : Int!
    var trackingid : String!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        couriername = json["couriername"].stringValue
        courierservice = json["courierservice"].stringValue
        id = json["id"].intValue
        notes = json["notes"].stringValue
        shippingdate = json["shippingdate"].intValue
        trackingid = json["trackingid"].stringValue
    }
    init(couriername : String = "", courierservice : String = "", id : Int = 0, notes : String = "", shippingdate : Int = 0, trackingid : String = "") {
    }
}

class OrderItemModel {

    var buyerEmail : String!
    var buyerId : Int!
    var buyerImg : String!
    var buyerName : String!
    var buyerUsername : String!
    var cSymbol : String!
    var currencyMode : String!
    var currencyPosition : String!
    var formattedPrice : String!
    var formattedShippingCost : String!
    var formattedTotal : String!
    var formattedUnitprice : String!
    var itemid : Int!
    var itemname : String!
    var orderImage : String!
    var price : String!
    var quantity : Int!
    var shippingCost : String!
    var size : String!
    var total : Int!
    var unitprice : String!
   

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        buyerEmail = json["buyer_email"].string ?? json["seller_email"].stringValue
        buyerId = json["buyer_id"].int ?? json["seller_id"].int
        buyerImg = json["buyer_img"].string ?? json["seller_img"].stringValue
        buyerName = json["buyer_name"].string ?? json["seller_name"].stringValue
        buyerUsername = json["buyer_username"].string ?? json["seller_username"].stringValue
        cSymbol = json["cSymbol"].stringValue
        currencyMode = json["currency_mode"].stringValue
        currencyPosition = json["currency_position"].stringValue
        formattedPrice = json["formatted_price"].stringValue
        formattedShippingCost = json["formatted_shipping_cost"].stringValue
        formattedTotal = json["formatted_total"].stringValue
        formattedUnitprice = json["formatted_unitprice"].stringValue
        itemid = json["itemid"].intValue
        itemname = json["itemname"].stringValue.html2String
        orderImage = json["orderImage"].stringValue
        price = json["price"].stringValue
        quantity = json["quantity"].intValue
        shippingCost = json["shipping_cost"].stringValue
        size = json["size"].stringValue
        total = json["total"].intValue
        unitprice = json["unitprice"].stringValue
        
    }
}
