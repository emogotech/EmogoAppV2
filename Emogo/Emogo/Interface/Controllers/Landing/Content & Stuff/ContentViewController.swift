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

class ContentViewController: UIViewController {

    
    // MARK: - UI Elements
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    
    @IBOutlet weak var txtTitleImage: UITextField!
    @IBOutlet weak var txtDescription: MBAutoGrowingTextView!
    @IBOutlet weak var btnShareAction: UIButton!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var btnFlagIcon: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnAddToStream: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var kHeight: NSLayoutConstraint!
    @IBOutlet weak var viewOption: UIView!


    var currentIndex:Int!
    var seletedImage:ContentDAO!
    var photoEditor:PhotoEditorViewController!
    let shapes = ShapeDAO()
    var isEdit:Bool!
    var isAddStream:Bool! = false
    var isEditngContent:Bool! = false
    var isForEditOnly:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         self.prepareLayout()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - PrepareLayout
    
    func prepareLayout() {
         if self.isEdit == nil {
            imgCover.isUserInteractionEnabled = true
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            imgCover.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            imgCover.addGestureRecognizer(swipeLeft)
         }else {
            self.btnAddToStream.isHidden = true
        }
        self.txtTitleImage.maxLength = 50

        self.imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 2
        self.imgCover.addGestureRecognizer(tap)
        txtDescription.delegate = self
        
        if self.currentIndex != nil{
            let temp = ContentList.sharedInstance.arrayContent[self.currentIndex]
            if temp.type == .video {
                let videoUrl = URL(string: temp.coverImage)
                LightboxConfig.handleVideo(self, videoUrl!)
            }
        }
        
      txtTitleImage.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
        self.updateContent()
        
    }
    
    
    func updateContent() {
        self.imgCover.image = nil
        self.imgCover.animatedImage = nil
        if self.isEdit == nil {
            seletedImage = ContentList.sharedInstance.arrayContent[currentIndex]
        }
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
        self.txtDescription.placeholder = "Description"
        self.txtDescription.placeholderColor = .white
        
        if  seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }
        
        self.txtTitleImage.isHidden = true
        self.txtDescription.isHidden = true
        if !seletedImage.name.isEmpty {
            self.txtTitleImage.text = seletedImage.name.trim()
            self.txtTitleImage.isHidden = false
        }
        if !seletedImage.description.isEmpty {
            var description  = seletedImage.description.trim()
            if seletedImage.description.count > 250 {
                description = seletedImage.description.trim(count: 250)
            }
            self.txtDescription.text = description
            print(description)

        }else{
            self.txtDescription.text = ""
        }
        
        
        
        if seletedImage.type == .image || seletedImage.type == .gif {
            self.btnPlayIcon.isHidden = true
            self.btnEdit.isHidden     = false
        }else {
            self.btnPlayIcon.isHidden = true
            self.btnEdit.isHidden     = true
        }
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
            seletedImage.imgPreview?.getColors({ (colors) in
                self.imgCover.backgroundColor = colors.background
                self.txtTitleImage.textColor = .white//colors.secondary
                self.txtDescription.textColor = .white//colors.secondary
                self.txtTitleImage.placeholderColor(text:"Title",color: .white)//colors.secondary
            })
        }else {
            if seletedImage.type == .image {
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImage)
                
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImage, handler: { (image) in
                    
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.background
                        self.txtTitleImage.textColor = .white//colors.secondary

                        self.txtDescription.textColor = .white//colors.secondary
                        self.txtTitleImage.placeholderColor(text:"Title",color: .white)//colors.secondary
                    })
                })
                
                self.btnPlayIcon.isHidden = true
            }else   if seletedImage.type == .video {
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.background
                        self.txtTitleImage.textColor = .white//colors.secondary
                        self.txtDescription.textColor = .white//colors.secondary
                        self.txtTitleImage.placeholderColor(text:"Title",color: .white)//colors.secondary
                    })
                })
                self.btnPlayIcon.isHidden = false
            }else if seletedImage.type == .link {
                self.btnPlayIcon.isHidden = true
          self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.background
                        self.txtTitleImage.textColor = .white//colors.secondary
                        self.txtDescription.textColor = .white//colors.secondary
                        self.txtTitleImage.placeholderColor(text:"Title",color: .white)//colors.secondary
                    })
                })
            }else {
               self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.background
                        self.txtTitleImage.textColor = .white//colors.secondary
                        self.txtDescription.textColor = .white//colors.secondary
                self.txtTitleImage.placeholderColor(text:"Title",color: .white)//colors.secondary
                    })
                })
                
            }
        }
        
        if self.seletedImage.isEdit == false {
            self.btnEdit.isHidden = true
            self.btnDone.isHidden = true
            self.txtTitleImage.isUserInteractionEnabled = false
            self.txtDescription.isUserInteractionEnabled = false
            if self.seletedImage.description.trim().isEmpty {
                self.txtDescription.isHidden = true
            }else{
                self.txtDescription.isHidden = false
            }
            self.btnFlagIcon.isHidden = false
        }else {
            self.btnEdit.isHidden = false
            if isEditngContent {
                self.btnDone.isHidden = false
            }
            else{
                self.btnDone.isHidden = true
            }
            self.txtTitleImage.isHidden = false
            self.txtDescription.isHidden = false

            
            self.txtTitleImage.isUserInteractionEnabled = true
            self.txtDescription.isUserInteractionEnabled = true
            self.btnFlagIcon.isHidden = true
        }
        
        if self.seletedImage.type == .image {
            self.btnEdit.isHidden = false
        }else{
            self.btnEdit.isHidden = true
        }
        
        if self.seletedImage.isDelete == false {
            self.btnDelete.isHidden = true
        }else {
            self.btnDelete.isHidden = false
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
            kHeight.constant = 30.0
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
            self.btnEdit.isHidden = false
        }else{
            self.btnFlagIcon.isHidden = false
            self.btnEdit.isHidden = true
        }
        
        // image aspect ratio----
        self.imgCover.contentMode = .scaleAspectFit

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
        
        layout.caption = txtTitleImage.text!
        layout.image  = imgCover.image
        layout.subcaption = txtDescription.text
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
    
    
    @IBAction func btnActionAddStream(_ sender: Any) {
        
        if isEditngContent {
            
            let alert = UIAlertController(title: kAlert_Confirmation_For_Edit_Content, message: kAlert_Delete_Content_Msg, preferredStyle: .alert)
            let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
                self.txtTitleImage.text = self.seletedImage.name
                self.txtDescription.text = self.seletedImage.description
                let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
                obj.objContent = self.seletedImage
                self.navigationController?.push(viewController: obj)
                self.isEditngContent = false
            }
            let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(yes)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
            
        }
        else{
        let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
        obj.objContent = seletedImage
        obj.streamID =  ContentList.sharedInstance.objStream
        self.navigationController?.push(viewController: obj)
        }
    }
    @IBAction func btnDoneAction(_ sender: Any) {
       // Update Content
        HUDManager.sharedInstance.showHUD()
        if self.seletedImage.imgPreview != nil {
            self.uploadFile()
        }else {
         //   self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: "", type: self.seletedImage.type.rawValue)
            self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: self.seletedImage.coverImageVideo, type: self.seletedImage.type.rawValue, width: self.seletedImage.width, height: self.seletedImage.height)
        }
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
    
    @objc func textFieldDidChange(textfield:UITextField) {
        if txtTitleImage.text?.trim().lowercased() != seletedImage.name.trim().lowercased() || txtDescription.text.trim().lowercased() != seletedImage.description.trim().lowercased() {
            isEditngContent = true
            self.btnDone.isHidden = false
        }else{
            isEditngContent = true
            self.btnDone.isHidden = false
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
                        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
                            self.next()
                            self.isEditngContent = false
                        }
                        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
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
                        let alert = UIAlertController(title: kAlert_Confirmation_For_Edit_Content, message: kAlert_Delete_Content_Msg, preferredStyle: .alert)
                        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
                            self.previous()
                            self.isEditngContent = false
                        }
                        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(yes)
                        alert.addAction(no)
                        present(alert, animated: true, completion: nil)
                    }
                    
                }
                break
                
            default:
                break
            }
        }
    }
    
    func next() {
        if(currentIndex < ContentList.sharedInstance.arrayContent.count-1) {
            currentIndex = currentIndex + 1
        }
        Animation.addRightTransitionImage(imgV: self.imgCover)
        updateContent()
    }
    
    func previous() {
        if currentIndex != 0{
            currentIndex =  currentIndex - 1
        }
        Animation.addLeftTransitionImage(imgV: self.imgCover)
        updateContent()
    }
    
    func performEdit(){
        if seletedImage.type == .image {
            if self.seletedImage.imgPreview == nil {
                SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImage, handler: { (image) in
                    if image != nil {
                        self.openEditor(image:image!)
                    }
                })
            }else {
                self.openEditor(image:seletedImage.imgPreview!)
            }
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
        //PhotoEditorDelegate
        photoEditor.photoEditorDelegate = self
        photoEditor.hiddenControls = [.share]
        photoEditor.stickers = shapes.shapes
        photoEditor.colors = [.red,.blue,.green, .black, .brown, .cyan, .darkGray, .yellow, .lightGray, .purple , .groupTableViewBackground]
        present(photoEditor, animated: true) {
        }
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
                    let url = URL(string: obj.coverImage)
                    let videoUrl = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: videoUrl!)
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
                LightboxConfig.handleVideo(self, videoUrl!)
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
    
    func updateContent(coverImage:String,coverVideo:String, type:String,width:Int,height:Int){
        APIServiceManager.sharedInstance.apiForEditContent(contentID: self.seletedImage.contentID, contentName: txtTitleImage.text!, contentDescription: txtDescription.text!, coverImage: coverImage, coverImageVideo: coverVideo, coverType: type, width: width, height: height) { (content, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                content?.isShowAddStream = self.isAddStream
                if self.isEdit == nil {
                    ContentList.sharedInstance.arrayContent[self.currentIndex] = content!
                }else {
                    if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == content?.contentID.trim()}) {
                    
                        ContentList.sharedInstance.arrayContent[index] = content!
                    }
                    self.seletedImage = content
                    self.btnDone.isHidden = true
                    if self.isForEditOnly != nil {
                        self.navigationController?.pop()
                    }
                    
                }
                self.updateContent()
                self.isEditngContent = false
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func uploadFile(){
        // Create a object array to upload file to AWS
        self.deleteFileFromAWS(content: self.seletedImage)
        let fileName = NSUUID().uuidString + ".png"
        AWSRequestManager.sharedInstance.imageUpload(image: self.seletedImage.imgPreview!, name: fileName) { (imageURL, error) in
            if error == nil {
                DispatchQueue.main.async { // Correct
                    self.seletedImage.coverImage = imageURL
                    self.seletedImage.imgPreview = nil
                    self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: self.seletedImage.coverImageVideo, type: self.seletedImage.type.rawValue, width:Int((self.seletedImage.imgPreview?.size.width)!)
                        , height: Int((self.seletedImage.imgPreview?.size.height)!))
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
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
    func doneEditing(image: UIImage) {
        // the edited image
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        seletedImage.imgPreview = image
        seletedImage.width = Int(image.size.width)
        seletedImage.height = Int(image.size.height)

        if currentIndex != nil {
            ContentList.sharedInstance.arrayContent[currentIndex] = seletedImage
        }
        self.updateContent()
        self.btnDone.isHidden = false
        
    }
    
    func canceledEditing() {
        print("Canceled")
        AppDelegate.appDelegate.keyboardResign(isActive: true)
    }
}


extension ContentViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtTitleImage {
            txtDescription.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if txtTitleImage.text?.trim().lowercased() != seletedImage.name.trim().lowercased() || txtDescription.text.trim().lowercased() != seletedImage.description.trim().lowercased() {
            isEditngContent = true
            self.btnDone.isHidden = false
        }else{
            isEditngContent = true
            self.btnDone.isHidden = false
        }
    }
    
}

extension ContentViewController:UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        if txtTitleImage.text?.trim().lowercased() != seletedImage.name.trim().lowercased() || txtDescription.text.trim().lowercased() != seletedImage.description.trim().lowercased() {
            isEditngContent = true
            self.btnDone.isHidden = false
        }else{
            isEditngContent = false
            self.btnDone.isHidden = true
        }
    }
    

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {        
        if(text == "\n") {
            txtDescription.resignFirstResponder()
            return false
        }
        return textView.text.length + (text.length - range.length) <= 250
    }
   
}

extension ContentViewController:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate {

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}


