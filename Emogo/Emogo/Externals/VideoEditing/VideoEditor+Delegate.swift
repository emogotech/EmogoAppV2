//
//  VideoEditor+Delegate.swift
//  Emogo
//
//  Created by Pushpendra on 15/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import BMPlayer
import UIKit
import PryntTrimmerView
import AVFoundation

extension VideoEditorViewController: TrimmerViewDelegate {
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        avPlayer?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        avPlayer?.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        avPlayer?.pause()
        avPlayer?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        print(duration)
    }
    
    
}


extension VideoEditorViewController: ColorDelegate {
    
    func didSelectColor(color: UIColor){
        print(activeTextView)
        activeTextView?.textColor = color
        textColor = color
    }

}

extension VideoEditorViewController: StickersViewControllerDelegate {
    func didSelectView(view: UIView) {
        self.canvasImageView.isHidden = false
        view.center = canvasImageView.center
        view.tag = 112
        self.canvasImageView.addSubview(view)
        self.removeStickersView()
        addGestures(view: view)
        self.configureNavigationForEditing()
    }
    
    func didSelectImage(image: UIImage) {
        self.canvasImageView.isHidden = false
        let imageView = UIImageView(image: image)
        imageView.tag = 111
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = canvasImageView.center
        self.canvasImageView.addSubview(imageView)
        //Gestures
        self.removeStickersView()
        addGestures(view: imageView)
        self.configureNavigationForEditing()
    }
    
    func stickersViewDidDisappear() {
        stickersVCIsVisible = false
    }
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.panGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(self.pinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(self.rotationGesture(_:)) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
        
}

