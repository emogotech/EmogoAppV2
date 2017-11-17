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
    
    //MARK:- UI Elements
    @IBOutlet weak var txtMobileNumber : UITextField!
    
    //MARK:- Variables
    var userName :  String?
    
    //MARK:- Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Action Methods
    @IBAction func btnTextMeCode(_ sender : UIButton){
        
        if (self.txtMobileNumber.text?.trim().isEmpty)! {
            let alert = UIAlertController(title: iMsgAlertTitle_Alert, message:iMsgError_Mobile , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else if (txtMobileNumber.text?.trim().count)! < 12 {
            
            let alert = UIAlertController(title: iMsgAlertTitle_Alert, message:kAlertPhoneNumberLengthMsg , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.sigupUser()
        }
    }
    
    //MARK:- PrepareLayout
    func prepareLayout()  {
        
        let placeholder = SharedData.sharedInstance.placeHolderText(text: iMsgPlaceHolderText_SignUpMobile, colorName: UIColor.white)
        txtMobileNumber.attributedPlaceholder = placeholder;
        
        txtMobileNumber.layer.cornerRadius = iMsg_CornorRadius
        txtMobileNumber.clipsToBounds = true
        
        txtMobileNumber.text = "\(SharedData.sharedInstance.countryCode!)"
    }
    
    //MARK:- TextField Delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyle), object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldText: String! = textField.text
        
        if(textFieldText.count == SharedData.sharedInstance.countryCode.count && string == iMsg_String_isBlank){
            return false
        }
        
        if(string == iMsg_String_isBlank) {
            return true
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
        self.txtMobileNumber.resignFirstResponder()
    }
    
    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return true
    }
    
    // MARK: - API Methods
    private func sigupUser(){
       // HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForUserSignup(userName: self.userName!, phone: (txtMobileNumber.text?.trim())!, completionHandler: { (isSuccess, errorMsg) in
          //  HUDManager.sharedInstance.hideHUD()
            
            if isSuccess == true {
                let obj : SignUpVerifyViewController  = SharedData.sharedInstance.storyBoard.instantiateViewController(withIdentifier: iMsgSegue_SignUpVerify) as! SignUpVerifyViewController
                obj.OTP = errorMsg
                obj.phone = self.txtMobileNumber.text?.trim()
                self.present(obj, animated: true, completion: nil)

            }
        })
    }
}

