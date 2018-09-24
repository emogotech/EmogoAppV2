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

   // @IBOutlet weak var txtOtP                 : SHSPhoneTextField!

    @IBOutlet weak var otpView: VPMOTPView!
    
    var OTP:String!
    var phone:String!
    var isForLogin:String!
    var txtOtP: String = ""

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
         UITextField.appearance().keyboardAppearance = .dark
        self.setOTPView()
       // addToolBar(textField: txtOtP)
       // txtOtP.formatter.setDefaultOutputPattern("#####")
    }
    
    func setOTPView() {
       
        otpView.otpFieldsCount = 5
        otpView.otpFieldDefaultBorderColor = UIColor.gray
        otpView.otpFieldDisplayType = .square
        otpView.otpFieldSize = 40
        otpView.otpFieldBorderWidth = 1
        otpView.cursorColor = UIColor.gray
        otpView.delegate = self
        otpView.shouldAllowIntermediateEditing = false
    
        
        // Create the UI
        otpView.initializeUI()
    }
    
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.isTranslucent = true
        //        toolBar.tintColor =  UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePressed))
        doneButton.tintColor = .white
        
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton1,doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.inputAccessoryView = toolBar
        textField.keyboardAppearance = .dark
      
    }
    @objc func donePressed(){
        self.btnGoToLandingScreen(UIButton())
    }
    
    // MARK: -  Action Methods And Selector
    @IBAction func btnGoToLandingScreen(_ sender: Any) {
      print(self.txtOtP)
        if (self.txtOtP.trim().isEmpty) {
            self.showToast(type: .error, strMSG: kAlert_Verification_Length_Msg)
        }else if (txtOtP.trim().count) != 5 {
            self.showToast(type: .error, strMSG: kAlert_Verification_Length_Msg)
        }else {
            self.view.endEditing(true)
            if self.isForLogin == nil {
                self.verifyOTP()
            }else {
                verifyLogin()
            }
            self.txtOtP = ""
        }
    }
    
    
    @IBAction func btnResendOTPAction(_ sender: Any) {
        self.resendOTP()
    }
    
    @IBAction func btnbackAction(_ sender: Any) {
        self.navigationController?.pop()

    }

    // MARK: - Class Methods
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: - API Methods

    func verifyOTP(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForVerifyUserOTP(otp: self.txtOtP,phone: self.phone) { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    AppDelegate.appDelegate.removeOberserver()
                    let obj:StreamListViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView) as! StreamListViewController
                
                    self.navigationController?.flipPush(viewController: obj)
                }else {
                    self.showToast(type: .error, strMSG: errorMsg!)
                }
            }
        }else {
            self.showToast(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
       
    }
    
    func verifyLogin(){
        
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForVerifyLoginOTP(otp: self.txtOtP,phone: self.phone) { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    AppDelegate.appDelegate.removeOberserver()
                    let obj:StreamListViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView) as! StreamListViewController
                    self.navigationController?.flipPush(viewController: obj)
                }else {
                    self.showToast(type: .error, strMSG: errorMsg!)
                }
            }
        }else {
            self.showToast(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
    func resendOTP(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForResendOTP(phone: self.phone) { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    self.showToast(type: .error, strMSG: kAlert_OTP_Msg)
//                    self.txtOtP.text = errorMsg
                }
            }
        }else {
            self.showToast(type: .error, strMSG: kAlert_Network_ErrorMsg)
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

extension VerificationViewController: VPMOTPViewDelegate {
    
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        if !hasEntered {
            txtOtP = ""
        }
        return true
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otpString: String) {
        txtOtP = otpString
    }
    func currentEditing(otpString: String){
        print("OTPString: \(otpString)")
        txtOtP = otpString
    }
}
