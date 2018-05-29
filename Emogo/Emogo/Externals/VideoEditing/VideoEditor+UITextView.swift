//
//  VideoEditor+UITextView.swift
//  Emogo
//
//  Created by Pushpendra on 28/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

extension VideoEditorViewController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView != txtDescription {
            let rotation = atan2(textView.transform.b, textView.transform.a)
            if rotation == 0 {
                let oldFrame = textView.frame
                let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
                textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
            }
        }
       
    }
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView != txtDescription {
            isTyping = true
            lastTextViewTransform =  textView.transform
            lastTextViewTransCenter = textView.center
            lastTextViewFont = textView.font!
            activeTextView = textView
            textView.superview?.bringSubview(toFront: textView)
            textView.font = UIFont(name: "Helvetica", size: 30)
            UIView.animate(withDuration: 0.3,
                           animations: {
                            textView.transform = CGAffineTransform.identity
                            textView.center = CGPoint(x: UIScreen.main.bounds.width / 2,
                                                      y:  UIScreen.main.bounds.height / 5)
            }, completion: nil)
        }
        
    }
    
  
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView != txtDescription {

        guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
            else {
                return
        }
        activeTextView = nil
        textView.font = self.lastTextViewFont!
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = self.lastTextViewTransform!
                        textView.center = self.lastTextViewTransCenter!
        }, completion: nil)
        }else {
//            if  txtDescription.text.trim().lowercased() != seletedImage.description.trim().lowercased() {
//                self.isForEditOnly = true
//            }else{
//                isForEditOnly = nil
//            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == txtDescription {
            if(text == "\n") {
                txtDescription.resignFirstResponder()
                return false
            }
            return textView.text.length + (text.length - range.length) <= 250
        }
        return true
    }
    
}

extension VideoEditorViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtTitleImage {
            txtDescription.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
