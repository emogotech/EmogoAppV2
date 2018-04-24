//
//  SignInViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 31/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var txtPhoneNumber                 : SHSPhoneTextField!
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        AppDelegate.appDelegate.removeOberserver()
        AppDelegate.appDelegate.addOberserver()
        
        addToolBar(textField: txtPhoneNumber)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.disMissKeyboard))
        view.addGestureRecognizer(tap)
        // Set Rule for Phone Format
        txtPhoneNumber.formatter.setDefaultOutputPattern(kPhoneFormat)
        txtPhoneNumber.formatter.prefix = SharedData.sharedInstance.countryCode!
      //  txtPhoneNumber.formatter.prefix = "+1"
        txtPhoneNumber.hasPredictiveInput = true;
        txtPhoneNumber.textDidChangeBlock = { (textField: UITextField!) -> Void in
            print("number is \(textField.text ?? "")")
        }
    }
    
    // MARK: -  Action Methods And Selector
    @IBAction func btnDoneAction(_ sender: Any) {
         self.disMissKeyboard()
        if (self.txtPhoneNumber.text?.trim().isEmpty)! {
            self.txtPhoneNumber.shake()
        }else if (txtPhoneNumber.text?.trim().count)! < 10 {
            self.showToast(type: .error, strMSG: kAlert_Phone_Number_Length_Msg)
        }else {
            self.userLogin()
        }
    }
    
    @IBAction func btnSignupAction(_ sender: Any) {
        self.disMissKeyboard()
        let obj:UserNameViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_UserNameView) as! UserNameViewController
        self.navigationController?.push(viewController: obj)
    }
    @IBAction func btnActionBack(_ sender: Any) {
        self.navigationController?.pop()
    }
    
    // MARK: - Class Methods
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: - API Methods

    
    func userLogin(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForUserLogin(phone: (txtPhoneNumber.text?.trim())!) { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    /*
                    let obj:StreamListViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView) as! StreamListViewController
                    self.navigationController?.flipPush(viewController: obj)
 */
                    
                    let obj:VerificationViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_VerificationView) as! VerificationViewController
                    obj.isForLogin = "errorMsg"
                    obj.phone = self.txtPhoneNumber.text?.trim()
                    self.navigationController?.push(viewController: obj)
                    
                }else {
                    self.showToast(type: .error, strMSG: errorMsg!)
                }
            }
        }else {
            self.showToast(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
        
    }
        

}


extension SignInViewController: UITextFieldDelegate{
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
        self.btnDoneAction(UIButton())
    }
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
}




