//
//  SignInViewController.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/16/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit
import Messages

class SignInViewController: MSMessagesAppViewController {
    
    // MARK:- UI Elements
    @IBOutlet weak var txtMobileNumber  : UITextField!
    @IBOutlet weak var txtMobileCollapse  : UITextField!
    @IBOutlet weak var viewExpand  : UIView!
    @IBOutlet weak var viewCollapse  : UIView!
    @IBOutlet weak var imgBackground : UIImageView!
    
    // MARK: - Variables
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
        
        let placeholder = SharedData.sharedInstance.placeHolderText(text: kPlaceHolder_Text_Mobile, colorName: UIColor.white)
        txtMobileNumber.attributedPlaceholder = placeholder;
         txtMobileNumber.text = "\(SharedData.sharedInstance.countryCode!)"
        
        
        txtMobileCollapse.attributedPlaceholder = placeholder
        txtMobileCollapse.text = "\(SharedData.sharedInstance.countryCode!)"
        
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
            self.txtMobileNumber.text = self.txtMobileCollapse.text
            self.txtMobileNumber.becomeFirstResponder()
        }else{
            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = true
            viewCollapse.isHidden = false
            self.txtMobileCollapse.text = self.txtMobileNumber.text
            self.txtMobileNumber.resignFirstResponder()
        }
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
        else if !(Validator.isMobileLength(text: txtMobileNumber.text!, lenght: kCharacter_Min_Length_MobileNumber)) {
             self.showToastIMsg(type: .error, strMSG: kAlert_Phone_Number_Length_Msg)
        }
        else {
            self.view.endEditing(true);
            self.userLogin()
        }
    }
    
    @IBAction func btnTapSignUp(_ sender : UIButton) {
        self.view.endEditing(true);

        let obj : SignUpNameViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignUpName) as! SignUpNameViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                if isSuccess == true {
                    let obj : HomeViewController  = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Home) as! HomeViewController
                    if kDefault?.bool(forKey: kUserLogggedIn) == true {
                        UserDAO.sharedInstance.parseUserInfo()
                    }
                    self.present(obj, animated: false, completion: nil)
                    self.addTransitionAtPresentingControllerRight()
                }
                else {
                    self.showToastIMsg(type: .error, strMSG: errorMsg!)
                }
            }
        }else {
            self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
}

// MARK:- Extension TextField Delegate
extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!SharedData.sharedInstance.isMessageWindowExpand) {
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Expand), object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: String! = textField.text
        
        
        if range.location < SharedData.sharedInstance.countryCode.count {
            return false
        }
        
        if(textFieldText.count == SharedData.sharedInstance.countryCode.count && string == kString_isBlank ) {
            return false
        }
        
        if(string == kString_isBlank) {
            return true
        }
        
        if(textFieldText.count >= kCharacter_Max_Length_MobileNumber){
            return false
        }
        
        if(string == kString_singleSpace){
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

}


