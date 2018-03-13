//
//  DeeplinkDAO.swift
//  Emogo
//
//  Created by pushpendra on 13/03/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
class DeeplinkDAO {
    var website:String! = ""
    var fullName:String! = ""
    var birthday:String! = ""
    var location:String! = ""
    var biography:String! = ""
    var phone:String! = ""
    var userImage:String! = ""
    var userId:String! = ""

    
    init(dictDeeplink:[String:Any]) {
        if let data = dictDeeplink["website"]{
            self.website = data as! String
        }
        if let data = dictDeeplink["user_full_name"]{
            self.fullName = data as! String
        }
        if let data = dictDeeplink["birthday"]{
            self.birthday = data as! String
        }
        if let data = dictDeeplink["location"]{
            self.location = data as! String
        }
        if let data = dictDeeplink["biography"]{
            self.biography = data as! String
        }
        if let data = dictDeeplink["phone"]{
            self.phone =  "\(data)"
        }
        if let data = dictDeeplink["user_image"]{
            self.userImage = data as! String
        }
        if let data = dictDeeplink["user_id"]{
            self.userId =  "\(data)"
        }
    }
}

