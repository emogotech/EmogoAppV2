//
//  CollaboratorDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class CollaboratorDAO {
    var name:String! = ""
    var colabID:String! = ""
    var imgUser:String! = ""
    var isSelected:Bool! = false
    var phone:String! = ""
    var canAddContent:Bool! = false
    var canAddPeople:Bool! = false
    var userID:String! = ""
    var UserProfileID:String! = ""

    var addedByMe:Bool! = false
    var userImage:String! = ""
    var displayName:String! = ""

    init(colabData:[String:Any]) {
        if let obj = colabData["id"] {
            self.colabID = "\(obj)"
        }
        if let obj = colabData["phone_number"] {
            self.phone = "\(obj)"
        }
        if let obj = colabData["name"] {
            self.name = obj as! String
        }
        if let obj = colabData["full_name"] {
            self.name = obj as! String
        }
        if let obj = colabData["display_name"] {
            self.displayName = obj as! String
        }
        if let obj = colabData["image"] {
            self.imgUser = obj as! String
        }
        if let obj = colabData["can_add_content"] {
            self.canAddContent = obj as! Bool
        }
        if let obj = colabData["can_add_people"] {
            self.canAddPeople = obj as! Bool
        }
        if let obj = colabData["user_profile_id"] {
            self.UserProfileID = "\(obj)"
        }
        if let obj = colabData["user_id"] {
            self.userID = "\(obj)"
        }
        if let obj = colabData["added_by_me"] {
            self.addedByMe = obj as! Bool
        }
        if let obj = colabData["user_image"] {
            self.userImage = obj as! String
        }
    }
    
}
/*
"display_name" = Reena;
"full_name" = Tgdhd;
"user_image" = "https://s3.amazonaws.com/emogo-v2/stream-media/6E2F9478-F296-475A-956A-8391A91D13CC.png";
"user_profile_id" = 8;
 */
