//
//  FilterManager.swift
//  ImageEditing
//
//  Created by Pushpendra on 02/05/18.
//  Copyright © 2018 Pushpendra. All rights reserved.
//

import UIKit
import Foundation

protocol FilterManagerDelegate {
    func processImage(images:[GradientfilterDAO])
}
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
    static let allValues = [Mosaic, scream, Muse,Udanie,Candy,Feathers,Normal,Chrome,Fade,Instant,Mono,Noir,Process,Tonal,Transfer,Tone,Linear]

   
}


class FilterManager: NSObject {

    
   fileprivate var image:UIImage!
    fileprivate var filterType:ApplyFilter!
    fileprivate let context = CIContext(options: nil)
    var images = [GradientfilterDAO]()
    
    var filterDelegate:FilterManagerDelegate?

    init(image:UIImage) {
         super.init()
        self.image = image
        self.applyFilter()
    }
    
    
    func applyFilter() {
        
        let group = DispatchGroup()

        for category in ApplyFilter.allValues{
            print(category.rawValue)
            group.enter()
            self.processImages(name: category.rawValue, image: self.image) { (originalImage, previewImage) in
             
                if let originalImage = originalImage, let previewImage = previewImage {
                    let filter = GradientfilterDAO(name: category.rawValue, imgPreview: previewImage, imgOriginal: originalImage)
                    filter.name = "\(category)"
                    self.images.append(filter)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main, execute: {
            if self.filterDelegate != nil {
            self.filterDelegate?.processImage(images: self.images)
            }
        })
        
    }
    
    
    func processImages(name:String,image:UIImage, completionHandler:@escaping (_ originalImage:UIImage?, _ previewImage:UIImage?)->Void){
        let numbersRange = name.rangeOfCharacter(from: .decimalDigits)
        let smallImage = self.resizeImage(image: image)
        let hasNumbers = (numbersRange != nil)
        if hasNumbers {
            if #available(iOS 11.0, *) {
                StyleArt.shared.process(image: image, style: ArtStyle(rawValue: Int(name)!)!) { (originalImage) in
                    StyleArt.shared.process(image: smallImage , style: ArtStyle(rawValue: Int(name)!)!) { (previewImage) in
                       
                        completionHandler(originalImage,previewImage)
                    }
                }
            } else {
                // Fallback on earlier versions
                if self.filterDelegate != nil {
                    completionHandler(nil,nil)
                }
            }
        }else {
            let originalImage = createFilteredImage(filterName: name, image: image)
            let previewImage = createFilteredImage(filterName: name, image: smallImage)
            completionHandler(originalImage,previewImage)
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
        if filter == nil {
            return image
        }
        
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
