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
    
    // MARK:- UI Elements
    @IBOutlet weak var txtName  : UITextField!
    
    // MARK s: - Variables
    var hudView                 : LoadingView!
    
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
        
        let placeholder = SharedData.sharedInstance.placeHolderText(text: iMsgPlaceHolderText_SignUpName, colorName: UIColor.white)
        txtName.attributedPlaceholder = placeholder;
        
        txtName.layer.cornerRadius = iMsg_CornorRadius
        txtName.clipsToBounds = true
    }
    
    // MARK:- LoaderSetup
    func setupLoader() {
        
        hudView  = LoadingView.init(frame: self.view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK:- Action Methods
    @IBAction func btnNext(_ sender : UIButton){
        if !(Validator.isEmpty(text: txtName.text!)) {
            txtName.shakeTextField()
        } else if(!Validator.isNameLengthMin(text: txtName.text!, lenghtMin: iMsgNameMinLength)) {
            self.showToastIMsg(type: .error, strMSG: iMsgError_NameMsg)
        } else if(!Validator.isNameLengthMax(text: txtName.text!, lenghtMax: iMsgNameMaxLength)){
            self.showToastIMsg(type: .error, strMSG: iMsgError_NameMax)
        } else if(!Validator.isNameContainSpace(text: txtName.text!)){
            self.showToastIMsg(type: .error, strMSG: iMsgError_NameSpace)
        } else {
            self.view.endEditing(true);
            self.verifyUserName()
        }
    }
    
    @IBAction func btnTapSignIn(_ sender : UIButton) {
        self.view.endEditing(true);

        let obj : SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignIn) as! SignInViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.txtName.resignFirstResponder()
    }
    
    // MARK:- TextField Delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyleExpand), object: nil)
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
        
        if( ( textFieldText == iMsg_String_singleSpace )){
            return false
        }
        if(textFieldText.count > 0){
            let charPrevious = textFieldText[textFieldText.count - 1]
            if( ( charPrevious == iMsg_String_singleSpace ) && ( string == iMsg_String_singleSpace )){
                return false
            }
        }

//        let characterSet = CharacterSet.init(charactersIn: iMsgCharacterSet)
//        if string.rangeOfCharacter(from: characterSet) == nil{
//            return false
//        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == iMsgSegue_SignUpMobile {
        }
    }
    
    // MARK: - API Methods
    func verifyUserName(){
        if Reachability.isNetworkAvailable() {
              hudView.startLoaderWithAnimation()
            APIServiceManager.sharedInstance.apiForUserNameVerify(userName: (txtName.text?.trim())!) { (isSuccess, errorMsg) in
                self.hudView.stopLoaderWithAnimation()
                if isSuccess == true {
                    let obj : SignUpMobileViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_SignUpMobile) as! SignUpMobileViewController
                    obj.userName = self.txtName.text?.trim()
                    self.addRippleTransition()
                    self.present(obj, animated: false, completion: nil)
                } else {
                    self.showToastIMsg(type: .error, strMSG: kAlertUserNameAlreayExistsMsg)
                }
            }
        }
        else {
             self.showToastIMsg(type: .error, strMSG: kAlertNetworkErrorMsg)
        }
    }
}

