//
//  ShareViewHomeController.swift
//  ShareExt
//
//  Created by Sushobhit on 24/01/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Messages
import MessageUI
import ReadabilityKit

class ShareViewHomeController: UIViewController {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDesc : UILabel!
    @IBOutlet weak var lblLink : UILabel!
    @IBOutlet weak var imgLink : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAndSetContentFromContext()
    }
    
    private func fetchAndSetContentFromContext() {
        let items = extensionContext?.inputItems
        var itemProvider: NSItemProvider?
        if items != nil && items!.isEmpty == false {
            let item = items![0] as! NSExtensionItem
            if let attachments = item.attachments {
                for attachment in attachments {
                    itemProvider = attachment as? NSItemProvider
                    let urlType = kUTTypeURL as NSString  as String
                    if itemProvider?.hasItemConformingToTypeIdentifier(urlType) == true {
                        itemProvider?.loadItem(forTypeIdentifier: urlType, options: nil) { (item, error) -> Void in
                            if error == nil {
                                if let url = item as? NSURL {
                                    Readability.parse(url: url as URL, completion: { data in
                                        if data != nil {
                                            if let title = data?.title {
                                                print(title)
                                                DispatchQueue.main.async {
                                                    self.lblTitle.text = title
                                                }
                                            }
                                            if let description = data?.description {
                                                print(description)
                                                DispatchQueue.main.async {
                                                    self.lblDesc.text = description
                                                }
                                            }
                                            if let topImage = data?.topImage {
                                                print(topImage)
                                                
//                                                self.imgLinks = topImage
                                            }
                                        }
                                    })
                                        DispatchQueue.main.async {
                                            self.lblLink.text = "\(item)"
                                        }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
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
}

extension ShareViewHomeController:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
