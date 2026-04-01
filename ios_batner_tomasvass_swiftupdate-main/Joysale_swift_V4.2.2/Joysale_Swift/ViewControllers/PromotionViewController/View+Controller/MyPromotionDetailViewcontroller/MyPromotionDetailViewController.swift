//
//  MyPromotionDetailViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 20/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class MyPromotionDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topViewHeightConst: NSLayoutConstraint!
    var promotionModel: PromotionResultModel?
    var viewModel = PromotionViewModel()
    var isFromItemDetails = false
    var itemDetails: ItemModel?
    var itemDetailsvideo: StoryListModel?
    var isfromtype = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
        self.configUI()
    }
    func configUI() {
        self.tableView.register(UINib(nibName: "PromotionDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PromotionDetailTableViewCell")
        self.collectionView.register(UINib(nibName: "ItemDetailsImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemDetailsImageCollectionViewCell")
        self.tableView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.NavigationBarButtonItem()
        self.loadData()
    }
    func loadData() {
        if isFromItemDetails {
            let itemImage = (isfromtype == "story") ? (self.itemDetailsvideo?.photos.first?.itemUrlMainOriginal ?? "") : (self.itemDetails?.photos.first?.itemUrlMainOriginal ?? "")
            let itemTitle = (isfromtype == "story") ? (self.itemDetailsvideo?.itemTitle ?? "") : (self.itemDetails?.itemTitle ?? "")
            
            self.promotionModel?.itemImage = itemImage
            self.promotionModel?.itemName = itemTitle
            self.collectionView.reloadData()
            
            self.NavigationBarButtonItem()
            self.tableView.isHidden = true
            Utility.shared.startAnimation(viewController: self)
            let itemid = (isfromtype == "story") ? (self.itemDetailsvideo?.id ?? 0) : (self.itemDetails?.id ?? 0)
            self.viewModel.checkPromotionData(item_id: "\(itemid ?? 0)", onSuccess: { (success) in
                self.tableView.isHidden = false
                self.promotionModel = self.viewModel.itemPromotionResultModel?.result
                self.promotionModel?.itemImage = itemImage
                self.promotionModel?.itemName = itemTitle
                self.NavigationBarButtonItem()
                self.tableView.reloadData()
                self.collectionView.reloadData()
                Utility.shared.stopAnimation(viewController: self)
            }) { (failure) in
                Utility.shared.stopAnimation(viewController: self)
            }
        }
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
    }
    func NavigationBarButtonItem() {
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "detail_back").imageFlippedForRightToLeftLayoutDirection(), for: UIControl.State.normal)
        button.tintColor = UIColor(named: "whitecolor")
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        button.tag = 0
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if UserDefaultModule.shared.getAppLanguage().capitalized == "Arabic" {
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        }
        else {
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        }

        button.addTarget(self, action: #selector(self.leftBarButtonAct(_:)), for: .touchUpInside)
        
        let button1: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button1.setImage(self.resizedImage(at: #imageLiteral(resourceName: "applogo"), for: CGSize(width: 35, height: 35)), for: .normal)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "applogo"))
        imageView.sd_setImage(with: URL(string: (UserDefaultModule.shared.getUserData()?.photo ?? "")), placeholderImage: nil) { (image, error, cache, url) in
            button1.setImage(self.resizedImage(at: (image ?? #imageLiteral(resourceName: "applogo")), for: CGSize(width: 35, height: 35)), for: .normal)
            button1.contentMode = .scaleAspectFill
            button1.layer.cornerRadius = 17.5
            button1.clipsToBounds = true
        }
//        button1.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button1.tag = 1
        button1.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button1.addTarget(self, action: #selector(self.leftBarButtonAct(_:)), for: .touchUpInside)
        button1.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        
        let button2: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button2.titleLabel?.lineBreakMode = .byTruncatingTail
        button2.titleLabel?.font = UIFont(name: APP_FONT_REGULAR, size: 20) ?? UIFont.systemFont(ofSize: 14)
        button2.setTitle((self.promotionModel?.itemName ?? ""), for: .normal)
        button2.tag = 2
        button2.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button2.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: button), UIBarButtonItem(customView: button1), UIBarButtonItem(customView: button2)]
    }
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    @objc func leftBarButtonAct(_ sender: UIButton) {
        if sender.tag == 0 {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
extension MyPromotionDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if (self.promotionModel?.promotionName ?? "") != "adds" {
                return 0
            }
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionDetailTableViewCell") as! PromotionDetailTableViewCell
        if let premiumData = self.promotionModel {
            cell.loadData(premiumData, index: indexPath.section)
        }
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let y = 300 - (scrollView.contentOffset.y + 300)
            let height = min(max(y, 0), 400)
            topViewHeightConst.constant = height
            self.collectionView.reloadData()
            if self.topViewHeightConst.constant < 10 {
                self.collectionView.isHidden = true
                self.topView.isHidden = true
            }
            else {
                self.collectionView.isHidden = false
                self.topView.isHidden = false
            }
        }
    }
}
extension MyPromotionDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemDetailsImageCollectionViewCell", for: indexPath) as! ItemDetailsImageCollectionViewCell
        if let photos = self.promotionModel?.itemImage {
            var imageUrl = photos
            if !photos.contains("http") {
                imageUrl = "\(ADD_IMAGE_URL)/\(self.promotionModel?.itemId ?? 0)/\(photos)"
            }
            cell.itemImageView.sd_setImage(with: URL(string: imageUrl)) { (image, error, cache, url) in
                if error != nil {
                    cell.itemImageView.image = #imageLiteral(resourceName: "profilelogo")
                }
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.collectionView.bounds.height)
    }
}
