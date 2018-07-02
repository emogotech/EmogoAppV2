//
//  DrawingImageView.swift
//  Emogo
//
//  Created by Pushpendra on 27/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
class DrawingView : UIImageView {
    
    var lastPoint : CGPoint!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            drawLine(from: lastPoint, to: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    func drawLine(from lastPoint : CGPoint, to newPoint : CGPoint) {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.image?.draw(in: self.bounds)
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: lastPoint)
        context?.addLine(to: newPoint)
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(5)
        context?.setStrokeColor(UIColor.black.cgColor)
        
        context?.strokePath()
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func clear() {
        self.image = nil
    }
}
