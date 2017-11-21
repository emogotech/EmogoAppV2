//
//  HUDManager.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class HUDManager: NSObject {
    
    var overlayView         : UIView = UIView()
    
    class var sharedInstance: HUDManager {
        struct Static {
            static let instance: HUDManager = HUDManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }
    
    let activityIndicator : PMProgressHUD = {
        let view = PMProgressHUD(frame: CGRect.zero)
        view.imgLogo = UIImage(named:"loader")!
        view.firstColor = UIColor(r: 0, g: 173.0, b: 243.0)
        view.secondColor = UIColor(r: 0, g: 173.0, b: 243.0)
        view.thirdColor = UIColor(r: 0, g: 173.0, b: 243.0)
        view.duration = 2.5
        view.lineWidth = 5.0
        view.bgColor =  UIColor.black.withAlphaComponent(0.5)
        
        return view
    }()
    
    func showHUD(){
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.activityIndicator.show()
    }
    func hideHUD(){
        UIApplication.shared.endIgnoringInteractionEvents()
        self.activityIndicator.hide()
    }
    
}
