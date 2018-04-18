//
//  FollowerDAO.swift
//  Emogo
//
//  Created by Pushpendra on 18/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation

enum FollowerType:String {
    case Follower = "Followers"
    case Following = "Followings"
}

class FollowerDAO {
    var fullName:String! = ""
    var phone:String! = ""
    var userImage:String! = ""
    var userId:String! = ""
    var userProfileID:String! = ""
    var displayName:String! = ""
  
    init(dictFollow:[String:Any]) {
        if let data = dictFollow["phone_number"]{
            self.phone = data as! String
        }
        if let data = dictFollow["full_name"]{
            self.fullName = data as! String
        }
        if let data = dictFollow["user_image"]{
            self.userImage = data as! String
        }
        if let data = dictFollow["user_id"]{
            self.userId = "\(data)"
        }
        if let data = dictFollow["user_profile_id"]{
            self.userProfileID = "\(data)"
        }
        if let data = dictFollow["display_name"]{
            self.displayName = data as! String
        }
    }
}


class FollowList{
    
    var arrayFollowers:[FollowerDAO]!
    var requestURl:String! = ""
    class var sharedInstance: FollowList {
        struct Static {
            static let instance: FollowList = FollowList()
        }
        return Static.instance
    }
    init() {
        arrayFollowers = [FollowerDAO]()
    }
    
}

