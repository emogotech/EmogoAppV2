//
//  PreviewControls.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
import Gallery
import Lightbox
import MessageUI
import Messages

extension PreviewController {
    
    func openGallery(){
        let gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    }
    
   @objc func openFullView(){
    var index = 0
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
            let text = obj.name + "\n\n" +  obj.description

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
                    let url = URL(string: obj.coverImage)
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
}


extension PreviewController:UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  ContentList.sharedInstance.arrayContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PreviewCell, for: indexPath) as! PreviewCell
        let obj =  ContentList.sharedInstance.arrayContent[indexPath.row]
        cell.setupPreviewWithType(content:obj)
        cell.playIcon.tag = indexPath.row
        cell.playIcon.addTarget(self, action: #selector(self.playIconTapped(sender:)), for: .touchUpInside)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height - 30, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.preparePreview(index: indexPath.row)
    }
    
}

extension PreviewController:PhotoEditorDelegate
{
    func doneEditing(image: UIImage) {
        // the edited image
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        seletedImage.imgPreview = image
        seletedImage.isUploaded = false
        ContentList.sharedInstance.arrayContent[selectedIndex] = seletedImage
        self.preparePreview(index: selectedIndex)
        self.previewCollection.reloadData()
    }
    
    func canceledEditing() {
        print("Canceled")
        AppDelegate.appDelegate.keyboardResign(isActive: true)
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


extension PreviewController:GalleryControllerDelegate {
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        HUDManager.sharedInstance.showHUD()
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    print(tempPath)
                    if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:tempPath) {
                        let camera = ContentDAO(contentData: [:])
                        camera.imgPreview = image
                        camera.fileName = tempPath.absoluteString.getName()
                        camera.fileUrl = tempPath
                        camera.type = .video
                        print(camera.fileName)
                        ContentList.sharedInstance.arrayContent.insert(camera, at: 0)
                        self.btnPreviewOpen.isHidden = false
                        self.previewCollection.reloadData()
                        HUDManager.sharedInstance.hideHUD()
                    }
                }
            }
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        self.preparePreview(assets: images)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        

    }
    
  private func preparePreview(assets:[Image]){
    
        Image.resolve(images: assets, completion: {  resolvedImages in
            for i in 0..<resolvedImages.count {
                let obj = resolvedImages[i]
                let camera = ContentDAO(contentData: [:])
                camera.imgPreview = obj
                camera.type = .image
                if let file =  assets[i].asset.value(forKey: "filename"){
                    camera.fileName = file as! String
                }
                ContentList.sharedInstance.arrayContent.insert(camera, at: 0)
            }
            self.previewCollection.reloadData()
        })
        
    }
    
}

extension PreviewController:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        txtDescription.placeholderName = "Description"
        
        if let placeholderLabel = txtDescription.viewWithTag(100) as? UILabel {
            let shouldHide = txtDescription.text.count > 0
            placeholderLabel.isHidden = shouldHide
        }
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


//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if txtStreamCaption.text.trim() == "Stream Caption"{
//            txtStreamCaption.text = nil
//        }
//    }



