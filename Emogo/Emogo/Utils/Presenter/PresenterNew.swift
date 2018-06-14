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
        let size = UIScreen.main.bounds.size.height - 657
        print(size)
        let width = ModalSize.full
        let height = ModalSize.custom(size: 667)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: size ))
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
        customPresenter.backgroundOpacity = 1.0
        customPresenter.dismissOnSwipe = true
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
    
}
