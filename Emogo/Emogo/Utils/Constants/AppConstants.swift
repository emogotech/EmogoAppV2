//
//  AppConstants.swift
//  Emogo
//
//  Created by Vikas Goyal on 15/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

/*
Constants Used in Enier App
 */

import Foundation
import UIKit

// MARK: -  Constants Variables
let kFrame                               = UIScreen.main.bounds

let kDefault                             = UserDefaults.standard

let kStoryboardMain                      = UIStoryboard(name: "Main", bundle: nil)

// MARK: - Storyboard Identifier
let kStoryboardID_SignUpView = "signUpView"
let kStoryboardID_SigninView = "signInView"
let kStoryboardID_VerificationView = "verificationView"
let kStoryboardID_UserNameView = "userNameView"


// MARK: - StoryboardSegue Identifier


// MARK: - UserDefault Identifier


// MARK: - Notification Observer Identifier



// MARK: - Static Alert Messages
let kAlertTitle                         = "Alert!"
let kAlertTitleMessage                  = "Message"

let kPleaseEnterNameMsg                 = "Please Enter User Name."
let kAlertPhoneNumberLengthMsg          = "Phone Number must be 10 characters."
let kAlertVerificationLengthMsg         = "Verification Code must be 4 characters."
let kAlertLoginSuccessMsg               = "You Have Successfully Logged in with us."

