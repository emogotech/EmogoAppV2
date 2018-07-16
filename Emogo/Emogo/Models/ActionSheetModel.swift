//
//  ActionSheetModel.swift
//  Emogo
//
//  Created by Pushpendra on 14/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
class  ActionSheetModel {
    var arrayActions = [Menu]()
    
    init() {
       self.prepareActionSheet()
    }
    
    func prepareActionSheet(){
  
        arrayActions.removeAll()
        var menu = Menu(icon: UIImage(named: "action_photo_video")!, name: "Photos/Videos")
        arrayActions.append(menu)
        
        menu = Menu(icon: UIImage(named: "action_camera_icon")!, name: "Camera")
        arrayActions.append(menu)
        
        menu = Menu(icon: UIImage(named: "action_link_icon")!, name: "Link")
        arrayActions.append(menu)
        
        menu = Menu(icon: UIImage(named: "note_icon")!, name: "Note")
        arrayActions.append(menu)
        
        menu = Menu(icon: UIImage(named: "action_giphy_icon")!, name: "Gif")
        arrayActions.append(menu)
        
        menu = Menu(icon: UIImage(named: "action_my_stuff")!, name: "My Stuff")
        arrayActions.append(menu)
        
    }
    

}

