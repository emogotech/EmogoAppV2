//
//  ViewController.swift
//  Emogo
//
//  Created by Vikas Goyal on 27/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎
    
    
    @IBOutlet weak var viewTutorial                  : KASlideShow!
    @IBOutlet weak var pageController                : HHPageView!
    @IBOutlet weak var lblWelcome                    : UILabel!


   var images = [UIImage]()
  
    
    //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        AppDelegate.appDelegate.addOberserver()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎
    

    func prepareLayouts(){
        images.removeAll()
        images.append(UIImage(named: "image one")!)
        images.append(UIImage(named: "image two")!)
        images.append(UIImage(named: "image three")!)
        images.append(UIImage(named: "image four")!)
        images.append(UIImage(named: "image five")!)
        images.append(UIImage(named: "image six")!)
    
        pageController.delegate = self
        pageController.isUserInteractionEnabled = false
        pageController.setImageActiveState(#imageLiteral(resourceName: "selected slider circle"), inActiveState: #imageLiteral(resourceName: "unselected slider cirlce"))
        pageController.setNumberOfPages(images.count)
        pageController.setCurrentPage(1)
        viewTutorial.datasource = self
        viewTutorial.delegate = self
        viewTutorial.delay = 1 // Delay between transitions
        viewTutorial.transitionDuration = 0.5 // Transition duration
        viewTutorial.transitionType = KASlideShowTransitionType.slideHorizontal // Choose a transition type (fade or slide)
        viewTutorial.isRepeatAll = true
        viewTutorial.isIphone = true
        viewTutorial.imagesContentMode = .scaleAspectFit // Choose a content mode for images to display
        viewTutorial.add(KASlideShowGestureType.all)
        viewTutorial.isExclusiveTouch = true
        viewTutorial.reloadData()
        pageController.load()
       
        if SharedData.sharedInstance.countryCode.trim().isEmpty {
            self.getCountryCode()
        }
    }

    
    //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎
    
    
    @IBAction func btnActionSignup(_ sender: Any) {
        let obj:UserNameViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_UserNameView) as! UserNameViewController
        self.navigationController?.push(viewController: obj)
    }
    
    @IBAction func btnActionSignin(_ sender: Any) {
        let obj:SignInViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_SigninView) as! SignInViewController
        self.navigationController?.push(viewController: obj)
    }
    
    //MARK: ⬇︎⬇︎⬇︎Other Methods ⬇︎⬇︎⬇︎
    
    func signup(){
        let obj:UserNameViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_UserNameView) as! UserNameViewController
        self.addLeftTransitionView(subtype: kCATransitionFromRight)
        self.navigationController?.pushNormal(viewController: obj)
    }
    
    
    //MARK: ⬇︎⬇︎⬇︎ API Methods ⬇︎⬇︎⬇︎

    func getCountryCode(){
        HUDManager.sharedInstance.showHUD()
        APIManager.sharedInstance.getCountryCode { (code) in
            HUDManager.sharedInstance.hideHUD()
            if !(code?.isEmpty)! {
               let code = "+\(SharedData.sharedInstance.getCountryCallingCode(countryRegionCode: code!))"
                SharedData.sharedInstance.countryCode = code
            }else {
                
                SharedData.sharedInstance.countryCode = SharedData.sharedInstance.getLocaleCountryCode()
            }
        }
    }
    
}


//MARK: ⬇︎⬇︎⬇︎ EXTENSION ⬇︎⬇︎⬇︎
//MARK: ⬇︎⬇︎⬇︎ Delegate And Datasource ⬇︎⬇︎⬇︎

extension ViewController:KASlideShowDelegate,KASlideShowDataSource,HHPageViewDelegate {
    
    func hhPageView(_ pageView: HHPageView!, currentIndex: Int) {
        
    }
    
    func slideShow(_ slideShow: KASlideShow!, objectAt index: Int) -> NSObject! {
        return images[index]
    }
    
    func slideShowImagesNumber(_ slideShow: KASlideShow!) -> Int {
        return images.count
    }
    
    // MARK: - KASlideShow delegate
    func slideShowDidShowNext(_ slideShow: KASlideShow!) {
        let tag = Int(slideShow.currentIndex)
        pageController.updateState(forPageNumber: tag + 1)
        self.updateText(tag: tag)
    }
    func slideShowDidShowPrevious(_ slideShow: KASlideShow!) {
        let tag = Int(slideShow.currentIndex)
        pageController.updateState(forPageNumber: tag + 1)
        self.updateText(tag: tag)
    }

    func slideShowDidEnded(_ slideShow: KASlideShow!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.signup()
        }
    }
    
    func updateText(tag:Int) {
        switch tag {
        case 0:
            lblWelcome.text = "Welcome to Emogo!"
            break
        case 1:
            lblWelcome.text = "Emogo are collections of photos,\nvideos,links & gifs"
            break
        case 2:
            lblWelcome.text = "Collaborate with friends on public or private emogos"
            break
        case 3:
            lblWelcome.text = "Share everything right from iMessage"
            break
        case 4:
            break
        case 5:
            break
        default:
            lblWelcome.text = "Welcome to Emogo!"
        }
    }
    
   
}


