//
//  SignInViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 31/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var txtPhoneNumber                 : UITextField!

    
    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.disMissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
    }
    
    
    // MARK: -  Action Methods And Selector
    
    @IBAction func btnDoneAction(_ sender: Any) {
        if (self.txtPhoneNumber.text?.trim().isEmpty)! {
            self.txtPhoneNumber.shake()
        }else if (txtPhoneNumber.text?.trim().count)! < 10 {
            self.showToast(type: "2", strMSG: kAlertPhoneNumberLengthMsg)
        }else {
            self.showToast(type: "1", strMSG: kAlertLoginSuccessMsg)
        }
    }
    
    @IBAction func btnSignupAction(_ sender: Any) {
        let obj:UserNameViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_UserNameView) as! UserNameViewController
        self.navigationController?.flipPush(viewController: obj)
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
