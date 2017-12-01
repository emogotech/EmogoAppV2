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
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage)
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
        let params:[String:Any] = ["phone_number":phone,"user_name":userName]
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
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage)
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
        let params:[String:Any] = ["otp":otp,"phone_number":phone]
        APIManager.sharedInstance.POSTRequest(strURL: kVerifyOTPAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        
                        if let data = (value as! [String:Any])["data"] {
                            let dictUserData:NSDictionary = data as! NSDictionary
                            kDefault.setValue(dictUserData.replacingNullsWithEmptyStrings(), forKey: kUserLogggedInData)
                            UserDAO.sharedInstance.parseUserInfo()
                            kDefault.set(true, forKey: kUserLogggedIn)
                        }
                        completionHandler(true,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    // MARK: - Resend OTP API
    
    func apiForResendOTP( phone:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["phone_number":phone]
        APIManager.sharedInstance.POSTRequest(strURL: kResendAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        var otp:String! = ""
                        if let data = (value as! [String:Any])["data"] {
                            let result:[String:Any] = data as! [String : Any]
                            if let code = result["otp"] {
                                otp = "\(code)"
                            }
                        }
                        completionHandler(true,otp)
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage)
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
        let params:[String:Any] = ["phone_number":phone]
        APIManager.sharedInstance.POSTRequest(strURL: kLoginAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let dictUserData:NSDictionary = data as! NSDictionary
                            kDefault.setValue(dictUserData.replacingNullsWithEmptyStrings(), forKey: kUserLogggedInData)
                            UserDAO.sharedInstance.parseUserInfo()
                            print(UserDAO.sharedInstance.user.fullName)
                            kDefault.set(true, forKey: kUserLogggedIn)
                            
                            SharedData.sharedInstance.setUserInfo(dictObject: dictUserData)
                        }
                        completionHandler(true,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - LANDING API'S
    
    // MARK: - Create Stream API
    
    func apiForCreateStream( streamName:String, streamDescription:String,coverImage:String,streamType:String,anyOneCanEdit:Bool,collaborator:[CollaboratorDAO],canAddContent:Bool,canAddPeople:Bool,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        var jsonCollaborator = [[String:Any]]()
        for obj in collaborator {
            let value = ["name":obj.name.trim(),"phone_number":obj.phone.trim()]
            jsonCollaborator.append(value)
        }
        var  params: [String: Any]!
        if anyOneCanEdit == true {
            params = [
            "name" : streamName,
            "description" : streamDescription,
            "image" : coverImage,
            "type":streamType,
            "any_one_can_edit":anyOneCanEdit,
            "collaborator":jsonCollaborator
            ]
        }else {
            params = [
            "name" : streamName,
            "description" : streamDescription,
            "image" : coverImage,
            "type":streamType,
            "any_one_can_edit":anyOneCanEdit,
            "collaborator":jsonCollaborator ,
            "collaborator_permission": [
            "can_add_content" : canAddContent,
            "can_add_people": canAddPeople
            ]
            ]
        }
      
        
        print(params)
        
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kStreamAPI, Param: params) { (result) in
            
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        completionHandler(true,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    func apiForGetStreamList(completionHandler:@escaping (_ results:[StreamDAO]?, _ strError:String?)->Void) {
        var objects = [StreamDAO]()
        var strURL = kStreamAPI
        if(SharedData.sharedInstance.nextStreamString != ""){
            strURL = "\(kStreamAPI)\(SharedData.sharedInstance.nextStreamString!)"
        }
        APIManager.sharedInstance.GETRequestWithHeader(strURL: strURL) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                         if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                objects.append(stream)
                            }
                        }
                        if let nextPagningUrl = (value as! [String:Any])["next"] as? String  {
                            let lastIndexFromUrl = (nextPagningUrl ).components(separatedBy: "/")
                                SharedData.sharedInstance.nextStreamString = lastIndexFromUrl.last
                                SharedData.sharedInstance.isMoreContentAvailable = true
                        }else{
                            SharedData.sharedInstance.isMoreContentAvailable = false
                        }
                        completionHandler(objects,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(objects,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(objects,error.localizedDescription)
            }
        }
    }
}
