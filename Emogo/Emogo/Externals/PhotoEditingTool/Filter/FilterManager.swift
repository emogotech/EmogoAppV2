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
    case Gradient1 = "filter_gradient_1.png"
    case Gradient2 = "filter_gradient_2.png"
    case Gradient3 = "filter_gradient_3.png"
    case Gradient4 = "filter_gradient_4.png"
    case Gradient5 = "filter_gradient_5.png"
    case Gradient6 = "filter_gradient_6.png"
    case Gradient7 = "filter_gradient_7.png"

    
    static let allValues = [Mosaic, scream, Muse,Udanie,Candy,Feathers,Normal,Chrome,Fade,Instant,Mono,Noir,Process,Tonal,Transfer,Tone,Linear,Gradient1,Gradient2,Gradient3,Gradient4,Gradient5,Gradient6,Gradient7]
    
}


class FilterManager: NSObject {
    
    
    fileprivate var image:UIImage!
    fileprivate var smallImage:UIImage!
    fileprivate var filterType:ApplyFilter!
    fileprivate let context = CIContext(options: nil)
    
    typealias SuccessHandler = (_ originalImage: UIImage?, _ previewImage: UIImage?) -> ()
    
    var ResultHandler:SuccessHandler!
    
    override init() {
        super.init()
    }
    
    
    func applyFilter(filterName:String,image:UIImage, completionHandler:@escaping (_ originalImage:UIImage?, _ previewImage:UIImage?)->Void) {
        self.image = image
        print(filterName)
       // self.smallImage = self.resizeImage(image: image)
        self.ResultHandler = completionHandler
        let numbersRange = filterName.rangeOfCharacter(from: .decimalDigits)
        let hasNumbers = (numbersRange != nil)
        let anEnum = ApplyFilter(rawValue: filterName)!
        self.filterType = anEnum
        if filterName.contains(".png") {
            let frontImage = UIImage(named: filterName)
            let originalImage = image.mergedImageWith(frontImage: frontImage!)
            completionHandler(originalImage,originalImage)
        }else if hasNumbers {
            
            if #available(iOS 11.0, *) {
                StyleArt.shared.process(image: self.image, style: ArtStyle(rawValue: self.filterType.hashValue)!) { (originalImage) in
                    completionHandler(originalImage ?? nil, originalImage ?? nil)
                }
            } else {
                // Fallback on earlier versions
                completionHandler(nil,nil)
            }
            
        }else {
            let originalImage = createFilteredImage(filterName: filterName, image: self.image)
           // let previewImage = createFilteredImage(filterName: filterName, image: self.smallImage)
            completionHandler(originalImage,originalImage)
        }
        
    }
    
    func getOriginalImage(filterName:String,image:UIImage, completionHandler:@escaping (_ originalImage:UIImage?)->Void){
        
    }
    
    
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        if filter == nil {
            return image
        }
        
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
