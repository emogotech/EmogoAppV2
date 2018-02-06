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
    
    func apiForVerifyLoginOTP(otp:String, phone:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["otp":otp,"phone_number":phone]
        APIManager.sharedInstance.POSTRequest(strURL: kVerifyLoginAPI, Param: params) { (result) in
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
                            //kDefault?.setValue(dictUserData.replacingNullsWithEmptyStrings(), forKey: kUserLogggedInData)
                          //  UserDAO.sharedInstance.parseUserInfo()
                            print(dictUserData)
                          //  kDefault?.set(true, forKey: kUserLogggedIn)
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
    
    func apiForCreateStream( streamName:String, streamDescription:String,coverImage:String,streamType:String,anyOneCanEdit:Bool,collaborator:[CollaboratorDAO],canAddContent:Bool,canAddPeople:Bool,height:Int,width:Int,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?,_ stream:StreamDAO?)->Void){
        var jsonCollaborator = [[String:Any]]()
        for obj in collaborator {
            let value = ["name":obj.name.trim(),"phone_number":obj.phone.trim()]
            jsonCollaborator.append(value)
        }
        var  params: [String: Any]!
        if anyOneCanEdit == true {
            params = [
                "height":height,
                "width":width,
                "name" : streamName,
                "description" : streamDescription,
                "image" : coverImage,
                "type":streamType,
                "any_one_can_edit":anyOneCanEdit,
                "collaborator":[],
                "collaborator_permission": [
                    "can_add_content" : true,
                    "can_add_people": false
                ]
            ]
        }else {
            params = [
                "height":height,
                "width":width,
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
                        if let data = (value as! [String:Any])["data"] {
                            let stream = StreamDAO(streamData: (data as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            stream.selectionType = StreamType.myStream
                            completionHandler(true,"",stream)
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage,nil)
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription,nil)
            }
        }
    }
    
    // MARK: - Edit Stream API
    func apiForEditStream(streamID:String,streamName:String, streamDescription:String,coverImage:String,streamType:String,anyOneCanEdit:Bool,collaborator:[CollaboratorDAO],canAddContent:Bool,canAddPeople:Bool,height:Int,width:Int,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        
        var jsonCollaborator = [[String:Any]]()
        for obj in collaborator {
            let value = ["name":obj.name.trim(),"phone_number":obj.phone.trim()]
            jsonCollaborator.append(value)
        }
        var  params: [String: Any]!
        if anyOneCanEdit == true {
            params = [
                "height":height,
                "width":width,
                "name" : streamName,
                "description" : streamDescription,
                "image" : coverImage,
                "type":streamType,
                "any_one_can_edit":anyOneCanEdit,
                "collaborator":[],
                "collaborator_permission": [
                    "can_add_content" : true,
                    "can_add_people": false
                ]
            ]
        }else {
            params = [
                "height":height,
                "width":width,
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
                        if let data = (value as! [String:Any])["data"] {
                            let stream = StreamDAO(streamData: (data as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            for i in 0..<StreamList.sharedInstance.arrayStream.count {
                                let oldData = StreamList.sharedInstance.arrayStream[i]
                                  if oldData.ID == stream.ID {
                                    print(oldData.selectionType)
                                    stream.selectionType = oldData.selectionType
                                    StreamList.sharedInstance.arrayStream[i] = stream
                                }
                            }
//                            for obj in StreamList.sharedInstance.arrayStream {
//                                if obj.ID == stream.ID {
//                                    if let index =  StreamList.sharedInstance.arrayStream.index(where: {$0.ID.trim() == stream.ID.trim()}) {
//                                        let oldData = StreamList.sharedInstance.arrayStream[index]
//                                        print("index found in main list")
//                                        print(oldData.selectionType)
//                                        stream.selectionType = oldData.selectionType
//                                        StreamList.sharedInstance.arrayStream[index] = stream
//                                    }
//                                }
//                            }
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
    
    
    // MARK: - Get All Stream API
    
    func apiForGetTopStreamList(completionHandler:@escaping (_ results:[StreamDAO]?, _ strError:String?)->Void) {
        var objects = [StreamDAO]()
        APIManager.sharedInstance.GETRequestWithHeader(strURL: kGetTopStreamAPI) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            print(data)
                            let result:[String:Any] = data as! [String:Any]
                            if let value = result["emogo"] {
                                let dict:[String:Any] = value as! [String : Any]
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        stream.selectionType = StreamType.emogoStreams
                                         objects.append(stream)
                                    }
                                }
                               
                            }
                            
                            if let value = result["featured"] {
                               
                                let dict:[String:Any] = value as! [String : Any]
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        stream.selectionType = StreamType.featured
                                        objects.append(stream)
                                    }
                                }
                                
                            }
                            
                            if let value = result["my_stream"] {
                                let dict:[String:Any] = value as! [String : Any]
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        stream.selectionType = StreamType.myStream
                                        objects.append(stream)
                                    }
                                }
                            }
                            
                            if let value = result["people"] {
                                let dict:[String:Any] = value as! [String : Any]
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let people = StreamDAO(peopleData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        people.selectionType = .People
                                        objects.append(people)
                                    }
                                }
                               
                            }
                            
                            if let value = result["popular"] {
                                let dict:[String:Any] = value as! [String : Any]
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        stream.selectionType = StreamType.populer
                                        objects.append(stream)
                                    }
                                }
                            }
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
                            if kShowOnlyMyStream.isEmpty {
                                if  type == .down {
                                    if !StreamList.sharedInstance.requestURl.contains(kBaseURL) {
                                        for _ in StreamList.sharedInstance.arrayStream {
                                            if let index = StreamList.sharedInstance.arrayStream.index(where: { $0.selectionType == currentStreamType}) {
                                                StreamList.sharedInstance.arrayStream.remove(at: index)
                                                print("Removed")
                                            }
                                        }
                                    }
                                }
                            }
                            for obj in result {
                                
                                let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                if kShowOnlyMyStream.isEmpty {
                                    stream.selectionType = filter
                                    StreamList.sharedInstance.arrayStream.append(stream)
                                }else {
                                    if StreamList.sharedInstance.arrayMyStream.contains(where: {$0.ID == stream.ID}) {
                                        // it exists, do something
                                    } else {
                                    StreamList.sharedInstance.arrayMyStream.append(stream)
                                    }
                                }
                               
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
    
    
    func apiForGetMyProfileStreamList(type:RefreshType,filter:StreamType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        
        if type == .start || type == .up{
            StreamList.sharedInstance.requestURl = "stream?self_created=True"
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
                               
                                    if StreamList.sharedInstance.arrayProfileStream.contains(where: {$0.ID == stream.ID}) {
                                        // it exists, do something
                                    } else {
                                        StreamList.sharedInstance.arrayProfileStream.append(stream)
                                    }
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
                            if data is NSDictionary {
                                let stream = StreamViewDAO(streamData: (data as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                completionHandler(stream,"")
                            }else {
                                completionHandler(nil,"request failed")
                            }
                        }
                    }else if status == APIStatus.NotFound.rawValue {
                        completionHandler(nil,"\(APIStatus.NotFound.rawValue)")
                    }else{
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                if error.localizedDescription.contains("\(APIStatus.NotFound.rawValue)") {
                    completionHandler(nil,"\(APIStatus.NotFound.rawValue)")
                    
                }else{
                    completionHandler(nil,error.localizedDescription)
                }
            }
        }
    }
    
    
    func apiForGetStreamColabList(streamID:String,completionHandler:@escaping (_ colabs:[CollaboratorDAO]?, _ strError:String?)->Void){
        let url = kStreamColabListAPI + "\(streamID)/"
        var arrayColabs = [CollaboratorDAO]()
        APIManager.sharedInstance.GETRequestWithHeader(strURL: url) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            if let colabDict = (data as! [String:Any])["collaborators"] {
                                let result:[Any] = colabDict as! [Any]
                                for obj in result {
                                    let colab = CollaboratorDAO(colabData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    arrayColabs.append(colab)
                                }
                            }
                            completionHandler(arrayColabs,"")
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
    
    func apiForGetPeopleList(type:RefreshType,deviceType:DeviceType, completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
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
                            if deviceType == .iPhone {
                                for obj in result {
                                    let people = StreamDAO(peopleData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    if StreamList.sharedInstance.arrayStream.contains(where: {$0.userId == people.userId}) {
                                        // it exists, do something
                                    } else {
                                        StreamList.sharedInstance.arrayStream.append(people)                           }
                                }
                            }else {
                                for obj in result {
                                    let people = PeopleDAO(peopleData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    PeopleList.sharedInstance.arrayPeople.append(people)
                                }
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
    
    
    func apiForCreateContent(contents:[Any]? = nil,contentName:String, contentDescription:String,coverImage:String,coverImageVideo:String,coverType:String,width:Int,height:Int,completionHandler:@escaping (_ contents:[ContentDAO]?, _ strError:String?)->Void){
        var params:[Any]!
        if contents == nil {
            params =  [["url":coverImage,"name":contentName.trim(),"type":coverType,"description":contentDescription.trim(),"video_image":coverImageVideo,"height":height,"width":width]]
            
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
        if type == .start || type == .up{
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
                                content.isShowAddStream = true
                                content.isEdit = true
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
    
    func apiForEditContent( contentID:String,contentName:String, contentDescription:String,coverImage:String,coverImageVideo:String,coverType:String,width:Int,height:Int,completionHandler:@escaping (_ content:ContentDAO?, _ strError:String?)->Void){
        let param = ["url":coverImage,"name":contentName.trim(),"type":coverType,"description":contentDescription.trim(),"video_image":coverImageVideo,"height":height,"width":width] as [String : Any]
        let url = kContentAPI + "\(contentID)/"
        print(param)
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
        if type == .start || type == .up{
            let url = "content/link_type/"
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
    
    func apiForGlobalSearchPeople(searchString:String,type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        PeopleList.sharedInstance.requestURl = kGlobleSearchPeopleAPI+searchString.replacingOccurrences(of: " ", with: "%20")
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

    // -------------------------------Search----------------------------

    func apiForSearchStream(strSearch:String,type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void){
        if type == .start || type == .up{
            let strURL =  kGlobleSearchStreamAPI+strSearch.replacingOccurrences(of: " ", with: "%20")
            StreamList.sharedInstance.requestURlSearch  = strURL
        }
        if StreamList.sharedInstance.requestURlSearch.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
       
        APIManager.sharedInstance.GETRequestWithHeader(strURL: StreamList.sharedInstance.requestURlSearch) { (result) in
            
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                StreamList.sharedInstance.arrayMyStream.append(stream)
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                               StreamList.sharedInstance.requestURlSearch = ""
                                completionHandler(.end,"")
                            }else {
                               StreamList.sharedInstance.requestURlSearch = obj as! String
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
    

        func apiForSearchPeople(strSearch:String,type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void){
            if type == .start || type == .up{
            let strURL =  kGlobleSearchPeopleAPI+strSearch.replacingOccurrences(of: " ", with: "%20")
            StreamList.sharedInstance.requestURlSearch  = strURL
        }
        if StreamList.sharedInstance.requestURlSearch.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: StreamList.sharedInstance.requestURlSearch) { (result) in
            
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let people = StreamDAO(peopleData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                StreamList.sharedInstance.arrayMyStream.append(people)
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                StreamList.sharedInstance.requestURlSearch = ""
                                completionHandler(.end,"")
                            }else {
                                StreamList.sharedInstance.requestURlSearch = obj as! String
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
    
    
    // -------------------------------End----------------------------
    
    
    func apiForGlobalSearchPeople(searchString:String,completionHandler:@escaping (_ peopleList:[PeopleDAO]?, _ strError:String?)->Void){
        PeopleList.sharedInstance.requestURl = kGlobleSearchPeopleAPI+searchString.replacingOccurrences(of: " ", with: "%20")
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
        let strURL = kGlobleSearchStreamAPI+strSearch.replacingOccurrences(of: " ", with: "%20")
        
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
    
    
    // MARK: - Logout API
    
    func apiForLogoutUser( completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kLogoutAPI, Param: nil) { (result) in
            
            switch(result){
                
            case .success(let value):
                print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        completionHandler(true,"")
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
    
    
    func apiForGetColabList(type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        if type == .start || type == .up{
            StreamList.sharedInstance.requestURl = kCollaboratorAPI
        }
        if StreamList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        print("stream request URl ==\(StreamList.sharedInstance.requestURl!)")
        APIManager.sharedInstance.GETRequestWithHeader(strURL: StreamList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                if StreamList.sharedInstance.arrayProfileStream.contains(where: {$0.ID == stream.ID}) {
                                    // it exists, do something
                                } else {
                                    StreamList.sharedInstance.arrayProfileStream.append(stream)                                }
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
    
    func apiForGetUserStream(userID:String,type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        if type == .start || type == .up{
            StreamList.sharedInstance.requestURl = kUserStreamAPI
        }
        if StreamList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        print("stream request URl ==\(StreamList.sharedInstance.requestURl!)")
        let param = ["user_id":userID]
        APIManager.sharedInstance.POSTRequestWithHeader(strURL:  StreamList.sharedInstance.requestURl, Param: param) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                if StreamList.sharedInstance.arrayMyStream.contains(where: {$0.ID == stream.ID}) {
                                    // it exists, do something
                                } else {
                                    StreamList.sharedInstance.arrayMyStream.append(stream)                                }
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
    
    func apiForSendReport( type:String, user:String, stream: String, content : String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let param = ["type":type.capitalized,"user":user,"stream":stream,"content":content]
        print(param)
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kReportAPI, Param: param) { (result) in
            switch(result){
            case .success(let value):
                print(value)
                completionHandler(true,"success")
                break
            case .error(let error):
                print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
                break
            }
        }
    }
    
    
    // MARK: - User Profile Update
    func apiForUserProfileUpdate(name:String,profilePic:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let url = kProfileUpdateAPI + "\(UserDAO.sharedInstance.user.userId!)/"
        let phone : String = UserDAO.sharedInstance.user.phoneNumber
        let params:[String:Any] = ["user_image":profilePic , "phone_number" : phone]
        APIManager.sharedInstance.PUTRequestWithHeader(strURL: url, Param: params) { (result) in
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
    
    
    
    func apiForDeleteContentFromStream(streamID:String,contentID:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let url = kDeleteStreamContentAPI + "\(streamID)/"
        let params:[String:Any] = ["content":[contentID]]
        print(url)
        print(params)
        APIManager.sharedInstance.delete(strURL: url, Param: params) { (result) in
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
    
    func apiForGetContent(contenID:String, completionHandler:@escaping (_ results:[String:Any]?, _ strError:String?)->Void) {
        let url = kGetContentDescriptionAPI+contenID+"/"
        APIManager.sharedInstance.GETRequestWithHeader(strURL: url) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            print(data)
                            let result:[String:Any] = data as! [String:Any]
                            print(result)
                            completionHandler(result,"")
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
}

