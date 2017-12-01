//
//  AppDelegate.swift
//  Emogo
//
//  Created by Vikas Goyal on 27/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var appDelegate:AppDelegate!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.initializeApplication()
        return true
      
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Initialize
    
    fileprivate func initializeApplication(){
        // Keyboard Manager
        IQKeyboardManager.sharedManager().enable = true
        AppDelegate.appDelegate = self
        // Crashlytics
        Fabric.with([Crashlytics.self])
        // If User already logged in
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            UserDAO.sharedInstance.parseUserInfo()
            self.openLandingScreen()
        }
        
        self.keyboardToolBar(disable:false)
    }
    
   fileprivate func openLandingScreen(){
        
        self.window = UIWindow(frame:  UIScreen.main.bounds)
        let objHome = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView) as! StreamListViewController
        let navigation = UINavigationController(rootViewController: objHome)
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
    
    }
    func keyboardToolBar(disable:Bool){
        IQKeyboardManager.sharedManager().enableAutoToolbar = disable
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = disable
        self.keyboardResign(isActive: true)
    }
  
    func keyboardResign(isActive:Bool){
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = isActive
    }
}


/*
 private func composeMessage() -> MSMessage {
 var components = URLComponents()
 var items = [URLQueryItem]()
 items.append(URLQueryItem(name: "test", value: "food"))
 components.queryItems = items
 
 let layout = MSMessageTemplateLayout()
 layout.caption = "Test Me"
 let message = MSMessage(session: MSSession())
 message.url = components.url
 message.layout = layout
 return message
 }
 
 @objc func actionButtonClicked (sender: UIButton) {
 let composeVC = MFMessageComposeViewController()
 composeVC.messageComposeDelegate = self
 
 composeVC.recipients = []
 composeVC.message = composeMessage()
 
 self.present(composeVC, animated: true, completion: nil)
 }
*/
