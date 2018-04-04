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
import SwiftLinkPreview

class ShareViewHomeController: UIViewController {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDesc : UILabel!
    @IBOutlet weak var lblLink : UILabel!
    @IBOutlet weak var imgLink : UIImageView!
    @IBOutlet weak var viewContainer : UIView!
    @IBOutlet weak var viewLogin : UIView!
    
    @IBOutlet weak var btnAddToStream : UIButton!
    @IBOutlet weak var btnShareStream : UIButton!
    @IBOutlet weak var imgChoosedImage : UIImageView!
    
    var hudView  : LoadingView!
    var isLoadWeb : Bool = false
    
    var tempWebView  : UIWebView!
    
    
    var dictData : Dictionary = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblTitle.text = ""
        self.lblDesc.text = ""
        self.lblLink.text = ""
        
        let defaultUser  = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")
        
        if defaultUser?.bool(forKey: "userloggedin") == true {
            setupLoader()
            self.navigationController?.navigationBar.isHidden  = true
            viewLogin.isHidden = true
        }
        else {
            viewLogin.isHidden = false
            self.perform(#selector(self.closeAfter), with: nil, afterDelay: 10.0)
        }
        
        viewContainer.layer.cornerRadius = 10.0
        viewContainer.clipsToBounds = true
        
        imgLink.layer.cornerRadius = 10.0
        imgLink.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaultUser  = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")
        if defaultUser?.bool(forKey: "userloggedin") == true {
            DispatchQueue.main.async {
                self.hudView.startLoaderWithAnimation()
            }
            self.fetchAndSetContentFromContext()
        }
    }
    // MARK:- LoaderSetup
    func setupLoader() {
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        hudView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        hudView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hudView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func closeAfter(){
        
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    func hideExtensionWithCompletionHandler(completion:@escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.20, animations: {
            self.navigationController!.view.transform = CGAffineTransform(translationX: 0, y: self.navigationController!.view.frame.size.height)
        }, completion: completion)
    }
    
    private func fetchAndSetContentFromContext() {
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first as! NSItemProvider
        let propertyList = String(kUTTypePropertyList)
        let strPublicURL = String(kUTTypeURL)
        let strPublicPng  =   String(kUTTypePNG)
        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList, options: nil, completionHandler: { (item, error) -> Void in
                guard let dictionary = item as? NSDictionary else { return }
                OperationQueue.main.addOperation {
                    if let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                        let urlString = results["URL"] as? String,
                        let url = NSURL(string: urlString) {
                        print("URL retrieved: \(urlString)")
                        self.getData(mainURL: url as URL!)
                    }
                }
            })
        }else if itemProvider.hasItemConformingToTypeIdentifier(strPublicURL){
            itemProvider.loadItem(forTypeIdentifier: strPublicURL, options: nil, completionHandler: { (item, error) -> Void in
                guard let url = item as? URL else { return }
                OperationQueue.main.addOperation {
                        self.getData(mainURL: url as URL!)
                }
            })
        }else if itemProvider.hasItemConformingToTypeIdentifier(strPublicPng){
            
            self.imgLink.isHidden   =   true
            self.lblDesc.isHidden   =   true
            self.lblTitle.isHidden  =   true
            self.lblLink.isHidden   =   true
            
            
            itemProvider.loadItem(forTypeIdentifier: strPublicPng, options: nil, completionHandler: { (item, error) -> Void in
                
                let imagePath = item as! NSURL
                if FileManager.default.fileExists(atPath: imagePath.path!){
                    print("Exists")
                    let data = NSData.init(contentsOf: imagePath as URL)
                    let imageObj = UIImage(data: data! as Data)
                    self.imgChoosedImage.image  =   imageObj
                    self.imgLink.image  =   imageObj
                    
                    
                    self.dictData["coverImageVideo"] = imagePath.path //url?.absoluteString

                    self.dictData["name"] = "name - 101"
                    self.dictData["description"] = "description - 101"
                    self.dictData["coverImage"] = imagePath.path //url.absoluteString
                    self.dictData["type"] = "Picture"
                    
                    self.hudView.stopLoaderWithAnimation()
                }else{
                    print("No Image")
                }
                
                
                
                
//                guard let image = item as? UIImage else {
//                    print("error in extracting image")
//                    return }
//                OperationQueue.main.addOperation {
//                    print(image)
////                    self.getData(mainURL: url as URL!)
//                }
            })
        } else {
            print("Error - check itemProvider object!")
        }
    }
    
    func getData(mainURL : URL!){
        if let url = mainURL  {
            let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: DisabledCache.instance)
            slp.preview(url.absoluteString,
                        onSuccess: { result in
                            let title = result[SwiftLinkResponseKey.title]
                            let description = result[SwiftLinkResponseKey.description]
                            let imageUrl = result[SwiftLinkResponseKey.image]
                            if let title = title {
                                DispatchQueue.main.async {
                                    self.lblTitle.text = title as? String
                                    self.lblLink.text = url.absoluteString
                                }
                            }
                            if let description = description {
                                DispatchQueue.main.async {
                                    self.lblDesc.text = description as? String
                                    self.lblLink.text = url.absoluteString
                                    self.imgLink.contentMode  = .scaleAspectFill
                                }
                            }
                            if let imageUrl = imageUrl {
                                let url = URL(string: imageUrl as! String)
                                if url != nil {
                                    
                                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                        if error != nil {
                                            print(error!)
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            let img = UIImage(data: data!)
                                            if img == nil {
                                              self.setupWebViewWithUrlStr(strUrl: mainURL!)
                                            }
                                            else {
                                                self.dictData["coverImageVideo"] = url?.absoluteString
                                                self.imgLink.image = img
                                                self.imgLink.contentMode = .scaleAspectFill
                                                self.hudView.stopLoaderWithAnimation()
                                            }
                                        }
                                    }).resume()
                                }
                                else {
                                    self.setupWebViewWithUrlStr(strUrl: mainURL!)
                                }
                            } else {
                                self.setupWebViewWithUrlStr(strUrl: mainURL!)
                            }
                            self.dictData["name"] = title
                            self.dictData["description"] = description
                            self.dictData["coverImage"] = url.absoluteString
                            self.dictData["type"] = "link"
                            self.dictData["isUploaded"] = "false"
            },
                        onError: {
                            error in print("\(error)")
                            self.hudView.stopLoaderWithAnimation()
                            self.showToastIMsg(strMSG: error.localizedDescription )
            })
        }else{
            self.hudView.stopLoaderWithAnimation()
            
            //Sushobhit
            self.showToastIMsg(strMSG: "Plesae Provide message")
        }
    }
    
    func setupWebViewWithUrlStr(strUrl:URL) {
        tempWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
        tempWebView.delegate = self
        tempWebView.scalesPageToFit = true
        tempWebView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        let request = URLRequest(url: strUrl)
        tempWebView.loadRequest(request)
    }
    
    // helper for loading image
    func getDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error? ) -> Void)) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            completion(data, response, error)
        }).resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnCancleAction(_ sender:UIButton) {
        self.view.isUserInteractionEnabled = false
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    @IBAction func btnActionShare(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        let width = Int((self.imgLink.image?.size.height)!)
        let height = Int((self.imgLink.image?.size.width)!)
        self.dictData["height"] = String(format: "%d", (width))
        self.dictData["width"] =  String(format: "%d", (height))
        let str = self.createURLWithComponentsForStream(userInfo: self.dictData, typeNavigation: "shareWithMessage")
        self.presentAppViewWithDeepLink(strURL: str!)
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
            self.view.isUserInteractionEnabled = true
        })
    }
    
    @IBAction func btnAddToStreamAction(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        let width = Int((self.imgLink.image?.size.height)!)
        let height = Int((self.imgLink.image?.size.width)!)
        self.dictData["height"] = String(format: "%d", (width))
        self.dictData["width"] =  String(format: "%d", (height))
        let str = self.createURLWithComponentsForStream(userInfo: self.dictData, typeNavigation: "addContentFromShare")
        self.presentAppViewWithDeepLink(strURL: str!)
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
            self.view.isUserInteractionEnabled = true
        })
    }
    
    @IBAction func btnPostAction(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        
        let width = Int((self.imgLink.image?.size.height)!)
        let height = Int((self.imgLink.image?.size.width)!)
        self.dictData["height"] = String(format: "%d", (width))
        self.dictData["width"] =  String(format: "%d", (height))
        let str = self.createURLWithComponentsForStream(userInfo: self.dictData, typeNavigation: "addContentFromShare")
        self.presentAppViewWithDeepLink(strURL: str!)
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
            self.view.isUserInteractionEnabled = true
        })
    }
    
    func presentAppViewWithDeepLink(strURL : String) {
        guard let url = URL(string: strURL) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            //             UIApplication.shared.openURL(url)
        }
    }
    
    func createURLWithComponentsForStream(userInfo: Dictionary<String, Any>,typeNavigation:String!) -> String? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "Emogo";
        urlComponents.host = "emogo"
        
        // add params
        
        let name = URLQueryItem(name: "name", value: userInfo["name"] as? String )
        let description = URLQueryItem(name: "description", value: userInfo["description"] as? String )
        let coverImage = URLQueryItem(name: "coverImage", value: userInfo["coverImage"] as? String )
        let type = URLQueryItem(name: "type", value: userInfo["type"] as? String )
        let isUploaded = URLQueryItem(name: "isUploaded", value: userInfo["isUploaded"] as? String )
        let coverImageVideo = URLQueryItem(name: "coverImageVideo", value: userInfo["coverImageVideo"] as? String )
        let height = URLQueryItem(name: "height", value: "200" )
        let width = URLQueryItem(name: "width", value: "200")
        urlComponents.queryItems = [name, description, coverImage, type,isUploaded,coverImageVideo,height,width]
        let strURl = "\(urlComponents.url!)/"+typeNavigation
        return strURl
    }
    
    func composeMessage() -> MSMessage {
        
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = lblTitle.text!
        layout.image  = imgLink.image
        layout.subcaption = lblDesc.text!
        message.layout = layout
        message.url = URL(string: "Content/0000/0000")
        
        return message
    }
    
}

extension ShareViewHomeController:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ShareViewHomeController : UIWebViewDelegate {
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.hudView.stopLoaderWithAnimation()
        }
        //Sushobhit
        self.showToastIMsg(strMSG: "Plesae Provide message")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if !isLoadWeb {
            self.perform(#selector(self.getImageForWebView), with: nil, afterDelay: 5.0)
            isLoadWeb = true
        }
        
    }
    
    @objc func getImageForWebView(){
        let image  : UIImage! = self.captureScreen(viewToCapture: self.tempWebView)
        if image != nil {
            let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate).png"
            if   self.writeFile(image, relativePath) {
                print("success")
            }
            DispatchQueue.main.async {
                self.imgLink.image = image
                self.imgLink.contentMode = .scaleAspectFill
            }
            DispatchQueue.main.async {
                self.hudView.stopLoaderWithAnimation()
            }
        }else{
            //Sushobhit
            self.showToastIMsg(strMSG: "Plesae Provide message")
            
        }
        self.tempWebView = nil
    }
    
    func captureScreen(viewToCapture : UIView)  -> UIImage {
        UIGraphicsBeginImageContext(viewToCapture.bounds.size)
        viewToCapture.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return viewImage!
    }
    
    
    func writeFile(_ image: UIImage, _ imgName: String) -> Bool{
        let imageData = UIImageJPEGRepresentation(image, 1)
        let relativePath = imgName
        let path = self.documentsPathForFileName(name: relativePath)
        
        do {
            try imageData?.write(to: path, options: .atomic)
            let strPath = path.absoluteString
            self.dictData["coverImageVideo"] = strPath
        } catch {
            return false
        }
        return true
    }
    
    func readFile(_ name: String) -> UIImage{
        let fullPath = self.documentsPathForFileName(name: name)
        var image = UIImage()
        
        if FileManager.default.fileExists(atPath: fullPath.path){
            image = UIImage(contentsOfFile: fullPath.path)!
        }else{
            image = UIImage(named: "user")!  //a default place holder image from apps asset folder
        }
        return image
    }
    
    func documentsPathForFileName(name: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0]
        let fullPath = path.appendingPathComponent(name)
        return fullPath
    }
    
}


