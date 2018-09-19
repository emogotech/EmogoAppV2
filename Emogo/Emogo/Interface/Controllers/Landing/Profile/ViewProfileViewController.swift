//
//  ViewProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Haptica

class ViewProfileViewController: UIViewController {
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var btnStream: UIButton!
    @IBOutlet weak var btnColab: UIButton!
   
    @IBOutlet weak var lblNOResult: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var imgLink: UIImageView!
    @IBOutlet weak var btnContainer: UIView!
    @IBOutlet weak var kHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var segmentMain: HMSegmentedControl!
    @IBOutlet weak var kHeightlblBio: NSLayoutConstraint!
    @IBOutlet weak var kHeightViewLocation: NSLayoutConstraint!
    @IBOutlet weak var lblSingleView: UILabel!
    @IBOutlet weak var imgSingleView: UIImageView!
    @IBOutlet weak var viewSingle: UIView!
    @IBOutlet weak var kHeightlblName: NSLayoutConstraint!
    
    let layout = CHTCollectionViewWaterfallLayout()
    var objPeople:PeopleDAO!
    var oldContentOffset = CGPoint.zero
    var topConstraintRange = (CGFloat(0)..<CGFloat(220))
    var streamType:String! = "1"
    var arrayMyStreams = [StreamDAO]()
    var arrayColabStream = [StreamDAO]()
    let color = UIColor(r: 155, g: 155, b: 155)
    var isCalledMyStream:Bool! = true
    var isCalledColabStream:Bool! = true
    var selectedImageView:UIImageView?
    var selectedIndexPath:IndexPath?
    let font = UIFont(name: "SFProText-Light", size: 14.0)
    let fontSelected = UIFont(name: "SFProText-Medium", size: 14.0)
    let fontSegment = UIFont(name: "SFProText-Medium", size: 12.0)
    var selectedCell:ProfileStreamCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imgSingleView.isHidden = true
        self.imgLocation.isHidden = true
        self.imgLink.isHidden = true
        prepareLayouts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayouts(){
        
        self.title = objPeople.fullName
        self.lblNOResult.text = kAlert_No_Stream_found
        self.configureNavigationWithTitle()
       
        
//        self.imgLink.image =  #imageLiteral(resourceName: "link_icon")
//        self.imgLocation.image = #imageLiteral(resourceName: "location_icon")
//        self.imgSingleView.image = #imageLiteral(resourceName: "location_icon")
        let btnFlag = UIBarButtonItem(image: #imageLiteral(resourceName: "stream_flag"), style: .plain, target: self, action: #selector(self.showReportList))
        let btnShare = UIBarButtonItem(image: #imageLiteral(resourceName: "share_profile"), style: .plain, target: self, action: #selector(self.profileShareAction))
        self.navigationItem.rightBarButtonItems = [btnFlag,btnShare]
        self.profileCollectionView.dataSource  = self
        self.profileCollectionView.delegate = self
        StreamList.sharedInstance.arrayMyStream.removeAll()
        self.profileCollectionView.reloadData()
        profileCollectionView.alwaysBounceVertical = true
        self.viewSingle.isHidden = true
        
        // Change individual layout attributes for the spacing between cells
//        layout.minimumColumnSpacing = 8.0
//        layout.minimumInteritemSpacing = 8.0
//        layout.sectionInset = UIEdgeInsetsMake(4, 8, 0, 8)
//        layout.columnCount = 2
        
            layout.minimumColumnSpacing = 13.0
            layout.minimumInteritemSpacing = 13.0
            layout.sectionInset = UIEdgeInsetsMake(13, 13, 0, 13)
            layout.columnCount = 2
        
        // Collection view attributes
        self.profileCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        // Add the waterfall layout to your collection view
        self.profileCollectionView.collectionViewLayout = layout
        configureLoadMoreAndRefresh()
        self.prepareData()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.profileCollectionView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.profileCollectionView.addGestureRecognizer(swipeLeft)
        
        segmentMain.sectionTitles = ["EMOGOS", "COLLABS"]
        
        segmentMain.indexChangeBlock = {(_ index: Int) -> Void in
            
            print("Selected index \(index) (via block)")
            self.updateSegment(selected: index)
        }
        segmentMain.selectionIndicatorHeight = 3.0
        segmentMain.backgroundColor = UIColor.white
        segmentMain.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 74, g: 74, b: 74),NSAttributedStringKey.font : fontSegment ?? UIFont.boldSystemFont(ofSize: 12.0) ]
       // segmentMain.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
        segmentMain.selectionIndicatorColor = kCardViewBordorColor
        segmentMain.selectionStyle = .textWidthStripe
        segmentMain.selectedSegmentIndex = 0
        segmentMain.selectionIndicatorLocation = .down
        segmentMain.shouldAnimateUserSelection = false
        
    }
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.profileCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            self?.getStreamList(type:.up,streamType: (self?.streamType)!)
            
        }
        self.profileCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            self?.getStreamList(type:.down,streamType: (self?.streamType)!)
        }
        self.profileCollectionView.expiredTimeInterval = 20.0
    }
    
    func prepareData(){
        let nibViews = UINib(nibName: "ProfileStreamView", bundle: nil)
        self.profileCollectionView.register(nibViews, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: kHeader_ProfileStreamView)
        print(objPeople.userProfileID)
        APIServiceManager.sharedInstance.apiForGetUserInfo(userID: objPeople.userProfileID, isCurrentUser: false) { (people, errorMSG) in
            if (errorMSG?.isEmpty)! {
                
                DispatchQueue.main.async {
                    if let people = people {
                        self.objPeople = people
                        self.lblFullName.text =  people.displayName.trim().capitalized
                        self.lblFullName.minimumScaleFactor = 1.0
                       // self.lblWebsite.text = people.website.trim()
                        self.lblWebsite.minimumScaleFactor = 1.0
                      //  self.lblLocation.text = people.location.trim()
                        self.lblLocation.minimumScaleFactor = 1.0
                        self.lblBio.text = people.biography.trim()
                        //self.lblBirthday.text = people.birthday.trim()
                        self.title = people.fullName.trim()
                        self.lblBio.minimumScaleFactor = 1.0
                        self.imgLink.isHidden = true
                        self.imgLocation.isHidden = true
                        self.imgSingleView.isHidden = true
                        
                        if people.website.trim().count > 20 {
                            self.lblWebsite.text = "\(people.website.trim(count: 20))...".trim()
                        }else{
                            self.lblWebsite.text = people.website.trim()
                        }
                        if people.location.trim().count > 15 {
                            self.lblLocation.text = "\(people.location.trim(count: 15))...".trim()
                        }else{
                            self.lblLocation.text = people.location.trim()
                        }
                        
                        self.kHeightlblBio.constant = 42
                        self.kHeightViewLocation.constant = 32
                        
                        if self.objPeople.isFollowing {
                            self.btnFollow.setImage(#imageLiteral(resourceName: "followingNew"), for: .normal)
                        }else {
                            self.btnFollow.setImage(#imageLiteral(resourceName: "followNew"), for: .normal)
                        }
                        if people.location.trim().isEmpty {
                            self.imgLocation.isHidden = true
                        }
                        if people.website.trim().isEmpty {
                            self.imgLink.isHidden = true
                        }
                   
                        //   self.imgUser.borderWidth = 1.0
                        // self.imgUser.borderColor = UIColor(r: 13, g: 192, b: 237)
                        //print(people.userImage.trim())
                        if !people.userImage.trim().isEmpty {
                            self.imgUser.setImageWithResizeURL(people.userImage.trim())
                        }else {
                            if people.displayName.trim().isEmpty {
                                
                                self.imgUser.setImage(string:people.fullName, color: UIColor.colorHash(name:people.fullName ), circular: true)
                                
                            }else{
                                self.imgUser.setImage(string:people.displayName, color: UIColor.colorHash(name:people.displayName ), circular: true)
                            }
                        }
//                        if people.biography.trim().isEmpty  {
//                            self.kHeaderHeight.constant = 178
//                            self.topConstraintRange = (CGFloat(0)..<CGFloat(178))
//
//                        }
                        if !people.displayName.trim().isEmpty && !people.location.trim().isEmpty && !people.website.trim().isEmpty && people.biography.trim().isEmpty  {
                            
//                            self.lblLocation.text = people.location.trim()
//                            self.lblWebsite.text =  people.website.trim()
                            self.lblLocation.isHidden = false
                            self.lblWebsite.isHidden =  false
                            self.imgLink.isHidden = false
                            self.imgLocation.isHidden = false
                            self.lblBio.isHidden =  true
                            self.kHeightlblBio.constant = 0
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                            self.lblLocation.addGestureRecognizer(tap)
                            self.lblLocation.isUserInteractionEnabled = true
                            self.kHeaderHeight.constant = 211//178
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(211))
                        }
                            
                        else if !people.displayName.trim().isEmpty &&  people.location.trim().isEmpty && !people.website.trim().isEmpty && people.biography.trim().isEmpty {
                            if people.website.trim().count > 20 {
                                self.lblSingleView.text = people.website.trim()
                            }else{
                                self.lblSingleView.text = people.website.trim()
                            }
                           // self.lblSingleView.text = people.website.trim()
                            self.viewSingle.isHidden = false
                            self.lblWebsite.isHidden = true
                            self.lblLocation.isHidden = true
                            self.lblBio.isHidden = true
                            self.kHeightlblBio.constant = 0
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.imgSingleView.isHidden = false
                            self.imgSingleView.image = self.imgLink.image
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                            self.lblSingleView.addGestureRecognizer(tap)
                            self.lblSingleView.isUserInteractionEnabled = true
                            self.kHeaderHeight.constant = 211//178
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(211))
                        }
                        else if people.displayName.trim().isEmpty &&  people.location.trim().isEmpty && !people.website.trim().isEmpty && !people.biography.trim().isEmpty {
                            
                            if people.website.trim().count > 20 {
                                self.lblSingleView.text = people.website.trim()
                            }else{
                                self.lblSingleView.text = people.website.trim()
                            }
                           // self.lblLocation.text = UserDAO.sharedInstance.user.website.trim()
                          //  self.lblSingleView.text = people.website.trim()
                            
                            self.viewSingle.isHidden = false
                            self.lblWebsite.isHidden = true
                            self.lblBio.isHidden = false
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.imgSingleView.isHidden = false
                            self.imgSingleView.image = self.imgLink.image
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                            self.lblSingleView.addGestureRecognizer(tap)
                            self.lblSingleView.isUserInteractionEnabled = true
                            self.kHeaderHeight.constant = 223
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(223))
                        }
                            
                        else if !people.location.trim().isEmpty && people.website.trim().isEmpty && people.biography.trim().isEmpty && people.displayName.trim().isEmpty  {
                            
                            if people.location.trim().count > 15 {
                                self.lblSingleView.text = people.location.trim()
                            }else{
                                self.lblSingleView.text = people.location.trim()
                            }
                           // self.lblLocation.text = UserDAO.sharedInstance.user.location.trim()
                           // self.lblSingleView.text = people.location.trim()
                            self.viewSingle.isHidden = false
                            self.lblWebsite.isHidden = true
                            self.lblBio.isHidden = true
                            self.kHeightlblBio.constant = 0
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.lblLocation.isHidden = true
                            self.imgSingleView.isHidden = false
                            self.imgSingleView.image = #imageLiteral(resourceName: "location_icon")
                            self.kHeaderHeight.constant = 211//178
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(211))
                        }
                        else if !people.location.trim().isEmpty && people.website.trim().isEmpty && !people.biography.trim().isEmpty && !people.displayName.trim().isEmpty {
                           // self.lblLocation.text = UserDAO.sharedInstance.user.location.trim()
                            //self.lblSingleView.text = people.location.trim()
                            if people.location.trim().count > 15 {
                                self.lblSingleView.text = people.location.trim()
                            }else{
                                self.lblSingleView.text = people.location.trim()
                            }
                            self.viewSingle.isHidden = false
                            self.lblWebsite.isHidden = true
                            self.lblBio.isHidden = false
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.imgSingleView.isHidden = false
                            self.imgSingleView.image = #imageLiteral(resourceName: "location_icon")
                            self.kHeaderHeight.constant = 253//178
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(253))
                        }
                     
                        else if people.location.trim().isEmpty && people.website.trim().isEmpty && !people.biography.trim().isEmpty {
                            
                            self.lblLocation.isHidden = true
                            self.lblWebsite.isHidden = true
                            self.lblSingleView.isHidden = true
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.imgSingleView.isHidden =  true
                            
                            self.lblBio.isHidden = false
                            self.kHeightViewLocation.constant = 0
                            self.kHeaderHeight.constant = 221
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(221))
                            
                        }
                        else  if  people.location.trim().isEmpty && people.website.trim().isEmpty && people.biography.trim().isEmpty && !people.displayName.trim().isEmpty{
                            
                            self.lblLocation.isHidden = true
                            self.lblWebsite.isHidden = true
                            self.lblSingleView.isHidden = true
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.imgSingleView.isHidden = true
                            self.lblBio.isHidden = true
                            self.viewSingle.isHidden = true
                            self.kHeaderHeight.constant = 172
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(172))
                            
                        }else if people.displayName.trim().isEmpty && people.location.trim().isEmpty && people.website.trim().isEmpty && people.biography.trim().isEmpty {
                            
                            self.lblLocation.isHidden = true
                            self.lblWebsite.isHidden = true
                            self.lblSingleView.isHidden = true
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.imgSingleView.isHidden = true
                            self.lblBio.isHidden = true
                            self.viewSingle.isHidden = true
                            self.kHeightlblName.constant = 0
                            self.kHeaderHeight.constant = 147
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(147))
                        }
                        else if people.displayName.trim().isEmpty && !people.location.trim().isEmpty && !people.website.trim().isEmpty && !people.biography.trim().isEmpty {
                            
                            self.viewSingle.isHidden = true
                            self.kHeightlblName.constant = 0
                            self.kHeaderHeight.constant = 223
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(223))
                            
                        }else if !people.location.trim().isEmpty && !people.displayName.trim().isEmpty && people.biography.trim().isEmpty && people.website.trim().isEmpty {
                            
                            self.viewSingle.isHidden = false
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.imgSingleView.isHidden = false
                            self.lblLocation.isHidden = true
                            self.imgSingleView.image = #imageLiteral(resourceName: "location_icon")
                            if people.location.trim().count > 15 {
                                self.lblSingleView.text = people.location.trim()
                            }else{
                                self.lblSingleView.text = people.location.trim()
                            }
                            self.kHeightlblBio.constant = 0
                            self.kHeaderHeight.constant = 211//178
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(211))
                            
                        }else if people.location.trim().isEmpty && !people.displayName.trim().isEmpty && people.biography.trim().isEmpty && !people.website.trim().isEmpty {
                            
                            self.viewSingle.isHidden = false
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = true
                            self.lblLocation.isHidden = true
                            self.imgSingleView.isHidden = false
                            self.imgSingleView.image = self.imgLink.image
                            if people.website.trim().count > 20 {
                                self.lblSingleView.text = people.website.trim()
                            }else{
                                self.lblSingleView.text = people.website.trim()
                            }
                            self.kHeightlblBio.constant = 0
                            self.kHeaderHeight.constant = 211//178
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(211))
                            
                        }
                            
                        else{
                            self.viewSingle.isHidden = true
                            self.imgLocation.isHidden = false
                            self.imgLocation.image = #imageLiteral(resourceName: "location_icon")
                            self.imgLink.isHidden = false
                            self.imgLink.image =  #imageLiteral(resourceName: "link_icon")
                            self.kHeaderHeight.constant = 253//220
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(253))
                            
                        }
                        self.profileStreamShow()
                       // self.btnContainer.addBorders(edges: [UIRectEdge.top,UIRectEdge.bottom], color: self.color, thickness: 1)
//                        self.btnContainer.addBorders(edges: UIRectEdge.top, color: self.color, thickness: 1)
//                        self.btnContainer.roundCorners([.topLeft,.topRight], radius: 5)
//                        self.btnContainer.layer.masksToBounds = true
                    }
                    
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if objPeople != nil  {
            if !objPeople.userProfileID.isEmpty {
                HUDManager.sharedInstance.showHUD()
                self.getStreamList(type:.start,streamType: streamType)
            }
        }
        
    }
    
 
    func profileStreamShow(){
        if self.streamType == "1" {
            if self.isCalledMyStream {
                arrayMyStreams = StreamList.sharedInstance.arrayMyStream
            }
            if objPeople.stream != nil {
                
                if (objPeople.stream?.CoverImage.trim().isEmpty)! {
                    self.layout.headerHeight = 0
                    self.lblNOResult.isHidden = true
                    if arrayMyStreams.count == 0 {
                        self.lblNOResult.text = kAlert_No_Stream_found
                        self.lblNOResult.isHidden = false
                    }
                }else {
                    if self.isCalledMyStream {
                        let index = StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == self.objPeople.stream?.ID.trim()})
                        arrayMyStreams = StreamList.sharedInstance.arrayMyStream
                        if index != nil {
                            arrayMyStreams.remove(at: index!)
                        }else {
                            StreamList.sharedInstance.arrayMyStream.append(self.objPeople.stream!)
                        }
                    }else {
                        StreamList.sharedInstance.arrayMyStream = self.arrayMyStreams
                        let index = StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == self.objPeople.stream?.ID.trim()})
                        if index != nil {
                            arrayMyStreams.remove(at: index!)
                        }else {
                            StreamList.sharedInstance.arrayMyStream.append(self.objPeople.stream!)
                        }
                    }
                    lblNOResult.isHidden = true
                    self.layout.headerHeight = 200
                }
            }else {
                self.layout.headerHeight = 0
                self.lblNOResult.isHidden = true
                if arrayMyStreams.count == 0 {
                    self.lblNOResult.text = kAlert_No_Stream_found
                    self.lblNOResult.isHidden = false
                }
            }
            self.profileCollectionView.reloadData()
        }
    }
    
    
    @IBAction func btnActionMenuSelected(_ sender: UIButton) {
        self.updateSegment(selected: sender.tag)
    }
    
    @IBAction func btnActionFollowUser(_ sender: UIButton) {
        if self.objPeople.isFollowing {
            var name = objPeople.fullName
            if !objPeople.displayName.trim().isEmpty {
                name = objPeople.displayName.trim()
            }
            let alert = UIAlertController(title: kAlert_Message, message: String(format: kAlert_UnFollow_a_User,name!), preferredStyle: .actionSheet)
            let yes = UIAlertAction(title: kAlertTitle_Unfollow, style: .default) { (action) in
                self.unFollowUser()
            }
            let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            }
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
        }else {
            self.followUser()
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if kDefault?.bool(forKey: kHapticFeedback) == true{
                    Haptic.impact(.light).generate()
                }else{
                    
                }
                print("Swie Left")
                if self.streamType == "1" {
                    self.updateSegment(selected: 1)
                    //self.updateSegment(selected: 102)
                }
                break
                
            case UISwipeGestureRecognizerDirection.right:
                if kDefault?.bool(forKey: kHapticFeedback) == true{
                    Haptic.impact(.light).generate()
                }else{
                    
                }
                print("Swie Right")
                if self.streamType == "2" {
                    self.updateSegment(selected: 0)
                    //self.updateSegment(selected: 101)
                }
                break
            default:
                break
            }
        }
    }
    
    private func updateSegment(selected:Int){
        switch selected {
        case 0:
            layout.sectionInset = UIEdgeInsetsMake(13, 13, 0, 13)
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.streamType = "1"
            if self.arrayMyStreams.count == 0 && self.isCalledMyStream {
                self.getStream(type:  self.streamType)
            }
            self.profileStreamShow()
            self.segmentMain.selectedSegmentIndex = 0
            break
        case 1:
            layout.sectionInset = UIEdgeInsetsMake(3, 13, 0, 13)
            if kDefault?.bool(forKey: kHapticFeedback) == true{
                Haptic.impact(.light).generate()
            }else{
                
            }
            self.streamType = "2"
            if self.arrayColabStream.count == 0 && self.isCalledColabStream {
                self.getStream(type:  self.streamType)
            }
            self.lblNOResult.isHidden = true
            StreamList.sharedInstance.arrayMyStream = self.arrayColabStream
            if StreamList.sharedInstance.arrayMyStream.count == 0 {
                self.lblNOResult.text = kAlert_No_Stream_found
                self.lblNOResult.isHidden = false
            }
            self.layout.headerHeight = 0
            self.segmentMain.selectedSegmentIndex = 1
            self.profileCollectionView.reloadData()
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
            self.streamType = "1"
            if self.arrayMyStreams.count == 0 && self.isCalledMyStream {
                self.getStream(type:  self.streamType)
            }
            self.profileStreamShow()
            break
        case 102:
            self.btnStream.setImage(#imageLiteral(resourceName: "strems_icon"), for: .normal)
            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_active_icon"), for: .normal)
            self.streamType = "2"
            if self.arrayColabStream.count == 0 && self.isCalledColabStream {
                self.getStream(type:  self.streamType)
            }
            self.lblNOResult.isHidden = true
            StreamList.sharedInstance.arrayMyStream = self.arrayColabStream
            if StreamList.sharedInstance.arrayMyStream.count == 0 {
                self.lblNOResult.text = kAlert_No_Stream_found
                self.lblNOResult.isHidden = false
            }
            self.layout.headerHeight = 0
            self.profileCollectionView.reloadData()
            break
        default:
            break
        }
    }*/
    
    func getStream(type:String){
        HUDManager.sharedInstance.showHUD()
        self.getStreamList(type:.start,streamType: type)
    }
    
    
    override func btnBackAction() {
        
        if  ContentList.sharedInstance.mainStreamNavigate == nil {
            let array = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
            StreamList.sharedInstance.arrayViewStream = array
        }else {
            if ContentList.sharedInstance.mainStreamNavigate == "fromProfile" {
                let array = StreamList.sharedInstance.arrayProfileStream.filter { $0.isAdd == false }
                StreamList.sharedInstance.arrayViewStream = array
            }else if ContentList.sharedInstance.mainStreamNavigate == "fromColabProfile"{
                StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayProfileColabStream
            }
            else if  ContentList.sharedInstance.mainStreamNavigate == "View"{
                //                let array = StreamList.sharedInstance.arrayMyStream.filter { $0.isAdd == false }
                //                StreamList.sharedInstance.arrayViewStream = array
                
            }
            else {
                let array = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                StreamList.sharedInstance.arrayViewStream = array
            }
        }
        
        self.navigationController?.pop()
        
    }
    
    @objc func showReportList(){
        let optionMenu = UIAlertController(title: kAlert_Title_ActionSheet, message: "", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: self.objPeople.userId!, stream: "", content: "", completionHandler: { (isSuccess, error) in
                self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_User)
            })
            
        })
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: self.objPeople.userId!, stream: "", content: "", completionHandler: { (isSuccess, error) in
                self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_User)
            })
        })
        
        let cancelAction = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func profileShareAction(){
        if objPeople.shareURL.isEmpty {
            return
        }
        let url:URL = URL(string: objPeople.shareURL!)!
        let shareItem =  "Hey checkout \(objPeople.fullName.capitalized)'s profile!"
        let text = "\n via Emogo"
        
        // let shareItem = "Hey checkout the s profile,emogo"
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [shareItem,url,text], applicationActivities:nil)
        //  activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .airDrop]
        
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil);
        }
    }
    
    @objc func actionForWebsite(){
        
        guard let url = URL(string: objPeople.website.stringByAddingPercentEncodingForURLQueryParameter()!) else {
            self.showToast(strMSG: kAlert_ValidWebsite)
            return
        }
        if !["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            let appendedLink = "https://" + objPeople.website
            let modiURL = URL(string: appendedLink.stringByAddingPercentEncodingForURLQueryParameter()!)
            self.openURL(url: modiURL!)
        }else {
            self.openURL(url: url)
        }
    }
    
    func getStreamList(type:RefreshType,streamType:String){
        //self.lblNOResult.isHidden = true
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
            self.profileCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetUserStream(userID: objPeople.userProfileID,type: type,streamType: streamType) { (refreshType, errorMsg) in
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
            if StreamList.sharedInstance.arrayMyStream.count == 0 {
                if streamType == "2" {
                    self.lblNOResult.text = kAlert_No_Stream_found
                    self.lblNOResult.isHidden = false
                }
               
            }
            if streamType == "1" {
                self.profileStreamShow()
                self.isCalledMyStream = false
            }else {
                self.layout.headerHeight = 0
                self.arrayColabStream = StreamList.sharedInstance.arrayMyStream
                self.isCalledColabStream = false
            }
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func followUser(){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForFollowUser(userID: self.objPeople.userId) { (isSuccess, errorMSG) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.objPeople.isFollowing = true
                self.btnFollow.setImage(#imageLiteral(resourceName: "followingNew"), for: .normal)
            }else {
                self.showToast(strMSG: errorMSG!)
            }
        }
    }
    func unFollowUser(){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForUnFollowUser(userID: self.objPeople.userId) { (isSuccess, errorMSG) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.objPeople.isFollowing = false
                self.btnFollow.setImage(#imageLiteral(resourceName: "followNew"), for: .normal)
            }else {
                self.showToast(strMSG: errorMSG!)
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



extension ViewProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout,ProfileStreamViewDelegate {
   
    func actionForCover(imageView: UIImageView) {
        
        let obj:EmogoDetailViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EmogoDetailView) as! EmogoDetailViewController
        obj.currentIndex = 0
        obj.delegate = self
      
//        let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
        
        let index = StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == self.objPeople.stream?.ID.trim()})
        if index != nil {
            obj.currentIndex = index
        }else {
            StreamList.sharedInstance.arrayMyStream.insert(self.objPeople.stream!, at: 0)
            obj.currentIndex = 0
        }
        obj.streamType = currentStreamType.rawValue
        obj.viewStream = "View"
        selectedImageView = imageView
        obj.image =  imageView.image
        ContentList.sharedInstance.objStream = nil
        self.navigationController?.pushNormal(viewController: obj)
        
//        let array = StreamList.sharedInstance.arrayMyStream.filter { $0.isAdd == false }
//        StreamList.sharedInstance.arrayViewStream = array
//        print(array)
//        obj.streamType = currentStreamType.rawValue
//        obj.viewStream = "View"
//        selectedImageView = imageView
//        ContentList.sharedInstance.objStream = nil
//        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if  self.streamType == "1" {
            return self.arrayMyStreams.count
        }else {
            return StreamList.sharedInstance.arrayMyStream.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        var stream:StreamDAO?
        if self.streamType == "1" {
            stream = self.arrayMyStreams[indexPath.row]
            cell.prepareLayouts(stream: stream!)
            cell.lblName.text = ""
            cell.lblName.isHidden = true
        }else
        {
            stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
            cell.prepareLayouts(stream: stream!)
            cell.lblName.isHidden = false
        }
        
        if (stream?.haveSomeUpdate)! {
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = kCardViewBordorColor.cgColor
        }else {
            cell.layer.borderWidth = 0.0
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        cell.lblName.text = ""
        cell.lblName.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth - 23*kScale)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            selectedImageView = (cell as! ProfileStreamCell).imgCover
        }
        if self.streamType == "1" {
            let tempStream = self.arrayMyStreams[indexPath.row]
            let tempIndex = StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == tempStream.ID.trim()})
            let obj:EmogoDetailViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EmogoDetailView) as! EmogoDetailViewController
            obj.currentIndex = 0
            obj.delegate = self
            if tempIndex != nil {
                obj.currentIndex = tempIndex!
            }else {
                obj.currentIndex = indexPath.row
            }
            StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayMyStream
            obj.streamType = currentStreamType.rawValue
            obj.viewStream = "View"
            obj.image = selectedImageView?.image
            ContentList.sharedInstance.objStream = nil
            self.navigationController?.pushNormal(viewController: obj)

        }else {
            ContentList.sharedInstance.mainStreamIndex = nil
            StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayMyStream
//            let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
            let obj:EmogoDetailViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EmogoDetailView) as! EmogoDetailViewController
            obj.delegate = self
            obj.currentIndex = indexPath.row
            obj.streamType = currentStreamType.rawValue
            obj.image = selectedImageView?.image
            obj.viewStream = "View"
            ContentList.sharedInstance.objStream = nil
            self.navigationController?.pushNormal(viewController: obj)
            //self.navigationController?.pushViewController(obj, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print(kind)
        
        switch kind {
            
        case CHTCollectionElementKindSectionHeader:
            let headerView:ProfileStreamView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_ProfileStreamView, for: indexPath) as! ProfileStreamView
            
            if self.objPeople.stream != nil {
                headerView.prepareLayout(stream: self.objPeople.stream! , isCurrentUser: false, image: self.objPeople.userImage)
                headerView.delegate = self
            }
            headerView.imgCover.layer.cornerRadius = 11.0
            headerView.imgCover.layer.masksToBounds = true
            headerView.imgUser.isHidden = true
            
            return headerView
            
        default:
            
            fatalError("Unexpected element kind")
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

    
}

extension ViewProfileViewController : EmogoDetailViewControllerDelegate {
    
    func nextItemScrolled(index: Int?) {
        if let index = index {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = profileCollectionView.cellForItem(at: indexPath) {
                selectedIndexPath = indexPath
                self.selectedCell = cell as! ProfileStreamCell
                selectedImageView = self.selectedCell.imgCover
            }
        }else {
            selectedIndexPath = nil
            selectedImageView = nil
            self.profileCollectionView.reloadData()
        }
        
    }
    
}


