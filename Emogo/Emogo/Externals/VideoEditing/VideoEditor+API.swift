//
//  VideoEditor+API.swift
//  Emogo
//
//  Created by Pushpendra on 28/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import Foundation

extension VideoEditorViewController {
    
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
        if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:self.localFileURl!,isSave:true) {
            self.deleteFileFromAWS(content: self.seletedImage)
            let content = ContentDAO(contentData: [:])
            content.type = .video
            content.isUploaded = false
            content.imgPreview = image
            content.fileName = self.localFileURl!.absoluteString.getName()
            content.fileUrl = self.localFileURl!
            self.seletedImage = content
            AWSRequestManager.sharedInstance.prepareVideoToUpload(name: seletedImage.fileName, thumbImage: seletedImage.imgPreview, videoURL: seletedImage.fileUrl!, completion: { (strThumb,strVideo,error) in
                if error == nil {
                    
                }
            })
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
              //  self.photoEditorDelegate?.doneEditing(image: self.seletedImage)
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
