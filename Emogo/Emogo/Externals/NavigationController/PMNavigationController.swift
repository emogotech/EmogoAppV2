//
//  PMNavigationController.swift
//  Emogo
//
//  Created by Pushpendra on 22/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit


class PMNavigationController:UINavigationController {
    
    public let zoomNavigationControllerDelegate = ZoomNavigationControllerDelegate()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = zoomNavigationControllerDelegate
    }
    
}

//@IBDesignable extension UINavigationController {
//    @IBInspectable var barTintColor: UIColor? {
//        set {
//            guard let uiColor = newValue else { return }
//            self.navigationController?.navigationBar.barTintColor = UIColor.white
//          //  navigationBar.barTintColor = uiColor
//
//        }
//        get {
//            guard let color = navigationBar.barTintColor else { return nil }
//            return color
//        }
//    }
//}
