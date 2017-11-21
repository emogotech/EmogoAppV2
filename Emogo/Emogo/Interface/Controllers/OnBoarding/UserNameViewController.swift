//
//  UserNameViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 15/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class UserNameViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var txtUserName                 : UITextField!
    
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.disMissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    // MARK: -  Action Methods And Selector
    @IBAction func btnActionNext(_ sender: Any) {
        if (self.txtUserName.text?.trim().isEmpty)! {
            self.txtUserName.shake()
        }else if (txtUserName.text?.trim().count)! < 3 && (txtUserName.text?.trim().count)! > 30 {
            self.showToast(type: .error, strMSG: kAlertInvalidUserNameMsg)
        }else {
            self.verifyUserName()
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
    
    func verifyUserName(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForUserNameVerify(userName: (txtUserName.text?.trim())!) { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    let obj:SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_SignUpView) as! SignUpViewController
                    obj.userName = self.txtUserName.text?.trim()
                    self.navigationController?.push(viewController: obj)
                }else {
                    self.showToast(type: .error, strMSG: errorMsg!)
                }
            }
        }else {
            self.showToast(type: .error, strMSG: kAlertNetworkErrorMsg)
        }
       
    }
    
}

// MARK: -  EXTENSIONS

// MARK: -  Delegate and Datasource

