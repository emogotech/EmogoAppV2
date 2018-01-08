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
    @IBOutlet weak var lblTitleMessage: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    let editor: VideoEditing = VideoEditor()
    @IBOutlet weak var btnDone: UIButton!

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
        self.previewCollection.reloadData()
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
        // Remove Duplicate Objects
        self.txtTitleImage.maxLength = 50
        self.txtDescription.maxLength = 250
        var seen = Set<String>()
        var unique = [ContentDAO]()
        for obj in  ContentList.sharedInstance.arrayContent {
            if obj.isUploaded {
                if !seen.contains(obj.contentID) {
                    unique.append(obj)
                    seen.insert(obj.contentID)
                }
            }else {
                if !seen.contains(obj.fileName.trim()) {
                    unique.append(obj)
                    seen.insert(obj.fileName.trim())
                }
            }
        }
        ContentList.sharedInstance.arrayContent = unique
        
        self.preparePreview(index: 0)
        kPreviewHeight.constant = 129.0
        kWidthOptions.constant = 0.0
        viewOptions.isHidden = true
//        if self.strPresented != nil {
//            kWidthOptions.constant = 63.0
//            viewOptions.isHidden = false
//        }
        imgPreview.backgroundColor = .black
        self.imgPreview.contentMode = .scaleAspectFill
        
        if !self.seletedImage.createdBy.trim().isEmpty {
           
            if self.seletedImage.isEdit == false {
                self.btnEdit.isHidden = true
            }else {
                self.btnEdit.isHidden = false
            }
            if self.seletedImage.isDelete == false {
                self.btnEdit.isHidden = true
            }else {
                self.btnEdit.isHidden = false
            }
        }
        
        Gallery.Config.VideoEditor.maximumDuration = 30
        Gallery.Config.tabsToShow = [.imageTab, .videoTab]
        Gallery.Config.initialTab =  .imageTab
        Gallery.Config.Camera.imageLimit =  10
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = false

        self.imgPreview.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 2
        self.imgPreview.addGestureRecognizer(tap)
        // Preview Footer
        self.previewCollection.reloadData()
        self.btnDone.isHidden = false
       if ContentList.sharedInstance.objStream != nil {
        self.btnDone.isHidden = true
        }
    }
   
    
    func preparePreview(index:Int) {
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
        self.lblTitleMessage.text = ""
        self.lblDescription.text = ""
        self.selectedIndex = index
       
        seletedImage =  ContentList.sharedInstance.arrayContent[index]
        if  seletedImage.imgPreview != nil {
            self.imgPreview.image = Toucan(image: seletedImage.imgPreview!).resize(kFrame.size, fitMode: Toucan.Resize.FitMode.clip).image
        }
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
        }else if seletedImage.type == .video {
            self.btnPlayIcon.isHidden = false
        }else {
            self.btnPlayIcon.isHidden = true
        }
        if seletedImage.imgPreview != nil {
            self.imgPreview.image = seletedImage.imgPreview
        }else {
            if seletedImage.type == .image {
                self.imgPreview.setImageWithURL(strImage: seletedImage.coverImage, placeholder: "stream-card-placeholder")
            }else {
                self.imgPreview.setImageWithURL(strImage: seletedImage.coverImageVideo, placeholder: "stream-card-placeholder")
            }
        }
        
        if seletedImage.isUploaded {
            if self.seletedImage.isEdit == false {
                self.btnEdit.isHidden = true
            }else {
                self.btnEdit.isHidden = false
            }
            if self.seletedImage.isDelete == false {
                self.btnDelete.isHidden = true
            }else {
                self.btnDelete.isHidden = false
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
                if seletedImage.isUploaded {
                    let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                    objPreview.seletedImage = seletedImage
                    objPreview.isEdit = true
                    self.navigationController?.push(viewController: objPreview)
                }else{
                    self.openEditor(image:seletedImage.imgPreview!)
                }
            }
        }else {
            self.showToast(type: .error, strMSG: kAlert_Edit_Image)
        }
    }
    @IBAction func btnActionShare(_ sender: Any) {
        self.showToast(type: .error, strMSG: kAlert_Progress)
    }
    @IBAction func btnActionAddStream(_ sender: Any) {
        if ContentList.sharedInstance.objStream != nil {

            if ContentList.sharedInstance.arrayContent.count != 0 {
                HUDManager.sharedInstance.showProgress()
                let array = ContentList.sharedInstance.arrayContent
                    AWSRequestManager.sharedInstance.associateContentToStream(streamID: [(ContentList.sharedInstance.objStream)!], contents: array!, completion: { (isScuccess, errorMSG) in
                      HUDManager.sharedInstance.hideProgress()
                        if (errorMSG?.isEmpty)! {
                        }
                    })
                ContentList.sharedInstance.arrayContent.removeAll()
                self.previewCollection.reloadData()
                let when = DispatchTime.now() + 1.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    // Back Screen
                    let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream)
                    self.navigationController?.popToViewController(vc: obj)
                    
                }
            }
        }else {
            // Navigate to View Stream
            addContentToStream()
        }
        
    }
    @IBAction func btnDoneAction(_ sender: Any) {
       
        if ContentList.sharedInstance.arrayContent.count != 0 {
            let array = ContentList.sharedInstance.arrayContent.filter { $0.isUploaded == false }
            HUDManager.sharedInstance.showProgress()

            print(array.count)
            let arrayC = [String]()
            AWSRequestManager.sharedInstance.startContentUpload(StreamID: arrayC, array: array)
            ContentList.sharedInstance.arrayContent.removeAll()
            self.previewCollection.reloadData()
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                let objStream = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
                self.navigationController?.popToViewController(vc: objStream)
            }
        }
       
    }
    @IBAction func btnAnimateViewAction(_ sender: Any) {
        self.animateView()
    }
    @IBAction func btnPlayAction(_ sender: Any) {
        self.openFullView()
    }
    
    @IBAction func btnGalleryAction(_ sender: Any) {
        self.openGallery()
    }
    @IBAction func btnCameraAction(_ sender: Any) {
        let obj:CameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CameraViewController
        self.navigationController?.popToViewController(vc: obj)
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
    @objc func playIconTapped(sender:UIButton) {
        self.preparePreview(index: sender.tag)
    }
    
    // MARK: - Class Methods

    func deleteSelectedContent(){
        arraySelectedContent?.remove(at: self.selectedIndex)
        ContentList.sharedInstance.arrayContent.remove(at: self.selectedIndex)
        if  ContentList.sharedInstance.arrayContent.count != 0 {
                self.preparePreview(index: 0)
        }else{
            if self.strPresented == nil {
                self.navigationController?.popNormal()
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.previewCollection.reloadData()
    }
    private func animateView(){
        UIView.animate(withDuration: 0.5) {
            self.isPreviewOpen = !self.isPreviewOpen
            if self.isPreviewOpen == false {
                // Down icon
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
                self.kPreviewHeight.constant = 129.0
               self.imgPreview.contentMode = .scaleAspectFill

            }else {
                // Up icon
                self.kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
               self.imgPreview.contentMode = .scaleAspectFill

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
            if seletedImage.type == .video {
                type = "Video"
                AWSRequestManager.sharedInstance.prepareVideoToUpload(name: seletedImage.fileName, videoURL: seletedImage.fileUrl!, completion: { (strThumb,strVideo,error) in
                    if error == nil {
                self.addContent(fileUrl: strVideo!, type: type, fileUrlVideo: strThumb!)
                    }
                })

            }else if seletedImage.type == .image {
                AWSRequestManager.sharedInstance.imageUpload(image: seletedImage.imgPreview!, name: seletedImage.fileName!, completion: { (fileURL, error) in
                    self.addContent(fileUrl: fileURL!, type: type, fileUrlVideo:"")
            })
            }
        }
    }
                /*
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
    */
    /*
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

 
    func uploadFileToAWS(fileURL:URL,name:String, completion:@escaping (String?,Error?)->Void){
        
        AWSManager.sharedInstance.uploadFile(fileURL, name: name) { (fileUrl,error) in
            completion(fileUrl,error)
            
        }
    }
*/

    func addContent(fileUrl:String,type:String,fileUrlVideo:String){
        APIServiceManager.sharedInstance.apiForCreateContent(contentName: (txtTitleImage.text?.trim())!, contentDescription: (txtDescription.text?.trim())!, coverImage: fileUrl,coverImageVideo:fileUrlVideo, coverType: type) { (contents, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                if !self.isContentAdded {
                    self.showToast(type: .success, strMSG: kAlert_Content_Added)
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
    let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
        self.navigationController?.push(viewController: obj)
        }
    
    func deleteContent(){
        HUDManager.sharedInstance.showHUD()
        let content = [seletedImage.contentID.trim()]
        APIServiceManager.sharedInstance.apiForDeleteContent(contents: content) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
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
    
   
    func associateContent() {
       
//        if ContentList.sharedInstance.objStream != nil && contents.count != 0{
//            AWSRequestManager.sharedInstance.associateContentToStream(streamID: (ContentList.sharedInstance.objStream?.streamID)!, contentID: contents, completion: { (isSuccess, errorMsg) in
//                if (errorMsg?.isEmpty)! {
//                self.showToast(strMSG: kAlert_Content_Associated_To_Stream)
//                }else {
//                self.showToast(strMSG: errorMsg!)
//                }
//            })
//        }
        
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



