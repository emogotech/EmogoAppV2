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
    @IBOutlet weak var imgCover: UIImageView!
    
    @IBOutlet weak var txtTitleImage: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnShareAction: UIButton!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnAddToStream: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblTitleMessage: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var kHeight: NSLayoutConstraint!
    @IBOutlet weak var viewOption: UIView!

    var currentIndex:Int!
    var seletedImage:ContentDAO!
    var photoEditor:PhotoEditorViewController!
    let shapes = ShapeDAO()
    var isEdit:Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         self.prepareLayout()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
        self.txtDescription.maxLength = 250

        self.imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 2
        self.imgCover.addGestureRecognizer(tap)
        
        self.updateContent()
    }
    
    
    func updateContent() {
        if self.isEdit == nil {
            seletedImage = ContentList.sharedInstance.arrayContent[currentIndex]
        }
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
        self.lblTitleMessage.text = ""
        self.lblDescription.text = ""
        
        if  seletedImage.imgPreview != nil {
            self.imgCover.image = Toucan(image: seletedImage.imgPreview!).resize(kFrame.size, fitMode: Toucan.Resize.FitMode.clip).image
        }
      
        
        /*
        if  self.seletedImage.isUploaded {
            self.txtTitleImage.isHidden = true
            self.txtDescription.isHidden = true
            self.lblTitleMessage.isHidden = false
            self.lblDescription.isHidden = false
        }  else {
            self.txtTitleImage.isHidden = false
            self.txtDescription.isHidden = false
            self.lblTitleMessage.isHidden = true
            self.lblDescription.isHidden = true
        }
 */
        if !seletedImage.name.isEmpty {
            self.txtTitleImage.text = seletedImage.name.trim()
            self.lblTitleMessage.text = seletedImage.name.trim()
        }
        if !seletedImage.description.isEmpty {
            self.txtDescription.text = seletedImage.description.trim()
            self.lblDescription.text = seletedImage.name.trim()
        }
        if seletedImage.type == .image {
            self.btnPlayIcon.isHidden = true
        }else {
            self.btnPlayIcon.isHidden = false
        }
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }else {
            if seletedImage.type == .image {
                self.btnPlayIcon.isHidden = true
                self.imgCover.setImageWithURL(strImage: seletedImage.coverImage, placeholder: "stream-card-placeholder")
            }else   if seletedImage.type == .video {
                self.imgCover.setImageWithURL(strImage: seletedImage.coverImageVideo, placeholder: "stream-card-placeholder")
                self.btnPlayIcon.isHidden = false
            }else if seletedImage.type == .link {
                self.btnPlayIcon.isHidden = true
                self.imgCover.setImageWithURL(strImage: seletedImage.coverImageVideo, placeholder: "stream-card-placeholder")
            }
        }
        
        if self.seletedImage.isEdit == false {
            self.btnEdit.isHidden = true
            self.btnDone.isHidden = true
            self.txtTitleImage.isHidden = true
            self.txtDescription.isHidden = true
            self.lblTitleMessage.isHidden = false
            self.lblDescription.isHidden = false
        }else {
            self.btnEdit.isHidden = false
            self.btnDone.isHidden = false
            self.txtTitleImage.isHidden = false
            self.txtDescription.isHidden = false
            self.lblTitleMessage.isHidden = true
            self.lblDescription.isHidden = true
        }
        if self.seletedImage.isDelete == false {
            self.btnDelete.isHidden = true
        }else {
            self.btnDelete.isHidden = false
        }

      if self.seletedImage.isShowAddStream {
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
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: -  Action Methods And Selector
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popNormal()
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        if   ContentList.sharedInstance.arrayContent.count != 0 {
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
        }else {
            self.showToast(type: .error, strMSG: kAlert_Edit_Image)
        }
    }
    
    @IBAction func btnActionShare(_ sender: Any) {
        let composeVC = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendAttachments(){
            composeVC.recipients = []
            composeVC.message = composeMessage()
            self.present(composeVC, animated: true, completion: nil)
        }
        else{
          //  self.showToast(type: .error, strMSG: kAlert_Progress)
        }
    }
    
    func composeMessage() -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        
        layout.caption = lblTitleMessage.text!
        layout.image  = imgCover.image
        layout.subcaption = lblDescription.text
        let content = ContentList.sharedInstance.arrayContent[currentIndex]
        message.layout = layout
        message.url = URL(string: "\(kNavigation_Content)/\(content.contentID!)/\(ContentList.sharedInstance.objStream!)")
        
        return message
    }
    
    
    @IBAction func btnActionAddStream(_ sender: Any) {
        let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
        obj.objContent = seletedImage
        self.navigationController?.push(viewController: obj)
    }
    @IBAction func btnDoneAction(_ sender: Any) {
       // Update Content
        HUDManager.sharedInstance.showHUD()
        if self.seletedImage.imgPreview != nil {
            self.uploadFile()
        }else {
            self.updateContent(coverImage: self.seletedImage.coverImage!, coverVideo: "", type: self.seletedImage.type.rawValue)
        }
    }
    
    @IBAction func btnPlayAction(_ sender: Any) {
        self.openFullView()
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            
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
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .left:
                if currentIndex !=  ContentList.sharedInstance.arrayContent.count-1 {
                    self.next()
                }
                break
                
            case .right:
                if currentIndex != 0 {
                    self.previous()
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
            self.deleteContent()
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
        for obj in arrayTemp {
            var image:LightboxImage!
            if obj.type == .image {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: obj.name, videoURL: nil)
                }else{
                    let url = URL(string: obj.coverImage)
                    if url != nil {
                        image = LightboxImage(imageURL: url!, text: obj.name, videoURL: nil)
                    }
                }
            }else if obj.type == .video {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: obj.name, videoURL: obj.fileUrl)
                }else {
                    let url = URL(string: obj.coverImage)
                    let videoUrl = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!, text: obj.name, videoURL: videoUrl!)
                }
            }
            if image != nil {
                arrayContents.append(image)
            }
        }
        
        let controller = LightboxController(images: arrayContents, startIndex: index)
        controller.dynamicBackground = true
        if arrayContents.count != 0 {
            present(controller, animated: true, completion: nil)
        }
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
                    self.currentIndex =  self.currentIndex - 1
                    if(self.currentIndex < ContentList.sharedInstance.arrayContent.count-1) {
                        self.next()
                    }else {
                        self.previous()
                    }
                    
                    if  ContentList.sharedInstance.arrayContent.count == 0 {
                        self.navigationController?.pop()
                    }
                }else {
                    if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
                        ContentList.sharedInstance.arrayContent.remove(at: index)
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
    
    func updateContent(coverImage:String,coverVideo:String, type:String){
        APIServiceManager.sharedInstance.apiForEditContent(contentID: self.seletedImage.contentID, contentName: txtTitleImage.text!, contentDescription: txtDescription.text!, coverImage: coverImage, coverImageVideo: coverVideo, coverType: type) { (content, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                if self.isEdit == nil {
                    ContentList.sharedInstance.arrayContent[self.currentIndex] = content!
                }else {
                    if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == content?.contentID.trim()}) {
                        ContentList.sharedInstance.arrayContent[index] = content!
                    }
                    self.seletedImage = content
                }
                self.updateContent()
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func uploadFile(){
        // Create a object array to upload file to AWS
        self.deleteFileFromAWS(content: self.seletedImage)
        AWSRequestManager.sharedInstance.imageUpload(image: self.seletedImage.imgPreview!, name: NSUUID().uuidString + ".png") { (imageURL, error) in
            if error == nil {
                DispatchQueue.main.async { // Correct
                    self.updateContent(coverImage: imageURL!, coverVideo: "", type: self.seletedImage.type.rawValue)
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
        if currentIndex != nil {
            ContentList.sharedInstance.arrayContent[currentIndex] = seletedImage
        }
        self.updateContent()
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
}
