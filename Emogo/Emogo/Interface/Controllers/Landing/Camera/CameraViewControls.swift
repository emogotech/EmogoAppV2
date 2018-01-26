//
//  CameraViewControls.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//


import Foundation
import UIKit


// MARK: - ENUM'S

enum FlashOptions:String {
    case on = "flash_yellow_icon"
    case off = "flash_white_icon_inactive"
    case auto = "flash-icon"
}

enum CameraAction:String {
    case capture = "camera"
    case stop = "stop"
    case record = "record"
    case recording = "recording"
    case timer = "timer"
}


extension CustomCameraViewController {
    
    
    // MARK: - TIMER FUNCTIONALITY
    
    // MARK: - schedule timer

   func captreIn(time:Int) {
        timeSec = time
      self.disable(isOn:false)
        self.lblRecordTimer.isHidden = false
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(CustomCameraViewController.countDown)), userInfo: nil, repeats: true)
    }
    
    // MARK: - Show CountDown

    @objc func countDown(){
        self.viewFlashOptions.isHidden = true
        if timeSec < 1 {
            timer.invalidate()
            self.lblRecordTimer.isHidden = true
            self.disable(isOn:true)
            takePhoto()
        } else {
            beepSound?.play { completed in
                print("completed: \(completed)")
            }
            timeSec -= 1
            lblRecordTimer.text = timeString(time: TimeInterval(timeSec),inSeconds: true)
        }
    }
    
    
    // MARK: - RECORDING FUNCTIONALITY
    
    // MARK: - Perform  camera Actions

    func performCamera(action:CameraAction) {
        switch action {
        case .capture:
            takePhoto()
            break
        case .record:
            print("prepare for record")
            break
        case .stop:
            stopVideoRecording()
            break
        case .recording:
            startVideoRecording()
            break
        case .timer:
            self.captreIn(time: captureInSec!)
            captureInSec = nil
            break
        }
    }
    
    // MARK: - Record Button Status

//    func recordButtonTapped(isShow:Bool){
//        isCaptureMode = false
//        self.btnGallery.isHidden = isShow
//        self.btnRecording.isHidden = isShow
//        self.btnFlash.isHidden = isShow
//        self.btnShutter.isHidden = isShow
//        self.btnTimer.isHidden = isShow
//        if isShow == true {
//            self.btnCamera.setImage(#imageLiteral(resourceName: "video_play"), for: .normal)
//        }else {
//            self.btnCamera.setImage(#imageLiteral(resourceName: "capture-icon"), for: .normal)
//            isCaptureMode = true
//        }
//    }
    
    // MARK: -  Update Buttons

    func updateButtonStatus(isEnable:Bool) {
        self.btnCamera.isUserInteractionEnabled = isEnable
        self.btnGallery.isUserInteractionEnabled = isEnable
        self.btnRecording.isUserInteractionEnabled = isEnable
        self.btnShutter.isUserInteractionEnabled = isEnable
        self.btnTimer.isUserInteractionEnabled = isEnable
    }
    
    
    // MARK: -  Update Record time

    @objc func updateRecordingTime(){
        timeSec += 1
        lblRecordTimer.text = timeString(time: TimeInterval(timeSec),inSeconds: false)
    }
    
  
    // MARK: - FLASH FUNCTIONALITY
   
    func flashOption(options:FlashOptions){
        
        switch options {
        case .auto:
            flashEnabled = false
            self.btnFlashOn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.btnFlashOff.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.btnFlashAuto.setTitleColor(#colorLiteral(red: 0.9960784314, green: 0.8196078431, blue: 0.3254901961, alpha: 1), for: .normal)
            btnFlash.setImage( UIImage(named: FlashOptions.auto.rawValue), for: .normal)
          //  self.viewFlashOptions.swipeToUp(height: 20)
            break
        case .on:
            flashEnabled = true
            self.btnFlashAuto.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.btnFlashOff.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.btnFlashOn.setTitleColor(#colorLiteral(red: 0.9960784314, green: 0.8196078431, blue: 0.3254901961, alpha: 1), for: .normal)
            btnFlash.setImage( UIImage(named: FlashOptions.on.rawValue), for: .normal)
          //  self.viewFlashOptions.swipeToUp(height: 20)
            break
        case .off:
            flashEnabled = false
            self.btnFlashAuto.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.btnFlashOn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.btnFlashOff.setTitleColor(#colorLiteral(red: 0.9960784314, green: 0.8196078431, blue: 0.3254901961, alpha: 1), for: .normal)
            btnFlash.setImage( UIImage(named: FlashOptions.off.rawValue), for: .normal)
         //   self.viewFlashOptions.swipeToUp(height: 20)
            break
        }
        self.viewFlashOptions.isHidden = true
        self.isFlashClicked = false
    }
    
    // MARK: -  Disable Interaction
    
    func disable(isOn:Bool) {
    self.btnFlash.isUserInteractionEnabled = isOn
    self.btnCamera.isUserInteractionEnabled = isOn
    self.btnRecording.isUserInteractionEnabled = isOn
    self.btnGallery.isUserInteractionEnabled = isOn
    self.btnShutter.isUserInteractionEnabled = isOn
    self.btnTimer.isUserInteractionEnabled = isOn
    }

    
    // MARK: -  Convert Time
    
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
}
