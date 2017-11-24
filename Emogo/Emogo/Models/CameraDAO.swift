//
//  ImageDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class ImageDAO {
    
    var type:PreviewType!
    var imgPreview:UIImage!
    var title:String! = ""
    var description:String! = ""

    init(type:PreviewType, image:UIImage) {
        self.type = type
        self.imgPreview = image
    }
}


class Gallery{
    
    var Images:[ImageDAO]!
    
    class var sharedInstance: Gallery {
        struct Static {
            static let instance: Gallery = Gallery()
        }
        return Static.instance
    }
    
    init() {
        Images = [ImageDAO]()
    }
       
    
}
