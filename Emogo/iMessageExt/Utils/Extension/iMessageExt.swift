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
// MARK: - UIColor
extension UIColor {
    
    convenience init (r : CGFloat , g : CGFloat , b : CGFloat ) {
        self.init(red: r / 255.0 , green: g / 255.0 , blue: b / 255.0 , alpha: 1.0)
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
// MARK: - UIView
extension UIView {
    
    func addBlurView(style:UIBlurEffectStyle? = .dark){
        self.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style!)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect.zero
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.tag = 828748374
        if let viewWithTag = self.viewWithTag(828748374) {
            viewWithTag.removeFromSuperview()
        }
        self.insertSubview(blurView, at: 0)
        
        blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        //        blurView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //        blurView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
    }
    func addBlurView(){
        self.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect.zero
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.tag = 828748374
        if let viewWithTag = self.viewWithTag(828748374) {
            viewWithTag.removeFromSuperview()
        }
        self.insertSubview(blurView, at: 0)
        
        blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        //        blurView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //        blurView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
    }
    
    func setTopCurve(){
        let offset = CGFloat(self.frame.size.height/4)
        let bounds = self.bounds
        let rectBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height/2  , width:  bounds.size.width, height: bounds.size.height / 2)
        let rectPath = UIBezierPath(rect: rectBounds)
        let ovalBounds = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        self.layer.mask = maskLayer
    }
}

let imageCaches = NSCache<AnyObject, AnyObject>()
typealias CompletionHandlers = (_ success:Bool, _ image:FLAnimatedImage?) -> Void

extension FLAnimatedImageView {
    func loadImageUsingCacheWithUrlString(_ urlString: String,completionHandler: @escaping CompletionHandlers) {
        
        self.animatedImage = nil
        
        //check cache for image first
        if let cachedImage = imageCaches.object(forKey: urlString as AnyObject) as? FLAnimatedImage {
            self.animatedImage = cachedImage
            completionHandler(true, self.animatedImage!)
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                completionHandler(false,nil)
                return
            }
            
            DispatchQueue.main.async(execute: {
                if let downloadedImage = FLAnimatedImage(animatedGIFData: data!) {
                    imageCaches.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.animatedImage = downloadedImage
                    completionHandler(true,self.animatedImage!)
                }
            })
            
        }).resume()
        
    }
    
    
    func setForAnimatedImage(strImage:String){
        if strImage.isEmpty{
            return
        }
        let imgURL = URL(string: strImage.stringByAddingPercentEncodingForURLQueryParameter()!)!
        self.setImageUrl(imgURL)
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
        transition.duration = 1.0
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = "rippleEffect"
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    func addRightTransitionImage(imgV:UIImageView){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
    func addLeftTransitionImage(imgV:UIImageView){
        let transition = CATransition()
        transition.duration = 0.3
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

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
    var heightOfLbl: CGFloat {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: CGFloat = CGFloat(lroundf(Float(self.sizeThatFits(textSize).height)))
        return rHeight
    }
    var isTruncated: Bool {
        guard let labelText = text else {
            return false
        }
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size
        return labelTextSize.height > bounds.size.height
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


