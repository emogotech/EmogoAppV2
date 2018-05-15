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
    
    var cache = NSCache<UIImage, AnyObject>()
    
    class var sharedInstance : FilterManager {
        struct Static {
            static let instance : FilterManager = FilterManager()
        }
        return Static.instance
    }
    
    
    
    func imageFor(obj: Filter,buffer:ImageBuffer?,image:UIImage, completionHandler:@escaping (_ image: Filter?) -> ()) {
        
        var objFilter:Filter?
        let data: UIImage? = self.cache.object(forKey: (obj.key as AnyObject) as! UIImage) as? UIImage
        
        if let imageData = data {
            objFilter = Filter(icon: imageData, name: obj.iconName)
            objFilter?.key = obj.key
            DispatchQueue.main.async {
                completionHandler(objFilter)
            }
            return
        }
        
        let value:String = obj.key
        let numbersRange = value.rangeOfCharacter(from: .decimalDigits)
        let hasNumbers = (numbersRange != nil)
        if value.contains(".png") {
            if let frontImage = UIImage(named: value) {
                let filterImage = image.mergedImageWith(frontImage: frontImage)
                self.cache.setObject(filterImage, forKey: (value as AnyObject) as! UIImage)
                objFilter = Filter(icon: filterImage, name: obj.iconName)
                objFilter?.key = obj.key
                DispatchQueue.main.async {
                    completionHandler(objFilter)
                }
            }
            
        }else if hasNumbers {
            if buffer != nil {
                let filterImage = UIImage(imageBuffer: buffer!)
                self.cache.setObject(filterImage!, forKey: (value as AnyObject) as! UIImage)
                objFilter = Filter(icon: filterImage, name: obj.iconName)
                objFilter?.key = obj.key
                DispatchQueue.main.async {
                    completionHandler(objFilter)
                }
            }
        }else {
            let filterImage  = image.createFilteredImage(filterName: value)
            self.cache.setObject(filterImage, forKey: (value as AnyObject) as! UIImage)
            objFilter = Filter(icon: filterImage, name: obj.iconName)
            objFilter?.key = obj.key
            DispatchQueue.main.async {
                completionHandler(objFilter)
            }
        }
        
    
    }
}
