//
//  BannerDetailsViewController.swift
//  Joysale_Swift
//
//  Created by Hitasoft on 17/07/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import UIKit

class BannerDetailsViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var transactionIDLabel: UILabel!
    @IBOutlet weak var transactionIDTitleLabel: UILabel!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var paidAmountTitleLabel: UILabel!
    @IBOutlet weak var topViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var pageView: UIView!
    var selectedAd: AdHistoryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    func configUI() {
        self.pageView.cornerViewRadius()
        self.navigationController?.customNavigationBarView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)

        self.photoLabel.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.paidAmountTitleLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "Paid_amount")
        self.paidAmountLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.transactionIDTitleLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "Transaction_id")
        self.transactionIDLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.durationTitleLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "up_to")
        self.durationLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .left, text: "")
        self.statusTitleLabel.config(color: UIColor(named: "SecondaryTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "Status")
        self.statusLabel.config(color: UIColor(named: "AppTextColor"), font: UIFont(name: APP_FONT_REGULAR, size: 14), align: .left, text: "")
        self.collectionView.register(UINib(nibName: "ItemDetailsImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemDetailsImageCollectionViewCell")
        self.loadData()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.updateStatusBarStyle()
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
    func loadData() {
        self.paidAmountLabel.text = self.selectedAd?.formattedPrice ?? ""
        self.transactionIDLabel.text = self.selectedAd?.transactionId ?? ""
        if (self.selectedAd?.approveStatus ?? "") == "approved" {
            self.statusLabel.text = getLanguage["approved"] ?? ""
            self.statusLabel.textColor = UIColor(named: "green_color")
        }
        else if (self.selectedAd?.approveStatus ?? "") == "Pending" {
            self.statusLabel.text = getLanguage["pending"] ?? ""
            self.statusLabel.textColor = UIColor(named: "bluecolor")
        }
        else {
            self.statusLabel.text = (self.selectedAd?.approveStatus ?? "")
            self.statusLabel.textColor = UIColor(named: "redcolor")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: (self.selectedAd?.postedDate ?? "0")) {
            formatter.dateFormat = "MMM dd, YYYY"
            let postedDate = formatter.string(from: date)
            print(date)  // Prints:  2018-12-10 06:00:00 +0000
            self.title = postedDate
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let startDate = formatter.date(from: (self.selectedAd?.startDate ?? "0")),let endDate = formatter.date(from: (self.selectedAd?.endDate ?? "0")) {
            formatter.dateFormat = "MMM dd, YYYY"
            let sDate = formatter.string(from: startDate)
            let lDate = formatter.string(from: endDate)
            self.durationLabel.text = "\(sDate) \(getLanguage["on"] ?? "") \(lDate)"
        }
        self.photoLabel.text = "1/2"
    }
}
extension BannerDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemDetailsImageCollectionViewCell", for: indexPath) as! ItemDetailsImageCollectionViewCell
        if indexPath.row == 0 {
            cell.itemImageView.sd_setImage(with: URL(string: self.selectedAd?.webBannerUrl ?? ""), placeholderImage: nil , completed: nil)
        }
        else {
            cell.itemImageView.sd_setImage(with: URL(string: self.selectedAd?.appBannerUrl ?? ""), placeholderImage: nil , completed: nil)

        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.collectionView.bounds.height)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.collectionView.contentOffset.x >= self.view.frame.width {
            self.photoLabel.text = "2/2"
        }
        else {
            self.photoLabel.text = "1/2"
        }
    }
}
