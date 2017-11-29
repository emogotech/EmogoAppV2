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
        let menu1 = Menu(icon: #imageLiteral(resourceName: "PopularDeselected"), name: "Popular")
        menu1.iconSelected = #imageLiteral(resourceName: "Popular")
        arrayMenu.append(menu1)
        let menu2 = Menu(icon: #imageLiteral(resourceName: "MyStreamsDeselected"), name: "My Streams")
        menu2.iconSelected = #imageLiteral(resourceName: "My Streams")
        arrayMenu.append(menu2)
        let menu3 = Menu(icon: #imageLiteral(resourceName: "featutreDeselected"), name: "Featured")
        menu3.iconSelected = #imageLiteral(resourceName: "Featured")
        arrayMenu.append(menu3)
        let menuAdd = Menu(icon: #imageLiteral(resourceName: "add_icon"), name: "Add")
        menuAdd.iconSelected = #imageLiteral(resourceName: "add_icon_blue")
        arrayMenu.append(menuAdd)
        let menu4 = Menu(icon:#imageLiteral(resourceName: "emogoDeselected"), name: "Emogo Streams")
        menu4.iconSelected = #imageLiteral(resourceName: "Emogo Streams")
        arrayMenu.append(menu4)
        let menu5 = Menu(icon: #imageLiteral(resourceName: "ProfileDeselected"), name: "Profile")
        menu5.iconSelected = #imageLiteral(resourceName: "Profile")
        arrayMenu.append(menu5)
        let menu6 = Menu(icon: #imageLiteral(resourceName: "PeopleDeselect"), name: "Peoples")
        menu6.iconSelected = #imageLiteral(resourceName: "Peoples")
        arrayMenu.append(menu6)
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
