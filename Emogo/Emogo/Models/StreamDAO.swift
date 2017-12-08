//
//  StreamDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

enum StreamType:String{
    case populer = "1"
    case myStream = "2"
    case featured = "3"
    case emogoStreams = "4"
}


class StreamDAO {
    var ID:String! = ""
    var Author:String! = ""
    var Title:String! = ""
    var CoverImage:String! = ""
    var IDcreatedBy:String! = ""

    init(streamData:[String:Any]) {
        if let obj  = streamData["name"] {
            self.Title = obj as! String
        }
        if let obj  = streamData["author"] {
            self.Author = obj as! String
        }
        if let obj  = streamData["image"] {
            self.CoverImage = obj as! String
        }
        if let obj  = streamData["id"] {
            self.ID = "\(obj)"
        }
        if let obj  = streamData["created_by"] {
            self.IDcreatedBy = "\(obj)"
        }
    }
}

class StreamList{
    
    var arrayStream:[StreamDAO]!
    var requestURl:String! = ""
    class var sharedInstance: StreamList {
        struct Static {
            static let instance: StreamList = StreamList()
        }
        return Static.instance
    }
    init() {
        arrayStream = [StreamDAO]()
    }
    
    func updateRequestType(filter:StreamType){
        switch filter {
        case .populer:
           self.requestURl =  kStreamAPI + "popular=True"
            break
        case .myStream:
            self.requestURl =  kStreamAPI + "my_stream=True"
            break
        case .featured:
            self.requestURl =  kStreamAPI + "featured=True"
            break
        case .emogoStreams:
            self.requestURl =  kStreamAPI + "emogo=True"
            break
    
        }
    }
    
}
/*
 collaborators =     (
 {
 "can_add_content" = 1;
 "can_add_people" = 0;
 name = "Singham raj";
 "phone_number" = "+917921215626263";
 },
 {
 "can_add_content" = 1;
 "can_add_people" = 0;
 name = "Kant singh";
 "phone_number" = "+917921215626264";
 }
 );


 */


class StreamViewDAO{
    var anyOneCanEdit:String! = ""
    var category:String! = ""
    var description:String! = ""
    var streamID:String! = ""
    var author:String! = ""
    var title:String! = ""
    var coverImage:String! = ""
    var idCreatedBy:String! = ""
    var emogo:String! = ""
    var featured:String! = ""
    var streamPermission:String! = ""
    var type:String! = ""
    var viewCount:String! = ""
    var arrayContent = [ContentDAO]()
    var arrayColab = [CollaboratorDAO]()

    init(streamData:[String:Any]) {
        if let obj  = streamData["any_one_can_edit"] {
            self.anyOneCanEdit = "\(obj)"
        }
        if let obj  = streamData["view_count"] {
            self.viewCount = "\(obj)"
        }
        if let obj  = streamData["category"] {
            self.category = obj as! String
        }
        if let obj  = streamData["type"] {
            self.type = obj as! String
        }
        if let obj  = streamData["stream_permission"] {
            print(obj)
        }
        if let obj  = streamData["emogo"] {
            self.emogo = "\(obj)"
        }
        if let obj  = streamData["featured"] {
            self.featured = "\(obj)"
        }
        if let obj  = streamData["collaborators"] {
            let objColab:[Any] = obj as! [Any]
            print(objColab)
            for value in objColab {
                let colab = CollaboratorDAO(colabData: value as! [String : Any])
                self.arrayColab.append(colab)
            }
        }
        if let obj  = streamData["contents"] {
            let objContent:[Any] = obj as! [Any]
            for value in objContent {
                let dict:NSDictionary = value as! NSDictionary
                let conent = ContentDAO(contentData: dict.replacingNullsWithEmptyStrings() as! [String : Any])
                self.arrayContent.append(conent)
            }
        }
        if let obj  = streamData["description"] {
            self.description = obj as! String
        }
        if let obj  = streamData["name"] {
            self.title = obj as! String
        }
        if let obj  = streamData["author"] {
            self.author = obj as! String
        }
        if let obj  = streamData["image"] {
            self.coverImage = obj as! String
        }
        if let obj  = streamData["id"] {
            self.streamID = "\(obj)"
        }
        if let obj  = streamData["created_by"] {
            self.idCreatedBy = "\(obj)"
        }
    }
}

class ContentDAO{
   
    var contentID:String! = ""
    var name:String! = ""
    var coverImage:String! = ""
    var type:String! = ""
    init(contentData:[String:Any]) {
        if let obj  = contentData["name"] {
            self.name = obj as! String
        }
        if let obj  = contentData["type"] {
            self.type = obj as! String
        }
        if let obj  = contentData["url"] {
            self.coverImage = obj as! String
        }
        if let obj  = contentData["id"] {
            self.contentID = "\(obj)"
        }
       
    }
}




