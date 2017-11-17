//
//  SignInViewController.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/16/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit
import Messages

class SignInViewController: MSMessagesAppViewController,UITextFieldDelegate {
    
    //MARK:- UI Elements
    @IBOutlet weak var txtMobileNumber : UITextField!
    @IBOutlet weak var btnCountryCode : UIButton!
    
    //MARK:- Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Action Methods
    @IBAction func btnSignIn(_ sender : UIButton){
        let vc = SharedData.sharedInstance.storyBoard.instantiateViewController(withIdentifier: iMsgSegue_SignUpMobile)
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK:- PrepareLayout
    func prepareLayout()  {
        
        let placeholder = NSAttributedString(string: iMsgPlaceHolderText_SignIn, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        txtMobileNumber.attributedPlaceholder = placeholder;
        
        txtMobileNumber.layer.cornerRadius = iMsg_CornorRadius
        txtMobileNumber.clipsToBounds = true
        
        btnCountryCode.layer.cornerRadius = iMsg_CornorRadius
        btnCountryCode.clipsToBounds = true
    }
    
    //MARK:- TextField Delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyle), object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(string == iMsg_String_isBlank) {
            return true
        }
        
        let textFieldText: String! = textField.text
        
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
        self.txtMobileNumber.resignFirstResponder()
    }
    
    //MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return true
    }
    
}


