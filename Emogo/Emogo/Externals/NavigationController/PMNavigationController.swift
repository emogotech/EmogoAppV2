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
    
    private let zoomNavigationControllerDelegate: ZoomNavigationControllerDelegate = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = zoomNavigationControllerDelegate
    }
    
    
}
