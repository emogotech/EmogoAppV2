//
//  CameraViewControls.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//


import Foundation
import UIKit
import RS3DSegmentedControl
import Lightbox

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

enum CameraMode:String {
    case normal = "1"
    case handFree = "2"
}

extension CustomCameraViewController {
    
    
    // MARK: - TIMER FUNCTIONALITY
    
    // MARK: - schedule timer

   func captreIn(time:Int) {
        timeSec = time
     self.lblRecordTimer.text = "00"
      self.disable(isOn:false)
        self.lblRecordTimer.isHidden = false
    self.navigationItem.rightBarButtonItem  = nil
    self.navigationItem.leftBarButtonItem  = nil
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
            self.setupButtonWhileRecording(isAddButton: true)
        } else {
            beepSound?.play { completed in
               // print("completed: \(completed)")
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
            //print("prepare for record")
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
//        self.isRecording = true
//        self.btnGallery.isHidden = isShow
//        self.btnRecording.isHidden = isShow
//        self.btnFlash.isHidden = isShow
//        self.btnTimer.isHidden = isShow
//        prepareNavBarButtons()
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
//        self.btnRecording.isUserInteractionEnabled = isEnable
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
//    self.btnRecording.isUserInteractionEnabled = isOn
    self.btnGallery.isUserInteractionEnabled = isOn
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
    
    func openFullView(index:Int){
        self.navigationItem.rightBarButtonItem = nil
        var arrayContents = [LightboxImage]()
        for obj in ContentList.sharedInstance.arrayContent {
            var image:LightboxImage!
            let text = obj.name + "\n" +  obj.description
            
            if obj.type == .image {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: text.trim(), videoURL: nil)
                }else{
                    let url = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: nil)
                }
            }else if  obj.type == .video {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: text.trim(), videoURL: obj.fileUrl)
                }else {
                    let url = URL(string: obj.coverImageVideo)
                    let videoUrl = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: videoUrl!)
                }
            }
            arrayContents.append(image)
        }
        let controller = LightboxController(images: arrayContents, startIndex: index)
        controller.dynamicBackground = true
   
        present(controller, animated: true) {
            let buttonNext   = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
            buttonNext.setImage(#imageLiteral(resourceName: "share_button"), for: .normal)
            buttonNext.addTarget(self, action: #selector(self.previewScreenNavigated), for: .touchUpInside)
            buttonNext.contentHorizontalAlignment  = .right
            buttonNext.contentVerticalAlignment = .bottom
            let btnNext = UIBarButtonItem(customView: buttonNext)
            // let btnNext = UIBarButtonItem(image: #imageLiteral(resourceName: "share_button"), style: .plain, target: self, action: #selector(self.previewScreenNavigated))
            self.navigationItem.rightBarButtonItem = btnNext
        }
    //    present(controller, animated: true, completion: nil)
}
}



extension CustomCameraViewController:RS3DSegmentedControlDelegate {
    
    func updateCameraType(index:Int) {
        switch index {
        case 0:
            self.cameraMode = .normal
            
            UIView.animate(withDuration: 0.2, animations: {
                self.btnGallery.alpha    =   1.0
                self.btnTimer.alpha      =   1.0
            }, completion: { (success) in
                self.btnGallery.isHidden    =   false
                self.btnTimer.isHidden      =   false
            })
            
            break
        case 1:
            self.cameraMode = .handFree
            
            UIView.animate(withDuration: 0.2, animations: {
                self.btnGallery.alpha    =   0.0
                self.btnTimer.alpha      =   0.0
            }, completion: { (success) in
                self.btnGallery.isHidden    =   true
                self.btnTimer.isHidden      =   true
            })
            
            break
        default:
            self.cameraMode = .normal
            
            UIView.animate(withDuration: 0.2, animations: {
                self.btnGallery.alpha    =   1.0
                self.btnTimer.alpha      =   1.0
            }, completion: { (success) in
                self.btnGallery.isHidden    =   false
                self.btnTimer.isHidden      =   false
            })
            
        }
    }

    func number(ofSegmentsIn3DSegmentedControl segmentedControl: RS3DSegmentedControl!) -> UInt {
        return 2
    }
    
    func titleForSegment(at segmentIndex: UInt, segmentedControl: RS3DSegmentedControl!) -> String! {
        return ["NORMAL","HANDS-FREE"][Int(segmentIndex)]
    }
    
    func didSelectSegment(at segmentIndex: UInt, segmentedControl: RS3DSegmentedControl!) {
        switch Int(segmentIndex) {
        case 0:
            self.cameraMode = .normal
            
            UIView.animate(withDuration: 0.2, animations: {
                self.btnGallery.alpha    =   1.0
                self.btnTimer.alpha      =   1.0
            }, completion: { (success) in
             //   self.btnGallery.isHidden    =   false
              //  self.btnTimer.isHidden      =   false
            })
            
            break
        case 1:
            self.cameraMode = .handFree
            
            UIView.animate(withDuration: 0.2, animations: {
                self.btnGallery.alpha    =   0.0
                self.btnTimer.alpha      =   0.0
            }, completion: { (success) in
             //   self.btnGallery.isHidden    =   true
            //    self.btnTimer.isHidden      =   true
            })
            
            break
        default:
            self.cameraMode = .normal
            
            UIView.animate(withDuration: 0.2, animations: {
                self.btnGallery.alpha    =   1.0
                self.btnTimer.alpha      =   1.0
            }, completion: { (success) in
               // self.btnGallery.isHidden    =   false
              //  self.btnTimer.isHidden      =   false
            })
            
        }
    }
    
    
    
}
