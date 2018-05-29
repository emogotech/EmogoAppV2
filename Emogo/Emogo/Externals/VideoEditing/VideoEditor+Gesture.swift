//
//  VideoEditor+Gesture.swift
//  Emogo
//
//  Created by Pushpendra on 22/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
extension VideoEditorViewController:UIGestureRecognizerDelegate  {
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        self.view.endEditing(true)
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                if recognizer.state == .began {
                    for imageView in subImageViews(view: canvasImageView) {
                        let location = recognizer.location(in: imageView)
                        let alpha = imageView.alphaAtPoint(location)
                        if alpha > 0 {
                            imageViewToPan = imageView
                            break
                        }
                    }
                }
                if imageViewToPan != nil {
                    moveView(view: imageViewToPan!, recognizer: recognizer)
                }
            } else  if view is UITextView  {
                   self.moveView(view: view, recognizer: recognizer)
            } else {
                self.moveView(view: view, recognizer: recognizer)
            }
        }
    }
    
    /**
     UIPinchGestureRecognizer - Pinching Objects
     If it's a UITextView will make the font bigger so it doen't look pixlated
     */
    
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        self.colorPickerView.isHidden = true
        self.colorsCollectionView.isHidden = true
        self.view.endEditing(true)
        let pinchGesture = recognizer
        
        if let view = recognizer.view {
            if view is UITextView {
                print("textview")
                let textView = view as! UITextView
                
                if textView.font!.pointSize * recognizer.scale < 90 {
                    let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
                    textView.font = font
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                } else {
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                    
                }
                
                textView.setNeedsDisplay()
            } else {
                
                var currentScale:Float = 0.0
                if .began == pinchGesture.state || .changed == pinchGesture.state {
                    if let value =  pinchGesture.view?.layer.value(forKeyPath: "transform.scale.x") {
                        let num:NSNumber = value as! NSNumber
                        
                        currentScale = Float(truncating: num)
                    }
                    let minScale: Float = 1.0
                    let maxScale: Float = 4.0
                    //  let zoomSpeed: Float = 0.1
                    var deltaScale = Float(pinchGesture.scale )
                    //deltaScale = ((deltaScale - 1) * zoomSpeed) + 1
                    deltaScale = min(deltaScale, maxScale / currentScale)
                    deltaScale = max(deltaScale, minScale / currentScale)
                    let zoomTransform: CGAffineTransform = (pinchGesture.view?.transform.scaledBy(x: CGFloat(deltaScale), y: CGFloat(deltaScale)))!
                    pinchGesture.view?.transform = zoomTransform
                    pinchGesture.scale = 1
                }
            }
            recognizer.scale = 1
        }
    }
   
    /**
     UIRotationGestureRecognizer - Rotating Objects
     */
    @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        self.view.endEditing(true)
        
        if let view = recognizer.view {
            self.colorPickerView.isHidden = true
            self.colorsCollectionView.isHidden = true
            if view is UITextView {
                let viewSub = recognizer.view?.superview
                if viewSub?.tag  == 2001{
                    viewSub?.transform = (viewSub?.transform.rotated(by: recognizer.rotation))!
                    recognizer.rotation = 0
                }
            }else{
                
                view.transform = view.transform.rotated(by: recognizer.rotation)
                recognizer.rotation = 0
            }
            
        }
    }
    
    /**
     UITapGestureRecognizer - Taping on Objects
     Will make scale scale Effect
     Selecting transparent parts of the imageview won't move the object
     */
    
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                for imageView in subImageViews(view: canvasImageView) {
                    let location = recognizer.location(in: imageView)
                    let alpha = imageView.alphaAtPoint(location)
                    if alpha > 0 {
                        scaleEffect(view: imageView)
                        break
                    }
                }
            } else {
                scaleEffect(view: view)
            }
        }
    }
    
    /*
     Support Multiple Gesture at the same time
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            if !stickersVCIsVisible {
                addStickersViewController()
            }
        }
    }
    
    // to Override Control Center screen edge pan from bottom
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    /**
     Scale Effect
     */
    func scaleEffect(view: UIView) {
        view.superview?.bringSubview(toFront: view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }
    
    /**
     Moving Objects
     delete the view if it's inside the delete view
     Snap the view back if it's out of the canvas
     */
    
    func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
        
        view.superview?.bringSubview(toFront: view)
        let pointToSuperView = recognizer.location(in: self.view)
        
        view.center = CGPoint(x: view.center.x + recognizer.translation(in: canvasImageView).x,
                              y: view.center.y + recognizer.translation(in: canvasImageView).y)
        
        recognizer.setTranslation(CGPoint.zero, in: canvasImageView)
        lastPanPoint = pointToSuperView
        if recognizer.state == .ended {
            imageViewToPan = nil
            lastPanPoint = nil
           if !canvasImageView.bounds.contains(view.center) { //Snap the view back to canvasImageView
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = self.canvasImageView.center
                })
                
            }
        }
    }
    
    func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if imageView is UIImageView {
                imageviews.append(imageView as! UIImageView)
            }
        }
        return imageviews
    }
    
}
