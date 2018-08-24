//
//  StreamDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

enum StreamType:String {
    case populer = "Popular"
    case myStream = "My Stream"
    case featured = "Featured Stream"
    case emogoStreams = "Emogo Stream"
    case People = "People"
    case Liked  =   "Liked"
    case Following  =   "Following"
    case Emogo = "Emogo"
    case Collab = "Collab"
    case profile = "profile"
    case Public = "Public"
    case Private = "Private"

}

enum DeviceType:String {
    case iPhone = "1"
    case iMessage = "2"
}



class StreamDAO {
    var ID:String! = ""
    var Author:String! = ""
    var Title:String! = ""
    var CoverImage:String! = ""
    var IDcreatedBy:String! = ""
    var isSelected:Bool! = false
    var isAdd:Bool! = false
    var streamType:String! = ""
    var width                  :Int! = 300
    var hieght                 :Int! = 300
    var selectionType:StreamType!
    var count:Int! = 0
    var haveSomeUpdate:Bool! = false
    var isColabStream:Bool! = false
    var canAddContent:Bool! = false
    var color:String! = ""

    
   
    // People

    var fullName                   :String! = ""
    var phoneNumber                :String! = ""
    var userId                     :String! = ""
    var userImage                  :String! = ""
    var userProfileId                     :String! = ""
    var displayName                     :String! = ""

    
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
        if let obj  = streamData["type"] {
            self.streamType = obj as! String
        }
        if let obj = streamData["width"] {
            self.width =  Int("\(obj)")
        }
        if let obj = streamData["height"] {
            self.hieght = Int("\(obj)")
        }
        if let obj  = streamData["color"] {
            self.color = obj as! String
        }
        
        if let obj  = streamData["have_some_update"] {
            let value  = "\(obj)"
            self.haveSomeUpdate = value.toBool()
        }
        if let obj  = streamData["is_collaborator"] {
            let value  = "\(obj)"
            self.isColabStream = value.toBool()
        }
        
        if let obj  = streamData["stream_permission"] {
            if obj is [String:Any] {
                if let value = (obj as! [String:Any]) ["can_add_content"] {
                    let canadd  = "\(value)"
                    self.canAddContent = canadd.toBool()
                }
            }
        }
        
    }
    
    
    init(peopleData:[String:Any]) {
    

        if let obj = peopleData["user_id"] {
            self.userId = "\(obj)"
        }
        if let obj = peopleData["user_profile_id"] {
            self.userProfileId = "\(obj)"
        }
        if let obj = peopleData["display_name"] {
            self.displayName = obj as! String
        }
        if let obj = peopleData["full_name"] {
            self.fullName = obj as! String
        }
        if let obj = peopleData["phone_number"] {
            self.phoneNumber = "\(obj)"
        }
        if let obj = peopleData["user_image"] {
            self.userImage = obj as! String
        }
        self.selectionType = .People
    

    }
}

class StreamList{
    
    var arrayStream:[StreamDAO]!
    var arrayMyStream:[StreamDAO]!
    var arrayProfileStream:[StreamDAO]!
    var arrayViewStream:[StreamDAO]!
    var requestURl:String! = ""
    var selectedStream:StreamDAO!
    var requestURlSearch:String! = ""
    var arrayProfileColabStream:[StreamDAO]!
    var objStream:String?

    class var sharedInstance: StreamList {
        struct Static {
            static let instance: StreamList = StreamList()
        }
        return Static.instance
    }
    
    init() {
        arrayStream = [StreamDAO]()
        arrayMyStream = [StreamDAO]()
        arrayProfileStream = [StreamDAO]()
        arrayViewStream = [StreamDAO]()
        arrayProfileColabStream = [StreamDAO]()
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
        case .People:
            PeopleList.sharedInstance.requestURl = kPeopleAPI
            break
        case .Public:
            self.requestURl = "user_streams?public_stream=" + UserDAO.sharedInstance.user.userProfileID
            break
        case .Private:
            self.requestURl = "user_streams?private_stream=" + UserDAO.sharedInstance.user.userProfileID
            break
        case .Liked:
            self.requestURl = "user_liked_streams/"
            break
        case .Following:
            self.requestURl = "user_streams?following_stream=True"
            break
        case .Emogo:
            self.requestURl =  kStreamAPI + "self_created=True"
            break
        case .Collab:
            self.requestURl =  kMyStreamCollabListAPI + "collab=True"
            break
        case .profile:
            break
        }
    }
    
}

class StreamViewDAO{
    var anyOneCanEdit:Bool! = false
    var canAddContent:Bool! = false
    var canAddPeople:Bool! = false
    var category:String! = ""
    var description:String! = ""
    var streamID:String! = ""
    var author:String! = ""
    var title:String! = ""
    var coverImage:String! = ""
    var idCreatedBy:String! = ""
    var emogo:Bool! = false
    var featured:Bool! = false
    var streamPermission:String! = ""
    var type:String! = ""
    var viewCount:String! = ""
    var totalLikeCount:String! = ""
    var totalLiked:String! = ""
    var likeStatus: String! = ""
    var arrayContent = [ContentDAO]()
    var arrayColab = [CollaboratorDAO]()
    var width                  :Int! = 0
    var hieght                 :Int! = 0
    var userCanAddPeople:Bool! = false
    var userCanAddContent:Bool! = false
    var totalCollaborator:String! = ""
    var userImage:String! = ""
    var colabImageFirst:String! = ""
    var colabImageSecond:String! = ""
    var arrayLikedUsers = [LikedUser]()
    var color:String! = ""
    
    init(streamData:[String:Any]) {
        
        if let obj  = streamData["created_by"] {
            self.idCreatedBy = "\(obj)"
        }
        if let obj  = streamData["total_likes"] {
            self.totalLikeCount = "\(obj)"
        }
        if let obj =  streamData["liked"] {
            self.likeStatus = "\(obj)"
        }
        if let obj  = streamData["view_count"] {
            self.viewCount = "\(obj)"
        }
        if let obj = streamData["total_liked"] {
            self.totalLiked = "\(obj)"
        }
        if let obj  = streamData["category"] {
            self.category = obj as! String
        }
        if let obj  = streamData["type"] {
            self.type = obj as! String
        }
        if let obj  = streamData["color"] {
            self.color = obj as! String
        }
        
        if let obj  = streamData["stream_permission"] {
            if obj is [String:Any] {
                let dict:[String:Any] = obj as! [String : Any]
                if let obj  = dict["can_add_content"] {
                    let value  = "\(obj)"
                    self.canAddContent = value.toBool()
                }
                if let obj  = dict["can_add_people"] {
                    let value  = "\(obj)"
                    self.canAddPeople = value.toBool()
                }
            }
        }
        
        if let obj  = streamData["collaborator_permission"] {
            if obj is [String:Any] {
                let dict:[String:Any] = obj as! [String : Any]
                if let obj  = dict["can_add_content"] {
                    let value  = "\(obj)"
                    self.userCanAddContent = value.toBool()
                }
                if let obj  = dict["can_add_people"] {
                    let value  = "\(obj)"
                    self.userCanAddPeople = value.toBool()
                }
            }
        }
        
        
        if let obj  = streamData["any_one_can_edit"] {
            let value  = "\(obj)"
            self.anyOneCanEdit = value.toBool()
//            if anyOneCanEdit == true {
//                self.canAddContent = true
//                self.canAddPeople = true
//            }
        }
        if let obj  = streamData["total_collaborator"] {
           self.totalCollaborator = "\(obj)"
        }
        
        if let obj  = streamData["emogo"] {
            let value  = "\(obj)"
            self.emogo = value.toBool()
        }
        if let obj  = streamData["featured"] {
            let value  = "\(obj)"
            self.featured = value.toBool()
        }
        if let obj  = streamData["collaborators"] {
            let objColab:[Any] = obj as! [Any]
            for value in objColab {
                let colab = CollaboratorDAO(colabData: value as! [String : Any])
                
                if colab.userID == UserDAO.sharedInstance.user.userProfileID.trim() {
                    colab.isSelected = true
                    self.userImage = colab.userImage
                }else {
                    colab.isSelected = colab.addedByMe
                }
                
                self.arrayColab.append(colab)
            }
            
            for colab in self.arrayColab {
                if colab.userID.trim() != self.idCreatedBy.trim() {
                    if colabImageFirst.trim().isEmpty {
                        if colab.userImage.isEmpty {
                            self.colabImageFirst =  colab.name
                        }else {
                            self.colabImageFirst =  colab.userImage
                        }
                    } else if colabImageSecond.trim().isEmpty {
                        if colab.userImage.isEmpty{
                            self.colabImageSecond = colab.name
                        }else{
                            self.colabImageSecond = colab.userImage
                        }
                    }
                    
                    if !self.colabImageFirst.trim().isEmpty &&  !self.colabImageSecond.trim().isEmpty {
                        break
                    }
                }
            }
         }
        

       
        if let obj  = streamData["contents"] {
            let objContent:[Any] = obj as! [Any]
            for value in objContent {
                let dict:NSDictionary = value as! NSDictionary
                let conent = ContentDAO(contentData: dict.replacingNullsWithEmptyStrings() as! [String : Any])
                  conent.isUploaded = true
               
                if self.canAddContent == true {
                    conent.isShowAddStream = true
                }
                if self.idCreatedBy.trim() == UserDAO.sharedInstance.user.userProfileID.trim() {
                    conent.isDelete = true
                    self.canAddContent = true
                    self.canAddPeople = true
                }
                if conent.createdBy.trim() == UserDAO.sharedInstance.user.userProfileID.trim() {
                    conent.isEdit = true
                    conent.isDelete = true
                }
                if self.canAddContent == true  || self.canAddPeople == true || self.anyOneCanEdit == true || self.type.lowercased() == "public" {
                    conent.isShowAddStream = true
                }
                self.arrayContent.append(conent)
            }
//            if self.canAddContent == true {
//                let content = ContentDAO(contentData: [:])
//                content.isAdd = true
//                self.arrayContent.insert(content, at: 0)
//            }
        }
        
        if let obj = streamData["user_liked"] {
            if obj is [Any] {
                let array:[Any] = obj  as! [Any]
                for value in array {
                    let user = LikedUser(dictUser: (value as!  NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                    self.arrayLikedUsers.append(user)
                }
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
        if let obj = streamData["user_image"]{
            self.userImage = obj as! String
        }
        if let obj = streamData["width"] {
            self.width =  Int("\(obj)")
        }
        if let obj = streamData["height"] {
            self.hieght = Int("\(obj)")
        }
      
       
        if self.idCreatedBy.trim() == UserDAO.sharedInstance.user.userProfileID.trim() {
            self.canAddPeople = true
            self.canAddContent = true
        }
        
    }
}


class LikedUser{

    var userID:String! = ""
    var userProfileID:String! = ""
    var name:String! = ""
    var userImage:String! = ""
    var userDisplayName:String! = ""
    var isFollowing:Bool! = false

    init(dictUser:[String:Any]) {
        
        if let obj  = dictUser["id"] {
            self.userID = "\(obj)"
        }
        if let obj = dictUser["full_name"]{
            self.name = obj as! String
        }
        if let obj = dictUser["display_name"]{
            self.userDisplayName = obj as! String
        }
        if let obj = dictUser["user_image"]{
            self.userImage = obj as! String
        }
        if let data = dictUser["is_following"]{
            self.isFollowing = "\(data)".toBool()
        }
        if let obj = dictUser["user_profile_id"] {
            self.userProfileID = "\(obj)"
        }
    }
}




