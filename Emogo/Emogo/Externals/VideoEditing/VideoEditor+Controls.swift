//
//  VideoEditor+Controls.swift
//  Emogo
//
//  Created by Pushpendra on 15/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation

extension VideoEditorViewController {
    
    
    @objc func actionForRightMenu(sender:UIButton) {
        switch sender.tag {
        case 101:
            self.loadAssest()
            break
        default:
            break
        }
    }
    
    
    @objc func btnSaveAction(){
      
    }
    
    @objc func buttonBackAction(){
       
        self.navigationController?.popViewAsDismiss()
    }
    
    
}
