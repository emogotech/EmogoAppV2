//
//  VerificationViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 31/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var txtOtP                 : UITextField!

    
    // MARK: - Override Functions

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
    
    @IBAction func btnGoToLandingScreen(_ sender: Any) {
        if (self.txtOtP.text?.trim().isEmpty)! {
            self.txtOtP.shake()
        }else if (txtOtP.text?.trim().count)! != 4 {
            self.showToast(type: "2", strMSG: kAlertVerificationLengthMsg)
        }else {
            self.showToast(type: "1", strMSG: kAlertLoginSuccessMsg)
        }
    }
    @IBAction func btnResendOTPAction(_ sender: Any) {
        self.showToast(type: "3", strMSG: kAlertResendCodeMsg)
    }

    
    // MARK: - Class Methods
    
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
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
