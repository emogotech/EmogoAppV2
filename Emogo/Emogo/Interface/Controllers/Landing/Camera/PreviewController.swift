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

    @IBOutlet weak var imgPreview: FLAnimatedImageView!
    @IBOutlet weak var txtTitleImage: UITextField!
    @IBOutlet weak var txtDescription: MBAutoGrowingTextView!
    @IBOutlet weak var btnShareAction: UIButton!
    @IBOutlet weak var btnPreviewOpen: UIButton!
    @IBOutlet weak var previewCollection: UICollectionView!
    @IBOutlet weak var kPreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var kWidthOptions: NSLayoutConstraint!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnDone: UIButton!

    // MARK: - Variables
    let editor: VideoEditing = VideoEditor()

    var isPreviewOpen:Bool! = false
    var selectedIndex:Int! = 0
    var photoEditor:PhotoEditorViewController!
    let shapes = ShapeDAO()
    var isContentAdded:Bool! = false
    var seletedImage:ContentDAO!
    var strPresented:String!
    var isEditingContent:Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
        if self.isEditingContent{
            self.preparePreview(index: selectedIndex)
        }
        self.previewCollection.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
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
        txtDescription.text = "Description"
        txtDescription.delegate = self

        var seen = Set<String>()
        var unique = [ContentDAO]()
        for obj in  ContentList.sharedInstance.arrayContent {
            if obj.isUploaded {
                if !seen.contains(obj.contentID) {
                    unique.append(obj)
                    seen.insert(obj.contentID)
                }
            }else if obj.type == .gif || obj.type == .link {
                    if !seen.contains(obj.coverImage.trim()) {
                    unique.append(obj)
                    seen.insert(obj.coverImage.trim())
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
        
        if !self.seletedImage.createdBy.trim().isEmpty {
           
            if self.seletedImage.isEdit == false {
                self.btnEdit.isHidden = true
            }else {
                if self.seletedImage.type == .image {
                    self.btnEdit.isHidden = false
                }else{
                    self.btnEdit.isHidden = true
                }
            }
            if self.seletedImage.isDelete == false {
                self.btnEdit.isHidden = true
            }else {
                if self.seletedImage.type == .image {
                    self.btnEdit.isHidden = false
                }else{
                    self.btnEdit.isHidden = true
                }
            }
        }
        
        Gallery.Config.VideoEditor.maximumDuration = 30
        Gallery.Config.tabsToShow = [.imageTab, .videoTab]
        Gallery.Config.initialTab =  .imageTab
        Gallery.Config.Camera.imageLimit =  10
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = false

        self.imgPreview.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 1
        self.imgPreview.addGestureRecognizer(tap)
        // Preview Footer
        self.previewCollection.reloadData()
        self.btnDone.isHidden = false
       if ContentList.sharedInstance.objStream != nil {
        self.btnDone.isHidden = true
        }
        if self.seletedImage.isUploaded  == false{
            self.btnShareAction.isHidden = true
        }
    }
   
    
    func preparePreview(index:Int) {
        self.txtTitleImage.text = ""

        self.selectedIndex = index
       
        seletedImage =  ContentList.sharedInstance.arrayContent[index]
        
        if !seletedImage.name.isEmpty {
            self.txtTitleImage.text = seletedImage.name.trim()
        }
        if !seletedImage.description.isEmpty {
            self.txtDescription.text = seletedImage.description.trim()
        }else {
            txtDescription.text = "Description"
        }
        if seletedImage.type == .image {
            self.btnPlayIcon.isHidden = true
            self.btnEdit.isHidden = false
        }else if seletedImage.type == .video {
            self.btnPlayIcon.isHidden = false
            self.btnEdit.isHidden = true
        }else {
            self.btnPlayIcon.isHidden = true
            self.btnEdit.isHidden = true
        }
        if seletedImage.imgPreview != nil {
            self.imgPreview.image = seletedImage.imgPreview
            seletedImage.imgPreview?.getColors({ (colors) in
                self.imgPreview.backgroundColor = colors.background
                self.txtTitleImage.textColor = colors.secondary
                self.txtDescription.textColor = colors.secondary
                self.txtTitleImage.placeholderColor(color: colors.secondary)
            })
        }else {
            if seletedImage.type == .image  {
        
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImage, handler: { (image) in
                    
                    image?.getColors({ (colors) in
                        self.imgPreview.backgroundColor = colors.background
                        self.txtTitleImage.textColor = colors.secondary
                        self.txtDescription.textColor = colors.secondary
                        self.txtTitleImage.placeholderColor(color: colors.secondary)
                    })
                    
                })
                self.imgPreview.setForAnimatedImage(strImage:seletedImage.coverImage)

            }else {
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    
                    image?.getColors({ (colors) in
                        self.imgPreview.backgroundColor = colors.background
                        self.txtTitleImage.textColor = colors.secondary
                        self.txtDescription.textColor = colors.secondary
                        self.txtTitleImage.placeholderColor(color: colors.secondary)
                    })
                })
                
            self.imgPreview.setForAnimatedImage(strImage:seletedImage.coverImageVideo)

            }
        }
        self.txtTitleImage.isHidden = false
        self.txtDescription.isHidden = false
        if seletedImage.isUploaded {
            if self.seletedImage.isEdit == false {
                self.btnEdit.isHidden = true
            }else {
                if self.seletedImage.type == .image {
                    self.btnEdit.isHidden = false
                }else{
                    self.btnEdit.isHidden = true
                }
            }
            if self.seletedImage.isDelete == false {
                self.btnDelete.isHidden = true
            }else {
                self.btnDelete.isHidden = false
            }
            self.txtTitleImage.isHidden = true
            self.txtDescription.isHidden = true
        }
        self.imgPreview.contentMode = .scaleAspectFit

    }
    
    
    func hideControls(isHide:Bool) {
        
    }
    
    func resetLayout(){
        self.imgPreview.image = nil
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
    }
    
    // MARK: -  Action Methods And Selector

    
    @IBAction func btnBackAction(_ sender: Any) {
        if self.strPresented == nil {
            self.imgPreview.image = nil
            self.navigationController?.popNormal()
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            if seletedImage.type == .image {
                if seletedImage.isUploaded {
                    isEditingContent = true
                    let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                    objPreview.seletedImage = seletedImage
                    objPreview.isEdit = true
                    objPreview.isForEditOnly = true
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
        self.view.endEditing(true)
        if ContentList.sharedInstance.arrayContent.count > 10 {
            self.alertForLimit()
            return
        }
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
                self.resetLayout()
                self.previewCollection.reloadData()
                let when = DispatchTime.now() + 1.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    // Back Screen
                    let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream)
                    obj.title = currentStreamType.rawValue
//                    obj.streamType
                    self.navigationController?.popToViewController(vc: obj)
                    
                }
            }
        }else {
            // Navigate to View Stream
            addContentToStream()
        }
        
    }
    @IBAction func btnDoneAction(_ sender: Any) {
       self.view.endEditing(true)
        if ContentList.sharedInstance.arrayContent.count != 0 {
            let array = ContentList.sharedInstance.arrayContent.filter { $0.isUploaded == false }
            HUDManager.sharedInstance.showProgress()

            let arrayC = [String]()
            AWSRequestManager.sharedInstance.startContentUpload(StreamID: arrayC, array: array)
            self.imgPreview.image = nil
            self.resetLayout()
            ContentList.sharedInstance.arrayContent.removeAll()
            self.previewCollection.reloadData()
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                if kNavForProfile.isEmpty {
                    let objStream = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
                    
                    self.navigationController?.popToViewController(vc: objStream)
                }else {
                     kNavForProfile = ""
                      let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView)
                    self.navigationController?.popToViewController(vc: obj)
                }
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
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
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
        
        if self.seletedImage.isUploaded {
            if let index =  arraySelectedContent?.index(where: {$0.contentID.trim() == seletedImage.contentID.trim()}) {
                arraySelectedContent?.remove(at: index)
            }
            
            if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == seletedImage.contentID.trim()}) {
                ContentList.sharedInstance.arrayContent.remove(at: index)
            }
            
        }else {
            
            if self.seletedImage.type == .gif {
             
                if let index =  arraySelectedContent?.index(where: {$0.coverImage.trim() == self.seletedImage.coverImage.trim()}) {
                    arraySelectedContent?.remove(at: index)
                }
                
                if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.coverImage.trim() == seletedImage.coverImage.trim()}) {
                    ContentList.sharedInstance.arrayContent.remove(at: index)
                }
                
            }else {
                if let index =  arrayAssests?.index(where: {$0.name.lowercased().trim() == seletedImage.fileName.lowercased().trim()}) {
                    arrayAssests?.remove(at: index)
                }
                
                if let index =  arraySelectedContent?.index(where: {$0.fileName.trim() == self.seletedImage.fileName.trim()}) {
                    arraySelectedContent?.remove(at: index)
                }
                
                if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.fileName.trim() == seletedImage.fileName.trim()}) {
                    ContentList.sharedInstance.arrayContent.remove(at: index)
                }
                
            }
        }
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
                self.preparePreview(index: 0)
        }else{
             arrayAssests?.removeAll()
             arraySelectedContent?.removeAll()
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
                self.imgPreview.contentMode = .scaleAspectFit

            }else {
                // Up icon
                self.kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
                self.imgPreview.contentMode = .scaleAspectFit

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
        APIServiceManager.sharedInstance.apiForCreateContent(contentName: (txtTitleImage.text?.trim())!, contentDescription: (txtDescription.text?.trim())!, coverImage: fileUrl,coverImageVideo:fileUrlVideo, coverType: type,width:0,height:0) { (contents, errorMsg) in
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
    
    func alertForLimit(){
        let alert = UIAlertController(title: kAlert_Capture_Title, message: kAlert_Capture_Limit_Exceeded, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
        }
        
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
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



