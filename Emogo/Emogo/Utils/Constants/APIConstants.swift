//
//  APIConstants.swift
//  
//
//  Created by Vikas Goyal on 15/11/17.
//

import UIKit
import AWSCore


// MARK: -  AWS Credendtial's

let kAWS_AccessKey = "AKIAI44TFVCYXAX3XHIA"
let kAWS_SecretKey = "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"

// MARK: -  AWS Bucket's
let kBucketStreamMedia = "emogo-v2/stream-media"
let kBucketUserMedia = "emogo-v2/user-media"
let kBucketTesting = "emogo-v2/testing"

// MARK: -  AWS Region
let kRegion = AWSRegionType.USEast1
//let kRegion = AWSRegionType.APSouth1

// MARK: -  API
// base URL
let kBaseURL                                      = "http://54.196.89.61/api/"
let kGetCountryCode                               = "http://freegeoip.net/json/"

// MARK: -  API END POINTS

let kSignUpAPI                                      = "signup/"
let kVerifyOTPAPI                                   = "verify_otp/"
let kLoginAPI                                       = "login/"
let kUserNameVerifyAPI                              = "unique_user_name/"
let kResendAPI                                      = "resend_otp/"
let kStreamAPI                                      = "stream?"
let kPeopleAPI                                      = "users/"
let kStreamViewAPI                                  = "stream/"
let kContentAPI                                     = "content/"
let kContentAddToStreamAPI                          = "move_content_to_stream/"
let kGlobleSearchPeopleAPI                          = "users?people="
let kGlobleSearchStreamAPI                          = "stream?global_search="
let kProfileAPI                                     = "users/"
let kLogoutAPI                                      = "logout/"
let kCollaboratorAPI                                = "user_collaborators/"




// MARK: -  API STATUS CODE
enum APIStatus: String {
    case successOK = "200"
    case success = "201"
    case NoContent = "204"
    case BadRequest = "400"
    case ServerError = "500"
    case NotFound = "404"
}

