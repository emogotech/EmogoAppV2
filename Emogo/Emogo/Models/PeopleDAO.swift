//
//  PeopleDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class PeopleDAO {
    /*
     biography = "<null>";
     birthday = "<null>";
     "branchio_url" = "<null>";
     followers = 0;
     following = 0;
     "full_name" = test;
     location = "<null>";
     "phone_number" = "+918523691440";
     "profile_stream" =     {
     };
     "user_image" = "https://s3.amazonaws.com/emogo-v2/stream-media/AA5D28E7-A6CE-4FE8-B336-1737DC7B2E14.png";
     "user_profile_id" = 7;
     website = "<null>";
 */
 
    var fullName                   :String! = ""
    var phoneNumber                :String! = ""
    var userId                     :String! = ""
    var userImage                  :String! = ""
    var biography                  :String! = ""
    var birthday                  :String! = ""
    var location                  :String! = ""
    var website                       :String! = ""
    var stream                        :StreamDAO?
    var followers                     :String! = ""
    var following                     :String! = ""
    var displayName                     :String! = ""
    var isFollowing                     :Bool! = false
    var isFollower                     :Bool! = false
    var shareURL                       :String! = ""

    init(peopleData:[String:Any]) {
        
        if let obj = peopleData["is_follower"] {
            self.isFollower = "\(obj)".toBool()
        }
        
        if let obj = peopleData["is_following"] {
            self.isFollowing = "\(obj)".toBool()
        }
        
        if let obj = peopleData["display_name"] {
            self.displayName = obj as! String
        }
        
        if let obj = peopleData["location"] {
            self.location = obj as! String
        }
        
        if let obj = peopleData["followers"] {
            self.followers = "\(obj)"
        }
        if let obj = peopleData["following"] {
            self.following = "\(obj)"
        }
        
        if let obj = peopleData["website"] {
            self.website = obj as! String
        }
        if let obj = peopleData["birthday"] {
            self.birthday = obj as! String
        }
        
        if let obj = peopleData["biography"] {
            self.biography = obj as! String
        }
        
        if let obj = peopleData["user_profile_id"] {
            self.userId = "\(obj)"
        }
        if let obj = peopleData["full_name"] {
            self.fullName = obj as! String
        }
        if let obj = peopleData["phone_number"] {
            self.phoneNumber = "\(obj)"
        }
        if let obj = peopleData["user_image"] {
            self.userImage = obj as! String
        }
        if let obj = peopleData["branchio_url"] {
            self.shareURL = obj as! String
        }
        if let obj = peopleData["profile_stream"] {
            if obj is [String:Any] {
                self.stream = StreamDAO(streamData: (obj as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
            }
        }
    }
    
}


class PeopleList{
    
    var arrayPeople:[PeopleDAO]!
    var requestURl:String! = ""
    class var sharedInstance: PeopleList {
        struct Static {
            static let instance: PeopleList = PeopleList()
        }
        return Static.instance
    }
    init() {
        arrayPeople = [PeopleDAO]()
    }

}
