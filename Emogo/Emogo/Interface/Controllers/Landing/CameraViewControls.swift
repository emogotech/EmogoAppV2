//
//  CameraViewControls.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit


extension CameraViewController {
    
    
   func captreIn(time:Int) {
        timeSec = time
        self.lblRecordTimer.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(CameraViewController.countDown)), userInfo: nil, repeats: true)
    }
    
    @objc func updateRecordingTime(){
        timeSec += 1
        lblRecordTimer.text = timeString(time: TimeInterval(timeSec),inSeconds: false)
    }
    
    @objc func countDown(){
        if timeSec < 1 {
            timer.invalidate()
            self.lblRecordTimer.isHidden = true
            takePhoto()
        } else {
            beepSound?.play { completed in
                print("completed: \(completed)")
            }
            timeSec -= 1
            lblRecordTimer.text = timeString(time: TimeInterval(timeSec),inSeconds: true)
        }
    }
    
    func timeString(time:TimeInterval, inSeconds:Bool) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        if inSeconds == true {
            return String(format:"%02i", seconds)
        }else {
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }
    }
    
     func updateButtonStatus(isEnable:Bool) {
        self.btnCamera.isUserInteractionEnabled = isEnable
        self.btnGallery.isUserInteractionEnabled = isEnable
        self.btnRecording.isUserInteractionEnabled = isEnable
        self.btnShutter.isUserInteractionEnabled = isEnable
        self.btnTimer.isUserInteractionEnabled = isEnable
    }
}
