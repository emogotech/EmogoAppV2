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
    case profile = "5"
    case people = "6"
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
        case .profile:
            self.requestURl =  kStreamAPI + ""
            break
        case .people:
            self.requestURl =  "users?people"
            break
        }
    }
    
}
