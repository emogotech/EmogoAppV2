//
//  ProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
//import XLActionController
import Social
import Haptica


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
    @IBOutlet weak var btnNextStuff: UIButton!
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
   
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var segmentMain: HMSegmentedControl!
    @IBOutlet weak var heightviewBio: NSLayoutConstraint!
    @IBOutlet weak var kViewLocWebHeight: NSLayoutConstraint!
    
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
    var timer:Timer?
    
    let color = UIColor(r: 155, g: 155, b: 155)
    let colorSelected = UIColor.black
    let font = UIFont(name: "SFProText-Bold", size: 14.0)
    let fontSelected = UIFont(name: "SFProText-Medium", size: 14.0)
    let fontSegment = UIFont(name: "SFProText-Bold", size: 12.0)

    var lastOffset:CGPoint! = CGPoint.zero
    var didScrollInLast:Bool! = false
    var selectedType:StuffType! = StuffType.All
    var selectedSegment:SegmentType! = SegmentType.EMOGOS
    var profileStreamIndex = 0
    var isCalledMyStream:Bool! = true
    var isCalledColabStream:Bool! = true
    var isStuffUpdated:Bool! = true
    var objStream : StreamViewDAO?
    
    var lastIndex : Int = 10
    var refresher: UIRefreshControl?
    var oldContentOffset = CGPoint.zero
    var topConstraintRange = (CGFloat(0)..<CGFloat(220))
    var selectedImageView:UIImageView?
    var hudView  : LoadingView!
    var hudRefreshView : LoadingView!
    var strBackFromColab:String! = ""
    
   // 178
    let layout = CHTCollectionViewWaterfallLayout()

    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayouts()
        self.setupLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lblName.text = UserDAO.sharedInstance.user.fullName.trim()
        self.prepareLayout()
        updateList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.lblName.text = UserDAO.sharedInstance.user.fullName.trim()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        self.title = "Profile"
        self.btnNextStuff.isHidden = true
//        self.btnClose.tintColor = UIColor(r: 0, g: 122, b: 255)
//        self.btnShare.tintColor = UIColor(r: 0, g: 122, b: 255)
//        self.btnSetting.tintColor = UIColor(r: 0, g: 122, b: 255)
        self.lblName.text = UserDAO.sharedInstance.user.fullName.trim()
        ContentList.sharedInstance.arrayStuff.removeAll()
        StreamList.sharedInstance.arrayProfileStream.removeAll()
        StreamList.sharedInstance.arrayProfileColabStream.removeAll()
        self.profileCollectionView.dataSource  = self
        self.profileCollectionView.delegate = self
    
        kShowOnlyMyStream = "1"
        self.getStreamList(type:.start,filter: .myStream)
        self.setupRefreshLoader()

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
      //  segmentMain.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
        segmentMain.selectionIndicatorColor =  kCardViewBordorColor
        segmentMain.selectionStyle = .textWidthStripe
        segmentMain.selectedSegmentIndex = 0
        segmentMain.selectionIndicatorLocation = .down
        segmentMain.shouldAnimateUserSelection = false
    }
    
    func prepareLayout() {
       // lblUserName.text = "@" + UserDAO.sharedInstance.user.fullName.trim()
       // lblUserName.minimumScaleFactor = 1.0
        APIServiceManager.sharedInstance.apiForGetUserInfo(userID: UserDAO.sharedInstance.user.userProfileID, isCurrentUser: true) { (_, _) in
            
            DispatchQueue.main.async {
                self.imgLink.image = #imageLiteral(resourceName: "link icon")
                self.imgLocation.image = #imageLiteral(resourceName: "location icon")
                self.lblLocation.isHidden = false
                self.lblWebsite.isHidden = false
                self.lblFollowers.isHidden = true
                self.lblFollowing.isHidden = true

                self.lblFullName.text =  UserDAO.sharedInstance.user.displayName.trim().capitalized
                self.lblFullName.minimumScaleFactor = 1.0
               // self.lblWebsite.text = UserDAO.sharedInstance.user.website.trim()
                self.lblWebsite.minimumScaleFactor = 1.0
               // self.lblLocation.text = UserDAO.sharedInstance.user.location.trim()
                self.lblLocation.minimumScaleFactor = 1.0
                self.lblBio.text = UserDAO.sharedInstance.user.biography.trim()
                
                self.heightviewBio.constant = 42
                self.kViewLocWebHeight.constant = 32
                
                if UserDAO.sharedInstance.user.website.trim().count > 20 {
                      self.lblWebsite.text = "\(UserDAO.sharedInstance.user.website.trim(count: 20))..."
                }
                if UserDAO.sharedInstance.user.location.trim().count > 15 {
                    self.lblLocation.text = "\(UserDAO.sharedInstance.user.location.trim(count: 15))..."
                }
                if UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.kHeaderHeight.constant = 178
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(178))
                }else {
                    self.kHeaderHeight.constant = 220
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(220))
                }
                //self.lblBirthday.text = UserDAO.sharedInstance.user.birthday.trim()
                self.lblName.text = UserDAO.sharedInstance.user.fullName.trim()
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
            //    self.imgUser.borderWidth = 1.0
              //  self.imgUser.borderColor = UIColor(r: 13, g: 192, b: 237)
               

//                if UserDAO.sharedInstance.user.location.trim().isEmpty && !UserDAO.sharedInstance.user.website.trim().isEmpty {
//                    self.lblLocation.text = UserDAO.sharedInstance.user.website.trim()
//                    self.lblWebsite.isHidden = true
//                    self.imgLink.isHidden = true
//                    self.imgLocation.isHidden = false
//                    self.imgLocation.image = self.imgLink.image
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
//                    self.lblLocation.addGestureRecognizer(tap)
//                    self.lblLocation.isUserInteractionEnabled = true
//                }
                
                if !UserDAO.sharedInstance.user.location.trim().isEmpty && !UserDAO.sharedInstance.user.website.trim().isEmpty && UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    
                    self.lblLocation.text = "\(UserDAO.sharedInstance.user.location.trim(count: 15))..."
                    self.lblWebsite.text =  "\(UserDAO.sharedInstance.user.website.trim(count: 20))..."
                    self.lblLocation.isHidden = false
                    self.lblWebsite.isHidden =  false
                    self.imgLink.isHidden = false
                    self.imgLocation.isHidden = false
                    self.lblBio.isHidden =  true
                    self.heightviewBio.constant = 0
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                    self.lblLocation.addGestureRecognizer(tap)
                    self.lblLocation.isUserInteractionEnabled = true
                    self.kHeaderHeight.constant = 165//178
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(165))
                }
                    
                else if UserDAO.sharedInstance.user.location.trim().isEmpty && !UserDAO.sharedInstance.user.website.trim().isEmpty && UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.lblLocation.text = "\(UserDAO.sharedInstance.user.website.trim(count: 20))..."
                    self.lblWebsite.isHidden = true
                    self.lblBio.isHidden = true
                    self.heightviewBio.constant = 0
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLink.image
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                    self.lblLocation.addGestureRecognizer(tap)
                    self.lblLocation.isUserInteractionEnabled = true
                    self.kHeaderHeight.constant = 170//172
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(170))
                }
                else if UserDAO.sharedInstance.user.location.trim().isEmpty && !UserDAO.sharedInstance.user.website.trim().isEmpty && !UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.lblLocation.text = "\(UserDAO.sharedInstance.user.website.trim(count: 20))..."
                    self.lblWebsite.isHidden = true
                    self.lblBio.isHidden = true
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLink.image
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                    self.lblLocation.addGestureRecognizer(tap)
                    self.lblLocation.isUserInteractionEnabled = true
                    self.kHeaderHeight.constant = 205//210
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(205))
                }
                    
                else if !UserDAO.sharedInstance.user.location.trim().isEmpty && UserDAO.sharedInstance.user.website.trim().isEmpty && UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.lblLocation.text = "\(UserDAO.sharedInstance.user.website.trim(count: 20))..."
                    self.lblWebsite.isHidden = true
                    self.lblBio.isHidden = true
                    self.heightviewBio.constant = 0
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLocation.image
                    self.kHeaderHeight.constant = 170//172
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(170))
                }
                else if !UserDAO.sharedInstance.user.location.trim().isEmpty && UserDAO.sharedInstance.user.website.trim().isEmpty && !UserDAO.sharedInstance.user.biography.trim().isEmpty {
                    self.lblLocation.text = "\(UserDAO.sharedInstance.user.website.trim(count: 20))..."
                    self.lblWebsite.isHidden = true
                    self.lblBio.isHidden = false
                    self.imgLink.isHidden = true
                    self.imgLocation.isHidden = false
                    self.imgLocation.image = self.imgLocation.image
                    self.kHeaderHeight.constant = 205//210
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
                    self.lblWebsite.isHidden = false
                    self.kHeaderHeight.constant = 205//210
                    self.topConstraintRange = (CGFloat(0)..<CGFloat(205))
                    
                }
                self.profileStreamShow()
            }
            
        }
      
      //  btnContainer.addBorders(edges: [UIRectEdge.top,UIRectEdge.bottom], color: color, thickness: 1)
//        btnContainer.addBorders(edges: UIRectEdge.top, color: color, thickness: 1)
//        btnContainer.roundCorners([.topLeft,.topRight], radius: 10)
//        btnContainer.layer.masksToBounds = true
        
        
        if  self.currentMenu == .stuff {
            kStuffOptionsHeight.constant = 17.0
        }else {
            kStuffOptionsHeight.constant = 0.0
        }
        
    }
    @objc func actionForWebsite(){
        
        guard let url = URL(string: UserDAO.sharedInstance.user.website.stringByAddingPercentEncodingForURLQueryParameter()!) else {
            self.showToastIMsg( type: .error, strMSG: kAlert_ValidWebsite)
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
    // MARK:- LoaderSetup
    
    func setupLoader() {
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        hudView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        hudView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hudView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        DispatchQueue.main.async {
            self.hudView.startLoaderWithAnimation()
        }
    }

    func updateList(){
        self.lblName.text = UserDAO.sharedInstance.user.fullName.trim()
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
               
                self.getStreamList(type:.start,filter: .myStream)
            }else {
               
                self.getColabs(type: .start)
            }
        }
    }
   /*
    func updateStuffList(index:Int){
        switch index {
        case 0:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
               Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = .All
            break
        case 1:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
               Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Picture
            break
        case 2:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
              Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Video
            break
        case 3:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
               Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Links
            break
        case 4:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
               Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Notes
            break
        case 5:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
               Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = StuffType.Giphy
            break
        default:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
               Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedType = .All
        }
        
        if  ContentList.sharedInstance.arrayContent.count == 0 {
            for i in 0..<ContentList.sharedInstance.arrayStuff.count {
                let obj = ContentList.sharedInstance.arrayStuff[i]
                obj.isSelected = false
                ContentList.sharedInstance.arrayStuff[i] = obj
            }
        }
        
        
        self.btnNext.isHidden = true
   
        if ContentList.sharedInstance.arrayContent.count != 0 {
            self.btnNext.isHidden = false
         
        }
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        self.lblNOResult.isHidden = true
        if array.count == 0  {
            self.lblNOResult.isHidden = false
            self.lblNOResult.text = "No Stuff Found"
        }
        self.profileCollectionView.reloadData()
    }*/
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
       
        
        if  ContentList.sharedInstance.arrayContent.count == 0 {
            self.btnNextStuff.isHidden = true
            for i in 0..<ContentList.sharedInstance.arrayStuff.count {
                let obj = ContentList.sharedInstance.arrayStuff[i]
                obj.isSelected = false
                ContentList.sharedInstance.arrayStuff[i] = obj
            }
        }
        
        self.btnNextStuff.isHidden = true
      
        if ContentList.sharedInstance.arrayContent.count != 0 {
            self.btnNextStuff.isHidden = false

        }
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        self.lblNOResult.isHidden = true
        if array.count == 0  {
            self.lblNOResult.isHidden = false
            self.lblNOResult.text = "No Stuff Found"
        }
        self.profileCollectionView.reloadData()
    }
    
    @objc func resignRefreshLoader(){
        self.refresher?.endRefreshing()
        if hudRefreshView != nil {
            hudRefreshView.stopLoaderWithAnimation()
        }
        self.refresher?.frame = CGRect.zero
    }
    
    func streaminputDataType(type:RefreshType) {
        if(type == .start){
            if hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            self.resignRefreshLoader()
        }
        else{
            self.resignRefreshLoader()
        }
    }
    
    // MARK:- pull to refresh LoaderSetup
    
    func setupRefreshLoader() {
        if self.refresher == nil {
            self.refresher = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: self.profileCollectionView.frame.size.width, height: 100))
            
            hudRefreshView  = LoadingView.init(frame: (self.refresher?.frame)!)
            hudRefreshView.load?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            hudRefreshView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            hudRefreshView.loaderImage?.isHidden = true
            hudRefreshView.load?.frame = CGRect(x: 0, y: (self.refresher?.frame.width)!/2-30, width: 30, height: 30)
            hudRefreshView.load?.translatesAutoresizingMaskIntoConstraints = false
            hudRefreshView.load?.widthAnchor.constraint(equalToConstant: 30).isActive = true
            hudRefreshView.load?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            hudRefreshView.load?.lineWidth = 3.0
            hudRefreshView.load?.duration = 2.0
            self.refresher?.addSubview(hudRefreshView)
            
            self.profileCollectionView!.alwaysBounceVertical = true
            self.refresher?.tintColor = UIColor.clear
            self.refresher?.addTarget(self, action: #selector(pullToDownAction), for: .valueChanged)
            self.profileCollectionView!.addSubview(refresher!)
           
        }
    }
    @objc func pullToDownAction() {
        
        self.refresher?.frame = CGRect(x: 0, y: 0, width: self.profileCollectionView.frame.size.width, height: 100)
        SharedData.sharedInstance.nextStreamString = ""
        self.hudRefreshView.startLoaderWithAnimation()
      //  self.profileCollectionView.isUserInteractionEnabled = false
        if self.currentMenu == .stream {
            self.getStreamList(type:.up,filter:.myStream)
        }else if self.currentMenu == .stuff {
            self.getMyStuff(type: .up)
        }else {
            self.getColabs(type: .up)
        }
   
    }
  
    //MARK:- Button Action
    
    @IBAction func btnNextStuffAction(_ sender: Any) {
       
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Add_Content , preferredStyle: .alert)
        let Continue = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            
            let strUrl = "\(kDeepLinkURL)\(kDeepLinkUserProfile)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let Cancel = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(Continue)
        alert.addAction(Cancel)
        present(alert, animated: true, completion: nil)
    }
   
    
    @IBAction func btnSettingAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kStoryboardID_SettingView) as! SettingViewController
        self.present(vc, animated: true, completion: nil)
      
    }
    
    @IBAction func btnProfileAction(_ sender: Any) {
        
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
     
        if self.strBackFromColab == "backFromColab" {
          self.dismiss(animated: true, completion: nil)
        }else if strBackFromColab == "fromViewStreamColab"{
          self.dismiss(animated: true, completion: nil)
        }else if strBackFromColab == "fromProfile" {
            let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            vc.isFromProfile = true
            self.present(vc, animated: true, completion: nil)
        }
        else{
           self.dismiss(animated: true, completion: nil)

    }
}
    
    @IBAction func btnShareAction(_ sender: Any) {
        self.profileShareAction()
    }
    
    // MARK: -  Action Methods And Selector
   
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
                print("Swie Right")
                if kDefault?.bool(forKey: kHapticFeedback) == true{
                    Haptic.impact(.light).generate()
                }else{
                    
                }
                if currentMenu == .colabs {
                    Animation.addLeftTransition(collection: self.profileCollectionView)
                    self.updateSegment(selected: 0)
                    //self.updateSegment(selected: 101)
                }else if currentMenu == .stuff {
                    if  self.selectedType == StuffType.All {
                        Animation.addLeftTransition(collection: self.profileCollectionView)
                        self.updateSegment(selected: 1)
                        //self.updateSegment(selected: 102)
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
        let obj:FollowersViewController =  self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_FollowersView) as! FollowersViewController
        if gesture.view?.tag == 111 {
            obj.listType = FollowerType.Follower
        }else {
            obj.listType = FollowerType.Following
        }
         self.present(obj, animated: true, completion: nil)

    }
    
    //MARK:- Button Action
    
    @IBAction func btnActionMenuSelected(_ sender: UIButton) {
        self.updateSegment(selected: sender.tag)
    }
    
    @IBAction func btnActionProfileUpdate(_ sender: UIButton) {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Profile , preferredStyle: .alert)
        let Continue = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            let strUrl = "\(kDeepLinkURL)\(kDeepLinkTypeProfile)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let Cancel = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(Continue)
        alert.addAction(Cancel)
        present(alert, animated: true, completion: nil)
      
    }
    @objc func btnActionForHeaderEdit(sender:UIButton) {
       
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Edit_Stream , preferredStyle: .alert)
        let Continue = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            let streamId = UserDAO.sharedInstance.user.stream?.ID
            let strUrl = "\(kDeepLinkURL)\(streamId!)/\(kDeepLinkTypeEditStream)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)

        }
        let Cancel = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(Continue)
        alert.addAction(Cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func btnActionForEdit(sender:UIButton) {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Edit_Stream , preferredStyle: .alert)
        let Continue = UIAlertAction(title: kAlert_Confirmation_Button_Title   , style: .default) { (action) in
            let stream = self.arrayMyStreams[sender.tag]
            let strUrl = "\(kDeepLinkURL)\(stream.ID!)/\(kDeepLinkTypeEditStream)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
//            let strUrl = "\(kDeepLinkURL)\(kDeepLinkTypeEditStream)"
//            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let Cancel = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(Continue)
        alert.addAction(Cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func btnSelectAction(button : UIButton)  {
        let index   =   button.tag
        let indexPath   =   IndexPath(item: index, section: 0)
        if let cell = self.profileCollectionView.cellForItem(at: indexPath) {
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            let content = array[indexPath.row]
            content.isSelected = !content.isSelected
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
        
        let contains =  ContentList.sharedInstance.arrayContent.contains(where: { $0.isSelected == true })
        
        if contains {
             self.btnNextStuff.isHidden = false
            
        }else {
             self.btnNextStuff.isHidden = true
           
        }
        
    }
    
    private func updateSegment(selected:Int){
         ContentList.sharedInstance.arrayContent.removeAll()
        switch selected {
        case 0:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedSegment = .EMOGOS
            self.currentMenu = .stream
            self.btnNextStuff.isHidden = true
            self.segmentMain.selectedSegmentIndex = 0
            break
        case 1:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedSegment = .COLLABS
            self.currentMenu = .colabs
            self.btnNextStuff.isHidden = true
            self.segmentMain.selectedSegmentIndex = 1
            
            break
        case 2:
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.selectedSegment = .MYSTUFF
            self.currentMenu = .stuff
            self.btnNextStuff.isHidden = true
            self.segmentMain.selectedSegmentIndex = 2
            break
        default:
            break
        }
    }
    
   /*
    private func updateSegment(selected:Int){
        switch selected {
        case 101:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_active_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .stream
            self.btnNext.isHidden = true
         
            break
        case 102:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_active_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .colabs
            self.btnNext.isHidden = true
          

            break
        case 103:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_active_icon"), for: .normal)
            self.currentMenu = .stuff
            self.btnNext.isHidden = true
          
            break
        default:
            break
        }
    }*/
    
    private func updateConatiner(){
     
        switch currentMenu {
        case .stuff:
            kStuffOptionsHeight.constant = 17.0
            if ContentList.sharedInstance.arrayStuff.count == 0  && self.isStuffUpdated {
              
                self.getTopContents()
              //  self.getMyStuff(type: .start)
            }else {
                let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
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
            
                self.getStreamList(type:.start,filter: .myStream)
            }
            self.profileStreamShow()
          
            break
        case .colabs:
            kStuffOptionsHeight.constant = 0.0
            if StreamList.sharedInstance.arrayProfileColabStream.count == 0 && isCalledColabStream {
             
                self.getColabs(type: .start)
            }
            self.layout.headerHeight = 0.0
            self.profileStreamShow()
            self.profileCollectionView.reloadData()
         break
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
             self.hudView.stopLoaderWithAnimation()
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            
            if self.hudRefreshView != nil {
                self.hudRefreshView.stopLoaderWithAnimation()
            }
            self.streaminputDataType(type: type)
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
                self.showToastIMsg(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    func getTopContents(){
    
        APIServiceManager.sharedInstance.apiForGetTopContent { (_, errorMsg) in
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            
            if self.hudRefreshView != nil {
                self.hudRefreshView.stopLoaderWithAnimation()
            }
            self.streaminputDataType(type: .start)
            if (errorMsg?.isEmpty)! {
                self.lblNOResult.isHidden = true
                self.btnNextStuff.isHidden = true
               
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
                self.showToastIMsg(type: .success, strMSG: errorMsg!)
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
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            
            if self.hudRefreshView != nil {
                self.hudRefreshView.stopLoaderWithAnimation()
            }
            self.streaminputDataType(type: type)
            
            self.lblNOResult.isHidden = true
              if ContentList.sharedInstance.arrayContent.count == 0 {
                  self.btnNextStuff.isHidden = true
            }
           
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            if array.count == 0 {
                self.lblNOResult.text  = "No Stuff Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
            self.layout.headerHeight = 0.0
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
              self.showToastIMsg(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getColabs(type:RefreshType){
       
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayProfileColabStream.removeAll()
            self.profileCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetColabList(type: type) { (refreshType, errorMsg) in
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            
            if self.hudRefreshView != nil {
                self.hudRefreshView.stopLoaderWithAnimation()
            }
            self.streaminputDataType(type: type)
            self.lblNOResult.isHidden = true
            if StreamList.sharedInstance.arrayProfileColabStream.count == 0 {
                self.lblNOResult.text  = "No Emogo Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
            self.isCalledColabStream = false
            self.layout.headerHeight = 0.0
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
               self.showToastIMsg(type: .success, strMSG: errorMsg!)
            }
        }
    }

    func reorderContent(orderArray:[ContentDAO]) {
        
        APIServiceManager.sharedInstance.apiForReorderMyContent(orderArray: orderArray) { (isSuccess,errorMSG)  in
         
            if (errorMSG?.isEmpty)! {
                self.profileCollectionView.reloadData()
                self.selectedIndex = nil
            }
        }
    }
    @objc func btnPlayAction(sender:UIButton){
        
        let content = ContentList.sharedInstance.arrayStuff[sender.tag]
        if content.isAdd {
            //    btnActionForAddContent()
        }else {
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isAdd == false }
            ContentList.sharedInstance.arrayContent = array
            if ContentList.sharedInstance.arrayContent.count != 0 {
                let obj:StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
              
                obj.arrContentData = array
                obj.currentStreamID = self.objStream?.streamID!
                obj.currentContentIndex  = sender.tag
                obj.currentStreamTitle = self.objStream?.title
                let nav = UINavigationController(rootViewController:  obj)
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
       
//        let content = ContentList.sharedInstance.arrayStuff[sender.tag]
//        if content.isAdd {
//            //    btnActionForAddContent()
//        }else {
//            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isAdd == false }
//            ContentList.sharedInstance.arrayContent = array
//            if ContentList.sharedInstance.arrayContent.count != 0 {
//                let obj:StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
//                obj.arrContentData = array
//                obj.currentStreamID = self.objStream?.streamID!
//                obj.currentContentIndex  = sender.tag
//                obj.currentStreamTitle = self.objStream?.title
//                self.present(obj, animated: false, completion: nil)
//            }
//
//            }
        }
    /*
    func profileStreamShow(){
        
        if UserDAO.sharedInstance.user.stream != nil {
            
            if (UserDAO.sharedInstance.user.stream?.isColabStream)! {
                if (UserDAO.sharedInstance.user.stream?.CoverImage.trim().isEmpty)! {
                    self.layout.headerHeight = 0
                }else {
                    self.layout.headerHeight = 200
                }
                
            }else {
                if self.currentMenu == .stream {
                    if (UserDAO.sharedInstance.user.stream?.CoverImage.trim().isEmpty)! {
                        self.layout.headerHeight = 0
                    }else {
                        self.layout.headerHeight = 200
                    }
                }else {
                    self.layout.headerHeight = 0
                }
            }
        }else {
            self.layout.headerHeight = 0
        }
        
        self.lblNOResult.isHidden = true
        if self.currentMenu == .stream {
            arrayMyStreams = StreamList.sharedInstance.arrayProfileStream
            let index = StreamList.sharedInstance.arrayProfileStream.index(where: {$0.ID.trim() == UserDAO.sharedInstance.user.stream?.ID.trim()})
            if index != nil {
                profileStreamIndex = index!
                arrayMyStreams.remove(at: index!)
            }
            if arrayMyStreams.count == 0 {
                lblNOResult.text = "No Emogo Found."
                lblNOResult.isHidden = false
            }
        }else if self.currentMenu == .colabs {
            arrayMyStreams = StreamList.sharedInstance.arrayProfileColabStream
            
            let index = StreamList.sharedInstance.arrayProfileColabStream.index(where: {$0.ID.trim() == UserDAO.sharedInstance.user.stream?.ID.trim()})
            if index != nil {
                profileStreamIndex = index!
                arrayMyStreams.remove(at: index!)
            }
            
            if arrayMyStreams.count == 0 {
                self.lblNOResult.text  = "No Emogo Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
        }
        
        self.profileCollectionView.reloadData()
        
    }*/
    
}


extension ProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout,ProfileStreamViewDelegate
{
    func actionForCover(imageView: UIImageView) {
        
//        let obj:StreamViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Stream) as! StreamViewController
          let obj:ViewStreamController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
        if UserDAO.sharedInstance.user.stream != nil {
            if (UserDAO.sharedInstance.user.stream?.isColabStream)! {
                if self.currentMenu == .stream {
                    self.profileStreamIndex = 0
                    var array = StreamList.sharedInstance.arrayProfileStream.filter { $0.isAdd == false }
                    array.insert(UserDAO.sharedInstance.user.stream!, at: 0)
                 
                    StreamList.sharedInstance.arrayViewStream = array
                    obj.arrStream = array
                }else {
                    StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileColabStream
                    obj.arrStream = StreamList.sharedInstance.arrayProfileColabStream
                }
            }else {
                let array = StreamList.sharedInstance.arrayProfileStream.filter { $0.isAdd == false }
                StreamList.sharedInstance.arrayViewStream = array
                obj.arrStream = array
            }
        }
        
        selectedImageView = imageView
        obj.currentStreamIndex = profileStreamIndex
        ContentList.sharedInstance.objStream = nil
        self.present(obj, animated: false, completion: nil)
            
        }
    
    
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamView, for: indexPath) as! ProfileStreamViewCell
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamView, for: indexPath) as! ProfileStreamViewCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
           
            cell.btnEdit.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(self.btnActionForEdit(sender:)), for: .touchUpInside)
            let stream = StreamList.sharedInstance.arrayProfileColabStream[indexPath.row]
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
               
            headerView.delegate = self as! ProfileStreamViewDelegate
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
               // btnActionForAddContent()
            }else {
                isEdited = true
                ContentList.sharedInstance.arrayContent = array
                
               if ContentList.sharedInstance.arrayContent.count != 0  {
                let content = ContentDAO(contentData: [:])
                content.coverImage = objStream?.coverImage
                content.isUploaded = true
                content.type = .image
                content.fileName = "SreamCover"
                content.name = objStream?.title
                content.description = objStream?.description
               
                let obj : StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
                       obj.isProfile = "TRUE"
                       obj.arrContentData = array
                       obj.currentContentIndex  = indexPath.row
                        let nav = UINavigationController(rootViewController: obj)
                        if let imageCell = collectionView.cellForItem(at: indexPath) as? StreamContentViewCell {
                            nav.cc_setZoomTransition(originalView: imageCell.imgCover)
                            nav.cc_swipeBackDisabled = true
                    }
                        self.present(nav, animated: true, completion: nil)
                     //  self.present(obj, animated: false, completion: nil)
                
                }

            }
        }else {
            //  let stream = StreamList.sharedInstance.arrayProfileStream[indexPath.row]
            isEdited = true
            var index = 0
            if let cell = collectionView.cellForItem(at: indexPath) {
                selectedImageView = (cell as! ProfileStreamViewCell).imgCover
            }
//            let obj:StreamViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Stream) as! StreamViewController
              let obj:ViewStreamController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
            if currentMenu == .stream {
                let tempStream = self.arrayMyStreams[indexPath.row]
                let tempIndex = StreamList.sharedInstance.arrayProfileStream.index(where: {$0.ID.trim() == tempStream.ID.trim()})
                if tempIndex != nil {
                    index = tempIndex!
                }
                obj.viewStream = "fromProfile"
                obj.arrStream = StreamList.sharedInstance.arrayProfileStream
                StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileStream
            }else {
                
                obj.viewStream = "fromColabProfile"
                index = indexPath.row
                obj.arrStream = StreamList.sharedInstance.arrayProfileColabStream
                StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileColabStream
            }
           
            obj.currentStreamIndex = index
            ContentList.sharedInstance.objStream = nil
            self.present(obj, animated: false, completion: nil)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if self.selectedType == .All && self.currentMenu == .stuff {
            
            let contentDest = ContentList.sharedInstance.arrayStuff[sourceIndexPath.row]
            ContentList.sharedInstance.arrayStuff.remove(at: sourceIndexPath.row)
            ContentList.sharedInstance.arrayStuff.insert(contentDest, at: destinationIndexPath.row)
            DispatchQueue.main.async {
                self.profileCollectionView.reloadItems(at: [destinationIndexPath,sourceIndexPath])
               
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
    func showToastIMsg(type:AlertType,strMSG:String) {
        self.view.makeToast(message: strMSG,
                            duration: TimeInterval(3.0),
                            position: .top,
                            image: nil,
                            backgroundColor: UIColor.black.withAlphaComponent(0.6),
                            titleColor: UIColor.yellow,
                            messageColor: UIColor.white,
                            font: nil)
        }
}
