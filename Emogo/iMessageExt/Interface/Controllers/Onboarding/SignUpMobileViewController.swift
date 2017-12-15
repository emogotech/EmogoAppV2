//
//  SignUpMobileViewController.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/16/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit
import Messages

class SignUpMobileViewController: MSMessagesAppViewController,UITextFieldDelegate {
    
    // MARK:- UI Elements
    @IBOutlet weak var txtMobileNumber  : UITextField!
    
    // MARK:- Variables
    var userName                        :  String?
    var hudView                         : LoadingView!
    
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
        let placeholder = SharedData.sharedInstance.placeHolderText(text: iMsgPlaceHolderText_SignUpMobile, colorName: UIColor.white)
        txtMobileNumber.attributedPlaceholder = placeholder;
        
        txtMobileNumber.layer.cornerRadius = iMsg_CornorRadius
        txtMobileNumber.clipsToBounds = true
        
        txtMobileNumber.text = "\(SharedData.sharedInstance.countryCode!)"
    }
    
    // MARK:- LoaderSetup
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
    @IBAction func btnTextMeCode(_ sender : UIButton){
        if !(Validator.isEmpty(text: txtMobileNumber.text!)) {
            txtMobileNumber.shakeTextField()
        }
        else if !(Validator.isMobileLength(text: txtMobileNumber.text!, lenght: iMsgCharacterMinLength_MobileNumber)) {
            self.showToastIMsg(type: .error, strMSG: kAlertPhoneNumberLengthMsg)
        }
        else {
            self.view.endEditing(true);
            self.sigupUser()
        }
    }
    
    @IBAction func btnTapSignIn(_ sender : UIButton) {
        self.view.endEditing(true);
        
        let obj : SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignIn) as! SignInViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    // MARK:- TextField Delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyleExpand), object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: String! = textField.text
        if range.location < 3 {
            return false
        }
        if(textFieldText.count == SharedData.sharedInstance.countryCode.count && string == iMsg_String_isBlank) {
            return false
        }
        if(string == iMsg_String_isBlank) {
            return true
        }
        if(textFieldText.count >= iMsgCharacterMaxLength_MobileNumber){
            return false
        }
        if(string == iMsg_String_singleSpace){
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
        self.txtMobileNumber.resignFirstResponder()
    }
    
    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }
    
    // MARK: - API Methods
    private func sigupUser(){
        if Reachability.isNetworkAvailable() {
            hudView.startLoaderWithAnimation()
            APIServiceManager.sharedInstance.apiForUserSignup(userName: self.userName!, phone: (txtMobileNumber.text?.trim())!, completionHandler: { (isSuccess, errorMsg) in
                self.hudView.stopLoaderWithAnimation()
                if isSuccess == true {
                    let obj : SignUpVerifyViewController  = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_SignUpVerify) as! SignUpVerifyViewController
                    obj.OTP = errorMsg
                    obj.phone = self.txtMobileNumber.text?.trim()
                    //                self.addTransitionAtPresentingControllerRight()
                    self.present(obj, animated: false, completion: nil)
                }
                else {
                    self.showToastIMsg(type: .error, strMSG: errorMsg!)
                }
            })
            
        }
        else {
             self.showToastIMsg(type: .error, strMSG: kAlertNetworkErrorMsg)
        }
    }
}

