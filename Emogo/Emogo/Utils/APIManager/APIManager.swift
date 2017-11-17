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
    
    // MARK: - REQUEST WITH HEADER
    func POSTRequestWithHeader(strURL: String, Param: [String: Any], callback: ((ApiResult<Any, Error>) -> Void)?) {
        self.completionHandler = callback
        let url = "\(kBaseURL)\(strURL)"
        let headers : HTTPHeaders = ["Authorization" :"Token "]
        Alamofire.request(url, method: .post, parameters: Param, encoding: URLEncoding.default, headers: headers).validate().validate(statusCode: 200..<500).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
                 print(error.localizedDescription)
                 if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                 }
                 callback!(.error(error))
            }
        }
    }
    
    func GETRequestWithHeader(strURL: String, callback: ((ApiResult<Any, Error>) -> Void)?) {
        self.completionHandler = callback
        let url = "\(kBaseURL)\(strURL)"
        let headers : HTTPHeaders = ["Authorization" :"Token "]
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().validate(statusCode: 200..<500).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
                print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                }
                callback!(.error(error))
            }
        }
    }
    
    func PUTRequestWithHeader(strURL: String, Param: [String: Any], callback: ((ApiResult<Any, Error>) -> Void)?){
        self.completionHandler = callback
        let url = "\(kBaseURL)\(strURL)"
        let headers : HTTPHeaders = ["Authorization" :"Token "]
        Alamofire.request(url, method: .put, parameters: Param, encoding: URLEncoding.default, headers: headers).validate().validate(statusCode: 200..<500).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
                print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                }
                callback!(.error(error))
            }
        }
    }
    
    //MARK :- Upload Image to server
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
                        print(error.localizedDescription)
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
    
        
    // MARK: - REQUEST WITHOUT HEADER
    func POSTRequest(strURL: String, Param: [String: Any], callback: ((ApiResult<Any, Error>) -> Void)?) {
        self.completionHandler = callback
        let url = "\(kBaseURL)\(strURL)"
        print(url)
        //   let headers : HTTPHeaders = ["Content-Type" : "application/json"]
        Alamofire.request(url, method: .post, parameters: Param, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let dict:[String:Any] = value as! [String : Any]
                callback!(.success(dict))
                break
            case .failure(let error):
                // TODO deal with error
                print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                }
                callback!(.error(error))
            }
        }
    }
    
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
                print(error.localizedDescription)
                if response.response != nil {
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                }
                callback!(.error(error))
            }
            
        }
    }
    
    // MARK: - Get Country Code

    func getCountryCode(completionHandler:@escaping (_ strCode:String?)->Void){
        let url = URL(string: kGetCountryCode)
        let request = URLRequest(url: url!)
        let dataTask = URLSession.shared.dataTask(with: request) {
            data,response,error in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                    guard let code = jsonResult["country_code"] else {
                        completionHandler("")
                        return
                    }
                    completionHandler("\(code)")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                completionHandler("")
            }
        }
        dataTask.resume()
    }
}
