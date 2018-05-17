//
//  VideoEditor+Resolution.swift
//  Emogo
//
//  Created by Pushpendra on 16/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import AVFoundation
import BMPlayer

extension VideoEditorViewController {
    
    
    func prepareAlertForResolution(){
        
        let alert = UIAlertController(title: "Video Quality", message: nil, preferredStyle: .actionSheet)
        let low = UIAlertAction(title: "Low Quality", style: .destructive) { (action) in
            self.updateViderResolution(strResoultion: AVAssetExportPresetLowQuality)
        }
        let medium = UIAlertAction(title: "Medium Quality", style: .destructive) { (action) in
            self.updateViderResolution(strResoultion: AVAssetExportPresetMediumQuality)

        }
        let high = UIAlertAction(title: "High Quality", style: .destructive) { (action) in
            self.updateViderResolution(strResoultion: AVAssetExportPresetHighestQuality)
        }
        
        let q640 = UIAlertAction(title: "640x480", style: .destructive) { (action) in
            self.updateViderResolution(strResoultion: AVAssetExportPreset640x480)
        }
        let q960 = UIAlertAction(title: "960x540", style: .destructive) { (action) in
            self.updateViderResolution(strResoultion: AVAssetExportPreset960x540)
        }
        let q1280 = UIAlertAction(title: "1280x720", style: .destructive) { (action) in
            self.updateViderResolution(strResoultion: AVAssetExportPreset1280x720)
        }
        
        let q1920 = UIAlertAction(title: "1920x1080", style: .destructive) { (action) in
            self.updateViderResolution(strResoultion: AVAssetExportPreset1920x1080)
        }
        let q3840 = UIAlertAction(title: "3840x2160", style: .destructive) { (action) in
            self.updateViderResolution(strResoultion: AVAssetExportPreset3840x2160)
        }
        
        let cancel = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(low)
        alert.addAction(medium)
        alert.addAction(high)
        alert.addAction(q640)
        alert.addAction(q960)
        alert.addAction(q1280)
        alert.addAction(q1920)
        alert.addAction(q3840)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func updateViderResolution(strResoultion:String){
        self.editManager.optimizeVideo(path: self.localFileURl!, exportPreset: strResoultion, fps: 0, progress: { (_, _) in
            
        }, finish: { (fileURL, error) in
            DispatchQueue.main.async {
                if let fileURL = fileURL {
                    self.updatePlayerAsset(videURl:fileURL)
                }
            }
        })
    }
    
    func updatePlayerAsset(videURl:URL) {
        if self.player.isPlaying {
            self.player.pause()
        }
        let asset = BMPlayerResource(url: videURl)
        player.setVideo(resource: asset)
        player.play()
    }
}
