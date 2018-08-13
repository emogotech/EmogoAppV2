//
//  WelcomeScreenVC.swift
//  iMessageExt
//
//  Created by Sushobhit on 05/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class WelcomeScreenVC: MSMessagesAppViewController {
    
    // MARK: - Outlets
//    @IBOutlet weak var container: UIView!
//    @IBOutlet weak var imgBackground : UIImageView!
    
    @IBOutlet weak var viewExpand  : UIView!
    @IBOutlet weak var viewCollapse  : UIView!
    
    @IBOutlet weak var viewTutorial                 : KASlideShow!
    @IBOutlet weak var pageController                : HHPageView!
    
    @IBOutlet weak var viewTutorialClosed                 : KASlideShow!
    @IBOutlet weak var pageControllerClosed                : HHPageView!

    @IBOutlet weak var viewSplash  : UIView!

    
    var images = [UIImage]()
    
    // MARK: - Variables
    var hudView: LoadingView!
    
    
    // MARK: - Life-Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.viewSplash.isHidden = false
//       self.viewExpand.isHidden = true
      // self.viewCollapse.isHidden = true
        
        pageController.delegate = self
        pageControllerClosed.delegate = self
        
        // SharedData.sharedInstance.resetAllData()
        setupLoader()
        prepareLayout()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotification_Manage_Request_Style_Expand), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotification_Manage_Request_Style_Compact), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenStyleExpand), name: NSNotification.Name(rawValue: kNotification_Manage_Request_Style_Expand), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeStyleCompact), name: NSNotification.Name(rawValue: kNotification_Manage_Request_Style_Compact), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeOrentation), name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
        
    }
    
    
    //MARK: Keyboard Observer.
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                if SharedData.sharedInstance.keyboardHeightForSignin == 0.0 {
                    SharedData.sharedInstance.keyboardHeightForSignin =  keyboardSize.height
                }
                if SharedData.sharedInstance.isMessageWindowExpand {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin.y -= SharedData.sharedInstance.keyboardHeightForSignin/2 - 60
                    })
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0{
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin.y = 0
            })
        }
    }
    
    @objc func requestMessageScreenChangeSize(){
        if SharedData.sharedInstance.isMessageWindowExpand {
            
            UIView.animate(withDuration: 0.2, animations: {
                //                self.imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
                self.viewExpand.isHidden = false
                self.viewCollapse.isHidden = true
                self.viewExpand.center = self.view.center
                self.viewCollapse.center = self.view.center
            }, completion: { (finshed) in
            })
        }else{
            //            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            UIView.animate(withDuration: 0.1, animations: {
                self.view.endEditing(true)
                self.viewExpand.isHidden = true
                self.viewCollapse.isHidden = false
                self.viewExpand.center = self.view.center
                self.viewCollapse.center = self.view.center
            }, completion: { (finshed) in
                print("request For Full View")
             //   self.perform(#selector(self.showFullView), with: nil, afterDelay: 1.0)
            })
        }
    }
    
    // MARK:- LoaderSetup
    func setupLoader() {
        
        self.viewSplash.isHidden = true
//   self.viewExpand.isHidden = true
      // self.viewCollapse.isHidden = false
        
        self.perform(#selector(self.isUserLogedIn), with: nil, afterDelay: 2.0)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            if self.hudView != nil {
                self.hudView.startLoaderWithAnimation()
            }
        }
        
        if  SharedData.sharedInstance.isMessageWindowExpand {
            //            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        }else{
            //            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        
        images.removeAll()
        
        if  SharedData.sharedInstance.isMessageWindowExpand {
            images.append(UIImage(named: "imsg_onbr_1")!)
            images.append(UIImage(named: "imsg_onbr_2")!)
            images.append(UIImage(named: "imsg_onbr_3")!)
            images.append(UIImage(named: "imsg_onbr_4")!)
            images.append(UIImage(named: "imsg_onbr_5")!)
            images.append(UIImage(named: "imsg_onbr_6")!)
//            images.append(UIImage(named: "tut_imsg_1")!)
//            images.append(UIImage(named: "tut_imsg_2")!)
//            images.append(UIImage(named: "tut_imsg_3")!)
//            images.append(UIImage(named: "tut_imsg_4")!)
         
        }else{
            images.append(UIImage(named: "imsg_onbr_1")!)
            images.append(UIImage(named: "imsg_onbr_2")!)
            images.append(UIImage(named: "imsg_onbr_3")!)
            images.append(UIImage(named: "imsg_onbr_4")!)
            images.append(UIImage(named: "imsg_onbr_5")!)
            images.append(UIImage(named: "imsg_onbr_6")!)
        }
        
        pageController.delegate = self
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
        
        pageControllerClosed.delegate = self
        pageControllerClosed.setImageActiveState(#imageLiteral(resourceName: "selected slider circle"), inActiveState: #imageLiteral(resourceName: "unselected slider cirlce"))
        pageControllerClosed.setNumberOfPages(images.count)
        pageControllerClosed.setCurrentPage(1)
        viewTutorialClosed.datasource = self
        viewTutorialClosed.delegate = self
        viewTutorialClosed.delay = 1 // Delay between transitions
        viewTutorialClosed.transitionDuration = 0.5 // Transition duration
        viewTutorialClosed.transitionType = KASlideShowTransitionType.slideHorizontal // Choose a transition type (fade or slide)
        viewTutorialClosed.isRepeatAll = true
        viewTutorialClosed.isIphone = true
        viewTutorialClosed.imagesContentMode = .scaleAspectFit // Choose a content mode for images to display
        viewTutorialClosed.add(KASlideShowGestureType.all)
        viewTutorialClosed.isExclusiveTouch = true
        viewTutorialClosed.reloadData()
        pageControllerClosed.load()
  
//        pageController.setCurrentPage(0)
//        pageController.setNumberOfPages(images.count)
//        pageController.setImageActiveState(UIImage(named: "selected slider circle"), inActiveState: UIImage(named: "unselected slider cirlce"))
//        viewTutorial.datasource = self
//        viewTutorial.delegate = self
//        viewTutorial.delay = 1 // Delay between transitions
//        viewTutorial.transitionDuration = 1.0 //0.5 // Transition duration
//        viewTutorial.transitionType = KASlideShowTransitionType.slideHorizontal // Choose a transition type (fade or slide)
//        viewTutorial.isRepeatAll = true
//        viewTutorial.imagesContentMode = .scaleAspectFit // Choose a content mode for images to display
//        viewTutorial.add(KASlideShowGestureType.all)
//        viewTutorial.isExclusiveTouch = true
//        viewTutorial.isIphone = true
//        viewTutorial.reloadData()
//        viewTutorial.start()
//        pageController.load()
//        pageController.updateState(forPageNumber: 0)
        
//        pageControllerClosed.setCurrentPage(0)
//        pageControllerClosed.setNumberOfPages(images.count)
//        pageControllerClosed.setImageActiveState(UIImage(named: "selected slider circle"), inActiveState: UIImage(named: "unselected slider cirlce"))
//        viewTutorialClosed.datasource = self
//        viewTutorialClosed.delegate = self
//        viewTutorialClosed.delay = 1 // Delay between transitions
//        viewTutorialClosed.transitionDuration =  1.0 // 0.5 // Transition duration
//        viewTutorialClosed.transitionType = KASlideShowTransitionType.slideHorizontal // Choose a transition type (fade or slide)
//        viewTutorialClosed.isRepeatAll = true
//        viewTutorialClosed.imagesContentMode = .scaleAspectFit // Choose a content mode for images to display
//        viewTutorialClosed.add(KASlideShowGestureType.all)
//        viewTutorialClosed.isExclusiveTouch = true
//        viewTutorialClosed.reloadData()
//        viewTutorialClosed.start()
//        pageControllerClosed.load()
//        pageControllerClosed.updateState(forPageNumber: 0)
       // self.perform(#selector(self.showFullView), with: nil, afterDelay: 1.0)
    }
    
    func prepareLoader(){
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    @objc func showFullView(){
        if self.presentationStyle == MSMessagesAppPresentationStyle.compact {
            self.requestPresentationStyle(MSMessagesAppPresentationStyle.expanded)
        }
    }
    @objc func isUserLogedIn() {
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            UserDAO.sharedInstance.parseUserInfo()
            if SharedData.sharedInstance.tempViewController == nil {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    self.present(vc, animated: true, completion: nil)
                }
               // self.viewSplash.isHidden = true
                // edit by Pushpendra
               // self.addChildViewController(vc)
//                vc.view.frame = CGRect(x:0, y:0, width:self.container.frame.size.width,height: self.container.frame.size.height);
//                self.container.addSubview(vc.view)
                // edit by Pushpendra
               // vc.didMove(toParentViewController: self)
//                self.container.isHidden = false
            }
        }
        else {
            self.viewSplash.isHidden = true
            self.viewCollapse.isHidden = false
           
//            self.container.isHidden = true
        }
    }
    
    // MARK: - PrepareLayout
    
    func prepareLayout()  {
        //        imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        SharedData.sharedInstance.tempViewController = nil
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            UserDAO.sharedInstance.parseUserInfo()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)

        if SharedData.sharedInstance.isMessageWindowExpand {
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = false
            viewCollapse.isHidden = true
            
            //            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        }else{
            //            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
            self.viewExpand.center = self.view.center
            self.viewCollapse.center = self.view.center
            self.viewExpand.isHidden = true
            self.viewCollapse.isHidden = false
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        APIManager.sharedInstance.getCountryCode { (code) in
            if !(code?.isEmpty)! {
                let code = "+\(SharedData.sharedInstance.getCountryCallingCode(countryRegionCode: code!))"
                SharedData.sharedInstance.countryCode = code
               
            }else {
                 SharedData.sharedInstance.countryCode = SharedData.sharedInstance.getLocaleCountryCode()
            }
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
                self.hudView.removeFromSuperview()
            }

        }
    }
    
    // MARK: - Action methods
    @IBAction func btnTapSignIn(_ sender : UIButton) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let obj:SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignIn) as! SignInViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    @IBAction func btnTapSignUp(_ sender : UIButton) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let obj : SignUpNameViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignUpName) as! SignUpNameViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    // MARK: - Screen Size Handling
    @objc func requestMessageScreenStyleExpand() {
        requestPresentationStyle(.expanded)
        SharedData.sharedInstance.isMessageWindowExpand = true
    }
    
    @objc func changeOrentation() {
        print(self.view.frame.size.width)
        self.perform(#selector(self.changeOrentationAfterBack), with: nil, afterDelay: 0.7)
    }
    
    @objc func changeOrentationAfterBack() {
        if self.view.frame.size.width > self.view.frame.size.height {
            SharedData.sharedInstance.isPortrate = false
        }
        else {
            SharedData.sharedInstance.isPortrate = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Screen_Size), object: nil)
    }
    
    @objc func requestMessageScreenChangeStyleCompact() {
        requestPresentationStyle(.compact)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Conversation Handling
    override func willBecomeActive(with conversation: MSConversation) {
        SharedData.sharedInstance.savedConversation = conversation
        if conversation.selectedMessage != nil {
            self.selectedMsgTap(conversation: conversation)
        }
    }
    
    override func willResignActive(with conversation: MSConversation) {
        SharedData.sharedInstance.tempViewController = nil
        SharedData.sharedInstance.iMessageNavigation = ""
        SharedData.sharedInstance.iMessageNavigationCurrentStreamID = ""
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if(presentationStyle == .expanded) {
            SharedData.sharedInstance.isMessageWindowExpand = true
            //            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        }
        else {
            SharedData.sharedInstance.isMessageWindowExpand = false
            //             imgBackground.image = #imageLiteral(resourceName: "background_collapse")
        }
        NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Screen_Size), object: nil)
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        self.selectedMsgTap(conversation: conversation)
    }
    
    
    func selectedMsgTap(conversation: MSConversation) {
        
        if let message = conversation.selectedMessage {
            
            self.requestMessageScreenStyleExpand()
            
            let msgSummry = String(format: "%@", message.url! as CVarArg)
            
            let splitArr = msgSummry.components(separatedBy: "/")
            var streamData  = [String:Any]()
            
            if splitArr[0] == kNavigation_Stream {
                UserDAO.sharedInstance.parseUserInfo()
                streamData["id"] = splitArr[1]
                SharedData.sharedInstance.streamContent = StreamDAO.init(streamData: streamData)
            }
            else if splitArr[0] == kNavigation_Content {
                if splitArr.count>2{
                    SharedData.sharedInstance.iMessageNavigationCurrentStreamID = splitArr[2]
                    SharedData.sharedInstance.iMessageNavigationCurrentContentID = splitArr[1]
                    SharedData.sharedInstance.contentData = ContentDAO.init(contentData: streamData)
                }else{
                    SharedData.sharedInstance.iMessageNavigationCurrentStreamID = ""
                    SharedData.sharedInstance.iMessageNavigationCurrentContentID = splitArr[1]
                }
 
            }
            if SharedData.sharedInstance.tempViewController == nil {
              SharedData.sharedInstance.iMessageNavigation = splitArr[0]

//                let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//                self.addChildViewController(vc)
//                vc.view.frame = CGRect(x:0, y:0, width:self.container.frame.size.width,height: self.container.frame.size.height)
//                self.container.addSubview(vc.view)
//                vc.didMove(toParentViewController: self)
//                if hudView != nil {
//                    hudView.stopLoaderWithAnimation()
//                    self.hudView.removeFromSuperview()
//                }
//                self.container.isHidden = false
            }
            else {
                
                if (SharedData.sharedInstance.tempViewController?.isKind(of: HomeViewController.self))!{

                    self.dismiss(animated: false, completion: nil)
                    navigateControllerAfterMessageSelected(type: splitArr[0])
                }
                else if (SharedData.sharedInstance.tempViewController?.isKind(of: StreamContentViewController.self))!{
                    self.dismiss(animated: false, completion: nil)
                    self.dismiss(animated: false, completion: nil)
                    navigateControllerAfterMessageSelected(type: splitArr[0])

                }
            }
        }
    }
    
    func navigateControllerAfterMessageSelected(type:String){
        SharedData.sharedInstance.iMessageNavigation = type
        
 let obj : ViewStreamController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
        obj.isFromWelcome = "TRUE"
        if type == kNavigation_Stream {
            var arrayTempStream  = [StreamDAO]()
            arrayTempStream.append(SharedData.sharedInstance.streamContent!)
            obj.arrStream = arrayTempStream
            obj.currentStreamIndex = 0
        }else if type == kNavigation_Content {
            var arrayTempStream  = [StreamDAO]()
            var streamDatas  = [String:Any]()
            streamDatas["id"] = SharedData.sharedInstance.iMessageNavigationCurrentStreamID
            SharedData.sharedInstance.streamContent = StreamDAO.init(streamData: streamDatas)
            arrayTempStream.append(SharedData.sharedInstance.streamContent!)
            obj.arrStream = arrayTempStream
            obj.currentStreamIndex = 0
        }
        self.present(obj, animated: false, completion: nil)
    }
    
    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
    }
    
}

extension WelcomeScreenVC:KASlideShowDelegate,KASlideShowDataSource,HHPageViewDelegate {
    
    func hhPageView(_ pageView: HHPageView!, currentIndex: Int) {
        
    }
    
    func slideShow(_ slideShow: KASlideShow!, objectAt index: Int) -> NSObject! {
        return images[index]
    }
    
    func slideShowImagesNumber(_ slideShow: KASlideShow!) -> Int {
        return images.count
    }
  /*
    // MARK: - KASlideShow delegate
    func slideShowDidShowNext(_ slideShow: KASlideShow!) {
        let tag = Int(slideShow.currentIndex)
        print(tag)
        print(pageController)
        if pageController != nil {
            pageController.updateState(forPageNumber: tag + 1)
            pageControllerClosed.updateState(forPageNumber: tag + 1)
            self.updateText(tag: tag)
        }
        }
        
    func slideShowDidShowPrevious(_ slideShow: KASlideShow!) {
        let tag = Int(slideShow.currentIndex)
        pageController.updateState(forPageNumber: tag + 1)
        pageControllerClosed.updateState(forPageNumber: tag + 1)
        self.updateText(tag: tag)
    }*/
    
    // MARK: - KASlideShow delegate
    func slideShowDidShowNext(_ slideShow: KASlideShow!) {
        let tag = Int(slideShow.currentIndex)
        pageController.updateState(forPageNumber: tag + 1)
        pageControllerClosed.updateState(forPageNumber: tag + 1)
      // self.updateText(tag: tag)
    }
    func slideShowDidShowPrevious(_ slideShow: KASlideShow!) {
        let tag = Int(slideShow.currentIndex)
        pageController.updateState(forPageNumber: tag + 1)
        pageControllerClosed.updateState(forPageNumber: tag + 1)
       //self.updateText(tag: tag)
    }
    func slideShowDidEnded(_ slideShow: KASlideShow!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.signup()
        }
    }
    
//    func updateText(tag:Int) {
//        switch tag {
//        case 0:
//            lblWelcome.text = "Welcome to Emogo!"
//            break
//        case 1:
//            lblWelcome.text = "Emogo are collections of photos,\nvideos,links & gifs"
//            break
//        case 2:
//            lblWelcome.text = "Collaborate with friends on public or private emogos"
//            break
//        case 3:
//            lblWelcome.text = "Share everything right from iMessage"
//
//            break
//        default:
//            lblWelcome.text = "Welcome to Emogo!"
//        }
//    }
    
    func signup(){
        let obj : SignUpNameViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignUpName) as! SignUpNameViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
}
