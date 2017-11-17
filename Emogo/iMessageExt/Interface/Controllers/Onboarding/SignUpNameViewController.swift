//
//  SignUpNameViewController.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/16/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit
import Messages

class SignUpNameViewController: MSMessagesAppViewController,UITextFieldDelegate {
    
    //MARK:- UI Elements
    @IBOutlet weak var txtName : UITextField!
    
    //MARK:- Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- PrepareLayout
    func prepareLayout()  {
        
        let placeholder = SharedData.sharedInstance.placeHolderText(text: iMsgPlaceHolderText_SignUpName, colorName: UIColor.white)
        txtName.attributedPlaceholder = placeholder;
        
        txtName.layer.cornerRadius = iMsg_CornorRadius
        txtName.clipsToBounds = true
    }
    
    //MARK:- Action Methods
    @IBAction func btnNext(_ sender : UIButton){
        if(Validator.isNameIsValidForString(string: txtName.text!, numberOfCharacters: 3)){
            let vc = SharedData.sharedInstance.storyBoard.instantiateViewController(withIdentifier: iMsgSegue_SignUpMobile)
            self.present(vc, animated: true, completion: nil)
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
        
        if(textFieldText.count >= iMsgCharacterMaxLength_Name){
            return false
        }
        
        if(range.location == 0 && string == iMsg_String_singleSpace){
            return false
        }
        
        if(textFieldText.count > 0){
            let charPrevious = textFieldText[textFieldText.count - 1]
            if( ( charPrevious == iMsg_String_singleSpace ) && ( string == iMsg_String_singleSpace )){
                return false
            }
        }
        
        let characterSet = CharacterSet.init(charactersIn: iMsgCharacterSet)
        if string.rangeOfCharacter(from: characterSet) == nil{
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == iMsgSegue_SignUpMobile {
            //present your view controller or do some code
        }
    }
    
    func showToast(type:String,strMSG:String) {
        if type == iMsgAlertType_One {
            CRNotifications.showNotification(type: .success, title: iMsgAlertTitle_Success, message: strMSG, dismissDelay: iMsgDismissDelayTimeForPopUp)
        }else if type == iMsgAlertType_Two {
            CRNotifications.showNotification(type: .error, title: iMsgAlertTitle_Alert, message: strMSG, dismissDelay: iMsgDismissDelayTimeForPopUp)
        }else {
            CRNotifications.showNotification(type: .info, title: iMsgAlertTitle_Info, message: strMSG, dismissDelay: iMsgDismissDelayTimeForPopUp)
        }
    }
    
}

