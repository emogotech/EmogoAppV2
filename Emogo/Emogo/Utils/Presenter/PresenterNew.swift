//
//  PresenterNew.swift
//  Emogo
//
//  Created by Northout on 14/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Presentr

class PresenterNew: NSObject {

    static var instance : PresenterNew = {
        let instance  = PresenterNew()
        return instance
    }()
    
    //MARK:- All Presenter
    
    static let CreateStreamPresenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 30), sizeLandscape: Float(kFrame.size.width - 30))
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 30))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundOpacity = 0.85
        customPresenter.dismissOnSwipe = true
        customPresenter.blurBackground = false
        return customPresenter
    }()
    
  
    
    
    static let EditStreamPresenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 30), sizeLandscape: Float(kFrame.size.width - 30))
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 30))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundOpacity = 0.85
        customPresenter.dismissOnSwipe = false
        customPresenter.blurBackground = false
        return customPresenter
    }()
   
     static let ActionSheetPresenter: Presentr = {
        
         if deviceType.iPhoneX  {
            
            let width = ModalSize.full
            let height = ModalSize.customOrientation(sizePortrait: Float(415), sizeLandscape: Float(415))
            let cennterY = kFrame.size.height - 415
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = .coverVertical
            customPresenter.dismissTransitionType = .coverVertical
            customPresenter.roundCorners = true
            customPresenter.cornerRadius = 35.0
            customPresenter.backgroundOpacity = 0.85
            customPresenter.dismissOnSwipe = true
            customPresenter.blurBackground = false
            
            return customPresenter
            
         }else  if deviceType.iPhone6_6s{
            
            let width = ModalSize.full
            let height = ModalSize.customOrientation(sizePortrait: Float(380), sizeLandscape: Float(380))
            let cennterY = kFrame.size.height - 380
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = .coverVertical
            customPresenter.dismissTransitionType = .coverVertical
            customPresenter.roundCorners = true
            customPresenter.cornerRadius = 35.0
            customPresenter.backgroundOpacity = 0.85
            customPresenter.dismissOnSwipe = true
            customPresenter.blurBackground = false
            
            return customPresenter
            
         }else{
        
            let width = ModalSize.full
            let height = ModalSize.customOrientation(sizePortrait: Float(405), sizeLandscape: Float(405))
            let cennterY = kFrame.size.height - 405
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            let customPresenter = Presentr(presentationType: customType)
            customPresenter.transitionType = .coverVertical
            customPresenter.dismissTransitionType = .coverVertical
            customPresenter.roundCorners = true
            if  deviceType.iPhone5_5s {
                customPresenter.cornerRadius = 0.0
            }else {
                customPresenter.cornerRadius = 35.0
            }
          
            customPresenter.backgroundOpacity = 0.85
            customPresenter.dismissOnSwipe = true
            customPresenter.blurBackground = false
        
            return customPresenter
    }
    }()
    
        static let ActionSheetViewStreamPresenter: Presentr = {
            
            if deviceType.iPhoneX  {
                
                let width = ModalSize.full
                let height = ModalSize.customOrientation(sizePortrait: Float(320), sizeLandscape: Float(320))
                let cennterY = kFrame.size.height - 320
                let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
                let customType = PresentationType.custom(width: width, height: height, center: center)
                let customPresenter = Presentr(presentationType: customType)
                customPresenter.transitionType = .coverVertical
                customPresenter.dismissTransitionType = .coverVertical
                customPresenter.roundCorners = true
                customPresenter.cornerRadius = 35.0
                customPresenter.backgroundOpacity = 0.85
                customPresenter.dismissOnSwipe = true
                customPresenter.blurBackground = false
                
                return customPresenter
                
            }else  if deviceType.iPhone6_6s{
                
                let width = ModalSize.full
                let height = ModalSize.customOrientation(sizePortrait: Float(290), sizeLandscape: Float(290))//340
                let cennterY = kFrame.size.height - 290
                let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
                let customType = PresentationType.custom(width: width, height: height, center: center)
                let customPresenter = Presentr(presentationType: customType)
                customPresenter.transitionType = .coverVertical
                customPresenter.dismissTransitionType = .coverVertical
                customPresenter.roundCorners = true
                customPresenter.cornerRadius = 35.0
                customPresenter.backgroundOpacity = 0.85
                customPresenter.dismissOnSwipe = true
                customPresenter.blurBackground = false
                
                return customPresenter
                
            }else{
                
                let width = ModalSize.full
                let height = ModalSize.customOrientation(sizePortrait: Float(350), sizeLandscape: Float(350))
                let cennterY = kFrame.size.height - 350
                let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
                let customType = PresentationType.custom(width: width, height: height, center: center)
                let customPresenter = Presentr(presentationType: customType)
                customPresenter.transitionType = .coverVertical
                customPresenter.dismissTransitionType = .coverVertical
                customPresenter.roundCorners = true
                if  deviceType.iPhone5_5s {
                    customPresenter.cornerRadius = 0.0
                }else {
                    customPresenter.cornerRadius = 35.0
                }
                
                customPresenter.backgroundOpacity = 0.85
                customPresenter.dismissOnSwipe = true
                customPresenter.blurBackground = false
                
                return customPresenter
            }
       
        
    }()
    
    static let AddCollabPresenter: Presentr = {
        
        let width = ModalSize.full
        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 30), sizeLandscape: Float(kFrame.size.width - 30))
      
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 30))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundOpacity = 0.85
        customPresenter.dismissOnSwipe = true
        customPresenter.blurBackground = false
        return customPresenter
    }()
    
    
    let contentContainer: Presentr = {
        let width = ModalSize.full
        var height:ModalSize!
        var center:ModalCenterPosition!

        if #available(iOS 11, *), UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 60), sizeLandscape: Float(kFrame.size.width - 60))
             center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 60))

        }else {
            height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 30), sizeLandscape: Float(kFrame.size.width - 30))
             center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 30))
        }
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.blurBackground = false
        customPresenter.backgroundOpacity = 0.85
        customPresenter.dismissOnSwipe = true
        return customPresenter
    }()
    
    
    static let SettingPresenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.customOrientation(sizePortrait: Float(180), sizeLandscape: Float(180))
        let cennterY = kFrame.size.height - 180
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundOpacity = 0.85
        customPresenter.dismissOnSwipe = false
        customPresenter.blurBackground = false
        return customPresenter
    }()
}
