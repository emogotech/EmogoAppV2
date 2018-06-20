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
        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 60), sizeLandscape: Float(kFrame.size.width - 60))
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 60))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundOpacity = 1.0
        customPresenter.dismissOnSwipe = true
        customPresenter.blurBackground = true
        customPresenter.blurStyle = UIBlurEffectStyle.light
        return customPresenter
    }()
    
    
    static let EditStreamPresenter: Presentr = {
        let size = UIScreen.main.bounds.size.height - 657
        let width = ModalSize.full
        let height = ModalSize.custom(size: 667)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: size ))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundColor = UIColor.clear
        customPresenter.backgroundOpacity = 0.8
        customPresenter.dismissOnSwipe = false
        customPresenter.blurBackground = true
        customPresenter.blurStyle = UIBlurEffectStyle.light
        
        
        return customPresenter
    }()
    
    static let ActionSheetPresenter: Presentr = {
        
        let customType = PresentationType.bottomHalf
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundOpacity = 1.0
        customPresenter.dismissOnSwipe = true
        customPresenter.blurBackground = true
        customPresenter.blurStyle = UIBlurEffectStyle.light
        
        
        return customPresenter
    }()
    
    static let AddCollabPresenter: Presentr = {
        
        let width = ModalSize.full
        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height/2.0 + 150.0), sizeLandscape: Float(kFrame.size.width/2.0 + 150.0))
        let cennterY = kFrame.size.height - (kFrame.size.height/2.0 + 150.0)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: cennterY))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundOpacity = 1.0
        customPresenter.dismissOnSwipe = true
        customPresenter.blurBackground = true
        customPresenter.blurStyle = UIBlurEffectStyle.light
        
        return customPresenter
    }()
    
    
    let contentContainer: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.customOrientation(sizePortrait: Float(kFrame.size.height - 30), sizeLandscape: Float(kFrame.size.width - 30))
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 30))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVerticalFromTop
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = true
        customPresenter.blurBackground = false
        customPresenter.backgroundOpacity = 1.0
        customPresenter.backgroundColor = UIColor.black
        customPresenter.dismissOnSwipe = true
        return customPresenter
    }()
    
}
