//
//  StreamContentViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 29/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class StreamContentViewController: MSMessagesAppViewController {
    
    // MARK:- UI Elements
    @IBOutlet weak var lblStreamTitle       : UILabel!
    @IBOutlet weak var lblStreamName        : UILabel!
    @IBOutlet weak var lblStreamDesc        : UILabel!
    
    @IBOutlet  weak var contentProgressView : UIProgressView!
    
    @IBOutlet weak var imgStream            : UIImageView!
    @IBOutlet weak var imgGradient          : UIImageView!
    
    @IBOutlet weak var viewAction           : UIView!
    @IBOutlet weak var viewAddStream        : UIView!
    
    @IBOutlet weak var btnEdit              : UIButton!
    @IBOutlet weak var btnDelete            : UIButton!
    
    
    // MARK: - Variables
    var currentContentIndex                 : Int!
    var currentStreamID                     : String!
    var arrContentData                      = [ContentDAO]()
    var hudView                             : LoadingView!
    // MARK: - Life-cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedData.sharedInstance.tempViewController = self
        setupLoader()
        self.perform(#selector(self.prepareLayout), with: nil, afterDelay: 0.2)
        ContentList.sharedInstance.arrayContent = arrContentData
        requestMessageScreenChangeSize()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentProgressView.transform = CGAffineTransform(scaleX: 1, y: 3)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: iMsgNotificationManageScreen), object: nil)
        DispatchQueue.main.async {
            self.hudView.startLoaderWithAnimation()
        }
    }
    
    // MARK:- Selector Methods
    @objc func requestMessageScreenChangeSize(){
        if(SharedData.sharedInstance.isMessageWindowExpand == false){
            imgStream.isUserInteractionEnabled = false
            viewAddStream.isHidden = true
        }
        else {
            imgStream.isUserInteractionEnabled = true
            viewAddStream.isHidden = false
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
        loadViewForUI()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imgStream.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imgStream.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if currentContentIndex !=  arrContentData.count-1 {
                    DispatchQueue.main.async {
                        self.hudView.startLoaderWithAnimation()
                    }
                    self.perform(#selector(self.nextContentLoad), with: nil, afterDelay: 0.1)
                }
                break
            case UISwipeGestureRecognizerDirection.right:
                if currentContentIndex != 0 {
                    DispatchQueue.main.async {
                        self.hudView.startLoaderWithAnimation()
                    }
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
        let content = self.arrContentData[currentContentIndex]
        self.lblStreamName.text = content.name.trim().capitalized
        btnEdit.isHidden = true
        btnDelete.isHidden = true
        if content.type == .image {
            self.imgStream.setImageWithURL(strImage: content.coverImage, placeholder: "stream-card-placeholder")
        }else{
            if !content.coverImage.isEmpty {
                let url = URL(string: content.coverImage.stringByAddingPercentEncodingForURLQueryParameter()!)
                if  let image = SharedData.sharedInstance.getThumbnailImage(url: url!) {
                    self.imgStream.image = image
                }
            }
        }
        
        lblStreamDesc.text = content.description.trim().capitalized
        let currenProgressValue = Float(currentContentIndex)/Float(arrContentData.count-1)
        contentProgressView.setProgress(currenProgressValue, animated: true)
        
        if content.contentID.trim() == UserDAO.sharedInstance.user.userId.trim(){
            btnEdit.isHidden = false
            btnDelete.isHidden = false
        }
        DispatchQueue.main.async {
            self.hudView.stopLoaderWithAnimation()
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
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationReloadStreamContent), object: nil)
        }
        else {
            SharedData.sharedInstance.iMessageNavigation = ""
              NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationReloadContenData), object: nil)
        }
    }
    
    @IBAction func btnsendAction(_ sender:UIButton){
        if(SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyleCompact), object: nil)
        }
        self.perform(#selector(self.sendMessage), with: nil, afterDelay: 0.1)
    }
    
    @IBAction func btnDeleteAction(_ sender:UIButton){
        let content = self.arrContentData[currentContentIndex]
        let contentIds = [content.contentID.trim()]
        APIServiceManager.sharedInstance.apiForDeleteContent(contents: contentIds) { (isSuccess, errorMsg) in
            if isSuccess == true {
                ContentList.sharedInstance.arrayContent.remove(at: self.currentContentIndex)
                self.arrContentData.remove(at: self.currentContentIndex)
                if(self.arrContentData.count == 0){
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationReloadStreamContent), object: nil)
                    return
                }
                if(self.currentContentIndex != 0){
                    self.currentContentIndex = self.currentContentIndex - 1
                }
                self.loadViewForUI()
            }else {
                
            }
        }
    }
    
    @objc func sendMessage(){
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = lblStreamName.text!
        layout.image  = imgStream.image
        layout.subcaption = lblStreamDesc.text
        let content = self.arrContentData[currentContentIndex]
        message.summaryText = "\(iMsg_NavigationContent) \(content.contentID!) \(currentStreamID!) "
        
        message.layout = layout
        SharedData.sharedInstance.savedConversation?.insert(message, completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func deleteContent(contentObj:ContentDAO){
        
    }
}
