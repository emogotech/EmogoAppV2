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
    
    // MARK: - Variables
    var hudView: LoadingView!
   
    // MARK: - Life-Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
       // SharedData.sharedInstance.resetAllData()
        prepareLayout()
        setupLoader()
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenStyleExpand), name: NSNotification.Name(rawValue: iMsgNotificationManageRequestStyleExpand), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeStyleCompact), name: NSNotification.Name(rawValue: iMsgNotificationManageRequestStyleCompact), object: nil)
        
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.container.frame = self.view.bounds
    }
    
    @objc func isUserLogedIn() {
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
              UserDAO.sharedInstance.parseUserInfo()
            let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.addChildViewController(vc)
            vc.view.frame = CGRect(x:0, y:0, width:self.container.frame.size.width,height: self.container.frame.size.height);
            self.container.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
            self.hudView.stopLoaderWithAnimation()
             self.hudView.removeFromSuperview()
            self.container.isHidden = false
        }
        else {
            self.hudView.stopLoaderWithAnimation()
            self.hudView.removeFromSuperview()
            self.container.isHidden = true
        }
    }
    
    // MARK: - PrepareLayout
    func prepareLayout()  {
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            UserDAO.sharedInstance.parseUserInfo()
        }
        APIManager.sharedInstance.getCountryCode { (code) in
            if !(code?.isEmpty)! {
                let code = "+\(SharedData.sharedInstance.getCountryCallingCode(countryRegionCode: code!))"
                SharedData.sharedInstance.countryCode = code
            }
        }
    }
    
    // MARK: - Action methods
    @IBAction func btnTapSignIn(_ sender : UIButton) {
        let obj:SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignIn) as! SignInViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    @IBAction func btnTapSignUp(_ sender : UIButton) {
        let obj : SignUpNameViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_SignUpName) as! SignUpNameViewController
        self.addRippleTransition()
        self.present(obj, animated: false, completion: nil)
    }
    
    // MARK: - Screen Size Handling
    @objc func requestMessageScreenStyleExpand() {
        requestPresentationStyle(.expanded)
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
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
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
        }
        else {
            SharedData.sharedInstance.isMessageWindowExpand = false
        }
        NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageScreen), object: nil)
        // Called before the extension transitions to a new presentation style.
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        
//     if let message = conversation.selectedMessage {
//            if let messageLayout = message.layout {
//                print((messageLayout as! MSMessageTemplateLayout).caption as Any)
//                print((messageLayout as! MSMessageTemplateLayout).image as Any)
//                print((messageLayout as! MSMessageTemplateLayout).subcaption as Any)
//                print((messageLayout as! MSMessageTemplateLayout).caption as Any)
//            }
//
//         print(message.url as Any)
//
//        self.extensionContext?.open(message.url!, completionHandler: { (success: Bool) in
//            print(success)
//            })
//        }
//        let strUrl = "\(kDeepLinkImessage)abcd)"
//        guard let url = URL(string: strUrl) else {
//            return
//        }
//        if UIApplication.shared.canOpenURL(url) {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        } else {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open( URL(string: "itms://itunes.apple.com/app/")!, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL( URL(string: "itms://itunes.apple.com/app/")!)
//            }
//        }
        
    }
    
		    // MARK: - Delegate Methods of Segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return false
        
    }
    
}

