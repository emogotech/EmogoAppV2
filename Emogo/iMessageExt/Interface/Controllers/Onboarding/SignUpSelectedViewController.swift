//
//  SignUpSelectedViewController.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/16/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit
import Messages

class SignUpSelectedViewController: MSMessagesAppViewController {
    
    // MARK:- Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- Action Methods
    @IBAction func btnGoBackWherIWas(_ sender : UIButton){
    }
    
    @IBAction func btnBrowseStreams(_ sender : UIButton){
    }
    
    @IBAction func btnCheckEmogoStream(_ sender : UIButton){
    }

    //MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }
}

