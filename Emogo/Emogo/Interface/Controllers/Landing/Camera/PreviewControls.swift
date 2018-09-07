//
//  PreviewControls.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
import Lightbox
import MessageUI
import Messages

extension PreviewController {
    
    func openGallery(){
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            //     self?.selectedAssets = assets
            self?.preparePreview(assets: assets)
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
            //exceed max selection
        }
        viewController.selectedAssets = [TLPHAsset]()
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 10
        configure.muteAudio = false
        configure.usedCameraButton = false
        configure.usedPrefetch = false
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
    }
    
    func preparePreview(assets:[TLPHAsset]){
        
        HUDManager.sharedInstance.showHUD()
        let group = DispatchGroup()
        for obj in assets {
            group.enter()
            let camera = ContentDAO(contentData: [:])
            camera.isUploaded = false
            if obj.type == .photo || obj.type == .livePhoto {
                camera.fileName = NSUUID().uuidString + ".png"
                camera.type = .image
                if obj.fullResolutionImage != nil {
                    camera.imgPreview = obj.fullResolutionImage
                    camera.color = obj.fullResolutionImage?.getColors().primary.toHexString
                    self.updateData(content: camera)
                    group.leave()
                }else {
                    
                    obj.cloudImageDownload(progressBlock: { (progress) in
                        
                    }, completionBlock: { (image) in
                        if let img = image {
                            camera.imgPreview = img
                            camera.color = img.getColors().primary.toHexString
                            self.updateData(content: camera)
                        }
                        group.leave()
                    })
                }
                
            }else if obj.type == .video {
                camera.type = .video
                obj.tempCopyMediaFile(progressBlock: { (progress) in
                    print(progress)
                }, completionBlock: { (url, mimeType) in
                    print(mimeType)
                    camera.fileUrl = url
                    camera.fileName = url.lastPathComponent
                    obj.phAsset?.getOrigianlImage(handler: { (img, _) in
                        if img != nil {
                            camera.imgPreview = img
                            camera.color = img?.getColors().primary.toHexString
                        }else {
                            camera.imgPreview = #imageLiteral(resourceName: "stream-card-placeholder")
                        }
                        self.updateData(content: camera)
                        group.leave()
                    })
                })
            }
        }
        
        group.notify(queue: .main, execute: {
            HUDManager.sharedInstance.hideHUD()
            self.btnPreviewOpen.isHidden = false
            self.previewCollection.reloadData()
        })
    }
    
    func updateData(content:ContentDAO) {
        ContentList.sharedInstance.arrayContent.insert(content, at: 0)
        self.btnPreviewOpen.isHidden = false
    }
    
   @objc func openFullView(){
    var index = 0
    if self.seletedImage.type == .notes {
        self.notePreview()
        return
    }
    
    if self.seletedImage.type == .gif {
        self.gifPreview()
        return
    }
    if seletedImage.type == .link {
        guard let url = URL(string: seletedImage.coverImage) else {
            return //be safe
        }
        self.openURL(url: url)
    }else {
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
            if image != nil {
              
                arrayContents.append(image)
                if obj.isUploaded {
                    if  obj.contentID.trim()  == self.seletedImage.contentID.trim(){
                        index = arrayContents.count - 1
                    }
                }else {
                    if  obj.fileName.trim()  == self.seletedImage.fileName.trim(){
                        index = arrayContents.count - 1
                    }
                }
            }
        }
        
        let controller = LightboxController(images: arrayContents, startIndex: index)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
}
    
    func gifPreview(){
        let obj:ShowPreviewViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ShowPreviewView) as! ShowPreviewViewController
        obj.objContent = self.seletedImage
        self.present(obj, animated: false, completion: nil)
    }
    
    func notePreview(){
        let obj:NotesPreviewViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: "notesPreviewView") as! NotesPreviewViewController
        obj.contentDAO = self.seletedImage
        self.navigationController?.pushAsPresent(viewController: obj)
    }

}


extension PreviewController:UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  ContentList.sharedInstance.arrayContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PreviewCell, for: indexPath) as! PreviewCell
        let obj =  ContentList.sharedInstance.arrayContent[indexPath.row]
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        cell.layer.cornerRadius = 10.0
        cell.clipsToBounds = true
        cell.setupPreviewWithType(content:obj)
        cell.playIcon.tag = indexPath.row
        cell.playIcon.addTarget(self, action: #selector(self.playIconTapped(sender:)), for: .touchUpInside)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height - 40, height: collectionView.frame.size.height - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.preparePreview(index: indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

extension PreviewController:PhotoEditorDelegate
{
    func doneEditing(image: ContentDAO) {
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        self.seletedImage = image
        ContentList.sharedInstance.arrayContent[selectedIndex] = image
        self.preparePreview(index: selectedIndex)
        self.previewCollection.reloadData()
    }
    
    func canceledEditing() {
        print("Canceled")
        AppDelegate.appDelegate.keyboardResign(isActive: true)
    }
}
extension PreviewController:VideoEditorDelegate
{
    func cancelEditing() {
        AppDelegate.appDelegate.keyboardResign(isActive: true)
    }
    
    func saveEditing(image: ContentDAO) {
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        self.seletedImage = image
        ContentList.sharedInstance.arrayContent[selectedIndex] = image
        self.preparePreview(index: selectedIndex)
        self.previewCollection.reloadData()
    }
    
}


extension PreviewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtTitleImage {
            txtDescription.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.setPreviewContent(title: (txtTitleImage.text?.trim())!, description: (txtDescription.text?.trim())!)
    }
}


extension PreviewController:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            txtDescription.resignFirstResponder()
            return false
        }
        return textView.text.length + (text.length - range.length) <= 250
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.setPreviewContent(title: (txtTitleImage.text?.trim())!, description: (txtDescription.text?.trim())!)
    }

}

extension PreviewController:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension PreviewController:CreateNotesViewControllerDelegate
{
    
    func updatedNotes(content:ContentDAO) {
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        self.seletedImage = content
        if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
            ContentList.sharedInstance.arrayContent [index] = seletedImage
            preparePreview(index: index)
        }
    }
    
}


//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if txtStreamCaption.text.trim() == "Stream Caption"{
//            txtStreamCaption.text = nil
//        }
//    }



