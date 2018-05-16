//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Pushpendra on 13/12/17.
//
//

import Foundation
import UIKit
//import CropViewController

// MARK: - Control
public enum control {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

extension PhotoEditorViewController {
    
    //MARK: Top Toolbar
    @IBAction func saveEditedImageButtonTapped(_ sender: Any) {
        if isForEditOnly == false{
            seletedImage.imgPreview = image
            seletedImage.description = txtDescription.text.trim()
            seletedImage.fileName = NSUUID().uuidString + ".png"
            seletedImage.isUploaded = false
            seletedImage.type = PreviewType.image
            self.photoEditorDelegate?.doneEditing(image: self.seletedImage!)
            self.navigationController?.popViewAsDismiss()
        }else {
            HUDManager.sharedInstance.showHUD()
            if self.seletedImage.imgPreview != nil {
                self.uploadFile()
            }else {
                //   self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: "", type: self.seletedImage.type.rawValue)
                self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: self.seletedImage.coverImageVideo, type: self.seletedImage.type.rawValue, width: self.seletedImage.width, height: self.seletedImage.height)
            }
        }
      

    }
    
    
    @objc func actionForLeftMenu(sender:UIButton) {
        switch sender.tag {
        case 101:
            self.drawWidth = 5.0
            break
        case 102:
            self.drawWidth = 10.0
            break
        case 103:
            self.drawWidth = 15.0
            break
        default:
            break
        }
    }
    
    @objc func actionForRightMenu(sender:UIButton) {
          guard let edgeMenuLeft = self.edgeMenuLeft else { return }
        if edgeMenuLeft.opened {
            edgeMenuLeft.close()
        }
        guard let edgeMenu = self.edgeMenu else { return }
        self.viewDescription.isHidden = true
        edgeMenu.close()
        switch sender.tag {
        case 101:
        self.selectedFeature = .text
        self.hideToolbar(hide: false)
        self.textButtonTapped()
            break
        case 102:
        self.selectedFeature = .drawing
        self.hideToolbar(hide: true)
        drawButtonTapped()
            break
        case 103:
        self.selectedFeature = .sticker
        stickersButtonTapped()
            break
        case 104:
            self.selectedFeature = .none
        let obj:FilterViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_FilterView) as! FilterViewController
            obj.image  = self.canvasImageView.image
            obj.filterDelegate = self
            obj.isLoaded = "Load"
            self.navigationController?.pushNormal(viewController: obj)
            break
        default:
            break
        }
        
    }
    
    
    @objc func btnSaveAction(){
    UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }
    
    @objc func buttonBackAction(){
        photoEditorDelegate?.canceledEditing()
        self.navigationController?.popViewAsDismiss()
    }
    
    @objc func btnCancelAction(){
        view.endEditing(true)
        self.hideToolbar(hide: nil)
        self.viewDescription.isHidden = false
        guard let edgeMenu = self.edgeMenu else { return }
        if  edgeMenu.opened == false {
            edgeMenu.open()
        }
        
        guard let edgeMenuLeft = self.edgeMenuLeft else { return }
        if  edgeMenuLeft.opened == true {
            edgeMenuLeft.close()
        }
        self.colorPickerView.isHidden = true
        if self.selectedFeature == .drawing {
            self.canvasImageView.image = self.image
        }else if self.selectedFeature == .sticker {
            if isStriker {
                isStriker = false
                for beforeTextViewHide in self.canvasImageView.subviews {
                    if beforeTextViewHide.isKind(of: UIImageView.self){
                        if beforeTextViewHide.tag == 111{
                            DispatchQueue.main.async {
                                beforeTextViewHide.removeFromSuperview()
                            }
                        }
                    }
                    if beforeTextViewHide.isKind(of: UIView.self){
                        if   beforeTextViewHide.tag == 112 {
                            DispatchQueue.main.async {
                                beforeTextViewHide.removeFromSuperview()
                            }
                        }
                    }
                }
            }
        }else if self.selectedFeature == .text {
            if  isText {
                isText = false
                self.lastTextViewTransform = nil
                for beforeTextViewHide in self.canvasImageView.subviews {
                    if beforeTextViewHide.isKind(of: UIView.self) {
                        if beforeTextViewHide.tag == 2001 {
                            DispatchQueue.main.async {
                                beforeTextViewHide.removeFromSuperview()
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    @objc func btnApplyFeatureAction(){
        view.endEditing(true)
        //  doneButton.isHidden = true
        colorPickerView.isHidden = true
        canvasImageView.isUserInteractionEnabled = true
        self.hideToolbar(hide: nil)
        self.viewDescription.isHidden = false
        if isDrawing {
            guard let edgeMenuLeft = self.edgeMenuLeft else { return }
            if  edgeMenuLeft.opened == true {
                edgeMenuLeft.close()
            }
        }
        isDrawing = false
        self.colorsCollectionView.isHidden = true
        self.gradientImageView.isHidden = true
        let img = self.canvasView.toImage()
        self.canvasImageView.image = img
        self.seletedImage.imgPreview = img
        if  isText {
            isText = false
            self.lastTextViewTransform = nil
            for beforeTextViewHide in self.canvasImageView.subviews {
                if beforeTextViewHide.isKind(of: UIView.self) {
                    if beforeTextViewHide.tag == 2001 {
                        DispatchQueue.main.async {
                            beforeTextViewHide.removeFromSuperview()
                        }
                    }
                }
            }
        }
        if isStriker {
            isStriker = false
            for beforeTextViewHide in self.canvasImageView.subviews {
                if beforeTextViewHide.isKind(of: UIImageView.self){
                    if beforeTextViewHide.tag == 111{
                        DispatchQueue.main.async {
                            beforeTextViewHide.removeFromSuperview()
                        }
                    }
                }
                if beforeTextViewHide.isKind(of: UIView.self){
                    if   beforeTextViewHide.tag == 112 {
                        DispatchQueue.main.async {
                            beforeTextViewHide.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    @objc func capturScreenShot(){
        for beforeTextViewHide in self.canvasImageView.subviews {
            if beforeTextViewHide.isKind(of: UITextView.self){
                if beforeTextViewHide.tag == 101{
                    DispatchQueue.main.async {
                        beforeTextViewHide.isHidden = true
                    }
                }
            }
        }
        
        let img = self.canvasView.toImage()
        self.canvasImageView.image = img
        for afterTextViewShow in self.canvasImageView.subviews {
            if afterTextViewShow.isKind(of: UITextView.self){
                if afterTextViewShow.tag == 101{
                    DispatchQueue.main.async {
                        afterTextViewShow.isHidden = false
                    }
                }
            }
        }
    }
    
    
    @IBAction func cropButtonTapped(_ sender: UIButton) {
//        let croppingStyle = CropViewCroppingStyle.default
//        let cropController = CropViewController(croppingStyle: croppingStyle, image: canvasImageView.image!)
//        cropController.delegate = self
//        present(cropController, animated: true, completion: nil)
    }
    
     func stickersButtonTapped() {
        addStickersViewController()
    }
    
     func drawButtonTapped() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(0.8 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
            guard let edgeMenu = self.edgeMenuLeft else { return }
            edgeMenu.open()
            self.colorPickerView.isHidden = false
            self.colorsCollectionView.isHidden = false
            Animation.viewSlideInFromBottomToTop(views: self.colorPickerView)
        })
        isDrawing = true
        canvasImageView.isUserInteractionEnabled = false
      //  doneButton.isHidden = false
    }
    
    func endDoneTextField(strTxt : String){
        if strTxt.trim() == ""{
           // doneButton.isHidden = true
            colorPickerView.isHidden = true
            canvasImageView.isUserInteractionEnabled = true
          //  hideToolbar(hide: false)
            isDrawing = false
            self.colorsCollectionView.isHidden = true
           
            for beforeTextViewHide in self.canvasImageView.subviews {
                if beforeTextViewHide.isKind(of: UITextView.self){
                    if beforeTextViewHide.tag == 101{
                        DispatchQueue.main.async {
                            beforeTextViewHide.removeFromSuperview()
                        }
                    }
                }
            }
            
        }else{
            
            self.colorsCollectionView.isHidden = true
            // doneButton.isHidden = false
            hideToolbar(hide: true)
        }
    }
    
    func endDone(){
        self.colorsCollectionView.isHidden = true
     //   doneButton.isHidden = false
        hideToolbar(hide: false)
    }
    
     func textButtonTapped() {
        
        isTyping = true
        self.colorsCollectionView.isHidden = false
        let textView = UITextView(frame: CGRect(x: 0, y:0,
                                                width: UIScreen.main.bounds.width, height: 30))
        textView.tag = 101
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .done
        textView.delegate = self
        textView.tintColor = .clear
        
        if viewTxt != nil {
            viewTxt = nil
        }
        viewTxt = UIView(frame:  CGRect(x: 0, y: canvasImageView.center.y,
                                        width: UIScreen.main.bounds.width, height: 30))
        viewTxt?.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 0)
        viewTxt?.tag = 2001
        viewTxt?.addSubview(textView)
        self.canvasImageView.addSubview(viewTxt!)
        addGestures(view: viewTxt!)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }    
    
    
    
    //MARK: Bottom Toolbar
    

    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        //clear drawing
        canvasImageView.image = nil
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
        canvasImageView.image = self.image
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
//        let img = self.canvasView.toImage()
//        self.dismiss(animated: true, completion: nil)
    }
    
   
    //MAKR: helper methods
    

    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        self.showToast(type: .error, strMSG: kAlert_Save_Image)
    }
    

}
