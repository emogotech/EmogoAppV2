//
//  PhotoEditor+Keyboard.swift
//  Pods
//
//  Created by Pushpendra on 13/12/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController {
    
   @objc func keyboardDidShow(notification: NSNotification) {
//        if isTyping {
//            doneButton.isHidden = false
//            colorPickerView.isHidden = false
//            hideToolbar(hide: true)
//        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        isTyping = false
//        doneButton.isHidden = true
//        hideToolbar(hide: false)
    }
    
   @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
             self.colorPickerViewBottomConstraint.constant = 0.0
            } else {
                
                if #available(iOS 11.0, *) {
                    let extraBottomSpace = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
                    let height = (endFrame?.size.height)! - extraBottomSpace!
                self.colorPickerViewBottomConstraint.constant =  -height //?? 0.0
                } else {
                    // Fallback on earlier versions

                self.colorPickerViewBottomConstraint.constant =  endFrame?.size.height ?? 0.0
                }
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

}
