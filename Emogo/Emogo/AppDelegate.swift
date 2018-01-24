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

        // Crashlytics

        self.initializeApplication()
        Fabric.with([Crashlytics.self])
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
                self.getInfoFormURL(url: url)
                 return setTypeOfViewController(objType: kDeepLinkTypePeople)
            }else if splitArr.last == kDeepLinkTypeAddStream as String {
                return setTypeOfViewController(objType: kDeepLinkTypeAddStream)
            }
            else if splitArr.last == kDeepLinkTypeAddContent as String {
                 SharedData.sharedInstance.streamID = splitArr[3]
                return setTypeOfViewController(objType: kDeepLinkTypeAddContent)
            }else if splitArr.last == kDeepLinkTypeEditStream as String {
                SharedData.sharedInstance.streamID = splitArr[3]
                return setTypeOfViewController(objType: kDeepLinkTypeEditStream)
            } else if splitArr.last == kDeepLinkTypeEditContent as String{
                    SharedData.sharedInstance.streamID = splitArr[3]
                    SharedData.sharedInstance.contentID = splitArr[4]
                  return setTypeOfViewController(objType: kDeepLinkTypeEditContent)
            } else if splitArr.last == kDeepLinkTypeShareAddContent as String {
                self.getInfoFormURLAddToStream(url: url)
                return setTypeOfViewController(objType: kDeepLinkTypeShareAddContent)
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
        }else if objType == kDeepLinkTypeEditStream {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypeEditStream
        }else if objType == kDeepLinkTypeEditContent {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypeEditContent
        } else if objType == kDeepLinkTypeShareAddContent {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypeShareAddContent
        }
        self.prepareViewController()

        return true
    }
    
    func getInfoFormURL(url:URL){
        var peopleData:[String:Any] = [String:Any]()
        peopleData["full_name"] = "\(url.valueOf(checkKeyType.fullname.rawValue)!)"
        peopleData["user_profile_id"] = "\(url.valueOf(checkKeyType.userId.rawValue)!)"
        peopleData["phone_number"] = "\(url.valueOf(checkKeyType.phoneNumber.rawValue)!)"
        
        if url.valueOf(checkKeyType.userImage.rawValue)! == "/\(kDeepLinkTypePeople)"{
             peopleData["user_image"] = ""
        }else{
            peopleData["user_image"] = "\(url.valueOf(checkKeyType.userImage.rawValue)!)"
        }
        SharedData.sharedInstance.peopleInfo = PeopleDAO.init(peopleData: peopleData)
    }
    
    func getInfoFormURLAddToStream(url:URL){

        
//        if let obj  = contentData["name"] {
//            self.name = obj as! String
//        }
//        if let obj  = contentData["type"] {
//            let strType:String = obj as! String
//            if strType.trim().lowercased() == "picture"{
//                self.type = .image
//            }else if strType.lowercased() == "video" {
//                self.type = .video
//            }else if strType.lowercased() == "link"{
//                self.type = .link
//            }else {
//                self.type = .gif
//            }
//            if let obj  = contentData["url"] {
//                self.coverImage = obj as! String
//            }
//            if let obj  = contentData["id"] {
//                self.contentID = "\(obj)"
//            }
//            if let obj  = contentData["description"] {
//                self.description = obj as! String
//            }
//            if let obj  = contentData["created_by"] {
//                self.createdBy = "\(obj)"
//            }
//            if let obj  = contentData["video_image"] {
//                self.coverImageVideo = obj as! String
//            }
        
        
        var dictData : Dictionary = [String:Any]()
        dictData["name"] = url.valueOf("name")
        dictData["url"] = url.valueOf("coverImage")
        dictData["description"] = url.valueOf("description")
        dictData["video_image"] = url.valueOf("coverImageVideo")
        dictData["height"] = url.valueOf("height")
        let width = url.valueOf("width")?.components(separatedBy: "/")
        dictData["width"] = width?[0]
        
        let content = ContentDAO(contentData: dictData)
        content.type = .link
        content.isUploaded = false
        
        print(SharedData.sharedInstance.contentList.arrayContent)
        SharedData.sharedInstance.contentList.arrayContent.append(content)
        print(SharedData.sharedInstance.contentList.arrayContent)
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
       self.performLogin()
        self.keyboardToolBar(disable:false)
        
        // Logout User if Token Is Expired
       
    }
    @objc private func performLogin(){
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            UserDAO.sharedInstance.parseUserInfo()
            print("token-----\(UserDAO.sharedInstance.user.token)")
            self.openLandingScreen()
        }
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
    
    func removeOberserver(){
        NotificationCenter.default.removeObserver(self)
    }
    
    func addOberserver(){
//        NotificationCenter.default.addObserver(self, selector: #selector(self.performLogin), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
