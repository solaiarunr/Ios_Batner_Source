//
//  HomeHeaderCollectionViewCell.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 12/06/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class HomeHeaderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var activityView: NVActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControll: UIPageControl!
    var bannerData = [BannerDatumModel]()
    var categoryData = [CategoryModel]()
    
    var viewType = 0
    var timer: Timer?
    var itemCount = 0
    var homeVC: HomeViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
        // Initialization code
    }
    func configUI() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")

    }
    func loadData(_ bannerData: [BannerDatumModel]) {
        self.pageControll.isHidden = false
        self.pageControll.numberOfPages = bannerData.count
        self.bannerData = bannerData
        self.collectionView.reloadData()
    }
}
extension HomeHeaderCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerData.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
        if indexPath.row < self.bannerData.count {
            self.activityView.startAnimating()
            self.activityView.isHidden = false

            cell.bannerImageView.sd_setImage(with: URL(string: bannerData[indexPath.row].bannerImage)) { (image, error, cache, url) in
                self.activityView.stopAnimating()
                self.activityView.isHidden = true
                if error != nil {
                     cell.bannerImageView.image = #imageLiteral(resourceName: "applogo")
                }
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.homeVC?.bannerURLAct(bannerData[indexPath.row].bannerURL)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: 225)
    }
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
             if let index = collectionView.indexPath(for: cell) {
                self.pageControll.currentPage = index.row
            }
        }
    }
}
