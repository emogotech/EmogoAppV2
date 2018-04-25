//
//  ProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import XLActionController
import Social


enum ProfileMenu:String{
    case stream = "1"
    case colabs = "2"
    case stuff = "3"
}


class ProfileViewController: UIViewController {
    
    
    // MARK: - UI Elements
    
    @IBOutlet weak var profileCollectionView: UICollectionView!

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var btnStream: UIButton!
    @IBOutlet weak var btnColab: UIButton!
    @IBOutlet weak var btnStuff: UIButton!
    @IBOutlet weak var lblNOResult: UILabel!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var imgLink: UIImageView!
    @IBOutlet weak var btnContainer: UIView!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var kStuffOptionsHeight: NSLayoutConstraint!
    @IBOutlet weak var kHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentControl: HMSegmentedControl!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!

    var arrayTopContent = [TopContent]()
    var arrayMyStreams = [StreamDAO]()
    
    var currentMenu: ProfileMenu = .stream {
        
        didSet {
            updateConatiner()
        }
    }
    
    var isEdited:Bool! = false
    var isUpdateList:Bool! = false
    var imageToUpload:UIImage!
    var fileName:String! = ""
    var selectedIndex:IndexPath?
    
    let color = UIColor(r: 155, g: 155, b: 155)
    let colorSelected = UIColor.black
    let font = UIFont(name: "SFProText-Light", size: 14.0)
    let fontSelected = UIFont(name: "SFProText-Medium", size: 14.0)
    let fontSegment = UIFont(name: "SFProText-Medium", size: 12.0)

    var lastOffset:CGPoint! = CGPoint.zero
    var didScrollInLast:Bool! = false
    var selectedType:StuffType! = StuffType.All
    var profileStreamIndex = 0

    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: false, allowResizing: false, allowMoving: false, minimumSize: CGSize.zero)
    }
    
    var oldContentOffset = CGPoint.zero
    var topConstraintRange = (CGFloat(0)..<CGFloat(220))
   // 178
    let layout = CHTCollectionViewWaterfallLayout()

    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureProfileNavigation()
        self.prepareLayout()
        updateList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        self.title = "Profile"
        self.profileCollectionView.dataSource  = self
        self.profileCollectionView.delegate = self
        HUDManager.sharedInstance.showHUD()
        kShowOnlyMyStream = "1"
        self.getStreamList(type:.start,filter: .myStream)
        configureLoadMoreAndRefresh()

        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(10, 8, 0, 8)
        layout.columnCount = 2

        // Collection view attributes
        self.profileCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.profileCollectionView.alwaysBounceVertical = true
        // Add the waterfall layout to your collection view
        self.profileCollectionView.collectionViewLayout = layout
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kProfileUpdateIdentifier)), object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kProfileUpdateIdentifier), object: nil, queue: nil) { (notification) in
            self.prepareLayout()
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.profileCollectionView.addGestureRecognizer(swipeRight)
      
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.profileCollectionView.addGestureRecognizer(swipeLeft)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
        self.profileCollectionView.addGestureRecognizer(longPressGesture)
        
        let tapFollow = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
        self.lblFollowers.isUserInteractionEnabled = true
        self.lblFollowers.addGestureRecognizer(tapFollow)
        
        let tapFollowing = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
        self.lblFollowing.isUserInteractionEnabled = true
        self.lblFollowing.addGestureRecognizer(tapFollowing)
        
        self.btnStream.setTitleColor(colorSelected, for: .normal)
        self.btnStream.titleLabel?.font = fontSelected
        self.btnColab.setTitleColor(color, for: .normal)
        self.btnColab.titleLabel?.font = font
        self.btnStuff.setTitleColor(color, for: .normal)
        self.btnStuff.titleLabel?.font = font
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
        self.lblWebsite.addGestureRecognizer(tap)
        self.lblWebsite.isUserInteractionEnabled = true
        let nibViews = UINib(nibName: "ProfileStreamView", bundle: nil)
        self.profileCollectionView.register(nibViews, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: kHeader_ProfileStreamView)
        
    }
    
    func prepareLayout() {
       // lblUserName.text = "@" + UserDAO.sharedInstance.user.fullName.trim()
       // lblUserName.minimumScaleFactor = 1.0
        APIServiceManager.sharedInstance.apiForGetUserInfo(userID: UserDAO.sharedInstance.user.userProfileID, isCurrentUser: true) { (_, _) in
            
            DispatchQueue.main.async {
                self.lblFullName.text =  UserDAO.sharedInstance.user.displayName.trim().capitalized
                self.lblFullName.minimumScaleFactor = 1.0
                self.lblWebsite.text = UserDAO.sharedInstance.user.website.trim()
                self.lblWebsite.minimumScaleFactor = 1.0
                self.lblLocation.text = UserDAO.sharedInstance.user.location.trim()
                self.lblLocation.minimumScaleFactor = 1.0
                self.lblBio.text = UserDAO.sharedInstance.user.biography.trim()
                if UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.kHeaderHeight.constant = 178
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(178))
                }else {
                    self.kHeaderHeight.constant = 220
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(220))
                }
                //self.lblBirthday.text = UserDAO.sharedInstance.user.birthday.trim()
                self.title = UserDAO.sharedInstance.user.fullName.trim()
                self.lblBio.minimumScaleFactor = 1.0
                self.imgLink.isHidden = false
                self.imgLocation.isHidden = false
                
                if UserDAO.sharedInstance.user.location.trim().isEmpty {
                    self.imgLocation.isHidden = true
                }
                if UserDAO.sharedInstance.user.website.trim().isEmpty {
                    self.imgLink.isHidden = true
                }
                self.lblFollowing.isHidden = false
                self.lblFollowers.isHidden = false
                if UserDAO.sharedInstance.user.followers.trim().isEmpty {
                    self.lblFollowers.isHidden = true
                }
                if UserDAO.sharedInstance.user.following.trim().isEmpty {
                    self.lblFollowing.isHidden = true
                }
                self.lblFollowers.text = UserDAO.sharedInstance.user.followers.trim()
                self.lblFollowing.text = UserDAO.sharedInstance.user.following.trim()
                //print(UserDAO.sharedInstance.user.userImage.trim())
                if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
                    self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage.trim())
                }
                if UserDAO.sharedInstance.user.location.trim().isEmpty && !UserDAO.sharedInstance.user.website.trim().isEmpty {
                    self.lblLocation.text = UserDAO.sharedInstance.user.website.trim()
                    self.lblWebsite.isHidden = true
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLink.image
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                    self.lblLocation.addGestureRecognizer(tap)
                    self.lblLocation.isUserInteractionEnabled = true
                }
                self.profileStreamShow()
            }
            
        }
      
        btnContainer.addBorders(edges: [UIRectEdge.top,UIRectEdge.bottom], color: color, thickness: 1)
        kStuffOptionsHeight.constant = 0.0

        // Segment control Configure

        segmentControl.sectionTitles = ["ALL", "PHOTOS", "VIDEOS", "LINKS", "NOTES","GIFS"]
        segmentControl.indexChangeBlock = {(_ index: Int) -> Void in
            print("Selected index \(index) (via block)")
            self.updateStuffList(index: index)
        }

        segmentControl.selectionIndicatorHeight = 1.0
        segmentControl.backgroundColor = UIColor.white
        segmentControl.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 74, g: 74, b: 74),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 12.0)]
        segmentControl.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
        segmentControl.selectionStyle = .textWidthStripe
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectionIndicatorLocation = .down
        segmentControl.shouldAnimateUserSelection = false
    }
    
    func updateList(){
        if isEdited {
            HUDManager.sharedInstance.showHUD()
            isEdited = false
            if  self.currentMenu == .stuff {
                self.getMyStuff(type: .start)
            }else if self.currentMenu == .stream{
                self.getStreamList(type:.start,filter: .myStream)
            }else {
                self.getColabs(type: .start)
            }
        }
    }
    
    func updateStuffList(index:Int){
        switch index {
        case 0:
            self.selectedType = .All
            break
        case 1:
            self.selectedType = StuffType.Picture
            break
        case 2:
            self.selectedType = StuffType.Video
            break
        case 3:
            self.selectedType = StuffType.Links
            break
        case 4:
            self.selectedType = StuffType.Notes
            break
        case 5:
            self.selectedType = StuffType.Giphy
            break
        default:
            self.selectedType = .All
        }
        HUDManager.sharedInstance.showHUD()
        self.profileCollectionView.es.resetNoMoreData()
        self.getMyStuff(type: .start)
    }
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.profileCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            if self?.currentMenu == .stream {
                self?.getStreamList(type:.up,filter:.myStream)
            }else if self?.currentMenu == .stuff {
                self?.getMyStuff(type: .up)
            }else {
                self?.getColabs(type: .up)
            }
        }
        self.profileCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            if self?.currentMenu == .stream {
                self?.getStreamList(type:.down,filter: .myStream)
            }else if self?.currentMenu == .stuff {
                self?.getMyStuff(type: .down)
            }else {
                self?.getColabs(type: .down)
            }
        }
        self.profileCollectionView.expiredTimeInterval = 20.0
    }
    func configureProfileNavigation(){
        
        var myAttribute2:[NSAttributedStringKey:Any]!
        if let font = UIFont(name: kFontBold, size: 20.0) {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: font]
        }else {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = kNavigationColor
        let img = UIImage(named: "forward_icon")
        let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.profileBackAction))
        self.navigationItem.rightBarButtonItem = btnback
        let btnLogout = UIBarButtonItem(image: #imageLiteral(resourceName: "logout_button"), style: .plain, target: self, action: #selector(self.btnLogoutAction))
           let btnShare = UIBarButtonItem(image: #imageLiteral(resourceName: "share icon"), style: .plain, target: self, action: #selector(self.profileShareAction))
        self.navigationItem.leftBarButtonItems = [btnLogout,btnShare]
        
    }
    
   
    // MARK: -  Action Methods And Selector
    
    @objc func profileBackAction(){
        
        self.addLeftTransitionView(subtype: kCATransitionFromRight)
        self.navigationController?.popNormal()
    }
    
    @objc func profileShareAction(){
        if UserDAO.sharedInstance.user.shareURL.isEmpty {
            return
        }
        let url:URL = URL(string: UserDAO.sharedInstance.user.shareURL!)!
      let shareItem =  "Hey checkout \(UserDAO.sharedInstance.user.fullName.capitalized)'s profile!"
        let text = "\n via Emogo"

       // let shareItem = "Hey checkout the s profile,emogo"
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [shareItem,url,text], applicationActivities:nil)
      //  activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .airDrop]
        
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil);
        }
    }
    
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                print("Swie Left")
                if currentMenu == .stream {
                    Animation.addRightTransition(collection: self.profileCollectionView)
                    self.updateSegment(selected: 102)
                }else if currentMenu == .colabs {
                    Animation.addRightTransition(collection: self.profileCollectionView)
                    self.updateSegment(selected: 103)
                }else {
                    if self.selectedType != StuffType.Giphy {
                        Animation.addRightTransition(collection: self.profileCollectionView)
                        let index = self.selectedType.hashValue + 1
                        self.segmentControl.selectedSegmentIndex = index
                        self.updateStuffList(index: index)
                    }
                    }
                break
                
            case UISwipeGestureRecognizerDirection.right:
                print("Swie Right")
                if currentMenu == .colabs {
                    Animation.addLeftTransition(collection: self.profileCollectionView)
                    self.updateSegment(selected: 101)
                }else if currentMenu == .stuff {
                    if  self.selectedType == StuffType.All {
                        Animation.addLeftTransition(collection: self.profileCollectionView)
                        self.updateSegment(selected: 102)
                    }else {
                        Animation.addLeftTransition(collection: self.profileCollectionView)
                        let index = self.selectedType.hashValue - 1
                        self.segmentControl.selectedSegmentIndex = index
                        self.updateStuffList(index: index)
                    }
                }
                break
            default:
                break
            }
        }
    }
    
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        if self.selectedType != .All {
            return
        }
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.profileCollectionView.indexPathForItem(at: gesture.location(in: self.profileCollectionView)) else {
                break
            }
            selectedIndex = selectedIndexPath
            profileCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            profileCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: self.profileCollectionView))
            
        case UIGestureRecognizerState.ended:
            profileCollectionView.endInteractiveMovement()
            selectedIndex = nil
        default:
            profileCollectionView.cancelInteractiveMovement()
            selectedIndex = nil
        }
    }
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let obj:FollowersViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_FollowersView) as! FollowersViewController
        if gesture.view?.tag == 111 {
            obj.listType = FollowerType.Follower
        }else {
            obj.listType = FollowerType.Following
        }
        self.navigationController?.push(viewController: obj)
    }
    
    @objc func actionForWebsite(){

    guard let url = URL(string: UserDAO.sharedInstance.user.website.stringByAddingPercentEncodingForURLQueryParameter()!) else {
            self.showToast(strMSG: kAlert_ValidWebsite)
            return
        }
        if !["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            let appendedLink = "https://" + UserDAO.sharedInstance.user.website
            let modiURL = URL(string: appendedLink.stringByAddingPercentEncodingForURLQueryParameter()!)
            self.openURL(url: modiURL!)
        }else {
            self.openURL(url: url)
        }
    }
   
    
    @IBAction func btnActionMenuSelected(_ sender: UIButton) {
        self.updateSegment(selected: sender.tag)
    }
    
    @IBAction func btnActionProfileUpdate(_ sender: UIButton) {
        isEdited = true
        let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileUpdateView)
        self.navigationController?.pushAsPresent(viewController: obj)
    }
    
   
    private func updateSegment(selected:Int){
        switch selected {
        case 101:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_active_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .stream
            break
        case 102:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_active_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .colabs
            break
        case 103:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_active_icon"), for: .normal)
            self.currentMenu = .stuff
            break
        default:
            break
        }
    }
    
    private func updateConatiner(){
        self.profileCollectionView.es.resetNoMoreData()
        switch currentMenu {
        case .stuff:
            kStuffOptionsHeight.constant = 28.0
            HUDManager.sharedInstance.showHUD()
            self.getMyStuff(type: .start)
            break
        case .stream:
            kStuffOptionsHeight.constant = 0.0
            HUDManager.sharedInstance.showHUD()
            self.getStreamList(type:.start,filter: .myStream)
            break
        case .colabs:
            kStuffOptionsHeight.constant = 0.0
            HUDManager.sharedInstance.showHUD()
            self.getColabs(type: .start)
            break
        }
    }
    override func btnLogoutAction() {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Logout, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
            HUDManager.sharedInstance.showHUD()
            APIServiceManager.sharedInstance.apiForLogoutUser { (isSuccess, errorMsg) in
                HUDManager.sharedInstance.hideHUD()
                if (errorMsg?.isEmpty)! {
                    self.logout()
                }else {
                    self.showToast(strMSG: errorMsg!)
                }
            }
            
            alert.dismiss(animated: true, completion: nil)
            
        }
        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
        
    }
    
    private func logout(){
        kDefault?.set(false, forKey: kUserLogggedIn)
        let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_InitialView)
        self.navigationController?.reverseFlipPush(viewController: obj)
    }
    
    
    @objc func btnActionForEdit(sender:UIButton) {
        isEdited = true
        let stream = StreamList.sharedInstance.arrayProfileStream[sender.tag]
        let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
        obj.streamID = stream.ID
        self.navigationController?.push(viewController: obj)
    }
    
    @objc func btnShowMoreAction(sender:UIButton){
        let top = self.arrayTopContent[sender.tag]
        if top.type == StuffType.All {
            isEdited = true
        }
        let obj:MyStuffPreViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffPreView) as! MyStuffPreViewController
        obj.selectedType = top.type
        self.navigationController?.push(viewController: obj)
    }
    
    func profileStreamShow(){
        if self.currentMenu == .stream {
            arrayMyStreams = StreamList.sharedInstance.arrayProfileStream
            if UserDAO.sharedInstance.user.stream != nil {
                if (UserDAO.sharedInstance.user.stream?.CoverImage.trim().isEmpty)! {
                    self.layout.headerHeight = 0
                    lblNOResult.isHidden = true

                    if arrayMyStreams.count == 0 {
                        self.layout.headerHeight = 0
                        lblNOResult.text = "No Streams Found."
                        lblNOResult.isHidden = false
                    }
                }else {
                    
                    let index = StreamList.sharedInstance.arrayProfileStream.index(where: {$0.ID.trim() == UserDAO.sharedInstance.user.stream?.ID.trim()})
                    if index != nil {
                        profileStreamIndex = index!
                        arrayMyStreams.remove(at: index!)
                    }
                    lblNOResult.isHidden = true
                    self.layout.headerHeight = 200
                }
            }else {
               self.layout.headerHeight = 0
                lblNOResult.isHidden = true
                if arrayMyStreams.count == 0 {
                    self.layout.headerHeight = 0
                    lblNOResult.text = "No Streams Found."
                    lblNOResult.isHidden = false
                }
            }
            
            self.profileCollectionView.reloadData()
        }
    }
    
    // MARK: - API

    func getStreamList(type:RefreshType,filter:StreamType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayProfileStream.removeAll()
            self.profileCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetMyProfileStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.profileCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.profileCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.profileCollectionView.es.stopLoadingMore()
            }
            
            self.lblNOResult.isHidden = true
            if StreamList.sharedInstance.arrayProfileStream.count == 0 {
                self.lblNOResult.text  = "No Stream Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
           
            self.profileStreamShow()
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getMyStuff(type:RefreshType){
        if type == .start || type == .up {
            ContentList.sharedInstance.arrayStuff.removeAll()
            self.profileCollectionView.reloadData()
        }
        
        APIServiceManager.sharedInstance.apiForGetStuffList(type: type,contentType: selectedType) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.profileCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.profileCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.profileCollectionView.es.stopLoadingMore()
            }
            
            self.lblNOResult.isHidden = true
            if ContentList.sharedInstance.arrayStuff.count == 0 {
                self.lblNOResult.text  = "No Stuff Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
            self.layout.headerHeight = 0.0
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getColabs(type:RefreshType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayProfileStream.removeAll()
            self.profileCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetColabList(type: type) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.profileCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.profileCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.profileCollectionView.es.stopLoadingMore()
            }
            self.lblNOResult.isHidden = true
            if StreamList.sharedInstance.arrayProfileStream.count == 0 {
                self.lblNOResult.text  = "No Stream Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
            self.layout.headerHeight = 0.0
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    func reorderContent(orderArray:[ContentDAO]) {
        
        APIServiceManager.sharedInstance.apiForReorderMyContent(orderArray: orderArray) { (isSuccess,errorMSG)  in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.profileCollectionView.reloadData()
                self.selectedIndex = nil
            }
        }
    }
    
    
    
    
    func btnActionForAddContent(){
        let actionController = ActionSheetController()
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.objStream = nil
        kContainerNav = ""
        kNavForProfile = "1"
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
        
        
        actionController.headerData = "ADD ITEM"
        actionController.shouldShowAddButton    =   false
        present(actionController, animated: true, completion: nil)
    }
    
    
    func actionForCamera(){
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        self.navigationController?.pushNormal(viewController: obj)
    }
    
    func btnActionForLink(){
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_LinkView)
        self.navigationController?.push(viewController: controller)
    }
    
    func btnActionForGiphy(){
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_GiphyView)
        self.navigationController?.push(viewController: controller)
    }
    
    
    func btnActionForMyStuff(){
        let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView)
        self.navigationController?.push(viewController: controller)
    }
    
    func actionForAddStream(){
        let controller = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView)
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
                
            } else if obj.type == .video {
                camera.type = .video
                obj.tempCopyMediaFile(progressBlock: { (progress) in
                    //print(progress)
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


extension ProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout,ProfileStreamViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentMenu == .stuff {
            return ContentList.sharedInstance.arrayStuff.count
        }else if currentMenu == .colabs {
            return StreamList.sharedInstance.arrayProfileStream.count
        }else {
            return self.arrayMyStreams.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        if currentMenu == .stuff {
            
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
            // for Add Content
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            cell.prepareLayout(content:content)
            return cell
            
        }else if currentMenu == .stream{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            cell.btnEdit.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(self.btnActionForEdit(sender:)), for: .touchUpInside)
            let stream = self.arrayMyStreams[indexPath.row]
            cell.prepareLayouts(stream: stream)
            if currentMenu == .stream {
                cell.lblName.text = ""
                cell.lblName.isHidden = true
            }
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            cell.btnEdit.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(self.btnActionForEdit(sender:)), for: .touchUpInside)
            let stream = StreamList.sharedInstance.arrayProfileStream[indexPath.row]
            cell.prepareLayouts(stream: stream)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print(kind)
        
        switch kind {
            
        case CHTCollectionElementKindSectionHeader:
            let headerView:ProfileStreamView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_ProfileStreamView, for: indexPath) as! ProfileStreamView
           
            if UserDAO.sharedInstance.user.stream != nil {
               
            headerView.delegate = self
        headerView.prepareLayout(stream:UserDAO.sharedInstance.user.stream!,isCurrentUser: true)
            }
            headerView.imgUser.isHidden = true
            return headerView
            
        default:
            
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if currentMenu == .stuff {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            if selectedIndex != nil {
                let tempContent = ContentList.sharedInstance.arrayStuff[selectedIndex!.row]
                return CGSize(width: tempContent.width, height: tempContent.height)
            }
            return CGSize(width: content.width, height: content.height)
        }else {
            let itemWidth = collectionView.bounds.size.width/2.0
            return CGSize(width: itemWidth, height: itemWidth - 40)
        }
       
    }
        
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentMenu == .stuff {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            if content.isAdd {
                btnActionForAddContent()
            }else {
                isEdited = true
                let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isAdd == false }
                ContentList.sharedInstance.arrayContent = array
                if ContentList.sharedInstance.arrayContent.count != 0 {
                    let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                    objPreview.currentIndex = indexPath.row
                    self.navigationController?.push(viewController: objPreview)
                }
            }
        }else {
          //  let stream = StreamList.sharedInstance.arrayProfileStream[indexPath.row]
                isEdited = true
                var index = 0
                if currentMenu == .stream {
                    let tempStream = self.arrayMyStreams[indexPath.row]
                    let tempIndex = StreamList.sharedInstance.arrayProfileStream.index(where: {$0.ID.trim() == tempStream.ID.trim()})
                    if tempIndex != nil {
                        index = tempIndex!
                    }
                     StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileStream
                }else {
                    index = indexPath.row
                    StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileStream
                }
                let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                obj.currentIndex = index
                obj.viewStream = "fromProfile"
                ContentList.sharedInstance.objStream = nil
                self.navigationController?.push(viewController: obj)
            }
        }
    
      func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let contentDest = ContentList.sharedInstance.arrayStuff[sourceIndexPath.row]
        ContentList.sharedInstance.arrayStuff.remove(at: sourceIndexPath.row)
        ContentList.sharedInstance.arrayStuff.insert(contentDest, at: destinationIndexPath.row)
        DispatchQueue.main.async {
            self.profileCollectionView.reloadItems(at: [destinationIndexPath,sourceIndexPath])
            HUDManager.sharedInstance.showHUD()
            self.reorderContent(orderArray:ContentList.sharedInstance.arrayStuff)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if selectedType == .All {
            return true
        }else {
            return false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let delta =  scrollView.contentOffset.y - oldContentOffset.y
        
        //we compress the top view
        if delta > 0 && kHeaderHeight.constant > topConstraintRange.lowerBound && scrollView.contentOffset.y > 0 {
            kHeaderHeight.constant -= delta
            scrollView.contentOffset.y -= delta
        }
        
        //we expand the top view
        if delta < 0 && kHeaderHeight.constant < topConstraintRange.upperBound && scrollView.contentOffset.y < 0{
            kHeaderHeight.constant -= delta
            scrollView.contentOffset.y -= delta
        }
        oldContentOffset = scrollView.contentOffset
    }
    
    func actionForCover(){
        isEdited = true
        let array = StreamList.sharedInstance.arrayProfileStream.filter { $0.isAdd == false }
            StreamList.sharedInstance.arrayViewStream = array
        
        let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
        obj.currentIndex = profileStreamIndex
        obj.viewStream = "fromProfile"
        ContentList.sharedInstance.objStream = nil
        self.navigationController?.push(viewController: obj)
    }
}








