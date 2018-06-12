//
//  ContentViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import MessageUI
import Messages
import Lightbox
import Photos
import IQKeyboardManagerSwift

class ContentViewController: UIViewController {
    
    
    // MARK: - UI Elements
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var lblTitleImage: UILabel!
    @IBOutlet weak var lblImageDescription: UILabel!
    @IBOutlet weak var btnShareAction: UIButton!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var btnFlagIcon: UIButton!
    @IBOutlet weak var btnAddToStream: UIButton!
    @IBOutlet weak var kHeight: NSLayoutConstraint!
    @IBOutlet weak var viewOption: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnLikeDislike: UIButton!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var kTitleHeight: NSLayoutConstraint!
    
   
    
    var currentIndex:Int!
    var seletedImage:ContentDAO!
    var objstream:StreamViewDAO!
    let shapes = ShapeDAO()
    var isEdit:Bool!
    var isAddStream:Bool! = false
    var isEditngContent:Bool! = false
    var isForEditOnly:Bool!
    var isFromAll:String?
    var isMoreTapped:Bool! = false
    var photoEditor:PhotoEditorViewController!
    var isViewCount:String?
    var stretchyHeader: StreamViewHeader!
    var streamDelegate:StreamViewHeaderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.prepareLayout()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.isNavigationBarHidden = false
        self.hideStatusBar()
        self.prepareNavBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showStatusBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - PrepareLayout
    
    func prepareLayout() {
        self.view.backgroundColor = .black
        
        if  SharedData.sharedInstance.deepLinkType == kDeepLinkTypeShareMessage {
            ContentList.sharedInstance.arrayContent.removeAll()
            ContentList.sharedInstance.arrayContent = SharedData.sharedInstance.contentList.arrayContent
            ContentList.sharedInstance.objStream = nil
            SharedData.sharedInstance.contentList.objStream = nil
            let conten = ContentList.sharedInstance.arrayContent[0]
            
            if conten.name.count > 75 {
                conten.name = conten.name.trim(count: 75)
            }
            if conten.description.count > 250 {
                conten.description = conten.description.trim(count: 250)
            }
            
            self.seletedImage = SharedData.sharedInstance.contentList.arrayContent[0]
            ContentList.sharedInstance.arrayContent.removeAll()
            ContentList.sharedInstance.arrayContent.append(conten)
            let arrayC = [String]()
            let array = ContentList.sharedInstance.arrayContent.filter { $0.isUploaded == false }
            AWSRequestManager.sharedInstance.startContentUpload(StreamID: arrayC, array: array)
            SharedData.sharedInstance.deepLinkType = ""
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = false
            self.showToast(strMSG: "Please while wait content is upload...")
            SharedData.sharedInstance.deepLinkType = ""
        }
        
        let tapLbl = UITapGestureRecognizer.init(target: self, action: #selector(self.lblTapAction(recognizer:)))
        tapLbl.numberOfTapsRequired = 1
        self.lblTitleImage.isUserInteractionEnabled = true
        self.lblTitleImage.addGestureRecognizer(tapLbl)
        
        let imgTap = UITapGestureRecognizer.init(target: self, action: #selector(self.imgTap(recognizer:)))
        imgTap.numberOfTapsRequired = 1
        self.imgCover.isUserInteractionEnabled = true
        self.imgCover.addGestureRecognizer(imgTap)
        
        
        if self.isEdit == nil {
            imgCover.isUserInteractionEnabled = true
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            imgCover.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            imgCover.addGestureRecognizer(swipeLeft)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeDown.direction = UISwipeGestureRecognizerDirection.down
            imgCover.addGestureRecognizer(swipeDown)
            
        }else {
            self.btnAddToStream.isHidden = true
        }
        
        self.imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 1
        self.imgCover.addGestureRecognizer(tap)
        
        if self.currentIndex != nil{
            let temp = ContentList.sharedInstance.arrayContent[self.currentIndex]
            if temp.type == .video {
                let videoUrl = URL(string: temp.coverImage)
                LightboxConfig.handleVideo(self, videoUrl!)
            }
        }
        
        self.updateContent()
        if  SharedData.sharedInstance.deepLinkType == kDeepLinkTypeShareMessage {
            self.btnAddToStream.isHidden = true
            self.btnFlagIcon.isHidden = true
            SharedData.sharedInstance.deepLinkType = ""
        }
        
    }
    
    @objc func lblTapAction(recognizer: UITapGestureRecognizer) {
        if self.seletedImage?.createdBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            self.lblTitleImage.isHidden = true
        }
    }
    
    
    @objc func imgTap(recognizer: UITapGestureRecognizer){
        self.lblTitleImage.isHidden = false
        self.view.endEditing(true)
    }
    
    
    func prepareNavBarButtons(){
        
        self.navigationController?.isNavigationBarHidden = false
        //        self.navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //        self.navigationController?.navigationBar.shadowImage = UIImage()
        //        self.navigationController?.navigationBar.isTranslucent = true
        //        self.navigationController?.navigationBar.barTintColor = .clear
        //        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = .white
        
        //        let btnBack = UIBarButtonItem(image: #imageLiteral(resourceName: "back-circle-icon"), style: .plain, target: self, action: #selector(self.btnBackAction(_:)))
        
        let button = self.getShadowButton(Alignment: 0)
        // button.setBackgroundImage(#imageLiteral(resourceName: "back-circle-icon"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "back icon_shadow"), for: .normal)
        button.addTarget(self, action: #selector(self.btnBackAction(_:)), for: .touchUpInside)
        let btnBack = UIBarButtonItem.init(customView: button)
        
        self.navigationItem.leftBarButtonItem = btnBack
        
        
        if seletedImage.likeStatus == 0 {
            self.btnLikeDislike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        }else{
            self.btnLikeDislike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        }
    }
    
    func updateContent() {
        
        self.imgCover.image = nil
        self.imgCover.animatedImage = nil
        print(currentIndex)
        if self.isEdit == nil {
            seletedImage = ContentList.sharedInstance.arrayContent[currentIndex]
        }
        self.lblTitleImage.text = ""
        self.lblImageDescription.text = ""
        if  seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }
        
        
        if seletedImage.type == .image || seletedImage.type == .gif {
            self.btnPlayIcon.isHidden = true
        }else {
            self.btnPlayIcon.isHidden = true
        }
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
            seletedImage.imgPreview?.getColors({ (colors) in
                self.imgCover.backgroundColor = colors.primary
                
            })
        }else {
            if seletedImage.type == .image {
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImage)
                
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImage, handler: { (image) in
                    
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.primary
                    })
                })
                
                self.btnPlayIcon.isHidden = true
            }else   if seletedImage.type == .video {
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.primary
                    })
                })
                self.btnPlayIcon.isHidden = false
            }else if seletedImage.type == .link {
                self.btnPlayIcon.isHidden = true
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.primary
                    })
                })
            }else {
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.primary
                    })
                })
            }
        }
        
        if self.seletedImage.isEdit == false {
            self.btnFlagIcon.isHidden = false
        }else {
            self.btnFlagIcon.isHidden = true
        }
        
        isAddStream = self.seletedImage.isShowAddStream
        if self.isAddStream {
            btnAddToStream.isHidden = false
        }else {
            btnAddToStream.isHidden = true
        }
        
        if self.seletedImage.isShowAddStream == false && self.seletedImage.isEdit == false {
            kHeight.constant = 0.0
            self.viewOption.isHidden = true
        }else {
            kHeight.constant = 48.0
            self.viewOption.isHidden = false
        }
        
        if SharedData.sharedInstance.deepLinkType != "" {
            if self.seletedImage.imgPreview == nil {
                SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImage, handler: { (image) in
                    if image != nil {
                        self.openEditor(image:image!)
                    }
                })
            }else {
                self.openEditor(image:seletedImage.imgPreview!)
            }
            SharedData.sharedInstance.deepLinkType = ""
        }
        
        if self.seletedImage?.createdBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            self.btnFlagIcon.isHidden = true
        }else{
            self.btnFlagIcon.isHidden = false
        }
        self.imgCover.contentMode = .scaleAspectFit
        self.btnFlagIcon.isHidden = true
        self.changeButtonAccordingSwipe(selected: seletedImage)
        if !seletedImage.createrImage.trim().isEmpty {
            self.imgUser.setImageWithResizeURL(seletedImage.createrImage.trim())
        }
        else {
            self.imgUser.setImage(string:seletedImage.fullname.trim(), color: UIColor.colorHash(name:seletedImage.fullname.trim() ), circular: true)
        }
        self.imgUser.isHidden = true
        // disable Like Unlike and save icon
        self.btnMore.isHidden = true
        if isViewCount != nil {
            apiForIncreaseViewCount()
        }
        self.lblTitleImage.addShadow()
        self.lblImageDescription.addShadow()
        self.kTitleHeight.constant = 24.0
        self.lblImageDescription.isHidden = false
        self.lblTitleImage.isHidden = false
        if seletedImage.name.trim().isEmpty {
            self.kTitleHeight.constant = 0.0
            self.lblTitleImage.isHidden = true
        
        }else {
            self.lblTitleImage.text = seletedImage.name.trim()
        }
        if seletedImage.description.trim().isEmpty {
            self.lblImageDescription.isHidden = true
        }else {
            self.lblImageDescription.numberOfLines = 0

           self.lblImageDescription.text = seletedImage.description.trim()
            let lines = self.lblImageDescription.numberOfVisibleLines
            if lines > 2 {
                self.btnMore.isHidden = false
            }else {
                self.btnMore.isHidden = true
            }
            self.lblImageDescription.numberOfLines = 2
        }
        
    }
    
    
    func changeButtonAccordingSwipe(selected:ContentDAO){
        //editing_cross_icon
        self.navigationItem.setRightBarButtonItems([], animated: true)
        
        //        var imgEdit = #imageLiteral(resourceName: "edit_icon")
        var arrButtons = [UIBarButtonItem]()
        
        if selected.isUploaded {
            if selected.isEdit {
                if selected.type == .image ||  selected.type == .video ||  selected.type == .link  {
                    let buttonEdit = self.getShadowButton(Alignment: 1)
                    buttonEdit.setImage(#imageLiteral(resourceName: "edit icon_new"), for: .normal)
                    buttonEdit.addTarget(self, action: #selector(self.btnEditAction(_:)), for: .touchUpInside)
                    let btnEdit = UIBarButtonItem.init(customView: buttonEdit)
                    
                    arrButtons.append(btnEdit)
                    
                }
            }else {
                if self.seletedImage?.createdBy.trim() != UserDAO.sharedInstance.user.userId.trim(){
                    let buttonFlag = self.getShadowButton(Alignment: 2)
                    buttonFlag.setImage(#imageLiteral(resourceName: "more icon"), for: .normal)
                    buttonFlag.addTarget(self, action: #selector(self.btnShowReportListAction(_:)), for: .touchUpInside)
                    let btnFlag = UIBarButtonItem.init(customView: buttonFlag)
                    arrButtons.append(btnFlag)
                    
                }
            }
            
           
            
            if selected.isDelete {
                //                let imgDelete = #imageLiteral(resourceName: "delete_icon-cover_image")
                //                let btnDelete = UIBarButtonItem(image: imgDelete, style: .plain, target: self, action: #selector(self.btnDeleteAction(_:)))
                
                let buttonLink = self.getShadowButton(Alignment: 1)
                // buttonLink.setBackgroundImage(#imageLiteral(resourceName: "delete_new"), for: .normal)
                buttonLink.setImage(#imageLiteral(resourceName: "delete icon_new"), for: .normal)
                buttonLink.addTarget(self, action: #selector(self.btnDeleteAction(_:)), for: .touchUpInside)
                let btnDelete = UIBarButtonItem.init(customView: buttonLink)
                arrButtons.append(btnDelete)
                
            }
            if seletedImage.likeStatus == 0{
                self.btnLikeDislike.setImage(#imageLiteral(resourceName: "Unlike_icon"), for: .normal)
            }else{
                self.btnLikeDislike.setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
            }
        }
        
        /*
         let imgFlag = #imageLiteral(resourceName: "content_flag")
         let btnFlag = UIBarButtonItem(image: imgFlag, style: .plain, target: self, action: #selector(self.btnShowReportListAction(_:)))
         
         if selected.isEdit == true {
         arrButtons.append(btnEdit)
         if selected.isDelete == true {
         arrButtons.append(btnDelete)
         }
         self.navigationItem.setRightBarButtonItems(arrButtons, animated: true)
         }else{
         var arrButtons = [UIBarButtonItem]()
         
         arrButtons.append(btnFlag)
         if selected.isDelete == true {
         arrButtons.append(btnDelete)
         }
         }
         */
        self.navigationItem.setRightBarButtonItems(arrButtons, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: -  Action Methods And Selector
    
    @IBAction func btnShowReportListAction(_ sender: Any){
        let optionMenu = UIAlertController(title: kAlert_Title_ActionSheet, message: "", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: "", stream: "", content: self.seletedImage.contentID!, completionHandler: { (isSuccess, error) in
                
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Content)
                }
            })
        })
        
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: "", stream: "", content: self.seletedImage.contentID!, completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Content)
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        if isForEditOnly == nil {
            ContentList.sharedInstance.objStream = nil
        }
        self.navigationController?.pop()
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        if self.seletedImage != nil {
           if self.seletedImage.type == .image  || self.seletedImage.type == .video || self.seletedImage.type == .link {
                if isEdit != nil {
                    performEdit()
                }else {
                    if   ContentList.sharedInstance.arrayContent.count != 0 {
                        performEdit()
                    }else {
                        self.showToast(type: .error, strMSG: kAlert_Edit_Image)
                    }
                }
            }
            
        }
        
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
        
        layout.caption = lblTitleImage.text!
        layout.image  = imgCover.image
        layout.subcaption = lblImageDescription.text
        
        message.layout = layout
        if ContentList.sharedInstance.objStream == nil {
            let strURl = String(format: "%@/%@", kNavigation_Content,seletedImage.contentID)
            message.url = URL(string: strURl)
        }else {
            let strURl = String(format: "%@/%@/%@", kNavigation_Content,seletedImage.contentID,ContentList.sharedInstance.objStream!)
            message.url = URL(string: strURl)
        }
        
        return message
    }
    
    
    @IBAction func btnActionAddStream(_ sender: Any) {
        let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
        obj.objContent = seletedImage
        obj.streamID =  ContentList.sharedInstance.objStream
        self.navigationController?.push(viewController: obj)
    }
    
    
    @IBAction func btnPlayAction(_ sender: Any) {
        self.openFullView()
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
        if isEdit != nil {
            performDelete()
        }else {
            if  ContentList.sharedInstance.arrayContent.count != 0 {
                performDelete()
            }
        }
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        self.SaveActionSheet()
        
    }
    
    @IBAction func btnLikeDislikeAction(_ sender: Any) {
        
        if seletedImage.likeStatus == 0{
            seletedImage.likeStatus = 1
        }else{
            seletedImage.likeStatus = 0
        }
        self.likeDislikeContent()
    }
    
    @IBAction func btnMoreAction(_ sender: Any) {
        isMoreTapped = !isMoreTapped
        if isMoreTapped {
            self.lblImageDescription.text = self.seletedImage.description.trim()
            self.lblImageDescription.numberOfLines = 0
        }else {
            self.lblImageDescription.text = self.seletedImage.description.trim()
            self.lblImageDescription.numberOfLines = 3
        }
    }
    
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        self.showToast(type: .error, strMSG: kAlert_Save_Image)
    }
    
    //MARK:- Video Download
    @objc func videoDownload(){
        
        
        APIManager.sharedInstance.download(strFile: self.seletedImage.coverImage) { (_, fileURL) in
            if let fileURL = fileURL {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:fileURL)
                }) { completed, error in
                    if completed {
                        print("Video is saved!")
                        self.showToast(type: AlertType.success, strMSG: kAlert_Save_Video)
                    }
                }
            }
        }
        
    }
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .left:
                if currentIndex !=  ContentList.sharedInstance.arrayContent.count-1 {
                    if !self.isEditngContent {
                        self.next()
                    }else{
                        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_For_Edit_Content, preferredStyle: .alert)
                        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
                            self.next()
                            self.isEditngContent = false
                        }
                        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(yes)
                        alert.addAction(no)
                        present(alert, animated: true, completion: nil)
                    }
                }
                break
                
            case .right:
    
                if currentIndex != 0 {
                    if !self.isEditngContent {
                        self.previous()
                    }else{
                        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_For_Edit_Content, preferredStyle: .alert)
                        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
                            self.previous()
                            self.isEditngContent = false
                        }
                        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(yes)
                        alert.addAction(no)
                        present(alert, animated: true, completion: nil)
                    }
                    
                }
                break
                
            case .down:
                self.navigationController?.popViewAsDismiss()
                
                break
            default:
                break
            }
        }
    }
    func SaveActionSheet(){
        
        let optionMenu = UIAlertController(title: kAlert_Message, message: "", preferredStyle: .actionSheet)
        let saveToMyStuffAction = UIAlertAction(title: kAlertSheet_SaveToMyStuff, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.saveToMyStuff()
        })
        
        let saveToGalleryAction = UIAlertAction(title: kAlertSheet_SaveToGallery, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            if self.seletedImage.type == .image {
                if self.seletedImage.imgPreview == nil {
                    HUDManager.sharedInstance.showHUD()
                    SharedData.sharedInstance.downloadFile(strURl: self.seletedImage.coverImage, handler: { (image,_) in
                        HUDManager.sharedInstance.hideHUD()
                        if image != nil {
                            UIImageWriteToSavedPhotosAlbum(image!
                                ,self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)
                                ), nil)
                            self.showToast(type: AlertType.success, strMSG: kAlert_Save_Image)
                        }
                    })
                }
                
            }else if self.seletedImage.type == .video{
                self.videoDownload()
                
            }else if self.seletedImage.type == .gif{
                
                self.imgCover.setForAnimatedImage(strImage:self.seletedImage.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImageVideo, handler: { (image) in
                    HUDManager.sharedInstance.hideHUD()
                    if image != nil {
                        UIImageWriteToSavedPhotosAlbum(image!
                            ,self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)
                            ), nil)
                        self.showToast(type: AlertType.success, strMSG: kAlert_Save_GIF)
                    }
                })
            }else if self.seletedImage.type == .link{
                
                //  self.imgCover.setForAnimatedImage(strImage:self.seletedImage.coverImage)
                SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImageVideo, handler: { (image) in
                    HUDManager.sharedInstance.hideHUD()
                    if image != nil {
                        UIImageWriteToSavedPhotosAlbum(image!
                            ,self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)
                            ), nil)
                        self.showToast(type: AlertType.success, strMSG: kAlert_Save_Link)
                    }
                })
            }
        })
        let cancelAction = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(saveToMyStuffAction)
        optionMenu.addAction(saveToGalleryAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func next() {
        self.imgCover.backgroundColor = .black
        if(currentIndex < ContentList.sharedInstance.arrayContent.count-1) {
            currentIndex = currentIndex + 1
        }
        Animation.addRightTransitionImage(imgV: self.imgCover)
        updateContent()
    }
    
    func previous() {
        self.imgCover.backgroundColor = .black
        if currentIndex != 0{
            currentIndex =  currentIndex - 1
        }
        Animation.addLeftTransitionImage(imgV: self.imgCover)
        updateContent()
    }
    
    func performEdit(){
        if seletedImage.type == .image {
            if self.seletedImage.imgPreview == nil {
                HUDManager.sharedInstance.showHUD()
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImage, handler: { (image) in
                    HUDManager.sharedInstance.hideHUD()
                    if image != nil {
                        self.openEditor(image:image!)
                    }
                })
              
            }else {
                self.openEditor(image:seletedImage.imgPreview!)
            }
        }else if seletedImage.type == .video {
            AppDelegate.appDelegate.keyboardResign(isActive: false)
            let objVideoEditor:VideoEditorViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_VideoEditorView) as! VideoEditorViewController
            objVideoEditor.delegate = self
            objVideoEditor.seletedImage = self.seletedImage
            self.navigationController?.pushAsPresent(viewController: objVideoEditor)
        }else if seletedImage.type == .link {
            HUDManager.sharedInstance.showHUD()
            print(self.seletedImage.coverImageVideo)
            SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                HUDManager.sharedInstance.hideHUD()
                if image != nil {
                    self.openEditor(image:image!)
                }
            })
        }
    }
    
    
    func performDelete(){
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Delete_Content_Msg, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
            self.deleteSelectedContent()
        }
        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    private func openEditor(image:UIImage){
        AppDelegate.appDelegate.keyboardResign(isActive: false)
        photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.image = image
        photoEditor.isForEditOnly = true
        photoEditor.seletedImage = self.seletedImage
        //PhotoEditorDelegate
        photoEditor.photoEditorDelegate = self
        photoEditor.hiddenControls = [.share]
        photoEditor.stickers = shapes.shapes
        photoEditor.colors = [.red,.blue,.green, .black, .brown, .cyan, .darkGray, .yellow, .lightGray, .purple , .groupTableViewBackground]
        self.navigationController?.pushAsPresent(viewController: photoEditor)
    }
    
    func deleteSelectedContent(){
        if !self.seletedImage.contentID.trim().isEmpty {
            if ContentList.sharedInstance.objStream != nil {
                self.deleteContentFromStream()
            }else {
                self.deleteContent()
            }
        }else {
            ContentList.sharedInstance.arrayContent.remove(at: self.currentIndex)
            self.currentIndex =  self.currentIndex - 1
            if(self.currentIndex < ContentList.sharedInstance.arrayContent.count-1) {
                self.next()
            }else {
                self.previous()
            }
            if  ContentList.sharedInstance.arrayContent.count == 0 {
                self.navigationController?.pop()
            }
        }
    }
    
    
    @objc func openFullView(){
        if self.seletedImage.type == .gif {
            self.gifPreview()
            return
        }
        if seletedImage.type == .link {
            guard let url = URL(string: seletedImage.coverImage) else {
                return //be safe
            }
            self.openURL(url: url)
            return
        }
        var arrayContents = [LightboxImage]()
        var index:Int! = 0
        var arrayTemp = [ContentDAO]()
        
        if isEdit == nil {
            index = self.currentIndex
            arrayTemp = ContentList.sharedInstance.arrayContent
        }else{
            arrayTemp.append(seletedImage)
        }
        for obj  in arrayTemp {
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
                    if let url = url, let videoUrl = videoUrl {
                        image = LightboxImage(imageURL: url, text: text.trim(), videoURL: videoUrl)
                    }
                    
                }
            }
            if image != nil {
                arrayContents.append(image)
                if obj.contentID == seletedImage.contentID {
                    index = arrayContents.count - 1
                }
            }
        }
        
        if seletedImage.type == .video {
            if self.currentIndex == nil {
                let videoUrl = URL(string: self.seletedImage.coverImage)
                if let videoUrl = videoUrl {
                    LightboxConfig.handleVideo(self, videoUrl)
                }
            }else {
                let temp = ContentList.sharedInstance.arrayContent[self.currentIndex]
                let videoUrl = URL(string: temp.coverImage)
                LightboxConfig.handleVideo(self, videoUrl!)
            }
            
        }else{
            let controller = LightboxController(images: arrayContents, startIndex: index)
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func gifPreview(){
        let obj:ShowPreviewViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ShowPreviewView) as! ShowPreviewViewController
        obj.objContent = self.seletedImage
        self.present(obj, animated: false, completion: nil)
    }
    func deleteContent(){
        HUDManager.sharedInstance.showHUD()
        let content = [seletedImage.contentID.trim()]
        APIServiceManager.sharedInstance.apiForDeleteContent(contents: content) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true {
                self.deleteFileFromAWS(content: self.seletedImage)
                if self.isFromAll != nil {
                    ContentList.sharedInstance.arrayStuff.remove(at: self.currentIndex)
                }
                if self.isEdit == nil {
                    ContentList.sharedInstance.arrayContent.remove(at: self.currentIndex)
                    if  ContentList.sharedInstance.arrayContent.count == 0 {
                        self.navigationController?.pop()
                        return
                    }
                    self.currentIndex =  self.currentIndex - 1
                    if(self.currentIndex < ContentList.sharedInstance.arrayContent.count-1) {
                        self.next()
                    }else {
                        self.previous()
                    }
                }else {
                    if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
                        ContentList.sharedInstance.arrayContent.remove(at: index)
                        self.navigationController?.pop()
                    }
                    if self.isForEditOnly != nil {
                        self.navigationController?.pop()
                    }
                }
                
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func deleteContentFromStream(){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForDeleteContentFromStream(streamID: ContentList.sharedInstance.objStream!, contentID: seletedImage.contentID.trim()) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true {
                if self.isEdit == nil {
                    ContentList.sharedInstance.arrayContent.remove(at: self.currentIndex)
                    if  ContentList.sharedInstance.arrayContent.count == 0 {
                        self.navigationController?.pop()
                        return
                    }
                    self.currentIndex =  self.currentIndex - 1
                    if(self.currentIndex < ContentList.sharedInstance.arrayContent.count-1) {
                        self.next()
                    }else {
                        self.previous()
                    }
                }else {
                    if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
                        ContentList.sharedInstance.arrayContent.remove(at: index)
                        self.navigationController?.pop()
                    }
                    if self.isForEditOnly != nil {
                        self.navigationController?.pop()
                    }
                    
                }
                
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func deleteFileFromAWS(content:ContentDAO){
        if !content.coverImage.isEmpty {
            AWSManager.sharedInstance.removeFile(name: content.coverImage.getName(), completion: { (isDeleted, error) in
            })
        }
        if !content.coverImageVideo.isEmpty {
            AWSManager.sharedInstance.removeFile(name: content.coverImageVideo.getName(), completion: { (isDeleted, error) in
            })
        }
    }
    
    //MARK:- Like Dislike Content
    
    func likeDislikeContent(){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForLikeDislikeContent(content: self.seletedImage.contentID, status:self.seletedImage.likeStatus)  { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true {
                if self.seletedImage.likeStatus == 0 {
                    self.btnLikeDislike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                    
                }else{
                    self.btnLikeDislike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                }
            }else{
                HUDManager.sharedInstance.hideHUD()
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func apiForIncreaseViewCount(){
        if let streamID = ContentList.sharedInstance.objStream {
            APIServiceManager.sharedInstance.apiForIncreaseStreamViewCount(streamID: streamID) { (_, _) in
                
            }
        }
        
    }
    //MARK:- Save Content to My Stuff
    
    func saveToMyStuff(){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForSaveStuffContent(contentID: self.seletedImage.contentID) { (isSuccess, error) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true {
                if self.seletedImage.type == .image {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Save_Image_MyStuff)
                }else  if self.seletedImage.type == .video {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Save_Video_MyStuff)
                }else  if self.seletedImage.type == .gif {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Save_GIF_MyStuff)
                }else  if self.seletedImage.type == .link{
                    self.showToast(type: AlertType.success, strMSG: kAlert_Save_Link_MyStuff)
                }
            }else{
                HUDManager.sharedInstance.hideHUD()
                self.showToast(strMSG: error!)
            }
        }
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


extension ContentViewController:PhotoEditorDelegate
{
    func doneEditing(image: ContentDAO) {
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        self.seletedImage = image
        if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
            ContentList.sharedInstance.arrayContent [index] = seletedImage
        }
        self.updateContent()
    }
    
    
    func canceledEditing() {
        print("Canceled")
        AppDelegate.appDelegate.keyboardResign(isActive: true)
    }
}

extension ContentViewController:VideoEditorDelegate
{
    func cancelEditing() {
        AppDelegate.appDelegate.keyboardResign(isActive: true)
    }
    
    func saveEditing(image: ContentDAO) {
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        self.seletedImage = image
        if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
            ContentList.sharedInstance.arrayContent [index] = seletedImage
        }
        self.updateContent()
    }
    
}


extension ContentViewController:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}



