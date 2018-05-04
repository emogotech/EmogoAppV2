//
//  ViewController+Delegate.swift
//  ImageEditing
//
//  Created by Pushpendra on 02/05/18.
//  Copyright © 2018 Pushpendra. All rights reserved.
//

import Foundation
import UIKit

extension PhotoEditorViewController:StickersViewControllerDelegate {
    func didSelectView(view: UIView) {
        isStriker = true
        view.tag = 112
        print(self.baseImageView.frame)
        self.baseImageView.addSubview(view)
        view.center = baseImageView.center
        self.removeStickersView()
        //Gestures
        addGestures(view: view)
    }
    
    func didSelectImage(image: UIImage) {
        isStriker = true
        print(self.baseImageView.frame)

        let imageView = UIImageView(image: image)
        imageView.tag = 111
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = baseImageView.center
        self.baseImageView.addSubview(imageView)
        print(self.baseImageView.center)
        //Gestures
        self.removeStickersView()
        
        addGestures(view: imageView)
    }
    
    func stickersViewDidDisappear() {
        stickersVCIsVisible = false
        //  hideToolbar(hide: false)
    }
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.panGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(self.pinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(self.rotationGesture(_:)) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
}

extension PhotoEditorViewController: ColorDelegate {
    
    func didSelectColor(color: UIColor) {
        self.drawingView.lineColor = color
    }
}

extension PhotoEditorViewController:UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
       
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            txtImageCaption.resignFirstResponder()
            return false
        }
        return textView.text.length + (text.length - range.length) <= 250
    }
    
}
