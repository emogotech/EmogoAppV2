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
         self.sd_setImage(with: imgURL, placeholderImage: UIImage(named: placeholder))
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
        self.navigationController?.navigationBar.barTintColor = kNavigationColor
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
    
    func configureProfileNavigation(){
     
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
        let img = UIImage(named: "forward_icon")
        let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.btnBackAction))
        self.navigationItem.rightBarButtonItem = btnback
        let btnLogout = UIBarButtonItem(image: #imageLiteral(resourceName: "logout_button"), style: .plain, target: self, action: #selector(self.btnLogoutAction))
        self.navigationItem.leftBarButtonItem = btnLogout

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
}



extension UIViewController:SFSafariViewControllerDelegate {
    func openURL(url:URL) {
        
            if #available(iOS 9.0, *) {
                let safariController = SFSafariViewController(url: url as URL)
                safariController.delegate = self
                
                let navigationController = UINavigationController(rootViewController: safariController)
                navigationController.setNavigationBarHidden(true, animated: false)
                self.present(navigationController, animated: true, completion: nil)
            } else {
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.openURL(url)
                }
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
    
    
    func getOrigianlImage(handler:@escaping (_ image:UIImage?)->Void){
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = false
        options.version = .current
        
        _ = PHCachingImageManager().requestImageData(for: self, options: options) { (imageData, dataUTI, orientation, info) in
            if let data = imageData {
                let image = UIImage(data: data)
                handler(image)
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
    
}
