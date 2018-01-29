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
        
        self.addToolBar(textField: txtName)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                if SharedData.sharedInstance.keyboardHeightForSignin == 0.0 {
                    SharedData.sharedInstance.keyboardHeightForSignin =  keyboardSize.height
                }
                if SharedData.sharedInstance.isMessageWindowExpand {
                    UIView.animate(withDuration: 0.4, animations: {
                        self.view.frame.origin.y -= SharedData.sharedInstance.keyboardHeightForSignin/2
                    })
                }
            }
        }
    }
    
 
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0{
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin.y = 0
            })
        }
    }

    
    @objc func requestMessageScreenChangeSize(){
        if SharedData.sharedInstance.isMessageWindowExpand {
            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
            self.viewExpand.isHidden = false
            self.viewExpand.center = self.view.center
            viewCollapse.isHidden = true
            self.viewCollapse.center = self.view.center
            self.txtName.text = self.txtNameCollapse.text
            self.txtName.becomeFirstResponder()
        }else{
            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            UIView.animate(withDuration: 0.1, animations: {
                self.view.endEditing(true)
                self.txtNameCollapse.resignFirstResponder()
            }, completion: { (finshed) in
                self.viewExpand.isHidden = true
                self.viewCollapse.isHidden = false
                self.viewExpand.center = self.view.center
                self.viewCollapse.center = self.view.center
                self.txtNameCollapse.text = self.txtName.text
            })
        }
        if SharedData.sharedInstance.isPortrate {
            
        } else {
            DispatchQueue.main.async(execute: {
                //                self.supportedInterfaceOrientations = .po
                self.view.transform  = CGAffineTransform(rotationAngle: -180)
            })
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
       self.view.endEditing(true);
       self.checkValidation()
    }
    
    @IBAction func btnTapSignIn(_ sender : UIButton) {
        self.view.endEditing(true);

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        let obj : SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignIn) as! SignInViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.txtName.resignFirstResponder()
    }
    
    // MARK:- TextField Delegate method
    
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePressed))
        doneButton.tintColor = .white
        
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton1,doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func donePressed(){
        self.checkValidation()
    }
    
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
    
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
    
    func checkValidation(){
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
        
    // MARK: - API Methods
    func verifyUserName(){
        if Reachability.isNetworkAvailable() {
              hudView.startLoaderWithAnimation()
            APIServiceManager.sharedInstance.apiForUserNameVerify(userName: (txtName.text?.trim())!) { (isSuccess, errorMsg) in
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                if isSuccess == true {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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

