//
//  FilterDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class FilterDAO {
    var arrayMenu = [Filter]()
    var arrayGradient = [Filter]()
    var arrayFilters  = [[String:String]]()
    let deviceName = UIDevice.current.modelName

    init() {
        print("Device name--->\(deviceName)")
        self.prepareData()
        prepareGradientData()
    }
    
    private func prepareData(){
        arrayMenu.removeAll()
        let menu1 = Filter(icon: #imageLiteral(resourceName: "brigtness-effect-icon"), name: "Brightness")
        arrayMenu.append(menu1)
        let menu2 = Filter(icon: #imageLiteral(resourceName: "contrast-effect-icon"), name: "Contrast")
        arrayMenu.append(menu2)
        let menu3 = Filter(icon: #imageLiteral(resourceName: "blur-effect-icon"), name: "Blur")
        arrayMenu.append(menu3)
        let menu4 = Filter(icon:#imageLiteral(resourceName: "saturation-effect-icon"), name: "Saturation")
        arrayMenu.append(menu4)
        let menu6 = Filter(icon: #imageLiteral(resourceName: "sharpen_icon"), name: "Sharpen")
        arrayMenu.append(menu6)
        let menu7 = Filter(icon: #imageLiteral(resourceName: "structure_icon"), name: "Structure")
        arrayMenu.append(menu7)
        let menu8 = Filter(icon: #imageLiteral(resourceName: "warmth_icon"), name: "Warmth")
        arrayMenu.append(menu8)
    }
    
    private func prepareGradientData(){
    
        self.arrayFilters = [
            ["name":"Normal","value":"No Filter"],
            ["name":"Chrome","value":"CIPhotoEffectChrome"],
            ["name":"Fade","value":"CIPhotoEffectFade"],
            ["name":"Instant","value":"CIPhotoEffectInstant"],
            ["name":"Mono","value":"CIPhotoEffectMono"],
            ["name":"Noir","value":"CIPhotoEffectNoir"],
            ["name":"Process","value":"CIPhotoEffectProcess"],
            ["name":"Tonal","value":"CIPhotoEffectTonal"],
            ["name":"Transfer","value":"CIPhotoEffectTransfer"],
            ["name":"Tone","value":"CILinearToSRGBToneCurve"],
            ["name":"Linear","value":"CISRGBToneCurveToLinear"],
            ["name":"Gradient1","value":"filter_gradient_1.png"],
            ["name":"Gradient2","value":"filter_gradient_2.png"],
            ["name":"Gradient3","value":"filter_gradient_3.png"],
            ["name":"Gradient4","value":"filter_gradient_4.png"],
            ["name":"Gradient5","value":"filter_gradient_5.png"],
            ["name":"Gradient6","value":"filter_gradient_6.png"],
            ["name":"Gradient7","value":"filter_gradient_7.png"]
        ]
    }
        
    
}

class Filter {
    var icon:UIImage?
    var iconName:String! = ""
    var key:String! = ""
    init(icon:UIImage?, name:String) {
        self.icon = icon
        self.iconName = name
    }
}

