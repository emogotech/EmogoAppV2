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
        
    }

}

extension VideoEditorViewController: StickersViewControllerDelegate {
    func didSelectView(view: UIView) {
        
    }
    
    func didSelectImage(image: UIImage) {
        
    }
    
    func stickersViewDidDisappear() {
        
    }
        
}

