//
//  iMessageExt.swift
//  iMessageExt
//
//  Created by Vikas Goyal on 17/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import Messages

// MARK: - String
extension String {
    
    func stringByAddingPercentEncodingForURLQueryParameter() -> String? {
        let allowedCharacters = NSCharacterSet.urlQueryAllowed
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height:height )
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.width
    }
    
    func trimStr() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
}

// MARK: - MSMessagesAppViewController
extension MSMessagesAppViewController {
    
    func addTransitionAtPresentingControllerRight(){
        let transition = CATransition()
        transition.duration = 0.7
        transition.type = "cube"
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    func addTransitionAtNaviagteNext(){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
    }
}

// MARK: - UITextField
extension UITextField {
    func shakeTextField() {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = 3
        animation.duration = 0.1
        animation.autoreverses = true
        animation.toValue = -5
        animation.fromValue = 5
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - UIApplication
extension UIApplication {
    func vkpv_mostTopViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
