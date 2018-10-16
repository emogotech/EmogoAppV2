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
                //print(value)
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
               // print(error.localizedDescription)
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
                //print(value)
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
               // print(error.localizedDescription)
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
                //print(value)
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
              //  print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    func apiForVerifyLoginOTP(otp:String, phone:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["otp":otp,"phone_number":phone]
        APIManager.sharedInstance.POSTRequest(strURL: kVerifyLoginAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
               // print(value)
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
               // print(error.localizedDescription)
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
               // print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    // MARK: - Login API
    
    func apiForUserLogin( phone:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["phone_number":phone]
       // print(params)
        APIManager.sharedInstance.POSTRequest(strURL: kLoginAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
                //print(value)
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
               // print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - LANDING API'S
    
    // MARK: - Create Stream API
    
    func apiForCreateStream( streamName:String, streamDescription:String,coverImage:String,streamType:String,anyOneCanEdit:Bool,collaborator:[CollaboratorDAO],canAddContent:Bool,canAddPeople:Bool,height:Int,width:Int,color:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?,_ stream:StreamDAO?)->Void){
        var jsonCollaborator = [[String:Any]]()
        for obj in collaborator {
            let value = ["name":obj.name.trim(),"phone_number":obj.phone.trim()]
            jsonCollaborator.append(value)
        }
        var  params: [String: Any]!
        if anyOneCanEdit == true {
            params = [
                "color":color,
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
                "color":color,
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
            //    print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let stream = StreamDAO(streamData: (data as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            if streamType == "Private" {
                                stream.selectionType = StreamType.Private
                            }else {
                                stream.selectionType = StreamType.Public
                            }
                            completionHandler(true,"",stream)
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage,nil)
                    }
                }
            case .error(let error):
               // print(error.localizedDescription)
                completionHandler(false,error.localizedDescription,nil)
            }
        }
    }
    
    // MARK: - Edit Stream API
    func apiForEditStream(streamID:String,streamName:String, streamDescription:String,coverImage:String,streamType:String,anyOneCanEdit:Bool,collaborator:[CollaboratorDAO],canAddContent:Bool,canAddPeople:Bool,height:Int,width:Int,color:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        
        var jsonCollaborator = [[String:Any]]()
        for obj in collaborator {
            let value = ["name":obj.name.trim(),"phone_number":obj.phone.trim()]
            jsonCollaborator.append(value)
        }
        var  params: [String: Any]!
        if anyOneCanEdit == true {
            params = [
                "color":color,
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
                "color":color,
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
        //print(params)
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
                        
                            
                            if let index =  StreamList.sharedInstance.arrayStream.index(where: {$0.ID.trim() == stream.ID.trim()}) {
                                let oldData = StreamList.sharedInstance.arrayStream[index]
                             
                                stream.haveSomeUpdate = false
                                stream.selectionType = oldData.selectionType
                                if stream.streamType.lowercased() == "public" {
                                    stream.selectionType = StreamType.Public
                                    
                                }else {
                                    stream.selectionType = StreamType.Private
                                    
                                }
                                StreamList.sharedInstance.arrayStream[index] = stream
                            }
                           
                            if StreamList.sharedInstance.arrayViewStream.count != 0 {
                                if let index =  StreamList.sharedInstance.arrayViewStream.index(where: {$0.ID.trim() == stream.ID.trim()}) {
                                    StreamList.sharedInstance.arrayViewStream[index] = stream
                                }
                            }
                            
                            if StreamList.sharedInstance.arrayProfileColabStream.count != 0 {
                                if let index =  StreamList.sharedInstance.arrayProfileColabStream.index(where: {$0.ID.trim() == stream.ID.trim()}) {
                                    StreamList.sharedInstance.arrayProfileColabStream[index] = stream
                                }
                            }
                            
                            
                            if StreamList.sharedInstance.arrayProfileStream.count != 0 {
                                if let index =  StreamList.sharedInstance.arrayProfileStream.index(where: {$0.ID.trim() == stream.ID.trim()}) {
                                    StreamList.sharedInstance.arrayProfileStream[index] = stream
                                }
                            }
                        }
                        
                        completionHandler(true,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage)
                    }
                }
            case .error(let error):
                //print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
        
    }
    
    func apiForEditStreamColabs(streamID:String,streamType:String,anyOneCanEdit:Bool,canAddContent:Bool,canAddPeople:Bool,collaborator:[CollaboratorDAO],completionHandler:@escaping (_ result:StreamViewDAO?, _ strError:String?)->Void){
     
        var jsonCollaborator = [[String:Any]]()
        for obj in collaborator {
            let value = ["name":obj.name.trim(),"phone_number":obj.phone.trim()]
            jsonCollaborator.append(value)
        }
       let params = [
            "type":streamType,
            "any_one_can_edit":anyOneCanEdit,
            "collaborator":jsonCollaborator,
            "collaborator_permission": [
                "can_add_content" : canAddContent,
                "can_add_people": canAddPeople]
        ] as [String : Any]
        
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
                                  
                                    stream.selectionType = oldData.selectionType
                                    StreamList.sharedInstance.arrayStream[i] = stream
                                }
                            }
                            
                            if StreamList.sharedInstance.arrayProfileColabStream.count != 0 {
                                if let index =  StreamList.sharedInstance.arrayProfileColabStream.index(where: {$0.ID.trim() == stream.ID.trim()}) {
                                    
                                    if stream.arrayColab.count >  0 {
                                        StreamList.sharedInstance.arrayProfileColabStream[index] = stream
                                    }else {
                                        StreamList.sharedInstance.arrayProfileColabStream.remove(at: index)
                                    }
                                }else {
                                    if stream.arrayColab.count >  0 {
                                        StreamList.sharedInstance.arrayProfileColabStream.insert(stream, at: 0)
                                    }
                                }
                            }
                            
                            
                            if StreamList.sharedInstance.arrayProfileStream.count != 0 {
                                if let index =  StreamList.sharedInstance.arrayProfileStream.index(where: {$0.ID.trim() == stream.ID.trim()}) {
                                    if stream.arrayColab.count ==  0 {
                                        StreamList.sharedInstance.arrayProfileStream[index] = stream
                                    }else {
                                        StreamList.sharedInstance.arrayProfileStream.remove(at: index)
                                    }
                                }else {
                                    if stream.arrayColab.count ==  0 {
                                        StreamList.sharedInstance.arrayProfileStream.insert(stream, at: 0)
                                    }
                                }
                            }
                            
                        }
                        completionHandler(nil,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
               // print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
        
    }
    
    // MARK: - Get All Stream API
    
    func apiForGetTopStreamList(completionHandler:@escaping (_ results:[StreamDAO]?, _ strError:String?)->Void) {
        var objects = [StreamDAO]()
        APIManager.sharedInstance.GETRequestWithHeader(strURL: kGetTopStreamAPI) { (result) in
            switch(result){
            case .success(let value):
              // print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                          //  print(data)
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
                            
                            if let value = result["public_stream"] {
                                let dict:[String:Any] = value as! [String : Any]
                              //  print(dict)
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                            stream.selectionType = StreamType.Public
                                        objects.append(stream)
                                    }
                                }
                            }
                            
                            if let value = result["private_stream"] {
                                let dict:[String:Any] = value as! [String : Any]
                                //  print(dict)
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        stream.selectionType = StreamType.Private
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
                            
                            if let value = result["following_stream"] {
                                let dict:[String:Any] = value as! [String : Any]
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        stream.selectionType = StreamType.Following
                                        objects.append(stream)
                                    }
                                }
                            }
                            
                            if let value = result["liked"] {
                                let dict:[String:Any] = value as! [String : Any]
                                if let obj = dict["data"] {
                                    let array:[Any] = obj as! [Any]
                                    for obj in array {
                                        let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        stream.selectionType = StreamType.Liked
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
               // print(error.localizedDescription)
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
                //print(error.localizedDescription)
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
    
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: StreamList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
               // print(value)
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
                                               // print("Removed")
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
               // print(error.localizedDescription)
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
   
        APIManager.sharedInstance.GETRequestWithHeader(strURL: StreamList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
               // print(value)
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
               // print(error.localizedDescription)
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
               // print(error.localizedDescription)
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
                //print(value)
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
               // print(error.localizedDescription)
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
                //print(value)
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
               // print(error.localizedDescription)
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
       // print(params)
        APIManager.sharedInstance.post(params: params, strURL: kContentAPI) { (result) in
            
            switch(result){
            case .success(let value):
                //print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        var arrayContents = [ContentDAO]()
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let objContent = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeShareMessage {
                                    objContent.isShowAddStream = true
                                }
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
               // print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    
    
    // MARK: - Content List API
    
    func apiForGetStuffList(type:RefreshType,contentType:StuffType? = .All, completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        if type == .start || type == .up{
            if contentType == .All {
            ContentList.sharedInstance.requestURl = kContentAPI
            }else{
                let type:String = (contentType?.rawValue)!
                ContentList.sharedInstance.requestURl = kContentAPI + "?type=\(type)"
            }
        }
        print(ContentList.sharedInstance.requestURl)
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
                            print(result)
                            for obj in result {
                                let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                content.isUploaded = true
                                content.isShowAddStream = true
                                content.isEdit = true
                                content.stuffType = contentType
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
                //print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    
    // MARK: - Delete  Content API
    
    func apiForDeleteContent(contents:[String],completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let param = ["content_list":contents]//kContentAPI
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: "delete_content/", Param: param) { (result) in
            switch(result){
            case .success(let value):
                //print(value)
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
               // print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
        
    }
    
    
    // MARK: - Content Edit API
    
    func apiForEditContent( contentID:String,contentName:String, contentDescription:String,coverImage:String,coverImageVideo:String,coverType:String,width:Int,height:Int,completionHandler:@escaping (_ content:ContentDAO?, _ strError:String?)->Void){
        let param = ["url":coverImage,"name":contentName.trim(),"type":coverType,"description":contentDescription.trim(),"video_image":coverImageVideo,"height":height,"width":width] as [String : Any]
        let url = kContentAPI + "\(contentID)/"
       // print(param)
        APIManager.sharedInstance.patch(strURL: url, Param: param) { (result) in
            switch(result){
            case .success(let value):
                //print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        
                        if let data = (value as! [String:Any])["data"] {
                            let content = ContentDAO(contentData: (data as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            content.isUploaded = true
                            content.isShowAddStream = true
                            completionHandler(content,"")
                        }
                        
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
                //print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Add  Content To Stream API
    
    func apiForContentAddOnStream(contentID:[String],streams:[String],completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void) {
        let param:[String:Any] = ["contents":contentID,"streams":streams]
        //print(param)
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kContentAddToStreamAPI, Param: param) { (result) in
            
            switch(result){
            case .success(let value):
                //print(value)
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
                //print(error.localizedDescription)
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
               // print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    // MARK: - Global seearch for People
    
    func apiForGlobalSearchPeople(searchString:String,type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        PeopleList.sharedInstance.requestURl = kGlobleSearchPeopleAPI+searchString.replacingOccurrences(of: " ", with: "%20")
      
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: PeopleList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
              
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
                //print(error.localizedDescription)
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
                print(value)
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
                //print(error.localizedDescription)
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
               // print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            //print(result)
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
                //print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    
    // -------------------------------End----------------------------
    
    
    func apiForGlobalSearchPeople(searchString:String,completionHandler:@escaping (_ peopleList:[PeopleDAO]?, _ strError:String?)->Void){
        PeopleList.sharedInstance.requestURl = kGlobleSearchPeopleAPI+searchString.replacingOccurrences(of: " ", with: "%20")
       
        APIManager.sharedInstance.GETRequestWithHeader(strURL: PeopleList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
                //print(value)
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
               // print(error.localizedDescription)
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
               // print(error.localizedDescription)
                completionHandler(objects,error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Logout API
    
    func apiForLogoutUser( completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kLogoutAPI, Param: nil) { (result) in
            
            switch(result){
                
            case .success(let value):
              
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
                    print(value)
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                if StreamList.sharedInstance.arrayProfileColabStream.contains(where: {$0.ID == stream.ID}) {
                                    // it exists, do something
                                } else {
                                    StreamList.sharedInstance.arrayProfileColabStream.append(stream)                                }
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
                //print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
            
        }
        
    }
    
    func apiForGetUserStream(userID:String,type:RefreshType,streamType:String,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        
        if type == .start || type == .up{
            if streamType == "1" {
                StreamList.sharedInstance.requestURl = kUserStreamEmogoAPI + userID
            }else {
                StreamList.sharedInstance.requestURl = kUserStreamColabAPI + userID
            }
        }
        if StreamList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
    
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: StreamList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let array:[Any] = data as! [Any]
                         
                            for obj in array {
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
               // print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
        
    }
    
    func apiForSendReport( type:String, user:String, stream: String, content : String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let param = ["type":type.capitalized,"user":user,"stream":stream,"content":content]
        //print(param)
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kReportAPI, Param: param) { (result) in
            switch(result){
            case .success(_):
               // print(value)
                completionHandler(true,"success")
                break
            case .error(let error):
               // print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
                break
            }
        }
    }
    
    
    // MARK: - User Profile Update
    func apiForUserProfileUpdate(name:String,location:String,website:String,biography:String,birthday:String,profilePic:String,displayName:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){

        let url = kProfileUpdateAPI + "\(UserDAO.sharedInstance.user.userId!)/"
        let phone : String = UserDAO.sharedInstance.user.phoneNumber
        let params:[String:Any] = ["full_name":name,"user_image":profilePic , "phone_number" : phone,"location":location,"website":website,"biography":biography,"birthday":birthday,"display_name":displayName]
        print(params)
        APIManager.sharedInstance.PUTRequestWithHeader(strURL: url, Param: params) { (result) in
            switch(result){
            case .success(let value):
              
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
            
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    
    func apiForAssignProfileStream(streamID:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        
        let url = kProfileUpdateAPI + "\(UserDAO.sharedInstance.user.userId!)/"
        let params:[String:Any] = ["profile_stream":streamID]
      
        APIManager.sharedInstance.PUTRequestWithHeader(strURL: url, Param: params) { (result) in
            switch(result){
            case .success(let value):
            
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        
                        if let data = (value as! [String:Any])["data"] {
                            let dictUserData:NSDictionary = data as! NSDictionary
                            kDefault?.setValue(dictUserData.replacingNullsWithEmptyStrings(), forKey: kUserLogggedInData)
                            UserDAO.sharedInstance.parseUserInfo()
                            kDefault?.set(true, forKey: kUserLogggedIn)
                            NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                        }
                        completionHandler(true,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(false,errorMessage)
                    }
                }
            case .error(let error):
               
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    
    func apiForGetUserInfo(userID:String,isCurrentUser:Bool,completionHandler:@escaping (_ isSuccess:PeopleDAO?, _ strError:String?)->Void) {
        let url = kProfileUpdateAPI + "\(userID)/"
        var pepole:PeopleDAO!
        APIManager.sharedInstance.GETRequestWithHeader(strURL: url) { (result) in
            switch(result){
            case .success(let value):
               print(value)
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        
                        if let data = (value as! [String:Any])["data"] {
                            let dictUserData:NSDictionary = data as! NSDictionary
                           
                            if isCurrentUser {
                                kDefault?.setValue(dictUserData.replacingNullsWithEmptyStrings(), forKey: kUserLogggedInData)
                                UserDAO.sharedInstance.parseUserInfo()
                                kDefault?.set(true, forKey: kUserLogggedIn)
                            }else {
                                pepole = PeopleDAO(peopleData: dictUserData.replacingNullsWithEmptyStrings() as! [String : Any])
                            }
                        }
                        completionHandler(pepole,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(pepole,errorMessage)
                    }
                }
            case .error(let error):
            
                completionHandler(pepole,error.localizedDescription)
            }
        }
    }
    
    
    func apiForDeleteContentFromStream(streamID:String,contentID:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let url = kDeleteStreamContentAPI + "\(streamID)/"
        let params:[String:Any] = ["content":[contentID]]
  
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: url, Param: params) { (result) in
            switch(result){
            case .success(let value):
              
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
                        
                            let result:[String:Any] = data as! [String:Any]
                           
                            completionHandler(result,"")
                        }
                        
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
          
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    func apiForReorderStreamContent(orderArray:[ContentDAO],streamID:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
     
        var arrayOrder = [[String:Any]]()
        for i in 1..<orderArray.count {
            let obj = orderArray[i]
            let value = ["id":obj.contentID!,"order":"\(i-1)"]
            arrayOrder.append(value)
        }
        
        let param = ["content":arrayOrder,"stream":streamID] as [String : Any]
 

        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kStreamReorderContentAPI, Param: param) { (result) in
            
            switch(result){
            case .success(let value):
           
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
          
                completionHandler(false,error.localizedDescription)
            }
            
        }
     
    }
    
    
    func apiForReorderMyContent(orderArray:[ContentDAO],completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        
        var arrayOrder = [[String:Any]]()
        for i in 0..<orderArray.count {
            let obj = orderArray[i]
            let value = ["id":obj.contentID!,"order":"\(i)"]
            arrayOrder.append(value)
        }
        
        let param = ["my_order":arrayOrder] as [String : Any]
      
        
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kReorderContentAPI, Param: param) { (result) in
            
            switch(result){
            case .success(let value):
              
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
              
                completionHandler(false,error.localizedDescription)
            }
            
        }
        
    }
    
    
    func apiForGetTopContent(completionHandler:@escaping (_ isSuccess:[TopContent]?, _ strError:String?)->Void){
        
     APIManager.sharedInstance.GETRequestWithHeader(strURL: kGetTopContentAPI) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                          
                            if  let all = (data as! [String:Any])["all"] {
                                
                                let array:[Any] = all as! [Any]
                                
                                for obj in array {
                                    let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    content.isUploaded = true
                                    content.isShowAddStream = true
                                    content.isEdit = true
                                    content.stuffType = .All
                                    ContentList.sharedInstance.arrayStuff.append(content)
                                }
                            }
                         if  let picture = (data as! [String:Any])["picture"] {
                               
                                let array:[Any] = picture as! [Any]
                                
                                for obj in array {
                                    let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    content.isUploaded = true
                                    content.isShowAddStream = true
                                    content.isEdit = true
                                    content.stuffType = .Picture
                                    ContentList.sharedInstance.arrayStuff.append(content)
                                }
                            
                            }
                           if let video = (data as! [String:Any])["video"] {
                              
                               let array:[Any] = video as! [Any]
                            
                                for obj in array {
                                    let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    content.isUploaded = true
                                    content.isShowAddStream = true
                                    content.isEdit = true
                                    content.stuffType = .Video
                                    ContentList.sharedInstance.arrayStuff.append(content)
                                }
                           
                            }
                           if let link = (data as! [String:Any])["link"] {
                             
                                let array:[Any] = link as! [Any]
                            
                                for obj in array {
                                    let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    content.isUploaded = true
                                    content.isShowAddStream = true
                                    content.isEdit = true
                                    content.stuffType = .Links
                                    ContentList.sharedInstance.arrayStuff.append(content)
                                }
                            
                                
                            }
                         if  let giphy = (data as! [String:Any])["giphy"] {
                               
                                let array:[Any] = giphy as! [Any]
                                for obj in array {
                                    let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    content.isUploaded = true
                                    content.isShowAddStream = true
                                    content.isEdit = true
                                    content.stuffType = .Giphy
                                    ContentList.sharedInstance.arrayStuff.append(content)
                                }
                            }
                            if  let giphy = (data as! [String:Any])["note"] {
                                
                                let array:[Any] = giphy as! [Any]
                                for obj in array {
                                    let content = ContentDAO(contentData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                    content.isUploaded = true
                                    content.isShowAddStream = true
                                    content.isEdit = true
                                    content.stuffType = .Notes
                                    ContentList.sharedInstance.arrayStuff.append(content)
                                }
                            }
                       
                            completionHandler([],"")
                        }
                        
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
             
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    // MARK: - VERSION 2 API'S

    func apiForLikedStreamList(completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: kGetUserLikedStreamsAPI) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let _ = (value as! [String:Any])["data"] {
                       
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
             
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    func apiForLikeUnlikeStream(stream:String, status:String,completionHandler:@escaping (_ updatedCount:String?,_ status:String?,_ results:[LikedUser]?, _ strError:String?)->Void){
        let param = ["stream":stream,"status":status] as [String : Any]
        var count:String! = ""
        var statusLiked:String! = ""
        var arrayLikedUsers = [LikedUser]()

        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kStreamLikeDislikeAPI, Param: param) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                          
                            let result:[String:Any] = data as! [String : Any]
                            if let likestatus = result["status"] {
                                statusLiked = "\(likestatus)"
                            }
                            if let totalLike = result["total_liked"]{
                                count = "\(totalLike)"
                            }
                            
                            if let likedArray = result["user_liked"]{
                                if likedArray is [Any] {
                                    let array:[Any] = likedArray  as! [Any]
                                    for value in array {
                                        let user = LikedUser(dictUser: (value as!  NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                        arrayLikedUsers.append(user)
                                    }
                                }
                            }
                            
                        }
                        completionHandler(count,statusLiked,arrayLikedUsers,"")

                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,nil,arrayLikedUsers,errorMessage)
                    }
                }
            case .error(let error):
              
                completionHandler(nil,nil,arrayLikedUsers,error.localizedDescription)
            }
        }
    }
    
    func apiForFollowUser(userID:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let param = ["following":userID]
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kUserFollowAPI, Param: param) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let _ = (value as! [String:Any])["data"] {
                         
                        }
                        completionHandler(true,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
              
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    
    
    func apiForUnFollowUser(userID:String,completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let url = kUserUnFollowAPI+userID+"/"
        APIManager.sharedInstance.delete(strURL: url) { (result) in
            switch(result){
            case .success(let value):
                
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
            
                completionHandler(false,error.localizedDescription)
            }
            
        }
    }
    

    
    func apiForUserFollowerList(type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void){
        
        if type == .start || type == .up{
            FollowList.sharedInstance.arrayFollowers.removeAll()
            FollowList.sharedInstance.requestURl = kUserFollowersAPI
        }
        if FollowList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: FollowList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
              
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                           
                            for obj in result {
                                let follow = FollowerDAO(dictFollow: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                FollowList.sharedInstance.arrayFollowers.append(follow)
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                FollowList.sharedInstance.requestURl = ""
                                completionHandler(.end,"")
                            }else {
                                FollowList.sharedInstance.requestURl = obj as! String
                                completionHandler(.down,"")
                            }
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
               
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    func apiForUserFollowingList(type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void){
        
        if type == .start || type == .up{
            FollowList.sharedInstance.arrayFollowers.removeAll()
            FollowList.sharedInstance.requestURl = kUserFollowingAPI
        }
        if FollowList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        APIManager.sharedInstance.GETRequestWithHeader(strURL: FollowList.sharedInstance.requestURl) { (result) in
            switch(result){
            case .success(let value):
           
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                          
                            for obj in result {
                                let follow = FollowerDAO(dictFollow: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                FollowList.sharedInstance.arrayFollowers.append(follow)
                            }
                        }
                        if let obj = (value as! [String:Any])["next"]{
                            if obj is NSNull {
                                FollowList.sharedInstance.requestURl = ""
                                completionHandler(.end,"")
                            }else {
                                FollowList.sharedInstance.requestURl = obj as! String
                                completionHandler(.down,"")
                            }
                        }
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
            
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    
   func apiForFollowingUserSearch(name:String,completionHandler:@escaping (_ results:[FollowerDAO]?, _ strError:String?)->Void){
    let url =  kUserFollowingSeacrhAPI + name
    var arrayResults = [FollowerDAO]()
    APIManager.sharedInstance.GETRequestWithHeader(strURL: url) { (result) in
        switch(result){
        case .success(let value):
           
            if let code = (value as! [String:Any])["status_code"] {
                let status = "\(code)"
                if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                    if let data = (value as! [String:Any])["data"] {
                        let result:[Any] = data as! [Any]
                     
                        for obj in result {
                            let follow = FollowerDAO(dictFollow: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            arrayResults.append(follow)
                        }
                    }
                    completionHandler(arrayResults,"")
                }else {
                    let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                    completionHandler(nil,errorMessage)
                }
            }
        case .error(let error):
       
            completionHandler(nil,error.localizedDescription)
        }
    }
    }
    
    func apiForFollowerUserSearch(name:String,completionHandler:@escaping (_ type:[FollowerDAO]?, _ strError:String?)->Void){
        let url =  kUserFollowerSearchAPI + name
        var arrayResults = [FollowerDAO]()
        APIManager.sharedInstance.GETRequestWithHeader(strURL: url) { (result) in
            switch(result){
            case .success(let value):
          
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                   
                            for obj in result {
                                let follow = FollowerDAO(dictFollow: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                arrayResults.append(follow)
                            }
                        }
                        completionHandler(arrayResults,"")

                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
             
                completionHandler(nil,error.localizedDescription)
            }
        }
    }
    
    // MARK:- Save Stuff Content API
    
    func apiForSaveStuffContent(contentID:String, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let params:[String:Any] = ["content_id":contentID]
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kSaveStuffContentAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
               
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
           
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    //MARK:- Like - DisLike Content API
    
    func apiForLikeDislikeContent(content:String, status:Int, completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
    
        let params:[String:Any] = ["content":content ,"status":status]
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kLikeDislikeContentAPI, Param: params) { (result) in
            switch(result){
            case .success(let value):
              
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
               
                completionHandler(false,error.localizedDescription)
            }
        }
    }
    
    //MARK:- get collab List
    
    func apiForGetMyStreamCollabList(type:RefreshType, completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
        
        if type == .start || type == .up{
            StreamList.sharedInstance.requestURl = kCollaboratorAPI
        }
        if StreamList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
     
        
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
                                if kShowOnlyMyStream.isEmpty {
                                    
                                    StreamList.sharedInstance.arrayStream.append(stream)
                                }else {
                                    if StreamList.sharedInstance.arrayMyStream.contains(where: {$0.ID == stream.ID}) {
                                      
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
               
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    
    //MAR:- API for Emogo Contact List
    
    func apiForGetEmogoContactList(type:RefreshType,deviceType:DeviceType, completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void) {
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
        
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            if deviceType == .iPhone {
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
              
                completionHandler(nil,error.localizedDescription)
            }
            
        }
    }
    
    func apiForIncreaseStreamViewCount(streamID:String, completionHandler:@escaping (_ isSuccess:String?, _ strError:String?)->Void){
        
        let params:[String:Any] = ["stream":streamID]
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kAPIIncreaseViewCount, Param: params) { (result) in
            switch(result){
            case .success(let value):
             
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    var strCount:String! = "0"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                           if let count = (data as! [String:Any])["total_view_count"] {
                                strCount = "\(count)"
                            }
                        }
                        completionHandler(strCount,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler("",errorMessage)
                    }
                }
            case .error(let error):
               
                completionHandler("",error.localizedDescription)
            }
        }
        
    }
  
    func apiForValidate(contacts:[String], completionHandler:@escaping (_ result:[String:Any]?, _ strError:String?)->Void){
        
        let params:[String:Any] = ["contact_list":contacts]
        var dictResult = [String:Any]()
        APIManager.sharedInstance.POSTRequestWithHeader(strURL: kAPICheckEmogoUser, Param: params) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                   
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let dictValue = (value as! [String:Any])["data"] {
                            dictResult = dictValue as! [String : Any]
                        }
                        completionHandler(dictResult,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(dictResult,errorMessage)
                    }
                }
            case .error(let error):
             
                completionHandler(dictResult,error.localizedDescription)
            }
        }
        
    }
    
    
    //MARK:- myStream List New
    
    func getMyStreamNewList(type:RefreshType,completionHandler:@escaping (_ type:RefreshType?, _ strError:String?)->Void){
        if type == .start || type == .up{
            StreamList.sharedInstance.requestURl = kMyStreamListAPI
        }
        if StreamList.sharedInstance.requestURl.trim().isEmpty {
            completionHandler(.end,"")
            return
        }
        var objects = [StreamDAO]()
        
        APIManager.sharedInstance.GETRequestWithHeader(strURL: kMyStreamListAPI) { (result) in
            switch(result){
            case .success(let value):
                if let code = (value as! [String:Any])["status_code"] {
                    let status = "\(code)"
                    if status == APIStatus.success.rawValue  || status == APIStatus.successOK.rawValue  {
                        if let data = (value as! [String:Any])["data"] {
                            let result:[Any] = data as! [Any]
                            for obj in result {
                                let stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                                stream.selectionType = StreamType.Public
                                objects.append(stream)
                            }
                        }
                        
                        completionHandler(.end,"")
                    }else {
                        let errorMessage = SharedData.sharedInstance.getErrorMessages(dict: value as! [String : Any])
                        completionHandler(nil,errorMessage)
                    }
                }
            case .error(let error):
               // print(error.localizedDescription)
                completionHandler(nil,error.localizedDescription)
            }
        }
        
        
    }
    func apiForGoToPreview(contentID:[String],completionHandler:@escaping (_ isSuccess:Bool?, _ strError:String?)->Void){
        let url = kAPIGoToPreview + "\(contentID)/"
     
        APIManager.sharedInstance.GETRequest(strURL: url) { (result) in
            switch(result){
            case .success(let value):
                //print(value)
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
                //print(error.localizedDescription)
                completionHandler(false,error.localizedDescription)
            }
        }
        
    }
}

