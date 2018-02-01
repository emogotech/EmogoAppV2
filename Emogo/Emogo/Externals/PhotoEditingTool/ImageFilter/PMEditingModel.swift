//
//  PMEditingModel.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation



class PMEditingModel {
    var defaultValue : Float = 0
    var currentValue : Float = 0
    var minValue     : Float = -100
    var maxValue     : Float = 100
    var lastValue    : Float = 0.0
  
    var type:FilterType!
    init(type:FilterType) {
        self.type = type
    }
    
    class func saturationItem () -> PMEditingModel  {
        let newItem = PMEditingModel(type: .saturation)
        return newItem
    }
    
    class func brightnessItem () -> PMEditingModel  {
        let newItem = PMEditingModel(type: .brightness)

        return newItem
    }
    
    class func contrastItem () -> PMEditingModel  {
        let newItem = PMEditingModel(type: .contrast)
        return newItem
    }
    class func blurItem () -> PMEditingModel  {
        let newItem = PMEditingModel(type: .blur)
        return newItem
    }
    
    
    class func sharpenItem () -> PMEditingModel  {
        let newItem = PMEditingModel(type: .sharpen)
        return newItem
    }
    
    
    class func structureItem () -> PMEditingModel  {
        let newItem = PMEditingModel(type: .structure)
        return newItem
    }
    
    class func warmthItem () -> PMEditingModel  {
        let newItem = PMEditingModel(type: .warmth)
        return newItem
    }
    
    
    func reset ()
    {
        self.currentValue = self.defaultValue
    }
}



