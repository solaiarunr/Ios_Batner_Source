//
//  AddressViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 25/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import DropDown


class AddressViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var isEditView = false
    var viewType = 0 // viewType == 1 -> View From ItemDetailsViewController, viewType == 2 -> From BuynowViewController
    
    var addressModelArray = [AddressModel]()
    
    var viewModel = AddressViewModel()
    var itemDetails: ItemModel?
    var itemDetailsvideo: StoryListModel?
    var countryArray = [ProductCountryModel]()
    var addressResult: AddressListResultModel?
    let dropDown = DropDown()
    var offerPayment = false
    var offerPrice = ""
    var returnTag: Int?
    var isfromtype = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        tableView.tableHeaderView = .init(frame: .init(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        // Do any additional setup after loading the view.
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
        self.addressModelArray.append(AddressModel(title: "nickname", desc: "Enter your name", value: ""))
        self.addressModelArray.append(AddressModel(title: "addressname", desc: "Enter your name", value: ""))
        self.addressModelArray.append(AddressModel(title: "addressone", desc: "Enter your address", value: ""))
        self.addressModelArray.append(AddressModel(title: "addresstwo", desc: "Enter your address", value: ""))
        self.addressModelArray.append(AddressModel(title: "city", desc: "Enter your city", value: ""))
        self.addressModelArray.append(AddressModel(title: "state", desc: "Enter your state", value: ""))
        self.addressModelArray.append(AddressModel(title: "country", desc: "Enter your country", value: ""))
        self.addressModelArray.append(AddressModel(title: "zipcode", desc: "Enter your zipcode", value: ""))
        self.addressModelArray.append(AddressModel(title: "mobileno", desc: "Enter your phone number", value: ""))

        self.navigationController?.isNavigationBarHidden = false
        var titleString = ""
        if isEditView {
            titleString = "editaddress"
            self.addressModelArray[0].value = self.addressResult?.nickname
            self.addressModelArray[1].value = self.addressResult?.name
            self.addressModelArray[2].value = self.addressResult?.address1
            self.addressModelArray[3].value = self.addressResult?.address2
            self.addressModelArray[4].value = self.addressResult?.city
            self.addressModelArray[5].value = self.addressResult?.state
            self.addressModelArray[6].value = self.addressResult?.country
            self.addressModelArray[7].value = self.addressResult?.zipcode
            self.addressModelArray[8].value = self.addressResult?.phone
        }
        else {
            titleString = "addaddress"
        }
        self.navigationController?.customNavigationBarView(title: titleString, fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressTableViewCell")
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.continueButton.backgroundColor = UIColor(named: "AppThemeColorNew") ?? .white
        self.continueButton.cornerMiniumRadius()
        self.continueButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "continue")
            
        self.loadData()
    }
    func loadData() {
        Utility.shared.startAnimation(viewController: self)
        ADMIN_VIEW_MODEL.productBeforeAddData(onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            if (ADMIN_VIEW_MODEL.productBeforeModel?.status ?? false) {
                self.countryArray = ADMIN_VIEW_MODEL.productBeforeModel?.result.country ?? [ProductCountryModel]()
                if self.isfromtype == "story"{
                    if let country = ADMIN_VIEW_MODEL.productBeforeModel?.result.country.filter({$0.countryId == Int(self.itemDetailsvideo?.countryId ?? "")}), self.viewType == 1 {
                        self.addressModelArray.filter({$0.title == "country"}).first?.value = (country.first?.countryName
                            ?? "")
                    }

                }else{
                    if let country = ADMIN_VIEW_MODEL.productBeforeModel?.result.country.filter({$0.countryId == Int(self.itemDetails?.countryId ?? "")}), self.viewType == 1 {
                        self.addressModelArray.filter({$0.title == "country"}).first?.value = (country.first?.countryName
                            ?? "")
                    }

                    
                }
                self.tableView.reloadData()
            }
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
    
    @IBAction func continueButtonAct(_ sender: UIButton) {
        
        var isValid = true
         var message = ""
        

         let userName = self.addressModelArray.filter({$0.title == "nickname"}).first?.value ?? ""
         let firstName = self.addressModelArray.filter({$0.title == "addressname"}).first?.value ?? ""
         let addressOne = self.addressModelArray.filter({$0.title == "addressone"}).first?.value ?? ""
        let addresstwo = self.addressModelArray.filter({$0.title == "addresstwo"}).first?.value ?? ""

         let city = self.addressModelArray.filter({$0.title == "city"}).first?.value ?? ""
         let state = self.addressModelArray.filter({$0.title == "state"}).first?.value ?? ""
        
        var country = self.addressModelArray.filter({$0.title == "country"}).first?.value ?? ""
        if country == "" {
            country = UserDefaultModule.shared.getcountryname() ?? ""
        }
       // let country = CURRENT_LOCATION
         let zipCode = self.addressModelArray.filter({$0.title == "zipcode"}).first?.value ?? ""
         let mobileNo = self.addressModelArray.filter({$0.title == "mobileno"}).first?.value ?? ""
         
         message = (userName == "") ? "please enter nick name" : ""
         message = (userName.count < 3 && message == "") ? "please enter nick name atleast 3 characters" : message
         message = (firstName == "" && message == "") ? "please enter name" : message
         message = (firstName.count < 3 && message == "") ? "please enter name atleast 3 characters" : message
         message = (addressOne == "" && message == "") ? "please enter address 1" : message
         message = (city == "" && message == "") ? "please enter city" : message
         message = (state == "" && message == "") ? "please enter state" : message
         message = (country == "" && message == "") ? "please select country" : message
         message = (zipCode == "" && message == "") ? "please enter zipcode" : message
         message = (mobileNo == "" && message == "") ? "please enter phone number" : message
        isValid = message == "" ? true : false
        let currencyID = self.countryArray.filter({$0.countryName == country}).first?.countryId ?? 0

        if isValid {
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.addShippingAddress(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), full_name: firstName, nick_name: userName, country_id: "\(currencyID)", country_name: country, state: state, address1: addressOne, address2: addresstwo, city: city, zip_code: zipCode, phone_no: mobileNo, defaultAddress: "\(self.addressResult?.defaultshipping ?? 0)", shipping_id: "\(self.addressResult?.shippingid ?? 0)", onSuccess: { (success) in
                var alertTitle = ""
                if success {
                    alertTitle = getLanguage["Address_added_successfully"] ?? ""
                }
                else {
                    alertTitle = (self.viewModel.resultModel?.message ?? "")
                }
                let alert = UIAlertController(title: getLanguage["alert"], message: alertTitle, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .default, handler: { (UIAlertAction) in
                    if success {
                        if self.viewType == 1 {
                            self.setAddressAsDefault("\(self.viewModel.resultModel?.result.shippingid ?? 0)")
                        }
                        else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else {
                    }
                }))
                self.present(alert, animated: true, completion: nil)
     
                Utility.shared.stopAnimation(viewController: self)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
        else {
            let alert = UIAlertController(title: getLanguage["alert"], message: getLanguage[message], preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func setAddressAsDefault(_ shippingID: String) {
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.setDefaultAddress(user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", shipping_id: shippingID, onSuccess: { (success) in
            Utility.shared.stopAnimation(viewController: self)
            let pageObj = BuyNowViewController()
            pageObj.isFromAddAddress = true
            pageObj.offerPayment = self.offerPayment
            pageObj.offerPrice = self.offerPrice
            pageObj.addressDetails = self.viewModel.resultModel?.result
            if self.isfromtype  == "story"{
                pageObj.isfromtype = "story"
                pageObj.itemDetailsvideo = self.itemDetailsvideo
                print("Mssddd",self.itemDetailsvideo)
            }else{
                pageObj.isfromtype = ""
                pageObj.itemDetails = self.itemDetails
            }
           
            self.navigationController?.pushViewController(pageObj, animated: true)
        }) { (failure) in
            Utility.shared.stopAnimation(viewController: self)
        }
    }
}
extension AddressViewController: UITableViewDelegate, UITableViewDataSource, addressDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.addressModelArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

       // return 10
        if #available(iOS 15.1, *) {
        return 15
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell") as! AddressTableViewCell
        cell.delegate = self
        cell.countryTextField.tag = indexPath.section
        cell.loadData(index: indexPath, addressModel: self.addressModelArray[indexPath.section])

        if self.addressModelArray[indexPath.section].title == "country" && self.viewType == 1{
            cell.countryTextField.isUserInteractionEnabled = false
        }
        else if self.addressModelArray[indexPath.section].title == "country" {
            cell.countryTextField.isUserInteractionEnabled = true
        }
        // MARK: Single Country Personalization
        
//        cell.countryTextField.text = CURRENT_LOCATION
//        cell.countryTextField.isUserInteractionEnabled = false
         
        return cell
    }

    @objc func configDropDownView(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag == 0 {
            dropDown.anchorView = sender
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            dropDown.width = sender.frame.width
            dropDown.semanticContentAttribute = .unspecified
            dropDown.dataSource = ADMIN_VIEW_MODEL.productBeforeModel?.result.country.map({$0.countryName}) ?? [String]()
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//                ADD_EDIT_ITEM_MODEL.country_id = "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.country[index].countryId ?? 0)"
                self.addressModelArray[6].value = "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.country[index].countryName ?? "")"
                self.tableView.reloadData()
            }
            dropDown.show()
        }
        else {
            dropDown.hide()
        }
    }
    func textFieldEndEditingAct(_ textField: UITextField) {
        let section = (textField.tag / 10)
        self.addressModelArray[section].value = textField.text!
    }
    func textViewEditingAct(_ textView: UITextView) {
        
    }
    func textFieldReturnAct(_ textField: UITextField) {
        let section = (textField.tag / 10)
        self.view.endEditing(true)
        print("section:: \(section) \((self.addressModelArray.count-1))")
        if section+1 < (self.addressModelArray.count) {
            self.returnTag = section
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section+1)) as? AddressTableViewCell {
                //                self.view.endEditing(true)
                print("section1:: \(section) \((self.addressModelArray.count-1))")
                if !cell.addressTextField.isHidden {
                    cell.addressTextField.becomeFirstResponder()
                }
                else if !cell.countryTextField.isHidden {
                    cell.countryTextField.becomeFirstResponder()
                }
            }
        }
    }
}
