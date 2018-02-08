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
    
    init() {
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
        arrayGradient.removeAll()
        for i in 0...6
        {
            let img = UIImage(named: "filter_gradient_\(i+1)_icon.png")
            let menu1 = Filter(icon: img!, name: "")
            arrayGradient.append(menu1)
        }

    }
    
}

class Filter {
    var icon:UIImage!
    var iconName:String! = ""
    init(icon:UIImage, name:String) {
        self.icon = icon
        self.iconName = name
    }
}
