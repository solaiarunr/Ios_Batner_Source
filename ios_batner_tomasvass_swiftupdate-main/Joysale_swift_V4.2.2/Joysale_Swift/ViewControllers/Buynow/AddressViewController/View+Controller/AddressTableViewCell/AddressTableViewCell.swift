//
//  AddressTableViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 25/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

protocol addressDelegate {
    func textFieldEndEditingAct(_ textField: UITextField)
    func textViewEditingAct(_ textView: UITextView)
    func textFieldReturnAct(_ textField: UITextField)
}


class AddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    var delegate: addressDelegate?
    @IBOutlet weak var addressTextView: UITextView!
//    @IBOutlet weak var textviewHeightConst: NSLayoutConstraint!
    var isShippingView = false
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.countryTextField.isHidden = true
        self.addressTextView.isHidden = true
        self.addressTextField.delegate = self
        self.addressTextView.delegate = self
        self.addressTextField.addDoneButtonOnKeyboard()
        self.addressLabel.config(color: UIColor(named: "appblackcolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.addressTextField.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.countryTextField.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.addressTextView.config(color: UIColor(named: "appblackcolor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.addressTextView.addDoneButtonOnKeyboard()
        self.addressTextField.addDoneButtonOnKeyboard()
        self.countryTextField.addDoneButtonOnKeyboard()
        self.countryTextField.addTarget(self, action: #selector(self.countryPickerTextFieldAct(_:)), for: .editingDidBegin)
    }
    @objc func countryPickerTextFieldAct(_ sender: UITextField) {
        let pickerView: UIPickerView = UIPickerView()
        // Load PickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        sender.inputView = pickerView
    }
    @objc func dismissPicker() {
        self.endEditing(true)
    }
    func loadData(index: IndexPath, addressModel: AddressModel) {
        self.addressLabel.text = (getLanguage[addressModel.title] ?? "").uppercased()
        self.countryTextField.isHidden = true
        self.addressTextField.placeholder = getLanguage[addressModel.desc] ?? ""
        self.countryTextField.placeholder = getLanguage[addressModel.desc] ?? ""

        self.addressTextField.tag = (index.section * 10)+index.row
        self.countryTextField.tag = (index.section * 10)+index.row
        self.addressTextView.tag = (index.section * 10)+index.row

        self.addressTextField.text = addressModel.value ?? ""
        self.countryTextField.text = addressModel.value ?? ""
        
        if addressModel.title == "country" {
            self.countryTextField.isHidden = false
            self.addressTextField.isHidden = true
        }
        if index.section == 8 {
            self.addressTextField.keyboardType = .numberPad
        }
        else {
            self.addressTextField.keyboardType = .default
        }
    }
    func loadShippingData(index: IndexPath, addressModel: AddressModel) {
        isShippingView = true
        self.addressTextField.isHidden = false
        self.addressTextView.isHidden = true
        self.addressLabel.text = (getLanguage[addressModel.title] ?? "").uppercased()
        self.addressTextField.placeholder = ""
        self.addressTextField.tag = (index.section * 10)+index.row
        self.countryTextField.tag = (index.section * 10)+index.row
        self.addressTextView.tag = (index.section * 10)+index.row
        self.addressTextField.text = addressModel.value
        
        if index.section == 4 {
            self.addressTextView.text = addressModel.value
            self.addressTextField.isHidden = true
            self.addressTextView.isHidden = false
        }
        else {
            if index.section == 0 {
                print("index \(self.addressTextField.tag)")

                self.addressTextField.setDatePicker(target: self, selector: #selector(self.datePickerAct), minimumDate: Date())
                self.addressTextField.text = addressModel.value
            }
            self.addressTextField.isHidden = false
            self.addressTextView.isHidden = true
        }

    }
    @objc func datePickerAct() {
        if let datePicker = self.addressTextField.inputView as? UIDatePicker { // 2-1
            let dateformatter = DateFormatter() // 2-2
            dateformatter.dateFormat = "dd-MMM-YYYY"
            self.addressTextField.text = dateformatter.string(from: datePicker.date)
        }
        self.addressTextField.resignFirstResponder()
        delegate?.textFieldEndEditingAct(self.addressTextField)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension AddressTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.endEditing(true)
        delegate?.textFieldReturnAct(textField)
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldEndEditingAct(textField)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let section = (textField.tag / 10)
        if section == 8 && !isShippingView {
            let allowedCharacters = CharacterSet(charactersIn:".0123456789")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            if allowedCharacters.isSuperset(of: characterSet) {
                return true
            }
            else {
                return false
            }
        }
        else if string.containsEmoji {
            return false
        }
        return true
    }
}
extension AddressTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
           // tableView?.beginUpdates()
          //  tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
//            if let thisIndexPath = tableView?.indexPath(for: self) {
//                tableView?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
//            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewEditingAct(textView)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.containsEmoji {
            return false
        }
        return true
    }
}

extension AddressTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ADMIN_VIEW_MODEL.productBeforeModel?.result.country.count ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ADMIN_VIEW_MODEL.productBeforeModel?.result.country[row].countryName ?? ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        ADD_EDIT_ITEM_MODEL.country_id = "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.country[row].countryId ?? 0)"
        self.countryTextField.text = "\(ADMIN_VIEW_MODEL.productBeforeModel?.result.country[row].countryName ?? "")"
        self.delegate?.textFieldEndEditingAct(self.countryTextField)
    }
}
//extension UITableViewCell {
//    var tableView: UITableView? {
//        get {
//            var table: UIView? = superview
//            while !(table is UITableView) && table != nil {
//                table = table?.superview
//            }
//            return table as? UITableView
//        }
//    }
//}
