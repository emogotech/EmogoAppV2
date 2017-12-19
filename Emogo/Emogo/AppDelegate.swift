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
    
    func application(_: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return url.scheme == "Emogo" && executeDeepLink(with: url)
    }
    
    private func executeDeepLink(with url: URL) -> Bool {
        let splitStr = "\(url)"
        let splitArr = splitStr.components(separatedBy: "/") as [String]
        print(splitArr)
        if (splitArr.last) != nil {
            if splitArr.last == kDeepLinkTypeProfile as String{
                return setTypeOfViewController(objType: kDeepLinkTypeProfile)
            }else if splitArr.last == kDeepLinkTypePeople as String {
                 return setTypeOfViewController(objType: kDeepLinkTypePeople)
            }else if splitArr.last == kDeepLinkTypeAddStream as String {
                return setTypeOfViewController(objType: kDeepLinkTypeAddStream)
            }
            else if splitArr.last == kDeepLinkTypeAddContent as String {
                return setTypeOfViewController(objType: kDeepLinkTypeAddContent)
            }else if splitArr.last == kDeepLinkTypeEditContent as String {
                SharedData.sharedInstance.streamID = splitArr[3]
                print(SharedData.sharedInstance.streamID)
                return setTypeOfViewController(objType: kDeepLinkTypeEditContent)
            }
            return false
        }
       return false
    }

    private func setTypeOfViewController(objType:String) -> Bool {
        if objType == kDeepLinkTypePeople {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypePeople
        }else if objType == kDeepLinkTypeProfile {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypeProfile
         }else if objType == kDeepLinkTypeAddStream {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypeAddStream
         }else if objType == kDeepLinkTypeAddContent {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypeAddContent
        }else if objType == kDeepLinkTypeEditContent {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypeEditContent
        }
        self.prepareViewController()

        return true
    }
    
    private func prepareViewController() {
         let objHome = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView) as! StreamListViewController
        self.window = UIWindow(frame:  UIScreen.main.bounds)
        let navigation = UINavigationController(rootViewController: objHome)
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: - Initialize
    fileprivate func initializeApplication(){
        // Keyboard Manager
        IQKeyboardManager.sharedManager().enable = true
        AppDelegate.appDelegate = self
       
        // If User already logged in
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            UserDAO.sharedInstance.parseUserInfo()
            print("token-----\(UserDAO.sharedInstance.user.token)")
            self.openLandingScreen()
        }
        self.keyboardToolBar(disable:false)
        // Crashlytics
        Fabric.with([Crashlytics.self])
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
