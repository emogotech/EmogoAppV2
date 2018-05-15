//
//  PhotoEditor+API.swift
//  Emogo
//
//  Created by Pushpendra on 14/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation

extension PhotoEditorViewController {
 
    func updateContent(){
        // Update Content
        HUDManager.sharedInstance.showHUD()
        if self.seletedImage.imgPreview != nil {
            self.uploadFile()
        }else {
            //   self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: "", type: self.seletedImage.type.rawValue)
            self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: self.seletedImage.coverImageVideo, type: self.seletedImage.type.rawValue, width: self.seletedImage.width, height: self.seletedImage.height)
        }
    }
    
    
    func uploadFile(){
        // Create a object array to upload file to AWS
        self.deleteFileFromAWS(content: self.seletedImage)
        let fileName = NSUUID().uuidString + ".png"
        AWSRequestManager.sharedInstance.imageUpload(image: self.seletedImage.imgPreview!, name: fileName) { (imageURL, error) in
            if error == nil {
                DispatchQueue.main.async { // Correct
                    self.seletedImage.coverImage = imageURL
                    self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: self.seletedImage.coverImageVideo, type: self.seletedImage.type.rawValue, width:Int((self.seletedImage.imgPreview?.size.width)!)
                        , height: Int((self.seletedImage.imgPreview?.size.height)!))
                    self.seletedImage.imgPreview = nil
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
    
    
    func updateContent(coverImage:String,coverVideo:String, type:String,width:Int,height:Int){
        APIServiceManager.sharedInstance.apiForEditContent(contentID: self.seletedImage.contentID, contentName: self.seletedImage.name, contentDescription: txtDescription.text!, coverImage: coverImage, coverImageVideo: coverVideo, coverType: type, width: width, height: height) { (content, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                
                if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == content?.contentID.trim()}) {
                    self.seletedImage = content
                    ContentList.sharedInstance.arrayContent[index] = content!
                }
                self.photoEditorDelegate?.doneEditing(image: self.seletedImage)
                self.navigationController?.popViewAsDismiss()
                // update data after saving and navigate back
                
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func deleteFileFromAWS(content:ContentDAO){
        if !content.coverImage.isEmpty {
            AWSManager.sharedInstance.removeFile(name: content.coverImage.getName(), completion: { (isDeleted, error) in
            })
        }
        if !content.coverImageVideo.isEmpty {
            AWSManager.sharedInstance.removeFile(name: content.coverImageVideo.getName(), completion: { (isDeleted, error) in
            })
        }
    }
    
}
