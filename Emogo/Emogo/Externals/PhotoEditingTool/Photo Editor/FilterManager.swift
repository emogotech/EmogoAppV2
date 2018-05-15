//
//  FilterManager.swift
//  Emogo
//
//  Created by Pushpendra on 15/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class FilterManager {
    
    let cache = NSCache<NSString, UIImage>()

    class var sharedInstance : FilterManager {
        struct Static {
            static let instance : FilterManager = FilterManager()
        }
        return Static.instance
    }
    
    
    
    func imageFor(obj: Filter,buffer:ImageBuffer?,image:UIImage, completionHandler:@escaping (_ image: Filter?) -> ()) {
        
        var objFilter:Filter?
        let data: UIImage? = self.cache.object(forKey: (obj.key as NSString))
        
        if let imageData = data {
            objFilter = Filter(icon: imageData, name: obj.iconName)
            objFilter?.key = obj.key
            DispatchQueue.main.async {
                completionHandler(objFilter)
            }
            return
        }
        DispatchQueue.global(qos: .default).async {

        let value:String = obj.key
        let numbersRange = value.rangeOfCharacter(from: .decimalDigits)
        let hasNumbers = (numbersRange != nil)
        if value.contains(".png") {
            if let frontImage = UIImage(named: value) {
                let filterImage = image.mergedImageWith(frontImage: frontImage)
                self.cache.setObject(filterImage, forKey: (obj.key as NSString))
                objFilter = Filter(icon: filterImage, name: obj.iconName)
                objFilter?.key = obj.key
                DispatchQueue.main.async {
                    completionHandler(objFilter)
                }
            }
            
        }else if hasNumbers {
            if buffer != nil {
                let filterImage = UIImage(imageBuffer: buffer!)
                self.cache.setObject(filterImage!, forKey: (obj.key as NSString))
                objFilter = Filter(icon: filterImage, name: obj.iconName)
                objFilter?.key = obj.key
                DispatchQueue.main.async {
                    completionHandler(objFilter)
                }
            }
        }else {
            let filterImage  = image.createFilteredImage(filterName: value)
            self.cache.setObject(filterImage, forKey: (obj.key as NSString))
            objFilter = Filter(icon: filterImage, name: obj.iconName)
            objFilter?.key = obj.key
            DispatchQueue.main.async {
                completionHandler(objFilter)
            }
        }
        
    
    }
    }
}
