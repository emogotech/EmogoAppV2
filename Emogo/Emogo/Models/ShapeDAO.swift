//
//  ShapeDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
class ShapeDAO {
    var shapes = [UIImage]()
    
    init(){
        self.initShapes()
    }
    
  private  func initShapes(){
        for i in 1...19 {
            let image = UIImage(named: "shape\(i)")
            shapes.append(image!)
        }
    }
}
