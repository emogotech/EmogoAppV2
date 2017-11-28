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
    var imgUser:UIImage?
    var isSelected:Bool! = false
    var phone:String! = ""

    init(name:String, image:UIImage?,phone:String) {
        self.name = name
        self.imgUser = image
        self.phone = phone
    }
    
}
