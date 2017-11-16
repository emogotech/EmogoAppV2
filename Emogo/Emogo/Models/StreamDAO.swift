//
//  StreamDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
class StreamDAO {
    var title:String! = ""
    var imgCover:UIImage!
    
    init(title:String, image:UIImage) {
        self.title = title
        self.imgCover = image
    }

}
