//
//  PhotoEditor+StickersViewController.swift
//  Pods
//
//  Created by Pushpendra on 13/12/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController {
    
    func addStickersViewController() {
        stickersVCIsVisible = true
        hideToolbar(hide: true)
        self.canvasImageView.isUserInteractionEnabled = false
        stickersViewController.stickersViewControllerDelegate = self
        
        for image in self.stickers {
            stickersViewController.stickers.append(image)
        }
        self.addChildViewController(stickersViewController)
        self.view.addSubview(stickersViewController.view)
        stickersViewController.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        stickersViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeStickersView() {
        stickersVCIsVisible = false
        isStriker = false
        for beforeTextViewHide in self.canvasImageView.subviews {
            if beforeTextViewHide.isKind(of: UIImageView.self){
                if beforeTextViewHide.tag == 111{
                    isStriker = true
                }
            }
            if beforeTextViewHide.isKind(of: UIView.self){
                if   beforeTextViewHide.tag == 112 {
                   isStriker = true
                }
            }
        }
        self.canvasImageView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.stickersViewController.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.stickersViewController.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.stickersViewController.view.removeFromSuperview()
            self.stickersViewController.removeFromParentViewController()
            if self.isStriker == true{
                 self.endDone()
            }else{
                self.hideToolbar(hide: false)
            }
           
        })
    }
    
    func doneStrekarView(){
          self.hideToolbar(hide: true)
    }
}

extension PhotoEditorViewController: StickersViewControllerDelegate {
    
    func didSelectView(view: UIView) {
//        isStriker = true

        view.center = canvasImageView.center
        view.tag = 112
        self.canvasImageView.addSubview(view)
        self.removeStickersView()
        //Gestures
        addGestures(view: view)
    }
    
    func didSelectImage(image: UIImage) {
//        isStriker = true
        
        let imageView = UIImageView(image: image)
        imageView.tag = 111
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = canvasImageView.center
        
        self.canvasImageView.addSubview(imageView)
        //Gestures
        self.removeStickersView()

        addGestures(view: imageView)
    }
    
    func stickersViewDidDisappear() {
        stickersVCIsVisible = false
        hideToolbar(hide: false)
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
