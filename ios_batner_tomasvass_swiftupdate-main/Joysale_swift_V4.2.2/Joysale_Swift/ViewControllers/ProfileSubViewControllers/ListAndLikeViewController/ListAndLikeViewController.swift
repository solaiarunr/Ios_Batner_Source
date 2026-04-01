//
//  ListAndLikeViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 11/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class ListAndLikeViewController: UIViewController {

    @IBOutlet weak var bottomLoader: UIActivityIndicatorView!
    @IBOutlet weak var noItemDesLabel: UILabel!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemStackView: UIStackView!

    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel = ExchangeViewModel()
    var userId = ""
    let delegate = UIApplication.shared.delegate as! AppDelegate
    private let refreshControl = UIRefreshControl()

    var itemModel = [ItemModel]()
    var likedModel = [ItemModel]()
    var offset = 0
    var isFound = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        print("List&LikeView")
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func configUI() {
        self.noItemStackView.isHidden = true
        self.noItemTitleLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, text: "sorry")
        self.noItemDesLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .center, text: "noItem")
        self.collectionView.register(UINib(nibName: "ExchangeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ExchangeCollectionViewCell")
        if #available(iOS 10.0, *) {
            self.collectionView.refreshControl = refreshControl
        } else {
            self.collectionView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refreshAct), for: .valueChanged)
        self.loadData()
    }
    @objc func refreshAct() {
        self.offset = 0
        self.isFound = true
        self.itemModel.removeAll()
        self.likedModel.removeAll()
        self.collectionView.reloadData()
        self.loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        self.offset = 0
        self.isFound = true
        self.loadData()
    }
    func loadData() {
        var type = ""
        if self.view.tag == 0 {
            type = "moreitems"
        }
        else {
            type = "liked"
        }
        self.refreshControl.beginRefreshing()
        self.viewModel.getItems(type: type, price: "", search_key: "", category_id: "", subcategory_id: "", user_id: UserDefaultModule.shared.getUserData()?.user_id ?? "", item_id: "", seller_id: self.userId, sorting_id: "1", offset: "\(self.offset)", limit: "20", posted_within: "", distance: "", distance_type: "", lang_type: DEFAULT_LANGUAGE_CODE, filters: "", product_condition: "", child_category_id: "", lon: "", lat: "", onSuccess: { (success) in
            self.bottomLoader.stopAnimating()
            if !success {
                self.isFound = false
                if self.offset == 0 {
                    self.itemModel.removeAll()
                    self.likedModel.removeAll()
                }
                let itemCount = type == "moreitems" ? self.itemModel.count : self.likedModel.count
                if itemCount == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            else {
                if self.offset == 0 {
                    self.itemModel.removeAll()
                    self.likedModel.removeAll()
                }
                if self.viewModel.getItemModel?.result != nil {
                    if type == "moreitems" {
                        self.itemModel += self.viewModel.getItemModel!.result.items
                    }
                    else {
                        self.likedModel += self.viewModel.getItemModel!.result.items
                    }
                }
                else {
                    self.isFound = false
                }
                let itemCount = type == "moreitems" ? self.itemModel.count : self.likedModel.count
                if itemCount == 0 {
                    self.noItemStackView.isHidden = false
                }
                else {
                    self.noItemStackView.isHidden = true
                }
            }
            self.refreshControl.endRefreshing()
            self.bottomLoader.stopAnimating()
            self.collectionView.reloadData()
        }) { (failure) in
            self.refreshControl.endRefreshing()
            self.bottomLoader.stopAnimating()
            self.collectionView.reloadData()
            Utility.shared.stopAnimation(viewController: self)
        }
    }
}
extension ListAndLikeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.view.tag == 0 ? self.itemModel.count : self.likedModel.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExchangeCollectionViewCell", for: indexPath) as! ExchangeCollectionViewCell
        if self.view.tag == 0 && self.itemModel.count > indexPath.row{
            cell.loadListLikeData(self.itemModel[indexPath.row])
            cell.buttonStackView.isHidden = false
            cell.contentView.cornerViewMiniumRadius()
            if self.itemModel.count > indexPath.row && self.itemModel.count % 20 == 0 {
                if indexPath.row == (self.itemModel.count - 1) && self.isFound && self.itemModel.count % 20 == 0  {
                    self.offset = self.itemModel.count
                    self.bottomLoader.startAnimating()
                    self.loadData()
                }
            }
        }
        else if self.likedModel.count > indexPath.row {
            cell.loadListLikeData(self.likedModel[indexPath.row])
            cell.buttonStackView.isHidden = false
            cell.contentView.cornerViewMiniumRadius()
            if self.likedModel.count > indexPath.row && self.likedModel.count % 20 == 0 {
                if indexPath.row == (self.likedModel.count - 1) && self.isFound {
                    self.offset = self.likedModel.count
                    self.bottomLoader.startAnimating()
                    self.loadData()
                }
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthMode = (self.collectionView.frame.width/2 - 12)
        let heightMode = (self.collectionView.frame.width/2 - 12)
        return CGSize(width: widthMode, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productType: String
         if self.view.tag == 0 {
             productType = self.itemModel[indexPath.item].product_type ?? ""
         } else {
             productType = self.likedModel[indexPath.item].product_type ?? ""
         }
        if productType == "video"{
                    let view = StoryAllList()
//                    view.productModel = self.productModel
                    view.type = "after"
                    if self.view.tag == 0 && self.itemModel.count > indexPath.row {
                        view.userId = self.itemModel[indexPath.row].sellerId
                        view.getitemstype = "myitems"
                        view.fromNav = "profile"
                        view.videoID = self.itemModel[indexPath.row].stream_id ?? ""
                        print("view.videoID_itemModel:\(self.itemModel[indexPath.row].stream_id ?? "")")
                    }
                    else {
                        if self.likedModel.count > indexPath.row {
                            view.userId = UserDefaultModule.shared.getUserData()?.user_id ?? ""
                            if self.likedModel[indexPath.row].promotionType == "Ad"{
                               view.ad_product = "true"
                            }else{
                               view.ad_product = "false"
                            }
                            view.hts_product_id = "\(self.likedModel[indexPath.row].id ?? 0)"
                            if indexPath.item == 0{
                                view.position = "\(indexPath.item)"
                                view.before_position = "\(0)"
                                view.after_position = "\(indexPath.item + 1)"
                            }else{
                                view.position = "\(indexPath.item)"
                                view.before_position = "\(indexPath.item - 1)"
                                view.after_position = "\(indexPath.item + 1)"
                            }
                            view.getitemstype = "liked"
                            view.fromNav = "Home"
                            view.seller_id = self.likedModel[indexPath.row].sellerId
                            view.videoID = self.likedModel[indexPath.row].stream_id ?? ""
                            view.user_Img = self.likedModel[indexPath.row].sellerImg ?? ""
                            print("view.videoID_likedModel:\(self.likedModel[indexPath.row].stream_id ?? "")")
                        }
                    }
                    self.delegate.navigationController.pushViewController(view, animated: true)
        }else{
            let pageObj = ItemDetailsViewController()
            if self.view.tag == 0 && self.itemModel.count > indexPath.row {
                pageObj.itemDetails = self.itemModel[indexPath.row]
                
                print("Solaiachk",self.itemModel[indexPath.row].promotionType)
            }
            else {
                pageObj.itemDetails = self.likedModel[indexPath.row]
            }
            
            self.delegate.navigationController.pushViewController(pageObj, animated: true)
        }

       
    }
}
