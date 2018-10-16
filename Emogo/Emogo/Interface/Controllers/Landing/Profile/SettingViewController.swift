//
//  SettingViewController.swift
//  Emogo
//
//  Created by Northout on 04/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

       //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎
    
    @IBOutlet weak var btnShareProfile: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var switchHaptic: UISwitch!
    @IBOutlet weak var lblSeprator: UILabel!
    @IBOutlet weak var lblTitleHaptic: UILabel!
    @IBOutlet weak var cons_top_logout: NSLayoutConstraint!
    
     //MARK: ⬇︎⬇︎⬇︎ Varibales ⬇︎⬇︎⬇︎
    
    var objNavigation:PMNavigationController?
    var isHapticFeedback:Bool! =  true
    
    
     //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        prepareLayout()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavigation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
   //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎
    
    func prepareLayout() {
        btnLogout.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
      //  switchForEffect.tintColor = UIColor(hex: "00ADF3")
        
        print(UIDevice.current.modelName)
        
        if deviceType.iPhone4 || deviceType.iPhone5_5s || deviceType.iPhone6P_6sP{
           switchHaptic.isHidden = true
           lblSeprator.isHidden = true
           lblTitleHaptic.isHidden = true
           cons_top_logout.constant = 0
        }
      
        else {
           switchHaptic.isHidden = false
           lblSeprator.isHidden = false
           lblTitleHaptic.isHidden = false
           cons_top_logout.constant = 99
            
        }
        if kDefault?.bool(forKey: kHapticFeedback) == true{
            switchHaptic.isOn = true
            switchHaptic.thumbTintColor = UIColor.white
        }else{
            switchHaptic.isOn = false
            switchHaptic.thumbTintColor = UIColor.lightGray
        }
    }
    

    
    func prepareNavigation() {
        var myAttribute2:[NSAttributedStringKey:Any]!
        if let font = UIFont(name: kFontBold, size: 20.0) {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: font]
        }else {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
        }
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.navigationController?.navigationBar.barTintColor = .white
        let img = UIImage(named: "profile_close_icon")
        let btnClose = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.btnCloseAction))
        self.navigationItem.leftBarButtonItem = btnClose
        
        self.title = "Settings"
    }
   
    //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎
    
    @objc func btnCloseAction(){
        self.navigationController?.popViewAsDismiss()
    }
   
    @IBAction func btnLogoutAction(_ sender: Any) {
      
        self.btnLogoutAction()
    }
    
    @IBAction func switchHapticAction(_ sender: Any) {
        
        if switchHaptic.isOn == true {
            self.switchHaptic.thumbTintColor = UIColor.white
            self.isHapticFeedback = true
            kDefault?.set(true, forKey: kHapticFeedback)
        }else{
            self.switchHaptic.thumbTintColor = UIColor.lightGray
            switchHaptic.isOn = false
            self.isHapticFeedback = false
          
            kDefault?.set(false, forKey: kHapticFeedback)
        }
        
    }

    
    override func btnLogoutAction() {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Logout, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForLogoutUser { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if (errorMsg?.isEmpty)! {
                    self.logout()
                }else {
                    self.showToast(strMSG: errorMsg!)
                 
                }
            }
            
            alert.dismiss(animated: true, completion: nil)
            
        }
        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
        
    }
    
    private func logout(){
        self.dismiss(animated: true) {
            kDefault?.set(false, forKey: kUserLogggedIn)
            let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_InitialView)
            self.objNavigation?.reverseFlipPush(viewController: obj)
        }
    }
  
}
