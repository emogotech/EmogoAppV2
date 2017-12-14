//
//  ContainerViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let selectedVC = instantiateMyStuffController()
        self.presentViewController(controller:selectedVC)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let selectedVC = instantiateMyStuffController()
        self.presentViewController(controller:selectedVC)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func presentViewController(controller: UIViewController) {
        // Remove any child view controllers that have been presented.
        removeAllChildViewControllers()
        addChildViewController(controller)
        controller.view.frame = viewContainer.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        viewContainer.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: viewContainer.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: viewContainer.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
            ])
        controller.didMove(toParentViewController: self)
    }
    
    @IBAction func btnActionController(_ sender: UIButton) {

    }
    // MARK: - Remove all Child ViewController
    
    private func removeAllChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    // MARK: - UIViewControllers
    
    func instantiateMyStuffController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView) as? MyStuffViewController else { fatalError("Unable to instantiate an WelcomeVC from the storyboard") }
        return controller
    }
    
    func instantiateLinkController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView) as? MyStuffViewController else { fatalError("Unable to instantiate an WelcomeVC from the storyboard") }
        return controller
    }
    func instantiateImportController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView) as? MyStuffViewController else { fatalError("Unable to instantiate an WelcomeVC from the storyboard") }
        return controller
    }
    func instantiateGiphyController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView) as? MyStuffViewController else { fatalError("Unable to instantiate an WelcomeVC from the storyboard") }
        return controller
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
