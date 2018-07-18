//
//  MessagesViewController.swift
//  emogo MessagesExtension
//
//  Created by Vikas Goyal on 14/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imgBackground : UIImageView!

    // MARK: - Variables
    var hudView: LoadingView!
    // MARK: - Life-Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delay(0.4) {
           
        }
   
        // SharedData.sharedInstance.resetAllData()
        setupLoader()
        prepareLayout()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotification_Manage_Request_Style_Expand), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotification_Manage_Request_Style_Compact), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenStyleExpand), name: NSNotification.Name(rawValue: kNotification_Manage_Request_Style_Expand), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeStyleCompact), name: NSNotification.Name(rawValue: kNotification_Manage_Request_Style_Compact), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeOrentation), name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

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
                        self.view.frame.origin.y -= SharedData.sharedInstance.keyboardHeightForSignin/2 - 80
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
    
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
       
    }
    
    // MARK:- LoaderSetup
    func setupLoader() {
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.perform(#selector(self.isUserLogedIn), with: nil, afterDelay: 2.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.hudView.startLoaderWithAnimation()
        }
        
        if  SharedData.sharedInstance.isMessageWindowExpand {
//            imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        }else{
//            imgBackground.image = #imageLiteral(resourceName: "background_collapse")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.container.frame = self.view.bounds
    }
    
    @objc func isUserLogedIn() {
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            self.hudView.removeFromSuperview()
            UserDAO.sharedInstance.parseUserInfo()
            if SharedData.sharedInstance.tempViewController == nil {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

                let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.addChildViewController(vc)
                vc.view.frame = CGRect(x:0, y:0, width:self.container.frame.size.width,height: self.container.frame.size.height);
                self.container.addSubview(vc.view)
                vc.didMove(toParentViewController: self)
                self.container.isHidden = false
            }
        }
        else {
            
//                if self.hudView != nil {
//                    self.hudView.stopLoaderWithAnimation()
//                }
//                self.hudView.removeFromSuperview()
            self.container.isHidden = true
        }
    }
    
    // MARK: - PrepareLayout
    
    func prepareLayout()  {
//        imgBackground.image = #imageLiteral(resourceName: "background-iPhone")
        SharedData.sharedInstance.tempViewController = nil
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            UserDAO.sharedInstance.parseUserInfo()
        }
        APIManager.sharedInstance.getCountryCode { (code) in
            if !(code?.isEmpty)! {
                let code = "+\(SharedData.sharedInstance.getCountryCallingCode(countryRegionCode: code!))"
                SharedData.sharedInstance.countryCode = code
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
            }else {
                SharedData.sharedInstance.countryCode = SharedData.sharedInstance.getLocaleCountryCode()
            }
            self.hudView.removeFromSuperview()
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
                let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.addChildViewController(vc)
                vc.view.frame = CGRect(x:0, y:0, width:self.container.frame.size.width,height: self.container.frame.size.height)
                self.container.addSubview(vc.view)
                vc.didMove(toParentViewController: self)
                if hudView != nil {
                    hudView.stopLoaderWithAnimation()
                    self.hudView.removeFromSuperview()
                }
                self.container.isHidden = false
            }
            else {
                if (SharedData.sharedInstance.tempViewController?.isKind(of: HomeViewController.self))!{
                    self.dismiss(animated: false, completion: nil)
                    navigateControllerAfterMessageSelected(type: splitArr[0])
                }
                else if (SharedData.sharedInstance.tempViewController?.isKind(of: StreamContentViewController.self))!{
                    self.dismiss(animated: false, completion: nil)
                    navigateControllerAfterMessageSelected(type: splitArr[0])
                }
            }
        }
    }
    
    func navigateControllerAfterMessageSelected(type:String){
        SharedData.sharedInstance.iMessageNavigation = type
         let obj : ViewStreamController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
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

