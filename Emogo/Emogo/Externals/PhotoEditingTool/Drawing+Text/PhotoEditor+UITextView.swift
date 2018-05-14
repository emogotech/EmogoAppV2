//
//  PhotoEditor+UITextView.swift
//  Pods
//
//  Created by Pushpendra on 13/12/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController: UITextViewDelegate {
    
    
    
   
     func textViewDidChange(_ textView: UITextView) {
        if textView != txtDescription {
        
            let rotation = atan2(textView.transform.b, textView.transform.a)
            if rotation == 0 {
                let oldFrame = textView.frame
                let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
                textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
                textView.textContainer.size = textView.frame.size
                DispatchQueue.main.async {
                    self.viewTxt?.frame.size = textView.frame.size
                }
            }
            print("did change")
        }
       
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView != txtDescription {
            isTyping = true
            isText = true
            lastTextViewTransform =  textView.superview?.transform
            lastTextViewTransCenter = textView.superview?.center
            lastTextViewFont = textView.font!
            activeTextView = textView
            textView.superview?.bringSubview(toFront: textView)
            textView.font = UIFont(name: "Helvetica", size: 30)
            textView.superview?.frame.size = textView.frame.size
            self.colorsCollectionView.isHidden = false
            UIView.animate(withDuration: 0.3,
                           animations: {
                            if textView.text.trim() != ""{
                                textView.superview?.transform = CGAffineTransform.identity
                                textView.superview?.frame = textView.frame
                                textView.superview?.frame.origin = CGPoint(x:   0, y:  0)
                                textView.frame.origin = CGPoint(x:   0,  y:  0)
                            }
                            else{
                                textView.superview?.center = CGPoint(x: self.view.bounds.width / 2, y:  self.canvasView.bounds.height / 5)
                                textView.superview?.transform = CGAffineTransform.identity
                            }
                            
            }, completion: nil)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView != txtDescription {
            guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
                else {
                    return
            }
            activeTextView = nil
            self.viewTxt?.frame.size = textView.frame.size
            textView.font = self.lastTextViewFont!
            textView.superview?.backgroundColor = UIColor.clear
            self.colorsCollectionView.isHidden = true
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.viewTxt?.transform = self.lastTextViewTransform!
                            self.viewTxt?.center = self.lastTextViewTransCenter!
            }, completion: nil)
            
        }
       
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == txtDescription {
            if(text == "\n") {
                txtDescription.resignFirstResponder()
                return false
            }
            return textView.text.length + (text.length - range.length) <= 250
        }else {
            if(text == "\n") {
                //            self.doneButtonAction()
                textView.resignFirstResponder()
                
                self.endDoneTextField(strTxt: textView.text.trim())
                //            self.endDone()
                return false
            }
            return true
        }
        
    }
    
}
