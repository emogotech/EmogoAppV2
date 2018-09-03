//
//  PMNavigationDelegate.swift
//  Emogo
//
//  Created by Pushpendra on 22/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit



extension StreamListViewController: ZoomTransitionSourceDelegate {
    var animationDuration: TimeInterval {
        return 0.4
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
    
    // Uncomment method below if you customize the animation.
    func zoomAnimation(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 2,
            options: .curveEaseInOut,
            animations: animations,
            completion: completion)
    }
}

// MARK: - ZoomTransitionDestinationDelegate


extension TestDetailViewController: ZoomTransitionDestinationDelegate {
    func transitionDestinationImageViewFrame(forward: Bool) -> CGRect {
        if forward {
            let x: CGFloat = 0
            let y: CGFloat = topLayoutGuide.length
            let width: CGFloat = view.frame.width
            let height: CGFloat = 250
            return CGRect(x: x, y: y, width: width, height: height)
        } else {
            return imgTestDetail.convert(imgTestDetail.bounds, to: view)
        }
    }
    
    func transitionDestinationWillBegin() {
        imgTestDetail.isHidden = true
    }
    
    func transitionDestinationDidEnd(transitioningImageView imageView: UIImageView) {
        imgTestDetail.isHidden = false
        imgTestDetail.image = imageView.image
    }
    
    func transitionDestinationDidCancel() {
        imgTestDetail.isHidden = false
    }
}

extension EmogoDetailViewController: ZoomTransitionDestinationDelegate {
    func transitionDestinationImageViewFrame(forward: Bool) -> CGRect {
        if forward {
            let x: CGFloat = 0
            let y: CGFloat = topLayoutGuide.length
            let width: CGFloat = view.frame.width
            let height: CGFloat = self.stretchyHeader.imgCover.bounds.size.height
            return CGRect(x: x, y: y, width: width, height: height)
        } else {
            return self.stretchyHeader.imgCover.convert(self.stretchyHeader.imgCover.bounds, to: view)
        }
    }
    
    func transitionDestinationWillBegin() {
        self.stretchyHeader.imgCover.isHidden = true
    }
    
    func transitionDestinationDidEnd(transitioningImageView imageView: UIImageView) {
        self.stretchyHeader.imgCover.isHidden = false
         self.stretchyHeader.imgCover.image = imageView.image
    }
    
    func transitionDestinationDidCancel() {
        self.stretchyHeader.imgCover.isHidden = false
    }
}


extension ProfileViewController: ZoomTransitionSourceDelegate {
    
    var animationDuration: TimeInterval {
        return 0.4
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
        return 0.4
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

