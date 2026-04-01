//
//  VideoCell.swift
//  ZiingoPrime
//
//  Created by MAC-PRO2018 on 14/04/25.
//

import UIKit
import AVKit
import AVFoundation

class VideoCell: UICollectionViewCell {
    
    static let identifier = "VideoCell"
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
     let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
       button.setImage(UIImage(named: "pause_new"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.8
      //  button.isHidden = true
        return button
    }()
    
    private var isPlaying = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(playPauseButton)
        setupConstraints()
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        
      //  playPauseButton.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        isPlaying = true
        
        playPauseButton.setImage(UIImage(named: "pause_new"), for: .normal)
        playPauseButton.tintColor = .white
        
    }
    
    func configure(with url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = contentView.bounds
        playerLayer?.videoGravity = .resizeAspect
        if let layer = playerLayer {
            contentView.layer.insertSublayer(layer, at: 0)
        }
        play()
    }
    func play() {
        // If we're at the end of the video, restart from beginning
        if let player = player, player.currentItem?.duration == player.currentTime() {
            player.seek(to: CMTime.zero)
        }
        
        player?.play()
        isPlaying = true
        playPauseButton.setImage(UIImage(named: "pause_new"), for: .normal)
        playPauseButton.tintColor = .white
    }

    func pause() {
        player?.pause()
        isPlaying = false
        playPauseButton.setImage(UIImage(named: "Play Image"), for: .normal)
        playPauseButton.isHidden = false
    }

    @objc private func didTapPlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    // Add this when setting up your player to detect when video finishes
    private func setupPlayerObservers() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(playerDidFinishPlaying),
                                             name: .AVPlayerItemDidPlayToEndTime,
                                             object: player?.currentItem)
    }

    @objc private func playerDidFinishPlaying(note: NSNotification) {
        // When video finishes, pause and reset to beginning
        pause()
        player?.seek(to: CMTime.zero)
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

