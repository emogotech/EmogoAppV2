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
            AppDelegate.appDelegate.removeOberserver()
            AppDelegate.appDelegate.addOberserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.disMissKeyboard))
        view.addGestureRecognizer(tap)
        self.txtUserName.delegate = self
        self.txtUserName.maxLength = 30
    }
    
    
    // MARK: -  Action Methods And Selector
    @IBAction func btnActionNext(_ sender: Any) {
            disMissKeyboard()
        if (self.txtUserName.text?.trim().isEmpty)! {
            self.txtUserName.shake()
        }else if (txtUserName.text?.trim().count)! < 3 || (txtUserName.text?.trim().count)! > 30 {
            self.showToast(type: .error, strMSG: kAlert_Invalid_User_Name_Msg)
        }else if (txtUserName.text?.trim().contains(kString_singleSpace))!{
            self.showToast(type: .error, strMSG: kAlert_Invalid_User_Space_Msg)
        }else {
            self.verifyUserName()
        }
    }
    
    @IBAction func btnActionSignin(_ sender: Any) {
        let obj:SignInViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_SigninView) as! SignInViewController
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
                    let obj:SignUpViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_SignUpView) as! SignUpViewController
                    obj.userName = self.txtUserName.text?.trim()
                    self.navigationController?.push(viewController: obj)
                }else {
                    self.showToast(type: .error, strMSG: errorMsg!)
                }
            }
        }else {
            self.showToast(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
       
    }
    
}

// MARK: -  EXTENSIONS

// MARK: -  Delegate and Datasource
extension UserNameViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

