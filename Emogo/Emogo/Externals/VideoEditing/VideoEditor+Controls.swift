//
//  VideoEditor+Controls.swift
//  Emogo
//
//  Created by Pushpendra on 15/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import AVFoundation

extension VideoEditorViewController {
    
    
    @IBAction func saveEditedVideoButtonTapped(_ sender: Any) {
        
             HUDManager.sharedInstance.showHUD()
        
            if self.isForEditOnly == false {
                self.uploadFile()
            }else {
                self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: self.seletedImage.coverImageVideo, type: self.seletedImage.type.rawValue, width: self.seletedImage.width, height: self.seletedImage.height)
            }
        
    }
    
    @objc func actionForRightMenu(sender:UIButton) {
        self.viewDescription.isHidden = true
        switch sender.tag {
        case 101:
            self.configureNavigationForEditing()
            selectedFeature = VideoEditorFeature.trimer
            self.loadAssest()
            break
        case 102:
            selectedFeature = VideoEditorFeature.sticker
            self.canvasImageView.isUserInteractionEnabled = true
            self.addStickersViewController()
            break
        case 103:
             removeAllNavButtons()
             selectedFeature = VideoEditorFeature.resolution
            self.prepareAlertForResolution()
            break
        case 104:
            selectedFeature = VideoEditorFeature.rate
            removeAllNavButtons()
            self.prepareForPlayRate()
            break
        case 105:
            selectedFeature = VideoEditorFeature.text
            self.canvasImageView.isUserInteractionEnabled = false
            configureNavigationForTextEditing()
            self.prepareForTextEditing()
            break
        default:
            break
        }
    }
    
    
    @objc func btnSaveAction(){
        if let editedFileURL = editedFileURL {
            self.localFileURl = editedFileURL
            self.isForEditOnly = false
        }
        self.viewDescription.isHidden = false
    }
    
    @objc func buttonBackAction(){
        if self.delegate != nil {
            self.delegate?.cancelEditing()
        }
        self.navigationController?.popViewAsDismiss()
    }
    @objc func btnTextEditingDone(){
        self.view.endEditing(true)
        self.colorPickerView.isHidden = true
        self.canvasImageView.isUserInteractionEnabled = true
        configureNavigationForEditing()
    }
    
    @objc func btnCancelAction(){
        self.isForEditOnly = true
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == false {
            edgeMenu.open()
        }
        configureNavigationButtons()
        if self.selectedFeature == VideoEditorFeature.sticker {
            self.canvasImageView.subviews.forEach({ $0.removeFromSuperview() })
            self.canvasImageView.isHidden = true
        }
        if self.avPlayer != nil {
            self.avPlayer?.pause()
            self.playerContainerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            self.avPlayer = nil
            self.closePreview()
            self.updateAsset(videoUrl: self.localFileURl!, type: self.selectedFeature)
        }
        self.editedFileURL = nil
        self.updatePlayerAsset(videURl: self.localFileURl!)
        self.viewDescription.isHidden = false
    }
    
    @objc func btnApplyFeatureAction(){
        self.isForEditOnly = false
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == false {
            edgeMenu.open()
        }
        configureNavigationButtons()
        if self.selectedFeature == .trimer {
          trimVideo()
        }else if self.selectedFeature == .sticker {
            addStickerOnvideo()
        }else if self.selectedFeature == .text {
            addTextonvideo()
        }
        self.viewDescription.isHidden = false
    }
    
    func trimVideo(){
        self.showActivity()
        self.editManager.trimVideo(path: self.localFileURl!, begin: self.trimmerView.startTime!, end: self.trimmerView.endTime!, progress: { (progress, strProgress) in
            print("progrss---->\(progress)")
            print("strProgress---->\(progress)")
            
        }, finish: { (fileUrl, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.updateAsset(videoUrl: fileUrl!, type: self.selectedFeature)
                }
            }
        })
    }
    
}
