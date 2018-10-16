//
//  SettingViewController.swift
//  Emogo
//
//  Created by Northout on 04/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

   
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var switchForEffect: UISwitch!
    @IBOutlet weak var switchHaptic: UISwitch!
    @IBOutlet weak var lblSeprator: UILabel!
    @IBOutlet weak var lblTitleHaptic: UILabel!
    @IBOutlet weak var cons_top_logout: NSLayoutConstraint!
    
    @IBOutlet weak var btnClose: UIButton!
    
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
       
    }
    
  
    //MARK:- prepare Layout
    
    func prepareLayout() {
        btnLogout.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        switchForEffect.tintColor = UIColor(hex: "00ADF3")
        
      
        
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
   
    //MARK: button actions
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
 
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

    //MARK:- logout Action
    
    func btnLogoutAction() {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Logout, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
           
            APIServiceManager.sharedInstance.apiForLogoutUser { (isSuccess, errorMsg) in
              
                if (errorMsg?.isEmpty)! {
                    self.logout()
                }else {
                  
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "WelcomeScreenVC") as! WelcomeScreenVC
        self.present(vc, animated: true, completion: nil)
        
    }
   
}
