//
//  PMNavigationDelegate.swift
//  Emogo
//
//  Created by Pushpendra on 22/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
/*
extension StreamListViewController: ZoomTransitionSourceDelegate {
  
    var animationDuration: TimeInterval {
        return 0.2
    }
    
    func transitionSourceImageView() -> UIImageView {
        return selectedImageView ?? UIImageView()
    }
    
    func transitionSourceImageViewFrame(forward: Bool) -> CGRect {
        guard let selectedImageView = selectedImageView else { return .zero }
        return selectedImageView.convert(selectedImageView.bounds, to: view)
    }
    
    func transitionSourceWillBegin() {
        selectedImageView?.isHidden = true
    }
    
    func transitionSourceDidEnd() {
        selectedImageView?.isHidden = false
    }
    
    func transitionSourceDidCancel() {
        selectedImageView?.isHidden = false
    }
}
 

extension ProfileViewController: ZoomTransitionSourceDelegate {
    
    var animationDuration: TimeInterval {
        return 0.2
    }
    
    func transitionSourceImageView() -> UIImageView {
        return selectedImageView ?? UIImageView()
    }
    
    func transitionSourceImageViewFrame(forward: Bool) -> CGRect {
        guard let selectedImageView = selectedImageView else { return .zero }
        return selectedImageView.convert(selectedImageView.bounds, to: view)
    }
    
    func transitionSourceWillBegin() {
        selectedImageView?.isHidden = true
    }
    
    func transitionSourceDidEnd() {
        selectedImageView?.isHidden = false
    }
    
    func transitionSourceDidCancel() {
        selectedImageView?.isHidden = false
    }
}

extension ViewProfileViewController: ZoomTransitionSourceDelegate {
    
    var animationDuration: TimeInterval {
        return 0.2
    }
    
    func transitionSourceImageView() -> UIImageView {
        return selectedImageView ?? UIImageView()
    }
    
    func transitionSourceImageViewFrame(forward: Bool) -> CGRect {
        guard let selectedImageView = selectedImageView else { return .zero }
        return selectedImageView.convert(selectedImageView.bounds, to: view)
    }
    
    func transitionSourceWillBegin() {
        selectedImageView?.isHidden = true
    }
    
    func transitionSourceDidEnd() {
        selectedImageView?.isHidden = false
    }
    
    func transitionSourceDidCancel() {
        selectedImageView?.isHidden = false
    }
}


extension ViewStreamController: ZoomTransitionDestinationDelegate {
    
    func transitionDestinationImageViewFrame(forward: Bool) -> CGRect {
        if forward {
            let x: CGFloat = 0
            let y: CGFloat = topLayoutGuide.length
            let width: CGFloat = view.frame.width
            let height: CGFloat = width * 2 / 3
            return CGRect(x: x, y: y, width: width, height: height)
        } else {
      //  return   stretchyHeader.imgCover.convert( stretchyHeader.imgCover.bounds, to: view)
            return .zero
        }
    }
    
    func transitionDestinationWillBegin() {
        if self.stretchyHeader != nil {
            stretchyHeader.imgCover.isHidden = true
        }
    }
    
    func transitionDestinationDidEnd(transitioningImageView imageView: UIImageView) {
        if self.stretchyHeader != nil {
            stretchyHeader.imgCover.isHidden = true
            stretchyHeader.imgCover.image = imageView.image
        }
       
    }
    
    func transitionDestinationDidCancel() {
        if self.stretchyHeader != nil {
            stretchyHeader.imgCover.isHidden = true
        }
    }
}

 */
