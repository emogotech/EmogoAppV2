//
//  FSPagerViewTransformer.swift
//  FSPagerView
//
//  Created by Wenchao Ding on 05/01/2017.
//  Copyright © 2017 Wenchao Ding. All rights reserved.
//

import UIKit

@objc
public enum FSPagerViewTransformerType: Int {
    case crossFading
    case zoomOut
    case depth
    case overlap
    case linear
    case coverFlow
    case ferrisWheel
    case invertedFerrisWheel
    case cubic
}

open class FSPagerViewTransformer: NSObject {
    
    open internal(set) weak var pagerView: FSPagerView?
    open internal(set) var type: FSPagerViewTransformerType
    
    open var minimumScale: CGFloat = 1.0
    open var minimumAlpha: CGFloat = 0.6
    
    @objc
    public init(type: FSPagerViewTransformerType) {
        self.type = type
        switch type {
        case .zoomOut:
            self.minimumScale = 0.85
        case .depth:
            self.minimumScale = 0.5
        default:
            break
        }
    }
    
    // Apply transform to attributes - zIndex: Int, frame: CGRect, alpha: CGFloat, transform: CGAffineTransform or transform3D: CATransform3D.
    open func applyTransform(to attributes: FSPagerViewLayoutAttributes) {
        guard let pagerView = self.pagerView else {
            return
        }
        let position = attributes.position
        let scrollDirection = pagerView.scrollDirection
        guard scrollDirection == .horizontal else {
            // This type doesn't support vertical mode
            return
        }
        var zIndex = 0
        var transform = CGAffineTransform.identity
        switch position {
        case -5 ... 5:
            let itemSpacing = attributes.bounds.width+self.proposedInteritemSpacing()
            let count: CGFloat = 14
            let circle: CGFloat = .pi * 2.0
            let radius = itemSpacing * count / circle
            let ty = radius * (self.type == .ferrisWheel ? 1 : -1)
            let theta = circle / count
            let rotation = position * theta * (self.type == .ferrisWheel ? 1 : -1)
            transform = transform.translatedBy(x: -position*itemSpacing, y: ty)
            transform = transform.rotated(by: rotation)
            transform = transform.translatedBy(x: 0, y: -ty)
            zIndex = Int((4.0-abs(position)*10))
        default:
            break
        }
        attributes.alpha = abs(position) < 0.5 ? 1 : self.minimumAlpha
        attributes.transform = transform
        attributes.zIndex = zIndex
    }
    
    // An interitem spacing proposed by transformer class. This will override the default interitemSpacing provided by the pager view.
    open func proposedInteritemSpacing() -> CGFloat {
        guard let pagerView = self.pagerView else {
            return 0
        }
        let scrollDirection = pagerView.scrollDirection
        guard scrollDirection == .horizontal else {
            return 0
        }
        return -pagerView.itemSize.width * 0.15
    }
    
}

