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
        if let obj = colabData["image"] {
            self.imgUser = obj as! String
        }
        if let obj = colabData["can_add_content"] {
            self.canAddContent = obj as! Bool
        }
        if let obj = colabData["can_add_people"] {
            self.canAddPeople = obj as! Bool
        }
       
       
    }
    
}
