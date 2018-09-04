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
extension StreamListViewController:UINavigationControllerDelegate,ZOZolaZoomTransitionDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC != self && toVC != self {
            return nil
        }
        
        // Determine if we're presenting or dismissing
        let type = (fromVC == self) ? ZOTransitionType.presenting : ZOTransitionType.dismissing
        
        // Create a transition instance with the selected cell's imageView as the target view
        
       // let zoomTransition = ZOZolaZoomTransition(from: self.selectedCell.imgCover, type: type, duration: 0.35, delegate: self)
        let zoomTransition = ZOZolaZoomTransition(from: self.selectedImageView, type: type, duration: 0.5, delegate: self)
        zoomTransition?.fadeColor = UIColor.clear
        return zoomTransition
    }
    
    
    func zolaZoomTransition(_ zoomTransition: ZOZolaZoomTransition!, startingFrameFor targetView: UIView!, relativeTo relativeView: UIView!, from fromViewController: UIViewController!, to toViewController: UIViewController!) -> CGRect {
        
        if fromViewController == self {
            // We're pushing to the detail controller. The starting frame is taken from the selected cell's imageView.
            
           
          return self.selectedCell.imgCover.convert(self.selectedCell.imgCover.bounds , to: relativeView)

        }
        
        else if (fromViewController is EmogoDetailViewController) {
       // else if (fromViewController is ViewStreamController) {
            // We're popping back to this master controller. The starting frame is taken from the detailController's imageView.
            let detailController = fromViewController as? EmogoDetailViewController
      //      let detailController = fromViewController as? ViewStreamController
            if detailController?.stretchyHeader != nil {
                return detailController!.stretchyHeader.imgCover.convert(detailController!.stretchyHeader.imgCover.bounds, to: relativeView)
            }
        }
        
        return CGRect.zero
        
    }
    
    func zolaZoomTransition(_ zoomTransition: ZOZolaZoomTransition!, finishingFrameFor targetView: UIView!, relativeTo relativeView: UIView!, from fromViewController: UIViewController!, to toViewController: UIViewController!) -> CGRect {
        
        if fromViewController == self {
            // We're pushing to the detail controller. The finishing frame is taken from the detailController's imageView.
            let detailController = toViewController as! EmogoDetailViewController
         // let detailController = toViewController as!  ViewStreamController
            return detailController.stretchyHeader.imgCover.convert(detailController.stretchyHeader.imgCover.bounds, to: relativeView)
        }
        else if (fromViewController is EmogoDetailViewController) {
            // We're popping back to this master controller. The finishing frame is taken from the selected cell's imageView.
            return  self.selectedCell.imgCover.convert(selectedCell.imgCover.bounds, to: relativeView)
               // self.selectedCell.imgCover.convert(selectedCell.imgCover.bounds, to: relativeView)
        }
        
        return CGRect.zero
        
    }
 
    /*
    func supplementaryViews(for zoomTransition: ZOZolaZoomTransition!) -> [Any]! {
        var clippedCells = [Any]()
        for  visibleCell: UICollectionViewCell? in streamCollectionView.visibleCells {
            if let visibleCell = visibleCell {
                let cell:StreamCell = visibleCell as! StreamCell
                let convertedRect = cell.convert(cell.bounds, to: view)
                if !view.frame.contains(convertedRect) {
                    clippedCells.append(cell)
                }
            }
        }
        print(clippedCells)
        return clippedCells
    }
    
    func zolaZoomTransition(_ zoomTransition: ZOZolaZoomTransition!, frameForSupplementaryView supplementaryView: UIView!, relativeTo relativeView: UIView!) -> CGRect {
         return supplementaryView.convert(supplementaryView.bounds, to: relativeView)
    }
    */

    
}

*/
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
}
// MARK: - ZoomTransitionDestinationDelegate

extension TestDetailViewController: ZoomTransitionDestinationDelegate {
    func transitionDestinationImageViewFrame(forward: Bool) -> CGRect {
        if forward {
            let x: CGFloat = 0
            let y: CGFloat = topLayoutGuide.length
            let width: CGFloat = view.frame.width
            let height: CGFloat = width * 2 / 3
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


extension EmogoDetailViewController: ZoomTransitionDestinationDelegate {
    
    func transitionDestinationImageViewFrame(forward: Bool) -> CGRect {
        if forward {
            let x: CGFloat = 0
            let y: CGFloat = topLayoutGuide.length
            let width: CGFloat = view.frame.width
            let height: CGFloat = 250
            return CGRect(x: x, y: y, width: width, height: height)
        } else {
         return  stretchyHeader.imgCover.convert( stretchyHeader.imgCover.bounds, to: view)
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

