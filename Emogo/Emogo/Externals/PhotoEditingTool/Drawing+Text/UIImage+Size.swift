//
//  UIImage+Size.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 5/2/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public extension UIImage {
    
    /**
     Suitable size for specific height or width to keep same image ratio
     */
    func suitableSize(heightLimit: CGFloat? = nil,
                             widthLimit: CGFloat? = nil )-> CGSize? {
        
        if let height = heightLimit {
            
            let width = (height / self.size.height) * self.size.width
            
            return CGSize(width: width, height: height)
        }
        
        if let width = widthLimit {
            let height = (width / self.size.width) * self.size.height
            return CGSize(width: width, height: height)
        }
        
        return nil
    }
    
    class func resizeImage(image: UIImage, targetSize: CGSize, alpha : CGFloat = 1.0) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        //            image.draw(in: rect)
        image.draw(in: rect, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func combineImages (images: [UIImage]) -> UIImage {
        var contextSize = CGSize.zero
        
        for image in images {
            contextSize.width = max(contextSize.width, image.size.width)
            contextSize.height = max(contextSize.height, image.size.height)
        }
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, UIScreen.main.scale)
        
        for image in images {
            let deltaWidth = contextSize.width / image.size.width
            let deltaHeight = contextSize.height / image.size.height
            
            let maxDelta = max(deltaWidth, deltaHeight)
            
            let originX = (contextSize.width - image.size.width * maxDelta) / 2
            let originY = (contextSize.height - image.size.height * maxDelta) / 2
            
            image.draw(in: CGRect(x : originX, y : originY, width : image.size.width * maxDelta, height : image.size.height * maxDelta))
        }
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return combinedImage!
    }
    
    func mergedImageWith(frontImage:UIImage) -> UIImage{
        
        let size = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        frontImage.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height), blendMode: .normal, alpha: 0.5)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func createFilteredImage(filterName: String) -> UIImage {
        // 1 - create source image
        
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: self)
        let filter = CIFilter(name: filterName )
        filter?.setDefaults()
        if filter == nil {
            return self
        }
        filter!.setDefaults()
        filter!.setValue(coreImage, forKey: kCIInputImageKey)
        let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
        let filteredImage = UIImage(cgImage: filteredImageRef!)
        return filteredImage
        
    }
    
    func resizeImage() -> UIImage {
        let image = self
        let ratio: CGFloat = 0.3
        let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
}
