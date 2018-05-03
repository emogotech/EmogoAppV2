//
//  FilterManager.swift
//  ImageEditing
//
//  Created by Pushpendra on 02/05/18.
//  Copyright © 2018 Pushpendra. All rights reserved.
//

import UIKit
import Foundation

enum ApplyFilter:String {
    case Mosaic = "0"
    case scream = "1"
    case Muse = "2"
    case Udanie = "3"
    case Candy = "4"
    case Feathers = "5"
    case Normal = "No Filter"
    case Chrome = "CIPhotoEffectChrome"
    case Fade = "CIPhotoEffectFade"
    case Instant = "CIPhotoEffectInstant"
    case Mono = "CIPhotoEffectMono"
    case Noir = "CIPhotoEffectNoir"
    case Process = "CIPhotoEffectProcess"
    case Tonal = "CIPhotoEffectTonal"
    case Transfer = "CIPhotoEffectTransfer"
    case Tone = "CILinearToSRGBToneCurve"
    case Linear = "CISRGBToneCurveToLinear"
   
}


class FilterManager: NSObject {

    
   fileprivate var image:UIImage!
    fileprivate var smallImage:UIImage!
    fileprivate var filterType:ApplyFilter!
    fileprivate let context = CIContext(options: nil)
    
    typealias SuccessHandler = (_ originalImage: UIImage?, _ previewImage: UIImage?) -> ()
    
    var ResultHandler:SuccessHandler!

    init(image:UIImage,type:ApplyFilter) {
         super.init()
        self.image = image
        self.filterType = type
        self.smallImage = self.resizeImage(image: image)
    }
    
    
    func applyFilter() {
        let filterName = filterType.rawValue
        
        let numbersRange = filterName.rangeOfCharacter(from: .decimalDigits)
        let hasNumbers = (numbersRange != nil)
        if hasNumbers {
            
            if #available(iOS 11.0, *) {
                StyleArt.shared.process(image: self.image, style: ArtStyle(rawValue: self.filterType.hashValue)!) { (originalImage) in
                    StyleArt.shared.process(image: self.smallImage, style: ArtStyle(rawValue: self.filterType.hashValue)!) { (previewImage) in
                        print(self.ResultHandler)
                        self.ResultHandler!(originalImage ?? nil, previewImage ?? nil)
                    }
                }
            } else {
                // Fallback on earlier versions
                self.ResultHandler!(nil,nil)
            }
    
        }else {
            let originalImage = createFilteredImage(filterName: filterName, image: self.image)
            let previewImage = createFilteredImage(filterName: filterName, image: self.smallImage)
            self.ResultHandler!(originalImage,previewImage)
        }
        
        
    }
    
    
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!)
        
        return filteredImage
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let ratio: CGFloat = 0.3
        let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
}
