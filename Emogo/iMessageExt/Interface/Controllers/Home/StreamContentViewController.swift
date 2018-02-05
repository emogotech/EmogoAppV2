//
//  StreamContentViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 29/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages
import Lightbox
import SafariServices

class StreamContentViewController: MSMessagesAppViewController {
    
    // MARK:- UI Elements
    @IBOutlet weak var lblStreamTitle       : UILabel!
    @IBOutlet weak var lblStreamName        : UILabel!
    @IBOutlet weak var lblStreamDesc        : UILabel!
    
    @IBOutlet  weak var contentProgressView : UIProgressView!
    
    @IBOutlet weak var imgStream            : FLAnimatedImageView!
    @IBOutlet weak var imgGradient          : UIImageView!
    
    @IBOutlet weak var viewAction           : UIView!
    
    @IBOutlet weak var btnEdit              : UIButton!
    @IBOutlet weak var btnDelete            : UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    var isDeleteContent: Bool = false
    
    
    // MARK: - Variables
    var currentContentIndex                 : Int!
    var currentStreamID                     : String!
    var currentStreamTitle                     : String?
    var arrContentData                      = [ContentDAO]()
    var hudView                             : LoadingView!
    // MARK: - Life-cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedData.sharedInstance.tempViewController = self
        setupLoader()
        let content = arrContentData.first
        if (content?.isAdd)! {
            arrContentData.remove(at: 0)
            currentContentIndex = currentContentIndex - 1
        }
        self.perform(#selector(self.prepareLayout), with: nil, afterDelay: 0.2)
//        ContentList.sharedInstance.arrayContent = arrContentData
        requestMessageScreenChangeSize()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentProgressView.transform = CGAffineTransform(scaleX: 1, y: 3)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)
        
    }
    
    // MARK:- Selector Methods
    @objc func requestMessageScreenChangeSize(){
        if(SharedData.sharedInstance.isMessageWindowExpand == false){
            imgStream.isUserInteractionEnabled = false
        }
        else {
            imgStream.isUserInteractionEnabled = true
        }
    }
    
    // MARK:- LoaderSetup
    func setupLoader() {
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: - PrepareLayout
    @objc func prepareLayout(){
        DispatchQueue.main.async {
            self.hudView.startLoaderWithAnimation()
        }
        
        loadViewForUI()
        let temp = self.arrContentData[currentContentIndex]
        if temp.type == .video {
            let videoUrl = URL(string: temp.coverImage)
            LightboxConfig.handleVideo(self, videoUrl!)
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imgStream.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imgStream.addGestureRecognizer(swipeLeft)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.btnPlayAction(_:)))
        imgStream.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if currentContentIndex !=  arrContentData.count-1 {
                    self.perform(#selector(self.nextContentLoad), with: nil, afterDelay: 0.1)
                }
                break
            case UISwipeGestureRecognizerDirection.right:
                if currentContentIndex != 0 {
                    self.perform(#selector(self.previousContentLoad), with: nil, afterDelay: 0.1)
                }
                break
            default:
                break
            }
        }
    }
    
    @objc func nextContentLoad() {
        if(currentContentIndex < arrContentData.count-1) {
            currentContentIndex = currentContentIndex + 1
        }
        
        self.addRightTransitionImage(imgV: self.imgStream)
        
        
        loadViewForUI()
    }
    
    @objc func previousContentLoad(){
        if currentContentIndex != 0{
            currentContentIndex = currentContentIndex - 1
        }
        
        self.addLeftTransitionImage(imgV: self.imgStream)
        loadViewForUI()
    }
    
    //MARK: - Load Data in UI
    func loadViewForUI(){
        self.imgStream.contentMode = .scaleAspectFit
        let content = self.arrContentData[currentContentIndex]
        self.lblStreamName.text = content.name.trim().capitalized
        
        if currentStreamTitle == "" {
            lblStreamTitle.text = ""
        }else{
            lblStreamTitle.text   = currentStreamTitle!
        }
        
        if content.type != nil {
            
            if content.type == .image {
                self.imgStream.setForAnimatedImage(strImage:content.coverImage)
                SharedData.sharedInstance.downloadImage(url: content.coverImage, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgStream.backgroundColor = colors.primary
                    })
                })
            }
            else if content.type == .video {
                self.imgStream.setForAnimatedImage(strImage:content.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: content.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgStream.backgroundColor = colors.primary
                    })
                })
            }
            else if content.type == .link {
                self.btnPlay.isHidden = true
                self.imgStream.setForAnimatedImage(strImage:content.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: content.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgStream.backgroundColor = colors.primary
                    })
                })
            } else {
                self.imgStream.setForAnimatedImage(strImage:content.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: content.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgStream.backgroundColor = colors.primary
                    })
                })
            }
            if content.type == .video   {
                self.btnPlay.isHidden = false
            }else {
                self.btnPlay.isHidden = true
            }
        }
        
        lblStreamDesc.text = content.description.trim().capitalized
        let currenProgressValue = Float(currentContentIndex)/Float(arrContentData.count-1)
        contentProgressView.setProgress(currenProgressValue, animated: true)
        btnEdit.isHidden = !content.isEdit
        btnDelete.isHidden = !content.isDelete
        
        
        self.lblStreamName.minimumScaleFactor = 1.0
        self.lblStreamDesc.minimumScaleFactor = 1.0
        self.lblStreamTitle.minimumScaleFactor = 1.0
        
        DispatchQueue.main.async {
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
        }
    }
    
    //MARK: - Action Methods
    @IBAction func btnAddStreamContent(_ sender:UIButton){
        let strUrl = "\(kDeepLinkURL)\(kDeepLinkTypeAddContent)"
        SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
    }
    
    @IBAction func btnClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
        if SharedData.sharedInstance.iMessageNavigation != ""{
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Stream_Content), object: nil)
            SharedData.sharedInstance.iMessageNavigation = ""
        }
        else {
            SharedData.sharedInstance.iMessageNavigation = ""
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Content_Data), object: nil)
        }
    }
    
    @IBAction func btnsendAction(_ sender:UIButton){
        self.view.isUserInteractionEnabled = false
        if(SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Compact), object: nil)
        }
        self.perform(#selector(self.sendMessage), with: nil, afterDelay: 0.1)
    }
    
    @IBAction func btnPlayAction(_ sender: Any) {
        self.openFullView()
    }
    
    @objc func openFullView() {
        let content = arrContentData[self.currentContentIndex]
        if content.type == .gif {
            return
        }
        if content.type == .link {
            guard let url = URL(string: content.coverImage) else {
                return //be safe
            }
            self.openURL(url: url)
            return
        }
        var arrayContents = [LightboxImage]()
        for obj in arrContentData {
            var image:LightboxImage!
            let text = obj.name + "\n" +  obj.description
            
            if obj.type == .image {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: text.trim(), videoURL: nil)
                }else{
                    let url = URL(string: obj.coverImage)
                    if url != nil {
                        image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: nil)
                    }
                }
            }else if obj.type == .video {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: text.trim(), videoURL: obj.fileUrl)
                }else {
                    let url = URL(string: obj.coverImageVideo)
                    let videoUrl = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: videoUrl!)
                }
            }
            if image != nil {
                arrayContents.append(image)
            }
        }
        
        if content.type == .video {
            let videoUrl = URL(string: content.coverImage)
            LightboxConfig.handleVideo(self, videoUrl!)
        }else{
            let controller = LightboxController(images: arrayContents, startIndex: self.currentContentIndex)
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnDeleteAction(_ sender:UIButton){
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Delete_Content_Msg , preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            self.hudView.startLoaderWithAnimation()
            let content = self.arrContentData[self.currentContentIndex]
            let contentIds = [content.contentID.trim()]
            if Reachability.isNetworkAvailable() {
                APIServiceManager.sharedInstance.apiForDeleteContent(contents: contentIds) { (isSuccess, errorMsg) in
                    self.hudView.stopLoaderWithAnimation()
                    if isSuccess == true {
//                        ContentList.sharedInstance.arrayContent.remove(at: self.currentContentIndex)
                        self.arrContentData.remove(at: self.currentContentIndex)
                        NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Stream_Content), object: nil)
                        if(self.arrContentData.count == 0){
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        if(self.currentContentIndex != 0){
                            self.currentContentIndex = self.currentContentIndex - 1
                        }
                        self.loadViewForUI()
                    } else {
                        self.showToastIMsg(type: .error, strMSG: errorMsg!)
                    }
                }
            }
            else {
                self.hudView.stopLoaderWithAnimation()
                self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
            }
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func btnEditAction(_ sender:UIButton){
        
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Edit_Content , preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
            let content = self.arrContentData[self.currentContentIndex]
            let strUrl = "\(kDeepLinkURL)\(self.currentStreamID!)/\(content.contentID!)/\(kDeepLinkTypeEditContent)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func sendMessage(){
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = lblStreamName.text!
        layout.image  = imgStream.image
        layout.subcaption = lblStreamDesc.text
        let content = self.arrContentData[currentContentIndex]
        message.layout = layout
        message.url = URL(string: "\(kNavigation_Content)/\(content.contentID!)/\(currentStreamID!)")
        SharedData.sharedInstance.savedConversation?.insert(message, completionHandler: nil)
        self.view.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
extension StreamContentViewController:SFSafariViewControllerDelegate {
    func openURL(url:URL) {
        
        if #available(iOS 9.0, *) {
            let safariController = SFSafariViewController(url: url as URL)
            safariController.delegate = self
            
            let navigationController = UINavigationController(rootViewController: safariController)
            navigationController.setNavigationBarHidden(true, animated: false)
            self.present(navigationController, animated: true, completion: nil)
        } else {
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    @available(iOS 9.0, *)
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
