//
//  PushHandler.swift
//  Emogo
//
//  Created by Pushpendra Mishra on 10/10/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UserNotifications

class PushHandler: NSObject, UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UserInfo %@",response.notification.request.content.userInfo)
      
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let dict:NSDictionary = notification.request.content.userInfo as NSDictionary
        print("UserInfo %@",dict)
        completionHandler(.alert)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(notification)
    }
    
    
}
