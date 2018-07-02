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
        
        if self.isEdit != nil {
            if let editedFileURL = editedFileURL {
                     self.localFileURl = editedFileURL
                    if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:editedFileURL,isSave:false) {
                        let camera = ContentDAO(contentData: [:])
                        camera.type = .video
                        camera.imgPreview = image
                        camera.fileName = self.localFileURl?.absoluteString.getName()
                        camera.fileUrl = localFileURl
                        camera.isUploaded = false
                        camera.name = txtTitleImage.text
                        camera.description = txtDescription.text
                        if self.delegate != nil {
                            self.delegate?.saveEditing(image: camera)
                        }
                        self.navigationController?.popViewAsDismiss()
                    }
            }
        }else {
            HUDManager.sharedInstance.showHUD()
            
            if self.isForEditOnly == false {
                if let editedFileURL = editedFileURL {
                    self.localFileURl = editedFileURL
                    self.uploadFile()
                }
            }else {
                self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: self.seletedImage.coverImageVideo, type: self.seletedImage.type.rawValue, width: self.seletedImage.width, height: self.seletedImage.height)
            }
        }
        
    }
    
    @objc func actionForRightMenu(sender:UIButton) {
        if self.localFileURl == nil {
            return
        }
        if stickersVCIsVisible {
            removeStickersView()
        }
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
            self.canvasImageView.isUserInteractionEnabled = true
            configureNavigationForTextEditing()
            self.prepareForTextEditing()
            break
        default:
            break
        }
    }
    
    
    @objc func btnSaveAction(){
        if let url = self.localFileURl {
            if let _ = SharedData.sharedInstance.videoPreviewImage(moviePath:url,isSave:true) {
                self.showToast(type: .error, strMSG: kAlert_Save_Video)
            }
            
        }
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
        self.colorsCollectionView.isHidden = true
        self.canvasImageView.isUserInteractionEnabled = true
        self.player.isUserInteractionEnabled = true
        self.playerContainerView.isUserInteractionEnabled = true
        configureNavigationForEditing()
    }
    @objc func btnClearAction(){
        self.configureNavigationButtons()
        self.updatePlayerAsset(videURl:self.originalFileURl!)
        self.editedFileURL = self.originalFileURl!
    }
    
    @objc func btnCancelAction(){
        self.isForEditOnly = true
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == false {
            edgeMenu.open()
        }
          let subview = self.canvasImageView.subviews
        if subview.count != 0 {
            for obj in self.canvasImageView.subviews {
                obj.removeFromSuperview()
            }
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
             closePreview()
        }else if self.selectedFeature == .sticker {
            addStickerOnvideo()
        }else if self.selectedFeature == .text {
            addTextonvideo()
        }else if self.selectedFeature == .resolution {
            if let editedFileURL = editedFileURL {
                self.localFileURl = editedFileURL
            }
        }
        self.viewDescription.isHidden = false
    }
    
   
    
}
