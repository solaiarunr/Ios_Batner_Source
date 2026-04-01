//
//  InsightsModel.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 30/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import Foundation
import SwiftyJSON


class InsightsModel{

    var comments : String!
    var engagementStatus : String!
    var exchangeRequest : String!
    var likes : String!
    var mostVisitedcity : [MostVisitedcityModel]!
    var offerRequest : String!
    var popularityLevel : String!
    var reachTips : String!
    var status : Bool!
    var totalViews : String!
    var totalVisitedcity : String!
    var uniqueViews : String!
    var viewsByMonth : [ViewsByYearModel]!
    var viewsByWeek : [ViewsByYearModel]!
    var viewsByYear : [ViewsByYearModel]!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        comments = json["comments"].stringValue
        engagementStatus = json["engagement_status"].stringValue
        exchangeRequest = json["exchange_request"].stringValue
        likes = json["likes"].stringValue
        mostVisitedcity = [MostVisitedcityModel]()
        let mostVisitedcityArray = json["most_visitedcity"].arrayValue
        for mostVisitedcityJson in mostVisitedcityArray{
            let value = MostVisitedcityModel(fromJson: mostVisitedcityJson)
            mostVisitedcity.append(value)
        }
        offerRequest = json["offer_request"].stringValue
        popularityLevel = json["popularity_level"].stringValue
        reachTips = json["reach_tips"].stringValue
        status = json["status"].boolValue
        totalViews = json["total_views"].stringValue
        totalVisitedcity = json["total_visitedcity"].stringValue
        uniqueViews = json["unique_views"].stringValue
        viewsByMonth = [ViewsByYearModel]()
        let viewsByMonthArray = json["views_by_month"].arrayValue
        for viewsByMonthJson in viewsByMonthArray{
            let value = ViewsByYearModel(fromJson: viewsByMonthJson)
            viewsByMonth.append(value)
        }
        viewsByWeek = [ViewsByYearModel]()
        let viewsByWeekArray = json["views_by_week"].arrayValue
        for viewsByWeekJson in viewsByWeekArray{
            let value = ViewsByYearModel(fromJson: viewsByWeekJson)
            viewsByWeek.append(value)
        }
        viewsByYear = [ViewsByYearModel]()
        let viewsByYearArray = json["views_by_year"].arrayValue
        for viewsByYearJson in viewsByYearArray{
            let value = ViewsByYearModel(fromJson: viewsByYearJson)
            viewsByYear.append(value)
        }
    }
}
class ViewsByYearModel {

    var duration : String!
    var views : String!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        duration = json["duration"].stringValue
        views = json["views"].stringValue
    }
}
class MostVisitedcityModel{

    var cityCount : String!
    var cityName : String!
    var percentage : String!
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        cityCount = json["city_count"].stringValue
        cityName = json["city_name"].stringValue
        percentage = json["percentage"].stringValue
    }
}
