 //
 //  AddProductTableViewCell.swift
 //  Joyshorts_Swift
 //
 //  Created by Hitasoft on 24/07/20.
 //  Copyright © 2020 Hitasoft. All rights reserved.
 //

 import UIKit

 protocol AddProductDelegate {
     func didSelectAddImageButtonAct(_ isAdd: Bool, tag: Int)
 }
 class AddProductTableViewCell: UITableViewCell {

     @IBOutlet weak var priceSeparatorView: UIView!
     @IBOutlet weak var collectionView: UICollectionView!
     @IBOutlet weak var detailStackView: UIStackView!
     @IBOutlet weak var dropDownButton: UIButton!
     @IBOutlet weak var switchControl: UISwitch!
     @IBOutlet weak var rightImageView: UIImageView!
     @IBOutlet weak var rightTextField: UITextField!
     @IBOutlet weak var titleLabel: UILabel!
     @IBOutlet weak var textView: UITextView!
     @IBOutlet weak var textField: UITextField!
     
     @IBOutlet weak var wholeStackView: UIStackView!
     @IBOutlet weak var HeaderLabel: UILabel!
     
     var imageArray = [AddProductImageModel]()
     var updateFilterData: UpdateFilterModel?
     var filterData: ProductFilterModel?
     var delegate: AddProductDelegate?
     override func awakeFromNib() {
         super.awakeFromNib()
         self.configUI()
     }
     func configUI() {
         self.textField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 15))
         self.textView.config(color: UIColor(named: "AppTextColor") ?? .white, font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
         self.rightTextField.config(color: UIColor(named: "AppTextColor"), align: .right, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 15))
         self.titleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
         self.HeaderLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
         self.dropDownButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .right, title: "")
         self.textField.addDoneButtonOnKeyboard()
         self.textField.delegate = self
         self.rightTextField.addDoneButtonOnKeyboard()
         self.rightTextField.delegate = self
         self.textView.textContainerInset = UIEdgeInsets.zero
         self.textView.textContainer.lineFragmentPadding = 0
         self.textView.addDoneButtonOnKeyboard()
         self.textView.delegate = self
         self.collectionView.delegate = self
         self.collectionView.dataSource = self
         self.collectionView.register(UINib(nibName: "CameraCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CameraCollectionViewCell")
         self.switchControl.semanticContentAttribute = .forceLeftToRight
         if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
             self.switchControl.transform = CGAffineTransform(scaleX: -1, y: 1)
         }
    
     }
     func loadImageData(imageArr: [AddProductImageModel]) {
         self.wholeStackView.setCustomSpacing(5.0, after: self.HeaderLabel)
         self.HeaderLabel.text = (getLanguage["listing_image"] ?? "")
         self.HeaderLabel.isHidden = false
         self.collectionView.isHidden = false
         self.imageArray = imageArr
         self.textField.isHidden = true
         self.textView.isHidden = true
         self.detailStackView.isHidden = true
         self.collectionView.reloadData()
     }
     func loadFilterData(_ filterData: ProductFilterModel, index: IndexPath) {
         self.textField.tag = ((index.section * 10) + index.row)
         self.rightTextField.tag = ((index.section * 10) + index.row)
         self.switchControl.tag = ((index.section * 10) + index.row)
         
         self.filterData = filterData
         self.rightTextField.config(color: UIColor(named: "AppTextColor"), align: .right, placeHolder: "", font: UIFont(name: APP_FONT_REGULAR, size: 15))
         self.textField.isHidden = true
         self.textView.isHidden = true
         self.rightTextField.text = ""
         self.detailStackView.isHidden = false
         self.collectionView.isHidden = true
         self.HeaderLabel.isHidden = true
         self.rightTextField.isHidden = true
         self.rightTextField.isUserInteractionEnabled = false
         self.rightImageView.isHidden = true
         self.dropDownButton.isHidden = true
         self.priceSeparatorView.isHidden = true
         self.switchControl.isHidden = true
         self.rightTextField.isHidden = false
         self.titleLabel.text = filterData.label
         
         if filterData.type == "dropdown" || filterData.type == "multilevel" {
             self.rightImageView.isHidden = false
             self.rightTextField.placeholder = ""
             if filterData.type == "dropdown" {
                 for id in updateFilterData?.dropdown ?? [FilterSubModel]() {
                     if let parentVal = filterData.values.filter({$0.parentId == id.id && filterData.categoryType == id.catType}).first {
                         self.rightTextField.text = parentVal.parentLabel
                     }
                 }
             }
             else if filterData.type == "multilevel" {
                 for id in updateFilterData?.multilevel ?? [FilterSubModel]() {
                     if let child = filterData.values.filter({$0.parentValues.contains(where: {$0.childId == id.id && id.catType == filterData.categoryType})}).first {
                         self.rightTextField.text = child.parentValues.filter({i in (updateFilterData?.multilevel.contains(where: {$0.id == i.childId && $0.catType == filterData.categoryType}) ?? false)}).first?.childName ?? ""
                     }
                 }
             }
         }
         else if filterData.type == "range" {
             self.rightTextField.attributedPlaceholder = NSAttributedString(string: ("\(filterData.minValue ?? "") - \(filterData.maxValue ?? "")"), attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "SecondaryTextColor") ?? .white])
             if let child = updateFilterData?.range.filter({$0.id == filterData.id}).first {
                 self.rightTextField.text = child.max_value
             }
             self.rightTextField.keyboardType = .numberPad
             self.rightTextField.isUserInteractionEnabled = true
         }
     }
     func loadData(index: IndexPath) {
         self.textField.isHidden = true
         self.textView.isHidden = true
         self.detailStackView.isHidden = true
         self.collectionView.isHidden = true
         self.HeaderLabel.isHidden = true
         self.rightTextField.isHidden = true
         self.rightImageView.isHidden = true
         self.dropDownButton.isHidden = true
         self.priceSeparatorView.isHidden = true
         self.switchControl.isHidden = true
         self.rightTextField.placeholder = ""
         self.rightTextField.isUserInteractionEnabled = false
         self.rightTextField.keyboardType = .default
        
         
         self.textField.tag = ((index.section * 10) + index.row)
 //        self.textView.tag = ((index.section * 10) + index.row)
         self.rightTextField.tag = ((index.section * 10) + index.row)
         self.switchControl.tag = ((index.section * 10) + index.row)
         if index.section == 2 {
             self.textField.text = ADD_EDIT_ITEM_MODEL.item_name
             self.textField.isHidden = false
             self.textField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "what_are_you_selling", font: UIFont(name: APP_FONT_REGULAR, size: 15))
         }
         else if index.section == 3 {
             self.textView.isHidden = false
             self.textView.text = getLanguage["describe_your_listing"] ?? ""
             self.textView.textColor = UIColor(named: "SecondaryTextColor") ?? .white
             if ADD_EDIT_ITEM_MODEL.item_des != "" {
                 self.textView.text = ADD_EDIT_ITEM_MODEL.item_des
                 self.textView.tag = 1
                 self.textView.textColor = UIColor(named: "AppTextColor") ?? .white
             }
         }
         else if index.section == 4 {
             self.detailStackView.isHidden = false
             self.switchControl.isHidden = false
             self.switchControl.isOn = ADD_EDIT_ITEM_MODEL.giving_away
             self.titleLabel.text = getLanguage["giving_away"] ?? ""
         }
         else if index.section == 5 {
            
             self.detailStackView.isHidden = false
             self.rightTextField.isHidden = false
             self.dropDownButton.isHidden = false
             self.priceSeparatorView.isHidden = false
             self.rightTextField.isUserInteractionEnabled = true
             self.titleLabel.text = getLanguage["price"] ?? ""
             self.rightTextField.config(color: UIColor(named: "AppTextColor"), align: .right, placeHolder: "enter_your_price", font: UIFont(name: APP_FONT_REGULAR, size: 15))
             self.rightTextField.text = ADD_EDIT_ITEM_MODEL.price
             self.rightTextField.keyboardType = .decimalPad
            
             let currency = ADMIN_VIEW_MODEL.productBeforeModel?.result.currency.filter({$0.symbol == (ADD_EDIT_ITEM_MODEL.currency ?? "")}).first
             if currency != nil {
                 self.dropDownButton.setTitle(currency?.symbol ?? "", for: .normal)
             }
             else {
                 self.dropDownButton.setTitle(ADMIN_VIEW_MODEL.productBeforeModel?.result.currency.first?.symbol ?? "", for: .normal)
                 ADD_EDIT_ITEM_MODEL.currency = ADMIN_VIEW_MODEL.productBeforeModel?.result.currency.first?.symbol ?? ""
             }
             
         }
         else if index.section == 6 {
             self.detailStackView.isHidden = false
             self.rightTextField.isHidden = false
             self.titleLabel.text = getLanguage["category"] ?? ""
             if ADD_EDIT_ITEM_MODEL.category != "",let categoryData = ADMIN_VIEW_MODEL.adminModel?.result.category.filter({$0.categoryId == (Int(ADD_EDIT_ITEM_MODEL.category) ?? 0)}).first {
                 self.rightTextField.text = categoryData.categoryName
                 if ADD_EDIT_ITEM_MODEL.subcategory != "", let subCategory = categoryData.subcategory.filter({$0.subId == (Int(ADD_EDIT_ITEM_MODEL.subcategory) ?? 0)}).first {
                     self.rightTextField.text = "\(categoryData.categoryName ?? "") · \(subCategory.subName ?? "")"
                     
                     if ADD_EDIT_ITEM_MODEL.child_category != "", let childCategory = subCategory.childCategory.filter({$0.childId == (Int(ADD_EDIT_ITEM_MODEL.child_category) ?? 0)}).first {
                         self.rightTextField.text = "\(categoryData.categoryName ?? "") · \(subCategory.subName ?? "") · \((childCategory.childName ?? ""))"
                     }
                 }
             }
             else {
                 self.rightTextField.config(color: UIColor(named: "AppTextColor"), align: .right, placeHolder: "select_your_category", font: UIFont(name: APP_FONT_REGULAR, size: 15))
             }
             self.rightImageView.isHidden = false
         }
         else if index.section == 8 {
             self.detailStackView.isHidden = false
             self.detailStackView.isHidden = false
             self.rightTextField.isHidden = false
             self.titleLabel.text = getLanguage["location"] ?? ""
             self.rightTextField.config(color: UIColor(named: "AppTextColor"), align: .right, placeHolder: "set_your_location", font: UIFont(name: APP_FONT_REGULAR, size: 15))
             self.rightImageView.isHidden = false
             //             self.rightTextField.text = UserDefaultModule.shared.getLocation() ?? ""
             if ADD_EDIT_ITEM_MODEL.address == ""{
                 self.rightTextField.text = UserDefaultModule.shared.getLocation() ?? ADD_EDIT_ITEM_MODEL.address
             }else{
                 self.rightTextField.text = ADD_EDIT_ITEM_MODEL.address
             }
         }
//         else if index.section == 9 {
//             self.detailStackView.isHidden = false
//             if index.row == 0 {
//                 self.rightTextField.isHidden = false
//                 self.rightTextField.text = ""
//                 self.rightImageView.isHidden = false
//                 self.titleLabel.text = getLanguage["itemcondition"] ?? ""
//                 if let itemCondition = ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.filter({$0.id == Int(ADD_EDIT_ITEM_MODEL.item_condition ?? "0")}).first {
//                     self.rightTextField.text = getLanguage[itemCondition.name] ?? itemCondition.name
//                 }
//             }
//             /*
//             else if index.row == 1{
//                 self.switchControl.isHidden = false
//                 self.switchControl.isOn = ADD_EDIT_ITEM_MODEL.exchange_to_buy
//                 self.titleLabel.text = getLanguage["exchangebuy"] ?? ""
//             }
//            */
//             /*
//             else {
//                 self.switchControl.isHidden = false
//                 self.switchControl.isOn = ADD_EDIT_ITEM_MODEL.make_offer == 1 ? true : false
//                 self.titleLabel.text = getLanguage["fixedprice"] ?? ""
//             }
//             */
//         }
//         else if index.section == 10 {
//             self.detailStackView.isHidden = false
//             self.titleLabel.isHidden = false
//             self.switchControl.isHidden = false
//             self.switchControl.isOn = ADD_EDIT_ITEM_MODEL.make_offer == 1 ? true : false
//             self.titleLabel.text = getLanguage["fixedprice"] ?? ""
//         }
         
         else if index.section == 10 {
             self.detailStackView.isHidden = false
             if index.row == 0 {
                 self.rightTextField.isHidden = false
                 self.rightTextField.text = ""
                 self.rightImageView.isHidden = false
                 self.titleLabel.text = getLanguage["itemcondition"] ?? ""
                 if let itemCondition = ADMIN_VIEW_MODEL.productBeforeModel?.result.productCondition.filter({$0.id == Int(ADD_EDIT_ITEM_MODEL.item_condition ?? "0")}).first {
                     self.rightTextField.text = getLanguage[itemCondition.name] ?? itemCondition.name
                 }
             }
             else if index.row == 1{
                 self.switchControl.isHidden = false
                 self.switchControl.isOn = ADD_EDIT_ITEM_MODEL.exchange_to_buy
                 self.titleLabel.text = getLanguage["exchangebuy"] ?? ""
             }
             else {
                 self.switchControl.isHidden = false
                 self.switchControl.isOn = ADD_EDIT_ITEM_MODEL.make_offer == 1 ? true : false
                 self.titleLabel.text = getLanguage["fixedprice"] ?? ""
             }
         }
         else if index.section == 11 {
             self.detailStackView.isHidden = false
             if index.row == 0 {
                 self.switchControl.isHidden = false
                 self.switchControl.isOn = ADD_EDIT_ITEM_MODEL.instant_buy
                 self.titleLabel.text = getLanguage["instantbuy"] ?? ""
             }
             else {
                 self.rightTextField.isUserInteractionEnabled = true
                 self.rightTextField.isHidden = false
                 self.rightTextField.keyboardType = .decimalPad
                 self.rightTextField.config(color: UIColor(named: "AppTextColor"), align: .right, placeHolder: "entershippingcost", font: UIFont(name: APP_FONT_REGULAR, size: 15))
                 self.titleLabel.text = getLanguage["shippingcost"] ?? ""
                 self.rightTextField.text = ADD_EDIT_ITEM_MODEL.shipping_cost
             }
         }
         /*
         else if index.section == 12 {
             self.textField.isHidden = false
             self.textField.config(color: UIColor(named: "AppTextColor"), align: .left, placeHolder: "optional", font: UIFont(name: APP_FONT_REGULAR, size: 15))
             self.textField.text = ADD_EDIT_ITEM_MODEL.youtube_link
         }
          */
     }
     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)

         // Configure the view for the selected state
     }
     
 }
 extension AddProductTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         if self.imageArray.count < 15 {
             return (self.imageArray.count + 1)
         }
         return (self.imageArray.count)
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCollectionViewCell", for: indexPath) as! CameraCollectionViewCell
         cell.selectedView.isHidden = true
         cell.cancelButton.tag = indexPath.row
         cell.cancelButton.addTarget(self, action: #selector(self.cancelButtonAct(_:)), for: .touchUpInside)
         if indexPath.row < self.imageArray.count {
             cell.cancelButton.isHidden = false
             if self.imageArray[indexPath.item].isuploaded {
                 if !self.imageArray[indexPath.item].imageUrl.contains("http") {
                     cell.itemImageView.sd_setImage(with: URL(string: "\(ADD_IMAGE_URL)/\(ADD_EDIT_ITEM_MODEL.item_id ?? "")/\(self.imageArray[indexPath.item].imageUrl ?? "")"), placeholderImage: nil , completed: nil)
                 }
                 else {
                     cell.itemImageView.sd_setImage(with: URL(string: self.imageArray[indexPath.item].imageUrl), placeholderImage: nil , completed: nil)
                 }
             }
             else {
                 cell.itemImageView.image = self.imageArray[indexPath.item].image
             }
         }
         else {
             cell.cancelButton.isHidden = true
           cell.itemImageView.image = #imageLiteral(resourceName: "addimage")
             cell.itemImageView.backgroundColor = UIColor(named: "BackColorwhite")
         }
         return cell
     }
     @objc func cancelButtonAct(_ sender: UIButton) {
         self.delegate?.didSelectAddImageButtonAct(false, tag: sender.tag)
     }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: self.collectionView.frame.height, height: self.collectionView.frame.height)
     }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         if indexPath.row < self.imageArray.count {
         }
         else {
             delegate?.didSelectAddImageButtonAct(true, tag: indexPath.row)
         }
     }
 }
 extension AddProductTableViewCell: UITextFieldDelegate {
     func textFieldDidBeginEditing(_ textField: UITextField) {
         let section = textField.tag / 10
         if section == 2 {
             textField.placeholder = ""
         }
     }
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.endEditing(true)
         return true
     }
     func textFieldDidEndEditing(_ textField: UITextField) {
         let section = textField.tag / 10
         if section == 2 {
             ADD_EDIT_ITEM_MODEL.item_name = textField.text!
             let redPlaceholderText = NSAttributedString(string: (getLanguage["what_are_you_selling"] ?? ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "SecondaryTextColor") ?? .white])
             self.textField.attributedPlaceholder = redPlaceholderText
         }
         else if section == 5 && textField == rightTextField{
             ADD_EDIT_ITEM_MODEL.price = textField.text!
         }
         else if section == 7 && textField == rightTextField {
             let updateValue = Utility.shared.filterStringToDict(ADD_EDIT_ITEM_MODEL.filters)
             if updateValue.range.count > 0 && updateValue.range.contains(where: {$0.id == filterData?.id ?? ""}) {
                 updateValue.range.removeAll(where: {$0.id == filterData?.id ?? ""})
             }
             updateValue.range.append(FilterRangeModel(max_value: self.rightTextField.text!, id: filterData?.id ?? "", min_value: self.rightTextField.text!))
             
             ADD_EDIT_ITEM_MODEL.filters = Utility.shared.filterDictToString(updateValue)
         }
         else if section == 11 && textField == rightTextField {
             ADD_EDIT_ITEM_MODEL.shipping_cost = textField.text!
         }
         else if section == 12 && textField == self.textField {
             ADD_EDIT_ITEM_MODEL.youtube_link = textField.text!
         }
     }
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         let section = textField.tag / 10
         if section == 2 {
             if string.containsEmojis {
                 return false
             }
             let strLength = textField.text?.count ?? 0
             let lngthToAdd = string.count
             let lengthCount = strLength + lngthToAdd
             if lengthCount > 100 {
                 return false
             }
              return true
         }
         else if section == 7 {
             let allowedCharacters = CharacterSet(charactersIn:".0123456789")//Here change this characters based on your requirement
             let characterSet = CharacterSet(charactersIn: string)
             if allowedCharacters.isSuperset(of: characterSet) {
                 return true
             }
             else {
                 return false
             }
         }
         if section == 5 && textField == rightTextField || section == 11 && textField == rightTextField {
             let amountString: NSString = textField.text! as NSString
             let newString: NSString = amountString.replacingCharacters(in: range, with: string) as NSString
             let regex = "\\d{0,\(ADMIN_VIEW_MODEL.adminModel?.result.priceRange.beforeDecimalNotation ?? "5")}(\\.\\d{0,\(ADMIN_VIEW_MODEL.adminModel?.result.priceRange.afterDecimalNotation ?? "2")})?"

             let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
             let allowedCharacters = CharacterSet(charactersIn:".0123456789")//Here change this characters based on your requirement
             let characterSet = CharacterSet(charactersIn: string)
             
             return predicate.evaluate(with:newString) && allowedCharacters.isSuperset(of: characterSet)
         }
         else if section == 2 {
             let strLength = textField.text?.count ?? 0
             let lngthToAdd = string.count
             let lengthCount = strLength + lngthToAdd
             if lengthCount > 70 {
                 self.endEditing(true)
                 return false
             }

         }
         return true
     }
 }
// extension AddProductTableViewCell: UITextViewDelegate {
//     func textViewDidBeginEditing(_ textView: UITextView) {
//         self.textChangeAct(textView)
//     }
//     func textViewDidEndEditing(_ textView: UITextView) {
//         self.textChangeAct(textView)
//         if textView.text != "" && textView.tag == 1 {
//             ADD_EDIT_ITEM_MODEL.item_des = textView.text!
//         }
//         else {
//             ADD_EDIT_ITEM_MODEL.item_des = ""
//         }
//     }
//     func textChangeAct(_ sender: UITextView) {
//         if textView.tag == 0 {
//             textView.tag = 1
//             textView.text = ""
//             textView.textColor = UIColor(named: "AppTextColor")
//         }
//         else {
//             if textView.text == "" {
//                 textView.tag = 0
//                 self.textView.text = getLanguage["describe_your_listing"] ?? ""
//                 self.textView.textColor = UIColor(named: "SecondaryTextColor") ?? .white
//             }
//         }
//     }
//     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//         if text.containsEmoji {
//             return false
//         }
//         let currentText = textView.text ?? ""
//         guard let stringRange = Range(range, in: currentText) else { return false }
//         let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
//         return updatedText.count <= 5000
//     }
// }

extension AddProductTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textChangeAct(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.textChangeAct(textView)
        if textView.text != "" && textView.tag == 1 {
            ADD_EDIT_ITEM_MODEL.item_des = textView.text!
        } else {
            ADD_EDIT_ITEM_MODEL.item_des = ""
        }
    }

    func textChangeAct(_ textView: UITextView) {
        if textView.tag == 0 {
            textView.tag = 1
            textView.text = ""
            textView.textColor = UIColor(named: "AppTextColor")
        } else {
            if textView.text == "" {
                textView.tag = 0
                textView.text = getLanguage["describe_your_listing"] ?? ""
                textView.textColor = UIColor(named: "SecondaryTextColor") ?? .white
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        /*
        // 🧠 Calculate number of visible lines
        let numberOfLines = Int(textView.contentSize.height / textView.font!.lineHeight)

        if numberOfLines > 5 {
            // 🛑 Trim the last change
            textView.text = String(textView.text.dropLast())
            // 🚨 Show alert once when line limit is hit
            if let vc = self.parentViewControllers {
                let alert = UIAlertController(title: nil, message: "Maximum 5 lines allowed for description.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                vc.present(alert, animated: true, completion: nil)
            }
        }
         */
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.containsEmoji {
            return true
        }

        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 6000
    }
    
    
}
extension UIView {
    var parentViewControllers: UIViewController? {
        var parentResponder: UIResponder? = self
        while let nextResponder = parentResponder?.next {
            if let vc = nextResponder as? UIViewController {
                return vc
            }
            parentResponder = nextResponder
        }
        return nil
    }
}
extension String {
    var containsEmojis: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x1F1E6...0x1F1FF, // Flags
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1FA70...0x1FAFF, // Extended-A
                 0x200D:            // Zero-width joiner
                return true
            default:
                continue
            }
        }
        return false
    }
}
