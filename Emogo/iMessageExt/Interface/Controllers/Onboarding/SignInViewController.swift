//
//  SignInViewController.swift
//  emogo MessagesExtension
//
//  Created by Sushobhit on 11/16/17.
//  Copyright © 2017 Sushobhit. All rights reserved.
//

import UIKit
import Messages
import Presentr

class SignInViewController: MSMessagesAppViewController {
    
    // MARK:- UI Elements
  //  @IBOutlet weak var txtMobileNumber  : UITextField!
  //  @IBOutlet weak var txtMobileCollapse  : UITextField!
    @IBOutlet weak var viewExpand       : UIView!
    @IBOutlet weak var viewCollapse     : UIView!
    @IBOutlet weak var imgBackground    : UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnCountryPicker : UIButton!
    @IBOutlet weak var btnCountryPickerCollaps : UIButton!
    @IBOutlet weak var txtMobileNumber  : SHSPhoneTextField!
    @IBOutlet weak var txtMobileCollapse  : SHSPhoneTextField!

    let customOrientationPresenter: Presentr = {
        let customType = PresentationType.bottomHalf
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = true
        customPresenter.backgroundColor = .black
        customPresenter.backgroundOpacity = 0.5
        customPresenter.cornerRadius = 5.0
        customPresenter.dismissOnSwipe = true
        return customPresenter
    }()

    lazy var popupViewController: CountryPickerViewController = {
        let popupViewController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_CountryPickerView)
        return popupViewController as! CountryPickerViewController
    }()
    
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
        let color = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
        let placeholder = SharedData.sharedInstance.placeHolderText(text: kPlaceHolder_Text_Mobile, colorName: color)
        txtMobileNumber.attributedPlaceholder = placeholder;
         txtMobileNumber.text = "\(SharedData.sharedInstance.countryCode!)"
        
        self.addToolBar(textField: txtMobileNumber)
        txtMobileCollapse.attributedPlaceholder = placeholder
        txtMobileCollapse.text = "\(SharedData.sharedInstance.countryCode!)"
        
        
        // Set Rule for Phone Format
        txtMobileNumber.formatter.setDefaultOutputPattern(kPhoneFormat, imagePath: "US")
        self.btnCountryPicker.isHidden = false
        popupViewController.delegate = self
        txtMobileNumber.formatter.prefix = " +1"
        txtMobileNumber.hasPredictiveInput = true;
        txtMobileNumber.textDidChangeBlock = { (textField: UITextField!) -> Void in
            print("number is \(textField.text ?? "")")
        }
        
        // Set Rule for Phone Format
        txtMobileCollapse.formatter.setDefaultOutputPattern(kPhoneFormat, imagePath: "US")
        self.btnCountryPickerCollaps.isHidden = false
        popupViewController.delegate = self
        txtMobileCollapse.formatter.prefix = " +1"
        txtMobileCollapse.hasPredictiveInput = true;
        txtMobileCollapse.textDidChangeBlock = { (textField: UITextField!) -> Void in
            print("number is \(textField.text ?? "")")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)
        
        if SharedData.sharedInstance.isMessageWindowExpand {
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = false
            viewCollapse.isHidden = true
            btnBack.isHidden = false
//            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        }else{
//            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = true
            viewCollapse.isHidden = false
            btnBack.isHidden = true
        }
        

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: Keyboard Observer.
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                if SharedData.sharedInstance.keyboardHeightForSignin == 0.0 {
                    SharedData.sharedInstance.keyboardHeightForSignin =  keyboardSize.height
                }
                if SharedData.sharedInstance.isMessageWindowExpand {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin.y -= SharedData.sharedInstance.keyboardHeightForSignin/2-60
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
//            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
            UIView.animate(withDuration: 0.2, animations: {
                self.viewExpand.isHidden = false
                self.viewExpand.center = self.view.center
                self.viewCollapse.isHidden = true
                self.viewCollapse.center = self.view.center
                self.txtMobileNumber.text = self.txtMobileCollapse.text
                self.btnBack.isHidden = false
            }, completion: { (finshed) in
                self.txtMobileNumber.becomeFirstResponder()
            })
        }else{
//            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            UIView.animate(withDuration: 0.1, animations: {
                self.view.endEditing(true)
            }, completion: { (finshed) in
                self.viewExpand.isHidden = true
                self.viewCollapse.isHidden = false
                self.viewExpand.center = self.view.center
                self.viewCollapse.center = self.view.center
                self.txtMobileCollapse.text = self.txtMobileNumber.text
                self.btnBack.isHidden = true
            })
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
    
    
    
    @IBAction func btnActionCountryPicker(_ sender: Any) {
        let nav = UINavigationController(rootViewController: popupViewController)
        customPresentViewController(customOrientationPresenter, viewController: nav, animated: true)
    }
   
    @IBAction func btnSignIn(_ sender : UIButton) {
        view.endEditing(true)
      self.checkValidation()
    }
    @IBAction func btnTapBackAction(_ sender : UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkValidation() {
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

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
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

                    let obj : SignUpVerifyViewController  = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_SignUpVerify) as! SignUpVerifyViewController
                    obj.OTP = errorMsg
                    obj.isForLogin = "errorMsg"
                    obj.phone = self.txtMobileNumber.text?.trim()
                    self.present(obj, animated: false, completion: nil)
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
         view.endEditing(true)
        self.checkValidation()
    }
    
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
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
    func delay(delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
}
extension SignInViewController: CountryPickerViewControllerDelegate{
    
    func dissmissPickerWith(country: CountryDAO) {
        txtMobileNumber.formatter.resetFormats()
        txtMobileNumber.formatter.setDefaultOutputPattern(kPhoneFormat, imagePath: country.code)
        SharedData.sharedInstance.countryCode = country.phoneCode
        txtMobileNumber.formatter.prefix =  " " + country.phoneCode
        
        txtMobileCollapse.formatter.resetFormats()
        txtMobileCollapse.formatter.setDefaultOutputPattern(kPhoneFormat, imagePath: country.code)
        SharedData.sharedInstance.countryCode = country.phoneCode
        txtMobileCollapse.formatter.prefix =  " " + country.phoneCode
    }
    
}
