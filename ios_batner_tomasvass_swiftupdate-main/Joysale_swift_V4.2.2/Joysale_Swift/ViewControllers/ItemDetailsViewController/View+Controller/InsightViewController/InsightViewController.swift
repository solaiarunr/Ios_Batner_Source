//
//  InsightViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 21/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import Charts


class InsightViewController: UIViewController {

    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var setView: UIView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = ItemDetailsViewModel()
    var itemData: ItemModel?
    var selectedTag = 0
    var viewModelArray = [ViewsByYearModel]()
    var isfromtype = ""
    var itemDatavideo : StoryListModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)

        self.loadData()
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        self.tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: getLanguage["days"] ?? "days", style: .default, handler: { (UIAlertAction) in
                    self.selectedTag = 0
                    self.setChart()
                }))
                alert.addAction(UIAlertAction(title: getLanguage["month"] ?? "month", style: .default, handler: { (UIAlertAction) in
                    self.selectedTag = 1
                    self.setChart()
                }))
                alert.addAction(UIAlertAction(title: getLanguage["year"] ?? "year", style: .default, handler: { (UIAlertAction) in
                    self.selectedTag = 2
                    self.setChart()
                }))
                alert.addAction(UIAlertAction(title: getLanguage["cancel"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func loadData() {
        Utility.shared.startAnimation(viewController: self)
        let itemId = (isfromtype == "story") ? (self.itemDatavideo?.id ?? 0) : (self.itemData?.id ?? 0)
        self.viewModel.getInsightsData(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", product_id: "\(itemId ?? 0)", onSuccess: { (success) in
            self.setChart()
            Utility.shared.stopAnimation(viewController: self)
            self.tableView.reloadData()
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    func configUI() {
        self.navigationController?.customNavigationBarView(title: getLanguage["insights"] ?? "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), vc: self)
        self.navigationController?.NavigationBarWithBackButtonAndTitle(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: true)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "calender_white", isLeft: false, vc: self, transparantView: true)
        self.tableView.register(UINib(nibName: "InsightsTableViewCell", bundle: nil), forCellReuseIdentifier: "InsightsTableViewCell")
        self.tableView.estimatedSectionFooterHeight = 50
        self.tableView.sectionFooterHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        chartView.noDataFont = UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        chartView.noDataTextColor = UIColor(named: "whitecolor") ?? .white
        chartView.noDataText = getLanguage["no_chart_data_available"] ?? ""
        self.setLabel.config(color: (UIColor(named: "whitecolor") ?? .white), font: (UIFont(name: APP_FONT_REGULAR, size: 15) ?? UIFont.boldSystemFont(ofSize: 15)), align: .left, text: (getLanguage["views"] ?? ""))
        self.setView.backgroundColor = .clear
        self.setView.setViewBorder(color: UIColor(named: "whitecolor") ?? .white)
        self.chartView.isUserInteractionEnabled = false
        self.chartView.rightAxis.enabled = true
        self.chartView.leftAxis.enabled = true
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: APP_FONT_REGULAR, size: 10) ?? UIFont.systemFont(ofSize: 10)
        xAxis.labelTextColor = UIColor(named: "whitecolor") ?? .white
        xAxis.axisLineColor = UIColor(named: "clearcolor") ?? .white

        xAxis.gridColor = UIColor.clear
        self.chartView.rightAxis.labelTextColor = UIColor.clear
        self.chartView.leftAxis.labelTextColor = UIColor.clear
        self.chartView.rightAxis.gridColor = UIColor.clear
        self.chartView.leftAxis.gridColor = UIColor.clear
        self.chartView.leftAxis.axisLineColor = UIColor.clear
        self.chartView.rightAxis.axisLineColor = UIColor.clear
    }
    func setChart() {
        var dataEntries: [ChartDataEntry] = []
        var dateArray = [String]()
        var minAxis: Double = 0
        var maxAxis: Double = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var dateFormat = "MMM dd"
        if selectedTag == 0 {
            self.viewModelArray = self.viewModel.insightsModel?.viewsByWeek ?? [ViewsByYearModel]()
            dateFormat = "MMM dd"
        }
        else if selectedTag == 1 {
            self.viewModelArray = self.viewModel.insightsModel?.viewsByMonth ?? [ViewsByYearModel]()
            dateFormat = "MMM"
        }
        else {
            self.viewModelArray = self.viewModel.insightsModel?.viewsByYear ?? [ViewsByYearModel]()
            dateFormat = "yyyy"
        }
        let formatter1 = DateFormatter()
        for (i, value) in self.viewModelArray.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(value.views) ?? 0)
            if minAxis > (Double(value.views) ?? 0) {
                minAxis = (Double(value.views) ?? 0)
            }
            if maxAxis < (Double(value.views) ?? 0) {
                maxAxis = (Double(value.views) ?? 0)
            }
            dataEntries.append(dataEntry)
            if let date = formatter.date(from: (value.duration ?? "")) {
                formatter1.dateFormat = dateFormat
                let dateAsString = formatter1.string(from: date)
                dateArray.append(dateAsString)
            }
        }
//        chartView.leftAxis.axisMinimum = 0
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateArray)

        let set1 = LineChartDataSet(entries: dataEntries, label: "")
        self.chartView.legend.enabled = false

        set1.circleRadius = 6
        set1.circleHoleColor = .clear
        set1.setCircleColor(UIColor(named: "whitecolor") ?? .white)
        let data = LineChartData(dataSet: set1)
        data.setValueTextColor(UIColor(named: "whitecolor") ?? .white)
        data.setValueFont(UIFont(name: APP_FONT_REGULAR, size: 10) ?? UIFont.boldSystemFont(ofSize: 10))
        set1.lineWidth = 2
        set1.setColor(UIColor(named: "whitecolor") ?? .white)
        set1.mode = .horizontalBezier
        set1.lineCapType = CGLineCap(rawValue: 5)!
        chartView.data = data
    }
}
extension InsightViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.insightsModel?.reachTips == nil {
            return 0
        }
        if section == 3 {
            if (ADMIN_VIEW_MODEL.adminModel?.result.exchange ?? "") == "disable" {
                return 3
            }
            return 4
        }
        else if section == 4 {
            return (self.viewModel.insightsModel?.mostVisitedcity.count ?? 0)
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InsightsTableViewCell") as! InsightsTableViewCell
        cell.popularButton.addTarget(self, action: #selector(self.promoteAct(_:)), for: .touchUpInside)
        if isfromtype == "story"{
            if let insight = self.viewModel.insightsModel, let itemDetails = self.itemDatavideo {
                cell.loadDatavideo(insight, itemDetails: itemDetails, index: indexPath)
            }
        }else{
            if let insight = self.viewModel.insightsModel, let itemDetails = self.itemData {
                cell.loadData(insight, itemDetails: itemDetails, index: indexPath)
            }
        }
        return cell
    }
    @objc func promoteAct(_ sender: UIButton) {
        debugPrint("PromoteBtnACT")
        if isfromtype == "story"{
            if  let itemDetails = self.itemDatavideo {
                if itemDetails.promotionType == "Normal" && PROMOTION_FLAG && itemDetails.itemStatus == "onsale"{
                    let pageObj = CreatePromotionViewController()
                    pageObj.itemID = "\(itemDetails.id ?? 0)"
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
            }else{
                debugPrint("ItemData Not Found")
            }
        }else{
            if  let itemDetails = self.itemData {
                if itemDetails.promotionType == "Normal" && PROMOTION_FLAG && itemDetails.itemStatus == "onsale"{
                    let pageObj = CreatePromotionViewController()
                    pageObj.itemID = "\(itemDetails.id ?? 0)"
                    self.navigationController?.pushViewController(pageObj, animated: true)
                }
            }else{
                debugPrint("ItemData Not Found")
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let pageObj = ReachMoreViewController()
            pageObj.reachMore = self.viewModel.insightsModel?.reachTips ?? ""
            self.navigationController?.pushViewController(pageObj, animated: true)
        }
    }
}
