//
//  ShareViewController.swift
//  ShareExt
//
//  Created by Northout on 31/07/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Messages
import MessageUI
import SwiftLinkPreview

class ShareViewController: UIViewController {
    
    //MARK: Outlet Connection
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewLink: UIView!
    @IBOutlet weak var collectionShareImage: UICollectionView!
    @IBOutlet weak var viewLogin: UIView!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnShareiMsg: UIButton!
    @IBOutlet weak var btnChooseEmogo: UIButton!
    
    @IBOutlet weak var imgLink: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
  
    
    var hudView  : LoadingView!
    var isLoadWeb : Bool = false
    var tempWebView  : UIWebView!
    var arrayImages = [UIImage]()
    var collectionLayout = CHTCollectionViewWaterfallLayout()
    var dictData : Dictionary = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        viewLink.layer.cornerRadius = 10.0
        viewLink.clipsToBounds = true
        viewLink.layer.borderColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        viewLink.layer.borderWidth =  1.0
      
        imgLink.layer.cornerRadius = 10.0
        imgLink.clipsToBounds = true
   
        self.viewLink.isHidden = false
        self.collectionShareImage.isHidden = true
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.prepareLayout()
        
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
    
    func prepareLayout(){
        
        self.collectionShareImage.isHidden = false
        self.collectionShareImage.delegate = self
        self.collectionShareImage.dataSource = self
        collectionLayout.minimumColumnSpacing = 8.0
        collectionLayout.minimumInteritemSpacing = 2.0
        collectionLayout.sectionInset = UIEdgeInsetsMake(10, 8, 0, 8)
        collectionLayout.columnCount = 2
        self.collectionShareImage.collectionViewLayout = collectionLayout
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
            if let nav = self.navigationController {
                self.navigationController!.view.transform = CGAffineTransform(translationX: 0, y: self.navigationController!.view.frame.size.height)
            }else {
                self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
            }
          //  print(self.navigationController)
        }, completion: completion)
    }
    
    private func fetchAndSetContentFromContext() {
        
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first as! NSItemProvider
        
        let propertyList = String(kUTTypePropertyList)
        let strPublicURL = String(kUTTypeURL)
        let strPublicPng  =   String(kUTTypePNG)
        let strPublicJpeg    =   String(kUTTypeJPEG)
        print(extensionItem)
        print(itemProvider)
        print(propertyList)
        print(strPublicURL)
        print(strPublicPng)
        print(strPublicJpeg)
        
        
        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList, options: nil, completionHandler: { (item, error) -> Void in
                guard let dictionary = item as? NSDictionary else { return }
                OperationQueue.main.addOperation {
                    self.collectionShareImage.isHidden = true
                    self.viewLink.isHidden = false
                    self.imgLink.isHidden   =   false
                    self.lblDesc.isHidden   =   false
                    self.lblTitle.isHidden  =   false
                    self.lblLink.isHidden   =   false
                    if let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                        let urlString = results["URL"] as? String,
                        let url = NSURL(string: urlString) {
                        print("URL retrieved: \(urlString)")
                        self.getData(mainURL: url as URL)
                    }
                }
            })
        }else if itemProvider.hasItemConformingToTypeIdentifier(strPublicURL){
            itemProvider.loadItem(forTypeIdentifier: strPublicURL, options: nil, completionHandler: { (item, error) -> Void in
                guard let url = item as? URL else {
                    //remove
                    self.closeAfter()
                    return }
                OperationQueue.main.addOperation {
                    self.getData(mainURL: url as URL)
                }
            })
        }else if itemProvider.hasItemConformingToTypeIdentifier(strPublicPng) {
            
                        self.collectionShareImage.isHidden = false
            
                        self.viewLink.isHidden  =  true
                        self.imgLink.isHidden   =   true
                        self.lblDesc.isHidden   =   true
                        self.lblTitle.isHidden  =   true
                        self.lblLink.isHidden   =   true
            
            
            if let item = self.extensionContext?.inputItems[0] as? NSExtensionItem{
                for (index,ele) in (item.attachments?.enumerated())!{
                    let itemProvider = ele as! NSItemProvider
                    
                    itemProvider.loadItem(forTypeIdentifier: strPublicPng, options: nil, completionHandler: { (item, error) -> Void in
                        
                        
                        let imagePath = item as! NSURL
                        if FileManager.default.fileExists(atPath: imagePath.path!){
                            print("Exists")
                           
                        
                            let data = NSData.init(contentsOf: imagePath as URL)
                            let imageObj = UIImage(data: data! as Data)
                            self.arrayImages.append(imageObj!)
                            print(self.arrayImages.count)
                           
                            let defaultUser  = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")
                            defaultUser?.setValue(UIImagePNGRepresentation(imageObj!), forKey: "imageObj"+"\(index)")
                            defaultUser?.synchronize()
                            
                            self.dictData["coverImageVideo"] = imagePath.path
                            self.dictData["name"] = "SharedImage_group.com.emogotechnologiesinc.thoughtstream"
                            self.dictData["description"] = ""
                            self.dictData["coverImage"] = imagePath.path
                            self.dictData["type"] = "Picture"
                            
                            self.collectionShareImage.reloadData()
                            
                            self.hudView.stopLoaderWithAnimation()
                        }else{
                            print("No Image")
                        }
                    })
                }
            }
            
        }else if itemProvider.hasItemConformingToTypeIdentifier(strPublicJpeg) {
            
            self.collectionShareImage.isHidden = false
          
            self.viewLink.isHidden  =  true
            self.imgLink.isHidden   =   true
            self.lblDesc.isHidden   =   true
            self.lblTitle.isHidden  =   true
            self.lblLink.isHidden   =   true
           
            
            if let item = self.extensionContext?.inputItems[0] as? NSExtensionItem{
                let itemcount = item.attachments?.count
                for (index,ele) in (item.attachments?.enumerated())!{
                    let itemProvider = ele as! NSItemProvider
            
            itemProvider.loadItem(forTypeIdentifier: strPublicJpeg, options: nil, completionHandler: { (item, error) -> Void in
               
                   
                let imagePath = item as! NSURL
                if FileManager.default.fileExists(atPath: imagePath.path!){
                    print("Exists")
                   
                    let data = NSData.init(contentsOf: imagePath as URL)
                    let imageObj = UIImage(data: data! as Data)
                    self.arrayImages.append(imageObj!)
                    print(self.arrayImages.count)
        
                    let defaultUser  = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")
                    defaultUser?.setValue(UIImagePNGRepresentation(imageObj!), forKey: "imageObj"+"\(index)")
                    defaultUser?.set(itemcount, forKey: "totalItems")
                    defaultUser?.synchronize()
                    self.dictData["coverImageVideo"] = imagePath.path
                    self.dictData["name"] = "SharedImage_group.com.emogotechnologiesinc.thoughtstream"
                    self.dictData["description"] = ""
                    self.dictData["coverImage"] = imagePath.path
                    self.dictData["type"] = "Picture"
                   
                    self.collectionShareImage.reloadData()
                    
                    self.hudView.stopLoaderWithAnimation()
                }else{
                    print("No Image")
                }
                    })
                }
            }
          
            
        } else  if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first as? NSItemProvider {
                if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") {
                    itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil, completionHandler: { (url, error) -> Void in
                        let strURL:String = url as! String
                        print(strURL)
                        guard let openUrl = URL(string: strURL) else {
                            //remove
                            self.closeAfter()
                            return
                        }
                        print(openUrl)
                        
                        
                        OperationQueue.main.addOperation {
                            self.getData(mainURL: openUrl)
                        }
                        
                        
                        //   self.extensionContext?.completeRequestReturningItems([], completionHandler:nil)
                    })
                }
            }
        }
        else {
            print("Error - check itemProvider object!")
            //remove
            closeAfter()
        }
    }
    
    func getData(mainURL : URL!){
        if let url = mainURL  {
            let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: DisabledCache.instance)
            slp.preview(url.absoluteString,
                        onSuccess: { result in
                            self.collectionShareImage.isHidden = true
                            self.viewLink.isHidden  =   false
                            self.imgLink.isHidden   =   false
                            self.lblDesc.isHidden   =   false
                            self.lblTitle.isHidden  =   false
                            self.lblLink.isHidden   =   false
                        
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
    //MARK:- Action for Buttons
    
    @IBAction func btnActionAdd(_ sender: Any) {
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
    
    @IBAction func btnActionCancel(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")?.setValue(nil, forKey: "imageObj")
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    @IBAction func btnActionClose(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")?.setValue(nil, forKey: "imageObj")
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    @IBAction func btnActionChooseEmogo(_ sender: Any) {
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
    
    @IBAction func btnActionShareiMsg(_ sender: Any) {
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
            // UIApplication.shared.openURL(url)
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
extension ShareViewController:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ShareViewController : UIWebViewDelegate {
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

extension ShareViewController: UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrayImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionImagesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionImagesCell", for: indexPath) as! CollectionImagesCell
       cell.imgSelected.image = self.arrayImages[indexPath.row]
       cell.imgSelected.layer.cornerRadius = 10.0
       cell.imgSelected.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
                let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
                return CGSize(width: itemWidth, height: 68)
    }
}
