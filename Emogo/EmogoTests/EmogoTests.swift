//
//  EmogoTests.swift
//  EmogoTests
//
//  Created by Vikas Goyal on 14/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import XCTest
@testable import Emogo

class EmogoTests: XCTestCase {
    
    let maxNumCharacters        =   10
    let maxUserNameCharacters   =   30
    let storyboard              =   UIStoryboard(name: "Main", bundle: Bundle.main)

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSignUpWithPhoneNumber() {
        
        let signupVC                            =   storyboard.instantiateViewController(withIdentifier: kStoryboardID_SignUpView) as! SignUpViewController
        signupVC.loadView()
        
        let strMaxLimitForPhoneNumber           =   String.init(repeating: Character("5"), count: 30)
        let isMaxLimitForPhoneNumberExceed      =   self.checkMaxCharactersFor(textField: signupVC.txtPhoneNumber, shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: strMaxLimitForPhoneNumber, andForCount: maxNumCharacters)
        XCTAssertFalse(isMaxLimitForPhoneNumberExceed,  "The user name text field should not allow \(maxNumCharacters+1) characters")
        
    }
    
    func testSignUpWithUserName(){
        
        let userNameVC                      = storyboard.instantiateViewController(withIdentifier: kStoryboardID_UserNameView) as! UserNameViewController
        userNameVC.loadView()
        
        let strMaxLimitForUserName          =   String.init(repeating: Character("A"), count: 35)
        let isMaxLimitForUserNameExceed     =   self.checkMaxCharactersFor(textField: userNameVC.txtUserName, shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: strMaxLimitForUserName, andForCount: maxNumCharacters)
        XCTAssertFalse(isMaxLimitForUserNameExceed,  "The phone number text field should not allow \(maxUserNameCharacters+1) characters")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

extension EmogoTests {

    func checkMaxCharactersFor(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String , andForCount count : Int) -> Bool {
        let newLength =     (textField.text?.count)! + string.count
        return newLength <= maxNumCharacters
    }
}
