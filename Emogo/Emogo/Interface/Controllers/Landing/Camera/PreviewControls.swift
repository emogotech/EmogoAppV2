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


extension PreviewController {
    
    func openGallery(){
        let gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    }
    
   @objc func openFullView(){
        var arrayContents = [LightboxImage]()
        for obj in ContentList.sharedInstance.arrayContent {
            var image:LightboxImage!
            if obj.type == .image {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!)
                }else{
                    let url = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!)
                }
            }else {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!)
                }else {
                    let url = URL(string: obj.coverImage)
                    let videoUrl = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!, text: obj.name, videoURL: videoUrl!)
                }
            }
            if image != nil {
                arrayContents.append(image)
            }
        }
        
        let controller = LightboxController(images: arrayContents, startIndex: self.selectedIndex)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
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
            self.setPreviewContent(title: (txtTitleImage.text?.trim())!, description: (txtDescription.text?.trim())!)
        }
        return true
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

