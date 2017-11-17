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
    
    //MARK:- UI Elements
    @IBOutlet weak var txtVeryficationCodde : UITextField!
    
    
    //MARK:- Variables
    var OTP : String?
    var phone : String?
    
    //MARK:- Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayout()
    }
    
    //MARK:- PrepareLayout
    func prepareLayout()  {
        
        let placeholder = SharedData.sharedInstance.placeHolderText(text: iMsgPlaceHolderText_SignUpVerify, colorName: UIColor.white)
        txtVeryficationCodde.attributedPlaceholder = placeholder;
        
        txtVeryficationCodde.layer.cornerRadius = iMsg_CornorRadius
        txtVeryficationCodde.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Action Methods
    @IBAction func btnDone(_ sender : UIButton){
        if(Validator.isInValidPhoneNumber(text: txtVeryficationCodde.text!) && Validator.isValidDigitCode(string: txtVeryficationCodde.text!, numberOfCharacters: iMsgCharacterMaxLength_VerificationCode) ) {
           
        }
    }
    
    //MARK:- TextField Delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyle), object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(string == iMsg_String_isBlank){
            return true
        }
        let textFieldText: String! = textField.text
        
        if(textFieldText.count >= iMsgCharacterMaxLength_VerificationCode){
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.txtVeryficationCodde.resignFirstResponder()
    }
    
    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return true
    }
    
    // MARK: - API Methods
    func verifyOTP(){
        APIServiceManager.sharedInstance.apiForVerifyUserOTP(otp: self.OTP!,phone: self.phone!) { (isSuccess, errorMsg) in
            if isSuccess == true {
                let vc = SharedData.sharedInstance.storyBoard.instantiateViewController(withIdentifier: iMsgSegue_SignUpSelected)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
}

