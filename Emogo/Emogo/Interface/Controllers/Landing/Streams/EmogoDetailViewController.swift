//
//  EmogoDetailViewController.swift
//  Emogo
//
//  Created by Pushpendra on 28/08/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import MessageUI
import Messages
import Lightbox

protocol EmogoDetailViewControllerDelegate {
    func nextItemScrolled(index:Int)
}
class EmogoDetailViewController: UIViewController {
    
    @IBOutlet weak var viewStreamCollectionView: UICollectionView!
    @IBOutlet weak var lblNoContent: UILabel!
    @IBOutlet weak var btnAddContent: UIButton!
    
    var currentIndex:Int!
    var currentStream:StreamDAO!
    var stretchyHeader: StreamViewHeader!
    var image:UIImage?
    var objNavigation:UINavigationController? = nil
    var isFromCreateStream:String?
    var viewStream:String?
    var isUpload:Bool! = false
   // var objStream:StreamViewDAO?
    var streamType:String!
    var delegate:EmogoDetailViewControllerDelegate?
    // StreamList.sharedInstance.arrayViewStream
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.edgesForExtendedLayout = []
    
        // Do any additional setup after loading the view.
        prepareLayouts()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.showStatusBar()
        isSwipeEnable = true
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.stretchyHeader.imgCover.isHidden = false
    }
  
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isSwipeEnable  = false
    }

    func prepareLayouts(){
       // self.configureNavigationTite()
        self.currentStream = StreamList.sharedInstance.arrayViewStream[currentIndex]
        self.lblNoContent.isHidden = true
        self.viewStreamCollectionView.dataSource  = self
        self.viewStreamCollectionView.delegate = self
        
        
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 13.0
        layout.minimumInteritemSpacing = 13.0
        
        layout.sectionInset = UIEdgeInsetsMake(12, 13, 0, 13)
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
            
          
            
        }
        kRefreshCell = true
        configureStrechyHeader()
        configureNavigation()
        prepareHeaderData()
        configureLoadmore()
    }
    
    func configureStrechyHeader() {
        let nibViews = Bundle.main.loadNibNamed("StreamViewHeader", owner: self, options: nil)
        self.stretchyHeader = nibViews?.first as! StreamViewHeader
        self.viewStreamCollectionView.addSubview(self.stretchyHeader)
        stretchyHeader.streamDelegate = self
        stretchyHeader.viewViewCount.isHidden = true
        stretchyHeader.viewLike.isHidden = true
        stretchyHeader.maximumContentHeight = 250
        stretchyHeader.swipeToDown(height: 250)
        self.stretchyHeader.btnLikeOtherUser.tag = 111
        self.stretchyHeader.btnLike.tag = 222
        self.stretchyHeader.btnLikeOtherUser .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        self.stretchyHeader.btnLikeOtherUser .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
        self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
        self.stretchyHeader.imgCover.image = selectedImageView?.image
        self.stretchyHeader.imgCover.backgroundColor = selectedImageView?.backgroundColor
        stretchyHeader.btnCollab.isUserInteractionEnabled = true
       
        if self.currentStream?.likeStatus == "0" {
            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        }else{
            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
            
        }
         stretchyHeader.btnCollab.addTarget(self, action: #selector(self.btnColabAction), for: .touchUpInside)
        stretchyHeader.btnLikeOtherUser.addTarget(self, action: #selector(self.likeStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnLike.addTarget(self, action: #selector(self.likeStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnLikeList.addTarget(self, action: #selector(self.showLikeList(sender:)), for: .touchUpInside)
        self.viewStreamCollectionView.bringSubview(toFront: stretchyHeader)
    }
    
    
    func prepareHeaderData(){
        DispatchQueue.main.async {
            self.stretchyHeader.prepareLayout(stream: self.currentStream)
        }
        
    }

    func configureNavigation(){
        if self.navigationController?.isNavigationBarHidden == true {
            self.navigationController?.isNavigationBarHidden = false
        }
        var arrayButtons = [UIBarButtonItem]()
        
        //  let imgP = UIImage(named: "back_icon_stream")
        let imgP = UIImage(named: "back_icon")
        let btnback = UIBarButtonItem(image: imgP, style: .plain, target: self, action: #selector(self.btnCancelAction))
        self.navigationItem.leftBarButtonItem = btnback
        
       let btnRightBar = UIBarButtonItem(image: #imageLiteral(resourceName: "stream_flag"), style: .plain, target: self, action: #selector(self.showReportList))
        arrayButtons.insert(btnRightBar, at: 0)
        
        
        if self.currentStream.IDcreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            stretchyHeader.viewLike.isHidden = false
            stretchyHeader.viewViewCount.isHidden = false
            stretchyHeader.btnLike.isHidden = false
            stretchyHeader.kConstantLikeWidth.constant = 37.0
            stretchyHeader.btnLikeOtherUser.isHidden = true
            
            let imgEdit = UIImage(named: "view_nav_edit_icon")
            let rightEditBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgEdit, style: .plain, target: self, action: #selector(self.editStreamAction(sender:)))
            arrayButtons.append(rightEditBarButtonItem)
            
           // let imgDownload = UIImage(named: "share_profile")
             let imgDownload = UIImage(named: "share_profile")
            let rightDownloadBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgDownload, style: .plain, target: self, action: #selector(self.shareStreamAction(sender:)))
            arrayButtons.append(rightDownloadBarButtonItem)
            if self.currentStream.anyOneCanEdit {
                let imgAddCollab = UIImage(named: "add_user_group_icon")
                let rightAddCollabBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgAddCollab, style: .plain, target: self, action: #selector(self.btnActionaddCollaborator))
                arrayButtons.append(rightAddCollabBarButtonItem)
            }
            
            self.btnAddContent.isHidden = false
        }else {
            
            if self.currentStream.canAddContent == true {
                self.btnAddContent.isHidden = false
            }
            
            if self.currentStream.canAddPeople == true {
                let imgEdit = UIImage(named: "view_nav_edit_icon")
                let rightEditBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgEdit, style: .plain, target: self, action: #selector(self.editStreamAction(sender:)))
                arrayButtons.append(rightEditBarButtonItem)
                
                //                if self.currentStream?.anyOneCanEdit {
                //                    let imgAddCollab = UIImage(named: "add_user_group_icon")
                //                    let rightAddCollabBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgAddCollab, style: .plain, target: self, action: #selector(self.btnActionaddCollaborator))
                //                    arrayButtons.append(rightAddCollabBarButtonItem)
                //                }
            }
            
            if self.currentStream.canAddContent == true  || self.currentStream.canAddPeople == true ||  self.currentStream.anyOneCanEdit == true || self.currentStream.streamType.lowercased() == "public" {
                let imgDownload = UIImage(named: "share_profile")
                let rightDownloadBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgDownload, style: .plain, target: self, action: #selector(self.shareStreamAction(sender:)))
                arrayButtons.append(rightDownloadBarButtonItem)
            }
            
            stretchyHeader.viewLike.isHidden = true
            stretchyHeader.viewViewCount.isHidden = true
            stretchyHeader.btnLike.isHidden = true
            stretchyHeader.kConstantLikeWidth.constant = 0.0
            stretchyHeader.btnLikeOtherUser.isHidden = false
            
        }

        self.navigationItem.rightBarButtonItems = arrayButtons
        if self.currentStream.likeStatus == "0" {
            self.stretchyHeader.btnLikeOtherUser.isSelected = false
            self.stretchyHeader.btnLike.isSelected = false
                self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        }else{
            self.stretchyHeader.btnLikeOtherUser.isSelected = true
            self.stretchyHeader.btnLike.isSelected = true
             self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
        }
        self.stretchyHeader.btnLike.isHidden = false
    }
    
    func configureLoadmore(){
        
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)

        self.viewStreamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            if self?.currentStream != nil {
                self?.getStream(currentStream: self?.currentStream)
            }
        }
    }
    
    @IBAction func btnActionForAddContent(_ sender:UIButton) {
        btnActionForAddContent()
    }
    @objc func showReportList(){
        if self.currentStream.IDcreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            showDelete()
        }else {
            showReport()
        }
    }
    
    @objc func btnActionaddCollaborator(){
        
        if self.currentStream != nil {
            let actionVC : AddCollabViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddCollabView) as! AddCollabViewController
            //  actionVC.delegate = self
            //  actionVC.arraySelected = self.currentStream.arrayColab
            //  actionVC.objStream = self.objStream
            let nav = UINavigationController(rootViewController: actionVC)
            customPresentViewController(PresenterNew.AddCollabPresenter, viewController: nav, animated: true, completion: nil)
        }
        
    }
    
    func showReport(){
        let optionMenu = UIAlertController(title: kAlert_Title_ActionSheet, message: "", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: "", stream: self.currentStream.ID, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Stream)
                }
            })
        })
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: "", stream: self.currentStream.ID, content: "", completionHandler: { (isSuccess, error) in
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
        if self.currentStream != nil {
            let editVC : EditStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EditStreamView) as! EditStreamController
            editVC.streamID = self.currentStream.ID
            let nav = UINavigationController(rootViewController: editVC)
            customPresentViewController(PresenterNew.EditStreamPresenter, viewController: nav, animated: true, completion: nil)
        }
    }
    
    @objc func likeStreamAction(sender:UIButton){
        // print("Like Action")
        print(sender.tag)
        /*
        let pulsator = Pulsator()
        pulsator.radius = 50.0
        pulsator.numPulse = 2
        pulsator.backgroundColor = UIColor(red: 0, green: 0.455, blue: 0.756, alpha: 1).cgColor
        if sender.tag == 111 {
        pulsator.position =  self.stretchyHeader.btnLikeOtherUser.center
        self.stretchyHeader.layer.addSublayer(pulsator)
            pulsator.start()
        }else if sender.tag  == 222{
            pulsator.position =  self.stretchyHeader.btnLike.center
            self.stretchyHeader.btnLike.superview?.layer.addSublayer(pulsator)
            pulsator.start()
        }
 */
        if sender.tag == 111 {
            
            UIView.transition(with: self.stretchyHeader.btnLikeOtherUser,
                              duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.stretchyHeader.btnLikeOtherUser.isSelected = !self.stretchyHeader.btnLikeOtherUser.isSelected
            },
                              completion: nil)
        }else if sender.tag == 222 {
            UIView.transition(with: self.stretchyHeader.btnLike,
                              duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.stretchyHeader.btnLike.isSelected = !self.stretchyHeader.btnLike.isSelected
            },
                              completion: nil)
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            pulsator.removeFromSuperlayer()
//        }
//
//

        if self.currentStream != nil {
            if  kDefault?.bool(forKey: kHapticFeedback) == true {
                self.stretchyHeader.btnLike.isHaptic = true
                self.stretchyHeader.btnLikeOtherUser.isHaptic = true
                self.stretchyHeader.btnLike.hapticType = .impact(.light)
                self.stretchyHeader.btnLikeOtherUser.hapticType = .impact(.light)
            }else{
                self.stretchyHeader.btnLike.isHaptic = false
                self.stretchyHeader.btnLikeOtherUser.isHaptic = false
            }
            // sender.isSelected = !sender.isSelected
            if self.currentStream.likeStatus == "0" {
                self.currentStream.likeStatus = "1"
                self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
                //   self.stretchyHeader.btnLikeOtherUser .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                //  self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
            }else{
                self.currentStream.likeStatus = "0"
                self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                //    self.stretchyHeader.btnLikeOtherUser.setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .selected)
                //   self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .selected)
            }
            
            
            self.likeDislikeStream()
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
         
            default:
                break
            }
        }
    }
    
    @objc func shareStreamAction(sender:UIButton){
        // print("Share Action")
        
        //        if  kDefault?.bool(forKey: kHapticFeedback) == true {
        //            self.stretchyHeader.btnShare.isHaptic = true
        //            self.stretchyHeader.btnShare.hapticType = .impact(.light)
        //        }else{
        //            self.stretchyHeader.btnShare.isHaptic = false
        //        }
        
        
        if MFMessageComposeViewController.canSendAttachments(){
            let composeVC = MFMessageComposeViewController()
            composeVC.recipients = []
            composeVC.message = composeMessage()
            composeVC.messageComposeDelegate = self
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    @objc func btnColabAction(){
        
        if self.currentStream != nil {
          //  if currentStream.totalCollaborator.trim().isEmpty {
                let  colabcount = Int(currentStream.totalCollaborator.trim())
                if colabcount! > 1 {
                    let obj:PeopleListViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PeopleListView) as! PeopleListViewController
                    obj.streamID = self.currentStream.ID
                    obj.currentIndex = self.currentIndex
                    obj.streamNavigate = self.viewStream
                    self.navigationController?.push(viewController: obj)
                    
                }else if currentStream.IDcreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                    //                    let obj:ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                    //                    self.navigationController?.popToViewController(vc: obj)
                    
                }
                else {
                    let objPeople = PeopleDAO(peopleData: [:])
                    objPeople.fullName = self.currentStream.Author
                    objPeople.userProfileID = self.currentStream.IDcreatedBy
                    let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                    obj.objPeople = objPeople
                    self.navigationController?.push(viewController: obj)
                }
           // }
        }
    }
    
    
    @objc func showLikeList(sender:UIButton){
        
    }
    @objc  func btnCancelAction(){
        self.navigationController?.navigationBar.isTranslucent = false
        if viewStream == nil {
            let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
            self.navigationController?.popToViewController(vc: obj)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func btnPlayAction(sender:UIButton){
        ContentList.sharedInstance.arrayContent.removeAll()
        let profileContent = ContentDAO(contentData: [:])
        profileContent.coverImage = currentStream.CoverImage
        profileContent.isUploaded = true
        profileContent.type = .image
        profileContent.fileName = "SreamCover"
        profileContent.name = currentStream.Title
        profileContent.description = currentStream.description
        var array = currentStream.arrayContent.filter { $0.isAdd == false }
        array.insert(profileContent, at: 0)
        ContentList.sharedInstance.arrayContent = array
        ContentList.sharedInstance.objStream = currentStream.ID
        let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
        objPreview.isViewCount = "TRUE"
        //   objPreview.delegate = self
        let indexPath = IndexPath(row: sender.tag, section: 0)
        objPreview.currentIndex = indexPath.row + 1
        objNavigation = UINavigationController(rootViewController: objPreview)
        if let nav = objNavigation {
            if let imageCell = viewStreamCollectionView.cellForItem(at: indexPath) as? StreamContentCell {
                
                navigationImageView = imageCell.imgCover
                nav.cc_setZoomTransition(originalView: navigationImageView!)
                
                nav.cc_swipeBackDisabled = true
            }
            
            self.present(nav, animated: true, completion: nil)
            //self.hideStatusBar()
        }
        
    }
    
    
    func btnActionForAddContent() {
        ContentList.sharedInstance.arrayContent.removeAll()
        let actionVC : ActionSheetViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_ActionSheet) as! ActionSheetViewController
             actionVC.delegate = self
             actionVC.fromViewStream = true
        customPresentViewController(PresenterNew.ActionSheetViewStreamPresenter, viewController: actionVC, animated: true, completion: nil)
        
    }
    
    func btnImportAction(){
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            self?.preparePreview(assets: assets)
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
        }
        viewController.selectedAssets = [TLPHAsset]()
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 10
        configure.muteAudio = false
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
            if obj.type == .photo || obj.type == .livePhoto {
                camera.fileName = NSUUID().uuidString + ".png"
                camera.type = .image
                if obj.fullResolutionImage != nil {
                    camera.imgPreview = obj.fullResolutionImage
                    camera.color = obj.fullResolutionImage?.getColors().primary.toHexString
                    self.updateData(content: camera)
                    group.leave()
                }
                else {
                    obj.cloudImageDownload(progressBlock: { (progress) in
                    }, completionBlock: { (image) in
                        if let img = image {
                            camera.imgPreview = img
                            camera.color = img.getColors().primary.toHexString
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
                    camera.fileName = url.lastPathComponent
                    obj.phAsset?.getOrigianlImage(handler: { (img, _) in
                        if img != nil {
                            camera.imgPreview = img
                            camera.color = img?.getColors().primary.toHexString
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
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            ContentList.sharedInstance.objStream = self.currentStream.ID
            self.navigationController?.pushNormal(viewController: objPreview)
        }
    }
    
    func actionForCamera(){
        ContentList.sharedInstance.objStream = self.currentStream?.ID
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        ContentList.sharedInstance.arrayContent.removeAll()
        self.navigationController?.pushNormal(viewController: obj)
    }
    
    func btnActionForLink(){
        
        ContentList.sharedInstance.objStream = self.currentStream?.ID
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_LinkView)
        self.navigationController?.push(viewController: controller)
    }
    
    func btnActionForGiphy(){
        ContentList.sharedInstance.objStream = self.currentStream?.ID
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_GiphyView)
        self.navigationController?.push(viewController: controller)
    }
    
    
    func btnActionForMyStuff(){
        ContentList.sharedInstance.objStream = self.currentStream?.ID
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView)
        self.navigationController?.push(viewController: controller)
    }
    func btnActionForNotes(){
        ContentList.sharedInstance.objStream = self.currentStream?.ID
        let controller:CreateNotesViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_CreateNotesView) as! CreateNotesViewController
        controller.isOpenFrom = "StreamView"
        self.navigationController?.push(viewController: controller)
    }
    
    func composeMessage() -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        
        let layout = MSMessageTemplateLayout()
        
        layout.caption = stretchyHeader.lblName.text!
        layout.image  = stretchyHeader.imgCover.image?.fixOrientation()
        layout.subcaption = stretchyHeader.lblDescription.text!
        
        message.layout = layout
        //let selectedImage = StreamList.sharedInstance.arrayStream[currentIndex]
        if StreamList.sharedInstance.objStream == nil {
            let strURl = String(format: "%@/%@", kNavigation_Stream,self.currentStream.ID)
            message.url = URL(string: strURl)
        }else {
            let strURl = String(format: "%@/%@/%@", kNavigation_Stream,self.currentStream.ID,StreamList.sharedInstance.objStream!)
            message.url = URL(string: strURl)
        }
        
        return message
    }
    
    func next() {
        //   self.objStream = nil
        // isDidLoad = true
        self.viewStreamCollectionView.isHidden = true
        self.lblNoContent.isHidden = true
        self.btnAddContent.isHidden = true
     //   stretchyHeader.imgCover.image = #imageLiteral(resourceName: "stream-card-placeholder")
        if(currentIndex < StreamList.sharedInstance.arrayViewStream.count-1) {
            currentIndex = currentIndex + 1
        }
        Animation.addRightTransition(collection: self.viewStreamCollectionView)
        //self.viewStreamCollectionView.reloadData()
      
        self.updateLayOut()
     
        if self.delegate != nil {
            self.delegate?.nextItemScrolled(index: currentIndex)
        }
    }
    
    func previous() {
        //  isDidLoad = true
        
        self.viewStreamCollectionView.isHidden = true
        //   self.objStream = nil
        self.btnAddContent.isHidden = true
     //   stretchyHeader.imgCover.image = #imageLiteral(resourceName: "stream-card-placeholder")
        
        self.lblNoContent.isHidden = true
        if currentIndex != 0{
            currentIndex =  currentIndex - 1
        }
        Animation.addLeftTransition(collection: self.viewStreamCollectionView)
  //      self.viewStreamCollectionView.reloadData()
      
        self.updateLayOut()
        
        if self.delegate != nil {
            self.delegate?.nextItemScrolled(index: currentIndex)
        }
    }
    
    func updateLayOut(){
        if self.stretchyHeader != nil  {
     //       self.stretchyHeader.imgCover.image = #imageLiteral(resourceName: "stream-card-placeholder")
        }
        if ContentList.sharedInstance.objStream != nil {
            
            if self.isUpload {
                self.isUpload = false
                
                let stream = StreamList.sharedInstance.arrayViewStream[currentIndex]
                let streamID = stream.ID
                if streamID != "" {
                    self.currentStream = stream
                    //self.getStream(currentStream:nil,streamID:streamID)
                }
            }else{
                let stream = StreamList.sharedInstance.arrayViewStream[currentIndex]
                let streamID = stream.ID
                if streamID != "" {
                    self.currentStream = stream
                    //self.getStream(currentStream:nil,streamID:streamID)
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
                  self.currentStream = nil
                self.currentStream = StreamList.sharedInstance.selectedStream
                
                //self.getStream(currentStream:StreamList.sharedInstance.selectedStream)
            }
            
            if SharedData.sharedInstance.deepLinkType != "" {
                self.btnActionForAddContent()
                SharedData.sharedInstance.deepLinkType = ""
            }
        }
        print( self.currentStream.Title)
        self.viewStreamCollectionView.isHidden = false
        self.viewStreamCollectionView.reloadData()
        kRefreshCell = true
        self.viewStreamCollectionView.es.resetNoMoreData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.prepareHeaderData()
        }
    }
    
    func likeDislikeStream(){
        
        APIServiceManager.sharedInstance.apiForLikeUnlikeStream(stream: currentStream.ID, status: self.currentStream.likeStatus) {(count,status, results,error) in
            if (error?.isEmpty)! {
                self.currentStream.likeStatus = status
                self.currentStream.totalLiked = count
                //  self.currentStream.arrayLikedUsers = results!
                if status == "0" {
                    self.stretchyHeader.lblLikeCount.text = "\(self.currentStream.totalLiked.trim())"
                    self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                    //                    self.stretchyHeader.btnLikeOtherUser.isSelected = false
                    //                    self.stretchyHeader.btnLikeOtherUser.setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                    //                    self.stretchyHeader.btnLike.isSelected = false
                    //                   self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                }else{
                    self.stretchyHeader.lblLikeCount.text = "\(self.currentStream.totalLiked.trim())"
                      self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                    //                    self.stretchyHeader.btnLike.isSelected = true
                    //                    self.stretchyHeader.btnLikeOtherUser.isSelected = true
                    //                    self.stretchyHeader.btnLikeOtherUser .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
                    //                  self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
                }
                
            }else{
                HUDManager.sharedInstance.hideHUD()
                self.showToast(type: .success, strMSG: error!)
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
                if StreamList.sharedInstance.selectedStream == nil {
                    if let i = StreamList.sharedInstance.arrayViewStream.index(where: { $0.ID.trim() == self.currentStream.ID.trim() }) {
                        StreamList.sharedInstance.arrayViewStream.remove(at: i)
                    }
                }else {
                    if let i = StreamList.sharedInstance.arrayViewStream.index(where: { $0.ID.trim() == StreamList.sharedInstance.selectedStream.ID.trim() }) {
                        StreamList.sharedInstance.arrayViewStream.remove(at: i)
                    }
                }
                
                
                for obj in StreamList.sharedInstance.arrayStream {
                    if obj.ID == self.currentStream.ID.trim() {
                        if let index =  StreamList.sharedInstance.arrayStream.index(where: {$0.ID.trim() == self.currentStream.ID.trim()}) {
                            StreamList.sharedInstance.arrayStream.remove(at: index)
                        }
                    }
                }
                self.showToast(strMSG: kAlert_Stream_Deleted_Success)
                if self.viewStream != nil && self.viewStream == "fromProfile" {
                    NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                }
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
    
    func getStream(currentStream:StreamDAO?, streamID:String? = nil){
    
        var id:String! = ""
        if streamID != nil {
            id = streamID
        }else {
            id = currentStream?.ID
        }
        APIServiceManager.sharedInstance.apiForViewStream(streamID:id) { (stream, errorMsg) in
            if (errorMsg?.isEmpty)! {
                self.viewStreamCollectionView.es.noticeNoMoreData()
                self.currentStream.arrayContent = (stream?.arrayContent)!
                self.viewStreamCollectionView.reloadData()
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension EmogoDetailViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let content = currentStream.arrayContent[indexPath.row]
        return CGSize(width: content.width, height: content.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
       return currentStream.arrayContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
        
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        let content = currentStream.arrayContent[indexPath.row]
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.prepareLayout(content:content)
        if content.type == .notes {
            cell.layer.borderColor =  UIColor(r: 225, g: 225, b: 225).cgColor
            cell.layer.borderWidth = 1.0
        }else {
            cell.layer.borderWidth = 0.0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // self.hideStatusBar()
        ContentList.sharedInstance.arrayContent.removeAll()
        let profileContent = ContentDAO(contentData: [:])
        profileContent.coverImage = currentStream.CoverImage
        profileContent.isUploaded = true
        profileContent.type = .image
        profileContent.fileName = "SreamCover"
        profileContent.name = currentStream.Title
        profileContent.description = currentStream.description
       
        var array = currentStream.arrayContent.filter { $0.isAdd == false }
        array.insert(profileContent, at: 0)
        ContentList.sharedInstance.arrayContent = array
        print(array)
        ContentList.sharedInstance.objStream = currentStream.ID
        let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
        objPreview.isViewCount = "TRUE"
        objPreview.delegate = self
        objPreview.currentIndex = indexPath.row + 1
        objNavigation = UINavigationController(rootViewController: objPreview)
       
           // self.perform(#selector(statusBar), with: nil, afterDelay: 0.1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let nav = self.objNavigation {
                    if let imageCell = self.viewStreamCollectionView.cellForItem(at: indexPath) as? StreamContentCell {
                        
                        navigationImageView = imageCell.imgCover
                        nav.cc_setZoomTransition(originalView: navigationImageView!)
                        
                        nav.cc_swipeBackDisabled = true
                    }
                    
                self.present(nav, animated: true, completion: nil)
            }
        }
        
    }

    
    
}
extension EmogoDetailViewController:StreamViewHeaderDelegate,UINavigationControllerDelegate,ContentViewControllerDelegate,MFMessageComposeViewControllerDelegate  {
    
    func updateViewCount(count: String) {
        if self.stretchyHeader != nil {
            self.stretchyHeader.lblViewCount.text = count
        }
    }
    func currentPreview(content:ContentDAO,index:IndexPath){
        if let _ = objNavigation {
            
            if let tempIndex =  self.currentStream.arrayContent.index(where: {$0.contentID.trim() == content.contentID.trim()}) {
                let indexPath = IndexPath(row: tempIndex, section: 0)
                if let imageCell = viewStreamCollectionView.cellForItem(at: indexPath) as? StreamContentCell {
                    self.viewStreamCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                    navigationImageView = imageCell.imgCover
                    objNavigation!.cc_setZoomTransition(originalView: navigationImageView!)
                }
            }
        }
    }
    
    func showPreview() {
//        if self.objStream == nil{
//
//        }else{
        
       
            ContentList.sharedInstance.arrayContent.removeAll()
            let profileContent = ContentDAO(contentData: [:])
            profileContent.coverImage = currentStream.CoverImage
            profileContent.isUploaded = true
            profileContent.type = .image
            profileContent.fileName = "SreamCover"
            profileContent.name = currentStream.Title
            profileContent.description = currentStream.description
        
            var array = currentStream.arrayContent.filter { $0.isAdd == false }
            array.insert(profileContent, at: 0)
            print(array)
            ContentList.sharedInstance.arrayContent = array
            ContentList.sharedInstance.objStream = currentStream.ID
            
            let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
            objPreview.isViewCount = "TRUE"
            objPreview.delegate = self
            objPreview.currentIndex = 0
            
            objNavigation = UINavigationController(rootViewController: objPreview)
            if let nav = objNavigation {
                navigationImageView = stretchyHeader.imgCover
                nav.cc_setZoomTransition(originalView: navigationImageView!)
                nav.cc_swipeBackDisabled = true
                //self.present(nav, animated: true, completion: nil)
                self.present(nav, animated: true) {
                    self.stretchyHeader.imgCover.isUserInteractionEnabled = true
                }
            }
            self.hideStatusBar()
      // }
       // self.present(nav, animated: true, completion: nil)
        // self.openFullView(index: nil)
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

extension EmogoDetailViewController :AddCollabViewControllerDelegate{
    func selectedColabs(arrayColab: [CollaboratorDAO]) {
        self.updateLayOut()
    }
}


extension EmogoDetailViewController : ActionSheetViewControllerDelegate {
    func didSelectAction(type:String) {
        switch type {
        case "1":
            self.btnImportAction()
            break
        case "2":
            self.actionForCamera()
            break
        case "3":
            self.btnActionForLink()
            break
        case "4":
            self.btnActionForNotes()
            break
        case "5":
            self.btnActionForGiphy()
            break
        case "6":
            self.btnActionForMyStuff()
            break
        default:
            break
        }
    }
    
}


//extension EmogoDetailViewController:MFMessageComposeViewControllerDelegate {
//    
//    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//}
