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
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app         = nil
    }
    
    func testUserName(){
        sleep(3 )
        app.buttons["sign up btn"].tap()
        
        let txtUserName_SignUp      =   app.textFields["Your text here"]
        let btnNext_SignUp          =   app.buttons["next btn"]
        
        txtUserName_SignUp.tap()
        for i in 0...3 {
            if i == 0 {
                txtUserName_SignUp.clearAndEnterText(text: "AB")
            }else if i == 1 {
                txtUserName_SignUp.clearAndEnterText(text: "A 1")
            }else if i == 2 {
                txtUserName_SignUp.clearAndEnterText(text: "AB")
            }else if i == 3 {
                txtUserName_SignUp.clearAndEnterText(text: "  1")
            }
            btnNext_SignUp.tap()
        }
        txtUserName_SignUp.clearAndEnterText(text: "Shyaamoo")
        btnNext_SignUp.tap()
    }
    
    func testSignUp() {
        app.buttons["sign up btn"].tap()
        
        let txtUserName_SignUp      =   app.textFields["Your text here"]
        let btnNext_SignUp          =   app.buttons["next btn"]
        
        txtUserName_SignUp.tap()
        txtUserName_SignUp.typeText("")
        btnNext_SignUp.tap()
        
        txtUserName_SignUp.clearAndEnterText(text: "Shyaamoo")
        btnNext_SignUp.tap()
        
        sleep(2)
        let txtPhone_SignUp         =   app.textFields["Please enter phone number"]
        let btnCode_SignUp          =   app.buttons["text me my code btn"]
        
        if txtPhone_SignUp.exists == true {
            for i in 0 ... 6 {
                if i == 0 {
                    txtPhone_SignUp.clearAndEnterText(text: "123")
                }else if i == 1 {
                    txtPhone_SignUp.clearAndEnterText(text: "1 2 3")
                }else if i == 2 {
                    txtPhone_SignUp.clearAndEnterText(text: "ABC123")
                }else if i == 3 {
                    txtPhone_SignUp.clearAndEnterText(text: "#$@12345")
                }else if i == 4 {
                    txtPhone_SignUp.clearAndEnterText(text: "0099#@")
                }else if i == 5 {
                    txtPhone_SignUp.clearAndEnterText(text: "75757")
                }
                else if i == 6 {
                    txtPhone_SignUp.clearAndEnterText(text: "7509875000")
                }
                btnCode_SignUp.tap()
            }
            
            sleep(2)
            
            let lblCodeDesc = app.staticTexts["We texted you a 5 digit code. Please enter it below."]
            if lblCodeDesc.exists  ==  true {
                let txtCode_SignUp          =   app.textFields["Please enter the code"]
                let code                =   txtCode_SignUp.value as! String
                print("code =========== >>>>>>>>>>> ", code)
                for i in 0...3{
                    txtCode_SignUp.tap()
                    if i == 0 {
                        txtCode_SignUp.clearAndEnterText(text: "12 34")
                    }else if i == 1{
                        txtCode_SignUp.clearAndEnterText(text: "1 234")
                    }else if i == 2{
                        txtCode_SignUp.clearAndEnterText(text: "12  3")
                    }else if i == 3{
                        txtCode_SignUp.clearAndEnterText(text: "12343")
                    }
                    app.buttons["done btn"].tap()
                }
                txtCode_SignUp.clearAndEnterText(text: code)
                app.buttons["done btn"].tap()
            }else{
                print("what?")
            }
        }else{
            print("name already exists")
        }
    }
    
    func testTheHappyCaseForSignUp(){
        
        app.buttons["sign up btn"].tap()
        
        let txtName = app.textFields["Your text here"]
        txtName.tap()
        txtName.typeText("Disha")
        app.buttons["next btn"].tap()
        
        sleep(3)
        let txtPhone = app.textFields["Please enter phone number"]
        if txtPhone.exists == true {
            txtPhone.tap()
            txtPhone.typeText("7500960077")
            let btnTextCode = app.buttons["text me my code btn"]
            btnTextCode.tap()
            
            sleep(3)
            let lblCodeDesc = app.staticTexts["We texted you a 5 digit code. Please enter it below."]
            
            if lblCodeDesc.exists == true {
                app.buttons["done btn"].tap()
            }else{
                print("phone number already exists or server error")
            }
        }else{
            print("something went wrong or Name already exists")
        }
    }
    
    func testSignInHappyCase101(){
        
        app.buttons["sign in btn"].tap()
        
        let txtPhone = app.textFields["Please enter phone number"]
        txtPhone.tap()
        txtPhone.typeText("7509820455")
        
        let btnDone = app.buttons["done btn"]
        btnDone.tap()
        sleep(3)
    }
    
    func testSignIn(){
        app.buttons["sign in btn"].tap()
        
        let txtPhone = app.textFields["Please enter phone number"]
        let btnDone = app.buttons["done btn"]
        txtPhone.tap()
        
        for i in 0...3{
            if i == 0 {
                txtPhone.clearAndEnterText(text: "123")
            }else if i == 1 {
                txtPhone.clearAndEnterText(text: "1 2 3")
            }else if i == 2 {
                txtPhone.clearAndEnterText(text: "ABC123")
            }else{
                txtPhone.clearAndEnterText(text: "7509820455")
            }
            btnDone.tap()
        }
        sleep(3)
    }
    
    
    
    func testSignInHappyCase(){
        
        app.buttons["sign in btn"].tap()
        
        let txtPhone = app.textFields["Please enter phone number"]
        txtPhone.tap()
        txtPhone.tap()
        txtPhone.typeText("7509820455")
        
        let btnDone =   app.buttons["done btn"]
        btnDone.tap()
        
    }
    
    func testSignIn_ForPhone_Screen(){
        app.buttons["sign in btn"].tap()
        
        let btnDone =   app.buttons["done btn"]
        
        XCTAssertTrue(btnDone.exists, "Done button is not displayed, must be Phone screen not presented")
        
        let txtPhone = app.textFields["Please enter phone number"]
        txtPhone.tap()
        txtPhone.tap()
        txtPhone.typeText("7509820455")
        
        btnDone.tap()
        
    }
        
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
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

