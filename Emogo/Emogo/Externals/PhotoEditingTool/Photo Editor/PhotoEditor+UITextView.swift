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
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            let oldFrame = textView.frame
            let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
        print("did change")
    }
     func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        isText = true
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
    
     func textViewDidEndEditing(_ textView: UITextView) {
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

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
//            self.doneButtonAction()
            textView.resignFirstResponder()
            self.endDone()
            return false
        }
        return true
    }
    
}
