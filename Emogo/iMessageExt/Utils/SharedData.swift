//
//  SharedData.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/14/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit

class SharedData: NSObject {
    
    //MARK:- Variables
    var isMessageWindowExpand : Bool = false
    
    var storyBoard = UIStoryboard(name: iMsgStoryBoard , bundle: nil)
    
    //MARK:- Create Instance Variable for SingleTon Classes
    class var sharedInstance: SharedData {
        struct Static {
            static let instance: SharedData = SharedData()
        }
        return Static.instance
    }

    func placeHolderText(text : String, colorName : UIColor) -> NSAttributedString {
        
        return NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
    }
}

