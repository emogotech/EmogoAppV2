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
    
    // MARK: - Signup API
    
    func apiForUserSignup(userName:String, phone:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["phone_number":userName,"user_name":phone]
        APIManager.sharedInstance.POSTRequest(strURL: kSignUp, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == kResponseSuccessCode {
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
    func apiForVerifyUserOTP(otp:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["otp":otp]
        APIManager.sharedInstance.POSTRequest(strURL: kVerifyOTP, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == kResponseSuccessCode {
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
    
    
    // MARK: - Login API
    
    func apiForUserLogin(userName:String, phone:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["phone_number":userName,"user_name":phone]
        APIManager.sharedInstance.POSTRequest(strURL: kSignUp, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == kResponseSuccessCode {
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

    
}
