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
import Haptica
import Presentr

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
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnNextStuff: UIButton!
    @IBOutlet weak var btnAdd: UIButton!

    @IBOutlet weak var heightviewBio: NSLayoutConstraint!
    @IBOutlet weak var kViewLocWebHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentMain: HMSegmentedControl!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    var arrayTopContent = [TopContent]()
    var arrayMyStreams = [StreamDAO]()
    
    var currentMenu: ProfileMenu = .stream {
        
        didSet {
            updateConatiner()
        }
    }
    
    var isEdited:Bool! = true
    
    var imageToUpload:UIImage!
    var fileName:String! = ""
    var selectedIndex:IndexPath?
    var timer:Timer?
    
    let color = UIColor(r: 155, g: 155, b: 155)
    let colorSelected = UIColor.black
    let font = UIFont(name: "SFProText-Light", size: 14.0)
    let fontSelected = UIFont(name: "SFProText-Medium", size: 14.0)
    let fontSegment = UIFont(name: "SFProText-Medium", size: 12.0)

    var lastOffset:CGPoint! = CGPoint.zero
    var didScrollInLast:Bool! = false
    var selectedType:StuffType! = StuffType.All
    var selectedSegment:SegmentType! =  SegmentType.EMOGOS
    var profileStreamIndex = 0
    var isCalledMyStream:Bool! = true
    var isCalledColabStream:Bool! = true
    var isStuffUpdated:Bool! = true
    var selectedImageView:UIImageView?

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
        self.lblNOResult.isHidden = true
        self.configureProfileNavigation()
        self.prepareLayout(listUpdate: false)
        updateList(hud: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if kDefault?.bool(forKey: kBounceAnimation) == false {
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startAnimation), userInfo: nil, repeats: true)
            }
        }
        if  SharedData.sharedInstance.deepLinkType == "updateProfile" {
          
            let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileUpdateView)
            self.navigationController?.push(viewController: obj)
            SharedData.sharedInstance.deepLinkType = ""
        }else if SharedData.sharedInstance.deepLinkType == kDeeplinkOpenUserProfile {
            
        }else {
            
        }
        
}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        self.title = "Profile"
        self.btnNext.isHidden = true
        self.btnAdd.isHidden = false
        self.lblNOResult.isHidden = true
        ContentList.sharedInstance.arrayStuff.removeAll()
        StreamList.sharedInstance.arrayProfileStream.removeAll()
        StreamList.sharedInstance.arrayProfileColabStream.removeAll()
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
            if notification.object != nil {
                self.profileCollectionView.reloadData()
            }else {
                self.prepareLayout(listUpdate: true)
            }
            
         }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.profileCollectionView.addGestureRecognizer(swipeRight)
      
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.profileCollectionView.addGestureRecognizer(swipeLeft)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
        self.profileCollectionView.addGestureRecognizer(longPressGesture)

        
//        let tapFollow = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
//        self.lblFollowers.isUserInteractionEnabled = true
//        self.lblFollowers.addGestureRecognizer(tapFollow)
//
//        let tapFollowing = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
//        self.lblFollowing.isUserInteractionEnabled = true
//        self.lblFollowing.addGestureRecognizer(tapFollowing)
        
       /*
        self.btnStream.setTitleColor(colorSelected, for: .normal)
        self.btnStream.titleLabel?.font = fontSelected
        self.btnColab.setTitleColor(color, for: .normal)
        self.btnColab.titleLabel?.font = font
        self.btnStuff.setTitleColor(color, for: .normal)
        self.btnStuff.titleLabel?.font = font
         */
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
        self.lblWebsite.addGestureRecognizer(tap)
        self.lblWebsite.isUserInteractionEnabled = true
        let nibViews = UINib(nibName: "ProfileStreamView", bundle: nil)
        self.profileCollectionView.register(nibViews, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: kHeader_ProfileStreamView)
     
        // Segment control Configure
        if kDefault?.bool(forKey: kHapticFeedback) == true{
            Haptic.impact(.light).generate()
        }else{
            
        }
        segmentControl.sectionTitles = ["ALL", "PHOTOS", "VIDEOS", "LINKS", "NOTES","GIFS"]
        
        segmentControl.indexChangeBlock = {(_ index: Int) -> Void in
          
            print("Selected index \(index) (via block)")
            self.updateStuffList(index: index)
        }
        segmentControl.selectionIndicatorHeight = 1.0
        segmentControl.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
       // segmentControl.backgroundColor = UIColor.white
        segmentControl.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 74, g: 74, b: 74),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 12.0)]
        segmentControl.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
        segmentControl.selectionStyle = .textWidthStripe
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectionIndicatorLocation = .down
        segmentControl.shouldAnimateUserSelection = false
      
        
        segmentMain.sectionTitles = ["EMOGOS", "COLLABS", "MY STUFF"]
        
        segmentMain.indexChangeBlock = {(_ index: Int) -> Void in
            
            print("Selected index \(index) (via block)")
            self.updateSegment(selected: index)
        }
         segmentMain.selectionIndicatorHeight = 1.0
         segmentMain.backgroundColor = UIColor.white
         segmentMain.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 74, g: 74, b: 74),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 12.0)]
        // segmentMain.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
         segmentMain.selectionIndicatorColor =  kCardViewBordorColor
         segmentMain.selectionStyle = .textWidthStripe
         segmentMain.selectedSegmentIndex = 0
         segmentMain.selectionIndicatorLocation = .down
         segmentMain.shouldAnimateUserSelection = false
       
    
    }
    
   
    func prepareLayout(listUpdate:Bool) {
       // lblUserName.text = "@" + UserDAO.sharedInstance.user.fullName.trim()
       // lblUserName.minimumScaleFactor = 1.0
        APIServiceManager.sharedInstance.apiForGetUserInfo(userID: UserDAO.sharedInstance.user.userProfileID, isCurrentUser: true) { (_, _) in
            
            DispatchQueue.main.async {
                self.imgLink.image = #imageLiteral(resourceName: "link icon")
                self.imgLocation.image = #imageLiteral(resourceName: "location icon")
                self.lblLocation.isHidden = false
                self.lblWebsite.isHidden = false
                self.lblBio.isHidden =  false
                self.lblFollowers.isHidden = true
                self.lblFollowing.isHidden = true

                self.lblFullName.text =  UserDAO.sharedInstance.user.displayName.trim().capitalized
                self.lblFullName.minimumScaleFactor = 1.0
                self.lblWebsite.text = UserDAO.sharedInstance.user.website.trim()
                self.lblWebsite.minimumScaleFactor = 1.0
                self.lblLocation.text = UserDAO.sharedInstance.user.location.trim()
                self.lblLocation.minimumScaleFactor = 1.0
                self.lblBio.text = UserDAO.sharedInstance.user.biography.trim()
               
                //self.lblBirthday.text = UserDAO.sharedInstance.user.birthday.trim()
                self.title = UserDAO.sharedInstance.user.fullName.trim()
                self.lblBio.minimumScaleFactor = 1.0
                self.imgLink.isHidden = false
                self.imgLocation.isHidden = false
                
                
                if UserDAO.sharedInstance.user.website.trim().count > 25 {
                    self.lblWebsite.text = UserDAO.sharedInstance.user.website.trim(count: 25)
                }
                
                self.heightviewBio.constant = 42
                self.kViewLocWebHeight.constant = 32
                
                if UserDAO.sharedInstance.user.location.trim().isEmpty {
                    self.imgLocation.isHidden = true
                }
                if UserDAO.sharedInstance.user.website.trim().isEmpty {
                    self.imgLink.isHidden = true
                }
                self.lblFollowing.isHidden = false
                self.lblFollowers.isHidden = false
                
                let tapFollow = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
                let tapFollowing = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
               
                if UserDAO.sharedInstance.user.followers.trim().isEmpty && !UserDAO.sharedInstance.user.following.trim().isEmpty  {
                    self.lblFollowers.text = UserDAO.sharedInstance.user.following.trim()
                     self.lblFollowing.text = ""
                    self.lblFollowers.isHidden = false
                    self.lblFollowers.tag = 0
                    self.lblFollowers.isUserInteractionEnabled = true
                    self.lblFollowing.isUserInteractionEnabled = false
                    self.lblFollowers.addGestureRecognizer(tapFollowing)
                }
                
                if UserDAO.sharedInstance.user.following.trim().isEmpty && !UserDAO.sharedInstance.user.followers.trim().isEmpty  {
                    self.lblFollowers.text = UserDAO.sharedInstance.user.followers.trim()
                    self.lblFollowers.isHidden = false
                    self.lblFollowers.tag = 111
                    self.lblFollowers.isUserInteractionEnabled = true
                    self.lblFollowing.isUserInteractionEnabled = false
                    self.lblFollowers.addGestureRecognizer(tapFollow)
                    self.lblFollowing.text = ""
                }
                    
                if !UserDAO.sharedInstance.user.following.trim().isEmpty && !UserDAO.sharedInstance.user.followers.trim().isEmpty  {
                   
                    self.lblFollowers.isHidden = false
                    self.lblFollowing.isHidden = false
                    self.lblFollowers.tag = 111
                    self.lblFollowing.tag = 0
                    self.lblFollowers.text = UserDAO.sharedInstance.user.followers.trim()
                    self.lblFollowers.isUserInteractionEnabled = true
                    self.lblFollowers.addGestureRecognizer(tapFollow)
                    self.lblFollowing.text = UserDAO.sharedInstance.user.following.trim()
                    self.lblFollowing.isUserInteractionEnabled = true
                    self.lblFollowing.addGestureRecognizer(tapFollowing)
                }
                //print(UserDAO.sharedInstance.user.userImage.trim())
                if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
                    self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage.trim())
                }else {
                    if UserDAO.sharedInstance.user.displayName.isEmpty {
                        self.imgUser.setImage(string:UserDAO.sharedInstance.user.fullName, color: UIColor.colorHash(name:UserDAO.sharedInstance.user.fullName ), circular: true)
                    }else{
                        self.imgUser.setImage(string:UserDAO.sharedInstance.user.displayName, color: UIColor.colorHash(name:UserDAO.sharedInstance.user.displayName ), circular: true)
                    }
                }
                // self.imgUser.borderWidth = 1.0
                //  self.imgUser.borderColor = UIColor(r: 13, g: 192, b: 237)
                
                if !UserDAO.sharedInstance.user.location.trim().isEmpty && !UserDAO.sharedInstance.user.website.trim().isEmpty && UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    
                    self.lblLocation.text = UserDAO.sharedInstance.user.location.trim()
                    self.lblWebsite.text =  UserDAO.sharedInstance.user.website.trim()
                    self.lblLocation.isHidden = false
                    self.lblWebsite.isHidden =  false
                    self.imgLink.isHidden = false
                    self.imgLocation.isHidden = false
                    self.lblBio.isHidden =  true
                    self.heightviewBio.constant = 0
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                    self.lblLocation.addGestureRecognizer(tap)
                    self.lblLocation.isUserInteractionEnabled = true
                    self.kHeaderHeight.constant = 170//178
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(170))
                }

             else if UserDAO.sharedInstance.user.location.trim().isEmpty && !UserDAO.sharedInstance.user.website.trim().isEmpty && UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.lblLocation.text = UserDAO.sharedInstance.user.website.trim()
                    self.lblLocation.isHidden =  false
                    self.lblWebsite.isHidden = true
                    self.lblBio.isHidden = true
                    self.heightviewBio.constant = 0
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLink.image
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                    self.lblLocation.addGestureRecognizer(tap)
                    self.lblLocation.isUserInteractionEnabled = true
                    self.kHeaderHeight.constant = 170//178
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(170))
                }
                else if UserDAO.sharedInstance.user.location.trim().isEmpty && !UserDAO.sharedInstance.user.website.trim().isEmpty && !UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.lblLocation.text = UserDAO.sharedInstance.user.website.trim()
                    self.lblLocation.isHidden =  false
                    self.lblWebsite.isHidden = true
                    self.lblBio.isHidden = false
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLink.image
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                    self.lblLocation.addGestureRecognizer(tap)
                    self.lblLocation.isUserInteractionEnabled = true
                    self.kHeaderHeight.constant = 205
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(205))
                }
               
                else if !UserDAO.sharedInstance.user.location.trim().isEmpty && UserDAO.sharedInstance.user.website.trim().isEmpty && UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.lblLocation.text = UserDAO.sharedInstance.user.location.trim()
                    self.lblLocation.isHidden =  false
                    self.lblWebsite.isHidden = true
                    self.lblBio.isHidden = true
                    self.heightviewBio.constant = 0
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLocation.image
                    self.kHeaderHeight.constant = 170//178
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(170))
                }
                else if !UserDAO.sharedInstance.user.location.trim().isEmpty && UserDAO.sharedInstance.user.website.trim().isEmpty && !UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.lblLocation.text = UserDAO.sharedInstance.user.location.trim()
                    self.lblLocation.isHidden =  false
                    self.lblWebsite.isHidden = true
                    self.lblBio.isHidden = false
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLink.image
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                    self.lblLocation.addGestureRecognizer(tap)
                    self.lblLocation.isUserInteractionEnabled = true
                    self.kHeaderHeight.constant = 205//178
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(205))
                }
               else if UserDAO.sharedInstance.user.location.trim().isEmpty && UserDAO.sharedInstance.user.website.trim().isEmpty && !UserDAO.sharedInstance.user.biography.trim().isEmpty {
           
                    self.lblLocation.isHidden = true
                    self.lblWebsite.isHidden = true
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = true
                    self.lblBio.isHidden = false
                    self.kViewLocWebHeight.constant = 0
                    self.kHeaderHeight.constant = 188
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(188))
                    
                }
               else  if  UserDAO.sharedInstance.user.location.trim().isEmpty && UserDAO.sharedInstance.user.website.trim().isEmpty && UserDAO.sharedInstance.user.biography.trim().isEmpty  {
                    
                    self.lblLocation.isHidden = true
                    self.lblWebsite.isHidden = true
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = true
                    self.lblBio.isHidden = true
                    self.kHeaderHeight.constant = 130 //146
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(130))
                   
                } 
 
                else{
                   
                    self.kHeaderHeight.constant = 205//220
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(205))
               
                }
                self.profileStreamShow()
                if listUpdate{
                    self.isEdited = true
                    self.updateList(hud: false)
                }
            }
            self.btnContainer.addShadow()
            self.btnContainer.roundCorners([.topLeft,.topRight], radius: 5)
        }
      
      //btnContainer.addBorders(edges: [UIRectEdge.top,UIRectEdge.bottom], color: color, thickness: 1)
        
        
        if  self.currentMenu == .stuff {
            kStuffOptionsHeight.constant = 17.0
        }else {
            kStuffOptionsHeight.constant = 0.0
        }
        
    }
    
    func updateList(hud:Bool){
        if isEdited {
            isEdited = false
            if  self.currentMenu == .stuff {
                ContentList.sharedInstance.arrayContent.removeAll()
                let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
                ContentList.sharedInstance.arrayContent = array.filter { $0.isSelected == true }
                self.profileCollectionView.reloadData()
//
//                for i in 0..<ContentList.sharedInstance.arrayStuff.count {
//                    let obj = ContentList.sharedInstance.arrayStuff[i]
//                    obj.isSelected = false
//                    ContentList.sharedInstance.arrayStuff[i] = obj
//                }
               // self.getMyStuff(type: .start)
            }else if self.currentMenu == .stream{
                if hud{
                    HUDManager.sharedInstance.showHUD()
                }
                self.getStreamList(type:.start,filter: .myStream)
            }else {
                if hud{
                    HUDManager.sharedInstance.showHUD()
                }
                self.getColabs(type: .start)
            }
        }
    }
    
 
    
    
    func updateStuffList(index:Int){
        switch index {
        case 0:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = .All
            self.segmentControl.selectedSegmentIndex = 0
            break
        case 1:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Picture
            self.segmentControl.selectedSegmentIndex = 1

            break
        case 2:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Video
            self.segmentControl.selectedSegmentIndex = 2

            break
        case 3:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Links
            self.segmentControl.selectedSegmentIndex = 3

            break
        case 4:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Notes
            self.segmentControl.selectedSegmentIndex = 4

            break
        case 5:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Giphy
            self.segmentControl.selectedSegmentIndex = 5

            break
        default:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = .All
            self.segmentControl.selectedSegmentIndex = 0

        }
        profileCollectionView.es.resetNoMoreData()
        
        if  ContentList.sharedInstance.arrayContent.count == 0 {
            for i in 0..<ContentList.sharedInstance.arrayStuff.count {
                let obj = ContentList.sharedInstance.arrayStuff[i]
                obj.isSelected = false
                ContentList.sharedInstance.arrayStuff[i] = obj
            }
        }
        
        self.btnNext.isHidden = true
        self.btnAdd.isHidden = false
        if ContentList.sharedInstance.arrayContent.count != 0 {
            self.btnNext.isHidden = false
            self.btnAdd.isHidden = true
        }
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        self.lblNOResult.isHidden = true
        if array.count == 0  {
            self.lblNOResult.isHidden = false
            self.lblNOResult.text = "No Stuff Found"
        }
        self.profileCollectionView.reloadData()
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
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        let img = UIImage(named: "forward_black")
        let btnback = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.profileBackAction))
        self.navigationItem.rightBarButtonItem = btnback
        
        let imgSetting = UIImage(named: "setting_icon")
        let btnSetting = UIBarButtonItem(image: imgSetting, style: .plain, target: self, action: #selector(self.btnSettingAction))
        let btnShare = UIBarButtonItem(image: #imageLiteral(resourceName: "share icon"), style: .plain, target: self, action: #selector(self.profileShareAction))
        self.navigationItem.leftBarButtonItems = [btnSetting,btnShare]
        
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
               // print("Swie Left")
                if kDefault?.bool(forKey: kHapticFeedback) == true{
                    Haptic.impact(.light).generate()
                }else{
                    
                }
                if currentMenu == .stream {
                    Animation.addRightTransition(collection: self.profileCollectionView)
                    self.updateSegment(selected: 1)
                    //self.updateSegment(selected: 102)
                }else if currentMenu == .colabs {
                    Animation.addRightTransition(collection: self.profileCollectionView)
                    self.updateSegment(selected: 2)
                    //self.updateSegment(selected: 103)
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
               // print("Swie Right")
                if kDefault?.bool(forKey: kHapticFeedback) == true{
                    Haptic.impact(.light).generate()
                }else{
                    
                }
                if currentMenu == .colabs {
                    Animation.addLeftTransition(collection: self.profileCollectionView)
                    self.updateSegment(selected: 0)
                   // self.updateSegment(selected: 101)
                    
                }else if currentMenu == .stuff {
                    if  self.selectedType == StuffType.All {
                        Animation.addLeftTransition(collection: self.profileCollectionView)
                        self.updateSegment(selected: 1)
                       // self.updateSegment(selected: 102)
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
        
        if self.selectedType == .All && self.currentMenu == .stuff {

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
        let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileUpdateView)
        self.navigationController?.pushAsPresent(viewController: obj)
    }
    
    @IBAction func btnActionNext(_ sender: Any) {
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
        }else {
            self.showToast(strMSG: kAlert_contentSelect)
        }
    }
  
    @objc func btnSelectAction(button : UIButton)  {
        let index   =   button.tag
        let indexPath   =   IndexPath(item: index, section: 0)
        if let cell = self.profileCollectionView.cellForItem(at: indexPath) {
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            let content = array[indexPath.row]
            content.isSelected = !content.isSelected
            for (index,obj) in ContentList.sharedInstance.arrayStuff.enumerated() {
                if obj.contentID.trim() == content.contentID.trim() {
                    obj.isSelected =  content.isSelected
                    ContentList.sharedInstance.arrayStuff[index] = obj
                }
            }
            
//            if let mainIndex =  ContentList.sharedInstance.arrayStuff.index(where: {$0.contentID.trim() == content.contentID.trim() && $0.stuffType == self.selectedType }) {
//                ContentList.sharedInstance.arrayStuff[mainIndex] = content
//            }
            if content.isSelected {
                (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            self.updateSelected(obj: content)
        }
    }
    
    
    func updateSelected(obj:ContentDAO){
       
        if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == obj.contentID.trim()}) {
            ContentList.sharedInstance.arrayContent.remove(at: index)
        }else {
            if obj.isSelected  {
                ContentList.sharedInstance.arrayContent.insert(obj, at: 0)
            }
        }
        
        let tempArray =  ContentList.sharedInstance.arrayContent.filter { $0.isSelected == true }
        ContentList.sharedInstance.arrayContent = tempArray
        
        let contains =  ContentList.sharedInstance.arrayContent.contains(where: { $0.isSelected == true })
        
        if contains {
            btnNext.isHidden = false
            self.btnAdd.isHidden = true
        }else {
            btnNext.isHidden = true
            self.btnAdd.isHidden = false
        }
        
    }
   
    func updateSegment(selected:Int){
        ContentList.sharedInstance.arrayContent.removeAll()
        switch selected {
        case 0:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedSegment = .EMOGOS
            self.lblNOResult.isHidden = true
            self.currentMenu = .stream
            self.btnNext.isHidden = true
            self.btnAdd.isHidden = false
            self.segmentMain.selectedSegmentIndex = 0
            break
        case 1:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.lblNOResult.isHidden = true
            self.selectedSegment = .COLLABS
            self.currentMenu = .colabs
            self.btnNext.isHidden = true
            self.btnAdd.isHidden = false
            self.segmentMain.selectedSegmentIndex = 1
            break
        case 2:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.lblNOResult.isHidden = true
            self.selectedSegment = .MYSTUFF
            self.currentMenu = .stuff
            self.btnNext.isHidden = true
            self.btnAdd.isHidden = false
            self.segmentMain.selectedSegmentIndex = 2
            break
            
        default:
            break
        }
    }
  /*
    private func updateSegment(selected:Int){
        ContentList.sharedInstance.arrayContent.removeAll()
        switch selected {
        case 101:
            self.lblNOResult.isHidden = true
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_active_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .stream
            self.btnNext.isHidden = true
            self.btnAdd.isHidden = false

            break
        case 102:
            self.lblNOResult.isHidden = true
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_active_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .colabs
            self.btnNext.isHidden = true
            self.btnAdd.isHidden = false

            break
        case 103:
            self.lblNOResult.isHidden = true
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_active_icon"), for: .normal)
            self.currentMenu = .stuff
            self.btnNext.isHidden = true
            self.btnAdd.isHidden = false
            break
        default:
            break
        }
    }*/
    
    private func updateConatiner(){
        self.profileCollectionView.es.resetNoMoreData()
        switch currentMenu {
        case .stuff:
            kStuffOptionsHeight.constant = 17.0
            if ContentList.sharedInstance.arrayStuff.count == 0  && self.isStuffUpdated {
                HUDManager.sharedInstance.showHUD()
                self.getTopContents()
              //  self.getMyStuff(type: .start)
            }else {
                let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
                var arrayTemp  = [ContentDAO]()
                for obj in ContentList.sharedInstance.arrayStuff {
                    obj.isSelected = false
                    arrayTemp.append(obj)
                }
                ContentList.sharedInstance.arrayStuff = arrayTemp
                self.lblNOResult.isHidden = true
                if array.count == 0  {
                    self.lblNOResult.isHidden = false
                    self.lblNOResult.text = "No Stuff Found"
                }
            }
            self.layout.headerHeight = 0.0
            self.profileCollectionView.reloadData()
            break
        case .stream:
            kStuffOptionsHeight.constant = 0.0
            if StreamList.sharedInstance.arrayProfileStream.count == 0  &&  self.isCalledMyStream {
                HUDManager.sharedInstance.showHUD()
                self.getStreamList(type:.start,filter: .myStream)
            }
            self.profileStreamShow()
          
            break
        case .colabs:
            kStuffOptionsHeight.constant = 0.0
            if StreamList.sharedInstance.arrayProfileColabStream.count == 0 && isCalledColabStream {
                HUDManager.sharedInstance.showHUD()
                self.getColabs(type: .start)
            }
            self.layout.headerHeight = 0.0
            self.profileStreamShow()
            self.profileCollectionView.reloadData()
         break
        }
    }
    @objc func btnSettingAction() {
        
        let settingVC = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_SettingView)
        self.navigationController?.pushAsPresent(viewController: settingVC)
        /*
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
        */
    }
    
    private func logout(){
        kDefault?.set(false, forKey: kUserLogggedIn)
        let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_InitialView)
        self.navigationController?.reverseFlipPush(viewController: obj)
    }
    
    
    @objc func btnActionForEdit(sender:UIButton) {
        let editVC : EditStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EditStreamView) as! EditStreamController
        if self.currentMenu == .stream {
            let stream = self.arrayMyStreams[sender.tag]
            editVC.streamID = stream.ID
        }else if self.currentMenu == .colabs {
            let stream = StreamList.sharedInstance.arrayProfileColabStream[sender.tag]
            editVC.streamID = stream.ID
        }
        editVC.isfromProfile = "fromProfile"
        let nav = UINavigationController(rootViewController: editVC)
        customPresentViewController(PresenterNew.EditStreamPresenter, viewController: nav, animated: true, completion: nil)
      
//        let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
//            let stream = self.arrayMyStreams[sender.tag]
//            obj.streamID = stream.ID
//            self.navigationController?.push(viewController: obj)
    }
    
    @objc func btnActionForHeaderEdit(sender:UIButton) {
        let editVC : EditStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EditStreamView) as! EditStreamController
         editVC.streamID = UserDAO.sharedInstance.user.stream?.ID
        editVC.isfromProfile = "fromProfile"
        let nav = UINavigationController(rootViewController: editVC)
        customPresentViewController(PresenterNew.EditStreamPresenter, viewController: nav, animated: true, completion: nil)
//        let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
//            obj.streamID = UserDAO.sharedInstance.user.stream?.ID
//            self.navigationController?.push(viewController: obj)
    }
    

    
    @objc func btnPlayAction(sender:UIButton){
        let content = ContentList.sharedInstance.arrayStuff[sender.tag]
        if content.isAdd {
        //    btnActionForAddContent()
        }else {
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isAdd == false }
            ContentList.sharedInstance.arrayContent = array
            if ContentList.sharedInstance.arrayContent.count != 0 {
                let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                objPreview.currentIndex = sender.tag
                let nav = UINavigationController(rootViewController: objPreview)
                let indexPath = IndexPath(row: sender.tag, section: 0)
                if let imageCell = profileCollectionView.cellForItem(at: indexPath) as? MyStuffCell {
                    nav.cc_setZoomTransition(originalView: imageCell.imgCover)
                    nav.cc_swipeBackDisabled = true
                }
           self.present(nav, animated: true, completion: nil)
//                let nav = UINavigationController(rootViewController: objPreview)
//            customPresentViewController( PresenterNew.instance.contentContainer, viewController: nav, animated: true)
            }
        }
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
                        lblNOResult.text = "No Emogo Found."
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
                    lblNOResult.text = "No Emogo Found."
                    lblNOResult.isHidden = false
                }
            }
            
            self.profileCollectionView.reloadData()
        }else if self.currentMenu == .colabs {
            self.lblNOResult.isHidden = true
            if StreamList.sharedInstance.arrayProfileColabStream.count == 0 {
                self.lblNOResult.text  = "No Emogo Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
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
                self.lblNOResult.text  = "No Emogo Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
            self.isCalledMyStream = false
            self.profileStreamShow()
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    func getTopContents(){
        APIServiceManager.sharedInstance.apiForGetTopContent { (_, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.lblNOResult.isHidden = true
                self.btnNext.isHidden = true
                self.btnAdd.isHidden = false
                let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
                if array.count == 0 {
                    self.lblNOResult.text  = "No Stuff Found"
                    self.lblNOResult.minimumScaleFactor = 1.0
                    self.lblNOResult.isHidden = false
                }
                self.isStuffUpdated = false

                self.layout.headerHeight = 0.0
                self.profileCollectionView.reloadData()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    func getMyStuff(type:RefreshType){
        if type == .start || type == .up {
            ContentList.sharedInstance.arrayContent.removeAll()
            for _ in  ContentList.sharedInstance.arrayStuff {
                if let index = ContentList.sharedInstance.arrayStuff.index(where: { $0.stuffType == selectedType}) {
                     ContentList.sharedInstance.arrayStuff.remove(at: index)
                   // print("Removed")
                }
            }
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
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            if array.count == 0 {
                self.lblNOResult.text  = "No Stuff Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
            self.layout.headerHeight = 0.0
            self.profileCollectionView.reloadData()
             self.btnAdd.isHidden = true
            if ContentList.sharedInstance.arrayContent.count == 0 {
                self.btnNext.isHidden = true
                self.btnAdd.isHidden = false
            }
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getColabs(type:RefreshType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayProfileColabStream.removeAll()
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
            if StreamList.sharedInstance.arrayProfileColabStream.count == 0 {
                self.lblNOResult.text  = "No Emogo Found"
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
    
    
    func reorderContent(orderArray:[ContentDAO]) {
        
        APIServiceManager.sharedInstance.apiForReorderMyContent(orderArray: orderArray) { (isSuccess,errorMSG)  in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.profileCollectionView.reloadData()
                self.selectedIndex = nil
            }
        }
    }
    
    
    
    
    @IBAction func btnActionAdd(_ sender: Any) {
        
        self.btnAdd.isHaptic = true
        self.btnAdd.hapticType = .impact(.light)
        kDefault?.setValue(true, forKey: kBounceAnimation)
        if self.timer != nil {
            self.timer?.invalidate()
        }
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.objStream = nil
        let actionVC : ActionSheetViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_ActionSheet) as! ActionSheetViewController
        actionVC.delegate = self
        customPresentViewController(PresenterNew.ActionSheetPresenter, viewController: actionVC, animated: true, completion: nil)
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
        let createVC : CreateStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CreateStreamView) as! CreateStreamController
        createVC.exestingNavigation = self.navigationController
        let nav = UINavigationController(rootViewController: createVC)
        customPresentViewController(PresenterNew.CreateStreamPresenter, viewController: nav, animated: true, completion: nil)
//        let controller = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView)
//        self.navigationController?.push(viewController: controller)
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
            camera.fileName = NSUUID().uuidString + ".png"
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

    @objc func startAnimation(){
       // print("Called")
        
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
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            return array.count
        }else if currentMenu == .colabs {
            return StreamList.sharedInstance.arrayProfileColabStream.count
        }else {
            return self.arrayMyStreams.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         self.lblNOResult.isHidden = true
        // Create the cell and return the cell
        if currentMenu == .stuff {
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            
            let content = array[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_MyStuffCell, for: indexPath) as! MyStuffCell
            // for Add Content
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            cell.btnSelect.tag = indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(self.btnSelectAction(button:)), for: .touchUpInside)
            cell.btnPlay.tag = indexPath.row
            cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
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
            if stream.haveSomeUpdate {
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = kCardViewBordorColor.cgColor
            }else {
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            self.lblNOResult.isHidden = true
            cell.btnEdit.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(self.btnActionForEdit(sender:)), for: .touchUpInside)
            let isIndexValid = StreamList.sharedInstance.arrayProfileColabStream.indices.contains(indexPath.row)
            if isIndexValid {
                let stream = StreamList.sharedInstance.arrayProfileColabStream[indexPath.row]
                cell.prepareLayouts(stream: stream)
                if stream.haveSomeUpdate {
                    cell.layer.borderWidth = 1.0
                    cell.layer.borderColor = kCardViewBordorColor.cgColor
                }else {
                    cell.layer.borderWidth = 0.0
                    cell.layer.borderColor = UIColor.clear.cgColor
                }
            }
           
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
                headerView.btnEditHeader.addTarget(self, action: #selector(self.btnActionForHeaderEdit(sender:)), for: .touchUpInside)
            }
            headerView.imgCover.layer.cornerRadius = 5.0
            headerView.imgCover.layer.masksToBounds = true
            headerView.imgUser.isHidden = true
            headerView.btnEditHeader.isHidden = false
            
            
            return headerView
            
        default:
            
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if currentMenu == .stuff {
            if self.selectedType == .All {
                let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
                if selectedIndex != nil {
                    let tempContent = ContentList.sharedInstance.arrayStuff[selectedIndex!.row]
                    return CGSize(width: tempContent.width, height: tempContent.height)
                }
                return CGSize(width: content.width, height: content.height)
            }else {
                let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
                let content = array[indexPath.row]
                return CGSize(width: content.width, height: content.height)
            }
        }else {
            let itemWidth = collectionView.bounds.size.width/2.0
            return CGSize(width: itemWidth, height: itemWidth - 40)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentMenu == .stuff {
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            let content = array[indexPath.row]
            if content.isAdd {
             //   btnActionForAddContent()
            }else {
                ContentList.sharedInstance.arrayContent = array
                if ContentList.sharedInstance.arrayContent.count != 0 {
                    //
                   // let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                    
                    let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                      objPreview.currentIndex = indexPath.row
                      objPreview.isProfile = "TRUE"
                    let nav = UINavigationController(rootViewController: objPreview)
                    if let imageCell = collectionView.cellForItem(at: indexPath) as? MyStuffCell {
                        nav.cc_setZoomTransition(originalView: imageCell.imgCover)
                        nav.cc_swipeBackDisabled = true
                    }
                    self.present(nav, animated: true, completion: nil)
                    
                  //  self.navigationController?.push(viewController: objPreview)
                }
            }
        }else {
          //  let stream = StreamList.sharedInstance.arrayProfileStream[indexPath.row]
                var index = 0
            if let cell = collectionView.cellForItem(at: indexPath) {
                selectedImageView = (cell as! ProfileStreamCell).imgCover
            }
            let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
            if currentMenu == .stream {
                let tempStream = self.arrayMyStreams[indexPath.row]
                let tempIndex = StreamList.sharedInstance.arrayProfileStream.index(where: {$0.ID.trim() == tempStream.ID.trim()})
                if tempIndex != nil {
                    index = tempIndex!
                }
                obj.viewStream = "fromProfile"
                
                StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileStream
            }else {
                
                obj.viewStream = "fromColabProfile"
                index = indexPath.row
                StreamList.sharedInstance.arrayViewStream.removeAll()
                StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileColabStream
            }
            obj.currentIndex = index
            ContentList.sharedInstance.objStream = nil
            self.navigationController?.pushViewController(obj, animated: true)
            }
        }
    
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if self.selectedType == .All && self.currentMenu == .stuff {
            
            let contentDest = ContentList.sharedInstance.arrayStuff[sourceIndexPath.row]
            ContentList.sharedInstance.arrayStuff.remove(at: sourceIndexPath.row)
            ContentList.sharedInstance.arrayStuff.insert(contentDest, at: destinationIndexPath.row)
            DispatchQueue.main.async {
                self.profileCollectionView.reloadItems(at: [destinationIndexPath,sourceIndexPath])
                HUDManager.sharedInstance.showHUD()
                self.reorderContent(orderArray:ContentList.sharedInstance.arrayStuff)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if self.selectedType == .All && self.currentMenu == .stuff {
            return true
        }else {
            return false
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let delta =  scrollView.contentOffset.y - oldContentOffset.y
        
        //we compress the top view
        if delta > 0 && kHeaderHeight.constant > topConstraintRange.lowerBound && scrollView.contentOffset.y > 0 {
            print(delta)
         //   btnContainer.addBorders(edges: .top, color: .white, thickness: 1)
            kHeaderHeight.constant -= delta
            scrollView.contentOffset.y -= delta
             print(delta)
        }
        
        //we expand the top view
        if delta < 0 && kHeaderHeight.constant < topConstraintRange.upperBound && scrollView.contentOffset.y < 0{
             print(delta)
         //   btnContainer.addBorders(edges: .top, color: color, thickness: 1)
            kHeaderHeight.constant -= delta
            scrollView.contentOffset.y -= delta
            print(delta)
        }
        oldContentOffset = scrollView.contentOffset
    }
    
    func actionForCover(imageView:UIImageView){
       
        if UserDAO.sharedInstance.user.stream != nil {
            if (UserDAO.sharedInstance.user.stream?.isColabStream)! {
                if self.currentMenu == .stream {
                    self.profileStreamIndex = 0
                    var array = StreamList.sharedInstance.arrayProfileStream.filter { $0.isAdd == false }
                    array.insert(UserDAO.sharedInstance.user.stream!, at: 0)
                    StreamList.sharedInstance.arrayViewStream = array
                }else {
                    StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileColabStream
                }
            }else {
                let array = StreamList.sharedInstance.arrayProfileStream.filter { $0.isAdd == false }
                StreamList.sharedInstance.arrayViewStream = array
            }
        }
      
        selectedImageView = imageView
        let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
        obj.currentIndex = profileStreamIndex
        obj.viewStream = "fromProfile"
        ContentList.sharedInstance.objStream = nil
        self.navigationController?.pushViewController(obj, animated: true)
    }
}

extension ProfileViewController : ActionSheetControllerHeaderActionDelegate {
    func actionSheetControllerHeaderButtonAction() {
        self.actionForAddStream()
    }
}
