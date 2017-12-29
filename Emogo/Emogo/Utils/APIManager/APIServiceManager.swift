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
                            kDefault?.setValue(dictUserData.replacingNullsWithEmptyStrings(), forKey: kUserLogggedInData)
                            UserDAO.sharedInstance.parseUserInfo()
                            kDefault?.set(true, forKey: kUserLogggedIn)
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
                            kDefault?.setValue(dictUserData.replacingNullsWithEmptyStrings(), forKey: kUserLogggedInData)
                            UserDAO.sharedInstance.parseUserInfo()
                            print(UserDAO.sharedInstance.user.fullName)
                            kDefault?.set(true, forKey: kUserLogggedIn)
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
    
    // MARK: - Edit Stream API
    func apiForEditStream(streamID:String,streamName:String, streamDescription:String,coverImage:String,streamType:String,anyOneCanEdit:Bool,collaborator:[CollaboratorDAO],canAddContent:Bool,canAddPeople:Bool,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        
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
        let url = kStreamViewAPI + "\(streamID)/"
        APIManager.sharedInstance.patch(strURL: url, Param: params) { (result) in
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
    
    
    
    // MARK: - Get All Stream API
    
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
    
    // MARK: - Get All Stream API iPhone
    
    func apiForiPhoneGetStreamList(type:RefreshType,filter:StreamType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        
        if type == .start || type == .up{
            StreamList.sharedInstance.updateRequestType(filter: filter)
        }
        if StreamList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        print("stream request URl ==\(StreamList.sharedInstance.requestURl!)")
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: StreamList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                if StreamList.sharedInstance.arrayStream.contains(where: {$0.ID == stream.ID}) {
                                    // it exists, do something
                                } else {
                                    StreamList.sharedInstance.arrayStream.append(stream)                                }
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                StreamList.sharedInstance.requestURl = ""
                                SharedData.sharedInstance.isMoreContentAvailable = false
                                
                                completionHandler(.end,"")
                            }else {
                                StreamList.sharedInstance.requestURl = obj as! String
                                SharedData.sharedInstance.isMoreContentAvailable = true
                                
                                completionHandler(.down,"")
                            }
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    // MARK: - People List API
    func apiForViewStream(streamID:String,completionHandler:@escaping (_ stream:StreamViewDAO?, _ strError:String?)->Void){
        let url = kStreamViewAPI + "\(streamID)/"
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: url) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            print(data)
                            let stream = StreamViewDAO(streamData: (data as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            completionHandler(stream,"")
                            
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    // MARK: - People List API
    
    func apiForGetPeopleList(type:RefreshType, completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        if type == .start || type == .up{
            PeopleList.sharedInstance.requestURl = kPeopleAPI
        }
        if PeopleList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: PeopleList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let people = PeopleDAO(peopleData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                PeopleList.sharedInstance.arrayPeople.append(people)
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                PeopleList.sharedInstance.requestURl = ""
                                completionHandler(.end,"")
                            }else {
                                PeopleList.sharedInstance.requestURl = obj as! String
                                completionHandler(.down,"")
                            }
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    
    // MARK: - Delete Stream  API
    
    func apiForDeleteStream(streamID:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let url = kStreamViewAPI + "\(streamID)/"
        APIManager.sharedInstance.delete(strURL: url) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.NoContent.rawValue{
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
    
    // MARK: - Create Content  API
    
    
    func apiForCreateContent(contents:[Any]? = nil,contentName:String, contentDescription:String,coverImage:String,coverImageVideo:String,coverType:String,completionHandler:@escaping (_ contents:[ContentDAO]?, _ strError:String?)->Void){
        var params:[Any]!
        if contents == nil {
            params =  [["url":coverImage,"name":contentName,"type":coverType,"description":contentDescription,"video_image":coverImageVideo]]
        }else {
            params = contents
        }
        print(params)
        APIManager.sharedInstance.post(params: params, strURL: kContentAPI) { (result) in
            
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        var arrayContents = [ContentDAO]()
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let objContent = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                objContent.isUploaded = true
                                arrayContents.append(objContent)
                            }
                        }
                        completionHandler(arrayContents,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    
    
    // MARK: - Content List API
    
    func apiForGetStuffList(type:RefreshType, completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        if type == .start{
            ContentList.sharedInstance.requestURl = kContentAPI
        }
        if ContentList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        APIManager.sharedInstance.GETRequestWithHeader(strURL: ContentList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                content.isUploaded = true
                                ContentList.sharedInstance.arrayStuff.append(content)
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                ContentList.sharedInstance.requestURl = ""
                                completionHandler(.end,"")
                            }else {
                                ContentList.sharedInstance.requestURl = obj as! String
                                completionHandler(.down,"")
                            }
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    
    // MARK: - Delete  Content API
    
    func apiForDeleteContent(contents:[String],completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let param = ["content_list":contents]
        APIManager.sharedInstance.delete(strURL: kContentAPI, Param: param) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.NoContent.rawValue{
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
    
    
    // MARK: - Content Edit API
    
    func apiForEditContent( contentID:String,contentName:String, contentDescription:String,coverImage:String,coverImageVideo:String,coverType:String,completionHandler:@escaping (_ content:ContentDAO?, _ strError:String?)->Void){
        let param = ["url":coverImage,"name":contentName,"type":coverType,"description":contentDescription,"video_image":coverImageVideo]
        let url = kContentAPI + "\(contentID)/"
        print(url)
        
        APIManager.sharedInstance.patch(strURL: url, Param: param) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        
                        if let data = (value as! [String:Any])["data"] {
                            let content = ContentDAO(contentData: (data as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            content.isUploaded = true
                            completionHandler(content,"")
                        }
                        
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Add  Content To Stream API
    
    func apiForContentAddOnStream(contentID:[String],streams:[String],completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void) {
        let param:[String:Any] = ["contents":contentID,"streams":streams]
        print(param)
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kContentAddToStreamAPI, Param: param) { (result) in
            
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
                completionHandler(nil,error.localizedDescription)
            }
        }
        
    }
    
    func apiForGetLink(type:RefreshType, completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void){
        if type == .start{
            let url = "content?type=link"
            ContentList.sharedInstance.requestURl = url
        }
        if ContentList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        APIManager.sharedInstance.GETRequestWithHeader(strURL: ContentList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                content.isUploaded = true
                                ContentList.sharedInstance.arrayLink.append(content)
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                ContentList.sharedInstance.requestURl = ""
                                completionHandler(.end,"")
                            }else {
                                ContentList.sharedInstance.requestURl = obj as! String
                                completionHandler(.down,"")
                            }
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    // MARK: - Global seearch for People
    func apiForGlobalSearchPeople(searchString:String,completionHandler:@escaping (_ peopleList:[PeopleDAO]?, _ strError:String?)->Void){
        PeopleList.sharedInstance.requestURl = kGlobleSearchPeopleAPI+searchString
        print(PeopleList.sharedInstance.requestURl)
        APIManager.sharedInstance.GETRequestWithHeader(strURL: PeopleList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let people = PeopleDAO(peopleData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                PeopleList.sharedInstance.arrayPeople.append(people)
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                PeopleList.sharedInstance.requestURl = ""
                                completionHandler(nil,"")
                            }else {
                                PeopleList.sharedInstance.requestURl = obj as! String
                                completionHandler(nil,"")
                            }
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    // MARK: - Global seearch for People
    func apiForGetStreamListFromGlobleSearch(strSearch:String, completionHandler:@escaping (_ results:[StreamDAO]?, _ strError:String?)->Void) {
        var objects = [StreamDAO]()
        let strURL = kGlobleSearchStreamAPI+strSearch
        
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
    
    
    func apiForGetUserInfo(user:String, completionHandler:@escaping (_ profile:ProfileDAO?, _ strError:String?)->Void) {
        let url = kProfileAPI + "\(user)"
        APIManager.sharedInstance.GETRequestWithHeader(strURL: url) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                           // let result:[Any] = data as! [Any]
                            let profile = ProfileDAO(profileData: (data as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            completionHandler(profile,"")
                        }
                        /*
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                PeopleList.sharedInstance.requestURl = ""
                                completionHandler(nil,"")
                            }else {
                                PeopleList.sharedInstance.requestURl = obj as! String
                                completionHandler(nil,"")
                            }
                        }
 */
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    
    
}
