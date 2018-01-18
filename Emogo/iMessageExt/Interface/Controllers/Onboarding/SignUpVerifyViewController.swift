//
//  SignUpVerifyViewController.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/16/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit
import Messages

class SignUpVerifyViewController: MSMessagesAppViewController,UITextFieldDelegate {
    
    // MARK:- UI Elements
    @IBOutlet weak var txtVeryficationCode  : UITextField!
    
    // MARK:- Variables
    var OTP                                 : String?
    var phone                               : String?
    var hudView                             : LoadingView!
    
    // MARK:- Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareLayout()
        self.setupLoader()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- PrepareLayout
    func prepareLayout()  {
        let placeholder = SharedData.sharedInstance.placeHolderText(text: kPlaceHolderText_Sign_Up_Verify, colorName: UIColor.white)
        txtVeryficationCode.attributedPlaceholder = placeholder;
        
//        txtVeryficationCode.layer.cornerRadius = kCornor_Radius
//        txtVeryficationCode.clipsToBounds = true
    }
    
    func setupLoader() {
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK:- Action Methods
    @IBAction func btnDone(_ sender : UIButton) {
        if !(Validator.isEmpty(text: txtVeryficationCode.text!)) {
            txtVeryficationCode.shakeTextField()
        }
        else if !(Validator.isMobileLength(text: txtVeryficationCode.text!, lenght: kCharacter_Max_Length_Verification_Code)) {
            self.showToastIMsg(type: .error, strMSG: kAlert_Verification_Length_Msg)
        }
        else {
            self.view.endEditing(true)
            self.verifyOTP()
        }
    }
    
    @IBAction func btnResend(_ sender : UIButton){
        self.view.endEditing(true)
        self.resendOTP()
    }
    
    //MARK:- TextField Delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Expand), object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: String! = textField.text
        if(string == kString_isBlank){
            return true
        }
        if(textFieldText.count >= kCharacter_Max_Length_Verification_Code){
            return false
        }
        if(string == kString_singleSpace){
            return false
        }
        let characterSet = CharacterSet.init(charactersIn: iMsgNumberSet)
        if string.rangeOfCharacter(from: characterSet) == nil{
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.txtVeryficationCode.resignFirstResponder()
    }
    
    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }
    
    // MARK: - API Methods
    func verifyOTP(){
        if Reachability.isNetworkAvailable() {
            self.hudView.startLoaderWithAnimation()
            APIServiceManager.sharedInstance.apiForVerifyUserOTP(otp: txtVeryficationCode.text!,phone: self.phone!) { (isSuccess, errorMsg) in
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                if isSuccess == true {
                    let obj : HomeViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Home) as! HomeViewController
                    self.addTransitionAtPresentingControllerRight()
                    self.present(obj, animated: false, completion: nil)
                }
                else {
                    self.showToastIMsg(type: .error, strMSG: errorMsg!)
                }
            }
        }
        else {
            self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
    
    func resendOTP(){
        if Reachability.isNetworkAvailable() {
            self.hudView.startLoaderWithAnimation()
            
            APIServiceManager.sharedInstance.apiForResendOTP(phone: self.phone!) { (isSuccess, errorMsg) in
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                if isSuccess == true {
                    self.txtVeryficationCode.text = errorMsg
                }
            }
        }else {
            self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
    
}

