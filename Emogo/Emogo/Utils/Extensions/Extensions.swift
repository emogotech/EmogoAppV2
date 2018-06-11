//
//  Extensions.swift
//  Emogo
//
//  Created by Vikas Goyal on 15/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SDWebImage
import Photos
import MobileCoreServices
import SafariServices
import Imaginary



// MARK: - UIColor
extension UIColor {
    
    convenience init (r : CGFloat , g : CGFloat , b : CGFloat ) {
        self.init(red: r / 255.0 , green: g / 255.0 , blue: b / 255.0 , alpha: 1.0)
    }
    
}

// MARK: - UIView
extension UIView {
    
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
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    /*
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    */
    func stringByAddingPercentEncodingForURLQueryParameter() -> String? {
        let allowedCharacters = NSCharacterSet.urlQueryAllowed
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height:height )
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.width
    }
    
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    
    func MIMEType() -> String? {
        if !self.isEmpty {
            let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self as CFString, nil)
            let UTI = UTIRef?.takeUnretainedValue()
            UTIRef?.release()
            
            let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI!, kUTTagClassMIMEType)
            if MIMETypeRef != nil
            {
                let MIMEType = MIMETypeRef?.takeUnretainedValue()
                MIMETypeRef?.release()
                return MIMEType! as String
            }
        }
        return nil
    }
    
    
    func isImageType() -> Bool {
        // image formats which you want to check
        let imageFormats = ["jpg", "png", "jpeg"]
        
        if URL(string: self) != nil  {
            
            let extensi = (self as NSString).pathExtension
            
            return imageFormats.contains(extensi)
        }
        return false
    }
    
    
}




// MARK: - UIView
extension UIView {
    
    @discardableResult func addBorders(edges: UIRectEdge, color: UIColor = .green, thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

// MARK: - UIImageView
extension UIImageView {
    
    func setImageWithURL(strImage:String, placeholder:String){
        if strImage.isEmpty{
            return
        }
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setIndicatorStyle(.gray)
        let imgURL = URL(string: strImage.stringByAddingPercentEncodingForURLQueryParameter()!)!
        self.sd_setImage(with: imgURL, placeholderImage: #imageLiteral(resourceName: "stream-card-placeholder"))
    }
    
    
    func setImageWithURL(strImage:String,handler : @escaping ((_ image : UIImage?, _ imageSize:CGSize?) -> Void)){
        if strImage.isEmpty{
            return
        }
        let imgURL = URL(string: strImage.stringByAddingPercentEncodingForURLQueryParameter()!)!
        //self.sd_setImage(with: url)
        self.sd_setImage(with: imgURL, placeholderImage: nil, options: .cacheMemoryOnly) { (image, _, _, _) in
            if let img = image {
                self.image = img
                handler(img,img.size)
            }
        }
        
        //    self.sd_setImage(with: imgURL, placeholderImage: UIImage(named: placeholder))
        
    }
    
    func setOriginalImage(strImage:String, placeholder:String){
        if strImage.isEmpty{
            return
        }
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setIndicatorStyle(.gray)
        let imgURL = URL(string: strImage.stringByAddingPercentEncodingForURLQueryParameter()!)!
        self.sd_setImage(with: imgURL, placeholderImage: UIImage(named: placeholder))
    }
    
}

// MARK: - UIButton
extension UIButton {
    
}

// MARK: - UIButton

extension UIViewController {
    
    func hideStatusBar(){
        UIApplication.shared.isStatusBarHidden = true
    }
    
    func showStatusBar(){
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func showAlert(strMessage:String){
        let alert = UIAlertController(title: "Message", message: strMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (actoin) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showToast(type:AlertType = .success,strMSG:String) {
        if strMSG != "request failed" {
            
            AppDelegate.appDelegate.window?.makeToast(message: strMSG,
                                                      duration: TimeInterval(3.0),
                                                      position: .top,
                                                      image: nil,
                                                      backgroundColor: UIColor.black.withAlphaComponent(0.6),
                                                      titleColor: UIColor.yellow,
                                                      messageColor: UIColor.white,
                                                      font: nil)
            
            //            self.view.makeToast(message: strMSG,
            //                                duration: TimeInterval(3.0),
            //                                position: .top,
            //                                image: nil,
            //                                backgroundColor: UIColor.black.withAlphaComponent(0.6),
            //                                titleColor: UIColor.yellow,
            //                                messageColor: UIColor.white,
            //                                font: nil)
        }
        
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
        let btnHome = UIButton()
        btnHome.frame = CGRect(x: 0, y: 0, width: (img2?.size.width)!, height: (img2?.size.height)!)
        btnHome.setImage(img2, for: .normal)
        self.navigationItem.titleView = btnHome
     
    }
    
    func configureNavigationWithTitle(){
        //        var fontFamilies = UIFont.familyNames
        //        for i in 0..<fontFamilies.count {
        //            let fontFamily: String = fontFamilies[i]
        //            let fontNames = UIFont.fontNames(forFamilyName: fontFamilies[i])
        //            print("\(fontFamily): \(fontNames)")
        //        }
        var myAttribute2:[NSAttributedStringKey:Any]!
        if let font = UIFont(name: kFontBold, size: 20.0) {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: font]
        }else {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        let img = UIImage(named: "back_icon")
        let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.btnBackAction))
        self.navigationItem.leftBarButtonItem = btnback
    }
    
    func configureNavigationTite(){
        var myAttribute2:[NSAttributedStringKey:Any]!
        if let font = UIFont(name: kFontBold, size: 20.0) {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: font]
        }else {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = kNavigationColor
    }
    
    
    
    @objc func btnMyProfileAction(){
        
    }
    @objc func btnCameraAction(){
        
    }
    @objc func btnHomeAction(){
        
    }
    @objc func btnLogoutAction(){
        
    }
    
    @objc func btnBackAction(){
        self.navigationController?.pop()
    }
    func addLeftTransitionView(subtype:String){
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = subtype
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    func getShadowButton(Alignment:Int) -> UIButton {
        let button = UIButton(type: .custom)
       // button.backgroundColor = .red
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        button.layer.masksToBounds = false
      //  button.layer.cornerRadius = 10
        button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)//CGSize(width: 1.5, height: 1.5)
        button.layer.shadowRadius = 0.5
        button.layer.shadowOpacity = 1.0
        button.layer.shadowColor = UIColor.black.cgColor
        switch Alignment {
        case 0:
            button.contentHorizontalAlignment  = .left
            button.contentVerticalAlignment = .bottom
            break
        case 1:
            button.contentHorizontalAlignment  = .right
            button.contentVerticalAlignment = .bottom
            break
        case 2:
            button.contentHorizontalAlignment  = .right
            button.contentVerticalAlignment = .bottom
//            button.contentHorizontalAlignment  = .center
//            button.contentVerticalAlignment = .bottom
            break
        default:
            break
        }
        return button
    }
    
    func imageOrientation(_ src:UIImage)->UIImage {
        if src.imageOrientation == UIImageOrientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        
        return img
    }
}



extension UIViewController:SFSafariViewControllerDelegate {
    
    func canOpenURL(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        
        //
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func openURL(url:URL) {
        
        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            
            // Can open with SFSafariViewController
            let safariController = SFSafariViewController(url: url as URL)
            safariController.delegate = self
            
            let navigationController = UINavigationController(rootViewController: safariController)
            navigationController.setNavigationBarHidden(true, animated: false)
            self.present(navigationController, animated: true, completion: nil)
            
        } else {
            // Scheme is not supported or no scheme is given, use openURL
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @available(iOS 9.0, *)
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - UINavigationController

extension UINavigationController {
    
    /**
     Pop current view controller to previous view controller.
     
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func pop(transitionType type: String = kCATransitionFade, duration: CFTimeInterval = 0.8) {
        self.addTransition(transitionType: type, duration: duration)
        self.popViewController(animated: false)
    }
    
    /**
     Push a new view controller on the view controllers's stack.
     - parameter vc:       view controller to push.
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func push(viewController vc: UIViewController, transitionType type: String = kCATransitionFade, duration: CFTimeInterval = 0.8) {
        self.addTransition(transitionType: type, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    func flipPush(viewController vc: UIViewController, transitionType type: String = "cube", duration: CFTimeInterval = 0.8) {
        self.addFlipTransition(transitionType: type, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    func reverseFlipPush(viewController vc: UIViewController, transitionType type: String = "cube", duration: CFTimeInterval = 0.8) {
        self.addReverseFlipTransition(transitionType: type, duration: duration)
        let controllersArray = self.viewControllers
        var vcToPop : UIViewController!
        for currentVC in controllersArray {
            if currentVC.className == vc.className {
                vcToPop = currentVC
                break
            }
        }
        print("vcToPop" , vcToPop)
        if vcToPop != nil {
            self.popToViewController(vcToPop, animated: false)
        }else {
            self.pushViewController(vc, animated: false)
        }
    }
    private func addTransition(transitionType type: String = "rippleEffect", duration: CFTimeInterval = 0.8) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = "rippleEffect"
        self.view.layer.add(transition, forKey: nil)
    }
    
    private func addFlipTransition(transitionType type: String = "cube", duration: CFTimeInterval = 1.0) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = type
        transition.subtype = kCATransitionFromRight
        self.view.layer.add(transition, forKey: nil)
        
    }
    
    private func addReverseFlipTransition(transitionType type: String = "cube", duration: CFTimeInterval = 0.8) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = type
        transition.subtype = kCATransitionFromLeft
        self.view.layer.add(transition, forKey: nil)
    }
    
    
    func pushNormal(viewController vc: UIViewController){
        self.pushViewController(vc, animated: true)
    }
    func popNormal(){
        self.popViewController(animated: true)
    }
    
    func popToView(){
        self.addTransition()
        self.popViewController(animated: false)
    }
    
    func popToViewController(vc:UIViewController){
        
        let controllersArray = self.viewControllers
        //        let objContain: Bool = controllersArray.contains(where: { $0.className == vc.className })
        var vcToPop : UIViewController!
        for currentVC in controllersArray {
            if currentVC.className == vc.className {
                vcToPop = currentVC
                break
            }
        }
        print("vcToPop" , vcToPop)
        if vcToPop != nil {
            self.popToViewController(vcToPop, animated: true)
        }else {
            self.pushViewController(vc, animated: true)
        }
        
        
        //        for obj in self.viewControllers {
        //            if "\(obj)" ==  "\(vc)"  {
        //                isPop = true
        //                print("pop called")
        //                self.popToViewController(vc, animated: true)
        //                break
        //            }
        //        }
        //        if isPop == false {
        //            self.pushViewController(vc, animated: true)
        //        }
    }
    
    func pushAsPresent(viewController:UIViewController) {
        let animation = CATransition()
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromTop
        animation.duration = 0.65
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.view.layer.add(animation, forKey: "AnimationFromBottomToTop")
        self.pushViewController(viewController, animated: false)
    }
    func popViewAsDismiss(){
        let animation = CATransition()
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromBottom
        animation.duration = 0.65
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.view.layer.add(animation, forKey: "AnimationFromBottomToTop")
        self.popViewController(animated: false)
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
    
    func placeholderColor(text:String,color:UIColor){
        self.attributedPlaceholder = NSAttributedString(string: text,
                                                        attributes: [NSAttributedStringKey.foregroundColor: color])
    }
    
    func addShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 3.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
    }
    
    
}

extension UITextView {
    
    func addShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 3.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
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
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
    
   var calculateMaxLines:Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let lines = Int(textSize.height/charSize)
        return lines
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
    
    func shadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shouldRasterize = true
    }
    
}



extension UIImage {
    
     class func image(_ view: UIView) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
            defer { UIGraphicsEndImageContext() }
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
            return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        }
    
    func compressImageSwift () -> UIImage {
        
        let actualHeight:CGFloat = self.size.height
        let actualWidth:CGFloat = self.size.width
        let imgRatio:CGFloat = actualWidth/actualHeight
        let maxWidth:CGFloat = 1024.0
        let resizedHeight:CGFloat = maxWidth/imgRatio
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:NSData = UIImageJPEGRepresentation(img, compressionQuality)! as NSData
        UIGraphicsEndImageContext()
        var imageToUpload = UIImage(data: imageData as Data)!
        imageToUpload = imageToUpload.fixOrientation()
        return imageToUpload
    }
    
    func reduceSize() -> UIImage {
        
        guard let data = UIImageJPEGRepresentation(self, 1.0)  else {
            return self
        }
        let size =  Int(data.count/1024/1024)
        print(size)
        if size > 1 {
            return self.compressImage(self, compressRatio: 1.0)
        }else {
            return self
        }
        //        let bcf = ByteCountFormatter()
        //        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        //        bcf.countStyle = .file
        //        let str = bcf.string(fromByteCount: Int64(data.count))
        //        print("formatted result: \(str)")
    }
    
    func resize(targetSize:CGSize) -> UIImage {
        // Figure out what our orientation is, and use that to form the rectangle
        let newSize = targetSize
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height:  newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
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
    func resizeImage(targetSize: CGSize, alpha : CGFloat = 1.0) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        //            image.draw(in: rect)
        self.draw(in: rect, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func combineImages (images: [UIImage]) -> UIImage {
        var contextSize = CGSize.zero
        
        for image in images {
            contextSize.width = max(contextSize.width, image.size.width)
            contextSize.height = max(contextSize.height, image.size.height)
        }
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, UIScreen.main.scale)
        
        for image in images {
            let deltaWidth = contextSize.width / image.size.width
            let deltaHeight = contextSize.height / image.size.height
            
            let maxDelta = max(deltaWidth, deltaHeight)
            
            let originX = (contextSize.width - image.size.width * maxDelta) / 2
            let originY = (contextSize.height - image.size.height * maxDelta) / 2
            
            image.draw(in: CGRect(x : originX, y : originY, width : image.size.width * maxDelta, height : image.size.height * maxDelta))
        }
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return combinedImage!
    }
    
    
    
}

extension UITableViewController {
    func showToastOnWindow(strMSG:String) {
        
        AppDelegate.appDelegate.window?.makeToast(message: strMSG,
                                                  duration: TimeInterval(3.0),
                                                  position: .top,
                                                  image: nil,
                                                  backgroundColor: UIColor.black.withAlphaComponent(0.6),
                                                  titleColor: UIColor.white,
                                                  messageColor: UIColor.white,
                                                  font: nil)
        
    }
}



extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
    
    func getOrigianlImage(handler:@escaping (_ image:UIImage?, _ fileName:String?)->Void){
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true
        options.version = .current
        _ = PHCachingImageManager().requestImageData(for: self, options: options) { (imageData, dataUTI, orientation, info) in
            if let data = imageData {
                let image = UIImage(data: data)
                var fileName:String! = NSUUID().uuidString + ".png"
                if let file =  self.value(forKey: "filename"){
                    fileName = file as! String
                    handler(image,fileName)
                }
            }
        }
        
    }
    
}


extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()
typealias CompletionHandler = (_ success:Bool, _ image:FLAnimatedImage?) -> Void


extension FLAnimatedImageView {
    func loadImageUsingCacheWithUrlString(_ urlString: String,completionHandler: @escaping CompletionHandler) {
        
        self.animatedImage = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? FLAnimatedImage {
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
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
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

extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholderName: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
    
    func CGRectMake( x: CGFloat,  y: CGFloat,  width: CGFloat,  height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

extension UITableViewCell {
    
    func hideSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
    }
    
    func showSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}


public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}


