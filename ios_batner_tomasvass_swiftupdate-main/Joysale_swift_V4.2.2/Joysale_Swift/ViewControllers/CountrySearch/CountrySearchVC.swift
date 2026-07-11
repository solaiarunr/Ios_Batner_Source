//
//  CountrySearchVC.swift
//  Chobi
//
//  Created by HTS on 21/11/23.
//  Copyright © 2023 Hitasoft. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift


protocol CountryCodeDelegate : AnyObject{
    func selectedCode(cc:String,cn:String)
}

class CountrySearchVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var Continuebtn: UIButton!
    weak var countryDel : CountryCodeDelegate?
    var selecteditem =  -1
    var selecteditemurl = ""
    var selectedcountrycode = ""
    var selectedcountryname = ""
    struct Objects {
        var countryCode : String!
        var searchCode : String!
        var searchname : String!
    }
    var inSearchMode = false
    var members = [Objects]()
    var membersFilter = [Objects]()
    let viewModel = CountrylistViewModel()
    
    var countryData = [CountrylistArrModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    func configUI(){
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        self.titleLbl.config(color: .white, font: mediumBold, align: .center, text: "Select your Country")
        self.searchView.crapView(radius: 10)
        self.searchView.backgroundColor = SEPARATOR_COLOR
        self.searchTF.config(color: .white, align: .left, placeHolder: "", font:liteBold )
        self.searchTF.attributedPlaceholder = NSAttributedString(string:getLanguage["Search"] ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white as Any])
        self.searchTF.delegate = self
        for i in 0..<Utility.shared.countryList.count {
            members.append(Objects(countryCode:Utility.shared.countryList[i]["country_code"] ?? "91",searchCode: Utility.shared.countryList[i]["code"] ?? "IN",searchname: Utility.shared.countryList[i]["name"] ?? ""))
        }
        self.Continuebtn.backgroundColor  = UIColor(named: "CountryColor")
        self.collectionView.register(UINib(nibName: "CountrySearchCell", bundle: nil), forCellWithReuseIdentifier: "CountrySearchCell")
        self.collectionView.reloadData()
//        self.Continuebtn.cornerMiniumRadius()
       
        self.loaddata()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        self.navigationController?.customNavigationBarView(title: "Select your Country", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 18), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
    }
    
    
    func loaddata(){
        
        self.viewModel.getcountrylist(onSuccess: { (success) in
            self.countryData = self.viewModel.countrylistModel.result ?? []
            self.collectionView.reloadData()
            
        }, onFailure: { (failure) in
           
            
        })
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }

    func statusAlert(msg: String) {
        var txt = msg
        if let langTxt = getLanguage[msg] as? String {
            txt = langTxt
        }
//        CRNotifications.showNotification(
//            textColor: .white,
//            backgroundColor: SECONDARY_COLOR,
//            image: UIImage(named: "brodcastInfo_icon"),
//            title: APP_NAME,
//            message: txt,
//            dismissDelay: 2
//        )
    }

    @IBAction func ContinuebtnTapped(_ sender: Any) {
        if self.selecteditem != -1 {
            Utility.shared.startAnimation(viewController: self)
            self.viewModel.getselectedcountrylist(country_code: self.selectedcountrycode, country_name: self.selectedcountryname, onSuccess: { (success)  in
                Utility.shared.stopAnimation(viewController: self)
                UserDefaultModule.shared.setAppFirst(true)
                var langCode = self.viewModel.getselectedCountrylist.country_code.lowercased()
                var langname = ""
                // Czech fix
                if langCode == "cz" {
                    langCode = "cs"
                    langname = "Czech"
                }
                else if langCode == "pl" {
                    langCode = "pl"
                    langname = "Polish"
                }
                else if langCode == "sk" {
                    langCode = "sk"
                    langname = "Slovakia"
                }
                else {
                    langCode = "en"
                    langname = "English"
                }
                
                DEFAULT_LANGUAGE_CODE = langCode
                UserDefaults.standard.set([DEFAULT_LANGUAGE_CODE], forKey: "AppleLanguages")
                UserDefaultModule.shared.setAppLanguage(language: langname)
                Utility.shared.configureLanguage()
                UserDefaults.standard.synchronize()
                debugPrint("country_name-->\(self.viewModel.getselectedCountrylist.country_name)")
                UserDefaultModule.shared.setCountrycode(code:self.viewModel.getselectedCountrylist.country_code )
                UserDefaultModule.shared.setCountryname(country:self.viewModel.getselectedCountrylist.country_name)
                UserDefaultModule.shared.setBaseonly(baseurl: self.viewModel.getselectedCountrylist.site_url)
                UserDefaultModule.shared.setBase(baseurl: self.viewModel.getselectedCountrylist.site_url + "api/")
                UserDefaultModule.shared.setChaturl(chaturl: self.viewModel.getselectedCountrylist.chat_url)
                UserDefaultModule.shared.setstreamurl(streamurl: self.viewModel.getselectedCountrylist.stream_url)
                SITE_URL = UserDefaultModule.shared.getbaseurl() ?? ""
                let vc = InitialViewController()
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated: true)
                
            }, onFailure: { (failure)  in
                
                
            })
            
        }else{
            let alert = UIAlertController(title: nil, message: getLanguage["Kindly Select Your Country"] ?? "Kindly Select Your Country", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: { (UIAlertAction) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backBtnAct(_ sender: UIButton){
      
        self.dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
       return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
      //input text
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        print("updatedText > ", updatedText)
        membersFilter = members.filter { $0.searchname.localizedCaseInsensitiveContains(updatedText)}
          print("membersFilter:\(membersFilter)")
           //if(searchArrRes.count == 0){
           if(updatedText == ""){
               if self.members.count == 0{
                  // self.noItemStackView.isHidden = false
               }else{
                  // self.noItemStackView.isHidden = true
               }
               inSearchMode = false
           }else{
               if(membersFilter.count == 0){
                 //  self.noItemStackView.isHidden = false
               }else{
                  // self.noItemStackView.isHidden = true
               }
               inSearchMode = true
           }
           self.collectionView.reloadData()
        return true
   }
}

extension CountrySearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if inSearchMode{
//            return self.membersFilter.count
//        }else{
//            return self.members.count
//        }
        return self.countryData.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width , height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    // Layout: Set Edges
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // MARK: - inSearchMode
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountrySearchCell", for: indexPath) as! CountrySearchCell
        let dict  = countryData[indexPath.item]
        if indexPath.item == self.selecteditem{
            cell.tickiconimg.isHidden = false
        }else{
            cell.tickiconimg.isHidden = true
        }
       cell.countryImg.sd_setImage(with: URL(string: dict.flag_image), placeholderImage: #imageLiteral(resourceName: "applogo"))
       cell.countryLbl.text = dict.country_name
        return cell
    }
    
    


    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.Continuebtn.backgroundColor = UIColor(named: "AppThemeColorNew")
        selecteditem = indexPath.item
        let dict = countryData[indexPath.item]
        self.selecteditemurl = dict.site_url
        self.selectedcountrycode = dict.country_code
        self.selectedcountryname = dict.country_name

        self.collectionView.reloadData()
        self.dismiss(animated: true)
    }

}
