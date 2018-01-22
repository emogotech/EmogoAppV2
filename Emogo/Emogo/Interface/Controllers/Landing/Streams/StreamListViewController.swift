//
//  StreamListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import XLActionController

class StreamListViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var streamCollectionView: UICollectionView!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var lblNoResult: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var txtSearch : UITextField!
    
    var lastIndex             : Int = 2
    var isPullToRefreshRemoved:Bool! = false
    private var lastContentOffset: CGFloat = 0
    
    //Search
    @IBOutlet weak var viewSearchMain: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewCollection: UIView!
    @IBOutlet weak var viewPeople: UIView!
    @IBOutlet weak var viewStream: UIView!
    @IBOutlet weak var btnStreamSearch          : UIButton!
    @IBOutlet weak var btnPeopleSearch          : UIButton!
    @IBOutlet weak var lblStreamSearch          : UILabel!
    @IBOutlet weak var lblPeopleSearch          : UILabel!
    @IBOutlet weak var lblSearch          : UILabel!
    @IBOutlet weak var btnSearch          : UIButton!
    
    var isSearch : Bool = false
    var isTapPeople : Bool = false
    var isTapStream : Bool = false
    var isUpdateList:Bool! = false
    var searchStr : String!
    var heightPeople                            : NSLayoutConstraint?
    var heightStream                            : NSLayoutConstraint?
    //-=-------------------------
    
    @IBOutlet weak var menuView: FSPagerView! {
        didSet {
            self.menuView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            menuView.backgroundView?.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 0)
            menuView.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 0)
            menuView.itemSize = CGSize(width: 130, height: 130)
            menuView.transformer = FSPagerViewTransformer(type:.ferrisWheel)
            menuView.delegate = self
            menuView.dataSource = self
            menuView.isHidden = true
            menuView.isExclusiveTouch = true
            menuView.collectionView.accessibilityLabel = "BottomMenuCollectionView"
        }
    }
    // Varibales
    private let headerNib = UINib(nibName: "StreamSearchCell", bundle: Bundle.main)
    var menu = MenuDAO()
    var isMenuOpen:Bool! = false
    var isPeopleList:Bool! = false
    var isLoadFirst:Bool! = true
    var collectionLayout = CHTCollectionViewWaterfallLayout()

    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.streamCollectionView.accessibilityLabel = "StreamCollectionView"
        setupAnchor()
        prepareLayouts()
        txtSearch.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureLandingNavigation()
        menuView.isHidden = true
        self.viewMenu.isHidden = false
        if SharedData.sharedInstance.deepLinkType != "" {
            self.checkDeepLinkURL()
        }
        self.prepareList()
        self.streamCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareLayoutForApper()
    }
    
    func checkDeepLinkURL() {
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeAddContent{
            let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
            kContainerNav = "1"
            currentTag = 111
            ContentList.sharedInstance.objStream = SharedData.sharedInstance.streamID
            arraySelectedContent = [ContentDAO]()
            arrayAssests = [ImportDAO]()
            ContentList.sharedInstance.arrayContent.removeAll()
            self.navigationController?.push(viewController: obj)
            SharedData.sharedInstance.deepLinkType = ""
        }
        
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeEditStream{
            let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
            obj.streamID = SharedData.sharedInstance.streamID
            self.navigationController?.push(viewController: obj)
            SharedData.sharedInstance.deepLinkType = ""
        }
        
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeEditContent {
            getStream(currentStreamID: SharedData.sharedInstance.streamID, currentConytentID: SharedData.sharedInstance.contentID)
        }
        
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypePeople {
            let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
            obj.objPeople = SharedData.sharedInstance.peopleInfo!
            self.navigationController?.push(viewController: obj)
            SharedData.sharedInstance.deepLinkType = ""
        }
        
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeProfile {
            let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView)
            self.navigationController?.push(viewController: obj)
            SharedData.sharedInstance.deepLinkType = ""
        }
        
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        // Logout User if Token Is Expired
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil, queue: nil) { (notification) in
            kDefault?.set(false, forKey: kUserLogggedIn)
            kDefault?.removeObject(forKey: kUserLogggedInData)
            let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_InitialView)
            self.navigationController?.reverseFlipPush(viewController: obj)
        }
        
        HUDManager.sharedInstance.showHUD()
        menuView.currentIndex = currentStreamType.hashValue
        self.getStreamList(type:.start,filter: currentStreamType)
        print("current index ----\(currentStreamType)")
        print("current index ----\(currentStreamType.hashValue)")
        
        // Attach datasource and delegate
        self.lblNoResult.isHidden = true
        self.streamCollectionView.dataSource  = self
        self.streamCollectionView.delegate = self
        
        // Change individual layout attributes for the spacing between cells
        collectionLayout.minimumColumnSpacing = 8.0
        collectionLayout.minimumInteritemSpacing = 8.0
        collectionLayout.sectionInset = UIEdgeInsetsMake(10, 8, 0, 8)
        collectionLayout.columnCount = 2
        // Collection view attributes
        self.streamCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.streamCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.streamCollectionView.collectionViewLayout = collectionLayout
        
        self.configureLoadMoreAndRefresh()
        
        self.btnStreamSearch.isUserInteractionEnabled = false
        self.btnPeopleSearch.isUserInteractionEnabled = true
        lblSearch.layer.cornerRadius = 20.0
        lblSearch.clipsToBounds = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.streamCollectionView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.streamCollectionView.addGestureRecognizer(swipeLeft)
        
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.menuView.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.viewMenu.addGestureRecognizer(swipeUp)
        
    }
    
    
    func prepareList(){
        if isUpdateList {
            isUpdateList = false
            if  menuView.currentIndex == 4 {
                menuView.currentIndex = 4
                collectionLayout.columnCount = 3
                self.actionForPeopleList()
            }else{
                collectionLayout.columnCount = 2
                HUDManager.sharedInstance.showHUD()
                self.getStreamList(type:.start,filter: currentStreamType)
            }
        }
        
        if  currentStreamType == StreamType.emogoStreams  && StreamList.sharedInstance.arrayStream.count == 0 {
            self.lblNoResult.isHidden = false
        }else{
            self.lblNoResult.isHidden = true
        }
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
                ContentList.sharedInstance.arrayContent.removeAll()
                ContentList.sharedInstance.objStream = nil
                kContainerNav = ""
                 self.addLeftTransitionView(subtype: kCATransitionFromRight)
                self.navigationController?.pushViewController(obj, animated: false)
                break
            case UISwipeGestureRecognizerDirection.right:
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.addLeftTransitionView(subtype: kCATransitionFromLeft)
                self.navigationController?.pushViewController(obj, animated: false)
                break
                
            case UISwipeGestureRecognizerDirection.down:
                self.menuView.isHidden = true
                self.viewMenu.isHidden = false
                Animation.viewSlideInFromTopToBottom(views: self.viewMenu)
                isMenuOpen = false
                break
                
            case UISwipeGestureRecognizerDirection.up:
                self.menuView.isHidden = false
                self.viewMenu.isHidden = true
                Animation.viewSlideInFromTopToBottom(views: self.menuView)
                isMenuOpen = true
                break
                
            default:
                break
            }
        }
    }
    
   
    
    func setupAnchor(){
        viewSearch.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        viewStream.translatesAutoresizingMaskIntoConstraints = false
        viewPeople.translatesAutoresizingMaskIntoConstraints = false
        heightStream = viewStream.heightAnchor.constraint(equalToConstant: 40)
        heightStream?.isActive = false
        viewStream.isHidden = false
        viewPeople.isHidden = false
        viewStream.topAnchor.constraint(equalTo: viewSearch.topAnchor).isActive = true
        viewStream.leftAnchor.constraint(equalTo: viewSearch.leftAnchor).isActive = true
        viewStream.rightAnchor.constraint(equalTo: viewSearch.rightAnchor).isActive = true
        viewStream.bottomAnchor.constraint(equalTo: viewPeople.topAnchor).isActive = true
        
        viewPeople.bottomAnchor.constraint(equalTo: viewSearch.bottomAnchor).isActive = true
        heightPeople = viewPeople.heightAnchor.constraint(equalToConstant: 40)
        heightPeople?.isActive = true
        viewPeople.leftAnchor.constraint(equalTo: viewSearch.leftAnchor).isActive = true
        viewPeople.rightAnchor.constraint(equalTo: viewSearch.rightAnchor).isActive = true
    }
    
    // MARK: - Prepare Layouts When View Appear
    
    func prepareLayoutForApper(){
        self.viewMenu.layer.contents = UIImage(named: "home_gradient")?.cgImage
        menuView.isAddBackground = false
        menuView.isAddTitle = true
        menuView.lblCurrentType.text = menu.arrayMenu[menuView.currentIndex].iconName
        self.menuView.layer.contents = UIImage(named: "bottomPager")?.cgImage
        if isLoadFirst {
            UIView.animate(withDuration: 0.1, animations: {
                self.viewSearch.frame = CGRect(x: self.viewSearch.frame.origin.x, y: self.viewSearchMain.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height-(self.navigationController?.navigationBar.frame.size.height)!)
                self.viewCollection.frame = self.viewSearch.frame
            })
            self.isLoadFirst = false
        }
        if(SharedData.sharedInstance.deepLinkType == kDeepLinkTypePeople){
            pagerView(menuView, didSelectItemAt: 4)
            menuView.currentIndex = 4
            self.viewMenu.isHidden = true
            self.menuView.isHidden = false
            SharedData.sharedInstance.deepLinkType = ""
        }
        if isSearch {
            self.viewMenu.isHidden = true
        }
    }
//
//    @objc func callingAfterOneSec(){
//
//    }
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.streamCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if (self?.isSearch)! && (self?.isTapPeople)! {
                self?.getPeopleGlobleSearch(searchText: (self?.searchStr)!, type: .start)
            }
            else if (self?.isSearch)! && (self?.isTapStream)! {
                self?.getStreamGlobleSearch(searchText: (self?.searchStr)!, type: .start)
            }
            else if (self?.isPeopleList)! {
                self?.getUsersList(type:.up)
            }else {
                self?.getStreamList(type:.up,filter:currentStreamType)
            }
        }
        
        self.streamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            if (self?.isSearch)! && (self?.isTapPeople)! {
                self?.getPeopleGlobleSearch(searchText: (self?.searchStr)!, type: .up)
            }
            else if (self?.isSearch)! && (self?.isTapStream)! {
                self?.getStreamGlobleSearch(searchText: (self?.searchStr)!, type: .up)
            }
            else if (self?.isPeopleList)! {
                self?.getUsersList(type:.up)
            }else {
                self?.getStreamList(type:.up,filter:currentStreamType)
            }
        }
        self.streamCollectionView.expiredTimeInterval = 20.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.streamCollectionView.es.autoPullToRefresh()
        }
    }
    
    func addLoadMore(){
        if  self.isPullToRefreshRemoved {
            self.isPullToRefreshRemoved  = false
            let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
            self.streamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
                
                if (self?.isSearch)! && (self?.isTapPeople)! {
                    self?.getPeopleGlobleSearch(searchText: (self?.searchStr)!, type: .down)
                }
                else if (self?.isSearch)! && (self?.isTapStream)! {
                    self?.getStreamGlobleSearch(searchText: (self?.searchStr)!, type: .down)
                }
                else if (self?.isPeopleList)! {
                    self?.getUsersList(type:.down)
                }
                else {
                    self?.getStreamList(type:.down,filter:currentStreamType)
                }
            }
        }
    }
    // MARK: -  Action Methods And Selector
    
    override func btnCameraAction() {
        actionForCamera()
    }
    
    override func btnHomeAction() {
        
    }
    
    override func btnMyProfileAction() {
        isUpdateList = true
        let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView)
        self.navigationController?.pushNormal(viewController: obj)
    }
    
    @IBAction func btnActionAdd(_ sender: Any) {
        ContentList.sharedInstance.arrayContent.removeAll()
        let actionController = ActionSheetController()
        actionController.addAction(Action(ActionData(title: "Photos & Videos", subtitle: "", image: #imageLiteral(resourceName: "action_photo_video")), style: .default, handler: { action in
            self.btnImportAction()
        }))
        actionController.addAction(Action(ActionData(title: "Camera", subtitle: "", image: #imageLiteral(resourceName: "action_camera_icon")), style: .default, handler: { action in
           
            self.actionForCamera()
            
        }))
        actionController.addAction(Action(ActionData(title: "Link", subtitle: "", image: #imageLiteral(resourceName: "action_link_icon")), style: .default, handler: { action in
            
            self.btnActionForLink()
        }))
        
        actionController.addAction(Action(ActionData(title: "Gif", subtitle: "", image: #imageLiteral(resourceName: "action_giphy_icon")), style: .default, handler: { action in
            
           self.btnActionForGiphy()
        }))
        
        actionController.addAction(Action(ActionData(title: "My Stuff", subtitle: "", image: #imageLiteral(resourceName: "action_my_stuff")), style: .default, handler: { action in
            
            self.btnActionForMyStuff()

        }))
        
        
        actionController.addAction(Action(ActionData(title: "Create New Stream", subtitle: "", image: #imageLiteral(resourceName: "action_stream_add_icon")), style: .default, handler: { action in
             self.actionForAddStream()
        }))
        
        actionController.headerData = "ADD FROM"
        present(actionController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnActionOpenMenu(_ sender: Any) {
        self.viewMenu.isHidden = true
        isMenuOpen = true
        self.menuView.isHidden = false
        Animation.viewSlideInFromTopToBottom(views: self.menuView)
        //  Animation.viewSlideInFromBottomToTop(views:self.menuView)
    }
    
    @IBAction func btnSearchAction(_ sender:UIButton) {
        if btnSearch.tag == 1 {
            txtSearch.text = ""
            btnSearch.setImage(#imageLiteral(resourceName: "search_icon_iphone"), for: UIControlState.normal)
            btnSearch.tag = 0
            isUpdateList = true
            self.prepareList()
            UIView.animate(withDuration: 0.1, delay: 0.1, options: [.curveEaseOut], animations: {
                self.viewSearch.frame = CGRect(x: self.viewSearch.frame.origin.x, y: self.viewSearchMain.frame.origin.y, width: self.viewSearchMain.frame.size.width, height: self.view.frame.size.height-self.viewSearchMain.frame.origin.y)
                self.viewCollection.frame = self.viewSearch.frame
            }, completion: nil)
            self.viewMenu.isHidden = false
            isSearch = false
        }
        else{
            if txtSearch.text?.trim() != "" {
                btnSearch.tag = 1
                btnSearch.setImage(#imageLiteral(resourceName: "cross_search"), for: UIControlState.normal)
                self.didTapActionSearch(searchString: (txtSearch.text?.trim())!)
                self.viewMenu.isHidden = true
                isSearch = true
            
            }
        }
    }
    
    @IBAction func btnActionStreamSearch(_ sender : UIButton){
        switch sender.tag {
            
        case 0:         //Stream
            lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            lblPeopleSearch.textColor = #colorLiteral(red: 0.6618840643, green: 0.6980385184, blue: 0.7022444606, alpha: 1)
            self.streamCollectionView.isHidden = true
            PeopleList.sharedInstance.requestURl = ""
            StreamList.sharedInstance.requestURl = ""
            collectionLayout.columnCount = 2
            self.getStreamGlobleSearch(searchText: searchStr, type: .start)
            break
            
        case 1:         //People
            collectionLayout.columnCount = 3
            lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            lblStreamSearch.textColor = #colorLiteral(red: 0.6618840643, green: 0.6980385184, blue: 0.7022444606, alpha: 1)
            self.streamCollectionView.isHidden = true
            PeopleList.sharedInstance.requestURl = ""
            StreamList.sharedInstance.requestURl = ""
            self.getPeopleGlobleSearch(searchText: searchStr, type: .start)
            break
            
        default:
            break
            
        }
    }
    
    // MARK: - Class Methods
    func checkForListSize() {
        if self.streamCollectionView.frame.size.height - 100 < self.streamCollectionView.contentSize.height {
            print("Greater")
            self.viewMenu.layer.contents = UIImage(named: "home_gradient")?.cgImage
        }else {
            print("less")
            self.viewMenu.layer.contents = nil
            self.btnMenu.transform = CGAffineTransform.init(rotationAngle: 0)
        }
    }
    
    // MARK: - API Methods

    func getStreamList(type:RefreshType,filter:StreamType){
        if type == .start || type == .up {
            self.addLoadMore()
            PeopleList.sharedInstance.arrayPeople.removeAll()
            StreamList.sharedInstance.arrayStream.removeAll()
            self.streamCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.streamCollectionView.es.stopLoadingMore()
                self.streamCollectionView.es.removeRefreshFooter()
                self.isPullToRefreshRemoved = true
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.streamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.streamCollectionView.es.stopLoadingMore()
            }
            self.lblNoResult.isHidden = true
            if StreamList.sharedInstance.arrayStream.count == 0 {
                self.lblNoResult.isHidden = false
                self.lblNoResult.text = kAlert_No_Stream_found

            }
            self.streamCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    func getUsersList(type:RefreshType){
        if type == .up {
            self.addLoadMore()
            StreamList.sharedInstance.arrayStream.removeAll()
            PeopleList.sharedInstance.arrayPeople.removeAll()
            self.streamCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetPeopleList(type:type) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.streamCollectionView.es.stopLoadingMore()
                self.streamCollectionView.es.removeRefreshFooter()
                self.isPullToRefreshRemoved = true
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.streamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.streamCollectionView.es.stopLoadingMore()
            }
            self.streamCollectionView.reloadData()
            
            self.lblNoResult.isHidden = true
            if PeopleList.sharedInstance.arrayPeople.count == 0 {
                self.lblNoResult.text = kAlert_No_User_Record_Found
                self.lblNoResult.isHidden = false
            }
            
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getStream(currentStreamID:String, currentConytentID:String){
        APIServiceManager.sharedInstance.apiForViewStream(streamID: currentStreamID) { (stream, errorMsg) in
            if (errorMsg?.isEmpty)! {
                let allContents = stream?.arrayContent
                if ((allContents?.count)! > 0){
                    
                    let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                    
                    for i in 0...(stream?.arrayContent.count)!-1 {
                        let data : ContentDAO = allContents![i]
                        print(data.contentID)
                        print(SharedData.sharedInstance.iMessageNavigationCurrentContentID)
                        if data.contentID ==  currentConytentID {
                            objPreview.seletedImage = data
                            objPreview.isEdit = true
                            self.navigationController?.push(viewController: objPreview)
                            break
                        }
                    }
                }
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    func getPeopleGlobleSearch(searchText:String, type:RefreshType){
        lblNoResult.text = kAlert_No_User_Record_Found
        if type != .up {
            HUDManager.sharedInstance.showHUD()
        }
        if type == .start || type == .up {
            self.addLoadMore()
            PeopleList.sharedInstance.arrayPeople.removeAll()
            StreamList.sharedInstance.arrayStream.removeAll()
            self.streamCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGlobalSearchPeople(searchString: searchText) { (values, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
                return
            }
            if PeopleList.sharedInstance.requestURl != "" {
                self.isPullToRefreshRemoved = true
            }
            self.streamCollectionView.es.stopPullToRefresh()
            self.streamCollectionView.es.stopLoadingMore()
            
            if type == .up ||  type == .start {
                UIApplication.shared.endIgnoringInteractionEvents()
            }else if type == .down {
            }
            
            self.btnStreamSearch.isUserInteractionEnabled = true
            self.btnPeopleSearch.isUserInteractionEnabled = false
            self.viewSearch.isHidden = false
            self.view.isUserInteractionEnabled = true
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            
            
            self.lblNoResult.isHidden = true
            if PeopleList.sharedInstance.arrayPeople.count == 0 {
                self.lblNoResult.isHidden = false
            }
            
            self.lblNoResult.isHidden = true
            self.expandPeopleHeight()
        }
    }
    
    func getStreamGlobleSearch(searchText:String, type:RefreshType){
        lblNoResult.text = kAlert_No_Stream_found
        if type != .up {
            HUDManager.sharedInstance.showHUD()
        }
        
        if type == .start || type == .up {
            self.addLoadMore()
            PeopleList.sharedInstance.arrayPeople.removeAll()
            StreamList.sharedInstance.arrayStream.removeAll()
            self.streamCollectionView.reloadData()
        }
        
        if SharedData.sharedInstance.iMessageNavigation == "" {
            APIServiceManager.sharedInstance.apiForGetStreamListFromGlobleSearch(strSearch: searchText) { (values, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if !(errorMsg?.isEmpty)! {
                    self.showToast(type: .success, strMSG: errorMsg!)
                    return
                }
                self.streamCollectionView.es.stopPullToRefresh()
                self.streamCollectionView.es.stopLoadingMore()
                HUDManager.sharedInstance.hideHUD()
                StreamList.sharedInstance.arrayStream = values
                self.viewMenu.isHidden = true
                self.viewSearch.isHidden = false
                self.btnStreamSearch.isUserInteractionEnabled = false
                self.btnPeopleSearch.isUserInteractionEnabled = true
                if StreamList.sharedInstance.requestURl != "" {
                    self.isPullToRefreshRemoved = true
                }
                self.lblNoResult.isHidden = true
                if StreamList.sharedInstance.arrayStream.count == 0 {
                    self.lblNoResult.isHidden = false
                }
                
                self.expandStreamHeight()
                self.view.isUserInteractionEnabled = true
                AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
                
            }
        }
    }
    
    
    func expandPeopleHeight() {
        self.streamCollectionView.isHidden = true
        
        UIView.animate(withDuration: 0.7, animations: {
            self.heightStream?.isActive = true
            self.heightPeople?.isActive = false
        }) { (finished) in
            self.isTapStream = false
            self.isTapPeople = true
            self.isSearch = true
            
            self.viewCollection.frame = CGRect(x: self.viewCollection.frame.origin.x, y: self.viewSearchMain.frame.origin.y + self.viewSearchMain.frame.size.height + 80, width: self.viewStream.frame.size.width, height: self.viewPeople.frame.size.height-40)
            self.streamCollectionView.isHidden = false
            self.streamCollectionView.reloadData()
            if PeopleList.sharedInstance.arrayPeople.count == 0 {
                self.lblNoResult.isHidden = false
            }
        }
    }
  
    
    func expandStreamHeight(){
        self.streamCollectionView.isHidden = true
        UIView.animate(withDuration: 0.7, animations: {
            self.heightStream?.isActive = false
            self.heightPeople?.isActive = true
        }) { (finished) in
            self.isTapStream = true
            self.isTapPeople = false
            self.isSearch = true
            self.streamCollectionView.isHidden = false
            self.viewCollection.frame = CGRect(x: self.viewCollection.frame.origin.x, y: self.viewSearchMain.frame.origin.y + self.viewSearchMain.frame.size.height + 40, width: self.viewSearch.frame.size.width, height: self.viewStream.frame.size.height-40)
            self.streamCollectionView.reloadData()
            //            if self.arrayStreams.count == 0 {
            //                self.lblNoResult.isHidden = false
            //            }
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

// MARK: - EXTENSION
// MARK: - Delegate and Datasource
extension StreamListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearch && isTapPeople {
            return PeopleList.sharedInstance.arrayPeople.count
        }
        else if isSearch && isTapStream {
            return StreamList.sharedInstance.arrayStream.count
        }
        else
            if isPeopleList {
                return PeopleList.sharedInstance.arrayPeople.count
            }else {
                return StreamList.sharedInstance.arrayStream.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        if isSearch && isTapPeople {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PeopleCell, for: indexPath) as! PeopleCell
            let people = PeopleList.sharedInstance.arrayPeople[indexPath.row]
            cell.prepareData(people:people)
            return cell
        }
        else if isSearch && isTapStream {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamCell, for: indexPath) as! StreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            
            let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
            cell.prepareLayouts(stream: stream)
            return cell
        }
        else if isPeopleList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PeopleCell, for: indexPath) as! PeopleCell
            let people = PeopleList.sharedInstance.arrayPeople[indexPath.row]
            cell.prepareData(people:people)
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamCell, for: indexPath) as! StreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            
            let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
            cell.prepareLayouts(stream: stream)
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if isSearch && isTapPeople {
            let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
            return CGSize(width: itemWidth, height: 100)
        }
        else if isSearch && isTapStream {
            let itemWidth = collectionView.bounds.size.width/2.0
            return CGSize(width: itemWidth, height: itemWidth - 40)
        }
        else if isPeopleList {
            let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
            return CGSize(width: itemWidth, height: 100)
        }
        else {
            let itemWidth = collectionView.bounds.size.width/2.0
            return CGSize(width: itemWidth, height: itemWidth - 40)
        }
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSearch && isTapPeople {
            let people = PeopleList.sharedInstance.arrayPeople[indexPath.row]
            if (people.userId == UserDAO.sharedInstance.user.userId) {
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.addLeftTransitionView(subtype: kCATransitionFromLeft)
                self.navigationController?.pushViewController(obj, animated: false)
            }
            else{
                let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                obj.objPeople = people
                self.navigationController?.push(viewController: obj)
            }
        }
        else if isSearch && isTapStream {
            let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
            obj.currentIndex = indexPath.row
            obj.streamType = currentStreamType.rawValue
            ContentList.sharedInstance.objStream = nil
            self.navigationController?.push(viewController: obj)
        }
        else if isPeopleList  {
             let people = PeopleList.sharedInstance.arrayPeople[indexPath.row]
            if (people.userId == UserDAO.sharedInstance.user.userId) {
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.navigationController?.push(viewController: obj)
            }
            else{
               
                let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                obj.objPeople = people
                self.navigationController?.push(viewController: obj)
            }
            
        }else {
            let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
            obj.currentIndex = indexPath.row
            obj.streamType = currentStreamType.rawValue
            ContentList.sharedInstance.objStream = nil
            self.navigationController?.push(viewController: obj)
        }
        
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isMenuOpen {
            self.menuView.isHidden = true
            self.viewMenu.isHidden = false
            Animation.viewSlideInFromTopToBottom(views: self.viewMenu)
            isMenuOpen = false
        }
        
        if (self.lastContentOffset > scrollView.contentOffset.y && !isSearch  ) {
            if  scrollView.contentOffset.y < -20 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseOut], animations: {
                    self.viewSearch.frame = CGRect(x: self.viewSearch.frame.origin.x, y: self.viewSearchMain.frame.origin.y + self.viewSearchMain.frame.size.height, width: self.viewSearchMain.frame.size.width, height: self.view.frame.size.height-self.viewSearchMain.frame.origin.y-self.viewSearchMain.frame.height)
                    self.viewCollection.frame = self.viewSearch.frame
                }, completion: nil)
            }
        }
            
        else if (self.lastContentOffset < scrollView.contentOffset.y)  &&  !isSearch {
            
            if scrollView.contentOffset.y > 0.5 {
                
                UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseIn], animations: {
                    self.viewSearch.frame = CGRect(x: self.viewSearch.frame.origin.x, y: self.viewSearchMain.frame.origin.y, width: self.viewSearchMain.frame.size.width, height: self.view.frame.size.height-self.viewSearchMain.frame.origin.y)
                    self.viewCollection.frame = self.viewSearch.frame
                }, completion: nil)
            }
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
        
    }
    
}

extension StreamListViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if txtSearch.text?.trim() != "" {
            self.didTapActionSearch(searchString: (txtSearch.text?.trim())!)
        }
        return true
    }
    

    func didTapActionSearch(searchString: String) {
        btnSearch.setImage(#imageLiteral(resourceName: "cross_search"), for: UIControlState.normal)
        btnSearch.tag = 1
        searchStr = searchString
        if isPeopleList {
            lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            lblStreamSearch.textColor = #colorLiteral(red: 0.6618840643, green: 0.6980385184, blue: 0.7022444606, alpha: 1)
            collectionLayout.columnCount = 3
            self.getPeopleGlobleSearch(searchText: searchString, type: .start)
        }else{
            lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            lblPeopleSearch.textColor = #colorLiteral(red: 0.6618840643, green: 0.6980385184, blue: 0.7022444606, alpha: 1)
            collectionLayout.columnCount = 2
            self.getStreamGlobleSearch(searchText: searchString, type: .start)
        }
    }
}


