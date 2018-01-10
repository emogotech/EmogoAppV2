//
//  GiphyDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class GiphyDAO {
    
    var name                   :String! = ""
    var caption                :String! = ""
    var width                  :Int! = 0
    var hieght                 :Int! = 0
    var url                    :String! = ""
    var isSelected             :Bool! = false
    
    init(previewData:[String:Any]) {
        
        if let obj = previewData["url"] {
            self.url = obj as! String
        }
        if let obj = previewData["width"] {
            self.width =  Int("\(obj)")
        }
        if let obj = previewData["height"] {
            self.hieght = Int("\(obj)")
        }
      
    }
}
