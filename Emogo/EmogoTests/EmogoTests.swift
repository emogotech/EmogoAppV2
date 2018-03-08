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
    let maxOTPCharacters        =   5
    let storyboard              =   UIStoryboard(name: "Main", bundle: Bundle.main)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSignUpWithUserName(){
        
        let userNameVC                      = storyboard.instantiateViewController(withIdentifier: kStoryboardID_UserNameView) as! UserNameViewController
        userNameVC.loadView()
        
        let strMaxLimitForUserName          =   String.init(repeating: Character("A"), count: 35)
        let isMaxLimitForUserNameExceed     =   self.checkMaxCharactersFor(textField: userNameVC.txtUserName, shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: strMaxLimitForUserName, andForCount: maxNumCharacters)
        XCTAssertTrue(isMaxLimitForUserNameExceed,  "The phone number text field should not allow \(maxUserNameCharacters+1) characters")
        
//        XCTAssertTrue(userNameVC.responds(to: #selector(userNameVC.textField(_:shouldChangeCharactersIn:replacementString:))), "") //not implemented yet
        
    }
    
    func testSignUpWithPhoneNumber() {
        
        let signupVC                            =   storyboard.instantiateViewController(withIdentifier: kStoryboardID_SignUpView) as! SignUpViewController
        signupVC.loadView()
        
        let field = signupVC.txtPhoneNumber!
        
        // Call through field.delegate, not through vc
        let result = field.delegate?.textField!(field,
                                              shouldChangeCharactersIn: NSMakeRange(0, 1),
                                              replacementString: "a")
        print(result)
        
        
        let strMaxLimitForPhoneNumber           =   String.init(repeating: Character("5"), count: 11)
        let isMaxLimitForPhoneNumberExceed      =   self.checkMaxCharactersFor(textField: signupVC.txtPhoneNumber, shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: strMaxLimitForPhoneNumber, andForCount: maxNumCharacters)
        XCTAssertFalse(isMaxLimitForPhoneNumberExceed,  "The Phone Number text field should not allow \(maxNumCharacters+1) characters")


    }
    
    func testSignUpWithOTP(){
        
        let verificationVC      =   storyboard.instantiateViewController(withIdentifier: kStoryboardID_VerificationView) as! VerificationViewController
        verificationVC.loadView()
        
        let strMaxLimitForOTPExceed           =   String.init(repeating: Character("5"), count: 11)
        let isMaxLimitForPhoneNumberExceed      =   self.checkMaxCharactersFor(textField: verificationVC.txtOtP, shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: strMaxLimitForOTPExceed, andForCount: maxOTPCharacters)
        XCTAssertFalse(isMaxLimitForPhoneNumberExceed,  "The OTP text field should not allow \(maxOTPCharacters+1) characters")
        
//        let strCharactersForOTP         =   String.init(repeating: "A", count: 5)
//        let isCharctersAllowedForOTP    =   self.checkMaxCharactersFor(textField: verificationVC.txtOtP, shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: strCharactersForOTP, andForCount: maxOTPCharacters)
//        XCTAssertFalse(isCharctersAllowedForOTP,  "The OTP text field should not allow characters")
        
    }
    
}

extension EmogoTests {
    
    func checkMaxCharactersFor(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String , andForCount count : Int) -> Bool {
        let newLength =     (textField.text?.count)! + string.count
        return newLength <= count
    }
    
}

