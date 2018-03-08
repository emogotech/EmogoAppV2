//
//  ProfileDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class ProfileDAO {
    
    var fullName                   :String! = ""
    var phoneNumber                :String! = ""
    var userId                     :String! = ""
    var userImage                  :String! = ""
    
    var arrayStream = [StreamDAO]()
    var arrayColabs = [PeopleDAO]()
    var arrayContents = [ContentDAO]()
    
    init(profileData:[String:Any]) {
        
        if let obj = profileData["user_profile_id"] {
            self.userId = "\(obj)"
        }
        if let obj = profileData["full_name"] {
            self.fullName = obj as! String
        }
        if let obj = profileData["phone_number"] {
            self.phoneNumber = "\(obj)"
        }
        if let obj = profileData["user_image"] {
            self.userImage = obj as! String
        }
        // Streams
        /*
        if let obj = profileData["streams"] {
            if obj is [Any] {
                let streams:[Any] = obj as! [Any]
                for dict in streams {
                    let stream = StreamDAO(streamData: (dict as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                    arrayStream.append(stream)
                }
            }
        }
        
        if let obj = profileData["contents"] {
            if obj is [Any] {
                let contents:[Any] = obj as! [Any]
                for dict in contents {
                    let content = ContentDAO(contentData: (dict as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                    arrayContents.append(content)
                }
            }
        }
        
        
        if let obj = profileData["contents"] {
            if obj is [Any] {
                let contents:[Any] = obj as! [Any]
                for dict in contents {
                    let content = ContentDAO(contentData: (dict as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                    arrayContents.append(content)
                }
            }
        }
    }
    */
}
}
