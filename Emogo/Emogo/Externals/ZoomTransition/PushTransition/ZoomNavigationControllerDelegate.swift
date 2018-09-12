//
//  ZoomNavigationControllerDelegate.swift
//  ZoomTransitioning
//
//  Created by WorldDownTown on 07/16/2016.
//  Copyright © 2016 WorldDownTown. All rights reserved.
//

import UIKit

public final class ZoomNavigationControllerDelegate: NSObject {
    private let zoomInteractiveTransition: ZoomInteractiveTransition = .init()
    private let zoomPopGestureRecognizer: UIScreenEdgePanGestureRecognizer = .init()
}


// MARK: - UINavigationControllerDelegate

extension ZoomNavigationControllerDelegate: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if zoomPopGestureRecognizer.delegate !== zoomInteractiveTransition {
            zoomPopGestureRecognizer.delegate = zoomInteractiveTransition
            zoomPopGestureRecognizer.addTarget(zoomInteractiveTransition, action: #selector(ZoomInteractiveTransition.handle(recognizer:)))
            //Changes by aarti
              // zoomPopGestureRecognizer.edges = .top
            zoomPopGestureRecognizer.edges = .left
            
            navigationController.view.addGestureRecognizer(zoomPopGestureRecognizer)
            zoomInteractiveTransition.zoomPopGestureRecognizer = zoomPopGestureRecognizer
        }

        if let interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer, interactivePopGestureRecognizer.delegate !== zoomInteractiveTransition {
            zoomInteractiveTransition.navigationController = navigationController
            interactivePopGestureRecognizer.delegate = zoomInteractiveTransition
        }
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return zoomInteractiveTransition.interactionController
    }

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if let source = fromVC as? ZoomTransitionSourceDelegate, let destination = toVC as? ZoomTransitionDestinationDelegate, operation == .push {
            return ZoomTransitioning(source: source, destination: destination, forward: true)
        } else if let source = toVC as? ZoomTransitionSourceDelegate, let destination = fromVC as? ZoomTransitionDestinationDelegate, operation == .pop {
            return ZoomTransitioning(source: source, destination: destination, forward: false)
        }
        return nil
    }
}
