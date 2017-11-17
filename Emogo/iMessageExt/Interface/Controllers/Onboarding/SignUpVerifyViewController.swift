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
    @IBOutlet weak var txtVeryficationCode : UITextField!
    
    
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
        txtVeryficationCode.attributedPlaceholder = placeholder;
        
        txtVeryficationCode.layer.cornerRadius = iMsg_CornorRadius
        txtVeryficationCode.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Action Methods
    @IBAction func btnDone(_ sender : UIButton){
        if (self.txtVeryficationCode.text?.trim().isEmpty)! {
            let alert = UIAlertController(title: iMsgAlertTitle_Alert, message:iMsgError_CodeMsg , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if (txtVeryficationCode.text?.trim().count)! != 5 {
            let alert = UIAlertController(title: iMsgAlertTitle_Alert, message:kAlertVerificationLengthMsg , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            self.verifyOTP()
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
        self.txtVeryficationCode.resignFirstResponder()
    }
    
    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return true
    }
    
    // MARK: - API Methods
    func verifyOTP(){
        APIServiceManager.sharedInstance.apiForVerifyUserOTP(otp: self.OTP!,phone: self.phone!) { (isSuccess, errorMsg) in
            if isSuccess == true {
                let vc : HomeViewController = SharedData.sharedInstance.storyBoard.instantiateViewController(withIdentifier: iMsgSegue_Home) as! HomeViewController
                self.present(vc, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: iMsgAlertTitle_Alert, message:errorMsg , preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

