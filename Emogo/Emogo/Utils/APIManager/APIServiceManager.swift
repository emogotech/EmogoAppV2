//
//  APIServiceManager.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit


class APIServiceManager: NSObject {
    
    class var sharedInstance: APIServiceManager {
        struct Static {
            static let instance: APIServiceManager = APIServiceManager()
        }
        return Static.instance
    }
    
    // MARK: - ONBOARDING API'S
    
    // MARK: - Username Verify API
    
    func apiForUserNameVerify(userName:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["user_name":userName]
        APIManager.sharedInstance.POSTRequest(strURL: kUserNameVerifyAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        completionHandler(true,"")
                    }else {
                        completionHandler(false,kAlertUserNameAlreayExistsMsg)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    // MARK: - Signup API

    
    func apiForUserSignup(userName:String, phone:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let strPhone = phone.replacingOccurrences(of:SharedData.sharedInstance.countryCode!, with: "")
        print(strPhone)
        let params:[String:Any] = ["phone_number":strPhone,"user_name":userName,"country_code":SharedData.sharedInstance.countryCode]
        APIManager.sharedInstance.POSTRequest(strURL: kSignUpAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        // For Get OTP (Static Login)
                        var otp:String! = ""
                        if let data = (value as! [String:Any])["data"] {
                            let result:[String:Any] = data as! [String : Any]
                            if let code = result["otp"] {
                                otp = "\(code)"
                            }
                        }
                        completionHandler(true,otp)
                    }else {
                        completionHandler(false,"")
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    // MARK: - Verify OTP API
    func apiForVerifyUserOTP(otp:String, phone:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let strPhone = phone.replacingOccurrences(of:SharedData.sharedInstance.countryCode!, with: "")
        print(strPhone)
        let params:[String:Any] = ["otp":otp,"phone_number":strPhone]
        APIManager.sharedInstance.POSTRequest(strURL: kVerifyOTPAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let dictUserData:NSDictionary = data as! NSDictionary
                            kDefault.setValue(dictUserData, forKey: kUserLogggedInData)
                            UserDAO.sharedInstance.parseUserInfo()
                            kDefault.set(true, forKey: kUserLogggedIn)
                        }
                        completionHandler(true,"")
                    }else {
                        completionHandler(false,"")
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Login API
    
    func apiForUserLogin( phone:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let strPhone = phone.replacingOccurrences(of:SharedData.sharedInstance.countryCode!, with: "")
        print(strPhone)
        let params:[String:Any] = ["phone_number":strPhone]
        APIManager.sharedInstance.POSTRequest(strURL: kLoginAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let dictUserData:NSDictionary = data as! NSDictionary
                            kDefault.setValue(dictUserData, forKey: kUserLogggedInData)
                            UserDAO.sharedInstance.parseUserInfo()
                            print(UserDAO.sharedInstance.user.fullName)
                            kDefault.set(true, forKey: kUserLogggedIn)
                        }
                        completionHandler(true,"")
                    }else {
                        completionHandler(false,"")
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    
}
