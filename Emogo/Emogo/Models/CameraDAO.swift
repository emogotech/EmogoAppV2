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



enum PreviewType:String{
    case image = "Picture"
    case video = "Video"
    case link = "Link"
}


/*
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

*/

class ContentList{
    var arrayContent:[ContentDAO]!
    var arrayStuff:[ContentDAO]!
    var arrayLink:[ContentDAO]!
    var objStream:StreamViewDAO?
    var requestURl:String! = ""
    class var sharedInstance: ContentList {
        struct Static {
            static let instance: ContentList = ContentList()
        }
        return Static.instance
    }
    
    init() {
        arrayContent = [ContentDAO]()
        arrayLink = [ContentDAO]()
        arrayStuff = [ContentDAO]()
    }
    
}

class ContentDAO{
    
    var contentID:String! = ""
    var name:String! = ""
    var coverImage:String! = ""
    var coverImageVideo:String! = ""
    var description:String! = ""
    var createdBy:String! = ""
    var type:PreviewType!
    var imgPreview:UIImage?
    var fileName:String! = ""
    var fileUrl:URL?
    var isUploaded:Bool! = false
    var isAdd:Bool! = false
    var isSelected:Bool! = false
    
    init(contentData:[String:Any]) {
        if let obj  = contentData["name"] {
            self.name = obj as! String
        }
        if let obj  = contentData["type"] {
            let strType:String = obj as! String
            if strType.trim().lowercased() == "picture"{
                self.type = .image
            }else if strType.lowercased() == "video" {
                self.type = .video
            }else {
                self.type = .link
            }
        }
        
        if let obj  = contentData["url"] {
            self.coverImage = obj as! String
        }
        if let obj  = contentData["id"] {
            self.contentID = "\(obj)"
        }
        if let obj  = contentData["description"] {
            self.description = obj as! String
        }
        if let obj  = contentData["created_by"] {
            self.createdBy = "\(obj)"
        }
        if let obj  = contentData["video_image"] {
            self.coverImageVideo = obj as! String
        }
    }
}

