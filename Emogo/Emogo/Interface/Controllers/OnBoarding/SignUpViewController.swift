//
//  SignUpViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 31/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var txtPhoneNumber                 : SHSPhoneTextField!
    
     var userName:String!

    
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
    @IBAction func btnGetOTPAction(_ sender: Any) {
        self.disMissKeyboard()
        if (self.txtPhoneNumber.text?.trim().isEmpty)! {
            self.txtPhoneNumber.shake()
        }else if (txtPhoneNumber.text?.trim().count)! < 10 {
            self.showToast(type: .error, strMSG: kAlertPhoneNumberLengthMsg)
        }else {
            self.sigupUser()
        }
    }
    
    @IBAction func btnActionSignin(_ sender: Any) {
        let obj:SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_SigninView) as! SignInViewController
        self.navigationController?.push(viewController: obj)
    }
    @IBAction func btnActionBack(_ sender: Any) {
        self.navigationController?.pop()
    }
    // MARK: - Class Methods
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
    }

    // MARK: - API Methods

    private func sigupUser(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForUserSignup(userName: self.userName, phone: (txtPhoneNumber.text?.trim())!, completionHandler: { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    let obj:VerificationViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_VerificationView) as! VerificationViewController
                    obj.OTP = errorMsg
                    obj.phone = self.txtPhoneNumber.text?.trim()
                    self.navigationController?.push(viewController: obj)
                }else {
                    self.showToast(type: .error, strMSG: errorMsg!)
                }
            })
        }else {
            self.showToast(type: .error, strMSG: kAlertNetworkErrorMsg)
        }
       
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
