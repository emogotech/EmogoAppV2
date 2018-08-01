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
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var appDelegate:AppDelegate!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Crashlytics

        self.initializeApplication()
        Fabric.with([Crashlytics.self,Branch.self])
        self.configureBranchSDK(launchOptions: launchOptions)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game. ForceStopVideoRecording
        
        if SharedData.sharedInstance.tempVC != nil {
            if (SharedData.sharedInstance.tempVC?.isKind(of: CustomCameraViewController.self))!{
                NotificationCenter.default.post(name: NSNotification.Name("ForceStopVideoRecording"), object: nil)
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
                
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        if SharedData.sharedInstance.tempVC != nil {
//            if (SharedData.sharedInstance.tempVC?.isKind(of: CustomCameraViewController.self))!{
//                NotificationCenter.default.post(name: NSNotification.Name("StopRec"), object: nil)
//            }
//        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
       // print("open url Called")
        let branchHandled = Branch.getInstance().application(app,
                                                             open: url,
                                                             sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
                                                             annotation: options[UIApplicationOpenURLOptionsKey.annotation]
        )
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        }else {
            return true
        }
        
        return url.scheme == "Emogo" && executeDeepLink(with: url)
    }
    
    private func executeDeepLink(with url: URL) -> Bool {
        let splitStr = "\(url)"
        let splitArr = splitStr.components(separatedBy: "/") as [String]
        //print(splitArr)
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
            }
            else if splitArr.last == kDeepLinkMyStreamView as String {
                SharedData.sharedInstance.streamID = splitArr[3]
                return setTypeOfViewController(objType: kDeepLinkMyStreamView)
            }
           else if splitArr.last == kDeepLinkTypeEditStream as String {
                SharedData.sharedInstance.streamID = splitArr[3]
                return setTypeOfViewController(objType: kDeepLinkTypeEditStream)
            } else if splitArr.last == kDeepLinkTypeEditContent as String{
                    SharedData.sharedInstance.streamID = splitArr[3]
                    SharedData.sharedInstance.contentID = splitArr[4]
                  return setTypeOfViewController(objType: kDeepLinkTypeEditContent)
            } else if splitArr.last == kDeepLinkTypeShareAddContent as String {
                self.getInfoFormURLAddToStream(url: url)
                return setTypeOfViewController(objType: kDeepLinkTypeShareAddContent)
            }else if splitArr.last == kDeepLinkShareEditContent as String {
                self.getInfoFormURLAddToStream(url: url)
                return setTypeOfViewController(objType: kDeepLinkShareEditContent)
            }
            else if splitArr.last == kDeepLinkTypeShareMessage as String {
                self.getInfoFormURLAddToStream(url: url)
                return setTypeOfViewController(objType: kDeepLinkTypeShareMessage)
            }else if splitArr.last == kDeepLinkUserProfile as String {
                return setTypeOfViewController(objType: kDeepLinkUserProfile)
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
        } else if objType == kDeepLinkMyStreamView {
            SharedData.sharedInstance.deepLinkType = kDeepLinkMyStreamView
        }else if objType == kDeepLinkShareEditContent {
              SharedData.sharedInstance.deepLinkType = kDeepLinkShareEditContent
        }
        else if objType == kDeepLinkTypeShareMessage {
            SharedData.sharedInstance.deepLinkType = kDeepLinkTypeShareMessage
        }else if  objType == kDeeplinkOpenUserProfile {
             SharedData.sharedInstance.deepLinkType  = kDeeplinkOpenUserProfile
        }else if  objType == kDeepLinkUserProfile {
            SharedData.sharedInstance.deepLinkType  = kDeepLinkUserProfile
        }
        
        self.prepareViewController()

        return true
    }
    
    
    func getInfoFormURL(url:URL){
        var peopleData:[String:Any] = [String:Any]()
        peopleData["full_name"] = "\(url.valueOf(checkKeyType.fullname.rawValue)!)"
        peopleData["user_id"] = "\(url.valueOf(checkKeyType.userId.rawValue)!)"
        peopleData["user_profile_id"] = "\(url.valueOf(checkKeyType.userProfileID.rawValue)!.replacingOccurrences(of: "/People", with: ""))"
        peopleData["phone_number"] = "\(url.valueOf(checkKeyType.phoneNumber.rawValue)!)"
        
        if url.valueOf(checkKeyType.userImage.rawValue)! == "/\(kDeepLinkTypePeople)"{
             peopleData["user_image"] = ""
        }else{
            peopleData["user_image"] = "\(url.valueOf(checkKeyType.userImage.rawValue)!)"
        }
        print(peopleData)
        SharedData.sharedInstance.peopleInfo = PeopleDAO.init(peopleData: peopleData)
    }
    
    func getInfoFormURLAddToStream(url:URL){
      
        var dictData : Dictionary = [String:Any]()
        
        if let count =  kDefault?.value(forKey: "totalItems") {
            SharedData.sharedInstance.contentList.arrayContent.removeAll()
            let imageCount:Int = count as! Int
            for i in 0..<imageCount {
                if let data =  kDefault?.value(forKey: "imageObj" + "\(i)") {
                    let image = UIImage(data: data as! Data)
                    let camera = ContentDAO(contentData: [:])
                    camera.type = .image
                    camera.imgPreview = image
                    camera.fileName = NSUUID().uuidString + ".png"
                    camera.height = Int((image?.size.height)!)
                    camera.width = Int((image?.size.width)!)
                    camera.isUploaded = false
                    SharedData.sharedInstance.contentList.arrayContent.append(camera)
                    kDefault?.removeObject(forKey: "totalItems")
                    kDefault?.removeObject(forKey: "imageObj" + "\(i)")
                    print(image)
                }
            }
            
            return
        }
         if url.valueOf("stream_id") == nil {
            
            dictData["name"] = url.valueOf("name")
            dictData["url"] = url.valueOf("coverImage")
            dictData["description"] = url.valueOf("description")
            dictData["video_image"] = url.valueOf("coverImageVideo")
            dictData["height"] = url.valueOf("height")
            let width = url.valueOf("width")?.components(separatedBy: "/")
            dictData["width"] = width?[0]
            let content = ContentDAO(contentData: dictData)
            content.type =  url.valueOf("type") == "Picture" ? PreviewType.image : .link   //.link
            content.isUploaded = false
            SharedData.sharedInstance.contentList.arrayContent.removeAll()
            SharedData.sharedInstance.contentList.arrayContent.append(content)
            
        }else {
            dictData["name"] = url.valueOf("name")
            dictData["url"] = url.valueOf("url")
            dictData["description"] = url.valueOf("description")
            dictData["video_image"] = url.valueOf("video_image")
            dictData["height"] = url.valueOf("height")
            dictData["width"] = url.valueOf("width")
            dictData["id"] = url.valueOf("content_id")
            dictData["type"] = url.valueOf("type")
            dictData["created_by"] = url.valueOf("created_by")
            let content = ContentDAO(contentData: dictData)
            let strID:String! =  url.valueOf("stream_id")
            if strID.trim() == "" {
                ContentList.sharedInstance.objStream = nil
                content.isUploaded = false
            }else {
                ContentList.sharedInstance.objStream = strID
                content.isUploaded = true
            }
            //print(SharedData.sharedInstance.contentList.arrayContent)
            SharedData.sharedInstance.contentList.arrayContent.removeAll()
            SharedData.sharedInstance.contentList.arrayContent.append(content)
        }
       
    //print(SharedData.sharedInstance.contentList.arrayContent)
    }
    
    private func prepareViewController() {
        if kDefault?.bool(forKey: kUserLogggedIn) == true {
            let objHome = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView) as! StreamListViewController
            self.window = UIWindow(frame:  UIScreen.main.bounds)
            let navigation = PMNavigationController(rootViewController: objHome)
            self.window?.rootViewController = navigation
            self.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - Initialize
    fileprivate func initializeApplication(){
        
        // Keyboard Manager
        IQKeyboardManager.sharedManager().enable = true
        AppDelegate.appDelegate = self
        kDefault?.removeObject(forKey: kRetakeIndex)
        // If User already logged in
       self.performLogin()
       self.keyboardToolBar(disable:false)
      if kDefault?.bool(forKey: kIsAppLaunch) == false {
            kDefault?.set(true, forKey: kIsAppLaunch)
            kDefault?.set(true, forKey: kHapticFeedback)
      }
       
    }
    
    // MARK: - Branch SDK Configuration
    func configureBranchSDK(launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
     
        let  branch = Branch.getInstance()
        // Branch -- uncomment line below for testing
        //        branch = Branch.getTestInstance()
        branch?.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
            if (error == nil) {
                if let dictData = params {
                    let dict:NSDictionary  = dictData as NSDictionary
                   // print(dict)
                    if dict["user_id"] != nil {
                        let deepLink = DeeplinkDAO(dictDeeplink: dict.replacingNullsWithEmptyStrings() as! [String : Any])
                        SharedData.sharedInstance.objDeepLink = deepLink
                        _ =  self.setTypeOfViewController(objType: kDeeplinkOpenUserProfile)
                    }
                }
            }
        })
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
        let navigation = PMNavigationController(rootViewController: objHome)
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    func addOberserver(){
    NotificationCenter.default.addObserver(self, selector: #selector(self.performLogin), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
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
