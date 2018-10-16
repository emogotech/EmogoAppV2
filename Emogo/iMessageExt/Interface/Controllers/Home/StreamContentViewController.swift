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
import Photos
import SafariServices


protocol StreamContentViewControllerDelegate {
    func updateStreamViewCount(count:String)
}

class StreamContentViewController: MSMessagesAppViewController {
    
    // MARK:- UI Elements
    @IBOutlet weak var lblStreamTitle       : UILabel!
    @IBOutlet weak var lblStreamName        : UILabel!
    @IBOutlet weak var lblStreamDesc        : UILabel!
    @IBOutlet  weak var contentProgressView : UIProgressView!
    @IBOutlet weak var imgStream            : FLAnimatedImageView!
    @IBOutlet weak var imgGradient          : UIImageView!
    @IBOutlet weak var viewAction           : UIView!
    @IBOutlet weak var btnDelete            : UIButton!
    @IBOutlet weak var btnPlay: UIButton!
   
  
    @IBOutlet weak var btnEdit              : UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomToolBarView: UIView!
    @IBOutlet weak var kEditWidthConstraint: UIButton!
    @IBOutlet weak var btnLikeDislike: UIButton!
    @IBOutlet weak var btnAddToEmogo: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var btnReport: UIButton!
    
    var isDeleteContent: Bool = false
    
    
    // MARK: - Variables
    var isFromAll                           : String?
    var currentContentIndex                 : Int!
    var currentStreamID                     : String!
    var currentStreamTitle                  : String?
    var arrContentData                      = [ContentDAO]()
    var hudView                             : LoadingView!
    var objStream                           : StreamViewDAO?
    var isViewCount                         : String?
    var seletedImage                         :ContentDAO!
    var isForEditOnly                       :Bool!
    var isEdit                              :Bool!
    var objContent                          :ContentDAO!
    var isViewStream:Bool! = true
    var delegate:StreamContentViewControllerDelegate?
    var isProfile:String?
    
    //var photoEditor                         :PhotoEditorViewController!
    
    // MARK: - Life-cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.isHidden = true
        SharedData.sharedInstance.tempViewController = self
        ContentList.sharedInstance.arrayContent = arrContentData
        setupLoader()
        updateContent()
        
        let content = arrContentData.first
        if (content?.isAdd)! {
            arrContentData.remove(at: 0)
            currentContentIndex = currentContentIndex - 1
        }
        self.perform(#selector(self.prepareLayout), with: nil, afterDelay: 0.2)
        requestMessageScreenChangeSize()
        //apiForIncreaseViewCount()
        
    }
   override func viewWillAppear(_ animated: Bool) {
       super .viewWillAppear(true)
        print(self.currentContentIndex)
        self.seletedImage = self.arrContentData[currentContentIndex]
        let content = self.arrContentData[currentContentIndex]
        if content.likeStatus == 0 {
            self.btnLikeDislike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)

        }else{
            self.btnLikeDislike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        }
    
        self.collectionView.reloadData()
        bottomToolBarView.backgroundColor = UIColor.clear
        if #available(iOS 11, *), UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            bottomToolBarView.backgroundColor = UIColor.black
        }
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         self.collectionView.isHidden = false
       // contentProgressView.transform = CGAffineTransform(scaleX: 1, y: 3)
        self.collectionView.reloadData()
        updateCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)
        
    }
    
    // MARK:- Selector Methods
    @objc func requestMessageScreenChangeSize(){
        if(SharedData.sharedInstance.isMessageWindowExpand == false){
           // imgStream.isUserInteractionEnabled = false
        }
        else {
            //imgStream.isUserInteractionEnabled = true
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
    
    func updateCollectionView(){
        let indexPath = IndexPath(row: currentContentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
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
       // imgStream.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        //imgStream.addGestureRecognizer(swipeLeft)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.collectionView.addGestureRecognizer(swipeDown)
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
       //  imgStream.addGestureRecognizer(swipeDown)
        
       // let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.btnPlayAction(_:)))
       // imgStream.addGestureRecognizer(tapRecognizer)
        
        if isViewStream == false {
            if isViewCount != nil && seletedImage.fileName != "SreamCover"{
                apiForIncreaseViewCount()
            }
        }
        isViewStream = false
//        if isViewCount == "TRUE" {
//             apiForIncreaseViewCount()
//        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if currentContentIndex !=  arrContentData.count-1 {
                    self.nextContentLoad()
                   // self.perform(#selector(self.nextContentLoad), with: nil, afterDelay: 0.1)
                }
                break
            case UISwipeGestureRecognizerDirection.right:
                if currentContentIndex != 0 {
                    self.previousContentLoad()
                   // self.perform(#selector(self.previousContentLoad), with: nil, afterDelay: 0.1)
                }
                break
                
            case UISwipeGestureRecognizerDirection.down:
                ContentList.sharedInstance.objStream = nil
                SharedData.sharedInstance.iMessageNavigation = ""
                NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Content_Data), object: nil)

                self.dismiss(animated: true, completion: nil)
                break
                
            default:
                break
            }
        }
    }
    
    func nextContentLoad() {
        if(currentContentIndex < arrContentData.count-1) {
            currentContentIndex = currentContentIndex + 1
        }
        
        self.addRightTransitionImage(imgV: self.imgStream)
        loadViewForUI()
    }
    
     func previousContentLoad(){
        if currentContentIndex != 0{
            currentContentIndex = currentContentIndex - 1
        }
        self.addLeftTransitionImage(imgV: self.imgStream)
        loadViewForUI()
    }
    func updateContent(){
        btnReport.isHidden = false
        self.btnLikeDislike.isHidden = false
        btnReport.isHidden = false
        if currentContentIndex != nil {
            let isIndexValid = ContentList.sharedInstance.arrayContent.indices.contains(currentContentIndex)
            if isIndexValid {
                seletedImage = ContentList.sharedInstance.arrayContent[currentContentIndex]
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
        if isViewStream == false {
            if isViewCount != nil && seletedImage.fileName != "SreamCover"{
                apiForIncreaseViewCount()
            }
        }
        isViewStream = false
        
        if seletedImage.fileName == "SreamCover" {
            self.btnLikeDislike.isHidden = true
            btnReport.isHidden = true
        }
    }
    
    //MARK: - Load Data in UI
    func loadViewForUI(){
        print(currentContentIndex)
       // self.imgStream.contentMode = .scaleAspectFit
       let content = self.arrContentData[self.currentContentIndex]
       // self.lblStreamName.text = content.name.trim().capitalized
       if content.type != nil {
            self.btnEdit.setImage(#imageLiteral(resourceName: "edit_icon"), for: UIControlState.normal)
            if content.type == .image {
               // self.imgStream.setForAnimatedImage(strImage:content.coverImage)
                SharedData.sharedInstance.downloadImage(url: content.coverImage, handler: { (image) in
                    image?.getColors({ (colors) in
                       // self.imgStream.backgroundColor = colors.primary
                    })
                })
            }
            else if content.type == .video {
                //self.imgStream.setForAnimatedImage(strImage:content.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: content.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        //self.imgStream.backgroundColor = colors.primary
                    })
                })
            }
            else if content.type == .link {
               // self.btnPlay.isHidden = true
                self.btnEdit.setImage(#imageLiteral(resourceName: "edit_icon"), for: UIControlState.normal)
                //self.imgStream.setForAnimatedImage(strImage:content.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: content.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                       // self.imgStream.backgroundColor = colors.primary
                    })
                })
            } else {
                //self.imgStream.setForAnimatedImage(strImage:content.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: content.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                       // self.imgStream.backgroundColor = colors.primary
                    })
                })
            }
            if content.type == .video   {
                //self.btnPlay.isHidden = false
            }else {
               // self.btnPlay.isHidden = true
            }
            
            if content.likeStatus == 0 {
                self.btnLikeDislike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                
            }else{
                self.btnLikeDislike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
            }
        }
        
       // lblStreamDesc.text = content.description.trim().capitalized
        let currenProgressValue = Float(currentContentIndex)/Float(arrContentData.count-1)
      //  contentProgressView.setProgress(currenProgressValue, animated: true)
        btnEdit.isHidden = !content.isEdit
      //  btnDelete.isHidden = !content.isDelete
       
       // self.lblStreamName.minimumScaleFactor = 1.0
       // self.lblStreamDesc.minimumScaleFactor = 1.0
       // self.lblStreamTitle.minimumScaleFactor = 1.0
        
        DispatchQueue.main.async {
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
        }
    }
    //MARK:- Like Dislike Stream
    
    func likeDislikeContent(){
        self.hudView.startLoaderWithAnimation()
        let content = self.arrContentData[currentContentIndex]
        APIServiceManager.sharedInstance.apiForLikeDislikeContent(content: content.contentID, status:content.likeStatus)  { (isSuccess, errorMsg) in
            self.hudView.stopLoaderWithAnimation()
            if isSuccess == true {
                if content.likeStatus == 0 {
                    self.btnLikeDislike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                    
                }else{
                    self.btnLikeDislike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                }
            }else{
                
                 self.showToastIMsg(type: .error, strMSG: errorMsg!)
            }
        }
    }
    
    func createURLWithComponents(content: ContentDAO, urlString:String) -> String? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "Emogo";
        urlComponents.host = "emogo"
        
        // add params
        let name = URLQueryItem(name: "name", value: content.name!)
        let url = URLQueryItem(name: "url", value: content.coverImage!)
        let description = URLQueryItem(name: "description", value: content.description!)
        let videoImage = URLQueryItem(name: "video_image", value: content.coverImageVideo!)
        let height = URLQueryItem(name: "height", value: "\(content.height!)")
        let width = URLQueryItem(name: "width", value:  "\(content.width!)")
        let contentID = URLQueryItem(name: "content_id", value: content.contentID!)
        let contentType = URLQueryItem(name: "type", value: content.type.rawValue)
        let created_by = URLQueryItem(name: "created_by", value: content.createdBy)
        var streamID:URLQueryItem?
        if self.currentStreamID == nil {
             streamID = URLQueryItem(name: "stream_id", value: "")
        }else {
             streamID = URLQueryItem(name: "stream_id", value: self.currentStreamID)
        }

        urlComponents.queryItems = [name, url, description, videoImage,videoImage,height,width,contentID,contentType,created_by,streamID!]
        
        let strURl = "\(urlComponents.url!)/\(kDeepLinkTypeShareAddContent)"
        print(strURl)
        return strURl
    }
    
    func createURLWithComponentsEdit(content: ContentDAO, urlString:String) -> String? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "Emogo";
        urlComponents.host = "emogo"

        // add params
        let name = URLQueryItem(name: "name", value: content.name!)
        let url = URLQueryItem(name: "url", value: content.coverImage!)
        let description = URLQueryItem(name: "description", value: content.description!)
        let videoImage = URLQueryItem(name: "video_image", value: content.coverImageVideo!)
        let height = URLQueryItem(name: "height", value: "\(content.height!)")
        let width = URLQueryItem(name: "width", value:  "\(content.width!)")
        let contentID = URLQueryItem(name: "content_id", value: content.contentID!)
        let contentType = URLQueryItem(name: "type", value: content.type.rawValue)
        let created_by = URLQueryItem(name: "created_by", value: content.createdBy)
        var streamID:URLQueryItem?
        if self.currentStreamID == nil {
            streamID = URLQueryItem(name: "stream_id", value: "")
        }else {
            streamID = URLQueryItem(name: "stream_id", value: self.currentStreamID)
        }

        urlComponents.queryItems = [name, url, description, videoImage,videoImage,height,width,contentID,contentType,created_by,streamID!]

        let strURl = "\(urlComponents.url!)/\(kDeepLinkShareEditContent)"
        print(strURl)
        return strURl
    }

    
   
    //MARK: - Action Methods
    @IBAction func btnSaveAction(_ sender: Any) {
        self.saveActionSheet()
    }
    
    @IBAction func btnLikeAction(_ sender: Any) {
        let content = self.arrContentData[currentContentIndex]
        if  content.likeStatus == 0 {
            content.likeStatus = 1
        }else{
            content.likeStatus = 0
        }
        self.likeDislikeContent()
    }
    

    @IBAction func btnAddToEmogo(_ sender: UIButton) {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Add_Content , preferredStyle: .alert)
        let Continue = UIAlertAction(title:kAlert_Confirmation_Button_Title, style: .default) { (action) in
        //    let stream = self.arrContentData[self.currentContentIndex]
            let url = self.createURLWithComponents(content: self.seletedImage, urlString: "")
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: url!)
            
        }
        let Cancel = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(Continue)
        alert.addAction(Cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func btnEditAction(_ sender:UIButton){
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Edit_Content , preferredStyle: .alert)
        let Continue = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
             //let content = self.arrContentData[self.currentContentIndex]
            
            let url = self.createURLWithComponentsEdit(content: self.seletedImage, urlString: "")
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: url!)
            
//             let strUrl = "\(kDeepLinkURL)\(content.contentID!)/\(kDeepLinkShareEditContent)"
//            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let Cancel = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(Continue)
        alert.addAction(Cancel)
        present(alert, animated: true, completion: nil)
        
    }
   
    
    @IBAction func btnClose(_ sender:UIButton){
       
        if SharedData.sharedInstance.iMessageNavigation != ""{
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Stream_Content), object: nil)
            SharedData.sharedInstance.iMessageNavigation = ""
        }
        else {
            SharedData.sharedInstance.iMessageNavigation = ""
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Content_Data), object: nil)
        }

         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnShareAction(_ sender:UIButton){
      
        if(SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Compact), object: nil)
        }
        if self.seletedImage.type == .link {
            SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImageVideo) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.sendMessage(image: image)
                    }
                }
            }
        } else {
            SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImage) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.sendMessage(image: image)
                    }
                    
                }
            }
        }
        //self.perform(#selector(self.sendMessage), with: nil, afterDelay: 0.1)
    }
    
    @IBAction func btnPlayAction(_ sender: Any) {
        self.openFullView()
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
            index = self.currentContentIndex
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
       if self.currentContentIndex == nil {
                let videoUrl = URL(string: self.seletedImage.coverImage)
                if let videoUrl = videoUrl {
                    LightboxConfig.handleVideo(self, videoUrl)
                }
            }else {
        let temp = ContentList.sharedInstance.arrayContent[self.currentContentIndex]
                let videoUrl = URL(string: temp.coverImage)
                LightboxConfig.handleVideo(self, videoUrl!)
            }
            
        }else{
            let controller = LightboxController(images: arrayContents, startIndex: index)
            controller.pageDelegate = self as? LightboxControllerPageDelegate
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            }
        }
    }
    func gifPreview(){
        let obj:StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
        obj.objContent = self.seletedImage
        self.present(obj, animated: false, completion: nil)
    }
    
    func notePreview(){
//        let obj:NotesPreviewViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: "notesPreviewView") as! NotesPreviewViewController
//        obj.contentDAO = self.seletedImage
//        self.navigationController?.pushAsPresent(viewController: obj)
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
                        ContentList.sharedInstance.arrayContent.remove(at: self.currentContentIndex)
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
    
    @IBAction func btnShowReportListAction(_ sender: Any){
        
        if seletedImage.isDelete {
            self.showDelete()
            return
        }
        if self.seletedImage?.createdBy.trim() != UserDAO.sharedInstance.user.userId.trim(){
            self.showReport()
        }

    }
    
 
    
    @objc func sendMessage(image:UIImage){
        
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = self.seletedImage.name!
        layout.image  = image
        layout.subcaption = self.seletedImage.description
        let content = self.seletedImage
        message.layout = layout
        if ContentList.sharedInstance.objStream == nil {
            let strURl = kNavigation_Content  + "/" + (content?.contentID!)!
            message.url = URL(string: strURl)
        }else {
            let strURl = kNavigation_Content + "/" + (content?.contentID!)! + "/" + ContentList.sharedInstance.objStream!
            message.url = URL(string: strURl)
        }
         SharedData.sharedInstance.savedConversation?.insert(message, completionHandler: nil)
 
    }
    

    func apiForIncreaseViewCount(){
        if let streamID = ContentList.sharedInstance.objStream {
            APIServiceManager.sharedInstance.apiForIncreaseStreamViewCount(streamID: streamID) { (count, _) in
                if self.delegate != nil {
                    self.delegate?.updateStreamViewCount(count: count!)
                }
            }
        }
        
    }
    //MARK:- Save Content to My Stuff
    
    func saveToMyStuff(){
    
        APIServiceManager.sharedInstance.apiForSaveStuffContent(contentID: self.seletedImage.contentID) { (isSuccess, error) in
           
            if isSuccess == true {
                if self.seletedImage.type == .image {
                     self.showToastIMsg(type: .success, strMSG:   kAlert_Save_Image_MyStuff)
                 
                }else  if self.seletedImage.type == .video {
                   self.showToastIMsg(type: .success, strMSG:   kAlert_Save_Video_MyStuff)
                    
                }else  if self.seletedImage.type == .gif {
                    self.showToastIMsg(type: .success, strMSG:   kAlert_Save_GIF_MyStuff)
                    
                   
                }else  if self.seletedImage.type == .link{
                     self.showToastIMsg(type: .success, strMSG:   kAlert_Save_Link_MyStuff)
                   
                }
            }else{
               
                self.showToastIMsg(type: .success, strMSG:   error!)
                
            }
        }
    }
    
    func showReport(){
        let optionMenu = UIAlertController(title: kAlert_Title_ActionSheet, message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: "", stream: "", content: self.seletedImage.contentID!, completionHandler: { (isSuccess, error) in
                
                if isSuccess! {
                    self.showToastIMsg(type: .success, strMSG: kAlert_Success_Report_Content)
                }
            })
        })
        
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: "", stream: "", content: self.seletedImage.contentID!, completionHandler: { (isSuccess, error) in
                if isSuccess! {
                        self.showToastIMsg(type: .success, strMSG: kAlert_Success_Report_Content)
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
    
    func saveActionSheet(){
        
        let optionMenu = UIAlertController(title: kSaveAlertTitle, message: nil, preferredStyle: .alert)
        let saveToMyStuffAction = UIAlertAction(title: kAlertSheet_SaveToMyStuff, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.saveToMyStuff()
        })
        let saveToGalleryAction = UIAlertAction(title: kAlertSheet_SaveToGallery, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            if self.seletedImage.type == .image {
                if self.seletedImage.imgPreview == nil {
                  
                    SharedData.sharedInstance.downloadFile(strURl: self.seletedImage.coverImage, handler: { (image,_) in
                       
                        if image != nil {
                            UIImageWriteToSavedPhotosAlbum(image!
                                ,self, #selector(self.image(_:withPotentialError:contextInfo:)
                                ), nil)
                        }
                    })
                }
                
            }else if self.seletedImage.type == .video{
                self.videoDownload()
                
            }else if self.seletedImage.type == .gif{
                
                SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImageVideo, handler: { (image) in
                 
                    if image != nil {
                        UIImageWriteToSavedPhotosAlbum(image!
                            ,self, #selector(self.image(_:withPotentialError:contextInfo:)
                            ), nil)
                    }
                })
            }else if self.seletedImage.type == .link{
                
                //  self.imgCover.setForAnimatedImage(strImage:self.seletedImage.coverImage)
                SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImageVideo, handler: { (image) in
                  
                    if image != nil {
                        UIImageWriteToSavedPhotosAlbum(image!
                            ,self, #selector(self.image(_:withPotentialError:contextInfo:)
                            ), nil)
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
    
    func showDelete(){
        let optionMenu = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Delete_Stream_Msg, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: kAlertDelete_Content, style: .destructive, handler:
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
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
          self.showToastIMsg(type: .error, strMSG: kAlert_Save_Image)
        
    }
    //MARK: ⬇︎⬇︎⬇︎ API Methods ⬇︎⬇︎⬇︎
    
    func deleteContent(){
       
        let content = [seletedImage.contentID.trim()]
        APIServiceManager.sharedInstance.apiForDeleteContent(contents: content) { (isSuccess, errorMsg) in
          
            if isSuccess == true {
                self.deleteFileFromAWS(content: self.seletedImage)
                if self.isFromAll != nil {
                    ContentList.sharedInstance.arrayStuff.remove(at: self.currentContentIndex)
                }
                if self.isEdit == nil {
                    ContentList.sharedInstance.arrayContent.remove(at: self.currentContentIndex)
                    if  ContentList.sharedInstance.arrayContent.count == 0 {
                        //self.navigationController?.pop()
                        return
                    }
                    self.currentContentIndex =  self.currentContentIndex - 1
                    self.updateCollectionView()
                }else {
                    if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == self.seletedImage.contentID.trim()}) {
                        ContentList.sharedInstance.arrayContent.remove(at: index)
                      //  self.navigationController?.pop()
                    }
                    if self.isForEditOnly != nil {
                       // self.navigationController?.pop()
                    }
                }
                
            }else {
                 self.showToastIMsg(type: .success, strMSG: errorMsg!)
            }
        }
    }
  
    func deleteContentFromStream(){
       
        APIServiceManager.sharedInstance.apiForDeleteContentFromStream(streamID: ContentList.sharedInstance.objStream!, contentID: seletedImage.contentID.trim()) { (isSuccess, errorMsg) in
          
            if isSuccess == true {
                if self.isViewCount != nil {
                    NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Image_Cover), object: nil)
                }
                
                ContentList.sharedInstance.arrayContent.remove(at: self.currentContentIndex)
                self.currentContentIndex =  self.currentContentIndex - 1
                
                if self.currentContentIndex < 0 {
                    self.currentContentIndex = 0
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
                 self.showToastIMsg(type: .success, strMSG: errorMsg!)
            }
            
        }
    }
    
    

    
    func deleteFileFromAWS(content:ContentDAO){
        if !content.coverImage.isEmpty {
      //  AWSManager.sharedInstance.removeFile(name: content.coverImage.getName(), completion: { (isDeleted, error) in
        //    })
        }
        if !content.coverImageVideo.isEmpty {
       // AWSManager.sharedInstance.removeFile(name: content.coverImageVideo.getName(), completion: { (isDeleted, error) in
         //   })
        }
    }
    @objc func videoDownload(){
        
        APIManager.sharedInstance.download(strFile: self.seletedImage.coverImage) { (_, fileURL) in
            if let fileURL = fileURL {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:fileURL)
                }) { completed, error in
                    if completed {
                    
                        self.showToastIMsg(type: .success, strMSG:   kAlert_Save_Video)
                    }
                }
            }
        }
    }
    
   
    func createURLWithComponents(userInfo: StreamDAO, urlString:String) -> String? {
        // create "https://api.nasa.gov/planetary/apod" URL using NSURLComponents
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "Emogo";
        urlComponents.host = "emogo"
        
        // add params
        let fullName = URLQueryItem(name: "fullName", value: userInfo.fullName!)
        let phoneNumber = URLQueryItem(name: "phoneNumber", value: userInfo.phoneNumber!)
        let userProfileID = URLQueryItem(name: "user_profile_id", value: userInfo.userProfileId!)
        let userId = URLQueryItem(name: "userId", value: userInfo.userId!)
        let userImage = URLQueryItem(name: "userImage", value: userInfo.userImage!)
        urlComponents.queryItems = [fullName, phoneNumber, userId, userProfileID,userImage]
        let strURl = "\(urlComponents.url!)/\(kDeepLinkTypePeople)"
        print(strURl)
        return strURl
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}




extension StreamContentViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
       return self.arrContentData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContent, for: indexPath) as! StreamContentViewCell
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
        self.currentContentIndex = indexPath.row
        self.updateContent()
        print(indexPath)
    }

}
