//
//  UserNameViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 15/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class UserNameViewController: UIViewController {
    
    //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎
    
    @IBOutlet weak var txtUserName                 : UITextField!
    @IBOutlet weak var checkBox                    : UIButton!
    var isAccepted:Bool! = false

    
    
    //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            AppDelegate.appDelegate.removeOberserver()
            AppDelegate.appDelegate.addOberserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎
    
    func prepareLayouts(){
        
        self.addToolBar(textField: self.txtUserName)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.disMissKeyboard))
        view.addGestureRecognizer(tap)
        self.txtUserName.delegate = self
        self.txtUserName.maxLength = 30
        isAccepted = false
        
    }
    
    
    //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎
    
    @IBAction func btnActionNext(_ sender: Any) {
            disMissKeyboard()
        if (self.txtUserName.text?.trim().isEmpty)! {
            self.txtUserName.shake()
        }else if (txtUserName.text?.trim().count)! < 3 || (txtUserName.text?.trim().count)! > 30 {
            self.showToast(type: .error, strMSG: kAlert_Invalid_User_Name_Msg)
        }else if (txtUserName.text?.trim().contains(kString_singleSpace))!{
            self.showToast(type: .error, strMSG: kAlert_Invalid_User_Space_Msg)
        }else if  isAccepted == false{
            self.showToast(type: .error, strMSG: kAlert_Terms_Condition_Msg)
        }else {
            self.verifyUserName()
        }
    }
    
    @IBAction func btnActionSignin(_ sender: Any) {
        let obj:SignInViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_SigninView) as! SignInViewController
        self.navigationController?.push(viewController: obj)
    }
    
    @IBAction func btnActionTermsAndPrivacy(_ sender: Any) {
        let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_TermsAndPrivacyView)
        let navController = UINavigationController(rootViewController: obj)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func btnTermsAndConditionAction(_ sender: Any) {
       isAccepted = !isAccepted
        if isAccepted {
            checkBox.setImage(#imageLiteral(resourceName: "check-box-filled"), for: .normal)
        }else {
            checkBox.setImage(#imageLiteral(resourceName: "check-box-empty"), for: .normal)
        }
    }
    @IBAction func btnActionBack(_ sender: Any) {
        self.navigationController?.pop()
    }
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    @objc func circleBoxValueChanged(sender: Checkbox) {
        print("circle box value change: \(sender.isChecked)")
    }
    
    
    //MARK: ⬇︎⬇︎⬇︎ API Methods ⬇︎⬇︎⬇︎

    
    func verifyUserName(){
        if Reachability.isNetworkAvailable() {
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForUserNameVerify(userName: (txtUserName.text?.trim())!) { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if isSuccess == true {
                    let obj:SignUpViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_SignUpView) as! SignUpViewController
                    obj.userName = self.txtUserName.text?.trim()
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


//MARK: ⬇︎⬇︎⬇︎ EXTENSION ⬇︎⬇︎⬇︎

//MARK: ⬇︎⬇︎⬇︎ Delegate And Datasource ⬇︎⬇︎⬇︎

extension UserNameViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
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
        self.btnActionNext(UIButton())
    }
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
}


