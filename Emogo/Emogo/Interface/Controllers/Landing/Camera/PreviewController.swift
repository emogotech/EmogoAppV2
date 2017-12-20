//
//  PreviewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Gallery

class PreviewController: UIViewController {

    // MARK: - UI Elements

    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var txtTitleImage: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnShareAction: UIButton!
    @IBOutlet weak var btnPreviewOpen: UIButton!
    @IBOutlet weak var previewCollection: UICollectionView!
    @IBOutlet weak var kPreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var kWidthOptions: NSLayoutConstraint!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    let editor: VideoEditing = VideoEditor()

    // MARK: - Variables

    var isPreviewOpen:Bool! = false
    var selectedIndex:Int! = 0
    var photoEditor:PhotoEditorViewController!
    let shapes = ShapeDAO()
    var isContentAdded:Bool! = false
    var seletedImage:ContentDAO!
    var strPresented:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        // Preview Height
        self.preparePreview(index: 0)
        kPreviewHeight.constant = 129.0
        kWidthOptions.constant = 0.0
        viewOptions.isHidden = true
        if self.strPresented != nil {
            kWidthOptions.constant = 63.0
            viewOptions.isHidden = false
        }
        imgPreview.backgroundColor = .black
        self.imgPreview.contentMode = .scaleAspectFit
        
        if !self.seletedImage.createdBy.trim().isEmpty {
            if self.seletedImage.createdBy.trim() != UserDAO.sharedInstance.user.userId.trim() {
                self.btnDelete.isHidden = true
                self.btnEdit.isHidden = true
            }
        }
        
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        Gallery.Config.tabsToShow = [.imageTab, .videoTab]
        Gallery.Config.initialTab =  .imageTab
        
        // Preview Footer
        self.previewCollection.reloadData()
    }
   
    
    func preparePreview(index:Int) {
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
        self.selectedIndex = index
       
        seletedImage =  ContentList.sharedInstance.arrayContent[index]
        if  seletedImage.imgPreview != nil {
            self.imgPreview.image = seletedImage.imgPreview
        }
        if !seletedImage.name.isEmpty {
            self.txtTitleImage.text = seletedImage.name.trim()
        }
        if !seletedImage.description.isEmpty {
            self.txtDescription.text = seletedImage.description.trim()
        }
        if seletedImage.type == .image {
            self.btnPlayIcon.isHidden = true
        }else {
            self.btnPlayIcon.isHidden = false
        }
        if seletedImage.imgPreview != nil {
            self.imgPreview.image = seletedImage.imgPreview
        }else {
            if seletedImage.type == .image {
                self.btnPlayIcon.isHidden = true
                self.imgPreview.setImageWithURL(strImage: seletedImage.coverImage, placeholder: "stream-card-placeholder")
            }else {
                self.imgPreview.setImageWithURL(strImage: seletedImage.coverImageVideo, placeholder: "stream-card-placeholder")
                self.btnPlayIcon.isHidden = false
            }
        }
        
    }
    
    
    func hideControls(isHide:Bool) {
        
    }
    
    // MARK: -  Action Methods And Selector

    
    @IBAction func btnBackAction(_ sender: Any) {
        if self.strPresented == nil {
            self.navigationController?.popNormal()
        }else {
            self.dismiss(animated: true, completion: nil)
        }
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
            self.showToast(type: .error, strMSG: "You don't have image to Edit.")
        }
    }
    @IBAction func btnActionShare(_ sender: Any) {
        self.showToast(type: .error, strMSG: "Content Will be shared by iMessage (work in progress).")
    }
    @IBAction func btnActionAddStream(_ sender: Any) {
        isContentAdded = true
        if seletedImage.isUploaded {
             addContentToStream()
        }else {
            if (self.txtTitleImage.text?.isEmpty)! {
                self.txtTitleImage.shake()
            }else {
                self.uploadFile()
            }
        }
    }
    @IBAction func btnDoneAction(_ sender: Any) {
         isContentAdded = false
        if (self.txtTitleImage.text?.isEmpty)! {
            self.txtTitleImage.shake()
        }else {
            self.uploadFile()
        }
    }
    @IBAction func btnAnimateViewAction(_ sender: Any) {
        self.animateView()
    }
    @IBAction func btnPlayAction(_ sender: Any) {
    }
    
    @IBAction func btnGalleryAction(_ sender: Any) {
        self.openGallery()
    }
    @IBAction func btnCameraAction(_ sender: Any) {
        let obj:CameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CameraViewController
        self.navigationController?.push(viewController: obj)
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
    
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            
            let alert = UIAlertController(title: "Confirmation!", message: "Are you sure, You want to Delete This Content?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "YES", style: .default) { (action) in
                self.deleteSelectedContent()
            }
            let no = UIAlertAction(title: "NO", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(yes)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        }
    }
    @objc func playIconTapped(sender:UIButton) {
        self.preparePreview(index: sender.tag)
    }
    
    // MARK: - Class Methods

    func deleteSelectedContent(){
        if self.seletedImage.contentID.trim().isEmpty {
            self.deleteContent()
        }else {
            ContentList.sharedInstance.arrayContent.remove(at: self.selectedIndex)
            if  ContentList.sharedInstance.arrayContent.count != 0 {
                self.preparePreview(index: 0)
            }else{
                self.navigationController?.pop()
            }
            self.previewCollection.reloadData()
        }
    }
    private func animateView(){
        UIView.animate(withDuration: 0.5) {
            self.isPreviewOpen = !self.isPreviewOpen
            if self.isPreviewOpen == false {
                // Down icon
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
                self.kPreviewHeight.constant = 129.0
               self.imgPreview.contentMode = .scaleAspectFit

            }else {
                // Up icon
                self.kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
               self.imgPreview.contentMode = .scaleToFill

            }
            self.view.updateConstraintsIfNeeded()
         //   self.imgPreview.image =  GalleryDAO.sharedInstance.Images[self.selectedIndex].imgPreview.resizeImage(targetSize: CGSize(width: self.imgPreview.bounds.width * 2.0, height: self.imgPreview.bounds.height * 2.0))
        }
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
    
    func setPreviewContent(title:String, description:String) {
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            seletedImage.name = title
            seletedImage.description = description
            ContentList.sharedInstance.arrayContent[selectedIndex] = seletedImage
        }
    }
    
    
    // MARK: - API Method
    
    func uploadFile(){
        // Create a object array to upload file to AWS
        var type:String! = "Picture"
        if !self.seletedImage.isUploaded  {
            HUDManager.sharedInstance.showProgress()
            var arrayURL = [Any]()
            if seletedImage.type == .video {
                type = "Video"
                Document.compressVideoFile(name: seletedImage.fileName, inputURL: seletedImage.fileUrl!, handler: { (compressed) in
                    if compressed != nil {
                        let fileUrl = URL(fileURLWithPath: compressed!)
                         if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:fileUrl) {
                            let img = image.reduceSize()
                            let compressedData = UIImageJPEGRepresentation(img, 1.0)
                            let url = Document.saveFile(data: compressedData!, name:  NSUUID().uuidString + ".jpeg")
                            let imgUrl = URL(fileURLWithPath: url)
                            let obj1 = ["name":NSUUID().uuidString + ".jpeg","url":imgUrl] as [String : Any]
                            arrayURL.append(obj1)
                        }
                        let obj = ["name":self.seletedImage.fileName!,"url":fileUrl] as [String : Any]
                        arrayURL.append(obj)
                        print(arrayURL)
                        self.startUpload(arryUrl: arrayURL, type: type)
                    }
                    
                })

            }else if seletedImage.type == .image {
                let image = seletedImage.imgPreview?.reduceSize()
                var compressedData:NSData?
                compressedData = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                if compressedData == nil {
                    compressedData = UIImagePNGRepresentation(seletedImage.imgPreview!) as NSData?
                }
                if let data = compressedData {
                    let url = Document.saveFile(data: data as Data , name: seletedImage.fileName)
                    let fileUrl = URL(fileURLWithPath: url)
                    let obj = ["name":seletedImage.fileName!,"url":fileUrl] as [String : Any]
                    arrayURL.append(obj)
                    self.startUpload(arryUrl: arrayURL, type: type)
                }else {
                    self.showToast(strMSG: "Unable to Upload Image")
                }
                
            }
        }else {
            if !self.seletedImage.contentID.trim().isEmpty {
                HUDManager.sharedInstance.showHUD()
                self.updateContent(coverImage: self.seletedImage.coverImage, coverVideo: self.seletedImage.coverImageVideo, type: self.seletedImage.type.rawValue)
            }
        }
    }
    
    func startUpload(arryUrl:[Any],type:String){
        var videoCover:String! = ""
        var file:String! = ""
        let dispatchGroup = DispatchGroup()
        for url in arryUrl  {
            let dict:[String:Any] = url as! [String : Any]
            if let obj = dict["name"], let objurl = dict["url"]  {
            print(obj)
            print(objurl)
            dispatchGroup.enter()
            self.uploadFileToAWS(fileURL: objurl as! URL, name: obj as! String, completion: { (fileUrl,error) in
                    if error == nil {
                        if type == "Video" {
                            if (fileUrl?.isImageType())! {
                                videoCover = fileUrl
                            }else {
                               file = fileUrl
                            }
                        }else {
                            file = fileUrl
                        }
                        dispatchGroup.leave()
                }
                })
            }
            
        }
       
        dispatchGroup.notify(queue: .main) {
            HUDManager.sharedInstance.hideProgress()
            DispatchQueue.main.async {
                print(videoCover)
                HUDManager.sharedInstance.showHUD()
                print(file)
                if self.seletedImage.contentID.trim().isEmpty {
                    self.addContent(fileUrl: file!,type:type,fileUrlVideo:videoCover)
                }else{
                
                self.updateContent(coverImage: file!, coverVideo: videoCover, type: type)
                }
            }
            
        }
    }
    
    
    func uploadFileToAWS(fileURL:URL,name:String, completion:@escaping (String?,Error?)->Void){
        
        AWSManager.sharedInstance.uploadFile(fileURL, name: name) { (fileUrl,error) in
            completion(fileUrl,error)
            
        }
    }
    func addContent(fileUrl:String,type:String,fileUrlVideo:String){
        APIServiceManager.sharedInstance.apiForCreateContent(contentName: (txtTitleImage.text?.trim())!, contentDescription: (txtDescription.text?.trim())!, coverImage: fileUrl,coverImageVideo:fileUrlVideo, coverType: type) { (contents, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                if !self.isContentAdded {
                    self.showToast(type: .success, strMSG: kAlertContentAdded)
                }
                self.modifyObjects(contents: contents!)
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    

    
    func modifyObjects(contents:[ContentDAO]){
        
        if contents.count != 0 {
        self.seletedImage = contents[0]
        ContentList.sharedInstance.arrayContent[selectedIndex] = seletedImage
        self.preparePreview(index: selectedIndex)
        }
        
        if self.isContentAdded {
            self.addContentToStream()
        }
    }
    
    func addContentToStream(){
        if seletedImage.isUploaded {
            if ContentList.sharedInstance.objStream != nil {
                
            }else {
                let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
                obj.objContent = seletedImage
                self.navigationController?.push(viewController: obj)
            }
           
        }
    }
    
    func deleteContent(){
        let content = [seletedImage.contentID.trim()]
        APIServiceManager.sharedInstance.apiForDeleteContent(contents: content) { (isSuccess, errorMsg) in
            if isSuccess == true {
                ContentList.sharedInstance.arrayContent.remove(at: self.selectedIndex)
                if  ContentList.sharedInstance.arrayContent.count != 0 {
                    self.preparePreview(index: 0)
                }else{
                    self.navigationController?.pop()
                }
                self.previewCollection.reloadData()
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func updateContent(coverImage:String,coverVideo:String, type:String){
        APIServiceManager.sharedInstance.apiForEditContent(contentID: self.seletedImage.contentID, contentName: txtTitleImage.text!, contentDescription: txtDescription.text!, coverImage: coverImage, coverImageVideo: coverVideo, coverType: type) { (content, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
            ContentList.sharedInstance.arrayContent[self.selectedIndex] = content!
            }else {
                self.showToast(strMSG: errorMsg!)
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



