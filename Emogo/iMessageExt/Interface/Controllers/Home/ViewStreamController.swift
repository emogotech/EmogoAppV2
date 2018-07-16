//
//  ViewStreamController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Lightbox
//import XLActionController
import MessageUI
import Messages

class ViewStreamController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout,StreamContentViewControllerDelegate,StreamViewHeaderDelegate  {
   
    
 
    // MARK: - UI Elements
    @IBOutlet weak var viewStreamCollectionView: UICollectionView!
    @IBOutlet weak var lblNoContent: UILabel!
    @IBOutlet weak var btnAddContent: UIButton!
    @IBOutlet weak var btnReport : UIButton!
    @IBOutlet weak var btnShare : UIButton!
    @IBOutlet weak var btnEdit   : UIButton!

    @IBOutlet weak var btnClose: UIButton!
    // Varibales
    var streamType:String!
    var objStream:StreamViewDAO?

    var currentIndex:Int!
    var currentCount:Int!
    var viewStream:String?
    var isRefresh:Bool! = true
    var isUpload:Bool! = false
    var isbackFromDown:Bool! = false
    var isDidLoad:Bool! = false
    var isFromWelcome : String?
    var hudView  : LoadingView!

    // MARK: - Override Functions
    var stretchyHeader: StreamViewHeader!
    var currentStreamIndex : Int!
    var longPressGesture:UILongPressGestureRecognizer!
    var selectedIndex:IndexPath?
    var nextIndexPath:IndexPath?

    var indexForMinimum = 0
    var isFromCreateStream:String?
    var arrStream  = [StreamDAO]()
  
    
    
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
        self.navigationItem.hidesBackButton = true
        
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
            
//            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//            swipeDown.direction = UISwipeGestureRecognizerDirection.down
//            viewStreamCollectionView.addGestureRecognizer(swipeDown)
        }
        
     longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
        self.viewStreamCollectionView.addGestureRecognizer(longPressGesture)
        configureStrechyHeader()
       
       
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
    func showPreview() {
        self.openFullView(index: nil)
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
        stretchyHeader.btnCollab.addTarget(self, action: #selector(self.btnColabAction), for: .touchUpInside)
        stretchyHeader.btnLike.addTarget(self, action: #selector(self.likeStreamAction(sender:)), for: .touchUpInside)
         stretchyHeader.btnLikeList.addTarget(self, action: #selector(self.showLikeList(sender:)), for: .touchUpInside)
        self.viewStreamCollectionView.bringSubview(toFront: stretchyHeader)
    }
    
    func prepareHeaderData(){
        if self.objStream != nil {
            stretchyHeader.prepareLayout(stream:self.objStream)
        }
    }
    /*
    func configureNewNavigation(){
        
        var arrayButtons = [UIBarButtonItem]()
        
        let imgP = UIImage(named: "back_icon_stream")
        let btnback = UIBarButtonItem(image: imgP, style: .plain, target: self, action: #selector(self.btnCancelAction))
        self.navigationItem.leftBarButtonItem = btnback
        
        let btnRightBar = UIBarButtonItem(image: #imageLiteral(resourceName: "stream_flag"), style: .plain, target: self, action: #selector(self.showReportList))
        arrayButtons.insert(btnRightBar, at: 0)
        
        
        if self.objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            stretchyHeader.viewLike.isHidden = false
            stretchyHeader.viewViewCount.isHidden = false
            let imgEdit = UIImage(named: "view_nav_edit_icon")
            let rightEditBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgEdit, style: .plain, target: self, action: #selector(self.editStreamAction(sender:)))
            arrayButtons.append(rightEditBarButtonItem)
            
            let imgDownload = UIImage(named: "share_profile")
            let rightDownloadBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgDownload, style: .plain, target: self, action: #selector(self.shareStreamAction(sender:)))
            arrayButtons.append(rightDownloadBarButtonItem)
            if !(self.objStream?.anyOneCanEdit)! {
                let imgAddCollab = UIImage(named: "add_user_group_icon")
                let rightAddCollabBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgAddCollab, style: .plain, target: self, action: #selector(self.btnActionaddCollaborator))
                arrayButtons.append(rightAddCollabBarButtonItem)
            }
           
            self.btnAddContent.isHidden = false
        }else {
            
            if self.objStream?.canAddContent == true {
                self.btnAddContent.isHidden = false
            }
            
            if self.objStream?.canAddPeople == true {
                let imgEdit = UIImage(named: "view_nav_edit_icon")
                let rightEditBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgEdit, style: .plain, target: self, action: #selector(self.editStreamAction(sender:)))
                arrayButtons.append(rightEditBarButtonItem)
                
                if !(self.objStream?.anyOneCanEdit)! {
                    let imgAddCollab = UIImage(named: "add_user_group_icon")
                    let rightAddCollabBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgAddCollab, style: .plain, target: self, action: #selector(self.btnActionaddCollaborator))
                    arrayButtons.append(rightAddCollabBarButtonItem)
                }
            }
            
            if self.objStream?.canAddContent == true  || self.objStream?.canAddPeople == true || self.objStream?.anyOneCanEdit == true || self.objStream?.type.lowercased() == "public" {
                let imgDownload = UIImage(named: "share_profile")
                let rightDownloadBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgDownload, style: .plain, target: self, action: #selector(self.shareStreamAction(sender:)))
                arrayButtons.append(rightDownloadBarButtonItem)
            }
            
            stretchyHeader.viewLike.isHidden = true
            stretchyHeader.viewViewCount.isHidden = true

        }
      
        self.navigationItem.rightBarButtonItems = arrayButtons
        
        if self.objStream?.likeStatus == "0" {
            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
            
        }else{
            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        }
        self.stretchyHeader.btnLike.isHidden = false

    }*/
    
    func prepareNavigation(){
     
        if ContentList.sharedInstance.mainStreamIndex != nil {
            self.currentIndex = ContentList.sharedInstance.mainStreamIndex
            ContentList.sharedInstance.mainStreamIndex = nil
        }
       // self.configureNavigationTite()
        self.navigationController?.navigationBar.tintColor = UIColor(r: 0, g: 122, b: 255)
        
         NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kNotification_Update_Image_Cover)), object: self)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kNotification_Update_Image_Cover), object: nil, queue: nil) { (notification) in
            self.updateLayOut()
        }
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kUpdateStreamViewIdentifier), object: nil, queue: nil) { (notification) in
            
            //print("prepareNavigation iin view controller")
           
            if let data = notification.userInfo?["data"] as? [String] {
               // print(data)
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
 
    @objc func updateLayOut(){
        if self.stretchyHeader != nil  {
            self.stretchyHeader.imgCover.image = #imageLiteral(resourceName: "stream-card-placeholder")
        }
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
               // self.btnActionForAddContent()
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
                  //  self.btnActionForAddContent()
                    SharedData.sharedInstance.deepLinkType = ""
                }
            }
        }
 
    
    @IBAction func btnActionForAddContent(_ sender:UIButton) {
       // btnActionForAddContent()
    }
    @IBAction func btnReportAction(_ sender: Any) {
        self.showReportList()
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        
        self.shareStreamAction()
    }
    @objc func showReportList(){
        if self.objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            showDelete()
        }else {
            showReport()
        }
    }
    
    @objc func btnActionaddCollaborator(){
        
        if self.objStream != nil {
            if (self.objStream?.arrayColab.count)! > 1 {
                let obj = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_Collaborator) as! CollaboratorViewController
                obj.strTitle = kCollaobatorList
                obj.arrCollaborator = objStream?.arrayColab
                self.present(obj, animated: true, completion: nil)
            }
        }
       
    }
    
    func showReport(){
        let optionMenu = UIAlertController(title: kAlert_Title_ActionSheet, message: "", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: "", stream: (self.objStream?.streamID!)!, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                 
                }
            })
        })
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: "", stream: (self.objStream?.streamID!)!, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToastIMsg(type: .success, strMSG: kAlert_Success_Report_Stream)
                  
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
    
    func showDelete(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: kAlertDelete_Content, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            self.deleteStream()
        })
        
        let cancelAction = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
        })
        
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
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Edit_Stream , preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            let stream = self.arrStream[self.currentStreamIndex]
            let strUrl = "\(kDeepLinkURL)\(stream.ID!)/\(kDeepLinkTypeEditStream)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnEditStream(_ sender:UIButton) {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Edit_Stream , preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            let stream = self.arrStream[self.currentStreamIndex]
            let strUrl = "\(kDeepLinkURL)\(stream.ID!)/\(kDeepLinkTypeEditStream)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func likeStreamAction(sender:UIButton){
      // print("Like Action")
        if self.objStream != nil {
//            if  kDefault?.bool(forKey: kHapticFeedback) == true {
//                self.stretchyHeader.btnLike.isHaptic = true
//                self.stretchyHeader.btnLike.hapticType = .impact(.light)
//            }else{
//                self.stretchyHeader.btnLike.isHaptic = false
//            }
            
            
            if self.objStream?.likeStatus == "0" {
                self.objStream?.likeStatus = "1"
            }else{
                self.objStream?.likeStatus = "0"
            }
            self.likeDislikeStream()
        }
        
    }
 
    @objc func shareStreamAction(sender:UIButton){
     self.shareStreamAction()
    }
    func shareStreamAction(){
        // print("Share Action")
        
        if  kDefault?.bool(forKey: kHapticFeedback) == true {
            //            self.btnShare.isHaptic = true
            //            self.btnShare.hapticType = .impact(.light)
        }else{
            //self.btnShare.isHaptic = false
        }
        if(SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Compact), object: nil)
        }
        self.perform(#selector(self.sendMessage), with: nil, afterDelay: 0.1)
        
        
    }
    
    @objc func sendMessage(){
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = stretchyHeader.lblName.text!
        layout.image  = stretchyHeader.imgCover.image
        layout.subcaption = stretchyHeader.lblDescription.text!
        if let url =  URL(string: (self.objStream?.coverImage)!) {
            layout.mediaFileURL = url
        }
        message.layout = layout
        if StreamList.sharedInstance.objStream == nil {
            let strURl = String(format: "%@/%@", kNavigation_Stream,self.objStream!.streamID)
            message.url = URL(string: strURl)
        }else {
            let strURl = String(format: "%@/%@/%@", kNavigation_Stream,self.objStream!.streamID,StreamList.sharedInstance.objStream!)
            message.url = URL(string: strURl)
        }
        
        SharedData.sharedInstance.savedConversation?.insert(message, completionHandler: nil)
        self.view.isUserInteractionEnabled = true
    }

    
    @objc func showLikeList(sender:UIButton){
        if self.objStream != nil && self.objStream?.arrayLikedUsers.count != 0{
            let obj = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_LikeListView) as! LikeListViewController
            obj.objStream = self.objStream
            self.present(obj, animated: true, completion: nil)
        }
    }
    @objc  func btnCancelAction(){
        if self.isFromWelcome != nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.present(vc, animated: true, completion: nil)
        }
            //        else if self.strStream == "viewStream"   {
            //            self.dismiss(animated: true, completion: nil)
            //            SharedData.sharedInstance.iMessageNavigation = "viewStream"
            //
            //        }
        else {
            self.dismiss(animated: true, completion: nil)
            SharedData.sharedInstance.iMessageNavigation = ""
            //  NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Content_Data), object: nil)
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
                
//            case .down:
//             self.navigationController?.popViewAsDismiss()
//            break
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
      
        APIServiceManager.sharedInstance.apiForLikeUnlikeStream(stream: (self.objStream?.streamID)!, status: (self.objStream?.likeStatus)!) {(count,status, results,error) in
          
           if (error?.isEmpty)! {
             self.objStream?.likeStatus = status
             self.objStream?.totalLiked = count
             self.objStream?.arrayLikedUsers = results!
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
        if self.objStream != nil {
            if (self.objStream?.arrayColab.count)! > 1 {
                let obj = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_Collaborator) as! CollaboratorViewController
                obj.strTitle = kCollaobatorList
                obj.arrCollaborator = objStream?.arrayColab
                self.present(obj, animated: true, completion: nil)
            }
        }
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
        let isIndexValid = ContentList.sharedInstance.arrayContent.indices.contains(index!)
        if isIndexValid {
            let seletedImage = ContentList.sharedInstance.arrayContent[index!]
            let videoUrl = URL(string: (seletedImage.coverImage)!)
            if videoUrl != nil {
                LightboxConfig.handleVideo(self, videoUrl!)
            }
        }
    }
    
    // MARK: - API Methods
    func getStream(currentStream:StreamDAO?, streamID:String? = nil){
        if isDidLoad == true {
           
        }
        var id:String! = ""
        if streamID != nil {
            id = streamID
        }else {
            id = currentStream?.ID
        }
        APIServiceManager.sharedInstance.apiForViewStream(streamID:id) { (stream, errorMsg) in
            if  self.isDidLoad == true {
               
            }
             self.isDidLoad = true
            self.lblNoContent.isHidden = true
            if (errorMsg?.isEmpty)! {
                self.objStream = stream
                self.prepareHeaderData()
          
                if self.objStream?.arrayContent.count == 0 {
                    self.lblNoContent.isHidden = false
                }
//               self.configureNewNavigation()
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
                
                if let streamIndex =  StreamList.sharedInstance.arrayStream.index(where: {$0.ID.trim() == self.objStream?.streamID.trim()}) {
                    let oldData = StreamList.sharedInstance.arrayStream[streamIndex]
                    oldData.haveSomeUpdate = false
                    StreamList.sharedInstance.arrayStream[streamIndex] = oldData
                }
            }
            else {
                if errorMsg == "404" {
                      self.showToastIMsg(type: .success, strMSG: kAlert_Stream_Deleted)
                  
//                    let when = DispatchTime.now() + 1.5
//                    DispatchQueue.main.asyncAfter(deadline: when) {
//                        self.navigationController?.popNormal()
//                    }
                }else {
                     self.showToastIMsg(type: .success, strMSG: errorMsg!)
                }
            }
        }
    }
    
    func deleteStream() {
        //        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Delete_Stream_Msg, preferredStyle: .alert)
        //        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
        let stream = self.arrStream[self.currentStreamIndex]
        APIServiceManager.sharedInstance.apiForDeleteStream(streamID: (stream.ID)!) { (isSuccess, errorMsg) in
            if (errorMsg?.isEmpty)! {
                self.arrStream.remove(at: self.currentStreamIndex)
                StreamList.sharedInstance.arrayStream.remove(at:self.currentStreamIndex)
                if(self.arrStream.count == 0){
                    if self.isFromWelcome != nil {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Content_Data), object: nil)
                    }
                    return
                }
                if(self.currentStreamIndex != 0){
                    self.currentStreamIndex = self.currentStreamIndex - 1
                }
                let stream = StreamList.sharedInstance.arrayViewStream[self.currentIndex]
                let streamID = stream.ID
                if streamID != "" {
                    self.getStream(currentStream:nil,streamID:streamID)
                }
            } else {
                self.showToastIMsg(type: .success, strMSG: errorMsg!)
            }
        }
    }
    func reorderContent(orderArray:[ContentDAO]) {
        
        APIServiceManager.sharedInstance.apiForReorderStreamContent(orderArray: orderArray, streamID: (self.objStream?.streamID)!) { (isSuccess,errorMSG)  in
          
            if (errorMSG?.isEmpty)! {
                self.selectedIndex = nil
                self.viewStreamCollectionView.reloadData()
            }
        }
    }
    func showToastIMsg(type:AlertType,strMSG:String) {
            self.view.makeToast(message: strMSG,
                                duration: TimeInterval(2.0),
                                position: .center,
                                image: nil,
                                backgroundColor: UIColor.black.withAlphaComponent(0.6),
                                titleColor: UIColor.yellow,
                                messageColor: UIColor.white,
                                font: nil)
        }
        
     

    func updateStreamViewCount(count: String) {
        
        //self.lbl_ViewCount.text = count
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let content = objStream?.arrayContent[indexPath.row]
        if content?.isAdd == true {
            return CGSize(width: #imageLiteral(resourceName: "add_content_icon").size.width, height: #imageLiteral(resourceName: "add_content_icon").size.height)
        }
        if selectedIndex != nil {
            let tempContent = objStream?.arrayContent[selectedIndex!.row]
            return CGSize(width: (tempContent?.width)!, height: (tempContent?.height)!)
        }
        return CGSize(width: (content?.width)!, height: (content?.height)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if objStream != nil {
            return objStream!.arrayContent.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : StreamCollectionViewCell = self.viewStreamCollectionView.dequeueReusableCell(withReuseIdentifier: iMgsSegue_StreamCollection, for: indexPath) as! StreamCollectionViewCell
        let content = objStream?.arrayContent[indexPath.row]
        
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.imgCover.image = nil
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.prepareLayout(content:content!)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        self.viewStreamCollectionView.deselectItem(at: indexPath, animated:false)
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
        let obj : StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
        obj.arrContentData = array!
        obj.isViewCount = "TRUE"
        obj.isViewStream =  true
        //   self.addRippleTransition()
        obj.currentStreamID = objStream?.streamID!
        obj.currentContentIndex  = indexPath.row + 1
        print(obj.currentContentIndex)
        let nav = UINavigationController(rootViewController: obj)
        if let imageCell = collectionView.cellForItem(at: indexPath) as? StreamCollectionViewCell {
            nav.cc_setZoomTransition(originalView: imageCell.imgCover)
            nav.cc_swipeBackDisabled = true
        }
        self.present(nav, animated: true, completion: nil)
        // self.present(obj, animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if destinationIndexPath.row == 0 {
            return
        }
        let contentDest = objStream?.arrayContent[sourceIndexPath.row]
        objStream?.arrayContent.remove(at: sourceIndexPath.row)
        objStream?.arrayContent.insert(contentDest!, at: destinationIndexPath.row)
        DispatchQueue.main.async {
            self.viewStreamCollectionView.reloadItems(at: [destinationIndexPath,sourceIndexPath])
           
            self.reorderContent(orderArray: (self.objStream?.arrayContent)!)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        if proposedIndexPath.row == 0 {
            return originalIndexPath
        }else {
            return proposedIndexPath
        }
    }
 }


