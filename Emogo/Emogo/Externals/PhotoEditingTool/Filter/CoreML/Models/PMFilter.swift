//
//  PMFilter.swift
//  Emogo
//
//  Created by Pushpendra on 09/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//


import Foundation
import UIKit

protocol PMFilter {
    /// Filter name.
    var name: String { get }
    
    /// Render - Feed the ML model with the given ImageBuffer and get the output of it.
    ///
    /// - Parameter from: Given image buffer (input) to the ML Model.
    /// - Returns: Output image buffer from the ML Model.
    func render(from: ImageBuffer) -> ImageBuffer?
    
}


/// Mosaic filter.

class MosaicFilter: PMFilter {
    
    let name: String = "Mosaic"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        if #available(iOS 11.0, *) {
            let model = FNSMosaic()
            let prediction = try? model.prediction(inputImage: from)
            
            return prediction?.outputImage
        } else {
            // Fallback on earlier versions
            return nil
        }
       
    }
    
}

/// La Muse filter.

class LaMuseFilter: PMFilter {
    
    let name: String = "La Muse"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        if #available(iOS 11.0, *) {
            let model = FNSLaMuse()
            let prediction = try? model.prediction(inputImage: from)
            
            return prediction?.outputImage
        } else {
            // Fallback on earlier versions
            return nil
        }
      
    }
}

/// The Scream filter.

class TheScreamFilter: PMFilter {
    
    let name: String = "The Scream"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        if #available(iOS 11.0, *) {
            let model = FNSTheScream()
            let prediction = try? model.prediction(inputImage: from)
            
            return prediction?.outputImage
        } else {
            // Fallback on earlier versions
            return nil
        }
        
    }
}

/// Candy filter.

class CandyFilter: PMFilter {
    
    let name: String = "Candy"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        if #available(iOS 11.0, *) {
            let model = FNSCandy()
            let prediction = try? model.prediction(inputImage: from)
            return prediction?.outputImage
        } else {
            // Fallback on earlier versions
            return nil
        }
       
    }
}

/// Udnie filter.

class UdnieFilter: PMFilter {
    
    let name: String = "Udnie"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        
        if #available(iOS 11.0, *) {
            let model = FNSUdnie()
            let prediction = try? model.prediction(inputImage: from)
            return prediction?.outputImage
        } else {
            // Fallback on earlier versions
            return nil
        }
        
    }
}


class FeathersFilter: PMFilter {
    
    let name: String = "Feathers"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        
        if #available(iOS 11.0, *) {
            let model = FNSFeathers()
            let prediction = try? model.prediction(inputImage: from)
            return prediction?.outputImage
        } else {
            // Fallback on earlier versions
            return nil
        }
        
     
    }
}
