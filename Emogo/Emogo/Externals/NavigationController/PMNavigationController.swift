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
    
//    public let zoomNavigationControllerDelegate: ZoomNavigationControllerDelegate = .init()
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        delegate = zoomNavigationControllerDelegate
//    }
    
    
}
