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
        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 60), sizeLandscape: Float(kFrame.size.width - 60))
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 60))
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
        
        if UIDevice.current.modelName.lowercased().contains("iphone5") || UIDevice.current.modelName.lowercased().contains("iphone 5") {
            let width = ModalSize.full
            let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height -  150.0), sizeLandscape: Float(kFrame.size.width - 150.0))
            let cennterY = kFrame.size.height - (kFrame.size.height -  150.0)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
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
        }else {
           
            let width = ModalSize.full
            let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height/2.0 +  100.0), sizeLandscape: Float(kFrame.size.width/2.0 +  100.0))
            let cennterY = kFrame.size.height - (kFrame.size.height/2.0 +  100.0)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
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
        }
       
    }()
    
    static let AddCollabPresenter: Presentr = {
        
        let width = ModalSize.full
        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 30), sizeLandscape: Float(kFrame.size.width - 30))
       // let height:ModalSize!
       // var center:ModalCenterPosition!
        
//        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height/2.0 + 150.0), sizeLandscape: Float(kFrame.size.width/2.0 + 150.0))
//        let cennterY = kFrame.size.height - (kFrame.size.height/2.0 + 150.0)
       // let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
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
    
}
