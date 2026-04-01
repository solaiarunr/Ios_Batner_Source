//
//  ImageAndVideoCell.swift
//  ZiingoPrime
//
//  Created by MAC-PRO2018 on 14/04/25.
//

import UIKit

class ImageAndVideoCell: UICollectionViewCell, UIScrollViewDelegate {
    
    
    static let identifier = "ImageCell"
       
       private let scrollView = UIScrollView()
       private let imageView = UIImageView()
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           scrollView.delegate = self
           scrollView.minimumZoomScale = 1.0
           scrollView.maximumZoomScale = 5.0
           scrollView.frame = contentView.bounds
           contentView.addSubview(scrollView)

           imageView.contentMode = .scaleAspectFit
           imageView.frame = scrollView.bounds
           scrollView.addSubview(imageView)
       }
       
       required init?(coder: NSCoder) { fatalError() }
       
       func configure(with url: URL) {
           imageView.sd_setImage(with: url)
           scrollView.setZoomScale(1.0, animated: false)
       }
       
       func viewForZooming(in scrollView: UIScrollView) -> UIView? {
           return imageView
       }
}
