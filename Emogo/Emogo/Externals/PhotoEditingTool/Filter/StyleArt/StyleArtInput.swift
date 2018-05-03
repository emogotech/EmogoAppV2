//
//  StyleTransferInput.swift
//  StyleArts
//
//  Created by Levin on 29/08/2017.
//  Copyright © 2017 Levin . All rights reserved.
//

import CoreML
import CoreVideo

class StyleArtInput : MLFeatureProvider {
    
    /// input as color (kCVPixelFormatType_32BGRA) image buffer, 720 pixels wide by 720 pixels high
    var input: CVPixelBuffer
    
    var featureNames: Set<String> {
        get {
            return ["inputImage"]
        }
    }
    
    @available(iOS 11.0, *)
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "inputImage") {
            return MLFeatureValue(pixelBuffer: input)
        }
        return nil
    }
    
    init(input: CVPixelBuffer) {
        self.input = input
    }
}
