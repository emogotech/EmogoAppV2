//
//  EmogoLandingScreenUITests.swift
//  EmogoUITests
//
//  Created by Sourabh on 06/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import XCTest

class EmogoLandingScreenUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure    = false
        app                     =   XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app     =   nil
    }
    
    func testLandingScreenTestWhenUserFirstTimeOpenAppAfterInstallingEmogo() {
        sleep(1)
        let btnSignUp   =   app.buttons["sign up btn"]
        let btnSignIn   =   app.buttons["sign in btn"]

        XCTAssertTrue(btnSignUp.exists, "Sign up button not exist, Presented screen is not Landing Screen")
        XCTAssertTrue(btnSignIn.exists, "Sign in button not exist, Presented screen is not Landing Screen")
    }
    
    func testLandingScreenForSignUpButton(){
        
        sleep(1)
        
        let btnSignUp   =   app.buttons["sign up btn"]
        let btnSignIn   =   app.buttons["Sign In"]
        let lblChooseUserNameText = app.staticTexts["Choose a User Name"]


        XCTAssertTrue(btnSignUp.exists, "Sign up button not exist, Presented screen is not Landing Screen")
        XCTAssertFalse(btnSignIn.exists, "Sign In button exist, Presented screen is not Sign Up Screen")
        XCTAssertFalse(lblChooseUserNameText.exists, "Sign In button exist, Presented screen is not Sign Up Screen")

        btnSignUp.tap()
        
        
        XCTAssertFalse(btnSignUp.exists, "Sign up button exists, Presented screen is not Sign up Screen")
        XCTAssertTrue(btnSignIn.exists, "Sign In button not exist, Presented screen is not Sign Up Screen")
        XCTAssertTrue(lblChooseUserNameText.exists, "lblChooseUserNameText not exist, Presented screen is not Sign Up Screen")
        
        sleep(2)
        
    }
    
    func testLandingScreenForSignInButton(){

        let btnSignIn_Landing       =   app.buttons["sign in btn"]
        let btnSignUp_Landing       =   app.buttons["sign up btn"]

        
        let lblPhoneNumber_SignIn   =   app.staticTexts["Enter Your Phone Number"]
        let btnDone_SignIn          =   app.buttons["done btn"]
        let btnSignUp_SignIn        =   app.buttons["Sign Up"]
        
        XCTAssertTrue(btnSignIn_Landing.exists, "Sign in button not exists, Presented screen is not Landing Screen")
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        
        XCTAssertFalse(lblPhoneNumber_SignIn.exists, "lblPhoneNumber_SignIn button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnDone_SignIn.exists, "btnDone_SignIn button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnSignUp_SignIn.exists, "btnSignUp_SignIn button exists, Presented screen is not Landing Screen")
        
        btnSignIn_Landing.tap()
        
        XCTAssertFalse(btnSignIn_Landing.exists, "Sign in button  exists, Presented screen is not Sign in Screen")
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button  exists, Presented screen is not Sign in Screen")
        
        XCTAssertTrue(lblPhoneNumber_SignIn.exists, "lblPhoneNumber_SignIn button not exists, Presented screen is not Sign in Screen")
        XCTAssertTrue(btnDone_SignIn.exists, "btnDone_SignIn button not exists, Presented screen is not Sign in Screen")
        XCTAssertTrue(btnSignUp_SignIn.exists, "btnSignUp_SignIn button not exists, Presented screen is not Sign in Screen")
    }
    
}
