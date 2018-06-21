//
//  StreamListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import XLActionController
import Haptica
import Presentr

class StreamListViewController: UIViewController {
    
    @IBOutlet weak var containerMenuView : UIStackView!
    
    // MARK: - UI Elements
    @IBOutlet weak var streamCollectionView: UICollectionView!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var lblNoResult: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnAdd   :   UIButton!
    @IBOutlet weak var txtSearch : UITextField!
    
    var lastIndex             : Int = 2
    var isPullToRefreshRemoved:Bool! = false
    private var lastContentOffset: CGFloat = 0
    var btnAddFrame   : CGRect!
    var segmentheader: SegmentHeaderViewCell!
    let fontSegment = UIFont(name: "SFProText-Medium", size: 12.0)
    var selectedType:StreamType! = StreamType.Public
    
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
    
    var isAddButtonTapped   =   false
    var isDidLoadCalled : Bool  =   false
    
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
    var arrayToShow = [StreamDAO]()
    var timer:Timer?
    
 
    
    
    /*
    let customOrientationPresenter: Presentr = {
        
        //let width = ModalSize.full
        //let height = ModalSize.custom(size: 550)
       // let height = ModalSize.fluid(percentage: 0.50)
        //let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 300))
      //  let customType = PresentationType.custom(width: width, height: height, center: center)
       
        let customType = PresentationType.bottomHalf
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 15.0
        customPresenter.backgroundOpacity = 1.0
        customPresenter.dismissOnSwipe = true
        customPresenter.blurBackground = true
        customPresenter.blurStyle = UIBlurEffectStyle.light
        
       
        return customPresenter
    }()
    
    lazy var popupViewController: ActionSheetViewController = {
        let popupViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_ActionSheet)
        
        return popupViewController as! ActionSheetViewController
    }()*/
    
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
        kShowOnlyMyStream = ""
        self.viewMenu.isHidden = false
        DispatchQueue.main.async {
            
            if self.isSearch == false {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }

                if  currentStreamType == .People {
                    self.collectionLayout.columnCount = 3
                }else {
                    self.collectionLayout.columnCount = 2
                }
            }else {

                if self.isSearch && self.isTapPeople {
                    self.collectionLayout.columnCount = 3
                }
                else {
                    self.collectionLayout.columnCount = 2
                }
            }
            if self.arrayToShow.count == 0 {
                self.lblNoResult.isHidden = false
            }else {
                self.lblNoResult.isHidden = true
            }
            print("index to change----->\(currentStreamType.hashValue)")
            self.menuView.currentIndex = currentStreamType.hashValue
            self.menuView.reloadData()
            self.streamCollectionView.reloadData()
        }
        if SharedData.sharedInstance.deepLinkType != "" {
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.checkDeepLinkURL()
            }
        }
        
        if #available(iOS 11, *), UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            let frame = self.menuView.frame
            let viewFrame = self.viewMenu.frame
//            self.menuView.backgroundColor = .red
//            self.viewMenu.backgroundColor = .green
            
            let extraBottomSpace = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
            let guide  =  self.view.safeAreaLayoutGuide

            
            self.menuView.removeConstraints(self.menuView.constraints)
            self.menuView.translatesAutoresizingMaskIntoConstraints = false
            
            self.menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            self.menuView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: extraBottomSpace! - 10).isActive = false
            self.menuView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.menuView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self.menuView.heightAnchor.constraint(equalToConstant: frame.size.height).isActive = true
            
//            
//            self.viewMenu.removeConstraints(self.viewMenu.constraints)
//            self.viewMenu.translatesAutoresizingMaskIntoConstraints = false
//
//            self.viewMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//
//            self.viewMenu.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: extraBottomSpace!).isActive = false
//            self.viewMenu.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//            self.viewMenu.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//            self.viewMenu.heightAnchor.constraint(equalToConstant: viewFrame.size.height).isActive = true
//            
//            let containerFrame = self.containerMenuView.frame
//
//            self.containerMenuView.topAnchor.constraint(equalTo: self.viewMenu.topAnchor).isActive = true
//            self.containerMenuView.bottomAnchor.constraint(equalTo: self.viewMenu.bottomAnchor).isActive = true
//            self.containerMenuView.widthAnchor.constraint(equalToConstant: containerFrame.size.width).isActive = true
//            self.containerMenuView.centerXAnchor.constraint(equalTo: self.viewMenu.centerXAnchor).isActive = true
//            self.containerMenuView.centerYAnchor.constraint(equalTo: self.viewMenu.centerYAnchor).isActive = true
            
        }

        if isDidLoadCalled == false {
            self.btnAddFrame    =   self.btnAdd.frame
        }
        isDidLoadCalled     =       true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareLayoutForApper()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func configureStreamHeader() {
    
        let nibViews = Bundle.main.loadNibNamed("SegmentHeaderViewCell", owner: self, options: nil)
        self.segmentheader = nibViews?.first as! SegmentHeaderViewCell
        self.streamCollectionView.addSubview(self.segmentheader)
        self.segmentheader.segmentDelegate = self
       
        segmentheader.segmentControl.isHidden = false
        
    }
    func checkDeepLinkURL() {
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeAddContent{
            self.getStream(currentStreamID: SharedData.sharedInstance.streamID, currentConytentID: "")
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
        
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeShareAddContent {
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
        }
        
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeShareMessage {
            ContentList.sharedInstance.arrayContent = SharedData.sharedInstance.contentList.arrayContent
            let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
            objPreview.currentIndex = 0
            let nav = UINavigationController(rootViewController: objPreview)
            customPresentViewController( PresenterNew.instance.contentContainer, viewController: nav, animated: true)
            
        }
        
        if SharedData.sharedInstance.deepLinkType == kDeeplinkOpenUserProfile {
           // Naviagte to user Profile
            if SharedData.sharedInstance.objDeepLink != nil {
                if SharedData.sharedInstance.objDeepLink?.userId.trim() == UserDAO.sharedInstance.user.userId.trim() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.isUpdateList = true
                        let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                        self.navigationController?.pushViewController(obj, animated: false)
                    }
                }else {
                    let objPeople = PeopleDAO(peopleData: [:])
                    objPeople.fullName = SharedData.sharedInstance.objDeepLink?.fullName
                    objPeople.userId = SharedData.sharedInstance.objDeepLink?.userId
                    objPeople.userImage = SharedData.sharedInstance.objDeepLink?.userImage
                    objPeople.phoneNumber = SharedData.sharedInstance.objDeepLink?.phone
                   objPeople.userProfileID = SharedData.sharedInstance.objDeepLink?.userProfileID
                    let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                    obj.objPeople = objPeople
                    self.navigationController?.push(viewController: obj)
                }
                SharedData.sharedInstance.deepLinkType = ""
                SharedData.sharedInstance.objDeepLink = nil
            }
        }
        
        
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        
        // Logout User if Token Is Expired
        AppDelegate.appDelegate.removeOberserver()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil, queue: nil) { (notification) in
            kDefault?.set(false, forKey: kUserLogggedIn)
            kDefault?.removeObject(forKey: kUserLogggedInData)
            let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_InitialView)
            self.navigationController?.reverseFlipPush(viewController: obj)
        }
        menuView.currentIndex = currentStreamType.hashValue
        print("current index ----\(currentStreamType)")
        print("current index ----\(currentStreamType.hashValue)")
        self.getTopStreamList()
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
        
//        if currentStreamType == .myStream {
//            self.configureStreamHeader()
//        }else{
//
//        }
    
        
    }
    
   
    
    @objc func startAnimation(){
        print("Called")
        
        UIView.animate(withDuration: 0.3 / 1.5, animations: {() -> Void in
            
            self.btnAdd.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
           
            
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: TimeInterval(0.3 / 2), animations: {() -> Void in
                self.btnAdd.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
               
                
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: TimeInterval(0.3 / 2), animations: {() -> Void in
                    self.btnAdd.transform = .identity
                   
                })
            })
        })

        
        
//        UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
//             self.btnAdd.alpha = 0
//        }) { _ in
//          //  self.viewToAnimate.removeFromSuperview()
//            self.btnAdd.alpha = 1.0
//        }
        
//        self.btnAdd.animation.moveY(self.btnAddFrame.origin.y - 10).thenAfter(0.5).makeY(self.btnAddFrame.origin.y + 10).animateWithCompletion(0.8) { (_) in
//
//        }
//            self.btnAdd.animation.moveY(self.btnAddFrame.origin.y - 10).makeY(self.btnAddFrame.origin.y + 10).animateWithCompletion(0.5, { (_) in
//            })
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
               self.isUpdateList = true
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
    
    func setViewSearchHeightFor_iPhoneX(){
        if #available(iOS 11, *), UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            let extraBottomSpace = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
            self.viewSearch.frame.size.height = self.viewSearch.frame.size.height - extraBottomSpace!
        }
    }
    
    // MARK: - Prepare Layouts When View Appear
    
    func prepareLayoutForApper(){
       self.viewMenu.layer.contents = UIImage(named: "home_gradient")?.cgImage
        menuView.isAddBackground = false
        menuView.isAddTitle = true
        menuView.lblCurrentType.text = menu.arrayMenu[menuView.currentIndex].iconName
       // self.menuView.layer.contents = UIImage(named: "bottomPager")?.cgImage
        let blurEffect = UIBlurEffect(style: .light)
        // 3
        let blurView = UIVisualEffectView(effect: blurEffect)
        // 4
        
        var blurFrame = menuView.bounds
        let blurHeight = (blurFrame.size.height / 2)
        blurFrame.size.height    =  blurHeight
        blurFrame.origin.y      =   blurHeight + 10
        blurView.frame = blurFrame
        blurView.setTopCurve()
        menuView.insertSubview(blurView, at: 0)
        print(blurView)

        if isLoadFirst {
            UIView.animate(withDuration: 0.1, animations: {
                self.viewSearch.frame = CGRect(x: self.viewSearch.frame.origin.x, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height-(self.navigationController?.navigationBar.frame.size.height)!)
                self.viewCollection.frame = self.viewSearch.frame
                self.setViewSearchHeightFor_iPhoneX()
            })
            self.isLoadFirst = false
        }
        /*
        if(SharedData.sharedInstance.deepLinkType == kDeepLinkTypePeople){
            pagerView(menuView, didSelectItemAt: 4)
            menuView.currentIndex = 4
            self.viewMenu.isHidden = true
            self.menuView.isHidden = false
            SharedData.sharedInstance.deepLinkType = ""
        }
 */
    
        if isSearch {
            self.viewMenu.isHidden = true
        }
        if kDefault?.bool(forKey: kBounceAnimation) == false {
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startAnimation), userInfo: nil, repeats: true)
            }
        }
    }
    
   
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.streamCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
             AppDelegate.appDelegate.window?.isUserInteractionEnabled = false
            if self?.isSearch == false {
                if currentStreamType == .People {
                    self?.getUsersList(type:.up)
                }else {
                    self?.getStreamList(type:.up,filter:currentStreamType)
                }
            }else {
                
                if (self?.isSearch)! && (self?.isTapPeople)! {
                    self?.getPeopleGlobalSearch(searchText: (self?.searchStr)!, type: .up)
                }
                else if (self?.isSearch)! && (self?.isTapStream)! {
                    self?.getStreamGlobalSearch(searchText: (self?.searchStr)!, type: .up)
                }
                
            }
            
            /*
            if (self?.isSearch)! && (self?.isTapPeople)! {
                self?.getPeopleGlobleSearch(searchText: (self?.searchStr)!, type: .start)
            }
            else if (self?.isSearch)! && (self?.isTapStream)! {
                self?.getStreamGlobleSearch(searchText: (self?.searchStr)!, type: .start)
            }
            else if (self?.isPeopleList)! {
                self?.getUsersList(type:.up)
            }else {
            }
 */
        }
        
        self.streamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            
                 AppDelegate.appDelegate.window?.isUserInteractionEnabled = false
            if self?.isSearch == false {
                if currentStreamType == .People {
                    self?.getUsersList(type:.down)
                }else {
                    self?.getStreamList(type:.down,filter:currentStreamType)
                }
            }else {
                if (self?.isSearch)! && (self?.isTapPeople)! {
                    self?.getPeopleGlobalSearch(searchText: (self?.searchStr)!, type: .down)
                }
                else if (self?.isSearch)! && (self?.isTapStream)! {
                    self?.getStreamGlobalSearch(searchText: (self?.searchStr)!, type: .down)
                }
            }
           
        }
        self.streamCollectionView.expiredTimeInterval = 15.0
    }
    
    func updateStreamSegment(index:Int){
        switch index {
        case 0:
            self.selectedType = StreamType.Public
            currentStreamType = self.selectedType
            StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
            self.getMyStreamViewData(type: .up)
            break
        case 1:
            self.selectedType = StreamType.Private
            currentStreamType = self.selectedType
            StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
            self.getMyStreamViewData(type: .up)
            break
            
        default:
            self.selectedType = StreamType.Public
            currentStreamType = self.selectedType
            StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
            self.getMyStreamViewData(type: .up)
        }
        HUDManager.sharedInstance.hideHUD()
        
        
    }

    // MARK: -  Action Methods And Selector
    
    override func btnCameraAction() {
        actionForCamera()
    }
    
    override func btnHomeAction() {
        
    }
    
    override func btnMyProfileAction() {
        isUpdateList = true
      
        let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
        self.addLeftTransitionView(subtype: kCATransitionFromLeft)
        self.navigationController?.pushViewController(obj, animated: false)
    }
    
    @IBAction func btnActionAdd(_ sender: Any) {
        
        self.btnAdd.isHaptic = true
        self.btnAdd.hapticType = .impact(.light)
        
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        kDefault?.set(true, forKey: kBounceAnimation)
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.objStream = nil
        
        let actionVC : ActionSheetViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_ActionSheet) as! ActionSheetViewController
        actionVC.delegate = self
        customPresentViewController(PresenterNew.ActionSheetPresenter, viewController: actionVC, animated: true, completion: nil)
    }
    
    @IBAction func btnActionOpenMenu(_ sender: Any) {
        
        if kDefault?.bool(forKey: kHapticFeedback) == true {
            self.btnMenu.isHaptic = true
            self.btnMenu.hapticType = .impact(.light)
        }else{
            
        }
        self.viewMenu.isHidden = true
        isMenuOpen = true
        self.menuView.isHidden = false
        Animation.viewSlideInFromTopToBottom(views: self.menuView)
        //  Animation.viewSlideInFromBottomToTop(views:self.menuView)
    }
    
    @IBAction func btnSearchAction(_ sender:UIButton) {
        if btnSearch.tag == 1 {
            self.view.endEditing(true)
            txtSearch.text = ""
            btnSearch.setImage(#imageLiteral(resourceName: "search_icon_iphone"), for: UIControlState.normal)
            btnSearch.tag = 0
            isUpdateList = true
            UIView.animate(withDuration: 0.1, delay: 0.1, options: [.curveEaseOut], animations: {
                self.viewSearch.frame = CGRect(x: self.viewSearch.frame.origin.x, y: self.viewSearchMain.frame.origin.y, width: self.viewSearchMain.frame.size.width, height: self.view.frame.size.height-self.viewSearchMain.frame.origin.y)
                self.viewCollection.frame = self.viewSearch.frame
                self.setViewSearchHeightFor_iPhoneX()
            }, completion: nil)
            self.viewMenu.isHidden = false
            isSearch = false
            if currentStreamType == .People {
                self.lblNoResult.text = kAlert_No_User_Record_Found
                collectionLayout.columnCount = 3
            }else {
                self.lblNoResult.text = kAlert_No_Stream_found
                collectionLayout.columnCount = 2
            }
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                if self.arrayToShow.count == 0 {
                    self.lblNoResult.isHidden = false
                }else {
                    self.lblNoResult.isHidden = true
                }
                self.streamCollectionView.reloadData()
            }
        }else{
            if txtSearch.text?.trim() != "" {
                btnSearch.tag = 1
                btnSearch.setImage(#imageLiteral(resourceName: "cross_search"), for: UIControlState.normal)
                self.didTapActionSearch(searchString: (txtSearch.text?.trim())!)
                self.viewMenu.isHidden = true
                isSearch = true
            }
        }
        
        if isMenuOpen {
            self.menuView.isHidden = true
            self.viewMenu.isHidden = false
            Animation.viewSlideInFromTopToBottom(views: self.viewMenu)
            isMenuOpen = false
        }
    }
    
    @IBAction func btnActionStreamSearch(_ sender : UIButton){
        switch sender.tag {
            
        case 0:         //Stream
            lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            self.streamCollectionView.isHidden = true
            PeopleList.sharedInstance.requestURl = ""
            StreamList.sharedInstance.requestURl = ""
            collectionLayout.columnCount = 2
            HUDManager.sharedInstance.showHUD()
            self.getStreamGlobalSearch(searchText: searchStr, type: .start)
            break
            
        case 1:         //People
            collectionLayout.columnCount = 3
            lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            self.streamCollectionView.isHidden = true
            PeopleList.sharedInstance.requestURl = ""
            StreamList.sharedInstance.requestURl = ""
            HUDManager.sharedInstance.showHUD()
            self.getPeopleGlobalSearch(searchText: searchStr, type: .start)
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

    func getMyStreamViewData(type:RefreshType){
        
        if type == .start || type == .up {
            for _ in StreamList.sharedInstance.arrayStream {
                if let index = StreamList.sharedInstance.arrayStream.index(where: { $0.selectionType == currentStreamType}) {
                    StreamList.sharedInstance.arrayStream.remove(at: index)
                    print("Removed")
                }
            }
        }
        APIServiceManager.sharedInstance.getMyStreamNewList(type: type) { (refreshType, errorMsg) in
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if refreshType == .end {
                self.streamCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                //  UIApplication.shared.endIgnoringInteractionEvents()
                self.streamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
              
                self.streamCollectionView.es.stopLoadingMore()
            }
            self.lblNoResult.isHidden = true
            self.lblNoResult.text = kAlert_No_Stream_found
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                if self.selectedType == .Public{
                    self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType}
                }else{
                    self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType}
                }
                if self.arrayToShow.count == 0 {
                    self.lblNoResult.isHidden = false
                }else {
                    self.lblNoResult.isHidden = true
                }
                self.streamCollectionView.reloadData()
            }
            self.streamCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getTopStreamList() {
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForGetTopStreamList { (streams, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
               AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if (errorMsg?.isEmpty)! {
                StreamList.sharedInstance.arrayStream.removeAll()
                StreamList.sharedInstance.arrayStream = streams
                DispatchQueue.main.async {
                    self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                    if self.arrayToShow.count == 0 {
                        self.lblNoResult.isHidden = false
                    }else {
                        self.lblNoResult.isHidden = true
                    }
                    self.streamCollectionView.reloadData()
                }
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getStreamList(type:RefreshType,filter:StreamType){
        
        if type == .start || type == .up {
            for _ in StreamList.sharedInstance.arrayStream {
                if let index = StreamList.sharedInstance.arrayStream.index(where: { $0.selectionType == currentStreamType}) {
                    StreamList.sharedInstance.arrayStream.remove(at: index)
                    print("Removed")
                }
            }
        }
        APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
               AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if refreshType == .end {
                self.streamCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.streamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.streamCollectionView.es.stopLoadingMore()
            }
            self.lblNoResult.isHidden = true
            self.lblNoResult.text = kAlert_No_Stream_found
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                
                if self.arrayToShow.count == 0 {
                    self.lblNoResult.isHidden = false
                }else {
                    self.lblNoResult.isHidden = true
                }
                self.streamCollectionView.reloadData()
            }
            self.streamCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
 
    func getStream(currentStreamID:String, currentConytentID:String){
        APIServiceManager.sharedInstance.apiForViewStream(streamID: currentStreamID) { (stream, errorMsg) in
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if (errorMsg?.isEmpty)! {
                let allContents = stream?.arrayContent
                if ((allContents?.count)! > 0){
                    if    SharedData.sharedInstance.deepLinkType == kDeepLinkTypeEditContent {
                        let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                        
                        for i in 0...(stream?.arrayContent.count)!-1 {
                            let data : ContentDAO = allContents![i]
                            print(data.contentID)
                            print(SharedData.sharedInstance.iMessageNavigationCurrentContentID)
                            if data.contentID ==  currentConytentID {
                                objPreview.seletedImage = data
                                objPreview.isEdit = true
                                let nav = UINavigationController(rootViewController: objPreview)
                                self.customPresentViewController( PresenterNew.instance.contentContainer, viewController: nav, animated: true)
                                
                                break
                            }
                        }
                    }
                    else {
                        let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                        let tempDict : NSDictionary = NSDictionary()
                        let streamDads = StreamDAO.init(streamData: tempDict as! [String : Any])
                        streamDads.ID = stream?.streamID
                        print(streamDads.ID)
                        StreamList.sharedInstance.arrayViewStream = [streamDads]
                        obj.currentIndex = 0
                        ContentList.sharedInstance.arrayContent = stream?.arrayContent
                        ContentList.sharedInstance.objStream = SharedData.sharedInstance.streamID
                        self.navigationController?.push(viewController: obj)
                    }
                }
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
                SharedData.sharedInstance.deepLinkType = ""
            }
        }
    }
    
    func getUsersList(type:RefreshType){
        if type == .up {
            for _ in StreamList.sharedInstance.arrayStream {
                if let index = StreamList.sharedInstance.arrayStream.index(where: { $0.selectionType == currentStreamType}) {
                    StreamList.sharedInstance.arrayStream.remove(at: index)
                    print("Removed")
                }
            }
        }
        APIServiceManager.sharedInstance.apiForGetPeopleList(type:type,deviceType:.iPhone) { (refreshType, errorMsg) in
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if refreshType == .end {
                self.streamCollectionView.es.noticeNoMoreData()
            }
            
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.streamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.streamCollectionView.es.stopLoadingMore()
            }
            self.lblNoResult.text = kAlert_No_User_Record_Found
            self.lblNoResult.isHidden = true
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                if self.arrayToShow.count == 0 {
                    self.lblNoResult.isHidden = false
                }else {
                    self.lblNoResult.isHidden = true
                }
                self.streamCollectionView.reloadData()
            }
            
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    
    // MARK: - Search API Methods
    
    

    func getPeopleGlobalSearch(searchText:String, type:RefreshType){
        
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
            self.arrayToShow.removeAll()
            self.streamCollectionView.reloadData()
        }
        
        APIServiceManager.sharedInstance.apiForSearchPeople(strSearch: searchText, type: type) { (refreshType, errorMsg) in
               AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            
            if refreshType == .end {
                self.streamCollectionView.es.noticeNoMoreData()
            }
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.streamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.streamCollectionView.es.stopLoadingMore()
            }
            self.lblNoResult.isHidden = true
            self.lblNoResult.text = kAlert_No_User_Record_Found
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayMyStream
                if self.arrayToShow.count == 0 {
                    self.lblNoResult.isHidden = false
                    self.lblPeopleSearch.text = "People"
                    self.lblStreamSearch.text = "Emogo"
                }else {
                    self.lblNoResult.isHidden = true
                    let count = "(\(self.arrayToShow.count))"
                    self.lblPeopleSearch.text = "People \(count)"
                    self.lblStreamSearch.text = "Emogo"
                }
                self.streamCollectionView.reloadData()
            }
            
            self.btnStreamSearch.isUserInteractionEnabled = true
            self.btnPeopleSearch.isUserInteractionEnabled = false
            self.viewSearch.isHidden = false
            self.expandPeopleHeight()
            
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
        
        /*
        if type != .up {
            HUDManager.sharedInstance.showHUD()
        }
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
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
 */
    }
    
    func getStreamGlobalSearch(searchText:String, type:RefreshType){

        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
             self.arrayToShow.removeAll()
            self.streamCollectionView.reloadData()
        }
        if SharedData.sharedInstance.iMessageNavigation == "" {
            
            APIServiceManager.sharedInstance.apiForSearchStream(strSearch: searchText, type: type, completionHandler: { (refreshType, errorMsg) in
                   AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
                if refreshType == .end {
                    self.streamCollectionView.es.noticeNoMoreData()
                }
                if type == .start {
                    HUDManager.sharedInstance.hideHUD()
                }
                if type == .up {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.streamCollectionView.es.stopPullToRefresh()
                }else if type == .down {
                    self.streamCollectionView.es.stopLoadingMore()
                }
                self.lblNoResult.isHidden = true
                self.lblNoResult.text = kAlert_No_Stream_found
                DispatchQueue.main.async {
                    self.arrayToShow = StreamList.sharedInstance.arrayMyStream
                    if self.arrayToShow.count == 0 {
                        self.lblNoResult.isHidden = false
                        self.lblStreamSearch.text = "Emogo"
                        self.lblPeopleSearch.text = "People"

                    }else {
                        self.lblNoResult.isHidden = true
                        let count = "(\(self.arrayToShow.count))"
                        self.lblStreamSearch.text = "Emogo \(count)"
                        self.lblPeopleSearch.text = "People"

                    }
                    self.streamCollectionView.reloadData()
                }
                
                self.viewMenu.isHidden = true
                self.viewSearch.isHidden = false
                self.btnStreamSearch.isUserInteractionEnabled = false
                self.btnPeopleSearch.isUserInteractionEnabled = true
                
                self.expandStreamHeight()
                if !(errorMsg?.isEmpty)! {
                    self.showToast(type: .success, strMSG: errorMsg!)
                }
                
            })
            
        }
        
        
        /*
        
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
            self.streamCollectionView.reloadData()
        }
                
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
 */
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
        
        return self.arrayToShow.count
        
        /*
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
 */
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        if self.isSearch == false {
            if currentStreamType == .People {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PeopleCell, for: indexPath) as! PeopleCell
                let people = self.arrayToShow[indexPath.row]
                cell.prepareData(people:people)
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamCell, for: indexPath) as! StreamCell
                cell.layer.cornerRadius = 5.0
                cell.layer.masksToBounds = true
                cell.isExclusiveTouch = true
                let stream = self.arrayToShow[indexPath.row]
                cell.prepareLayouts(stream: stream)
                return cell
            }
        }else {
            if isSearch && isTapPeople {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PeopleCell, for: indexPath) as! PeopleCell
                let people = self.arrayToShow[indexPath.row]
                cell.prepareData(people:people)
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamCell, for: indexPath) as! StreamCell
                cell.layer.cornerRadius = 5.0
                cell.layer.masksToBounds = true
                cell.isExclusiveTouch = true
                let stream = self.arrayToShow[indexPath.row]
                cell.prepareLayouts(stream: stream)
                return cell
            }
        }

        /*
       
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
 */
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if self.isSearch == false {
            if currentStreamType == .People {
                let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
                return CGSize(width: itemWidth, height: 100)
            }else {
                let itemWidth = collectionView.bounds.size.width/2.0
                return CGSize(width: itemWidth, height: itemWidth - 40)
            }
        }else {
            if isSearch && isTapPeople {
                let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
                return CGSize(width: itemWidth, height: 100)
            }
            else {
                let itemWidth = collectionView.bounds.size.width/2.0
                return CGSize(width: itemWidth, height: itemWidth - 40)
            }
        }
      
        /*
       
        else if isPeopleList {
            let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
            return CGSize(width: itemWidth, height: 100)
        }
        else {
            let itemWidth = collectionView.bounds.size.width/2.0
            return CGSize(width: itemWidth, height: itemWidth - 40)
        }
 */
    }
//    private func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//
//        header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SegmentHeaderViewCell", for: indexPath as IndexPath) as? SegmentHeaderViewCell
//
//        return header!
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isSearch == false {
            if currentStreamType == .People {
                let people = self.arrayToShow[indexPath.row]
                if (people.userId == UserDAO.sharedInstance.user.userId) {
                    let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                    self.addLeftTransitionView(subtype: kCATransitionFromLeft)
                    self.navigationController?.pushViewController(obj, animated: false)
                }
                else{
                    let objPeople = PeopleDAO(peopleData: [:])
                    objPeople.fullName = people.fullName
                    objPeople.userId = people.userId
                    objPeople.userImage = people.userImage
                    objPeople.phoneNumber = people.phoneNumber
                    objPeople.userProfileID = people.userProfileId
                    let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                    obj.objPeople = objPeople
                    self.navigationController?.push(viewController: obj)
                }
            }else {
                StreamList.sharedInstance.arrayViewStream = self.arrayToShow
                let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                obj.currentIndex = indexPath.row
                obj.streamType = currentStreamType.rawValue
                ContentList.sharedInstance.objStream = nil
                self.navigationController?.push(viewController: obj)
            }
        }else {
            if isSearch && isTapPeople {
                let people = self.arrayToShow[indexPath.row]
                if (people.userId == UserDAO.sharedInstance.user.userId) {
                    let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                    self.addLeftTransitionView(subtype: kCATransitionFromLeft)
                    self.navigationController?.pushViewController(obj, animated: false)
                }
                else{
                    let objPeople = PeopleDAO(peopleData: [:])
                    objPeople.fullName = people.fullName
                    objPeople.userId = people.userId
                    objPeople.userProfileID = people.userProfileId
                    objPeople.userImage = people.userImage
                    objPeople.phoneNumber = people.phoneNumber
                    objPeople.userProfileID = people.userProfileId
                    let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                    obj.objPeople = objPeople
                    self.navigationController?.push(viewController: obj)
                }
            }else {
                StreamList.sharedInstance.arrayViewStream = self.arrayToShow
                let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                obj.currentIndex = indexPath.row
                obj.streamType = currentStreamType.rawValue
                ContentList.sharedInstance.objStream = nil
                self.navigationController?.push(viewController: obj)
            }
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
                    self.setViewSearchHeightFor_iPhoneX()
                }, completion: nil)
            }
        }
            
        else if (self.lastContentOffset < scrollView.contentOffset.y)  &&  !isSearch {
            
            if scrollView.contentOffset.y > 0.5 {
                
                UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseIn], animations: {
                    self.viewSearch.frame = CGRect(x: self.viewSearch.frame.origin.x, y: self.viewSearchMain.frame.origin.y, width: self.viewSearchMain.frame.size.width, height: self.view.frame.size.height-self.viewSearchMain.frame.origin.y)
                    self.viewCollection.frame = self.viewSearch.frame
                    self.setViewSearchHeightFor_iPhoneX()
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
            if isMenuOpen {
                self.menuView.isHidden = true
                self.viewMenu.isHidden = false
                Animation.viewSlideInFromTopToBottom(views: self.viewMenu)
                isMenuOpen = false
            }
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
            lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            collectionLayout.columnCount = 3
            HUDManager.sharedInstance.showHUD()
            self.getPeopleGlobalSearch(searchText: searchString, type: .start)
        }else{
            lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            collectionLayout.columnCount = 2
            HUDManager.sharedInstance.showHUD()
            self.getStreamGlobalSearch(searchText: searchString, type: .start)
        }
    }
}

extension StreamListViewController : ActionSheetControllerHeaderActionDelegate {
    func actionSheetControllerHeaderButtonAction() {
        self.actionForAddStream()
    }
}



