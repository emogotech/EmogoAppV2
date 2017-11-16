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
let kPhoneFormat                         = "##########"

// MARK: -  FONT'S
let kFontRegular = "SF-Pro-Display-Regular"
let kFontMedium = "SF-Pro-Display-Medium"
let kFontLight = "SF-Pro-Display-Light"
let kFontBold = "SF-Pro-Display-Bold"

// MARK: - Storyboard Identifier
let kStoryboardID_SignUpView = "signUpView"
let kStoryboardID_SigninView = "signInView"
let kStoryboardID_VerificationView = "verificationView"
let kStoryboardID_UserNameView = "userNameView"
let kStoryboardID_WelcomeView = "welcomeView"
let kStoryboardID_StreamListView = "streamListView"

// MARK: - Cell's  and NIB's Identifier

let kCell_StreamCell = "streamCell"

// MARK: - StoryboardSegue Identifier


// MARK: - UserDefault Identifier
let kUserLogggedIn                      = "userloggedin"
let kUserLogggedInData                  = "userloggedinData"

// MARK: - Notification Observer Identifier



// MARK: - Static Alert Messages
let kAlertTitle                         = "Alert!"
let kAlertTitleMessage                  = "Message"

let kPleaseEnterNameMsg                 = "Please Enter User Name."
let kAlertPhoneNumberLengthMsg          = "Phone Number must be 10 characters."
let kAlertVerificationLengthMsg         = "Verification Code must be 5 characters."
let kAlertLoginSuccessMsg               = "You Have Successfully Logged in with us."
let kAlertInvalidUserNameMsg          = "User Name Should be Between 3 - 30 characters."

