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
    case gif = "Giphy"
    case notes = "Note"

}


enum StuffType:String {
    case All = "All"
    case Picture = "Picture"
    case Video = "Video"
    case Links = "Link"
    case Notes = "Note"
    case Giphy = "Giphy"
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

class TopContent{
    var name:String! = ""
    var Contents = [ContentDAO]()
    var image:UIImage?
    var type:StuffType!
    init(name:String,contents:[ContentDAO]) {
        self.name = name
        self.Contents = contents
    }
}

class ContentList{
    var arrayContent:[ContentDAO]!
    var arrayStuff:[ContentDAO]!
    var arrayLink:[ContentDAO]!
    var arrayToCreate:[ContentDAO]!

    var objStream:String?
    var mainStreamIndex:Int?
    var mainStreamNavigate:String?
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
        arrayToCreate = [ContentDAO]()
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
    var fileName:String! = ""
    var fileUrl:URL?
    var isUploaded:Bool! = false
    var isAdd:Bool! = false
    var isSelected:Bool! = false
    var isEdit:Bool! = false
    var isDelete:Bool! = false
    var isShowAddStream:Bool! = false
    var likeStatus:Int! = 0
    var width:Int! = 300
    var height:Int! = 300
    var color:String! = ""
    var stuffType:StuffType! = .All
    var createrImage:String! = ""
    var fullname:String! = ""

    var imgPreview:UIImage? = nil {
        
        didSet {
            if self.imgPreview != nil {
                self.width = Int(imgPreview!.size.width)
                self.height = Int(imgPreview!.size.height)
//                let r = self.imgPreview?.getColors().background.ciColor.red
//                let g = self.imgPreview?.getColors().background.ciColor.green
//                let b = self.imgPreview?.getColors().background.ciColor.blue
//                let bgColor = "\(String(describing: r))," + "\(String(describing: g))," + "\(String(describing: b))"
//                self.color = bgColor
            }
        }
    }
    

    init(contentData:[String:Any]) {
        
        if let obj  = contentData["user_image"] {
            self.createrImage = obj as! String
        }
        if let obj  = contentData["name"] {
            self.name = obj as! String
        }
        if let obj  = contentData["type"] {
            let strType:String = obj as! String
            if strType.trim().lowercased() == "picture"{
                self.type = .image
            }else if strType.lowercased() == "video" {
                self.type = .video
            }else if strType.lowercased() == "link"{
                self.type = .link
            }else if strType.lowercased() == "note"{
                self.type = .notes
            }else {
                self.type = .gif
            }
        }
        print(contentData)
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
        if let obj  = contentData["liked"] {
            self.likeStatus = Int("\(obj)")
        }
        if let obj  = contentData["full_name"] {
            self.fullname = obj as! String
        }
        
        if let obj = contentData["width"] {
            self.width =  Int("\(obj)")
            if  self.width  == 0 {
                self.width = 300
            }
        }
        if let obj = contentData["height"] {
            self.height = Int("\(obj)")
            if  self.height  == 0 {
                self.height = 300
            }
        }
        
        if self.createdBy.trim() == UserDAO.sharedInstance.user.userProfileID.trim() {
            self.isEdit = true
            self.isDelete = true
            
        }
        
        if let obj = contentData["imageObj"] {
            let img = obj as! UIImage
            self.imgPreview =   img
        }
    }
}


class  ImportDAO {
    var strID:String! = ""
    var isSelected:Bool! = false
    var assest:PHAsset!
    var name:String! = ""

    init(id:String,isSelected:Bool) {
        self.strID = id
        self.isSelected = isSelected
    }
}


