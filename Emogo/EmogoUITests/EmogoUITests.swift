//
//  EmogoUITests.swift
//  EmogoUITests
//
//  Created by Vikas Goyal on 14/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//


import XCTest


class EmogoUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
       
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        app         = nil
    }
    
    func testSignUp() {
        app.buttons["sign up btn"].tap()
        
        let txtUserName_SignUp      =   app.textFields["Your text here"]
        let btnNext_SignUp          =   app.buttons["next btn"]

        txtUserName_SignUp.tap()
        txtUserName_SignUp.typeText("")
        btnNext_SignUp.tap()
        
        txtUserName_SignUp.clearAndEnterText(text: "!@#$%^&*")
        btnNext_SignUp.tap()
        
        let txtPhone_SignUp         =   app.textFields["Please enter phone number"]
        let btnCode_SignUp          =   app.buttons["text me my code btn"]

        txtPhone_SignUp.clearAndEnterText(text: "123")
        btnCode_SignUp.tap()
        
        txtPhone_SignUp.clearAndEnterText(text: "123")
        btnCode_SignUp.tap()

        txtPhone_SignUp.clearAndEnterText(text: "123")
        btnCode_SignUp.tap()
        
        txtPhone_SignUp.clearAndEnterText(text: "1234 56789")
        btnCode_SignUp.tap()

        let txtCode_SignUp          =   app.textFields["Please enter the code"]
        txtCode_SignUp.tap()
        
        txtCode_SignUp.clearAndEnterText(text: "12 3")
        app.buttons["done btn"].tap()
    }
    
    func testSignIn(){
        
        app.buttons["sign in btn"].tap()
        
        let txtPhone_SignUp = app.textFields["Please enter phone number"]
        txtPhone_SignUp.tap()
        txtPhone_SignUp.typeText("1234567890")
        app.buttons["done btn"].tap()
        
    }
    
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    //        txtPhone_SignUp.press(forDuration: 3)
    //        app.menuItems["Select All"].tap()
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = stringValue.characters.map { _ in "\u{8}" }.joined(separator: "")
        
        self.typeText(deleteString)
        self.typeText(text)
    }
}
