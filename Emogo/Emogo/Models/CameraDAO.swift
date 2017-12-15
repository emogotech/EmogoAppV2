//
//  ImageDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
import Photos
class ImageDAO {
    
    var type:PreviewType!
    var imgPreview:UIImage!
    var title:String! = ""
    var description:String! = ""
    var fileName:String! = ""
    var fileUrl:URL?
    var isSelected:Bool! = false
    var isUploaded:Bool! = false

    init(type:PreviewType, image:UIImage) {
        self.type = type
        self.imgPreview = image
    }
}


class GalleryDAO{
    
    var Images:[ImageDAO]!
    var streamID:String! = ""
    class var sharedInstance: GalleryDAO {
        struct Static {
            static let instance: GalleryDAO = GalleryDAO()
        }
        return Static.instance
    }
    
    init() {
        Images = [ImageDAO]()
    }
       
    
}
