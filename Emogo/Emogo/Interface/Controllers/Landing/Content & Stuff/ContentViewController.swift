//
//  ContentCollectionViewController.swift
//  Emogo
//
//  Created by Pushpendra on 14/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import MessageUI
import Messages
import Lightbox
import Photos
import IQKeyboardManagerSwift


protocol ContentViewControllerDelegate {
    func updateViewCount(count:String)
}

class ContentViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomToolBarView: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var kEditWidthConstraint: UIButton!
    @IBOutlet weak var btnLikeDislike: UIButton!
    @IBOutlet weak var btnAddToEmogo: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnOther: UIButton!

    let cellIdentifier = "contentViewCell"
    var seletedImage:ContentDAO!
    var isForEditOnly:Bool!
    var isEdit:Bool!
    var photoEditor:PhotoEditorViewController!
    let shapes = ShapeDAO()
    var currentIndex:Int!
    var isViewCount:String?
    var isFromAll:String?
    var isFromViewStream:Bool! = true
    var delegate:ContentViewControllerDelegate?
    var isProfile:String?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.isHidden = true
        deeplinkHandle()
        
        updateContent()
        
        if self.currentIndex != nil{
            let temp = ContentList.sharedInstance.arrayContent[self.currentIndex]
            if temp.type == .video {
                let videoUrl = URL(string: temp.coverImage)
                LightboxConfig.handleVideo(self, videoUrl!)
            }
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.collectionView.addGestureRecognizer(swipeDown)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kDeepLinkContentAdded)), object: nil)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kDeepLinkContentAdded), object: nil, queue: nil) { (notification) in
            SharedData.sharedInstance.deepLinkType = ""
            ContentList.sharedInstance.arrayContent.removeAll()
            ContentList.sharedInstance.arrayContent = SharedData.sharedInstance.contentList.arrayContent
            self.currentIndex = 0
             self.updateContent()
            
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.isNavigationBarHidden = true
        self.collectionView.reloadData()
        bottomToolBarView.backgroundColor = UIColor.clear
        if #available(iOS 11, *), UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            bottomToolBarView.backgroundColor = UIColor.black
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.reloadData()
        updateCollectionView()
        self.collectionView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateContent(){
        btnOther.isHidden = false
        self.btnLikeDislike.isHidden = false
        btnOther.isHidden = false
        if currentIndex != nil {
            let isIndexValid = ContentList.sharedInstance.arrayContent.indices.contains(currentIndex)
            if isIndexValid {
                seletedImage = ContentList.sharedInstance.arrayContent[currentIndex]
            }
        }
        if seletedImage == nil {
            return
        }
        if seletedImage.likeStatus == 0 {
            self.btnLikeDislike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        }else{
            self.btnLikeDislike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        }
        self.collectionView.reloadData()
        btnAddToEmogo.isHidden = true
        btnShare.isHidden = true
        btnSave.isHidden = true
        if self.seletedImage.isShowAddStream {
            btnAddToEmogo.isHidden = false
            btnShare.isHidden = false
            btnSave.isHidden = false
        }
        self.btnEdit.isHidden = true
        if seletedImage.isEdit {
            self.btnEdit.isHidden = false
        }
        
        if isFromViewStream == false {
            if isViewCount != nil && seletedImage.fileName != "SreamCover"{
                apiForIncreaseViewCount()
            }
        }
        isFromViewStream = false
     
        if seletedImage.fileName == "SreamCover" {
            self.btnLikeDislike.isHidden = true
            btnOther.isHidden = true
        }
        
         if  SharedData.sharedInstance.deepLinkType == kDeepLinkShareEditContent {
             self.btnAddToEmogo.isHidden = false
             self.btnSave.isHidden = false
             self.btnShare.isHidden = false
        }
    }
    
    func deeplinkHandle(){
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
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = false
            self.showToast(strMSG: "Please while wait content is upload...")
        }
        self.updateContent()
       
    }
    
    func updateCollectionView(){
        let indexPath = IndexPath(row: currentIndex, section: 0)
       collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
    }
    
    
    
    @IBAction func btnShowReportListAction(_ sender: Any){
        if seletedImage.isDelete {
            self.showDelete()
            return
        }
        if self.seletedImage?.createdBy.trim() != UserDAO.sharedInstance.user.userId.trim(){
            self.showReport()
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        ContentList.sharedInstance.objStream = nil
        if isProfile != nil  {
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isSelected == true }
            ContentList.sharedInstance.arrayContent = array
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        if self.seletedImage != nil {
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
    
    @IBAction func btnLikeDislikeAction(_ sender: Any) {
        
        if seletedImage.likeStatus == 0{
            seletedImage.likeStatus = 1
        }else{
            seletedImage.likeStatus = 0
        }
        self.likeDislikeContent()
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        self.saveActionSheet()
    }
    
    @IBAction func btnActionShare(_ sender: Any) {
        if self.seletedImage.type == .link {
            SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImageVideo) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.shareSticker(image: image)
                    }
                }
            }
        } else {
            SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImage) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.shareSticker(image: image)
                    }
                    
                }
            }
    }
    }
    
    func shareSticker(image:UIImage){
        if MFMessageComposeViewController.canSendAttachments(){
            let composeVC = MFMessageComposeViewController()
            composeVC.recipients = []
            composeVC.message = composeMessage(image: image)
            composeVC.messageComposeDelegate = self
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    func composeMessage(image:UIImage) -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = self.seletedImage.name!
        layout.image  = image
        layout.subcaption = self.seletedImage.description
        let content = self.seletedImage
        message.layout = layout
        if ContentList.sharedInstance.objStream == nil {
            let strURl = kNavigation_Content + (content?.contentID!)!
            message.url = URL(string: strURl)
        }else {
            let strURl = kNavigation_Content + (content?.contentID!)! + ContentList.sharedInstance.objStream!
            message.url = URL(string: strURl)
        }
        
        return message
    }
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.down:
                ContentList.sharedInstance.objStream = nil
                if isProfile != nil  {
                    let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isSelected == true }
                    ContentList.sharedInstance.arrayContent = array
                }
                self.dismiss(animated: true, completion: nil)
            break
                
            default:
                break
            }
            }
        }
    
  
    
    
    @IBAction func btnActionAddStream(_ sender: Any) {
        let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
        obj.objContent = seletedImage
        obj.streamID =  ContentList.sharedInstance.objStream
        self.navigationController?.push(viewController: obj)
    }
    

    func showReport(){
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
    
    func showDelete(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: kAlertDelete_Content, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
           
            if self.isViewCount != nil {
                self.deleteContentFromStream()
            }else {
                self.deleteContent()
            }
        })
        
        let cancelAction = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func saveActionSheet(){
        
        let optionMenu = UIAlertController(title: kSaveAlertTitle, message: nil, preferredStyle: .actionSheet)
        let saveToMyStuffAction = UIAlertAction(title: kAlertSheet_SaveToMyStuff, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.saveToMyStuff()
        })
        
        let saveToGalleryAction = UIAlertAction(title: kAlertSheet_SaveToGallery, style: .default, handler: {
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
        
                SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImageVideo, handler: { (image) in
                    HUDManager.sharedInstance.hideHUD()
                    if image != nil {
                        UIImageWriteToSavedPhotosAlbum(image!
                            ,self, #selector(self.image(_:withPotentialError:contextInfo:)
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
                            ,self, #selector(self.image(_:withPotentialError:contextInfo:)
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
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        self.showToast(type: .error, strMSG: kAlert_Save_Image)
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
        }else if seletedImage.type == .notes {
            let controller:CreateNotesViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_CreateNotesView) as! CreateNotesViewController
            controller.contentDAO = self.seletedImage
            controller.delegate = self
            self.navigationController?.pushNormal(viewController: controller)
        }
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
    
    
    
    
    //MARK: ⬇︎⬇︎⬇︎ API Methods ⬇︎⬇︎⬇︎
    
    func deleteContent(){
        HUDManager.sharedInstance.showHUD()
        let content = [seletedImage.contentID.trim()]
        APIServiceManager.sharedInstance.apiForDeleteContent(contents: content) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true {
                self.deleteFileFromAWS(content: self.seletedImage)
                
                if ContentList.sharedInstance.arrayStuff.count != 0 {
                    let objTemp = ContentList.sharedInstance.arrayContent[self.currentIndex]
                    for (index,obj) in ContentList.sharedInstance.arrayStuff.enumerated() {
                        if obj.contentID.trim() == objTemp.contentID.trim() {
                            ContentList.sharedInstance.arrayStuff.remove(at: index)
                        }
                    }
                }
            NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier), object: "Delete")

                
                if self.isFromAll != nil {
                    ContentList.sharedInstance.arrayStuff.remove(at: self.currentIndex)
                }
                if self.isEdit == nil {
                    let isIndexValid = ContentList.sharedInstance.arrayContent.indices.contains(self.currentIndex)
                    if isIndexValid {
                        ContentList.sharedInstance.arrayContent.remove(at: self.currentIndex)
                    }
                    if  ContentList.sharedInstance.arrayContent.count == 0 {
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                    self.currentIndex =  self.currentIndex - 1
                    if self.currentIndex < 0 {
                        self.currentIndex = 0
                    }
                    self.updateCollectionView()
                    self.updateContent()
                }else {
                    if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
                        ContentList.sharedInstance.arrayContent.remove(at: index)
                        self.dismiss(animated: true, completion: nil)
                    }
                    if self.isForEditOnly != nil {
                        self.dismiss(animated: true, completion: nil)
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
                if self.isViewCount != nil {
                    NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Image_Cover), object: nil)
                }
               
                
                ContentList.sharedInstance.arrayContent.remove(at: self.currentIndex)
                self.currentIndex =  self.currentIndex - 1
                
                 if self.currentIndex < 0 {
                    self.currentIndex = 0
                 }
                    self.updateCollectionView()
                    self.updateContent()
                let array =  ContentList.sharedInstance.arrayContent.filter { $0.fileName != "SreamCover" }
                
                if  array.count == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.dismiss(animated: true, completion: nil)
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
            APIServiceManager.sharedInstance.apiForIncreaseStreamViewCount(streamID: streamID) { (count, _) in
                if self.delegate != nil {
                    self.delegate?.updateViewCount(count: count!)
                }
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
        
        if self.seletedImage.type == .notes {
            self.notePreview()
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
            controller.pageDelegate = self
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
    
    func notePreview(){
        let obj:NotesPreviewViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: "notesPreviewView") as! NotesPreviewViewController
        obj.contentDAO = self.seletedImage
        self.navigationController?.pushAsPresent(viewController: obj)
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

extension ContentViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
            return ContentList.sharedInstance.arrayContent.count
    }
    
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ContentViewCell
        let content =  ContentList.sharedInstance.arrayContent[indexPath.row]
       
        cell.prepareView(seletedImage: content)
        cell.btnPlayIcon.tag = indexPath.row
        cell.btnPlayIcon.addTarget(self, action: #selector(self.openFullView), for: .touchUpInside)
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kFrame.size.width, height: self.collectionView.frame.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.openFullView()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        self.currentIndex = indexPath.row
        self.updateContent()
        print(indexPath)
    }
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

extension ContentViewController:CreateNotesViewControllerDelegate
{
    
    func updatedNotes(content:ContentDAO) {
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        self.seletedImage = content
        if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
            ContentList.sharedInstance.arrayContent [index] = seletedImage
        }
        self.updateContent()
    }
    
}

extension ContentViewController:LightboxControllerPageDelegate {
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int){
       //   self.currentIndex = controller.currentPage
         print(page)
      //   self.updateContent()
     //   self.updateCollectionView()
    }
}

extension ContentViewController:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}


