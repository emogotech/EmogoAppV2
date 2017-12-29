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
import SDWebImage

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

// MARK: - UIImageView
extension UIImageView {
    
    func setImageWithURL(strImage:String, placeholder:String){
        if strImage.isEmpty{
            return
        }
        let imgURL = URL(string: strImage.stringByAddingPercentEncodingForURLQueryParameter()!)!
        //self.sd_setImage(with: url)
        self.sd_setImage(with: imgURL, placeholderImage: UIImage(named: placeholder))
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setIndicatorStyle(.gray)
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
    
    func addTransitionAtNaviagtePrevious(){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    func addRippleTransition() {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = "rippleEffect"
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    func addRightTransitionImage(imgV:UIImageView){
        let transition = CATransition()
        transition.duration = 0.7
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
    func addLeftTransitionImage(imgV:UIImageView){
        let transition = CATransition()
        transition.duration = 0.7
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
    func showToastIMsg(type:AlertType,strMSG:String) {
        self.view.makeToast(message: strMSG,
                            duration: TimeInterval(3.0),
                            position: .top,
                            image: nil,
                            backgroundColor: UIColor.black.withAlphaComponent(0.6),
                            titleColor: UIColor.yellow,
                            messageColor: UIColor.white,
                            font: nil)
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


