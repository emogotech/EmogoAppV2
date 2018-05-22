//
//  VideoEditor+TextEmoji.swift
//  Emogo
//
//  Created by Pushpendra on 22/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
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
        let size = CGSize(width: 150, height: 150)
        self.editManager.addContentToVideo(path: self.localFileURl!, boundingSize: size, contents: self.canvasImageView.subviews, progress: {(progress, strProgress) in
            print("progrss---->\(progress)")
            print("strProgress---->\(progress)")
        }) { (fileURL, error) in
            
            if let fileURL = fileURL {
                DispatchQueue.main.async {
                    self.canvasImageView.subviews.forEach({ $0.removeFromSuperview() })
                    //self.canvasImageView.isHidden = true
                    self.updatePlayerAsset(videURl: fileURL)
                }
            }
        }
    }
    
}


