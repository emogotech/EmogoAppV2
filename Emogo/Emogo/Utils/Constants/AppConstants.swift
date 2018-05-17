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
let kStoryboardStuff                     = UIStoryboard(name: "Stuff", bundle: nil)
let kStoryboardPhotoEditor               = UIStoryboard(name: "ImageEditor", bundle: nil)

let kPhoneFormat                         = "##########"

let kNavigationColor = UIColor(red: 247.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
let kaddStreamSwitchOffColor = UIColor(red: 219.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
let kaddStreamSwitchOnColor = UIColor(red: 0, green: 173/255.0, blue: 243/255.0, alpha: 1.0)

let kaddCardBorderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
let kaddCardBorderWidth : CGFloat = 3

var kContainerNav = ""
var kBackNav = ""
var kNavForProfile = ""
var kShowOnlyMyStream = ""
var kShowRetake = ""


// Selected Tag For Container
var currentTag = 111

var currentStreamType:StreamType! =  .featured  //.featured


var arraySelectedContent:[ContentDAO]?
var arrayAssests:[ImportDAO]?

// MARK: -  FONT'S
let kFontRegular = "SFProDisplay-Regular"
let kFontMedium = "SFProDisplay-Medium"
let kFontLight = "SFProDisplay-Light"
let kFontBold = "SFProDisplay-Bold"

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
let kStoryboardID_ProfileUpdateView = "profileUpdateView"
let kStoryboardID_ShowPreviewView = "showPreviewView"
let kStoryboardID_TermsAndPrivacyView = "termsAndPrivacyView"
let kStoryboardID_MyStuffPreView = "myStuffPreView"
let kStoryboardID_FollowersView = "followersView"
let kStoryboardID_AddCollaboratorContactsView = "addCollaboratorContactsView"
let kStoryboardID_PhotoEditorView = "photoEditorView"
let kStoryboardID_FilterView = "filterView"
let kStoryboardID_SettingView = "settingView"
let kStoryboardID_VideoEditorView = "videoEditorView"



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
let iMsgSegue_HomeCollectionPeople              = "PeopleSearchCollectionViewCells"

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
let kHeader_ProfileHeaderView = "profileHeaderView"
let kCell_MyStuffCollectionCell = "myStuffCollectionCell"
let kHeader_ProfileStreamView = "profileStreamView"
let kCell_FollowerCell = "followerCell"




let kCell_ProfileStreamCell = "profileStreamCell"
let kSegue_AddCollaboratorsView = "addColabSegue"
let kSegue_ContainerSegue = "containerSegue"

// MARK: - UserDefault Identifier
let kUserLogggedIn                      = "userloggedin"
let kUserLogggedInData                  = "userloggedinData"
let kaddBackgroundImage                 = "menuBackGround"
let kRetakeIndex = "indexRetake"
let kBounceAnimation = "ActiveBounceAnimation"

// MARK: - Notification Observer Identifier
let kLogoutIdentifier = "LogoutNavigationIdentifier"
let kUpdateStreamViewIdentifier = "UpdateStreamIdentifier"
let kProfileUpdateIdentifier = "ProfileUpdateIdentifier"

// MARK:- Redirect Links
let kDeepLinkURL = "Emogo://emogo/"
let kDeepLinkTypeProfile = "Profile"
let kDeepLinkTypePeople = "People"
let kDeepLinkTypeAddStream = "AddStream"
let kDeepLinkTypeAddContent = "AddStreamContent"
let kDeepLinkTypeEditStream = "editStream"
let kDeepLinkTypeEditContent = "editStreamContent"
let kDeepLinkTypeShareAddContent = "addContentFromShare"
let kDeepLinkTypeShareMessage = "shareWithMessage"
let kUserDefaltForContentData = "editContentData"
let kSearchType = "PEOPLE"
let kCollaobatorList = "Collaborator List"
let kDeeplinkOpenUserProfile = "DeeplinkUserProfile"

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
    case userProfileID = "user_profile_id"

}



//**********
//==== iMessage Constants=====
//**********

//PlaceHolder text
let kPlaceHolder_Text_Mobile                   = "Your number here"
let kPlaceHolderText_Sign_Up_Name               = "Your text here"
let kPlaceHolderText_Sign_Up_Verify             = "Your code here"


//Action sheet constant
let kAlertSheet_Spam = "It's Spam"
let kAlertSheet_Inappropiate = "It's inappropiate"
let kAlertSheet_SaveToGallery = "Save To Gallery"
let kAlertSheet_SaveToMyStuff = "Save To MyStuff"


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
let kAlert_Title_Confirmation                                            = "Confirmed!"
let kAlert_Confirmation_Button_Title                                      = "Continue"
let kAlert_Cancel_Title                                                  = "Cancel"
let kAlert_Title_ActionSheet                                                  =     "Report"
let kAlert_Select_Time                                                   = "Select Time"
let kAlertTitle_Emogo                                                   = "Emogo"
let kAlert_Capture_Title                                               = "Capture limit exceeded!"
let kAlert_Message                                                     = "Message!"


let kAlertTitle_Yes = "YES"
let kAlertTitle_No =  "No"
let kAlertTitle_Unfollow =  "Unfollow"


//Alert Messagage
let kAlert_Phone_Number_Length_Msg                                          = "Phone Number must be 10 digits."
let kAlert_Verification_Length_Msg                                         = "Verification Code must be 5 digits."
let kAlert_Invalid_User_Name_Msg                                            = "Username limit is 3-30 characters."
let kAlert_User_Name_Alreay_Exists_Msg                                       = "This username already exists, please enter a different name."
let kAlert_Network_ErrorMsg                                               = "We are unable to connect. Please check your internet connection!"
let kAlert_Stream_Added_Success                                            = "Stream added successfully."
let kAlert_Stream_Cover_Empty                                              = "Please select an image to be your stream cover."
let kAlert_Stream_Deleted_Success                           =           "Stream Deleted Successfully!"
let kAlert_Stream_Colab_Empty                                              = "Please select at least one collaborator."
let kAlert_Invalid_User_Space_Msg                                           = "Usernames can't contain spaces. Sorry!"
let kAlert_Terms_Condition_Msg                                           = "Accept Terms And Condition."
let kAlert_OTP_Msg                                       = "One time Password sent on your number Successfully."

let kAlert_Content_Added                                                  = "Content Created Successfully."
let kAlert_Content_Associated_To_Stream                                     = "Content added to your stream."
let kAlert_Select_Stream                                                  = "Please select at least one stream to add content."
let kAlert_Stream_Edited_Success                                           = "Stream Updated Successfully."
let kNotification_Update_Filter                                           = "updateFilterAfterCreateStream"
let kNotification_Update_Image_Cover                                       = "Cover image updated successfully"
let kAlert_Upload_Wait_Msg                                                 = "We are uploading your content... give us just a minute"
let kAlert_Error_NameMsg                                                   = "Please enter a minimum of three characters."
let kAlert_CamPermission                                                = "We need permission to access your camera! Please change your privacy settings"
let kAlert_Confirmation_Description_For_Profile                         = "We need to redirect you to the Emogo App to access your User Profile. Are you ready?"


let kAlert_Confirmation_Description_For_People                         = "We need to redirect you to the Emogo App to access User Profile. Are you ready?"


let kAlert_Confirmation_Description_For_Edit_Stream                      = "We need to redirect you to the Emogo App so you can edit your stream. Are you ready?"

let kAlert_Confirmation_For_Edit_Stream_Content                      = "Please first done edit contents"

let kAlert_Confirmation_For_Edit_Content                      = "Saving these changes will remove the previous version of this content."


let kAlert_Confirmation_Description_For_Edit_Content                     = "We need to redirect  you to the Emogo App so you can edit content. Are you ready?"
let kAlert_Confirmation_Description_For_Add_Content                      = "We need to redirect you to the Emogo App so you can add content. Are you ready?"
let kAlert_Edit_Image                                                    = "You don't have image to Edit."
let kAlert_Save_Image                                                    = "Image successfully saved to Photos library"
let kAlert_Save_Video                                                   = "Video successfully saved to Photos library"
let kAlert_Save_GIF                                                   = "GIF successfully saved to Photos library"
let kAlert_Save_Link                                                  = "Link successfully saved to Photos library"
let kAlert_Save_Image_MyStuff                                             = "Image successfully saved to My Stuff"
let kAlert_Save_Video_MyStuff                                                   = "Video successfully saved to My Stuff"
let kAlert_Save_GIF_MyStuff                                                     = "GIF successfully saved to My Stuff"
let kAlert_Save_Link_MyStuff                                                     = "Link successfully saved to My Stuff"
let kAlert_Delete_Stream_Msg                                              = "Are you sure you want to delete this Stream?"
let kAlert_Delete_Content_Msg                                             = "Are you sure you want to delete this Content?"
let kAlert_Logout                                                       = "Are you sure you want to logout?"
let kAlert_Stream_Not_Found                                               = "The stream you requested does not exist."
let kAlert_Content_Not_Found                                              = "The content you requested does not exist."
let kAlert_Stream_Add_Edited_Content = "If you proceed further without saving changes, recent changes will not appear later.Do you still want to continue?"
let kAlert_Progress                                                     = "Sharing content to iMessage..."
let kAlert_waitProcess                                                  = "Uploading Content..."

let kAlert_contenAddedToStream                                          = "Content added successfully."
let kAlert_contentSelect                                          = "Select something to proceed."

let kAlert_Success_Report_User = "You have successfully reported this user."
let kAlert_Success_Report_Stream = "You have successfully reported this stream."
let kAlert_Success_Report_Content = "You have successfully reported this content."

let kAlert_Capture_Limit_Exceeded = "You can select only 10 images at once."
let kAlert_Stream_Deleted = "This Stream has been deleted by its author!"



let kName_Report_Inappropriate = "Inappropriate"
let kName_Report_Spam = "Spam"
let kAlert_No_Stream_found                                          = "No Stream found"

let kAlert_No_User_Record_Found                                          = "No User found"

let kAlert_RemoveProfile                                         = "Remove"
let kAlert_UpateProfile                                         = "Update"
let kAlert_ValidWebsite                                         = "Please Enter Valid URL."

let kAlert_ProfileStreamAdded                                  = "Your Profile Stream is Updated."
let kAlert_Select_Stream_For_Assign                                                  = "Please select a stream to assign as Profile Stream."
let kAlert_UnFollow_a_User            = "Do you really want to unfollow %@?"




