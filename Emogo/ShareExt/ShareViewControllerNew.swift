//
//  ShareViewControllerNew.swift
//  ShareExt
//
//  Created by Sushobhit on 23/01/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Messages
import MessageUI


class ShareViewControllerNew: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(self.extensionContext?.inputItems)
//        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
//            if let itemProvider = item.attachments as? NSItemProvider {
//                print(itemProvider.description)
//                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
//                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
//                        if let shareURL = url as? NSURL {
//                            // do what you want to do with shareURL
//                        }
////                        self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
//                    })
//                }
//            }
//        }
       
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnCancleAction(_ sender:UIButton) {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @IBAction func btnActionShare(_ sender: Any) {
        if MFMessageComposeViewController.canSendAttachments(){
            let composeVC = MFMessageComposeViewController()
            composeVC.recipients = []
            composeVC.message = composeMessage()
            composeVC.messageComposeDelegate = self
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    func composeMessage() -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        
        layout.caption = "txtTitleImage.text!"
        layout.subcaption = "txtDescription.text"
        message.layout = layout
        
        return message
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShareViewControllerNew:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
