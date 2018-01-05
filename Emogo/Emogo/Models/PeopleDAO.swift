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
 
    var fullName                   :String! = ""
    var phoneNumber                :String! = ""
    var userId                     :String! = ""
    var userImage                  :String! = ""
    
    init(peopleData:[String:Any]) {
        
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
