//
//  iMessageExt.swift
//  iMessageExt
//
//  Created by Vikas Goyal on 17/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

// MARK: - String
extension String {
    
    func stringByAddingPercentEncodingForURLQueryParameter() -> String? {
        let allowedCharacters = NSCharacterSet.urlQueryAllowed
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height:height )
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.width
    }
    
    func trimStr() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
}
