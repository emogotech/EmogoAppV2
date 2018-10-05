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
import Haptica

protocol EmogoDetailViewControllerDelegate {
    func nextItemScrolled(index:Int?)
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
     var objStream:StreamViewDAO?
    var streamType:String!
    var delegate:EmogoDetailViewControllerDelegate?
    // StreamList.sharedInstance.arrayViewStream
    var objNavigationController:PMNavigationController?
    
    var longPressGesture:UILongPressGestureRecognizer!
    var selectedIndex:IndexPath?
    var nextIndexPath:IndexPath?
    
    
    
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
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData(notification:)), name: NSNotification.Name(rawValue: kUpdateStreamViewIdentifier), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kNotification_Update_Image_Cover)), object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData(notification:)), name: NSNotification.Name(rawValue: kNotification_Update_Image_Cover), object: nil)
        
       
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
         self.stretchyHeader.imgCover.isHidden = false
        self.viewStreamCollectionView.reloadData()
        if self.delegate != nil {
            self.delegate?.nextItemScrolled(index: currentIndex)
        }
    }
  
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isSwipeEnable  = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kNotification_Update_Image_Cover)), object: self)

    }
    
   
    func prepareLayouts(){
       // self.configureNavigationTite()
        
        if #available(iOS 11.0, *) {
            self.viewStreamCollectionView.contentInsetAdjustmentBehavior = .never
        }
        
        print(currentIndex)
        let contains = StreamList.sharedInstance.arrayViewStream.indices.contains(currentIndex)
        if contains{
            self.currentStream = StreamList.sharedInstance.arrayViewStream[currentIndex]
        }else {
            
        }
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
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
        self.viewStreamCollectionView.addGestureRecognizer(longPressGesture)
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
        self.stretchyHeader.btnLikeOtherUser .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
        self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
        self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        self.stretchyHeader.imgCover.image = nil
        self.stretchyHeader.imgCover.image = selectedImageView?.image
        self.stretchyHeader.imgCover.backgroundColor = selectedImageView?.backgroundColor
        stretchyHeader.btnCollab.isUserInteractionEnabled = true
//        if self.currentStream?.likeStatus == "0" {
//            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
//        }else{
//            self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
//
//        }
         stretchyHeader.btnCollab.addTarget(self, action: #selector(self.btnColabAction), for: .touchUpInside)
        stretchyHeader.btnLikeOtherUser.addTarget(self, action: #selector(self.likeStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnLike.addTarget(self, action: #selector(self.likeStreamAction(sender:)), for: .touchUpInside)
        stretchyHeader.btnLikeList.addTarget(self, action: #selector(self.showLikeList(sender:)), for: .touchUpInside)
        self.viewStreamCollectionView.bringSubview(toFront: stretchyHeader)
    }
    
    
    func prepareHeaderData(){
        DispatchQueue.main.async {
           
            self.stretchyHeader.prepareLayout(stream: self.currentStream)
            
            if self.currentStream.likeStatus == "0" {
                self.stretchyHeader.btnLikeOtherUser.isSelected = false
                self.stretchyHeader.btnLike.isSelected = false
              //  self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
            }else{
                self.stretchyHeader.btnLikeOtherUser.isSelected = true
                self.stretchyHeader.btnLike.isSelected = true
               // self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
            }
        }
        
    }

    func configureNavigation(){
        if self.navigationController?.isNavigationBarHidden == true {
            self.navigationController?.isNavigationBarHidden = false
        }
        self.navigationController?.navigationBar.barTintColor = UIColor.white
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
            
            let imgAddCollab = UIImage(named: "add_user_group_icon")
            let rightAddCollabBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgAddCollab, style: .plain, target: self, action: #selector(self.btnActionaddCollaborator))
            arrayButtons.append(rightAddCollabBarButtonItem)
            
            
            self.btnAddContent.isHidden = false
        }else {
            
            if self.currentStream.canAddContent == true {
                self.btnAddContent.isHidden = false
            }
            
            if self.currentStream.canAddPeople == true {
                let imgEdit = UIImage(named: "view_nav_edit_icon")
                let rightEditBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgEdit, style: .plain, target: self, action: #selector(self.editStreamAction(sender:)))
                arrayButtons.append(rightEditBarButtonItem)
                
            }
            
            if self.currentStream.canAddContent == true  || self.currentStream.canAddPeople == true ||  self.currentStream.anyOneCanEdit == true || self.currentStream.streamType.lowercased() == "public" {
                let imgDownload = UIImage(named: "share_profile")
                let rightDownloadBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgDownload, style: .plain, target: self, action: #selector(self.shareStreamAction(sender:)))
                arrayButtons.append(rightDownloadBarButtonItem)
            }
            
            
            if self.currentStream.canAddPeople {
                let imgAddCollab = UIImage(named: "add_user_group_icon")
                let rightAddCollabBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: imgAddCollab, style: .plain, target: self, action: #selector(self.btnActionaddCollaborator))
                arrayButtons.append(rightAddCollabBarButtonItem)
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
                //self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
        }else{
            self.stretchyHeader.btnLikeOtherUser.isSelected = true
            self.stretchyHeader.btnLike.isSelected = true
            // self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
        }
        self.stretchyHeader.btnLike.isHidden = false
    }
    
    func configureLoadmore(){
        
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
    //    let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
//        self.viewStreamCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
//            if self?.currentStream != nil {
//                self?.getStream(currentStream: self?.currentStream, streamID: "YES", isLoadMore: false)
//            }
//        }
        self.viewStreamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            if self?.currentStream != nil {
                self?.getStream(currentStream: self?.currentStream, isLoadMore: false)
            }
        }
       
    }
    
    @IBAction func btnActionForAddContent(_ sender:UIButton) {
        if kDefault?.bool(forKey: kHapticFeedback) == true {
            Haptic.impact(.heavy).generate()
            self.btnAddContent.isHaptic = true
            self.btnAddContent.hapticType = .impact(.heavy)
        }else{
            self.btnAddContent.isHaptic = false
        }
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
              actionVC.delegate = self
              actionVC.arraySelected = self.currentStream.arrayColab
            print( self.currentStream.arrayColab)
              actionVC.objStream = self.currentStream
             actionVC.objNavigationController = self.navigationController as? PMNavigationController
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
            editVC.objNavigationController = self.navigationController as? PMNavigationController
            let nav = PMNavigationController(rootViewController: editVC)
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
            if kDefault?.bool(forKey: kHapticFeedback) == true {
                Haptic.impact(.heavy).generate()
                self.stretchyHeader.btnLikeOtherUser.isHaptic = true
                self.stretchyHeader.btnLikeOtherUser.hapticType = .impact(.heavy)
            }else{
                self.stretchyHeader.btnLikeOtherUser.isHaptic = false
            }
        }else {
            if kDefault?.bool(forKey: kHapticFeedback) == true {
                Haptic.impact(.heavy).generate()
                self.stretchyHeader.btnLike.isHaptic = true
                self.stretchyHeader.btnLike.hapticType = .impact(.heavy)
            }else{
                self.stretchyHeader.btnLike.isHaptic = false
            }
        }
        
        self.stretchyHeader.btnLikeOtherUser.isUserInteractionEnabled = false
        self.stretchyHeader.btnLike.isUserInteractionEnabled = false

        if sender.tag == 111 {
            
            UIView.animate(withDuration: 0.1, animations: {() -> Void in
                self.stretchyHeader.btnLikeOtherUser.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.1, animations: {() -> Void in
                    self.stretchyHeader.btnLikeOtherUser.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.stretchyHeader.btnLikeOtherUser.isSelected = !self.stretchyHeader.btnLikeOtherUser.isSelected
                    
                    self.stretchyHeader.btnLikeOtherUser.isUserInteractionEnabled = true
                    self.stretchyHeader.btnLike.isUserInteractionEnabled = true
                
                })
            })
            
        }else if sender.tag == 222 {
            
            
            UIView.animate(withDuration: 0.1, animations: {() -> Void in
                self.stretchyHeader.btnLike.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.1, animations: {() -> Void in
                    self.stretchyHeader.btnLike.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.stretchyHeader.btnLike.isSelected = !self.stretchyHeader.btnLike.isSelected
                    
                    self.stretchyHeader.btnLikeOtherUser.isUserInteractionEnabled = true
                    self.stretchyHeader.btnLike.isUserInteractionEnabled = true
                    
                })
            })
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
            //    self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
                //   self.stretchyHeader.btnLikeOtherUser .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                //  self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
            }else{
                self.currentStream.likeStatus = "0"
              //  self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                //    self.stretchyHeader.btnLikeOtherUser.setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .selected)
                //   self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .selected)
            }
            
            
            var currentAction:Bool! = false
            
                if let mainIndex =  StreamList.sharedInstance.arrayStream.index(where: {$0.ID.trim() == currentStream.ID.trim() &&  $0.selectionType == .Liked}) {
                    print("stream disliked")
                    currentAction = false
                    StreamList.sharedInstance.arrayStream.remove(at: mainIndex)
                 //   StreamList.sharedInstance.arrayStream[mainIndex].likeStatus = self.currentStream.likeStatus
                }else {
                    currentAction = true
                    print("stream liked")
                    let tempStream = self.currentStream.copy()
                    tempStream.likeStatus  = "1"
                    let value =  Int(self.currentStream.totalLiked)! + 1
                    tempStream.totalLiked = "\(value)"
                    tempStream.selectionType = .Liked
                    print(tempStream.selectionType)
                    print(self.currentStream.selectionType)
                    StreamList.sharedInstance.arrayStream.insert(tempStream, at: 0)
                }
            
                if StreamList.sharedInstance.arrayStream.count != 0 {
                    for (index,obj) in StreamList.sharedInstance.arrayStream.enumerated() {
                        if obj.ID.trim() == currentStream.ID.trim() {
                            if currentAction {
                                StreamList.sharedInstance.arrayStream[index].likeStatus = "1"
                            }else {
                                StreamList.sharedInstance.arrayStream[index].likeStatus = "0"
                            }
                        }
                    }
                }
                
                if StreamList.sharedInstance.arrayViewStream.count != 0 {
                    
                    for (index,obj) in StreamList.sharedInstance.arrayViewStream.enumerated() {
                        if obj.ID.trim() == currentStream.ID.trim() {
                            if currentAction {
                                StreamList.sharedInstance.arrayViewStream[index].likeStatus = "1"
                            }else {
                                StreamList.sharedInstance.arrayViewStream[index].likeStatus = "0"
                            }
                        }
                    }
                    
                }
                if StreamList.sharedInstance.arrayProfileColabStream.count != 0 {
                    for (index,obj) in StreamList.sharedInstance.arrayProfileColabStream.enumerated() {
                        if obj.ID.trim() == currentStream.ID.trim() {
                            if currentAction {
                                StreamList.sharedInstance.arrayProfileColabStream[index].likeStatus = "1"
                            }else {
                                StreamList.sharedInstance.arrayProfileColabStream[index].likeStatus = "0"
                            }
                        }
                    }
                }
                if StreamList.sharedInstance.arrayProfileStream.count != 0 {
                    for (index,obj) in StreamList.sharedInstance.arrayProfileStream.enumerated() {
                        if obj.ID.trim() == currentStream.ID.trim() {
                            if currentAction {
                                StreamList.sharedInstance.arrayProfileStream[index].likeStatus = "1"
                            }else {
                                StreamList.sharedInstance.arrayProfileStream[index].likeStatus = "0"
                            }
                        }
                    }
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
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        if self.currentStream.IDcreatedBy.trim() != UserDAO.sharedInstance.user.userId.trim() {
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
                if colabcount! >= 1 {
                    let obj:PeopleListViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PeopleListView) as! PeopleListViewController
                    obj.streamID = self.currentStream.ID
                    obj.currentIndex = self.currentIndex
                    obj.streamNavigate = self.viewStream
                    self.navigationController?.push(viewController: obj)
                    
                }else if currentStream.IDcreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                    let obj:ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                        self.navigationController?.popToViewController(vc: obj)
                    
                }
                else {
                    print(currentStream.IDcreatedBy.trim())
                    print(UserDAO.sharedInstance.user.userId.trim())
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
        
      if self.currentStream != nil && self.currentStream?.arrayLikedUsers.count != 0{
            let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_LikeListView) as! LikeListViewController
            obj.objStream = self.currentStream
            self.navigationController?.push(viewController: obj)
      }
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
        profileContent.isEdit = false
        profileContent.name = currentStream.Title
        profileContent.createrImage = currentStream.userImage
        profileContent.description = currentStream.description
        var array = currentStream.arrayContent.filter { $0.isAdd == false }
        array.insert(profileContent, at: 0)
        ContentList.sharedInstance.arrayContent = array
        ContentList.sharedInstance.objStream = currentStream.ID
        let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
        objPreview.isViewCount = "TRUE"
        objPreview.streamIndex = currentIndex
        //   objPreview.delegate = self
        let indexPath = IndexPath(row: sender.tag, section: 0)
        objPreview.currentIndex = indexPath.row + 1
        let content = array[indexPath.row + 1]
        objNavigation = UINavigationController(rootViewController: objPreview)
        if let nav = objNavigation {
            if let imageCell = viewStreamCollectionView.cellForItem(at: indexPath) as? StreamContentCell {
                
                navigationImageView = nil
                let value = kFrame.size.width / CGFloat(content.width)
                kImageHeight  = CGFloat(content.height) * value
                if !content.description.trim().isEmpty  {
                    kImageHeight = kImageHeight + content.description.trim().height(withConstrainedWidth: kFrame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0)) + 25.0
                }
                if kImageHeight < viewStreamCollectionView.bounds.size.height {
                    kImageHeight = viewStreamCollectionView.bounds.size.height
                }
                navigationImageView = imageCell.imgCover
                nav.cc_setZoomTransition(originalView: navigationImageView!)
                nav.cc_swipeBackDisabled = false
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
    @objc func updateData(notification:Notification){
        if let dict = notification.userInfo {
            if let data = (dict as! [String:Any])["data"] as? [String] {
                print(data)
//                for v in 0...StreamList.sharedInstance.arrayViewStream.count-1 {
//                    let streams = StreamList.sharedInstance.arrayViewStream[v]
//                    for dataIDs in data {
//                        if streams.ID == dataIDs {
//                            self.currentIndex = v
//                            self.updateLayOut()
//                            break
//                        }
//                    }
//
                ContentList.sharedInstance.objStream = nil
                if self.currentStream != nil {
                    self.getStream(currentStream: self.currentStream,isLoadMore:false)
                }
                
                }
        }else {
        let isExist = StreamList.sharedInstance.arrayViewStream.indices.contains(self.currentIndex)
            if isExist {
                self.currentStream = StreamList.sharedInstance.arrayViewStream[self.currentIndex]
                if self.currentStream != nil {
                    self.getStream(currentStream: self.currentStream,isLoadMore:false)
                }
            }
            
        }
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
    
   @objc func updateLayOut(){
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
                let contains = StreamList.sharedInstance.arrayViewStream.indices.contains(currentIndex)
               if contains {
                    let stream = StreamList.sharedInstance.arrayViewStream[currentIndex]
                    let streamID = stream.ID
                    if streamID != "" {
                        self.currentStream = stream
                        //self.getStream(currentStream:nil,streamID:streamID)
                    }
                }
               
            }
            if SharedData.sharedInstance.deepLinkType != "" {
                self.btnActionForAddContent()
                SharedData.sharedInstance.deepLinkType = ""
            }
            ContentList.sharedInstance.objStream = nil
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
                //  self.getStream(currentStream:self.currentStream , isLoadMore: true)
            }
            
            if SharedData.sharedInstance.deepLinkType != "" {
                self.btnActionForAddContent()
                SharedData.sharedInstance.deepLinkType = ""
            }
        }
        print( self.currentStream)
        self.viewStreamCollectionView.isHidden = false
        self.viewStreamCollectionView.reloadData()
        kRefreshCell = true
        self.viewStreamCollectionView.es.resetNoMoreData()
        if self.currentStream.canAddContent == true {
            self.btnAddContent.isHidden = false
        }
       configureNavigation()
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
                   // self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                    //                    self.stretchyHeader.btnLikeOtherUser.isSelected = false
                    //                    self.stretchyHeader.btnLikeOtherUser.setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                    //                    self.stretchyHeader.btnLike.isSelected = false
                    //                   self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                }else{
                    self.stretchyHeader.lblLikeCount.text = "\(self.currentStream.totalLiked.trim())"
                   //   self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                    //                    self.stretchyHeader.btnLike.isSelected = true
                    //                    self.stretchyHeader.btnLikeOtherUser.isSelected = true
                    //                    self.stretchyHeader.btnLikeOtherUser .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
                    //                  self.stretchyHeader.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .selected)
                }
                
                
                if StreamList.sharedInstance.arrayStream.count != 0 {
                    for (index,obj) in StreamList.sharedInstance.arrayStream.enumerated() {
                        if obj.ID.trim() == self.currentStream.ID.trim() {
                              StreamList.sharedInstance.arrayStream[index].totalLiked = count
                            StreamList.sharedInstance.arrayStream[index].totalLikeCount = count
                            print(StreamList.sharedInstance.arrayStream[index].totalLikeCount)
                        }
                    }
                }
                
                if StreamList.sharedInstance.arrayViewStream.count != 0 {
                    
                    for (index,obj) in StreamList.sharedInstance.arrayViewStream.enumerated() {
                        if obj.ID.trim() == self.currentStream.ID.trim() {
                            StreamList.sharedInstance.arrayViewStream[index].totalLiked = count
                            StreamList.sharedInstance.arrayViewStream[index].totalLikeCount = count
                            print(StreamList.sharedInstance.arrayViewStream[index].totalLikeCount)

                           
                        }
                    }
                    
                }
                if StreamList.sharedInstance.arrayProfileColabStream.count != 0 {
                    for (index,obj) in StreamList.sharedInstance.arrayProfileColabStream.enumerated() {
                        if obj.ID.trim() == self.currentStream.ID.trim() {
                                StreamList.sharedInstance.arrayProfileColabStream[index].totalLiked = count
                              StreamList.sharedInstance.arrayProfileColabStream[index].totalLikeCount = count
                            print(StreamList.sharedInstance.arrayProfileColabStream[index].totalLikeCount)

                        }
                    }
                }
                if StreamList.sharedInstance.arrayProfileStream.count != 0 {
                    for (index,obj) in StreamList.sharedInstance.arrayProfileStream.enumerated() {
                        if obj.ID.trim() == self.currentStream.ID.trim() {
                                StreamList.sharedInstance.arrayProfileStream[index].totalLiked = count
                                  StreamList.sharedInstance.arrayProfileStream[index].totalLikeCount = count
                            print(StreamList.sharedInstance.arrayProfileStream[index].totalLikeCount)

                            
                        }
                    }
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
                self.showToast(strMSG: kAlert_Stream_Deleted_Success)
                if StreamList.sharedInstance.selectedStream == nil {
                    if let i = StreamList.sharedInstance.arrayViewStream.index(where: { $0.ID.trim() == self.currentStream.ID.trim() }) {
                        StreamList.sharedInstance.arrayViewStream.remove(at: i)
                    }
                }else {
                    if let i = StreamList.sharedInstance.arrayViewStream.index(where: { $0.ID.trim() == StreamList.sharedInstance.selectedStream.ID.trim() }) {
                        StreamList.sharedInstance.arrayViewStream.remove(at: i)
                    
                    }
                }
                print("currrent--->\(self.currentIndex)")
                
                print("currrent--->\(self.currentIndex - 1)")
                if self.currentIndex < 0 {
                    self.currentIndex = 0
                }
                
                for obj in StreamList.sharedInstance.arrayStream {
                    if obj.ID == self.currentStream.ID.trim() {
                        if let index =  StreamList.sharedInstance.arrayStream.index(where: {$0.ID.trim() == self.currentStream.ID.trim()}) {
                            StreamList.sharedInstance.arrayStream.remove(at: index)
                        }
                    }
                }
                
                for obj in StreamList.sharedInstance.arrayProfileStream {
                    if obj.ID == self.currentStream.ID.trim() {
                        if let index =  StreamList.sharedInstance.arrayProfileStream.index(where: {$0.ID.trim() == self.currentStream.ID.trim()}) {
                            StreamList.sharedInstance.arrayProfileStream.remove(at: index)
                        }
                    }
                }
                
                for obj in StreamList.sharedInstance.arrayProfileColabStream {
                    if obj.ID == self.currentStream.ID.trim() {
                        if let index =  StreamList.sharedInstance.arrayProfileColabStream.index(where: {$0.ID.trim() == self.currentStream.ID.trim()}) {
                            StreamList.sharedInstance.arrayProfileColabStream.remove(at: index)
                        }
                    }
                }
                
                
                if self.viewStream != nil && self.viewStream == "fromProfile" {
                    NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                }
                
                if StreamList.sharedInstance.arrayViewStream.count == 0 {
                    if self.delegate != nil {
                        self.delegate?.nextItemScrolled(index: nil)
                    }
                    self.navigationController?.navigationBar.isTranslucent = false
                    if self.isFromCreateStream  != nil  {
                        let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
                        self.navigationController?.popToViewController(vc: obj)
                    }else {
                        self.navigationController?.popNormal()
                    }
                }else {
                    let contains = StreamList.sharedInstance.arrayViewStream.indices.contains(self.currentIndex + 1)
                    if contains {
                        self.next()
                    }else {
                        self.previous()
                    }
                }
                
                //self.prepareList()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getStream(currentStream:StreamDAO?, streamID:String? = nil,isLoadMore:Bool? = nil){
        
        let id = currentStream?.ID
        APIServiceManager.sharedInstance.apiForViewStream(streamID:id!) { (stream, errorMsg) in
            if (errorMsg?.isEmpty)! {
                if streamID != nil {
                    self.viewStreamCollectionView.es.stopPullToRefresh()
                }
                self.viewStreamCollectionView.es.noticeNoMoreData()
                self.currentStream.arrayContent = (stream?.arrayContent)!
                self.currentStream.arrayColab = (stream?.arrayColab)!
                self.currentStream.colabImageFirst = (stream?.colabImageFirst)!
                self.currentStream.colabImageSecond = (stream?.colabImageSecond)!
                self.currentStream.userImage = (stream?.userImage)!
                self.currentStream.totalCollaborator = (stream?.totalCollaborator)!
                if isLoadMore! {
                    self.updateLayOut()
                }
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
    func reorderContent(orderArray:[ContentDAO]) {
        
        APIServiceManager.sharedInstance.apiForReorderStreamContent(orderArray: orderArray, streamID: (self.currentStream?.ID)!) { (isSuccess,errorMSG)  in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.selectedIndex = nil
                self.viewStreamCollectionView.reloadData()
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
        
        if selectedIndex != nil {
            let tempContent = currentStream.arrayContent[self.selectedIndex!.row]
            return CGSize(width: tempContent.width, height: tempContent.height)
        }
        
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
        self.viewStreamCollectionView.isUserInteractionEnabled = false
        ContentList.sharedInstance.arrayContent.removeAll()
        let profileContent = ContentDAO(contentData: [:])
        profileContent.coverImage = currentStream.CoverImage
        profileContent.isUploaded = true
        profileContent.type = .image
        profileContent.fileName = "SreamCover"
        profileContent.isEdit = false
        profileContent.name = currentStream.Title
        profileContent.description = currentStream.description
        profileContent.createrImage = currentStream.userImage

        var array = currentStream.arrayContent.filter { $0.isAdd == false }
        array.insert(profileContent, at: 0)
        ContentList.sharedInstance.arrayContent = array
        print(array)
        ContentList.sharedInstance.objStream = currentStream.ID
        let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
        objPreview.isViewCount = "TRUE"
        objPreview.delegate = self
        objPreview.strTitle = currentStream.Title
        objPreview.currentIndex = indexPath.row + 1
        objPreview.streamIndex = currentIndex
        
        objNavigation = UINavigationController(rootViewController: objPreview)
        let content = array[indexPath.row + 1]
           // self.perform(#selector(statusBar), with: nil, afterDelay: 0.1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let nav = self.objNavigation {
                    if let imageCell = self.viewStreamCollectionView.cellForItem(at: indexPath) as? StreamContentCell {
                        navigationImageView = nil
                        let value = kFrame.size.width / CGFloat(content.width)
                        kImageHeight  = CGFloat(content.height) * value
                        if !content.description.trim().isEmpty  {
                            kImageHeight = kImageHeight + content.description.trim().height(withConstrainedWidth: kFrame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0)) + 25.0
                        }
                        if kImageHeight < self.viewStreamCollectionView.bounds.size.height {
                            kImageHeight = self.viewStreamCollectionView.bounds.size.height
                        }
                        navigationImageView = imageCell.imgCover
                        nav.cc_setZoomTransition(originalView: navigationImageView!)
                        nav.cc_swipeBackDisabled = false
                    }
                    self.present(nav, animated: true, completion: {
                        self.viewStreamCollectionView.isUserInteractionEnabled = true
                    })
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
        
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if destinationIndexPath.row == 0 {
            return
        }
        let contentDest = currentStream?.arrayContent[sourceIndexPath.row]
        currentStream?.arrayContent.remove(at: sourceIndexPath.row)
        currentStream?.arrayContent.insert(contentDest!, at: destinationIndexPath.row)
        print("moving ended")
        DispatchQueue.main.async {
            self.viewStreamCollectionView.reloadItems(at: [destinationIndexPath,sourceIndexPath])
            HUDManager.sharedInstance.showHUD()
            self.reorderContent(orderArray: (self.currentStream?.arrayContent)!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.item == 0 {
            return IndexPath(item: 1, section: 0)
        }else  {
            return proposedIndexPath
        }
    }

    
    
}
extension EmogoDetailViewController:StreamViewHeaderDelegate,UINavigationControllerDelegate,ContentViewControllerDelegate,MFMessageComposeViewControllerDelegate  {
    
    func updateViewCount(count: String) {
        if self.stretchyHeader != nil {
            self.stretchyHeader.lblViewCount.text = count
            
            if StreamList.sharedInstance.arrayStream.count != 0 {
                for (index,obj) in StreamList.sharedInstance.arrayStream.enumerated() {
                    if obj.ID.trim() == currentStream.ID.trim() {
                        StreamList.sharedInstance.arrayStream[index].viewCount = count
                    }
                }
            }
            
            if StreamList.sharedInstance.arrayViewStream.count != 0 {
                
                for (index,obj) in StreamList.sharedInstance.arrayViewStream.enumerated() {
                    if obj.ID.trim() == currentStream.ID.trim() {
                        StreamList.sharedInstance.arrayViewStream[index].viewCount = count
                    }
                }
                
            }
            if StreamList.sharedInstance.arrayProfileColabStream.count != 0 {
                for (index,obj) in StreamList.sharedInstance.arrayProfileColabStream.enumerated() {
                    if obj.ID.trim() == currentStream.ID.trim() {
                        StreamList.sharedInstance.arrayProfileColabStream[index].viewCount = count
                    }
                }
            }
            if StreamList.sharedInstance.arrayProfileStream.count != 0 {
                for (index,obj) in StreamList.sharedInstance.arrayProfileStream.enumerated() {
                    if obj.ID.trim() == currentStream.ID.trim() {
                        StreamList.sharedInstance.arrayProfileStream[index].viewCount = count
                    }
                }
            }
        
        }
    }
    func currentPreview(content:ContentDAO,index:IndexPath){
        if let _ = objNavigation {
            
            if let tempIndex =  self.currentStream.arrayContent.index(where: {$0.contentID.trim() == content.contentID.trim()}) {
                let indexPath = IndexPath(row: tempIndex, section: 0)
                if let imageCell = viewStreamCollectionView.cellForItem(at: indexPath) as? StreamContentCell {
                    self.viewStreamCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                    navigationImageView = nil
                    let value = kFrame.size.width / CGFloat(content.width)
                    kImageHeight  = CGFloat(content.height) * value
                    if !content.description.trim().isEmpty  {
                        kImageHeight = kImageHeight + content.description.trim().height(withConstrainedWidth: kFrame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0)) + 25.0
                    }
                    if kImageHeight < self.viewStreamCollectionView.bounds.size.height {
                        kImageHeight = self.viewStreamCollectionView.bounds.size.height
                    }
                    navigationImageView = imageCell.imgCover
                    objNavigation!.cc_setZoomTransition(originalView: navigationImageView!)
                    objNavigation!.cc_swipeBackDisabled = false
                }
            }
        }
    }
    
    func showPreview() {
       
            ContentList.sharedInstance.arrayContent.removeAll()
            let content = ContentDAO(contentData: [:])
            content.coverImage = currentStream.CoverImage
            content.isUploaded = true
            content.type = .image
            content.fileName = "SreamCover"
            content.name = currentStream.Title
            content.createrImage = currentStream.userImage
            content.description = currentStream.description
            content.height = currentStream.hieght
            content.width = currentStream.width
            content.isEdit = false
            var array = currentStream.arrayContent.filter { $0.isAdd == false }
            array.insert(content, at: 0)
            print(array)
            ContentList.sharedInstance.arrayContent = array
            ContentList.sharedInstance.objStream = currentStream.ID
            
            let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
            objPreview.isViewCount = "TRUE"
            objPreview.delegate = self
            objPreview.currentIndex = 0
            objPreview.streamIndex = currentIndex
            objPreview.strTitle = currentStream.Title
            objNavigation = UINavigationController(rootViewController: objPreview)
            if let nav = objNavigation {
                navigationImageView = nil
                let value = kFrame.size.width / CGFloat(content.width)
                kImageHeight  = CGFloat(content.height) * value
                if !content.description.trim().isEmpty  {
                    kImageHeight = kImageHeight + content.description.trim().height(withConstrainedWidth: kFrame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0)) + 25.0
                }
                if kImageHeight < self.viewStreamCollectionView.bounds.size.height {
                    kImageHeight = self.viewStreamCollectionView.bounds.size.height
                }
                navigationImageView = stretchyHeader.imgCover
                nav.cc_setZoomTransition(originalView: navigationImageView!)
                nav.cc_swipeBackDisabled = false
                //self.present(nav, animated: true, completion: nil)
                self.present(nav, animated: true) {
                    self.stretchyHeader.imgCover.isUserInteractionEnabled = true
                }
            }
      // }
       // self.present(nav, animated: true, completion: nil)
        // self.openFullView(index: nil)
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

extension EmogoDetailViewController :AddCollabViewControllerDelegate{
    func dismissSuperView(objPeople: PeopleDAO?) {
        self.dismiss(animated: false) {
            if objPeople == nil {
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.navigationController?.popToViewController(vc: obj)
            }else {
                let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                obj.objPeople = objPeople
                self.navigationController?.popToViewController(vc: obj)
            }
        }
    }
    
    
    
    func selectedColabs(arrayColab: [CollaboratorDAO]) {
        self.getStream(currentStream: self.currentStream,isLoadMore:true)
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
