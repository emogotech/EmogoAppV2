//
//  EmogoSignUpUITests.swift
//  EmogoUITests
//
//  Created by Sourabh on 06/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import XCTest

class EmogoSignUpUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app     =   nil
    }
    
    //MARK:- Sign Up - User Name
    
    func testSignUpWithBlankUserName() {
        
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]

        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")

        let predicate   =  NSPredicate(format: "exists == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        btnNext_SignUp.tap()

        sleep(1)
    }
    
    func testSignUpWithNumberAsUserName(){
        
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp = app.staticTexts["Enter Your Phone Number"]

        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "exists == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.clearAndEnterText(text: "123231")
        btnNext_SignUp.tap()
        
        sleep(3)
        
        XCTAssertTrue(txtPhone_SignUp.exists, "txtPhone_SignUp not present , Presented screen is not Sign up with phone number must be an error in server or username already exists")
        
        if txtPhone_SignUp.exists {
            print("success")
        }
        
        sleep(2)
    }
    
    func testSignUpWithThreeCharacterAsUserName(){
        
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp = app.staticTexts["Enter Your Phone Number"]
        
        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "exists == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.clearAndEnterText(text: "ASA")
        btnNext_SignUp.tap()
        
        sleep(3)
        
        XCTAssertTrue(txtPhone_SignUp.exists, "txtPhone_SignUp not present , Presented screen is not Sign up with phone number must be an error in server or username already exists")
        
        if txtPhone_SignUp.exists {
            print("success")
        }
        
        sleep(2)
    }
    
    func testSignUpWithThirtyCharacterAsUserName(){
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp = app.staticTexts["Enter Your Phone Number"]
        
        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "isHittable == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.clearAndEnterText(text:"abcdefghijklmnopqrstuvwxyzabcd")
        btnNext_SignUp.tap()
        
        sleep(3)
        
        XCTAssertTrue(txtPhone_SignUp.exists, "txtPhone_SignUp not present , Presented screen is not Sign up with phone number must be an error in server or username already exists")
        
        if txtPhone_SignUp.exists {
            print("success")
        }
        
        sleep(2)
    }
    
    func testSignUpWithNumbersAndSpecialCharactersAsUserName(){
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp = app.staticTexts["Enter Your Phone Number"]
        
        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "isHittable == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.clearAndEnterText(text:"@#!123")
        btnNext_SignUp.tap()
        
        let predicateForTxtPhone   =  NSPredicate(format: "exists == 1")
        expectation(for: predicateForTxtPhone, evaluatedWith: txtPhone_SignUp, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertTrue(txtPhone_SignUp.exists, "txtPhone_SignUp not present , Presented screen is not Sign up with phone number must be an error in server or username already exists")
        
        if txtPhone_SignUp.exists {
            print("success")
        }
        
        sleep(2)
    }
    
    func testSignUpWithUnRegisteredUserNameAsUserName(){
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp = app.staticTexts["Enter Your Phone Number"]
        
        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "isHittable == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.clearAndEnterText(text:"DuumyUser101")
        btnNext_SignUp.tap()
        
        let predicateForTxtPhone   =  NSPredicate(format: "exists == 1")
        expectation(for: predicateForTxtPhone, evaluatedWith: txtPhone_SignUp, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(txtPhone_SignUp.exists, "txtPhone_SignUp not present , Presented screen is not Sign up with 19phone number must be an error in server or username already exists")
        
        if txtPhone_SignUp.exists {
            print("success")
        }
        
        sleep(2)
    }
    
    func testSignUpWithAlreadyRegisteredUserNameAsUserName(){
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp = app.staticTexts["Enter Your Phone Number"]
        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "isHittable == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.tap()
        txtUserName_SignUp.typeText("Sourabh")
        
        btnNext_SignUp.tap()
        
        sleep(5)
        
        XCTAssertTrue((btnNext_SignUp.exists && !txtPhone_SignUp.exists), "Screen not navigated, must be a server error or User Name already exists!")
        
        print("Success")
        
        sleep(2)
    }
    
    func testSignUpWithLessThanThreeCharactersLongUserNameAsUserName(){
        
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp = app.staticTexts["Enter Your Phone Number"]
        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "isHittable == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.tap()
        txtUserName_SignUp.typeText("So")
        
        btnNext_SignUp.tap()
        
        sleep(1)
        
        XCTAssertTrue((btnNext_SignUp.exists && !txtPhone_SignUp.exists), "Screen navigated, user name is accepting less than three characters!")
        
        print("Success For less than three characters!")
        
        txtUserName_SignUp.tap()
        txtUserName_SignUp.clearAndEnterText(text: "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz")
        
        btnNext_SignUp.tap()
        
        sleep(1)
        
        XCTAssertTrue((btnNext_SignUp.exists && !txtPhone_SignUp.exists), "Screen navigated, Username is accepting more than thirty characters!")
        
        print("Success For more than thirty characters!")
        
        sleep(2)
    }
    
    func testSignUpWithAddingSpacesInAndInBetweenNameAsUserName(){
        
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp = app.staticTexts["Enter Your Phone Number"]
        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "isHittable == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.tap()
        txtUserName_SignUp.typeText("     ")
        
        btnNext_SignUp.tap()
        
        sleep(1)
        
        XCTAssertTrue((btnNext_SignUp.exists && !txtPhone_SignUp.exists), "Screen navigated, User Name is accepting spaces")
        
        print("Success For blank spaces!")
        
        txtUserName_SignUp.tap()
        txtUserName_SignUp.clearAndEnterText(text: "Sourabh Gajbhiye")
        btnNext_SignUp.tap()
        sleep(1)
        
        XCTAssertTrue((btnNext_SignUp.exists && !txtPhone_SignUp.exists), "Screen navigated, User Name is accepting spaces")
        
        print("Success For in between spaces in user name!")
        
        
        sleep(2)
    }
    
    //MARK:- Sign Up - Phone
    
    func testSignUpWithBlankPhoneNumberForPhoneField(){
        
        let btnSignUp_Landing     =   app.buttons["sign up btn"]
        let btnNext_SignUp        =   app.buttons["next btn"]
        let txtUserName_SignUp    =   app.textFields["Your text here"]
        let txtPhone_SignUp       =   app.staticTexts["Enter Your Phone Number"]
        let btnTextCode_Phone     =   app.buttons["text me my code btn"]

        
        
        XCTAssertTrue(btnSignUp_Landing.exists, "Sign up button not exists, Presented screen is not Landing Screen")
        XCTAssertFalse(btnNext_SignUp.exists, "Next button exists, Presented screen is not Landing Screen")
        XCTAssertFalse(txtUserName_SignUp.exists, "txtUserName_SignUp button exists, Presented screen is not Landing Screen")
        
        let predicate   =  NSPredicate(format: "exists == 1")
        expectation(for: predicate, evaluatedWith: btnSignUp_Landing, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        btnSignUp_Landing.tap()
        
        XCTAssertFalse(btnSignUp_Landing.exists, "Sign up button exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(btnNext_SignUp.exists, "Next button not exists, Presented screen is not Sign Up Screen")
        XCTAssertTrue(txtUserName_SignUp.exists, "txtUserName_SignUp button not exists, Presented screen is not Sign Up Screen")
        
        txtUserName_SignUp.tap()
        txtUserName_SignUp.typeText("SourabhNorthout")
        btnNext_SignUp.tap()
        
        sleep(3)
        
        XCTAssertTrue(txtPhone_SignUp.exists, "txtPhone_SignUp not present , Presented screen is not Sign up with phone number must be an error in server or username already exists")
        
        btnTextCode_Phone.tap()
        
        
        sleep(2)
    }
}
