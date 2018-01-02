//
//  StreamListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class StreamListViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var streamCollectionView: UICollectionView!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var lblNoResult: UILabel!
    @IBOutlet weak var btnMenu: UIButton!

    var lastIndex             : Int = 2
    
    
    
    @IBOutlet weak var menuView: FSPagerView! {
        didSet {
            self.menuView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            menuView.backgroundView?.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 0)
            menuView.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 0)
            menuView.currentIndex = 2
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

    var currentStreamType:StreamType! = .featured
    
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.streamCollectionView.accessibilityLabel = "StreamCollectionView"
        prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureLandingNavigation()
        menuView.isHidden = true
        self.viewMenu.isHidden = false
      
        if SharedData.sharedInstance.deepLinkType == kDeepLinkTypeAddContent{
            let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView)
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
        
        self.streamCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      self.prepareLayoutForApper()
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
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kNotificationUpdateFilter)), object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createAfterStream), name: NSNotification.Name(rawValue: kNotificationUpdateFilter), object: nil)
        
        HUDManager.sharedInstance.showHUD()
        self.getStreamList(type:.start,filter: .featured)
        // Attach datasource and delegate
        self.lblNoResult.isHidden = true
        self.streamCollectionView.dataSource  = self
        self.streamCollectionView.delegate = self
        streamCollectionView.alwaysBounceVertical = true

        if let layout: IOStickyHeaderFlowLayout = self.streamCollectionView.collectionViewLayout as? IOStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 60.0)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 60)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: layout.itemSize.height)
            layout.parallaxHeaderAlwaysOnTop = false
            layout.disableStickyHeaders = true
            self.streamCollectionView.collectionViewLayout = layout
        }
        
        self.streamCollectionView.register(self.headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader, withReuseIdentifier: kHeader_StreamHeaderView)
        self.configureLoadMoreAndRefresh()

    }
    // MARK: - Prepare Layouts When View Appear
    
    func prepareLayoutForApper(){
        self.viewMenu.layer.contents = UIImage(named: "home_gradient")?.cgImage
        menuView.isAddBackground = false
        menuView.isAddTitle = true
        menuView.lblCurrentType.text = menu.arrayMenu[menuView.currentIndex].iconName
        self.menuView.layer.contents = UIImage(named: "bottomPager")?.cgImage
        
        if(SharedData.sharedInstance.deepLinkType == kDeepLinkTypePeople){
            pagerView(menuView, didSelectItemAt: 4)
            menuView.currentIndex = 4
            self.viewMenu.isHidden = true
            self.menuView.isHidden = false
            SharedData.sharedInstance.deepLinkType = ""
        }
    }
 
    @objc func createAfterStream(){
        self.perform(#selector(self.showMyStream), with: nil, afterDelay: 0.5)
    }
    
    @objc func showMyStream(){
        pagerView(menuView, didSelectItemAt: 1)
        menuView.currentIndex = 1
    }
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.streamCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
             UIApplication.shared.beginIgnoringInteractionEvents()
            if (self?.isPeopleList)!  {
                self?.getUsersList(type:.up)
            }else {
                self?.getStreamList(type:.up,filter:(self?.currentStreamType)!)
            }
        }
        self.streamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            if (self?.isPeopleList)!  {
                self?.getUsersList(type:.down)
            }else {
                self?.getStreamList(type:.down,filter: (self?.currentStreamType)!)
            }
        }
        self.streamCollectionView.expiredTimeInterval = 20.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.streamCollectionView.es.autoPullToRefresh()
        }
    }
  
    // MARK: -  Action Methods And Selector
    
    override func btnCameraAction() {
        
        let obj:CameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CameraViewController
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.objStream = nil
        kContainerNav = ""
        self.navigationController?.push(viewController: obj)
    }
    
    override func btnHomeAction() {
        
    }
    
    override func btnMyProfileAction() {
        let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView)
        self.navigationController?.push(viewController: obj)
       
    }

    
    @IBAction func btnActionAdd(_ sender: Any) {
        self.actionForAddStream()
    }
    
    @IBAction func btnActionOpenMenu(_ sender: Any) {
        self.viewMenu.isHidden = true
        isMenuOpen = true
        self.menuView.isHidden = false
        Animation.viewSlideInFromTopToBottom(views: self.menuView)
      //  Animation.viewSlideInFromBottomToTop(views:self.menuView)
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
            }
            self.streamCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    func getUsersList(type:RefreshType){
        if type == .up {
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
extension StreamListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout {
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isPeopleList {
            return PeopleList.sharedInstance.arrayPeople.count
        }else {
            return StreamList.sharedInstance.arrayStream.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        if isPeopleList {
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
    
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isPeopleList {
            let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
            return CGSize(width: itemWidth, height: 100)
        }else {
            let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var cell = UICollectionReusableView()
        switch kind {
        case IOStickyHeaderParallaxHeader:
            cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_StreamHeaderView, for: indexPath) as! StreamSearchCell
            return cell
        default:
            assert(false, "Unexpected element kind")
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           if isPeopleList  == false{
            
           // let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
            let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
            obj.currentIndex = indexPath.row
            obj.streamType = currentStreamType.rawValue
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
       
    }
    
}


extension StreamListViewController:UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let sourceTransition = fromVC as? (RMPZoomTransitionAnimating & RMPZoomTransitionDelegate)
        let destinationTransition = toVC as? (RMPZoomTransitionAnimating & RMPZoomTransitionDelegate)
        if sourceTransition is RMPZoomTransitionAnimating && destinationTransition is RMPZoomTransitionAnimating {
            let animator = RMPZoomTransitionAnimator()
            animator.goingForward = operation == .push
            animator.sourceTransition = sourceTransition
            animator.destinationTransition = destinationTransition
            return animator as? UIViewControllerAnimatedTransitioning
        }
        return nil
     }

}


