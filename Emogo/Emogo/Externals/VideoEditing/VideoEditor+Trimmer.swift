//
//  VideoEditor+Trimmer.swift
//  Emogo
//
//  Created by Pushpendra on 16/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import BMPlayer
import PryntTrimmerView
import AVFoundation

extension VideoEditorViewController {
    
    
    func loadAssest(){
        self.kTrimmerHeight.constant = 60.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            print(self.trimmerView)
            let strvideo = self.fileLocalPath
            let videoUrl = URL(fileURLWithPath: strvideo!)
            let asset = AVAsset(url: videoUrl)
            self.trimmerView.delegate = self
            self.trimmerView.asset = asset
            if self.player.isPlaying {
                self.player.pause()
            }
            self.player.removeFromSuperview()
            self.addVideoPlayer(with: asset, playerView: self.playerContainerView)
        }
    }
    
    
    func updateAsset(videoUrl:URL,type:VideoEditorFeature){
        if self.avPlayer != nil {
            self.avPlayer?.pause()
            self.playerContainerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            self.avPlayer = nil
            self.closePreview()
        }
        self.hideActivity()
        self.editedFileURL = videoUrl
        self.openPlayer(videoUrl: videoUrl)
    }
    
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            avPlayer?.seek(to: startTime)
        }
    }
    
    
    
    @objc func onPlaybackTimeChecker() {
        
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = avPlayer else {
            return
        }
        
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            trimmerView.seek(to: startTime)
        }
    }
    
    
    func startPlaybackTimeChecker() {
        
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(self.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        self.avPlayer = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
        self.avPlayer?.play()
    }
    
    
}
