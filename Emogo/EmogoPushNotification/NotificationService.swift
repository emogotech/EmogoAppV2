//
//  NotificationService.swift
//  EmogoPushNotification
//
//  Created by Pushpendra Mishra on 16/10/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UserNotifications



class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        guard let bestAttemptContent = bestAttemptContent else { return }
        
        bestAttemptContent.title = "\(bestAttemptContent.title)"
        
        guard let imageURLString = request.content.userInfo["attachment-url"] as? String,
            let imageURL = NSURL(string: imageURLString),
            let fileName = imageURL.lastPathComponent else {
                contentHandler(bestAttemptContent)
                return
        }
        
        let dataTask = URLSession.shared.dataTask(with: imageURL as URL) { (data, response, error) in
            guard let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName) else {
                contentHandler(bestAttemptContent)
                return
            }
            do {
                try data?.write(to: fileURL, options: .atomic)
            } catch {
                print(error)
            }
            
            guard let attachment = try? UNNotificationAttachment(identifier: "image", url: fileURL, options: nil) else {
                contentHandler(bestAttemptContent)
                return
            }
            
            bestAttemptContent.attachments = [attachment]
            contentHandler(bestAttemptContent)
        }
        dataTask.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
