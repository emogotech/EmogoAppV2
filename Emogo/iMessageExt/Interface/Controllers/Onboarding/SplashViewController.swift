//
//  SplashViewController.swift
//  iMessageExt
//
//  Created by Pushpendra on 07/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    let segue = "welcomeSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isUserLogedIn()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func isUserLogedIn() {
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            UserDAO.sharedInstance.parseUserInfo()
            if SharedData.sharedInstance.tempViewController == nil {
                let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
        else {
           self.performSegue(withIdentifier: segue, sender: self)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
