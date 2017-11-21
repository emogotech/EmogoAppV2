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
    
    // MARK:- UI Elements
    @IBOutlet weak var txtMobileNumber : UITextField!
    
    // MARK: - Variables
    var hudView: LoadingView!
    
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
        
        let placeholder = SharedData.sharedInstance.placeHolderText(text: iMsgPlaceHolderText_SignIn, colorName: UIColor.white)
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
    @IBAction func btnSignIn(_ sender : UIButton) {
        if !(Validator.isEmpty(text: txtMobileNumber.text!)) {
            txtMobileNumber.shakeTextField()
        }
        else if !(Validator.isMobileLength(text: txtMobileNumber.text!, lenght: iMsgCharacterMinLength_MobileNumber)) {
            let alert = UIAlertController(title: iMsgAlertTitle_Alert, message:kAlertPhoneNumberLengthMsg , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.txtMobileNumber.resignFirstResponder()
            self.userLogin()
        }
    }
    
    @IBAction func btnTapSignUp(_ sender : UIButton) {
        let obj : SignUpNameViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignUpName) as! SignUpNameViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    // MARK:- TextField Delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!SharedData.sharedInstance.isMessageWindowExpand) {
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyle), object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: String! = textField.text
        
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
        self.txtMobileNumber.resignFirstResponder()
    }
    
    //MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }
    
    // MARK: - API Methods
    func userLogin() {
        if Reachability.isNetworkAvailable() {
            hudView.startLoaderWithAnimation()
            APIServiceManager.sharedInstance.apiForUserLogin(phone: (txtMobileNumber.text?.trim())!) { (isSuccess, errorMsg) in
                self.hudView.stopLoaderWithAnimation()
                if isSuccess == true {
                    let obj : HomeViewController  = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Home) as! HomeViewController
                    self.addRippleTransition()
                    self.present(obj, animated: false, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: iMsgAlertTitle_Alert, message:errorMsg , preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else {
            let alert = UIAlertController(title: iMsgAlertTitle_Alert, message:kAlertNetworkErrorMsg , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}
