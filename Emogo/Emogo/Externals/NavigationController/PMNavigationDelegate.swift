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
    
    func transitionSourceImageView() -> UIImageView {
        return selectedImageView ?? UIImageView()
    }
    
    func transitionSourceImageViewFrame(forward: Bool) -> CGRect {
        guard let selectedImageView = selectedImageView else { return CGRect.zero }
        return selectedImageView.convert(selectedImageView.bounds, to: view)
    }
    
    func transitionSourceWillBegin() {
        selectedImageView?.isHidden = true
    }
    
    func transitionSourceDidEnd() {
        selectedImageView?.isHidden = true
    }
    
    func transitionSourceDidCancel() {
        selectedImageView?.isHidden = true
    }
}

extension ViewStreamController: ZoomTransitionDestinationDelegate {
    
    func transitionDestinationImageViewFrame(forward: Bool) -> CGRect {
        if forward {
           // return .zero

//            if self.stretchyHeader != nil {
//             return stretchyHeader.imgCover.bounds
//            }
            
            return CGRect(x: 0, y: 0, width: kFrame.size.width, height: 306)
        } else {
            if self.stretchyHeader != nil {
                return stretchyHeader.imgCover.convert(stretchyHeader.imgCover.bounds, to: view)
            }
        }
        return .zero
    }
    
    func transitionDestinationWillBegin() {
        if self.stretchyHeader != nil {
            stretchyHeader.imgCover.isHidden = true
        }
    }
    
    func transitionDestinationDidEnd(transitioningImageView imageView: UIImageView) {
        if self.stretchyHeader != nil {
            stretchyHeader.imgCover.isHidden = false
            stretchyHeader.imgCover.image = imageView.image
        }
       
    }
    
    func transitionDestinationDidCancel() {
        if self.stretchyHeader != nil {
            stretchyHeader.imgCover.isHidden = false
        }
    }
}
