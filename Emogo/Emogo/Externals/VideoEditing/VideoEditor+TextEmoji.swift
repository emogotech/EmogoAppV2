//
//  VideoEditor+TextEmoji.swift
//  Emogo
//
//  Created by Pushpendra on 22/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import AVFoundation

extension VideoEditorViewController  {
    
    
    func addStickersViewController() {
        
        stickersVCIsVisible = true
        stickersViewController.stickersViewControllerDelegate = self
        for image in self.stickers {
            stickersViewController.stickers.append(image)
        }
        self.addChildViewController(stickersViewController)
        self.view.addSubview(stickersViewController.view)
        stickersViewController.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        stickersViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeStickersView() {
       
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.stickersViewController.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.stickersViewController.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.stickersViewController.view.removeFromSuperview()
            self.stickersViewController.removeFromParentViewController()
            
        })
    }
    
    func addStickerOnvideo(){
        if self.player.isPlaying {
            self.player.pause()
        }
          let subview = self.canvasImageView.subviews
          let view = subview[0]
          let imageView = UIImageView(image: UIImage.image(view))
           imageView.backgroundColor = .clear
          imageView.frame = view.frame
        if let videoSize = self.resolutionSizeForLocalVideo(url: self.localFileURl!) {
            print(self.canvasImageView.bounds.size)
            print(imageView.frame)
            print(videoSize)
            print(videoSize.height/self.canvasImageView.bounds.size.height)
            print(videoSize.width/self.canvasImageView.bounds.size.width)
            print(self.canvasImageView.bounds.size.height-videoSize.height)
            print(self.canvasImageView.bounds.size.width-videoSize.width)

            let valueY = imageView.frame.origin.y - (self.canvasImageView.bounds.size.height-videoSize.height)
            let valueX = imageView.frame.origin.x - (self.canvasImageView.bounds.size.width-videoSize.width)
            print(valueY)
            print(valueX)
            imageView.center = CGPoint(x: valueX, y: valueY)
        }
        self.canvasImageView.isHidden = true
        self.editManager.addContentToVideo(path: self.localFileURl!, boundingSize: view.bounds.size, contents: [imageView], progress: {(progress, strProgress) in
        }) { (fileURL, error) in
            
            if let fileURL = fileURL {
                DispatchQueue.main.async {
                    self.canvasImageView.subviews.forEach({ $0.removeFromSuperview() })
                    self.updatePlayerAsset(videURl: fileURL)
                }
            }
        }
    }
    
    
    func resolutionSizeForLocalVideo(url:URL) -> CGSize? {
        
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
}


