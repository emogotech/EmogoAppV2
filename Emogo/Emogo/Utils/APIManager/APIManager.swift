//
//  APIManager.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import SwiftyJSON

enum ApiResult<T, Error> {
    case success(T)
    case error(Error)
}

class APIManager: NSObject {
    
    typealias CompletionClosure = (ApiResult<Any,Error>) -> ()
    fileprivate var completionHandler:CompletionClosure!
    
    // MARK: - INIT
    class var sharedInstance: APIManager {
        struct Static {
            static let instance: APIManager = APIManager()
        }
        return Static.instance
    }
    
    // MARK: - POST REQUEST
    func POSTRequestWithHeader(strURL: String, Param: [String: Any]? = nil, callback: ((ApiResult<Any, Error>) -> Void)?) {
        self.completionHandler = callback
        
        var url = "\(kBaseURL)\(strURL)"
        if strURL.contains(kBaseURL) {
            url = strURL
        }
        
        let headers : HTTPHeaders = ["Authorization" :"Token \(UserDAO.sharedInstance.user.token!)"]
        Alamofire.request(url, method: .post, parameters: Param, encoding: JSONEncoding.default, headers: headers).validate().validate(statusCode: 200..<500).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
                // print(error.localizedDescription)
                 if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                 }
                 callback!(.error(error))
            }
        }
    }
    
    
    func POSTRequest(strURL: String, Param: [String: Any], callback: ((ApiResult<Any, Error>) -> Void)?) {
        self.completionHandler = callback
        let url = "\(kBaseURL)\(strURL)"
        //print(url)
        //   let headers : HTTPHeaders = ["Content-Type" : "application/json"]
        Alamofire.request(url, method: .post, parameters: Param, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
               // print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                }
                callback!(.error(error))
            }
        }
    }
    
    
    func POSTImageWith(strURL: String,img:UIImage ,callback: ((ApiResult<Any, Error>) -> Void)?){
        self.completionHandler = callback
        let parameters = [
            "destination": "users",
            "field" : "image"
        ]
        let data = UIImageJPEGRepresentation(img, 0.2)
        let url = "\(kBaseURL)\(strURL)"
        let headers : HTTPHeaders = ["Authorization" :"Token "]
        Alamofire.upload(multipartFormData: { (multipartData) in
            multipartData.append(data!, withName: "image", fileName: "file.jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (SessionManager) in
            
            switch SessionManager {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let dict:[String:Any] = value as! [String : Any]
                        callback!(.success(dict))
                        break
                    case .failure(let error):
                        // TODO deal with error
                      //  print(error.localizedDescription)
                        if response.response != nil {
                            let statusCode = (response.response?.statusCode)!
                           print(statusCode)
                        }
                        callback!(.error(error))
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    // Post Param as Array
    
    func post(params:[Any],strURL: String,callback: ((ApiResult<Any, Error>) -> Void)?){
        //creates the request
        let url = "\(kBaseURL)\(strURL)"
        var request = URLRequest(url: try! url.asURL())
        //some header examples
        request.httpMethod = "POST"
        request.setValue("Token \(UserDAO.sharedInstance.user.token!)",
            forHTTPHeaderField: "Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        //now just use the request with Alamofire
        
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
               // print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)! //example : 200
                   // print(statusCode)
                    if statusCode == 401 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil)
                    }
                }
                callback!(.error(error))
            }
        }
    }
    
    // MARK: - GET REQUEST
    
    func GETRequestWithHeader(strURL: String, callback: ((ApiResult<Any, Error>) -> Void)?) {
        self.completionHandler = callback
        var url = "\(kBaseURL)\(strURL)"
        if strURL.contains(kBaseURL) {
            url = strURL.stringByAddingPercentEncodingForURLQueryParameter()!
        }
        let headers : HTTPHeaders = ["Authorization" :"Token \(UserDAO.sharedInstance.user.token!)"]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().validate(statusCode: 200..<500).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
               // print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)! //example : 200
                   // print(statusCode)
                    if statusCode == 401 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil)
                    }
                }
                    
                callback!(.error(error))
            }
        }
    }
    
    // Get Request
    
    func GETRequest(strURL: String,callback: ((ApiResult<Any, Error>) -> Void)?) {
        self.completionHandler = callback
        let url = "\(kBaseURL)\(strURL)"
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
               // print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)! //example : 200
                   // print(statusCode)
                    if statusCode == 401 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil)
                    }
                }
                callback!(.error(error))
            }
        }
    }
    
    func getCountryCode(completionHandler:@escaping (_ strCode:String?)->Void){
        
        Alamofire.request(kGetCountryCode,encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
               // print(dict)
                guard let code = dict["country_code"] else {
                    
                    completionHandler("")
                    return
                }
                completionHandler("\(code)")
                break
            case .failure(let error):
                // TODO deal with error
                print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                }
                completionHandler("")
            }
        }
    }
    
    
    // MARK: - PUT REQUEST

    func PUTRequestWithHeader(strURL: String, Param: [String: Any], callback: ((ApiResult<Any, Error>) -> Void)?){
        self.completionHandler = callback
        let url = "\(kBaseURL)\(strURL)"
        let headers : HTTPHeaders = ["Authorization" :"Token \(UserDAO.sharedInstance.user.token!)"]
       // print(headers)
        //print(url)

        Alamofire.request(url, method: .put, parameters: Param, encoding: JSONEncoding.default, headers: headers).validate().validate(statusCode: 200..<500).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
                print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)! //example : 200
                   // print(statusCode)
                    if statusCode == 401 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil)
                    }
                }
                callback!(.error(error))
            }
        }
    }
    
  
    // MARK: - DELETE REQUEST

   
    func delete(strURL: String,Param: [String: Any]? = nil,callback: ((ApiResult<Any, Error>) -> Void)?) {
        let url = "\(kBaseURL)\(strURL)".trim()
        let headers : HTTPHeaders = ["Authorization" :"Token \(UserDAO.sharedInstance.user.token!)"]
       // print(url)
        Alamofire.request(url, method: .delete, parameters: Param, encoding: JSONEncoding.default, headers: headers).validate().validate(statusCode: 200..<500).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
               // print(error)
             
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)! //example : 200
                   // print(statusCode)
                    if statusCode == 401 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil)
                    }
                }
                
                callback!(.error(error))
            }
        }
    }
    
    // MARK: - PATCH REQUEST

    func patch(params:[Any],strURL: String,callback: ((ApiResult<Any, Error>) -> Void)?){
        //creates the request
       // print(params)
        self.completionHandler = callback
        let url = "\(kBaseURL)\(strURL)"
        var request = URLRequest(url: try! url.asURL())
        //some header examples
        request.httpMethod = "PATCH"
        request.setValue("Token \(UserDAO.sharedInstance.user.token!)",
            forHTTPHeaderField: "Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        //now just use the request with Alamofire
        
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
               // print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)! //example : 200
                    //print(statusCode)
                    if statusCode == 401 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil)
                    }
                }
                callback!(.error(error))
            }
        }
    }
    
    func patch(strURL: String, Param: [String: Any], callback: ((ApiResult<Any, Error>) -> Void)?) {
        self.completionHandler = callback
        
        let url = "\(kBaseURL)\(strURL)"
        let headers : HTTPHeaders = ["Authorization" :"Token \(UserDAO.sharedInstance.user.token!)"]
        Alamofire.request(url, method: .patch, parameters: Param, encoding: JSONEncoding.default, headers: headers).validate().validate(statusCode: 200..<500).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
               // print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                }
                callback!(.error(error))
            }
        }
    }
    
    func download(strFile:String,completionHandler:@escaping (_ filePath:String?, _ fileURL:URL?)->Void) {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            // the name of the file here I kept is yourFileName with appended extension
            documentsURL.appendPathComponent(strFile.getName())
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(strFile, to: destination).response { response in
            
            if response.destinationURL != nil {
                //print(response.destinationURL!)
             if   let imagePath = response.destinationURL?.path {
                                   // print(imagePath)
                completionHandler(imagePath,response.destinationURL)
                return
                            }
            }else {
                completionHandler(nil,nil)
            }
//            if response.request, let imagePath = response.destinationURL?.path {
//                print(imagePath)
//            }
        }
    }
}
