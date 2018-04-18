//
//  UserDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class UserDAO {
    
    var user:User!
    
    class var sharedInstance: UserDAO {
        struct Static {
            static let instance: UserDAO = UserDAO()
        }
        return Static.instance
    }
    
    func parseUserInfo(){
        if kDefault?.value(forKey: kUserLogggedInData) != nil {
            if kDefault?.value(forKey: kUserLogggedInData) is [String:Any] {
                let dict = kDefault?.value(forKey: kUserLogggedInData) as! [String : Any]
                self.user = User(userData: dict)
            }
        }
    }
   
}



class User {
    
    var fullName                   :String! = ""
    var OTP                        :String! = ""
    var phoneNumber                :String! = ""
    var token                      :String! = ""
    var user                       :String! = ""
    var userId                     :String! = ""
    var userImage                  :String! = ""
    var location                   :String! = ""
    var website                    :String! = ""
    var biography                  :String! = ""
    var username                  :String! = ""
    var birthday                  :String! = ""
    var shareURL                  :String! = ""
    var userProfileID             :String! = ""
    var followers                 :String! = ""
    var following                 :String! = ""
    var stream                    :StreamDAO?
    var displayName             :String! = ""


   
    init(userData:[String:Any]) {
        
        if let obj = userData["full_name"] {
            self.fullName = obj as! String
        }
        if let obj = userData["display_name"] {
            self.displayName = obj as! String
        }
        if let obj = userData["followers"] {
            if "\(obj)" != "0" {
                self.followers = "\(obj)\nfollowers"
            }
        }
        if let obj = userData["following"] {
            if "\(obj)" != "0" {
                self.following = "\(obj)\nfollowing"
            }
        }
        if let obj = userData["branchio_url"] {
            self.shareURL = obj as! String
        }
        if let obj = userData["username"] {
            self.username = obj as! String
        }
        if let obj = userData["location"] {
            self.location = obj as! String
        }
        if let obj = userData["website"] {
            self.website = obj as! String
        }
        if let obj = userData["biography"] {
            self.biography = obj as! String
        }
        if let obj = userData["otp"] {
            self.OTP = "\(obj)"
        }
        if let obj = userData["token"] {
            self.token = obj as! String
        }
        if let obj = userData["phone_number"] {
            self.phoneNumber = "\(obj)"
        }
        if let obj = userData["birthday"] {
            self.birthday = "\(obj)"
        }
        if let obj = userData["user"] {
            self.user = "\(obj)"
        }
        if let obj = userData["user_id"] {
            self.userId = "\(obj)"
        }
        if let obj = userData["user_profile_id"] {
            self.userProfileID = "\(obj)"
        }
        if let obj = userData["user_image"] {
            self.userImage = obj as! String
        }
        if let obj = userData["profile_stream"] {
            if obj is [String:Any] {
                self.stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
            }
        }
    }

}




