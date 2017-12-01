//
//  VerificationViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 31/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {
    
    // MARK: - UI Elements

    @IBOutlet weak var txtOtP                 : UITextField!

     var OTP:String!
     var phone:String!

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
    @IBAction func btnGoToLandingScreen(_ sender: Any) {
        if (self.txtOtP.text?.trim().isEmpty)! {
            self.txtOtP.shake()
        }else if (txtOtP.text?.trim().count)! != 5 {
            self.showToast(type: .error, strMSG: kAlertVerificationLengthMsg)
        }else {
            self.verifyOTP()
        }
    }
    
    
    @IBAction func btnResendOTPAction(_ sender: Any) {
        self.resendOTP()
    }

    // MARK: - Class Methods
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: - API Methods

    func verifyOTP(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForVerifyUserOTP(otp: self.txtOtP.text!,phone: self.phone) { (isSuccess, errorMsg) in
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
    
    func resendOTP(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForResendOTP(phone: self.phone) { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    self.txtOtP.text = errorMsg
                }
            }
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
