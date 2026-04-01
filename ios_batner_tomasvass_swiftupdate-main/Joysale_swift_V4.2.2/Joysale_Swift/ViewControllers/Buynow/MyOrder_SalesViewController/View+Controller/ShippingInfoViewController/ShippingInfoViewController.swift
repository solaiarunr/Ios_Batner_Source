//
//  ShippingInfoViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 10/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
protocol DateDelegate {
    func DateAct(_ DateStr: Int)
}
class ShippingInfoViewController: UIViewController {

    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var viewType = ""
    var addressModelArray = [AddressModel]()
    var orderResultData: MyOrderResultModel?
    var orderVC: MyOrderSalesDetailViewController?
    let viewModel = MyOrderSalesViewModel()
    var DateDelegate: DateDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func configUI() {
        self.addressModelArray.append(AddressModel(title: "shipmentdate", desc: "", value: ""))
        self.addressModelArray.append(AddressModel(title: "couriername", desc: "", value: ""))
        self.addressModelArray.append(AddressModel(title: "shippingservice", desc: "", value: ""))
        self.addressModelArray.append(AddressModel(title: "trackingid", desc: "", value: ""))
        self.addressModelArray.append(AddressModel(title: "more_info", desc: "", value: ""))
        self.navigationController?.isNavigationBarHidden = false

        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.customNavigationBarView(title: "shippinginfo", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)

        self.tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressTableViewCell")
        self.saveButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .red
        self.saveButton.cornerMiniumRadius()
        self.saveButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "save")
        self.loadData()

    }
    func loadData() {
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.getTrackingDetails(orderid: "\(self.orderResultData?.orderid ?? 0)", onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            
            var trackingDetails: TrackingdetailModel?
            if success {
                trackingDetails = self.viewModel.getTrackingDetails?.result
                if (self.orderResultData?.trackingdetails.shippingdate ?? 0) != 0 {
                    trackingDetails?.shippingdate = UserDefaultModule.shared.getDate()
                    self.orderResultData?.trackingdetails.id = trackingDetails?.id
                }
            }
            else {
                if self.viewType == "edit" || self.viewType == "view"{
                    trackingDetails = self.orderResultData?.trackingdetails
                    if (self.orderResultData?.trackingdetails.shippingdate ?? 0) != 0 {
                    trackingDetails?.shippingdate = self.orderResultData?.trackingdetails.shippingdate
                    }
                 }
            }
            if trackingDetails != nil {
                self.addressModelArray[0].value = Utility.shared.timeStampWithDateFormat(timeStamp: "\(UserDefaultModule.shared.getDate() ?? 0)", dateFormat: "MMM dd, YYYY")
                self.addressModelArray[1].value = trackingDetails?.couriername ?? ""
                self.addressModelArray[2].value = trackingDetails?.courierservice ?? ""
                self.addressModelArray[3].value = trackingDetails?.trackingid ?? ""
                self.addressModelArray[4].value = trackingDetails?.notes ?? ""
            }
            if self.viewType == "view" {
                self.saveView.isHidden = true
            }
            self.tableView.reloadData()
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        self.viewDidLayoutSubviews()
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func saveButtonAct(_ sender: UIButton) {
        var isValid = false
        var message = ""
        if self.orderResultData?.trackingdetails != nil {
            if "\(self.orderResultData?.trackingdetails.shippingdate ?? 0)" == "0" {
                message = "\(getLanguage["Enter"] ?? "") \(getLanguage["shipmentdate"] ?? "")"
            }
            else if "\(self.orderResultData?.trackingdetails.couriername ?? "")" == "" {
                message = "\(getLanguage["Enter"] ?? "") \(getLanguage["couriername"] ?? "")"
            }
            else if "\(self.orderResultData?.trackingdetails.courierservice ?? "")" == "" {
                message = "\(getLanguage["Enter"] ?? "") \(getLanguage["shippingservice"] ?? "")"
            }
            else if (self.orderResultData?.trackingdetails.trackingid ?? "") == "" {
                message = "\(getLanguage["Enter"] ?? "") \(getLanguage["trackingid"] ?? "")"
            }
            else if (self.orderResultData?.trackingdetails.notes ?? "") == "" {
                message = "\(getLanguage["Enter"] ?? "") \(getLanguage["more_info"] ?? "")"
            }
            else {
                isValid = true
            }
        }
        else {
            message = "\(getLanguage["Enter"] ?? "") \(getLanguage["shipmentdate"] ?? "")"
        }

        if isValid {
            Utility.shared.startAnimation(viewController: self)
            viewModel.getOrderStatus(orderid: "\(self.orderResultData?.orderid ?? 0)", chstatus: "Track", subject: "", message: "", id: "\(self.orderResultData?.trackingdetails.id ?? 0)", shippingdate: "\(self.orderResultData?.trackingdetails.shippingdate ?? 0)", couriername: "\(self.orderResultData?.trackingdetails.couriername ?? "")", courierservice: "\(self.orderResultData?.trackingdetails.courierservice ?? "")", trackid: (self.orderResultData?.trackingdetails.trackingid ?? ""), notes: (self.orderResultData?.trackingdetails.notes ?? ""), onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                if success {
                    self.orderResultData?.status = "shipped"
                    self.orderVC?.orderResultData = self.orderResultData
                    DispatchQueue.main.async {
                        self.DateDelegate?.DateAct(self.orderResultData?.trackingdetails.shippingdate ?? 0)
                         self.navigationController?.popViewController(animated: true)
                    }
                }
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
        else {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
extension ShippingInfoViewController: UITableViewDelegate, UITableViewDataSource, addressDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.addressModelArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell") as! AddressTableViewCell
 
        if self.viewType == "view" {
            cell.addressTextField.isUserInteractionEnabled = false
            cell.addressTextView.isUserInteractionEnabled = false
         }
        cell.delegate = self
        cell.loadShippingData(index: indexPath, addressModel: self.addressModelArray[indexPath.section])
        return cell
    }
    func textFieldEndEditingAct(_ textField: UITextField) {
        let section = (textField.tag / 10)
        
        
        
            
        
        
        self.addressModelArray[section].value = textField.text!
        let dateformatter = DateFormatter() // 2-2
        dateformatter.dateStyle = .short // 2-3
        print("textfile \(textField.text) date \( self.addressModelArray[section].value) ")
//        let date = dateformatter.date(from: (self.addressModelArray[section].value ?? ""))

//        let dateStamp:TimeInterval = date?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
//        let dateSt:Int = Int(dateStamp)
        
      
        
        
        if self.orderResultData?.trackingdetails == nil {
            self.orderResultData?.trackingdetails = TrackingdetailModel()
        }
//        1611379763
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="dd-MMM-yyyy"
        let date = dfmatter.date(from: textField.text!)
        if date != nil{
        let dateStamp:TimeInterval = date!.timeIntervalSince1970
        let dateSt:Int = Int(dateStamp)
        self.orderResultData?.trackingdetails.shippingdate = dateSt
        }
        self.orderResultData?.trackingdetails.couriername = self.addressModelArray[1].value
        self.orderResultData?.trackingdetails.courierservice = self.addressModelArray[2].value
        self.orderResultData?.trackingdetails.trackingid = self.addressModelArray[3].value
    }
//    func textViewEditingAct(_ textView: UITextView) {
//        let section = (textView.tag / 10)
//        self.addressModelArray[section].value = textView.text!
//        self.orderResultData?.trackingdetails.notes = textView.text!
//    }
    func textViewEditingAct(_ textView: UITextView) {
        let section = textView.tag / 10
        print("section:", section)
        print("addressModelArray.count:", addressModelArray.count)
        print("text:", textView.text ?? "nil")
        print("orderResultData:", orderResultData as Any)
        print("trackingdetails:", orderResultData?.trackingdetails as Any)


        // ✅ Check index before accessing array
        if section < addressModelArray.count {
            addressModelArray[section].value = textView.text ?? ""
        } else {
            print("⚠️ Invalid section index: \(section)")
        }

        // ✅ Protect optional chain
        if let _ = orderResultData?.trackingdetails {
            orderResultData?.trackingdetails.notes = textView.text ?? ""
        } else {
            print("⚠️ trackingdetails is nil")
        }
    }

    func textFieldReturnAct(_ textField: UITextField) {
    }
}
