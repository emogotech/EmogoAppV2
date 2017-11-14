//
//  UserNameViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class UserNameViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var txtUserName                 : UITextField!

    
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
    
    @IBAction func btnActionNext(_ sender: Any) {
        if (self.txtUserName.text?.trim().isEmpty)! {
            self.txtUserName.shake()
        }
        else {
            let obj:SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_SignUpView) as! SignUpViewController
            self.navigationController?.push(viewController: obj)
        }
    }
    @IBAction func btnActionSignin(_ sender: Any) {
        let obj:SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_SigninView) as! SignInViewController
        self.navigationController?.push(viewController: obj)
    }
    
   
    
    // MARK: - Class Methods
    
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
    }

}




// MARK: -  EXTENSIONS
// MARK: -  Delegate and Datasource


extension UserNameViewController {
    
}

