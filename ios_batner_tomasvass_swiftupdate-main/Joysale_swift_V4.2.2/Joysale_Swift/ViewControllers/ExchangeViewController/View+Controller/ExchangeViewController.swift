//
//  ExchangeViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 29/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController {
    
    @IBOutlet weak var bottomLoader: UIActivityIndicatorView!
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var viewModel = ExchangeViewModel()
    var selectedItem: ItemModel?
   
    var itemDetails: ItemModel?
    var itemDetailsvideo: StoryListModel?
    var isfromtype = ""
    var itemModel = [ItemModel]()
    var offset = 0
    var isFound = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
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
        self.navigationController?.NavigationBarWithBackButtonAndTitle(title: getLanguage["exchangebuy"] ?? "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)

        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "noItem")

        self.createButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "create")
        self.createButton.setBorder(color: UIColor(named: "AppThemeColorNew"))
        self.cancelButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "cancel")
        self.cancelButton.cornerViewMiniumRadius()
        self.cancelButton.backgroundColor = (UIColor(named: "AppThemeColorNew") ?? .white)
        self.collectionView.register(UINib(nibName: "ExchangeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ExchangeCollectionViewCell")
        self.loadData()
    }
    func loadData() {
        Utility.shared.startAnimation(viewController: self)
        self.viewModel.getItems(type: "moreitems", price: "", search_key: "", category_id: "", subcategory_id: "", user_id: "", item_id: "", seller_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), sorting_id: "1", offset: "\(self.offset)", limit: "50", posted_within: "", distance: "", distance_type: "", lang_type: DEFAULT_LANGUAGE_CODE, filters: "", product_condition: "", child_category_id: "", lon: "", lat: "", onSuccess: { (success) in
            if !success {
                self.isFound = false
                if self.itemModel.count == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            else {
                if self.offset == 0 {
                    self.itemModel.removeAll()
                }
                if self.viewModel.getItemModel?.result != nil {
                    self.itemModel += self.viewModel.getItemModel!.result.items
                }
                else {
                    self.isFound = false
                }
                if self.itemModel.count == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            
            self.bottomLoader.stopAnimating()
            Utility.shared.stopAnimation(viewController: self)
            self.collectionView.reloadData()
        }) { (failure) in
            
            self.bottomLoader.stopAnimating()
            Utility.shared.stopAnimation(viewController: self)
        }
    }
    @IBAction func createButtonAct(_ sender: UIButton) {
        if "\(self.selectedItem?.id ?? 0)" != "0" {
            Utility.shared.startAnimation(viewController: self)
            let itemID = (isfromtype == "story") ? (self.itemDetailsvideo?.id ?? 0) : (self.itemDetails?.id ?? 0)

            self.viewModel.createExchangeAct(user_id: (UserDefaultModule.shared.getUserData()?.user_id ?? ""), myitem_id: "\(itemID)", exchangeitem_id: "\(self.selectedItem?.id ?? 0)", onSuccess: { (success) in
                Utility.shared.stopAnimation(viewController: self)
                let alert = UIAlertController(title: getLanguage["alert"], message: getLanguage[(self.viewModel.exchangeMessageModel?.message ?? "")] ?? (self.viewModel.exchangeMessageModel?.message ?? ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .default, handler: { (UIAlertAction) in
                    if (self.viewModel.exchangeMessageModel?.status ?? false) {
                        let pageObj = ExchangeListViewController()
                        pageObj.isTabbar = true
                        pageObj.selectedIndex = 1
                        self.navigationController?.pushViewController(pageObj, animated: true)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
        else {
            let alert = UIAlertController(title: nil, message: getLanguage["please_select_exchange"] ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: getLanguage["ok"], style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonAct(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension ExchangeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExchangeCollectionViewCell", for: indexPath) as! ExchangeCollectionViewCell
        if self.itemModel.count > indexPath.row {
            cell.loadData(self.itemModel[indexPath.row])
            
            if let selectedVal = self.selectedItem, selectedVal.id == self.itemModel[indexPath.row].id {
                cell.selectedView.isHidden = false
            }
            else {
                cell.selectedView.isHidden = true
            }
            if indexPath.row == (self.itemModel.count - 1) && self.isFound && self.itemModel.count >= 20 {
                self.offset = self.itemModel.count
                
                self.bottomLoader.startAnimating()
                self.loadData()
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width / 2), height: (self.view.frame.width / 2))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItem = self.itemModel[indexPath.row]
        self.collectionView.reloadData()
    }
}
