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
    
    }
   
}

class User:JSONModel {
    
    var firstName               :String! = ""
    var lastName                :String! = ""
    
    override class func propertyIsOptional(_ propertyName: String!) -> Bool {
        return true
    }
   
}
