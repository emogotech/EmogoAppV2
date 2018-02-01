//
//  PMPhotoEditingManager.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Foundation
import OpenGLES
enum FilterType:String {
    case saturation = "saturation"
    case brightness = "brightness"
    case contrast = "contrast"
    case blur = "blur"
    case structure = "structure"
    case tiltShift = "tiltShift"
    case sharpen = "sharpen"
    case warmth = "warmth"
    case cancel  = "cancel"
}

class PMPhotoEditingManager: NSObject {

    
    lazy var adjustmentItems : [PMEditingModel] =
        {
            return [PMEditingModel.brightnessItem(),
                    PMEditingModel.contrastItem(),
                    PMEditingModel.blurItem(),
                    PMEditingModel.saturationItem(),PMEditingModel.sharpenItem(),PMEditingModel.structureItem(),PMEditingModel.warmthItem()]
    }()

    var defaultImage                             : UIImage? = nil
    var tempAdjustmentImage                      : UIImage? = nil
    var modifiedImage                            : UIImage? = nil
    
    
    var colorControlFilter : CIFilter? = nil
    
    var saturationMetal : AGImageChain? = nil
    
    
    var ciContext : CIContext? = nil
    var coreImage : CIImage? = nil
    
    open class func  create() -> PMPhotoEditingManager
    {
        let service = PMPhotoEditingManager()
        return service
    }
    
    func setImage (image : UIImage) {
        self.modifiedImage = image
        self.defaultImage = image
         self.configureCIContext()
    }
    
    
    func applyFilterFor (adjustmentItem : PMEditingModel) -> UIImage? {
        guard let image = self.modifiedImage else {
            return nil
        }
        if (tempAdjustmentImage == nil) { self.tempAdjustmentImage = image }
        
        switch adjustmentItem.type {
        case .cancel:
            self.removeAllFilters()
            return self.defaultImage
        default:
            self.applyFilters()
        }
        return self.tempAdjustmentImage
    }
    
    func applyFilterImage (adjustmentItem : PMEditingModel) {
        adjustmentItem.lastValue = adjustmentItem.currentValue
    }
    
    func removeAllFilters ()  {
        self.modifiedImage = self.defaultImage
        self.tempAdjustmentImage = nil
        for adjustmentItem in self.adjustmentItems {
            adjustmentItem.reset()
        }
    }
    
    @discardableResult
    func applyFilters () -> UIImage?  {
//        guard let image = self.modifiedImage else {
//            return nil
//        }
//        if AGImageChain.isMetalAvailable() {
//            return self.applyMetalFilter(image: image)
//        }
        return self.applyCoreImageFilter()
    }
    
    
    fileprivate func applyMetalFilter (image : UIImage) -> UIImage {
        let processMetal = AGImageChain.init(image: image)
        
        self.adjustmentItems.forEach {
            if $0.currentValue != $0.defaultValue {
                switch $0.type {
                case .saturation:
                    processMetal.saturation(color: $0.currentValue / 100 + 1.0)
                case .brightness:
                    processMetal.brightness(($0.currentValue / 100) / 4)
                case .contrast:
                    processMetal.contrast(($0.currentValue / 100.0) / 4 + 1.0)
                case .blur:
                    processMetal.blur($0.currentValue / 2)
                case .structure:
                    processMetal.details($0.currentValue / 60)
                case .sharpen:
                    processMetal.sharpen($0.currentValue / 60)
                case .warmth:
                    processMetal.softLightFilter(Int($0.currentValue / 3))
              
                default:
                    break
                }
            }
        }
        guard let adjustmentImage = processMetal.image() else { return image }
        self.tempAdjustmentImage = adjustmentImage
        return self.tempAdjustmentImage!
    }
    
  
    
    func posterImage () -> UIImage {
        guard let mainImage = self.applyFilters() else {
            return UIImage()
        }
        self.cleanService()
        return mainImage
    }
    
    @discardableResult
    func applyCoreImageFilter() -> UIImage? {
        
        guard let ciImage = self.imageWithCIFilters()  else { return nil }
        
        guard let cgImageResult = self.ciContext?.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        let result = UIImage.init(cgImage: cgImageResult)
        
        self.tempAdjustmentImage = result
        
        return result
    }
    
    
    fileprivate func imageWithCIFilters () -> CIImage? {
        guard let ciImage = self.coreImage else { return nil }
        
        var newCIImage : CIImage? = ciImage
        
        self.adjustmentItems.forEach {
            if $0.currentValue != $0.defaultValue {
                switch $0.type {
                case .saturation :
                    newCIImage = self.addCIFilter(image: newCIImage,
                                                  coreImageFilter: "CIColorControls",
                                                  filterKeys: [kCIInputSaturationKey : $0.currentValue / 100 + 1.0])
                    print("saturationType-----\($0.currentValue / 100 + 1.0)")

                case .brightness:
                    newCIImage = self.addCIFilter(image: newCIImage,
                                                  coreImageFilter: "CIColorControls",
                                                  filterKeys: [kCIInputBrightnessKey : ($0.currentValue / 100) / 4 ])
                case .contrast:
                    newCIImage = self.addCIFilter(image: newCIImage,
                                                  coreImageFilter: "CIColorControls",
                                                  filterKeys: [kCIInputContrastKey : ($0.currentValue / 100.0) / 4 + 1.0])
                    
        
                case .blur:
                    newCIImage = self.addCIFilter(image: newCIImage,
                                                  coreImageFilter: "CIBoxBlur",
                                                  filterKeys: [kCIInputRadiusKey : $0.currentValue / 4])
                    
                case .structure:
                    newCIImage = self.addCIFilter(image: newCIImage,
                                                  coreImageFilter: "CISharpenLuminance",
                                                  filterKeys: [kCIInputSharpnessKey : $0.currentValue / 50 + 0.4])
            
                case .sharpen:
                    newCIImage = self.addCIFilter(image: newCIImage,
                                                  coreImageFilter: "CIUnsharpMask",
                                                  filterKeys: [kCIInputRadiusKey : $0.currentValue])
                case .warmth:
                    let correctionValue = $0.currentValue / 200
                    let r: CGFloat = $0.currentValue > 0 ? CGFloat(1.0 + correctionValue) : CGFloat(1.0 + correctionValue)
                    let g: CGFloat = 1.0
                    let b: CGFloat = $0.currentValue < 0 ? CGFloat(1.0 - correctionValue) : CGFloat(1.0 - correctionValue)
                    let a: CGFloat = 1.0
                    newCIImage = self.addCIFilter(image: newCIImage,
                                                  coreImageFilter: "CIColorMatrix",
                                                  filterKeys: ["inputRVector" : CIVector(x:r, y:0, z:0, w:0),
                                                               "inputGVector" : CIVector(x:0, y:g, z:0, w:0),
                                                               "inputBVector" : CIVector(x:0, y:0, z:b, w:0),
                                                               "inputAVector" : CIVector(x:0, y:0, z:0, w:a),] )
                    
                    
                default:
                    break
                
            }
            }
        }
        return newCIImage
    }
    
    fileprivate func addCIFilter (image: CIImage?, coreImageFilter : String,  filterKeys: [String : Any] /*, value : Float*/) -> CIImage? {
        guard let image = image else { return nil }
        guard let filter = CIFilter(name: coreImageFilter) else { return image}
        filter.setValue(image, forKey: kCIInputImageKey)
        filterKeys.forEach {
            filter.setValue($0.value, forKey: $0.key)
        }
        return filter.value(forKey: kCIOutputImageKey) as? CIImage
    }
    
    fileprivate func configureCIContext () {
        if self.ciContext != nil {
            return
        }
        guard let image = self.modifiedImage else { return }
        guard let cgimg = image.cgImage else { return }
        
        self.coreImage = CIImage(cgImage: cgimg)
        let openGLContext = EAGLContext(api: .openGLES2)
        self.ciContext = CIContext.init(eaglContext: openGLContext!, options: [kCIContextPriorityRequestLow: true])
    }
    
    fileprivate func cleanService () {
        self.removeAllFilters()
        self.ciContext = nil
        self.coreImage = nil
        self.defaultImage = nil
        self.modifiedImage = nil
    }
}
