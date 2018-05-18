//
//  CountryDAO.swift
//  Emogo
//
//  Created by Pushpendra on 18/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class CountryDAO {
    
    var name:String! = ""
    var code:String! = ""
    var phoneCode:String! = ""
    var isSelected:Bool! = false
    
    init(dictCountry:[String:Any]) {
        if let code = dictCountry["code"] {
            self.code = code as! String
        }
        if let code = dictCountry["dial_code"] {
            self.phoneCode = code as! String
        }
        if let code = dictCountry["name"] {
            self.name = code as! String
        }
    }
}
