//
//  Extensions.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import Foundation
import UIKit


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







