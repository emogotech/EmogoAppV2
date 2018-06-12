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
import MessageUI
import Messages

class ViewStreamController: UIViewController {
   
    
    // MARK: - UI Elements
    @IBOutlet weak var viewStreamCollectionView: UICollectionView!
    @IBOutlet weak var lblNoContent: UILabel!
    @IBOutlet weak var btnAddContent: UIButton!

    // Varibales
    var streamType:String!
    var objStream:StreamViewDAO?

    var currentIndex:Int!
    var currentCount:Int!
    var viewStream:String?
    var isRefresh:Bool! = true
    var isUpload:Bool! = false
    var isbackFromDown:Bool! = false
    
    // MARK: - Override Functions
    var stretchyHeader: StreamViewHeader!
    var longPressGesture:UILongPressGestureRecognizer!
    var selectedIndex:IndexPath?
    var nextIndexPath:IndexPath?

    var indexForMinimum = 0
    var isFromCreateStream:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewStreamCollectionView.accessibilityLabel = "ViewStreamCollectionView"
      
        self.prepareLayouts()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.lblNoContent.isHidden = true
        self.viewStreamCollectionView.dataSource  = self
        self.viewStreamCollectionView.delegate = self
        
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(20, 8, 8, 8)
       // layout.isEnableReorder = true
        layout.columnCount = 2
        // Collection view attributes
        self.viewStreamCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.viewStreamCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.viewStreamCollectionView.collectionViewLayout = layout
        
        if currentIndex != nil  && StreamList.sharedInstance.arrayViewStream.count > 1 {
            viewStreamCollectionView.isUserInteractionEnabled = true
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            viewStreamCollectionView.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            viewStreamCollectionView.addGestureRecognizer(swipeLeft)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeDown.direction = UISwipeGestureRecognizerDirection.down
            viewStreamCollectionView.addGestureRecognizer(swipeDown)
        }
        
    longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
        self.viewStreamCollectionView.addGestureRecognizer(longPressGesture)
        configureStrechyHeader()
       
       
    }
    
    func configureStrechyHeader() {
        let nibViews = Bundle.main.loadNibNamed("StreamViewHeader", owner: self, options: nil)
        self.stretchyHeader = nibViews?.first as! StreamViewHeader
        self.viewStreamCollectionView.addSubview(self.stretchyHeader)
        stretchyHeader.streamDelegate = self
        
        if self.objStream?.likeStatus == "0" {
            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        }else{
            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
            
        }
        stretchyHeader.btnDelete.addTarget(self, action: #selector(self.deleteStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnEdit.addTarget(self, action: #selector(self.editStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnCollab.addTarget(self, action: #selector(self.btnColabAction), for: .touchUpInside)
        stretchyHeader.btnLike.addTarget(self, action: #selector(self.likeStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnShare.addTarget(self, action: #selector(self.shareStreamAction(sender:)), for: .touchUpInside)
         stretchyHeader.btnLikeList.addTarget(self, action: #selector(self.showLikeList(sender:)), for: .touchUpInside)
     
    }
    
    func prepareHeaderData(){
        if self.objStream != nil {
            stretchyHeader.prepareLayout(stream:self.objStream)
        }
    }
    
    func prepareNavigation(){
        
        if ContentList.sharedInstance.mainStreamIndex != nil {
            self.currentIndex = ContentList.sharedInstance.mainStreamIndex
            ContentList.sharedInstance.mainStreamIndex = nil
        }

     
        self.configureNavigationTite()
        let imgP = UIImage(named: "back_icon")
        let btnback = UIBarButtonItem(image: imgP, style: .plain, target: self, action: #selector(self.btnCancelAction))
        self.navigationItem.leftBarButtonItem = btnback
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kUpdateStreamViewIdentifier), object: nil, queue: nil) { (notification) in
            
            print("prepareNavigation iin view controller")
           
            if let data = notification.userInfo?["data"] as? [String] {
                print(data)
                self.isUpload  = true
                for v in 0...StreamList.sharedInstance.arrayViewStream.count-1 {
                    let streams = StreamList.sharedInstance.arrayViewStream[v]
                    for dataIDs in data {
                        if streams.ID == dataIDs {
                            self.currentIndex = v
                               self.perform(#selector(self.updateLayOut), with: nil, afterDelay: 0.1)
                            break
                        }
                    }
                    ContentList.sharedInstance.objStream = nil
                }
                
                }
                
            
        }
        if isRefresh {
            if ContentList.sharedInstance.objStream != nil {
                self.isUpload  = true
                for v in 0...StreamList.sharedInstance.arrayViewStream.count-1 {
                    let streams = StreamList.sharedInstance.arrayViewStream[v]
                    if streams.ID == ContentList.sharedInstance.objStream {
                        self.currentIndex = v
                        self.perform(#selector(self.updateLayOut), with: nil, afterDelay: 0.1)
                        break
                    }
                }
                ContentList.sharedInstance.objStream = nil
            }else{
                self.updateLayOut()
        }
        }
    }
    
    @objc func updateImageAfterEdit(){
        self.perform(#selector(updateLayOut), with: nil, afterDelay: 0.3)
    }
    
    @objc func updateLayOut(){
        
        if ContentList.sharedInstance.objStream != nil {
            
            if self.isUpload {
                self.isUpload = false
                let stream = StreamList.sharedInstance.arrayViewStream[currentIndex]
                let streamID = stream.ID
                if streamID != "" {
                    self.getStream(currentStream:nil,streamID:streamID)
                }
            }else{
                let stream = StreamList.sharedInstance.arrayViewStream[currentIndex]
                let streamID = stream.ID
                if streamID != "" {
                    self.getStream(currentStream:nil,streamID:streamID)
                }
            }
            if SharedData.sharedInstance.deepLinkType != "" {
                self.btnActionForAddContent()
                SharedData.sharedInstance.deepLinkType = ""
            }
            
        }
        else {
            if StreamList.sharedInstance.arrayViewStream.count != 0 {
                if currentIndex != nil {
                    let isIndexValid = StreamList.sharedInstance.arrayViewStream.indices.contains(currentIndex)
                    if isIndexValid {
                        let stream =  StreamList.sharedInstance.arrayViewStream[currentIndex]
                        StreamList.sharedInstance.selectedStream = stream
                    }
                    }
                }
                if StreamList.sharedInstance.selectedStream != nil {
                    self.getStream(currentStream:StreamList.sharedInstance.selectedStream)
                }
                
                if SharedData.sharedInstance.deepLinkType != "" {
                    self.btnActionForAddContent()
                    SharedData.sharedInstance.deepLinkType = ""
                }
            }
        }
    
    func prepareActions(isCreator:Bool) {

        if isCreator {
            stretchyHeader.btnDelete.isHidden = false
            stretchyHeader.btnEdit.isHidden = false
            stretchyHeader.btnEdit.setImage(#imageLiteral(resourceName: "edit_icon_stream"), for: .normal)
            stretchyHeader.btnEdit.removeTarget(self, action: #selector(self.likeStreamAction(sender:)), for: .touchUpInside)
            stretchyHeader.btnEdit.addTarget(self, action: #selector(self.editStreamAction(sender:)), for: .touchUpInside)
            stretchyHeader.btnLikeList.addTarget(self, action: #selector(self.showLikeList(sender:)), for: .touchUpInside)
            stretchyHeader.btnContainer.isHidden = false

        }else {
            stretchyHeader.btnDelete.isHidden = true
            stretchyHeader.btnLike.isHidden = false
            stretchyHeader.btnEdit.isHidden = false
            stretchyHeader.btnEdit.setImage(#imageLiteral(resourceName: "Unlike_icon"), for: .normal)
            stretchyHeader.btnEdit.removeTarget(self, action: #selector(self.editStreamAction(sender:)), for: .touchUpInside)
            stretchyHeader.btnEdit.addTarget(self, action: #selector(self.likeStreamAction(sender:)), for: .touchUpInside)
            stretchyHeader.btnContainer.isHidden = true
            // removed for now
            stretchyHeader.btnEdit.isHidden = true

        }
        self.btnAddContent.isHidden = true
        if self.objStream?.canAddContent == true {
            self.btnAddContent.isHidden = false
        }
        
      stretchyHeader.btnShare.addTarget(self, action: #selector(self.shareStreamAction(sender:)), for: .touchUpInside)
        // removed for now
        stretchyHeader.btnLike.isHidden = false
       // stretchyHeader.btnContainer.isHidden = false
        if self.objStream?.likeStatus == "0" {
            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
            
        }else{
            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        }
    }
    
    @IBAction func btnActionForAddContent(_ sender:UIButton) {
        btnActionForAddContent()
    }
    @objc func showReportList(){
        let optionMenu = UIAlertController(title: kAlert_Title_ActionSheet, message: "", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: "", stream: (self.objStream?.streamID!)!, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Stream)
                }
            })
        })
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: "", stream: (self.objStream?.streamID!)!, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Stream)
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel, handler: {
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
    
    @objc func likeStreamAction(sender:UIButton){
       print("Like Action")
        
        if  kDefault?.bool(forKey: kHapticFeedback) == true {
            self.stretchyHeader.btnLike.isHaptic = true
            self.stretchyHeader.btnLike.hapticType = .impact(.light)
        }else{
             self.stretchyHeader.btnLike.isHaptic = false
        }
        
        
        if self.objStream?.likeStatus == "0" {
            self.objStream?.likeStatus = "1"
        }else{
            self.objStream?.likeStatus = "0"
        }
        self.likeDislikeStream()
    }
 
    @objc func shareStreamAction(sender:UIButton){
        print("Share Action")
        
        if  kDefault?.bool(forKey: kHapticFeedback) == true {
            self.stretchyHeader.btnShare.isHaptic = true
            self.stretchyHeader.btnShare.hapticType = .impact(.light)
        }else{
            self.stretchyHeader.btnShare.isHaptic = false
        }
        
      
        if MFMessageComposeViewController.canSendAttachments(){
            let composeVC = MFMessageComposeViewController()
            composeVC.recipients = []
            composeVC.message = composeMessage()
            composeVC.messageComposeDelegate = self
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    @objc func showLikeList(sender:UIButton){
        let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_LikeListView) as! LikeListViewController
        obj.objStream = self.objStream
        self.navigationController?.push(viewController: obj)
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
        if (self.objStream?.canAddContent)! {
            let index = sender.tag - 1
            self.openFullViewForVideo(index: index)
        }else {
            self.openFullViewForVideo(index: sender.tag)
        }
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
                
            case .down:
           
               self.navigationController?.popViewAsDismiss()
                
            default:
                break
            }
        }
    }
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        if self.objStream?.idCreatedBy.trim() != UserDAO.sharedInstance.user.userId.trim() {
            return
        }
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.viewStreamCollectionView.indexPathForItem(at: gesture.location(in: self.viewStreamCollectionView)) else {
                break
            }
            selectedIndex = selectedIndexPath
            viewStreamCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
   
            guard let nextIndex = self.viewStreamCollectionView.indexPathForItem(at: gesture.location(in: self.viewStreamCollectionView)) else {
                break
            }
            nextIndexPath = nextIndex
            print("location---->\(gesture.location(in: self.viewStreamCollectionView))")
    viewStreamCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))

 
        case UIGestureRecognizerState.ended:
            viewStreamCollectionView.endInteractiveMovement()
            selectedIndex = nil
        default:
            viewStreamCollectionView.cancelInteractiveMovement()
            selectedIndex = nil
        }
    }
    
   
    func composeMessage() -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        
        layout.caption = stretchyHeader.lblName.text!
        layout.image  = stretchyHeader.imgCover.image
        layout.subcaption = stretchyHeader.lblDescription.text!
        
        message.layout = layout
        //let selectedImage = StreamList.sharedInstance.arrayStream[currentIndex]
        if StreamList.sharedInstance.objStream == nil {
            let strURl = String(format: "%@/%@", kNavigation_Stream,self.objStream!.streamID)
            message.url = URL(string: strURl)
        }else {
            let strURl = String(format: "%@/%@/%@", kNavigation_Stream,self.objStream!.streamID,StreamList.sharedInstance.objStream!)
            message.url = URL(string: strURl)
        }
        
        return message
    }
      //MARK:- Like Dislike Stream
    
    func likeDislikeStream(){
        var id:String! = ""
        
        if ContentList.sharedInstance.objStream != nil {
            id = ContentList.sharedInstance.objStream
        }
        else {
            if currentIndex != nil {
                let stream =  StreamList.sharedInstance.arrayViewStream[currentIndex]
                id =  stream.ID
            }
        }
        
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForLikeUnlikeStream(stream: id, status: (self.objStream?.likeStatus)!) {(count,status, error) in
             HUDManager.sharedInstance.hideHUD()
           if (error?.isEmpty)! {
             self.objStream?.likeStatus = status
             self.objStream?.totalLiked = count
                  if status == "0" {
                    if let totalLike = self.objStream?.totalLiked.trim(){
                        self.stretchyHeader.lblLikeCount.text = "\(totalLike)"
                    }
                   self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                }else{
                    if let totalLike = self.objStream?.totalLiked.trim(){
                        self.stretchyHeader.lblLikeCount.text = "\(totalLike)"
                    }
                  self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                }
            
            }else{
                    HUDManager.sharedInstance.hideHUD()
                    self.showToast(type: .success, strMSG: error!)
                }
            }
    }
    
   
    
    func next() {
        self.lblNoContent.isHidden = true
        self.btnAddContent.isHidden = true
        stretchyHeader.imgCover.image = #imageLiteral(resourceName: "stream-card-placeholder")
        if(currentIndex < StreamList.sharedInstance.arrayViewStream.count-1) {
            currentIndex = currentIndex + 1
        }
        Animation.addRightTransition(collection: self.viewStreamCollectionView)
        self.viewStreamCollectionView.reloadData()
        self.updateLayOut()
    }
    
    func previous() {
        self.btnAddContent.isHidden = true
        stretchyHeader.imgCover.image = #imageLiteral(resourceName: "stream-card-placeholder")
        self.lblNoContent.isHidden = true
        if currentIndex != 0{
            currentIndex =  currentIndex - 1
        }
        Animation.addLeftTransition(collection: self.viewStreamCollectionView)
        self.updateLayOut()
    }
    
    @objc func btnColabAction(){
        let obj:PeopleListViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PeopleListView) as! PeopleListViewController
        obj.streamID = self.objStream?.streamID
        obj.currentIndex = self.currentIndex
        obj.streamNavigate = self.viewStream
        self.navigationController?.push(viewController: obj)
    }
    
    @objc func btnViewDropActionWith(button : UIButton){
    }
    
    func openFullView(index:Int?){
        var arrayContents = [LightboxImage]()
        var startIndex = 0
        if self.objStream == nil {
            return
        }
        if (self.objStream?.canAddContent)! {
            if index != nil {
                startIndex = index!
            }
        }
        else {
            if index != nil {
                startIndex = 1 + index!
            }
        }
        
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
                }
                else{
                    let url = URL(string: obj.coverImage)
                    if url != nil {
                        image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: nil)
                    }
                }
            }
            else if obj.type == .video {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: text.trim(), videoURL: obj.fileUrl)
                }else {
                    let url = URL(string: obj.coverImageVideo)
                    let videoUrl = URL(string: obj.coverImage)
                    if url == nil {
                        image = LightboxImage(image: #imageLiteral(resourceName: "stream-card-placeholder"), text: text.trim(), videoURL: videoUrl)
                    }else{
                        image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: videoUrl!)
                    }
                }
            }
            if image != nil {
                arrayContents.append(image)
            }
        }
        let controller = LightboxController(images: arrayContents, startIndex: startIndex)
        controller.dynamicBackground = true
        if arrayContents.count != 0 {
            present(controller, animated: true, completion: nil)
        }
    }

    func openFullViewForVideo(index:Int?){
        if self.objStream == nil {
            return
        }
        let array = objStream?.arrayContent.filter { $0.isAdd == false }
        ContentList.sharedInstance.arrayContent = array
        let seletedImage = ContentList.sharedInstance.arrayContent[index!]
        let videoUrl = URL(string: (seletedImage.coverImage)!)
        LightboxConfig.handleVideo(self, videoUrl!)
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
                if self.objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                    self.navigationItem.rightBarButtonItem = nil
                    self.prepareActions(isCreator: true)
                }
                else {
                    let btnRightBar = UIBarButtonItem(image: #imageLiteral(resourceName: "stream_flag"), style: .plain, target: self, action: #selector(self.showReportList))
                    self.navigationItem.rightBarButtonItem = btnRightBar
                    if self.objStream?.arrayContent.count == 0 {
                        self.lblNoContent.isHidden = false
                    }
                    self.prepareActions(isCreator: false)
                }
                // Get All Heights
                var arrayHeights = [Int]()
                
                for obj in (self.objStream?.arrayContent)! {
                    arrayHeights.append(obj.height)
                }
                let minimum = arrayHeights.min()
                if let index =  self.objStream?.arrayContent.index(where: {$0.height ==  minimum}) {
                    self.indexForMinimum = index
                }
                    
                DispatchQueue.main.async {
                    self.viewStreamCollectionView.reloadData()
                }
            }
            else {
                if errorMsg == "404" {
                    self.showToast(type: .success, strMSG: kAlert_Stream_Deleted)
                    let when = DispatchTime.now() + 1.5
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.navigationController?.popNormal()
                    }
                }else {
                    self.showToast(type: .success, strMSG: errorMsg!)
                }
            }
        }
    }
    
    func deleteStream(){
        HUDManager.sharedInstance.showHUD()
        var id:String! = ""
        
        if ContentList.sharedInstance.objStream != nil {
            id = ContentList.sharedInstance.objStream
        }
        else {
            if currentIndex != nil {
                let stream =  StreamList.sharedInstance.arrayViewStream[currentIndex]
                id =  stream.ID
            }
        }
        
        APIServiceManager.sharedInstance.apiForDeleteStream(streamID: id) { (isSuccess, errorMsg) in
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
                self.showToast(strMSG: kAlert_Stream_Deleted_Success)
                if self.isFromCreateStream  != nil  {
                    let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
                    self.navigationController?.popToViewController(vc: obj)
                }else {
                    self.navigationController?.popNormal()
                }
                //self.prepareList()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func reorderContent(orderArray:[ContentDAO]) {
        
        APIServiceManager.sharedInstance.apiForReorderStreamContent(orderArray: orderArray, streamID: (self.objStream?.streamID)!) { (isSuccess,errorMSG)  in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.selectedIndex = nil
                self.viewStreamCollectionView.reloadData()
            }
        }
    }
    
    func btnActionForAddContent() {
        
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
        actionController.shouldShowAddButton    =   false
        present(actionController, animated: true, completion: nil)
    }
    
    func actionForCamera(){
        ContentList.sharedInstance.objStream = self.objStream?.streamID
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        ContentList.sharedInstance.arrayContent.removeAll()
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
        isRefresh = false
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            self?.preparePreview(assets: assets)
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
        }
        viewController.selectedAssets = [TLPHAsset]()
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
            if obj.type == .photo || obj.type == .livePhoto {
                camera.type = .image
                if obj.fullResolutionImage != nil {
                    camera.imgPreview = obj.fullResolutionImage
                    self.updateData(content: camera)
                    group.leave()
                }
                else { 
                    obj.cloudImageDownload(progressBlock: { (progress) in
                    }, completionBlock: { (image) in
                        if let img = image {
                            camera.imgPreview = img
                            self.updateData(content: camera)
                        }
                        group.leave()
                    })
                }
            }
            else if obj.type == .video {
                camera.type = .video
                obj.tempCopyMediaFile(progressBlock: { (progress) in
                    print(progress)
                }, completionBlock: { (url, mimeType) in
                    camera.fileUrl = url
                    obj.phAsset?.getOrigianlImage(handler: { (img, _) in
                        if img != nil {
                            camera.imgPreview = img
                        }else {
                            camera.imgPreview = #imageLiteral(resourceName: "stream-card-placeholder")
                        }
                        self.updateData(content: camera)
                        group.leave()
                    })
                })
            }
        }
        group.notify(queue: .main, execute: {
            HUDManager.sharedInstance.hideHUD()
            if ContentList.sharedInstance.arrayContent.count == assets.count {
                self.perform(#selector(self.previewScreenNavigated), with: self, afterDelay: 0.2)
            }
        })
    }
    
    func updateData(content:ContentDAO) {
        ContentList.sharedInstance.arrayContent.insert(content, at: 0)
    }
    
    @objc func previewScreenNavigated(){
        self.isRefresh = true
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            ContentList.sharedInstance.objStream = self.objStream?.streamID
            self.navigationController?.pushNormal(viewController: objPreview)
        }
    }
}



extension ViewStreamController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
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
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.prepareLayout(content:content!)
        return cell
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {

        let content = objStream?.arrayContent[indexPath.row]
       
        if selectedIndex != nil {
            
            let tempContent = objStream?.arrayContent[self.selectedIndex!.row]
            return CGSize(width: (tempContent?.width)!, height: (tempContent?.height)!)
        }
        return CGSize(width: (content?.width)!, height: (content?.height)!)
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = objStream?.arrayContent[indexPath.row]
        if content?.isAdd == true {
            btnActionForAddContent()
        }
        else {
            ContentList.sharedInstance.arrayContent.removeAll()
            let content = ContentDAO(contentData: [:])
            content.coverImage = objStream?.coverImage
            content.isUploaded = true
            content.type = .image
            content.fileName = "SreamCover"
            content.name = objStream?.title
            content.description = objStream?.description
            var array = objStream?.arrayContent.filter { $0.isAdd == false }
            array?.insert(content, at: 0)
            ContentList.sharedInstance.arrayContent = array
            ContentList.sharedInstance.objStream = objStream?.streamID
            let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
              objPreview.isViewCount = "TRUE"
              objPreview.currentIndex = indexPath.row + 1
            self.navigationController?.push(viewController: objPreview)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
        
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        if destinationIndexPath.row == 0 {
//            return
//        }
        let contentDest = objStream?.arrayContent[sourceIndexPath.row]
        objStream?.arrayContent.remove(at: sourceIndexPath.row)
        objStream?.arrayContent.insert(contentDest!, at: destinationIndexPath.row)
            print("moving ended")
            DispatchQueue.main.async {
            self.viewStreamCollectionView.reloadItems(at: [destinationIndexPath,sourceIndexPath])
                HUDManager.sharedInstance.showHUD()
                self.reorderContent(orderArray: (self.objStream?.arrayContent)!)
            }
    }
    /*
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
     //   print("next---->\(proposedIndexPath.row)")
       // print("cuurent---->\(originalIndexPath.row)")

        
        if proposedIndexPath.item == 0 {
            return IndexPath(item: 1, section: 0)
        }else  {
            return proposedIndexPath
        }
    }
 */

}

extension ViewStreamController:StreamViewHeaderDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate  {
    
    func showPreview() {
        self.openFullView(index: nil)
    }
   
        
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
    }
   
   
}

//extension CHTCollectionViewWaterfallLayout {
//
//    override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
//
//        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
//
//        //Check that the movement has actually happeneds
//        if previousIndexPaths.first!.item != targetIndexPaths.first!.item {
//            self.delegate?.collectionView!(self.collectionView!, moveItemAt: previousIndexPaths.first!, to: targetIndexPaths.first!)
//        }
//
//        return context
//
//    }
//
//
//    override func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
//
//        return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
//    }
//
//    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
//        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
//        attributes.alpha = 0.8
//        return attributes
//    }
//}

//extension CHTCollectionViewWaterfallLayout {
//
//    override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
//
//        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
//
//        self.delegate?.collectionView!(self.collectionView!, moveItemAt: previousIndexPaths[0], to: targetIndexPaths[0])
//
//        return context
//    }
//
//
//}
