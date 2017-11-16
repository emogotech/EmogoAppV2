//
//  UserDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
import JSONModel

class UserDAO {
    
    var user:User!
    
    class var sharedInstance: UserDAO {
        struct Static {
            static let instance: UserDAO = UserDAO()
        }
        return Static.instance
    }
    
    func parseUserInfo(){
        if kDefault.value(forKey: kUserLogggedInData) != nil {
            let dict:[String:Any] = kDefault.value(forKey: kUserLogggedInData) as! [String:Any]
            if let u = try? User.init(dictionary: dict) {
                    self.user = u
            }
        }
    }
   
}

class User:JSONModel {
    
    var full_name                   :String! = ""
    var otp                         :String! = ""
    var phone_number                :String! = ""
    var token                       :String! = ""
    var user                        :String! = ""
    var user_id                     :String! = ""
    var user_image                  :String! = ""

    override class func propertyIsOptional(_ propertyName: String!) -> Bool {
        return true
    }

}




