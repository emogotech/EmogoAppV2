//
//  SettingViewController.swift
//  Emogo
//
//  Created by Northout on 04/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var btnShareProfile: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var switchForEffect: UISwitch!
    @IBOutlet weak var switchHaptic: UISwitch!
    @IBOutlet weak var lblSeprator: UILabel!
    @IBOutlet weak var lblTitleHaptic: UILabel!
    
    @IBOutlet weak var cons_top_logout: NSLayoutConstraint!
    //Variables
    
    var isHapticFeedback:Bool! =  true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareLayout()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavigation()
        
    }
    
    //MARK:- prepare Layout
    
    func prepareLayout() {
        btnLogout.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        switchForEffect.tintColor = UIColor(hex: "00ADF3")
        
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
           cons_top_logout.constant = 76
            
        }
        if kDefault?.bool(forKey: kHapticFeedback) == true{
            switchHaptic.isOn = true
        }else{
            switchHaptic.isOn = false
        }
    }
    
    //MARK:- prepare Navigation
    
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
    
 
    //MARK: button actions
    
    @objc func btnCloseAction(){
        self.navigationController?.popViewAsDismiss()
    }
    
    //MARK:- button logout action
    
    @IBAction func btnLogoutAction(_ sender: Any) {
      
        self.btnLogoutAction()
    }
    
    @IBAction func switchHapticAction(_ sender: Any) {
        
        if switchHaptic.isOn == true {
            self.isHapticFeedback = true
            kDefault?.set(true, forKey: kHapticFeedback)
        }else{
            switchHaptic.isOn = false
            self.isHapticFeedback = false
          
            kDefault?.set(false, forKey: kHapticFeedback)
        }
        
    }
    //MARK:- button share action
    
//    @IBAction func btnShareProfile(_ sender: Any) {
//        self.profileShareAction()
//
//    }
    //MARK:- logout Action
    
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
        kDefault?.set(false, forKey: kUserLogggedIn)
        let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_InitialView)
        self.navigationController?.reverseFlipPush(viewController: obj)
    }
    /*
    //MARK:- share Profile Action
    
     func profileShareAction(){
        if UserDAO.sharedInstance.user.shareURL.isEmpty {
            return
        }
        let url:URL = URL(string: UserDAO.sharedInstance.user.shareURL!)!
        let shareItem =  "Hey checkout \(UserDAO.sharedInstance.user.fullName.capitalized)'s profile!"
        let text = "\n via Emogo"
        
        // let shareItem = "Hey checkout the s profile,emogo"
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [shareItem,url,text], applicationActivities:nil)
        //  activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .airDrop]
        
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil);
        }
    }*/
}
