//
//  Animation.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import QuartzCore
//import Haptica

class Animation: NSObject {

    
  class func viewSlideInFromRightToLeft(view: UICollectionView) {
        var transition: CATransition? = nil
        transition = CATransition()
        transition!.duration = 0.5
        transition!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition!.type = kCATransitionPush
        transition!.subtype = kCATransitionFromRight
        view.layer.add(transition!, forKey: nil)
    }
   class func viewSlideInFromLeftToRight(view: UICollectionView) {
        var transition: CATransition? = nil
        transition = CATransition()
        transition!.duration = 0.5
    
        transition!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition!.type = kCATransitionPush
        transition!.subtype = kCATransitionFromLeft
        view.layer.add(transition!, forKey: nil)
    }
    
   class func viewSlideInFromTopToBottom(views: UIView) {
        var transition: CATransition? = nil
        transition = CATransition()
        transition!.duration = 0.5
        transition!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition!.type = kCATransitionPush
        transition!.subtype = kCATransitionFromTop
        views.layer.add(transition!, forKey: nil)
    }
  class func viewSlideInFromBottomToTop(views: UIView) {
        var transition: CATransition? = nil
        transition = CATransition()
        transition!.duration = 0.5
        transition!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition!.type = kCATransitionPush
        transition!.subtype = kCATransitionFromBottom
        views.layer.add(transition!, forKey: nil)
    }
    
    
   class func addRightTransitionImage(imgV:UIImageView){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        
        transition.subtype = kCATransitionFromRight
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
    class func addRightTransitionCollection(imgV:UICollectionView){
//        if kDefault?.bool(forKey: kHapticFeedback) == true{
//            Haptic.impact(.light).generate()
//        }else{
//
//        }
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
    class func addLeftTransitionCollection(imgV:UICollectionView){
//        if kDefault?.bool(forKey: kHapticFeedback) == true{
//            Haptic.impact(.light).generate()
//        }else{
//
//        }
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
  class  func addLeftTransitionImage(imgV:UIImageView){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
    class func addRightTransition(collection:UICollectionView){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        collection.layer.add(transition, forKey: kCATransition)
    }
    
    class  func addLeftTransition(collection:UICollectionView){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        collection.layer.add(transition, forKey: kCATransition)
    }
    
}
