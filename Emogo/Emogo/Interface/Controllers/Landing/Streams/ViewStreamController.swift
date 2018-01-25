//
//  ViewStreamController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Lightbox
import XLActionController

class ViewStreamController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var viewStreamCollectionView: UICollectionView!
    
    // Varibales
    var streamType:String!
    var objStream:StreamViewDAO?
    var currentIndex:Int!
    var viewStream:String?

    // MARK: - Override Functions
    var stretchyHeader: StreamViewHeader!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kNotification_Update_Image_Cover)), object: self)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.updateImageAfterEdit), name: NSNotification.Name(rawValue: kNotification_Update_Image_Cover), object: nil)
//
        
        // Do any additional setup after loading the view.
        self.viewStreamCollectionView.accessibilityLabel = "ViewStreamCollectionView"
        self.prepareLayouts()
    }
    
    @objc func updateImageAfterEdit(){
        self.perform(#selector(updateLayOut), with: nil, afterDelay: 0.3)
    }
    
   @objc func updateLayOut(){
    if ContentList.sharedInstance.objStream != nil {
        self.getStream(currentStream:nil,streamID:ContentList.sharedInstance.objStream)
    }else {
        if StreamList.sharedInstance.arrayViewStream.count != 0 {
            if currentIndex != nil {
                let stream =  StreamList.sharedInstance.arrayViewStream[currentIndex]
                StreamList.sharedInstance.selectedStream = stream
            }
            if StreamList.sharedInstance.selectedStream != nil {
                self.getStream(currentStream:StreamList.sharedInstance.selectedStream)
            }
        }
    }
   
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = nil
       self.prepareNavigation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)
    }
    // MARK: - Prepare Layouts
    func prepareLayouts(){
       
        // Attach datasource and delegate
        self.viewStreamCollectionView.dataSource  = self
        self.viewStreamCollectionView.delegate = self

        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(20, 8, 8, 8)
        layout.columnCount = 2
        // Collection view attributes
        self.viewStreamCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.viewStreamCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.viewStreamCollectionView.collectionViewLayout = layout
        
        if currentIndex != nil {
            viewStreamCollectionView.isUserInteractionEnabled = true
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            viewStreamCollectionView.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            viewStreamCollectionView.addGestureRecognizer(swipeLeft)
        }
        configureStrechyHeader()

    }
    
    func configureStrechyHeader(){
        let nibViews = Bundle.main.loadNibNamed("StreamViewHeader", owner: self, options: nil)
        self.stretchyHeader = nibViews?.first as! StreamViewHeader
        self.viewStreamCollectionView.addSubview(self.stretchyHeader)
        stretchyHeader.streamDelegate = self
        stretchyHeader.btnDelete.addTarget(self, action: #selector(self.deleteStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnEdit.addTarget(self, action: #selector(self.editStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnCollab.addTarget(self, action: #selector(self.btnColabAction), for: .touchUpInside)
        stretchyHeader.btnDropDown.addTarget(self, action: #selector(self.btnViewDropActionWith(button:)), for: .touchUpInside)
    }
    
    func prepareHeaderData(){
        if self.objStream != nil {
            stretchyHeader.prepareLayout(stream:self.objStream)
        }
    }
    
    func prepareNavigation(){
        
        self.configureNavigationTite()
      
        let imgP = UIImage(named: "back_icon")
        let btnback = UIBarButtonItem(image: imgP, style: .plain, target: self, action: #selector(self.btnCancelAction))
        self.navigationItem.leftBarButtonItem = btnback
        

        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kUpdateStreamViewIdentifier), object: nil, queue: nil) { (notification) in
            
            if ContentList.sharedInstance.objStream != nil {
           // self.viewStreamCollectionView.gestureRecognizers?.removeAll(keepingCapacity: false)
                self.updateLayOut()
                //  ContentList.sharedInstance.objStream = nil
            }
        }
        self.updateLayOut()
    }
    
    
    @objc func showReportList(){
        let optionMenu = UIAlertController(title: kAlertSheet_Spam, message: "", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: "", stream: (self.objStream?.streamID!)!, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Stream)
                }
            })
        })
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: "", stream: (self.objStream?.streamID!)!, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Stream)
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
    
    // MARK: -  Action Methods And Selector
    @objc func deleteStreamAction(sender:UIButton){
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Delete_Stream_Msg, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
           self.deleteStream()
        }
        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
   @objc func editStreamAction(sender:UIButton){
    if self.objStream != nil {
        let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
        obj.streamID = self.objStream?.streamID
        self.navigationController?.push(viewController: obj)
    }
    }
    
    @objc  func btnCancelAction(){
        if viewStream == nil {
            let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
            self.navigationController?.popToViewController(vc: obj)
        }else {
        self.navigationController?.pop()
        }
    }
    
    @objc func btnPlayAction(sender:UIButton){
        self.openFullView(index: sender.tag)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .left:
                if currentIndex !=  StreamList.sharedInstance.arrayViewStream.count-1 {
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
        if(currentIndex < StreamList.sharedInstance.arrayViewStream.count-1) {
            currentIndex = currentIndex + 1
        }
        Animation.addRightTransition(collection: self.viewStreamCollectionView)
        self.viewStreamCollectionView.reloadData()
        self.updateLayOut()
    }
    
    func previous() {
        if currentIndex != 0{
            currentIndex =  currentIndex - 1
        }
        Animation.addLeftTransition(collection: self.viewStreamCollectionView)
       
        self.updateLayOut()
    }
    
   @objc func btnColabAction(){
    let obj:PeopleListViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PeopleListView) as! PeopleListViewController
    obj.arrayColab = self.objStream?.arrayColab
    self.navigationController?.push(viewController: obj)
    }
    
    @objc func btnViewDropActionWith(button : UIButton){
        print("Drop down Action")
    }
/*
   @objc  func btnNextAction(){
    
    if currentIndex == StreamList.sharedInstance.arrayViewStream.count - 1 {
        current = 0
    }
    else {
        current += 1
    }
    self.prepareList()
    }
    
    @objc  func btnPreviousAction(){
        
        if(self.currentIndex == 0)
        {
            self.currentIndex = StreamList.sharedInstance.arrayViewStream.count - 1
        }
        else
        {
            self.currentIndex  -= 1
        }
        self.prepareList()
    }
   
 
    // MARK: - Class Methods

    func prepareList(){
        print("index---->\(self.currentIndex)")
        if self.currentIndex <= 0 {
            return
        }
        let stream = StreamList.sharedInstance.arrayViewStream[self.currentIndex!]
        self.getStream(currentStream:stream )
    }
     */
   
    
    func openFullView(index:Int?){
          var arrayContents = [LightboxImage]()
          var startIndex = 0
        
            let url = URL(string: (self.objStream?.coverImage)!)
            if url != nil {
                let text = (self.objStream?.title!)! + "\n" +  (self.objStream?.description!)!
                let image = LightboxImage(imageURL: url!, text:text, videoURL: nil)
                arrayContents.append(image)
            }
        
        let array = objStream?.arrayContent.filter { $0.isAdd == false }
        for obj in array! {
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
            }
        }
      
        if (self.objStream?.canAddContent)! {
            if index != nil {
                startIndex = index! - 1
            }
            let controller = LightboxController(images: arrayContents, startIndex: startIndex)
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            }
        }else {
            if index != nil {
                startIndex = index!
            }
            let controller = LightboxController(images: arrayContents, startIndex: startIndex)
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            }
        }
        
    }
    

    // MARK: - API Methods

    func getStream(currentStream:StreamDAO?, streamID:String? = nil){
        HUDManager.sharedInstance.showHUD()
        var id:String! = ""
        if streamID != nil {
            id = streamID
        }else {
            id = currentStream?.ID
        }
        APIServiceManager.sharedInstance.apiForViewStream(streamID:id) { (stream, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            
            if (errorMsg?.isEmpty)! {
                self.objStream = stream
                self.prepareHeaderData()
                self.viewStreamCollectionView.reloadData()
                if self.objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                    self.navigationItem.rightBarButtonItem = nil
                }else{
                    let btnRightBar = UIBarButtonItem(image: #imageLiteral(resourceName: "stream_flag"), style: .plain, target: self, action: #selector(self.showReportList))
                    self.navigationItem.rightBarButtonItem = btnRightBar
                }
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func deleteStream(){
        HUDManager.sharedInstance.showHUD()
     APIServiceManager.sharedInstance.apiForDeleteStream(streamID: (objStream?.streamID)!) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()

            if (errorMsg?.isEmpty)! {
                if let i = StreamList.sharedInstance.arrayViewStream.index(where: { $0.ID.trim() == StreamList.sharedInstance.selectedStream.ID.trim() }) {
                    StreamList.sharedInstance.arrayViewStream.remove(at: i)
                }
                
                for obj in StreamList.sharedInstance.arrayStream {
                    if obj.ID == StreamList.sharedInstance.selectedStream.ID {
                        if let index =  StreamList.sharedInstance.arrayStream.index(where: {$0.ID.trim() == obj.ID.trim()}) {
                            StreamList.sharedInstance.arrayStream.remove(at: index)
                        }
                    }
                }
                
                self.navigationController?.popNormal()
              //self.prepareList()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    func btnActionForAddContent(){
        let actionController = ActionSheetController()
        ContentList.sharedInstance.arrayContent.removeAll()
        actionController.addAction(Action(ActionData(title: "Photos & Videos", subtitle: "1", image: #imageLiteral(resourceName: "action_photo_video")), style: .default, handler: { action in
            self.btnImportAction()
        }))
        actionController.addAction(Action(ActionData(title: "Camera", subtitle: "1", image: #imageLiteral(resourceName: "action_camera_icon")), style: .default, handler: { action in
            
            self.actionForCamera()
            
        }))
        actionController.addAction(Action(ActionData(title: "Link", subtitle: "1", image: #imageLiteral(resourceName: "action_link_icon")), style: .default, handler: { action in
            
            self.btnActionForLink()
        }))
        
        actionController.addAction(Action(ActionData(title: "Gif", subtitle: "1", image: #imageLiteral(resourceName: "action_giphy_icon")), style: .default, handler: { action in
            
            self.btnActionForGiphy()
        }))
        
        actionController.addAction(Action(ActionData(title: "My Stuff", subtitle: "1", image: #imageLiteral(resourceName: "action_my_stuff")), style: .default, handler: { action in
            
            self.btnActionForMyStuff()
            
        }))
        
        actionController.headerData = "ADD ITEM"
        present(actionController, animated: true, completion: nil)
    }
    
    
    
    func actionForCamera(){
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.objStream = self.objStream?.streamID
        self.navigationController?.pushNormal(viewController: obj)
    }
    
    func btnActionForLink(){
        ContentList.sharedInstance.objStream = self.objStream?.streamID
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_LinkView)
        self.navigationController?.push(viewController: controller)
    }
    
    func btnActionForGiphy(){
        ContentList.sharedInstance.objStream = self.objStream?.streamID
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_GiphyView)
        self.navigationController?.push(viewController: controller)
    }
    
    
    func btnActionForMyStuff(){
        ContentList.sharedInstance.objStream = self.objStream?.streamID
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView)
        self.navigationController?.push(viewController: controller)
    }
    
    func btnImportAction(){
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            //     self?.selectedAssets = assets
            self?.preparePreview(assets: assets)
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
            //exceed max selection
        }
        viewController.selectedAssets = []
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 10
        configure.muteAudio = true
        configure.usedCameraButton = false
        configure.usedPrefetch = false
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    func preparePreview(assets:[TLPHAsset]){
        
        HUDManager.sharedInstance.showHUD()
        let group = DispatchGroup()
        for obj in assets {
            group.enter()
            let camera = ContentDAO(contentData: [:])
            camera.isUploaded = false
            camera.fileName = obj.originalFileName
            if obj.type == .photo {
                camera.type = .image
                if obj.fullResolutionImage != nil {
                    camera.imgPreview = obj.fullResolutionImage
                    self.updateData(content: camera)
                    group.leave()
                }else {
                    
                    obj.cloudImageDownload(progressBlock: { (progress) in
                        
                    }, completionBlock: { (image) in
                        if let img = image {
                            camera.imgPreview = img
                            self.updateData(content: camera)
                        }
                        group.leave()
                    })
                }
                
            }else if obj.type == .video {
                camera.type = .video
                obj.tempCopyMediaFile(progressBlock: { (progress) in
                    print(progress)
                }, completionBlock: { (url, mimeType) in
                    camera.fileUrl = url
                    if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:url) {
                        camera.imgPreview = image
                        self.updateData(content: camera)
                    }
                    group.leave()
                })
            }
        }
        group.notify(queue: .main, execute: {
            HUDManager.sharedInstance.hideHUD()
            if ContentList.sharedInstance.arrayContent.count == assets.count {
                self.previewScreenNavigated()
            }
        })
    }
    
    func updateData(content:ContentDAO) {
        ContentList.sharedInstance.arrayContent.insert(content, at: 0)
    }
    
    func previewScreenNavigated(){
        
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            ContentList.sharedInstance.objStream = self.objStream?.streamID
            self.navigationController?.pushNormal(viewController: objPreview)
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



extension ViewStreamController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if objStream != nil {
            return objStream!.arrayContent.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
         let content = objStream?.arrayContent[indexPath.row]
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.prepareLayout(content:content!)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let content = objStream?.arrayContent[indexPath.row]
        if content?.isAdd == true {
        
             return CGSize(width: #imageLiteral(resourceName: "add_content_icon").size.width, height: #imageLiteral(resourceName: "add_content_icon").size.height)
        }
        return CGSize(width: (content?.width)!, height: (content?.height)!)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = objStream?.arrayContent[indexPath.row]
        if content?.isAdd == true {
            btnActionForAddContent()
            /*
            let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
                kContainerNav = "1"
                currentTag = 111
            ContentList.sharedInstance.objStream = self.objStream?.streamID
             arraySelectedContent = [ContentDAO]()
             arrayAssests = [ImportDAO]()
            ContentList.sharedInstance.arrayContent.removeAll()
            self.navigationController?.push(viewController: obj)
            //self.navigationController?.push(viewController: obj)
 */
        }else {
                ContentList.sharedInstance.arrayContent.removeAll()
             let array = objStream?.arrayContent.filter { $0.isAdd == false }
             ContentList.sharedInstance.arrayContent = array
             ContentList.sharedInstance.objStream = objStream?.streamID
              let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
            if (self.objStream?.canAddContent)! {
                objPreview.currentIndex = indexPath.row - 1
            }else {
                objPreview.currentIndex = indexPath.row
            }
                self.navigationController?.push(viewController: objPreview)
        }
    }
    
}


extension ViewStreamController:StreamViewHeaderDelegate {
    func showPreview() {
     self.openFullView(index: nil)
    }
    
    
}

