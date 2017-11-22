//
//  SignInViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 31/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var txtPhoneNumber                 : SHSPhoneTextField!

    
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
        // Set Rule for Phone Format
        txtPhoneNumber.formatter.setDefaultOutputPattern(kPhoneFormat)
        txtPhoneNumber.formatter.prefix = SharedData.sharedInstance.countryCode!
        txtPhoneNumber.hasPredictiveInput = true;
        txtPhoneNumber.textDidChangeBlock = { (textField: UITextField!) -> Void in
            print("number is \(textField.text ?? "")")
        }
    }
    
    // MARK: -  Action Methods And Selector
    @IBAction func btnDoneAction(_ sender: Any) {
         self.disMissKeyboard()
        if (self.txtPhoneNumber.text?.trim().isEmpty)! {
            self.txtPhoneNumber.shake()
        }else if (txtPhoneNumber.text?.trim().count)! < 10 {
            self.showToast(type: .error, strMSG: kAlertPhoneNumberLengthMsg)
        }else {
            self.userLogin()
        }
    }
    
    @IBAction func btnSignupAction(_ sender: Any) {
        self.disMissKeyboard()
        let obj:UserNameViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_UserNameView) as! UserNameViewController
        self.navigationController?.push(viewController: obj)
    }
    
    // MARK: - Class Methods
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: - API Methods

    
    func userLogin(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForUserLogin(phone: (txtPhoneNumber.text?.trim())!) { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    let obj:StreamListViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_StreamListView) as! StreamListViewController
                    self.navigationController?.flipPush(viewController: obj)
                }else {
                    self.showToast(type: .error, strMSG: errorMsg!)
                }
            }
        }else {
            self.showToast(type: .error, strMSG: kAlertNetworkErrorMsg)
        }
        
    }
        

}




