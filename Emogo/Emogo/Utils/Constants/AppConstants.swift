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

let kDefault                             = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")


let kStoryboardMain                      = UIStoryboard(name: "Main", bundle: nil)
let kPhoneFormat                         = "##########"

let kNavigationColor = UIColor(red: 247.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
let kaddStreamSwitchOffColor = UIColor(red: 219.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
let kaddStreamSwitchOnColor = UIColor(red: 0, green: 173/255.0, blue: 243/255.0, alpha: 1.0)
// MARK: -  FONT'S
let kFontRegular = "SF Pro Display Regular"
let kFontMedium = "SF Pro Display Medium"
let kFontLight = "SF Pro Display Light"
let kFontBold = "SF Pro Display Bold"

// MARK: - Storyboard Identifier
let kStoryboardID_SignUpView = "signUpView"
let kStoryboardID_SigninView = "signInView"
let kStoryboardID_VerificationView = "verificationView"
let kStoryboardID_UserNameView = "userNameView"
let kStoryboardID_WelcomeView = "welcomeView"
let kStoryboardID_StreamListView = "streamListView"
let kStoryboardID_CameraView = "cameraView"
let kStoryboardID_PreView = "preView"
let kStoryboardID_AddStreamView = "addStreamView"
let kStoryboardID_AddCollaboratorsView = "addCollaboratorsView"
let kStoryboardID_InitialView = "initialView"
let kStoryboardID_PeopleListView = "peopleListView"




// MARK: - Cell's  and NIB's Identifier

let kCell_StreamCell = "streamCell"
let kHeader_StreamHeaderView = "streamSearchCell"
let kCell_PreviewCell = "previewCell"
let kFooter_Preview = "previewFooterView"
let kCell_AddCollaboratorsView = "addCollaboratorsViewCell"
let kCell_PeopleCell = "peopleCell"



// MARK: - StoryboardSegue Identifier


// MARK: - UserDefault Identifier
let kUserLogggedIn                      = "userloggedin"
let kUserLogggedInData                  = "userloggedinData"
let kaddBackgroundImage                 = "menuBackGround"

// MARK: - Notification Observer Identifier



// MARK: - Static Alert Messages
let kAlertTitle                         = "Alert!"
let kAlertTitleMessage                  = "Message!"
let kAlertTitleInfo                     = "Info!"

let kPleaseEnterNameMsg                 = "Please Enter User Name."
let kAlertPhoneNumberLengthMsg          = "Phone Number must be 10 digits."
let kAlertVerificationLengthMsg         = "Verification Code must be 5 digits."
let kAlertLoginSuccessMsg               = "You Have Successfully Logged in with us."
let kAlertInvalidUserNameMsg            = "Username limit is between 3-30 characters."
let kAlertUserNameAlreayExistsMsg       = "User Name Already Exists, Please enter Unique User Name."
let kAlertNetworkErrorMsg               = "Unable to connect, Please check your internet connection!"
let kAlertStreamNameEmpty = "Please enter Stream Name."
let kAlertStreamAddedSuccess = "Stream Added Successfully."
let kAlertStreamCaptionEmpty = "Please enter Stream Caption."
let kAlertStreamCoverEmpty = "Please Select Stream Cover Image."
let kAlertStreamColabEmpty = "Please Select Atleast one Collaborator."
let kAlertInvalidUserSpaceMsg            = "Space not allowed."


let kDeepLinkURL = "Emogo://emogo/"
let kDeepLinkTypeProfile = "Profile"
let kDeepLinkTypePeople = "People"
let kDeepLinkTypeAddStream = "AddStream"
let kDeepLinkTypeAddContent = "AddStreamContent"


// MARK: -  AlertMessage
enum AlertType: String {
    case success = "1"
    case error = "2"
    case Info = "3"
    
}


// MARK: -  Service Type
enum StreamInputType: String {
    case pullToRefresh = "1"
    case bottomScrolling = "2"
    case normal = "3"
    
}
// MARK: -  Refresh Type

enum RefreshType:String {
    case start = "0"
    case up = "1"
    case down = "2"
    case end = "3"
}


//**********
//==== iMessage Constants=====
//**********

//StoryBoard Name
let iMsgStoryBoard                              = "MainInterface"

//PlaceHolder text
let iMsgPlaceHolderText_SignIn                   = "Your number here"
let iMsgPlaceHolderText_SignUpName               = "Choose a Username"
let iMsgPlaceHolderText_SignUpMobile             = "Your number here"
let iMsgPlaceHolderText_SignUpVerify             = "Your code here"

//Segue Identifires
let iMsgSegue_SignIn                            = "SignInViewController"
let iMsgSegue_SignUpName                        = "SignUpNameViewController"
let iMsgSegue_SignUpMobile                      = "SignUpMobileViewController"
let iMsgSegue_SignUpVerify                      = "SignUpVerifyViewController"
let iMsgSegue_SignUpSelected                    = "SignUpSelectedViewController"
let iMsgSegue_Home                              = "HomeViewController"
let iMsgSegue_Stream                            = "StreamViewController"
let iMsgSegue_StreamContent                     = "StreamContentViewController"

let iMsgSegue_HomeCollection                    = "HomeCollectionViewCell"
let iMgsSegue_StreamCollection                  = "StreamCollectionViewCell"
let iMgsSegue_HomeCollectionReusableV           = "HomeCollectionReusableView"
let iMgsSegue_CollaboratorCollectionCell          = "CollaboratorCollectionViewCell"

//Notification Name
let iMsgNotificationManageRequestStyle          = "manageRequestStyle"
let iMsgNotificationManageScreen                 = "notifyForChangeScreenSize"

//Alert Messages
let iMsgError_NameMsg                           = "Please enter minimum three characters."
let iMsgError_CodeMsg                           = "Please enter 4 digit code."
let iMsgError_Mobile                            = "Please enter mobile number."
let iMsgError_Name                              = "Please enter the name."
let iMsgError_NameMax                           = "Username limit is between 3-30 characters."
let iMsgError_NameSpace                         = "Space not allowed"


//Alert Types
let iMsgAlertType_One = "1"
let iMsgAlertType_Two = "2"
let iMsgAlertType_Three = "3"

//Alert titles
let iMsgAlertTitle_Success                       = "Message!"
let iMsgAlertTitle_Alert                         = "Emogo"
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
let iMsgCharacterMaxLength_MobileNumber         = 15
let iMsgCharacterMinLength_MobileNumber         = 12

let iMsgNameMinLength                           = 3
let iMsgNameMaxLength                           = 20

let iMsgDismissDelayTimeForPopUp : TimeInterval = 3


let iMsg_hudAlphaConstant: CGFloat              = 0.7

