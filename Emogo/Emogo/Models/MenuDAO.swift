//
//  MenuDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit

class MenuDAO {
    var arrayMenu = [Menu]()
    
    init() {
        self.prepareData()
    }
    
    private func prepareData(){
        arrayMenu.removeAll()
        let menu2 = Menu(icon: #imageLiteral(resourceName: "MyStreamsDeselect"), name: "MY EMOGO")
        menu2.iconSelected = #imageLiteral(resourceName: "My Stream")
        arrayMenu.append(menu2)
        let menu1 = Menu(icon: #imageLiteral(resourceName: "PopularDeselect"), name: "POPULAR")
        menu1.iconSelected = #imageLiteral(resourceName: "PopularStream")
        arrayMenu.append(menu1)
        let menu3 = Menu(icon: #imageLiteral(resourceName: "featutreDeselect"), name: "FEATURED")
        menu3.iconSelected = #imageLiteral(resourceName: "Feature")
        arrayMenu.append(menu3) 
        let menu4 = Menu(icon:#imageLiteral(resourceName: "emogoDeselect"), name: "INSPIRATION")
        menu4.iconSelected = #imageLiteral(resourceName: "EmogoSelect")
        arrayMenu.append(menu4)
        //        let menu6 = Menu(icon: #imageLiteral(resourceName: "PeopleDeselect"), name: "People")
        //        menu6.iconSelected = #imageLiteral(resourceName: "Peoples")
        //        arrayMenu.append(menu6)
        
        let menuLiked   =   Menu(icon: #imageLiteral(resourceName: "liked-icon"), name: "LIKED")
        menuLiked.iconSelected  =   #imageLiteral(resourceName: "liked-selected-icon")
        arrayMenu.append(menuLiked)
        
        let menuFollwed   =   Menu(icon: #imageLiteral(resourceName: "following-icon"), name: "FOLLOWING")
        menuFollwed.iconSelected  =   #imageLiteral(resourceName: "following-selected-icon")
        arrayMenu.append(menuFollwed)
    }
}

class Menu {
    var icon:UIImage!
    var iconName:String! = ""
    var iconSelected:UIImage!
    
    init(icon:UIImage, name:String) {
        self.icon = icon
        self.iconName = name
    }
   
}

