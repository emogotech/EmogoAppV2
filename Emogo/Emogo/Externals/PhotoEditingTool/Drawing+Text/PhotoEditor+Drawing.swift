//
//  PhotoEditor+Drawing.swift
//  Photo Editor
//
//  Created by Pushpendra on 13/12/17.
//
//

import UIKit

extension PhotoEditorViewController {
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.location(in: self.canvasImageView)
            }
        }
            //Hide stickersVC if clicked outside it
        else if stickersVCIsVisible == true {
            if let touch = touches.first {
                let location = touch.location(in: self.view)
                if !stickersViewController.view.frame.contains(location) {
                    removeStickersView()
                }
            }
        }
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            // 6
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageView)
                drawLineFrom(lastPoint, toPoint: currentPoint)
                
                // 7
                lastPoint = currentPoint
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            if !swiped {
                // draw a single point
                drawLineFrom(lastPoint, toPoint: lastPoint)
            }
        }
        
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        print(self.canvasImageView.frame)
        let path = UIBezierPath()
        path.move(to: fromPoint)
        path.addLine(to: toPoint)
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = drawColor.cgColor
        shapeLayer.lineWidth = self.drawWidth
        self.canvasImageView.layer.addSublayer(shapeLayer)
        /*
        UIGraphicsBeginImageContext(canvasImageView.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasImageView.frame.size.width, height: canvasImageView.frame.size.height))
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3
            context.setLineCap( CGLineCap.round)
            context.setLineWidth(self.drawWidth)
            context.setStrokeColor(drawColor.cgColor)
            context.setBlendMode( CGBlendMode.normal)
            // 4
            context.strokePath()
            // 5
            canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
 */
    }
    
}
