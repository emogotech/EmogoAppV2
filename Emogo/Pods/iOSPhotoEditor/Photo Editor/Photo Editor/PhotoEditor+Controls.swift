//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

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
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cropButtonTapped(_ sender: UIButton) {
        let controller = CropViewController()
        controller.delegate = self
        controller.image = image
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }

    @IBAction func drawButtonTapped(_ sender: Any) {
        isDrawing = true
        canvasImageView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        colorPickerView.isHidden = false
        hideToolbar(hide: true)
    }

    @IBAction func textButtonTapped(_ sender: Any) {
        isTyping = true
        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        
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
        textView.delegate = self
        self.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        doneButton.isHidden = true
        colorPickerView.isHidden = true
        canvasImageView.isUserInteractionEnabled = true
        hideToolbar(hide: false)
        isDrawing = false
    }
    
    //MARK: Bottom Toolbar
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }
    
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
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let img = self.canvasView.toImage()
        photoEditorDelegate?.doneEditing(image: img)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pencilButtonPressed(_ sender: Any) {
        self.isPencilSelected = !self.isPencilSelected
        if self.isPencilSelected {
            self.pencilButton.setImage(#imageLiteral(resourceName: "pen_icon"), for: .normal)
        }else {
            self.pencilButton.setImage(#imageLiteral(resourceName: "pen_icon_unactive"), for: .normal)
        }
    }
    @IBAction func colorShowButtonPressed(_ sender: Any) {
        self.isColorSelected = !self.isColorSelected
        if self.isColorSelected {
            let image = UIImage(named: "color_bucket_icon")
            self.colorButton.setImage(image, for: .normal)
            self.showColorsView(isShow: true)
        }else {
            self.showColorsView(isShow: false)
            let image = UIImage(named: "color_bucket_icon_unactive")
            self.colorButton.setImage(image, for: .normal)        }
    }
    

    
    //MAKR: helper methods
    
     func viewSlideInFromRightToLeft(views: UIView) {
        var transition: CATransition? = nil
        transition = CATransition()
        transition!.duration = 0.5
        transition!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition!.type = kCATransitionPush
        transition!.subtype = kCATransitionFromRight
        views.layer.add(transition!, forKey: nil)
    }
     func viewSlideInFromLeftToRight(views: UIView) {
        var transition: CATransition? = nil
        transition = CATransition()
        transition!.duration = 0.5
        transition!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition!.type = kCATransitionPush
        transition!.subtype = kCATransitionFromLeft
        views.layer.add(transition!, forKey: nil)
    }
    
     func viewSlideInFromTopToBottom(views: UIView) {
        var transition: CATransition? = nil
        transition = CATransition()
        transition!.duration = 0.5
        transition!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition!.type = kCATransitionPush
        transition!.subtype = kCATransitionFromTop
        views.layer.add(transition!, forKey: nil)
    }
     func viewSlideInFromBottomToTop(views: UIView) {
        var transition: CATransition? = nil
        transition = CATransition()
        transition!.duration = 0.5
        transition!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition!.type = kCATransitionPush
        transition!.subtype = kCATransitionFromBottom
        views.layer.add(transition!, forKey: nil)
    }

    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
            view.isHidden = hidden
        }, completion: nil)
    }
    
    func showColorsView(isShow:Bool){
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
            if isShow == true {
                self.colorsCollectionView.alpha = 1.0
            }else {
                self.colorsCollectionView.alpha = 0
            }
        }) { (completion) in
            if isShow == true {
                self.colorsCollectionView.isHidden =  false
            }else {
                self.colorsCollectionView.isHidden =  true
            }
        }
    }
    func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideControls() {
        for control in hiddenControls {
            switch control {
                
            case .clear:
                clearButton.isHidden = true
            case .crop:
                cropButton.isHidden = true
            case .draw:
                drawButton.isHidden = true
            case .save:
                saveButton.isHidden = true
            case .share:
                shareButton.isHidden = true
            case .sticker:
                stickerButton.isHidden = true
            case .text:
                stickerButton.isHidden = true
            }
        }
    }
    
}
