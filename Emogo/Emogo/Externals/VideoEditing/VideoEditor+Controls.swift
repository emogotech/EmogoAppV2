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
    
    
    @objc func actionForRightMenu(sender:UIButton) {
        switch sender.tag {
        case 101:
            self.configureNavigationForEditing()
            selectedFeature = VideoEditorFeature.trimer
            self.loadAssest()
            break
        case 102:
            break
        case 103:
             removeAllNavButtons()
            self.prepareAlertForResolution()
            break
        case 104:
            break
        default:
            break
        }
    }
    
    
    @objc func btnSaveAction(){
        
      
    }
    
    @objc func buttonBackAction(){
        self.navigationController?.popViewAsDismiss()
    }
    
    
    @objc func btnCancelAction(){
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == false {
            edgeMenu.open()
        }
        configureNavigationButtons()
        if self.avPlayer != nil {
            self.avPlayer?.pause()
            self.playerContainerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            self.avPlayer = nil
            self.closePreview()
            self.updateAsset(videoUrl: self.localFileURl!, type: self.selectedFeature)
        }
    }
    
    @objc func btnApplyFeatureAction(){
        
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == false {
            edgeMenu.open()
        }
        configureNavigationButtons()
        if self.selectedFeature == .trimer {
         
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
    
    
}
