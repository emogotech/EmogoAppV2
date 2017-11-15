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
    
    func apiForUserSignup(userName:String, phone:String){
        let params:[String:Any] = ["":userName,"":phone]
        APIManager.sharedInstance.POSTRequest(strURL: "", Param: params) { (result) in
            switch(result){
            case .success(let value):
                print(value)
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Login API

    
}
