//
//  Extensions.swift
//  Emogo
//
//  Created by Vikas Goyal on 15/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
import CRNotifications
import QuartzCore

// MARK: - UIColor
extension UIColor {
    
    convenience init (r : CGFloat , g : CGFloat , b : CGFloat ) {
        self.init(red: r / 255 , green: g / 255 , blue: b / 255 , alpha: 1.0)
    }
    
}

// MARK: - UIView
extension UIView {
    
    func addCorner (radius : CGFloat , borderWidth : CGFloat , color : UIColor ) {
        
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        
    }
    
    var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
        
    }
    
    func addShadow(shadowColor: CGColor = UIColor.darkGray.cgColor,shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),shadowOpacity: Float = 0.6, shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    
    func swipeToUp (height : CGFloat ) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 8.0, initialSpringVelocity: 8.0, options: .curveEaseIn, animations: {
            
            self.frame.origin.y -= height
            
        }, completion: nil )
        
    }
    
    func swipeToDown (height : CGFloat ) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 8.0, initialSpringVelocity: 8.0, options: .curveEaseIn, animations: {
            
            self.frame.origin.y += height
            
        }, completion: nil )
        
    }
    
    
    func swipeToRight (distance : CGFloat ) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 5.0, initialSpringVelocity: 5.0, options: .curveEaseIn, animations: {
            
            self.frame.origin.x += distance
            
        }, completion: nil )
        
    }
    
    func swipeToLeft (distance : CGFloat ) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            
            self.frame.origin.x -= distance
            
        }, completion: nil )
        
    }
    
    
    func makeClickEffect () {
        
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.95 , y: 0.95)
        },
                       completion: { _ in
                        
                        UIView.animate(withDuration: 0.2) {
                            self.transform = CGAffineTransform.identity
                        }
                        
        })
        
    }
    
    
    func fadeIn(duration: TimeInterval ) {
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:  {
            
            self.alpha = 1.0
            
        }, completion: nil)
        
    }
    
    func fadeOut(duration: TimeInterval ) {
        
        UIView.animate(withDuration: duration , delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:  {
            
            self.alpha = 0.0
            
        }, completion: nil)
        
    }
    
}

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
    
//    func trim() -> String{
//        return self.trimmingCharacters(in: CharacterSet.whitespaces)
//    }
    
}

// MARK: - String
extension UIView {
    
}


// MARK: - UIButton
extension UIButton {
    
}

// MARK: - UIButton

extension UIViewController {
    
    func showAlert(strMessage:String){
        let alert = UIAlertController(title: "Message", message: strMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (actoin) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showToast(type:AlertType,strMSG:String) {
        
        self.view.makeToast(message: strMSG,
                            duration: TimeInterval(3.0),
                            position: .top,
                            image: nil,
                            backgroundColor: UIColor.black.withAlphaComponent(0.6),
                            titleColor: UIColor.yellow,
                            messageColor: UIColor.white,
                            font: nil)
    
    }
    
    func configureLandingNavigation(){
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = .white
        let img = UIImage(named: "my_profile")
        let btnProfile = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.btnMyProfileAction))
        self.navigationItem.leftBarButtonItem = btnProfile
        let img1 = UIImage(named: "camera_icon")
        let btnCamera = UIBarButtonItem(image: img1, style: .plain, target: self, action: #selector(self.btnCameraAction))
        self.navigationItem.rightBarButtonItem = btnCamera
        let img2 = UIImage(named: "home_icon_active")
        let btnHome = UIButton(type: .custom)
        btnHome.setImage(img2, for: .normal)
        self.navigationItem.titleView = btnHome
    }
    
    @objc func btnMyProfileAction(){
        
    }
    @objc func btnCameraAction(){
        
    }
    @objc func btnHomeAction(){
        
    }
    
}

// MARK: - UINavigationController

extension UINavigationController {
    
    /**
     Pop current view controller to previous view controller.
     
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func pop(transitionType type: String = kCATransitionFade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.popViewController(animated: false)
    }
    
    /**
     Push a new view controller on the view controllers's stack.
     - parameter vc:       view controller to push.
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func push(viewController vc: UIViewController, transitionType type: String = kCATransitionFade, duration: CFTimeInterval = 0.5) {
        self.addTransition(transitionType: type, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    func flipPush(viewController vc: UIViewController, transitionType type: String = "cube", duration: CFTimeInterval = 0.8) {
        self.addFlipTransition(transitionType: type, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    private func addTransition(transitionType type: String = "rippleEffect", duration: CFTimeInterval = 0.5) {
    
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = "rippleEffect"
        self.view.layer.add(transition, forKey: nil)
    }
    
    private func addFlipTransition(transitionType type: String = "cube", duration: CFTimeInterval = 0.8) {
       
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = type
        transition.subtype = kCATransitionFromRight
        self.view.layer.add(transition, forKey: nil)
        
    }
    
    func pushNormal(viewController vc: UIViewController){
        self.pushViewController(vc, animated: true)
    }
    func popNormal(){
        self.popViewController(animated: true)
    }
}


// MARK: UIKIT
extension UITextField {
    func shake() {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = 5
        animation.duration = 0.1
        animation.autoreverses = true
        animation.byValue = -5
        layer.add(animation, forKey: "shake")
    }
    
    func placeholderColor(){
        self.attributedPlaceholder = NSAttributedString(string: "placeholder text",
                                                        attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
}

extension UILabel {
    func addAnimation(){
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = 0.75
        self.layer.add(animation, forKey: "kCATransitionFade")
    }
    
    func addGradientBackground(){
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.red, UIColor.blue, UIColor.red, UIColor.blue]
        self.layer.insertSublayer(gradient, at: 0)
    }
}



extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
           
            newSize =  CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height:  newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
