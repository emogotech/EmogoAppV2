//
//  TermsAndPrivacyViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class TermsAndPrivacyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayout(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        //editing_cross_icon
        let img1 = UIImage(named: "cross_close_icon")
        let btnDone = UIBarButtonItem(image: img1, style: .plain, target: self, action: #selector(self.dismissAction))
        
        self.navigationItem.rightBarButtonItem = btnDone
    }
    
   @objc func dismissAction(){
        self.dismiss(animated: true, completion: nil)
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
