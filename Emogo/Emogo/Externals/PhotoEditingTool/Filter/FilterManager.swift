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
    
    
    private let filters: [PMFilter] = [
        MosaicFilter(),
        TheScreamFilter(),
        LaMuseFilter(),
        UdnieFilter(),
        CandyFilter(),
        FeathersFilter(),
        ]
    
    private var imageBuffer: ImageBuffer?
    
    private var renderedFilterBuffer: [String: ImageBuffer] = [:]
    
    
    init(image:UIImage) {
        super.init()
        self.image = image
        self.getPreviewImage()
    }
    
    func getPreviewImage() {
        if self.image != nil {
            self.smallImage = self.resizeImage(image: self.image)
            if #available(iOS 11.0, *) {
                let resizedImage = image.resize(to: CGSize(width: 720, height: 720))
                imageBuffer = resizedImage.buffer()
                self.loadRenderedImages()
            }
        }
    }
    
    private func loadRenderedImages() {
        renderedFilterBuffer.removeAll()
        guard let buffer = imageBuffer else {
            return
        }
        
        filters.forEach { (filter) in
            if let filteredBuffer = filter.render(from: buffer) {
                renderedFilterBuffer[filter.name] = filteredBuffer
            }
        }
        
    }
    
    func applyFilter(filterName:String, completionHandler:@escaping (_ originalImage:UIImage?, _ previewImage:UIImage?)->Void) {
        print(filterName)
        // self.smallImage = self.resizeImage(image: image)
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
                if let  index = Int(filterName) {
                    let filter = filters[index]
                    if let buffer = renderedFilterBuffer[filter.name] {
                        imageBuffer = buffer
                    }
                    guard let imageBuffer = imageBuffer else {
                        return
                    }
                    let image = UIImage(imageBuffer: imageBuffer)
                    completionHandler(image,image)
                }
                
            } else {
                // Fallback on earlier versions
                completionHandler(nil,nil)
            }
            
        }else {
            // self.smallImage = self.resizeImage(image: image)
            let originalImage = createFilteredImage(filterName: filterName, image: self.image)
            // let previewImage = createFilteredImage(filterName: filterName, image: self.smallImage)
            completionHandler(originalImage,originalImage)
        }
        
    }
    
    func getOriginalImage(filterName:String,image:UIImage, completionHandler:@escaping (_ originalImage:UIImage?)->Void){
        
    }
    
    
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        // 1 - create source image
        
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: image)
        let filter = CIFilter(name: filterName )
        filter?.setDefaults()
        if filter == nil {
            return image
        }
        filter!.setDefaults()
        filter!.setValue(coreImage, forKey: kCIInputImageKey)
        let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
        let filteredImage = UIImage(cgImage: filteredImageRef!)
        return filteredImage
        
        /*
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
         */
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
