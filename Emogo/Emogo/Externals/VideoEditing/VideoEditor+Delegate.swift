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
        player.seek(playerTime.seconds)
        player.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player.pause()
        player.seek(playerTime.seconds)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        print(duration)
    }
    
    
}
