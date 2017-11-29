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
        let collaboratorPermission = ["can_add_content":canAddContent,"can_add_people":canAddPeople]
        var jsonCollaborator = [[String:Any]]()
        for obj in collaborator {
            let value = ["name":obj.name!,"phone_number":obj.phone!]
            jsonCollaborator.append(value)
        }
        print(jsonCollaborator)
        let params:[String:Any] = ["name":streamName,description:streamDescription,"image":coverImage,"category":"","type":streamType,"any_one_can_edit":anyOneCanEdit,"content":"","collaborator":jsonCollaborator,"collaborator":collaboratorPermission]
        
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kAddStreamAPI, Param: params) { (result) in
            
        }
    }
    
    /*
     URL : http://54.196.89.61/api/stream/
     Mandatory Fields- Name, Image, Type
     Request Type : POST
     Header :
     Content-Type:application/json
     Authorization:token 3d9936ffb460924612f9083dd002b176bb004ddb
     Request: {
     "name" :"The first stream",
     "description":"Stream Description",
     "category": null,
     "image": "https://trello.com/image.png",
     "type" : "Public",
     "any_one_can_edit":true,
     "content":[
     { "name" : "Component-1","url" : "~~~??~>@/-1http://localhost/phppgadmin/images/themes/default/Export.png","type" : "Picture"},{ "name" : "Component-2","url" : "http://localhost/phppgadmin/images/themes/default/Export.png","type" : "Picture"}, { "name" : "","url" : "http://localhost/phppgadmin/images/themes/default/Export.png","type" : "Picture"}
     ],
     "collaborator":[
     { "name" : "Ranjeet singh","phone_number" : "+917921215626262"},{ "name" : "Ranjeet singh","phone_number" : "+917921215626262"},{ "name" : "Ranjeet singh","phone_number" : "+917921215626262"}
     ],
     "collaborator_permission":{
     "can_add_content":true,
     "can_add_people":false
     }
     }

 */

}
