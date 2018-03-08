//
//  EmogoStreamListVCUITests.swift
//  EmogoUITests
//
//  Created by Sourabh on 23/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import XCTest

class EmogoStreamListVCUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app         = nil
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func test_Device_For_AddImage(){
        
        app.navigationBars["home icon active"].buttons["camera icon"].tap()
        app.buttons["add galery"].tap()
        
        let element = app.collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element
        element.tap()
        app.navigationBars["Camera Roll"].buttons["Select(1)"].tap()
        app.buttons["share button"].tap()
        
        let txtTitle = app.textFields["Title your Image"]
        txtTitle.clearAndEnterText(text: "Sourabh")
        
        let txtDescription = app.textFields["Description text"]
        txtDescription.tap()
        txtDescription.clearAndEnterText(text: "Description")
        
        app.buttons["  Done"].tap()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
