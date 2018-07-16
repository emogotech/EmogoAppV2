//
//  RightEdgeInteractionController.swift
//  CustomTransition
//
//  Created by Pushpendra on 11/07/18.
//

import Foundation
import UIKit

open class RightEdgeInteractionController: UIPercentDrivenInteractiveTransition {
    
    open var inProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    public init(viewController: UIViewController) {
        super.init()
        
        self.viewController = viewController
        
        self.setupGestureRecognizer(in: viewController.view)
    }
    
    private func setupGestureRecognizer(in view: UIView) {
        let edge = UIScreenEdgePanGestureRecognizer(target: self,
                                                    action: #selector(self.handleEdgePan(_:)))
        edge.edges = .right
        view.addGestureRecognizer(edge)
    }
    
    @objc func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }
        
        let percent = -gesture.translation(in: gestureView).x / gestureView.bounds.size.width
        
        switch gesture.state {
        case .began:
            self.inProgress = true
            if let navigationController = viewController.navigationController {
                navigationController.popViewController(animated: true)
                return
            }
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            self.update(percent)
        case .cancelled:
            self.inProgress = false
            self.cancel()
        case .ended:
            self.inProgress = false
            
            // let velocity = gesture.velocity(in: gesture.view)
            
            if percent > 0.5  {
                self.finish()
            }
            else {
                self.cancel()
            }
        default:
            break
        }
    }
}

