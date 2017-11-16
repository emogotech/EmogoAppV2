//
//  WelcomeViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - UI Elements

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
    }
    
    // MARK: -  Action Methods And Selector
    
    @IBAction func btnActionGoWhereIWas(_ sender: Any) {
        //   self.showToast(type: "3", strMSG: kAlertResendCodeMsg)
    }
    @IBAction func btnActionBrowseStream(_ sender: Any) {
        //   self.showToast(type: "3", strMSG: kAlertResendCodeMsg)
    }
    @IBAction func btnActionEmogoStream(_ sender: Any) {
        //   self.showToast(type: "3", strMSG: kAlertResendCodeMsg)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
