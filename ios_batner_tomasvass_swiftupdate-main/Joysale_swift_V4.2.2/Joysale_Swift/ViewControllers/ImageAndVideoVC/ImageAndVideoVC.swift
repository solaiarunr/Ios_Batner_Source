//
//  ImageAndVideoVC.swift
//  ZiingoPrime
//
//  Created by MAC-PRO2018 on 14/04/25.
//

import UIKit

enum MediaType {
    case image(URL)
    case video(URL)
}


class ImageAndVideoVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var closebtn: UIButton!
    
    private weak var currentlyPlayingVideoCell: VideoCell?

    
     var items: [MediaType] = []
    var startIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCollectionView()

//        // Sample items
//        items = [
//            .image(UIImage(named: "withdraw_img")!),
//            .video(URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4")!),
//            .image(UIImage(named: "withdraw_img")!)
//        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handleVideoPlayback()
    }
    
    
    @IBAction func closebtnAct(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only scroll once
        if collectionView.contentOffset == .zero && startIndex < items.count {
            let indexPath = IndexPath(item: startIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
          //  handleVideoPlayback() // Optional: Start correct video
        }
    }

    
    
    private func setupCollectionView() {
         
        

     //   collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(ImageAndVideoCell.self, forCellWithReuseIdentifier: ImageAndVideoCell.identifier)
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
       // view.addSubview(collectionView)
    }

    // MARK: - Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = items[indexPath.item]
        switch media {
        case .image(let url):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageAndVideoCell.identifier, for: indexPath) as! ImageAndVideoCell
            cell.configure(with: url)
            return cell
        case .video(let url):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
            cell.configure(with: url)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    // MARK: - Auto Play/Pause for Videos

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleVideoPlayback()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        handleVideoPlayback()
    }
    
    private func handleVideoPlayback() {
        // Pause the previously playing cell (even if it's off screen)
        currentlyPlayingVideoCell?.pause()
        currentlyPlayingVideoCell = nil

        // Find and play the new video cell
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else { continue }
            let media = items[indexPath.item]

            if let videoCell = cell as? VideoCell, case .video = media {
                videoCell.play()
                currentlyPlayingVideoCell = videoCell
                break // Only play the first visible video
            }
        }
    }



}
