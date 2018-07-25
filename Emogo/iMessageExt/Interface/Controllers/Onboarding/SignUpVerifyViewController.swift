//
//  SignUpVerifyViewController.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/16/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit
import Messages

class SignUpVerifyViewController: MSMessagesAppViewController,UITextFieldDelegate,VPMOTPViewDelegate {
    
    // MARK:- UI Elements
   // @IBOutlet weak var txtVeryficationCode  : UITextField!
    @IBOutlet weak var txtVeryficationCollapse  : UITextField!
    @IBOutlet weak var imgBackground : UIImageView!
    
    @IBOutlet weak var otpExpandView: VPMOTPView!
    @IBOutlet weak var viewExpand  : UIView!
    @IBOutlet weak var viewCollapse  : UIView!
    @IBOutlet weak var otpCollapseView: VPMOTPView!
    
    // MARK:- Variables
    var OTP                                 : String?
    var phone                               : String?
    var hudView                             : LoadingView!
    var txtVeryficationCode: String = ""
    var isForLogin:String!
    
    // MARK:- Life-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareLayout()
        self.setupLoader()
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- PrepareLayout
    func prepareLayout()  {
        let color = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)

//        let placeholder = SharedData.sharedInstance.placeHolderText(text: kPlaceHolderText_Sign_Up_Verify, colorName: color)
//        txtVeryficationCode.attributedPlaceholder = placeholder;
//        self.addToolBar(textField: txtVeryficationCode)
//        txtVeryficationCollapse.attributedPlaceholder = placeholder
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)
      
        if SharedData.sharedInstance.isMessageWindowExpand {
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = false
            viewCollapse.isHidden = true
            self.setExpandOTPView()
//            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        }else{
//            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = true
            viewCollapse.isHidden = false
            self.setCollapseOTPView()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                if SharedData.sharedInstance.keyboardHeightForSignin == 0.0 {
                    SharedData.sharedInstance.keyboardHeightForSignin =  keyboardSize.height
                }
                if SharedData.sharedInstance.isMessageWindowExpand {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin.y -= SharedData.sharedInstance.keyboardHeightForSignin/2 - 60
                    })
                }
            }
        }
    }
    
    @IBAction func btnCollapseAction(_ sender: Any) {
        
        if(!SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Expand), object: nil)
            
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
         
            UIView.animate(withDuration: 0.2, animations: {
//                self.imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
                self.viewExpand.isHidden = false
                self.viewCollapse.isHidden = true
                self.viewExpand.center = self.view.center
                self.viewCollapse.center = self.view.center
                self.setExpandOTPView()
               // self.txtVeryficationCode.text = self.txtVeryficationCollapse.text
            }, completion: { (finshed) in
                //self.txtVeryficationCode.becomeFirstResponder()
            })
        }else{
           
//            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            UIView.animate(withDuration: 0.1, animations: {
                self.view.endEditing(true)
                 self.setCollapseOTPView()
                //self.txtVeryficationCollapse.resignFirstResponder()
            }, completion: { (finshed) in
                self.viewExpand.isHidden = true
                self.viewCollapse.isHidden = false
                self.viewExpand.center = self.view.center
                self.viewCollapse.center = self.view.center
              //  self.txtVeryficationCollapse.text = self.txtVeryficationCode.text
            })
        }
    }
   
    
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
    @IBAction func btnDone(_ sender : UIButton) {
        self.view.endEditing(true)
        self.checkValidation()
    }
    
    @IBAction func btnResend(_ sender : UIButton){
        self.view.endEditing(true)
        self.resendOTP()
    }
    
    //MARK:- TextField Delegate method
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.isTranslucent = true
        //        toolBar.tintColor =  UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
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
        self.view.endEditing(true)
        self.checkValidation()
    }
    
    func checkValidation() {
        if !(Validator.isEmpty(text: self.txtVeryficationCode)) {
            //txtVeryficationCode.shakeTextField()
        }
        else if !(Validator.isMobileLength(text: self.txtVeryficationCode, lenght: kCharacter_Max_Length_Verification_Code)) {
            self.showToastIMsg(type: .error, strMSG: kAlert_Verification_Length_Msg)
        }
        else {
            self.view.endEditing(true)
            if self.isForLogin == nil {
                self.verifyOTP()
            }else {
                verifyLogin()
            }
            
        }
    }
    
    func setExpandOTPView() {
   
        otpExpandView.otpFieldsCount = 5
        otpExpandView.otpFieldDefaultBorderColor = UIColor.gray
        otpExpandView.otpFieldDisplayType = .square
        otpExpandView.otpFieldSize = 40
        otpExpandView.otpFieldBorderWidth = 1
        otpExpandView.cursorColor = UIColor.gray
        otpExpandView.delegate = self
        otpExpandView.shouldAllowIntermediateEditing = false
        
        // Create the UI
        otpExpandView.initializeUI()
    }
    
    func setCollapseOTPView() {
        
        otpCollapseView.otpFieldsCount = 5
        otpCollapseView.otpFieldDefaultBorderColor = UIColor.gray
        otpCollapseView.otpFieldDisplayType = .square
        otpCollapseView.otpFieldSize = 40
        otpCollapseView.otpFieldBorderWidth = 1
        otpCollapseView.cursorColor = UIColor.gray
        otpCollapseView.delegate = self
        otpCollapseView.shouldAllowIntermediateEditing = false
        
        // Create the UI
        otpCollapseView.initializeUI()
    
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
        let textFieldText: String! = textField.text
        if(string == kString_isBlank){
            return true
        }
        if(textFieldText.count >= kCharacter_Max_Length_Verification_Code){
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        //self.txtVeryficationCode.resignFirstResponder()
    }
    
    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }
    
    // MARK: - API Methods
    func verifyOTP(){
        if Reachability.isNetworkAvailable() {
            self.hudView.startLoaderWithAnimation()
            APIServiceManager.sharedInstance.apiForVerifyUserOTP(otp: self.txtVeryficationCode,phone: self.phone!) { (isSuccess, errorMsg) in
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                if isSuccess == true {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

                    let obj : HomeViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Home) as! HomeViewController
                    self.addTransitionAtPresentingControllerRight()
                    self.present(obj, animated: false, completion: nil)
                }
                else {
                    self.showToastIMsg(type: .error, strMSG: errorMsg!)
                }
            }
        }
        else {
            self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
    
    func verifyLogin(){
        
        if Reachability.isNetworkAvailable() {
            self.hudView.startLoaderWithAnimation()
            APIServiceManager.sharedInstance.apiForVerifyLoginOTP(otp: self.txtVeryficationCode,phone: self.phone!) { (isSuccess, errorMsg) in

                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                if isSuccess == true {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
                    let obj : HomeViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Home) as! HomeViewController
                    self.addTransitionAtPresentingControllerRight()
                    self.present(obj, animated: false, completion: nil)
                }else {
                    self.showToastIMsg(type: .error, strMSG: errorMsg!)
                }
            }
        }else {
            self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
    
    
    func resendOTP(){
        if Reachability.isNetworkAvailable() {
            self.hudView.startLoaderWithAnimation()
            
            APIServiceManager.sharedInstance.apiForResendOTP(phone: self.phone!) { (isSuccess, errorMsg) in
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                if isSuccess == true {
                    self.showToastIMsg(type: .error, strMSG: kAlert_OTP_Msg)
//                    self.txtVeryficationCode.text = errorMsg
                }
            }
        }else {
            self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
  
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        
        return true
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
     
        return true
    }
    
    func enteredOTP(otpString: String) {
        self.txtVeryficationCode = otpString
        print("OTPString: \(otpString)")
    }
  }

