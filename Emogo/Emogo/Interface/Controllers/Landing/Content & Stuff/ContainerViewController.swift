//
//  ContainerViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit


enum ContainerType: String {
    case stuff = "200"
    case gallery = "201"
    case giphy = "204"
    case link = "400"
}


class ContainerViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnStuff: UIButton!
    @IBOutlet weak var btnImport: UIButton!
    @IBOutlet weak var btnLink: UIButton!
    @IBOutlet weak var btnGiphy: UIButton!
    
    var selectedConatiner: ContainerType = .stuff {
        
        didSet {
            updateConatiner()
        }
    }
    
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
       self.updateSegment(selected: sender.tag)
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
    
    private func instantiateMyStuffController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView) as? MyStuffViewController else { fatalError("Unable to instantiate an ViewController from the storyboard") }
        return controller
    }
    
    private func instantiateLinkController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_LinkView) as? LinkViewController else { fatalError("Unable to instantiate an ViewController from the storyboard") }
        return controller
    }
    private func instantiateImportController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ImportView) as? ImportViewController else { fatalError("Unable to instantiate an ViewController from the storyboard") }
        return controller
    }
    private func instantiateGiphyController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_GiphyView) as? GiphyViewController else { fatalError("Unable to instantiate an ViewController from the storyboard") }
        return controller
    }
    
    private func updateConatiner(){
        switch selectedConatiner {
        case .stuff:
            let selectedVC = instantiateMyStuffController()
            self.presentViewController(controller:selectedVC)
            break
        case .link:
            let selectedVC = instantiateLinkController()
            self.presentViewController(controller:selectedVC)
            break
        case .gallery:
            let selectedVC = instantiateImportController()
            self.presentViewController(controller:selectedVC)
            break
        case .giphy:
            let selectedVC = instantiateGiphyController()
            self.presentViewController(controller:selectedVC)
            break
        }
    }
    
    func updateSegment(selected:Int){
        switch selected {
        case 111:
            self.selectedConatiner = .stuff
            self.btnStuff.setImage(#imageLiteral(resourceName: "my_stuff_active_icon"), for: .normal)
            self.btnLink.setImage(#imageLiteral(resourceName: "link_unactive_icon"), for: .normal)
            self.btnImport.setImage(#imageLiteral(resourceName: "import_unactive_icon"), for: .normal)
            self.btnGiphy.setImage(#imageLiteral(resourceName: "giphy_unactive_icon"), for: .normal)
            break
        case 222:
            self.btnStuff.setImage(#imageLiteral(resourceName: "my_stuff_unactive_icon"), for: .normal)
            self.btnLink.setImage(#imageLiteral(resourceName: "link_active_icon"), for: .normal)
            self.btnImport.setImage(#imageLiteral(resourceName: "import_unactive_icon"), for: .normal)
            self.btnGiphy.setImage(#imageLiteral(resourceName: "giphy_unactive_icon"), for: .normal)
            self.selectedConatiner = .link
            break
        case 333:
            self.btnStuff.setImage(#imageLiteral(resourceName: "my_stuff_unactive_icon"), for: .normal)
            self.btnLink.setImage(#imageLiteral(resourceName: "link_unactive_icon"), for: .normal)
            self.btnImport.setImage(#imageLiteral(resourceName: "import_active_icon"), for: .normal)
            self.btnGiphy.setImage(#imageLiteral(resourceName: "giphy_unactive_icon"), for: .normal)
            self.selectedConatiner = .gallery
            break
        case 444:
            self.btnStuff.setImage(#imageLiteral(resourceName: "my_stuff_unactive_icon"), for: .normal)
            self.btnLink.setImage(#imageLiteral(resourceName: "link_unactive_icon"), for: .normal)
            self.btnImport.setImage(#imageLiteral(resourceName: "import_unactive_icon"), for: .normal)
            self.btnGiphy.setImage(#imageLiteral(resourceName: "giphy_active_icon"), for: .normal)
            self.selectedConatiner = .giphy
            break
        default:
            break
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
