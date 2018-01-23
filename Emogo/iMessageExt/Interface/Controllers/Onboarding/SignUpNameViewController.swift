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
    @IBOutlet weak var txtNameCollapse  : UITextField!
    @IBOutlet weak var imgBackground : UIImageView!
    
    @IBOutlet weak var viewExpand  : UIView!
    @IBOutlet weak var viewCollapse  : UIView!
    
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
        
        let placeholder = SharedData.sharedInstance.placeHolderText(text: kPlaceHolderText_Sign_Up_Name, colorName: UIColor.white)
        txtName.attributedPlaceholder = placeholder
        
        txtNameCollapse.attributedPlaceholder = placeholder
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)
        
        if SharedData.sharedInstance.isMessageWindowExpand {
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = false
            viewCollapse.isHidden = true
            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        }else{
            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = true
            viewCollapse.isHidden = false
        }
    }
    
    
    @objc func requestMessageScreenChangeSize(){
        if SharedData.sharedInstance.isMessageWindowExpand {
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = false
            viewCollapse.isHidden = true
            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
            self.txtName.text = self.txtNameCollapse.text
            self.txtName.becomeFirstResponder()
        }else{
            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = true
            viewCollapse.isHidden = false
            self.txtNameCollapse.text = self.txtName.text
            self.txtNameCollapse.resignFirstResponder()
        }
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
        } else if(!Validator.isNameLengthMin(text: txtName.text!, lenghtMin: kName_Min_Length)) {
            self.showToastIMsg(type: .error, strMSG: kAlert_Error_NameMsg)
        } else if(!Validator.isNameLengthMax(text: txtName.text!, lenghtMax: kName_Max_Length)){
            self.showToastIMsg(type: .error, strMSG: kAlert_Invalid_User_Name_Msg)
        } else if(!Validator.isNameContainSpace(text: txtName.text!)){
            self.showToastIMsg(type: .error, strMSG: kAlert_Invalid_User_Space_Msg)
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
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Expand), object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == kString_isBlank){
            return true
        }
        let textFieldText: String! = textField.text
        
        if(textFieldText.count >= kCharacterMaxLength_Name){
            return false
        }
        
        if(range.location == 0 && string == kString_singleSpace){
            return false
        }
        
        if( ( textFieldText == kString_singleSpace )){
            return false
        }
        if(textFieldText.count > 0){
            let charPrevious = textFieldText[textFieldText.count - 1]
            if( ( charPrevious == kString_singleSpace ) && ( string == kString_singleSpace )){
                return false
            }
        }
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
        
    // MARK: - API Methods
    func verifyUserName(){
        if Reachability.isNetworkAvailable() {
              hudView.startLoaderWithAnimation()
            APIServiceManager.sharedInstance.apiForUserNameVerify(userName: (txtName.text?.trim())!) { (isSuccess, errorMsg) in
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                if isSuccess == true {
                    let obj : SignUpMobileViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_SignUpMobile) as! SignUpMobileViewController
                    obj.userName = self.txtName.text?.trim()
                    self.addRippleTransition()
                    self.present(obj, animated: false, completion: nil)
                } else {
                    self.showToastIMsg(type: .error, strMSG: kAlert_User_Name_Alreay_Exists_Msg)
                }
            }
        }
        else {
             self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
}

