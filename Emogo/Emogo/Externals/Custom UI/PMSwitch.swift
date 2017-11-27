//
//  PMSwitch.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

@IBDesignable class PMSwitch : UISwitch {
    
    @IBInspectable var OnColor : UIColor! = UIColor.blue
    @IBInspectable var OffColor : UIColor! = kaddStreamSwitchOffColor
     var scaleValue: CGFloat! = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpCustomUserInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpCustomUserInterface()
    }
    
    
    func setUpCustomUserInterface() {
        
        //clip the background color
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        //Scale down to make it smaller in look
        self.transform = CGAffineTransform(scaleX: self.scaleValue, y: self.scaleValue);
        
        //add target to get user interation to update user-interface accordingly
        self.addTarget(self, action: #selector(PMSwitch.updateUI), for: UIControlEvents.valueChanged)
        
        //set onTintColor : is necessary to make it colored
        self.onTintColor = self.OnColor
        
        //setup to initial state
        self.updateUI()
    }
    
    //to track programatic update
    override func setOn(_ on: Bool, animated: Bool) {
        super.setOn(on, animated: true)
        updateUI()
    }
    
    //Update user-interface according to on/off state
    @objc func updateUI() {
        if self.isOn == true {
            self.backgroundColor = self.OnColor
        }
        else {
            self.backgroundColor = self.OffColor
        }
    }
}
