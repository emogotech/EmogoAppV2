//
//  CameraViewControllerTests.swift
//  EmogoTests
//
//  Created by Sourabh on 24/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import XCTest
@testable import Emogo

class CameraViewControllerTests: XCTestCase {
    
    let storyboard              =   UIStoryboard(name: "Main", bundle: Bundle.main)
    var vc                      :   CameraViewController!
    
    override func setUp() {
        super.setUp()
        vc                      =   storyboard.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CameraViewController
        vc.loadViewIfNeeded()
    }
    
    override func tearDown() {
        super.tearDown()
        vc                      =   nil
    }
    
    func testCVC_For_CameraFlashButton(){
        XCTAssertFalse(self.vc.isFlashClicked, "Flash value already clicked after view loaded!")
        XCTAssertTrue(self.vc.viewFlashOptions.isHidden, "viewFlashOptions is not hidden after view loaded!")

        self.vc.btnActionFlash(self.vc.btnFlash)
        
        XCTAssertTrue(self.vc.isFlashClicked, "Flash Value did not changed after clicking btnActionFlash!")
        XCTAssertFalse(self.vc.viewFlashOptions.isHidden, "viewFlashOptions is still hidden after clicking btnActionFlash!")
    }
    
}
