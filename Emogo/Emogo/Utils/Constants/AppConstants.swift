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
let kStoryboardID_CameraView = "cameraView"


// MARK: - Cell's  and NIB's Identifier

let kCell_StreamCell = "streamCell"
let kHeader_StreamHeaderView = "streamSearchCell"
let kCell_PreviewCell = "previewCell"


// MARK: - StoryboardSegue Identifier


// MARK: - UserDefault Identifier
let kUserLogggedIn                      = "userloggedin"
let kUserLogggedInData                  = "userloggedinData"

// MARK: - Notification Observer Identifier



// MARK: - Static Alert Messages
let kAlertTitle                         = "Alert!"
let kAlertTitleMessage                  = "Message!"
let kAlertTitleInfo                     = "Info!"

let kPleaseEnterNameMsg                 = "Please Enter User Name."
let kAlertPhoneNumberLengthMsg          = "Phone Number must be 10 characters."
let kAlertVerificationLengthMsg         = "Verification Code must be 5 characters."
let kAlertLoginSuccessMsg               = "You Have Successfully Logged in with us."
let kAlertInvalidUserNameMsg            = "User Name Should be Between 3 - 30 characters."
let kAlertUserNameAlreayExistsMsg       = "User Name Already Exists, Please enter Unique User Name."


// MARK: -  AlertMessage
enum AlertType: String {
    case success = "1"
    case error = "2"
    case Info = "3"
    
}

//**********
//==== iMessage Constants=====
//**********

//StoryBoard Name
let iMsgStoryBoard                              = "MainInterface"

//PlaceHolder text
let iMsgPlaceHolderText_SignIn                   = "Your number here"
let iMsgPlaceHolderText_SignUpName               = "Your text here"
let iMsgPlaceHolderText_SignUpMobile             = "Your number here"
let iMsgPlaceHolderText_SignUpVerify             = "Your code here"

//Segue Identifires
let iMsgSegue_SignIn                            = "SignInViewController"
let iMsgSegue_SignUpName                        = "SignUpNameViewController"
let iMsgSegue_SignUpMobile                      = "SignUpMobileViewController"
let iMsgSegue_SignUpVerify                      = "SignUpVerifyViewController"
let iMsgSegue_SignUpSelected                    = "SignUpSelectedViewController"
let iMsgSegue_Home                              = "HomeViewController"

//Notification Name
let iMsgNotificationManageRequestStyle          = "manageRequestStyle"

//Alert Messages
let iMsgError_NameMsg                           = "Please enter the name and minimum three characters."
let iMsgError_CodeMsg                           = "Please enter 4 digit code."
let iMsgError_Mobile                            = "Please enter mobile number."
let iMsgError_Name                              = "Please enter the name."


//Alert Types
let iMsgAlertType_One = "1"
let iMsgAlertType_Two = "2"
let iMsgAlertType_Three = "3"

//Alert titles
let iMsgAlertTitle_Success                       = "Message!"
let iMsgAlertTitle_Alert                         = "Alert!"
let iMsgAlertTitle_Info                          = "Info!"

//Sets Constant
let iMsgCharacterSet                            = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"
let iMsgNumberSet                               = "0123456789"

//String Check
let iMsg_String_isBlank                         = ""
let iMsg_String_singleSpace                     = " "

//Constant
let iMsg_CornorRadius : CGFloat                 = 18.0
let iMsgCharacterMaxLength_Name                 = 30
let iMsgCharacterMaxLength_VerificationCode     = 4
let iMsgCharacterMaxLength_MobileNumber         = 12

let iMsgNameMinLength                           = 3
let iMsgNameMaxLength                           = 20

let iMsgDismissDelayTimeForPopUp : TimeInterval = 3


let iMsg_hudAlphaConstant: CGFloat              = 0.4

