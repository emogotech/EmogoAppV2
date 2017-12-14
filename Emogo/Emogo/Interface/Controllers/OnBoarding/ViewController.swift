//
//  ViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 27/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements

    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareLayouts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
   // MARK: - Prepare Layouts
    func prepareLayouts(){
        if SharedData.sharedInstance.countryCode.trim().isEmpty {
            self.getCountryCode()
        }
    }

    // MARK: -  Action Methods And Selector
    @IBAction func btnActionSignup(_ sender: Any) {
        let obj:UserNameViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_UserNameView) as! UserNameViewController
        self.navigationController?.push(viewController: obj)
    }
    
    @IBAction func btnActionSignin(_ sender: Any) {
        let obj:SignInViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_SigninView) as! SignInViewController
        self.navigationController?.push(viewController: obj)
    }
    
    // MARK: - Class Methods
    
    func getCountryCode(){
        HUDManager.sharedInstance.showHUD()
        APIManager.sharedInstance.getCountryCode { (code) in
            HUDManager.sharedInstance.hideHUD()
            if !(code?.isEmpty)! {
               let code = "+\(SharedData.sharedInstance.getCountryCallingCode(countryRegionCode: code!))"
                SharedData.sharedInstance.countryCode = code
            }
        }
    }
}


