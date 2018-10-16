//
//  CircleLotationSet.swift
//  Pods
//
//  Created by Naver on 2017. 3. 30..
//
//

import UIKit

internal typealias CLSet = CircleLotationSet

internal enum CircleLotationSet {
    
    case leftUp
    case rightUp
    case rightDown
    case leftDown
    
    var color: CGColor {
        switch self {
        case .leftUp: return #colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1).cgColor
        case .rightUp: return #colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1).cgColor
        case .rightDown: return #colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1).cgColor
        case .leftDown: return #colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1).cgColor
        }
    }
    
    var frame: CGRect {
        switch self {
        case .leftUp: return CGRect(x: 0, y: 0, width: 10, height: 10)
        case .rightUp: return CGRect(x: 20, y: 0, width: 10, height: 10)
        case .rightDown: return CGRect(x: 20, y: 20, width: 10, height: 10)
        case .leftDown: return CGRect(x: 0, y: 20, width: 10, height: 10)
        }
    }
    
    var nextColor: CGColor {
        switch self {
        case .leftUp: return CircleLotationSet.rightUp.color
        case .rightUp: return CircleLotationSet.rightDown.color
        case .rightDown: return CircleLotationSet.leftDown.color
        case .leftDown: return CircleLotationSet.leftUp.color
        }
    }

    var nextPosition: CGPoint {
        switch self {
        case .leftUp: return CGPoint(x: 25, y: 5)
        case .rightUp: return CGPoint(x: 25, y: 25)
        case .rightDown: return CGPoint(x: 5, y: 25)
        case .leftDown: return CGPoint(x: 5, y: 5)
        }
    }
}
