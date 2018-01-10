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
let kScale                               = UIScreen.main.scale

let kDefault                             = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")


let kStoryboardMain                      = UIStoryboard(name: "Main", bundle: nil)
let kStoryboardStuff                      = UIStoryboard(name: "Stuff", bundle: nil)

let kPhoneFormat                         = "##########"

let kNavigationColor = UIColor(red: 247.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
let kaddStreamSwitchOffColor = UIColor(red: 219.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
let kaddStreamSwitchOnColor = UIColor(red: 0, green: 173/255.0, blue: 243/255.0, alpha: 1.0)

var kContainerNav = ""
var kBackNav = ""

// Selected Tag For Container
var currentTag = 111

var currentStreamType:StreamType! = .featured


var arraySelectedContent:[ContentDAO]?
var arrayAssests:[ImportDAO]?

// MARK: -  FONT'S
let kFontRegular = "SF Pro Display Regular"
let kFontMedium = "SF Pro Display Medium"
let kFontLight = "SF Pro Display Light"
let kFontBold = "SF Pro Display Bold"

let kPlaceholderImage = "stream-card-placeholder"


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
let kStoryboardID_viewStream = "viewStream"
let kStoryboardID_MyStreamView = "myStreamView"
let kStoryboardID_ContainerView = "containerView"
let kStoryboardID_MyStuffView = "myStuffView"
let kStoryboardID_LinkView = "linkView"
let kStoryboardID_GiphyView = "giphyView"
let kStoryboardID_ImportView = "importView"
let kStoryboardID_ContentView = "contentView"
let kStoryboardID_ProfileView = "profileView"
let kStoryboardID_UserProfileView = "userProfileView"

let iMsgSegue_Root                              = "MessagesViewController"
let iMsgSegue_SignIn                            = "SignInViewController"
let iMsgSegue_SignUpName                        = "SignUpNameViewController"
let iMsgSegue_SignUpMobile                      = "SignUpMobileViewController"
let iMsgSegue_SignUpVerify                      = "SignUpVerifyViewController"
let iMsgSegue_SignUpSelected                    = "SignUpSelectedViewController"
let iMsgSegue_Home                              = "HomeViewController"
let iMsgSegue_Stream                            = "StreamViewController"
let iMsgSegue_StreamContent                     = "StreamContentViewController"
let iMsgSegue_Collaborator                      = "CollaboratorViewController"

let iMsgSegue_HomeCollection                    = "HomeCollectionViewCell"
let iMgsSegue_StreamCollection                  = "StreamCollectionViewCell"
let iMgsSegue_HomeCollectionReusableV           = "HomeCollectionReusableView"
let iMgsSegue_CollaboratorCollectionCell          = "CollaboratorCollectionViewCell"
let iMsgSegue_HomeCollectionPeople        = "PeopleSearchCollectionViewCells"

let iMsgSegue_CollectionReusable_Footer        = "CustomFooterView"


// MARK: - Cell's  and NIB's Identifier
let kCell_StreamCell = "streamCell"
let kHeader_StreamHeaderView = "streamSearchCell"
let kCell_PreviewCell = "previewCell"
let kFooter_Preview = "previewFooterView"
let kCell_AddCollaboratorsView = "addCollaboratorsViewCell"
let kCell_PeopleCell = "peopleCell"
let kHeader_ViewStreamHeaderView = "streamViewHeader"
let kCell_AddContentCell = "addContentCell"
let kCell_StreamContentCell = "streamContentCell"
let kHeader_MyStreamHeaderView = "myStreamHeaderView"
let kCell_MyStreamCell = "myStreamCell"
let kCell_MyStuffCell = "myStuffCell"
let kCell_ImportCell = "importCell"
let kCell_GiphyCell = "giphyCell"
let kCell_LinkListCell = "linkListCell"


let kCell_ProfileStreamCell = "profileStreamCell"
let kSegue_AddCollaboratorsView = "addColabSegue"
let kSegue_ContainerSegue = "containerSegue"

// MARK: - UserDefault Identifier
let kUserLogggedIn                      = "userloggedin"
let kUserLogggedInData                  = "userloggedinData"
let kaddBackgroundImage                 = "menuBackGround"

// MARK: - Notification Observer Identifier
let kLogoutIdentifier = "LogoutNavigationIdentifier"
let kUpdateStreamViewIdentifier = "UpdateStreamIdentifier"

// MARK:- Redirect Links
let kDeepLinkURL = "Emogo://emogo/"
let kDeepLinkTypeProfile = "Profile"
let kDeepLinkTypePeople = "People"
let kDeepLinkTypeAddStream = "AddStream"
let kDeepLinkTypeAddContent = "AddStreamContent"
let kDeepLinkTypeEditStream = "editStream"
let kDeepLinkTypeEditContent = "editStreamContent"
let kUserDefaltForContentData = "editContentData"
let kSearchType = "PEOPLE"
let kCollaobatorList = "Collaborator List"

// MARK: -  Enums Alert
enum AlertType: String {
    case success = "1"
    case error = "2"
    case Info = "3"
}


// MARK: -  Enums Alert
enum TimerSet: String {
    case fiveSec = "5s"
    case tenSec = "10s"
    case fifteenSec = "15s"
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


enum checkKeyType: String {
    case fullname = "fullName"
    case phoneNumber = "phoneNumber"
    case userId = "userId"
    case userImage = "userImage"
}


//**********
//==== iMessage Constants=====
//**********

//PlaceHolder text
let kPlaceHolder_Text_Mobile                   = "Your number here"
let kPlaceHolderText_Sign_Up_Name               = "Your text here"
let kPlaceHolderText_Sign_Up_Verify             = "Your code here"

//Notification Name`
let kNotification_Manage_Request_Style_Expand          = "manageRequestStyleExpand"
let kNotification_Manage_Request_Style_Compact       = "manageRequestStyleExpand"
let kNotification_Manage_Screen_Size                    = "notifyForChangeScreenSize"
let kNotification_Reload_Content_Data                    = "notifyReloadContenData"
let kNotification_Reload_Stream_Content                    = "notifyReloadStreamContent"


//Sets Constant
let iMsgCharacterSet                            = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"
let iMsgNumberSet                               = "0123456789"

//String Check
let kString_isBlank                         = ""
let kString_singleSpace                     = " "
let kNavigation_Stream                       = "Stream"
let kNavigation_Content                       = "Content"


//Constant
let kCornor_Radius : CGFloat                 = 18.0
let kCharacterMaxLength_Name                 = 30
let kCharacter_Max_Length_Verification_Code     = 5
let kCharacter_Max_Length_MobileNumber         = 15
let kCharacter_Min_Length_MobileNumber         = 12
let kName_Min_Length                           = 3
let kName_Max_Length                           = 20
let kHud_Alpha_Constant: CGFloat              = 0.7

//Alert Title
let kAlert_Title                                                         = "Alert!"
let kAlert_Title_Confirmation                                            = "Confirmation!"
let kAlert_Confirmation_Button_Title                                      = "Continue"
let kAlert_Cancel_Title                                                  = "Cancel"
let kAlert_Select_Time                                                   = "Select Time"
let kAlertTitle_Emogo                                                   = "Emogo"
let kAlertTitle_Yes = "YES"
let kAlertTitle_No =  "No"

//Alert Messagage
let kAlert_Phone_Number_Length_Msg                                          = "Phone Number must be 10 digits."
let kAlert_Verification_Length_Msg                                         = "Verification Code must be 5 digits."
let kAlert_Invalid_User_Name_Msg                                            = "Username limit is between 3-30 characters."
let kAlert_User_Name_Alreay_Exists_Msg                                       = "User Name Already Exists, Please enter Unique User Name."
let kAlert_Network_ErrorMsg                                               = "Unable to connect, Please check your internet connection!"
let kAlert_Stream_Added_Success                                            = "Stream Added Successfully."
let kAlert_Stream_Cover_Empty                                              = "Please Select Stream Cover Image."
let kAlert_Stream_Colab_Empty                                              = "Please Select Atleast one Collaborator."
let kAlert_Invalid_User_Space_Msg                                           = "Space not allowed."
let kAlert_Content_Added                                                  = "Content Created Successfully."
let kAlert_Content_Associated_To_Stream                                     = "Content associated with selected Stream."
let kAlert_Select_Stream                                                  = "Please Select Atleast one Stream to add Content."
let kAlert_Stream_Edited_Success                                           = "Stream Updated Successfully."
let kNotification_Update_Filter                                           = "updateFilterAfterCreateStream"
let kNotification_Update_Image_Cover                                       = "updateImageAfterEditStream"
let kAlert_Upload_Wait_Msg                                                 = "Please wait, it may take a while!"
let kAlert_Error_NameMsg                                                   = "Please enter minimum three characters."
let kAlert_CamPermission                                                = "AVCam doesn't have permission to use the camera, please change privacy settings"
let kAlert_Confirmation_Description_For_Profile                         = "We need to redirect on Emogo App for the User Profile, Do you want to go to Emogo?"
let kAlert_Confirmation_Description_For_Edit_Stream                      = "We need to redirect on Emogo App for the Edit stream, Do you want to go to Emogo?"
let kAlert_Confirmation_Description_For_Edit_Content                     = "We need to redirect on Emogo App for the Edit content, Do you want to go to Emogo?"
let kAlert_Confirmation_Description_For_Add_Content                      = "We need to redirect on Emogo App for the Add content, Do you want to go to Emogo?"
let kAlert_Edit_Image                                                    = "You don't have image to Edit."
let kAlert_Save_Image                                                    = "Image successfully saved to Photos library"
let kAlert_Delete_Stream_Msg                                              = "Are you sure, You want to Delete This Stream?"
let kAlert_Delete_Content_Msg                                             = "Are you sure, You want to Delete This Content?"
let kAlert_Logout                                                       = "Are you sure, You want to logout?"
let kAlert_Stream_Not_Found                                               = "The stream you requested does not exists."
let kAlert_Content_Not_Found                                              = "The content you requested does not exists."

let kAlert_Progress                                                     = "Content Will be shared by iMessage (work in progress)."
let kAlert_waitProcess                                                  = "It may take a while, All Content will be added in MyStuff, After Uploading!"

let kAlert_contenAddedToStream                                          = "Content added successfully to Stream(s)."
let kAlert_contentSelect                                          = "Select Stuff to proceed."


let kAlert_No_Stream_found                                          = "No Stream found"

let kAlert_No_User_Record_Found                                          = "No User found"

