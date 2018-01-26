//
//  HomeViewController.swift
//  ShareExt
//
//  Created by Sushobhit on 26/01/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

@objc(HomeViewController)

class HomeViewController: UINavigationController {

    init() {
        let viewController:UIViewController = UIStoryboard(name: "MainInterface", bundle: nil).instantiateViewController(withIdentifier: "ShareViewHomeController") as UIViewController
        super.init(rootViewController: viewController)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
    }

}
