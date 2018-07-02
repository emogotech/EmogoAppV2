//
//  ViewProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class ViewProfileViewController: UIViewController {
   
    @IBOutlet weak var profileCollection: UICollectionView!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var btnStream: UIButton!
    @IBOutlet weak var btnColab: UIButton!
    @IBOutlet weak var lblNOResult: UILabel!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var imgLink: UIImageView!
    @IBOutlet weak var btnContainer: UIView!
    @IBOutlet weak var kHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    
    
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
    var profileStreamIndex = 0
    var hudRefreshView: LoadingView!
    var hudView  : LoadingView!
    var refresher: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
        prepareLayouts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        self.profileCollection.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayouts(){
    
        self.title = objPeople.fullName
        self.lblNOResult.text = kAlert_No_Stream_found
       
        let btnFlag = UIBarButtonItem(image: #imageLiteral(resourceName: "stream_flag"), style: .plain, target: self, action: #selector(self.showReportList))
        let btnShare = UIBarButtonItem(image: #imageLiteral(resourceName: "share icon"), style: .plain, target: self, action: #selector(self.profileShareAction))
        self.navigationItem.rightBarButtonItems = [btnFlag,btnShare]
      
        StreamList.sharedInstance.arrayMyStream.removeAll()
        self.profileCollection.dataSource  = self
        self.profileCollection.delegate = self
        self.profileCollection.reloadData()
        profileCollection.alwaysBounceVertical = true
        self.setupRefreshLoader()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(4, 8, 0, 8)
        layout.columnCount = 2

        // Collection view attributes
        self.profileCollection.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        // Add the waterfall layout to your collection view
        self.profileCollection.collectionViewLayout = layout
      
       self.prepareData()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.profileCollection.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.profileCollection.addGestureRecognizer(swipeLeft)
        
    }

    
    func prepareData(){
        let nibViews = UINib(nibName: "ProfileStreamView", bundle: nil)
        self.profileCollection.register(nibViews, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: kHeader_ProfileStreamView)
        print(objPeople.userProfileID)
        self.profileCollection!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kCell_ProfileStreamCell)
        APIServiceManager.sharedInstance.apiForGetUserInfo(userID: objPeople.userProfileID, isCurrentUser: false) { (people, errorMSG) in
            if (errorMSG?.isEmpty)! {
                
                DispatchQueue.main.async {
                    if let people = people {
                        self.objPeople = people
                        self.lblFullName.text =  people.displayName.trim().capitalized
                        self.lblFullName.minimumScaleFactor = 1.0
                        self.lblWebsite.text = people.website.trim()
                        self.lblWebsite.minimumScaleFactor = 1.0
                        self.lblLocation.text = people.location.trim()
                        self.lblLocation.minimumScaleFactor = 1.0
                        self.lblBio.text = people.biography.trim()
                        //self.lblBirthday.text = people.birthday.trim()
                        self.title = people.fullName.trim()
                        self.lblBio.minimumScaleFactor = 1.0
                        self.imgLink.isHidden = false
                        self.imgLocation.isHidden = false
                        if self.objPeople.isFollowing {
                            self.btnFollow.setImage(#imageLiteral(resourceName: "unfollow_btn"), for: .normal)
                        }else {
                            self.btnFollow.setImage(#imageLiteral(resourceName: "follow_btn"), for: .normal)
                        }
                        if people.location.trim().isEmpty {
                            self.imgLocation.isHidden = true
                        }
                        if people.website.trim().isEmpty {
                            self.imgLink.isHidden = true
                        }
                        if people.location.isEmpty && !people.website.trim().isEmpty {
                            self.lblLocation.text = people.website.trim()
                            self.lblWebsite.isHidden = true
                            self.imgLink.isHidden = true
                            self.imgLocation.isHidden = false
                            self.imgLocation.image = self.imgLink.image
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                            self.lblLocation.addGestureRecognizer(tap)
                            self.lblLocation.isUserInteractionEnabled = true
                        }else {
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionForWebsite))
                            self.lblWebsite.addGestureRecognizer(tap)
                            self.lblWebsite.isUserInteractionEnabled = true
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
                        if people.biography.trim().isEmpty  {
                            self.kHeaderHeight.constant = 178
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(178))
                            
                        }else {
                            self.kHeaderHeight.constant = 220
                            self.topConstraintRange = (CGFloat(0)..<CGFloat(220))
                        }
                        self.profileStreamShow()
                        self.btnContainer.addBorders(edges: [UIRectEdge.top,UIRectEdge.bottom], color: self.color, thickness: 1)
                }
               
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.profileCollection.dataSource  = self
        self.profileCollection.delegate = self
        if objPeople != nil  {
            if !objPeople.userProfileID.isEmpty {
                self.getStreamList(type:.start,streamType: streamType)
            }
        }
        self.profileCollection.reloadData()
    }
 

    // MARK:- pull to refresh LoaderSetup
    
    func setupRefreshLoader() {
        if self.refresher == nil {
            self.refresher = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: self.profileCollection.frame.size.width, height: 100))
            
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
            
            self.profileCollection!.alwaysBounceVertical = true
            self.refresher?.tintColor = UIColor.clear
            self.refresher?.addTarget(self, action: #selector(pullToDownAction), for: .valueChanged)
            self.profileCollection.addSubview(refresher!)
          
        }
    }
    @objc func pullToDownAction() {
        
        self.refresher?.frame = CGRect(x: 0, y: 0, width: self.profileCollection.frame.size.width, height: 100)
        SharedData.sharedInstance.nextStreamString = ""
        self.hudRefreshView.startLoaderWithAnimation()
        self.profileCollection.isUserInteractionEnabled = false
   
        self.getStreamList(type:.up,streamType: (self.streamType)!)
        self.profileCollection.reloadData()
       
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
            self.profileCollection.reloadData()
        }
    }
    
    //MARK:- Button Action
    
    @IBAction func btnCloseViewProfile(_ sender: Any) {
        
        self.btnBackAction()
    }
    @IBAction func btnActionShare(_ sender: Any) {
        self.profileShareAction()
    }
    
    @IBAction func btnActionReport(_ sender: Any) {
        self.showReportList()
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
            let alert = UIAlertController(title: kAlert_Message, message: String(format: kAlert_UnFollow_a_User,name!), preferredStyle: .alert)
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
                print("Swie Left")
                if self.streamType == "1" {
                    self.updateSegment(selected: 102)
                }
                break
                
            case UISwipeGestureRecognizerDirection.right:
                print("Swie Right")
                if self.streamType == "2" {
                    self.updateSegment(selected: 101)
                }
                break
            default:
                break
            }
        }
    }
    
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
            self.profileCollection.reloadData()
            break
        default:
            break
        }
    }
    
    func getStream(type:String){
        
         self.getStreamList(type:.start,streamType: type)
    }
    
   
    func btnBackAction() {
        
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
        
       self.dismiss(animated: true, completion: nil)
        
    }

    @objc func showReportList(){
        let optionMenu = UIAlertController(title: kAlert_Title_ActionSheet, message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: self.objPeople.userId!, stream: "", content: "", completionHandler: { (isSuccess, error) in
                
                  self.showToastIMsg(type: AlertType.success, strMSG: kAlert_Success_Report_User)
            })
            
        })
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: self.objPeople.userId!, stream: "", content: "", completionHandler: { (isSuccess, error) in
                 self.showToastIMsg(type: AlertType.success, strMSG: kAlert_Success_Report_User)
                
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
            self.showToastIMsg(type: .error, strMSG: kAlert_ValidWebsite)
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
        self.lblNOResult.isHidden = true
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
            self.profileCollection.reloadData()
        }
            
         APIServiceManager.sharedInstance.apiForGetUserStream(userID: objPeople.userProfileID,type: type,streamType: streamType) { (refreshType, errorMsg) in
                self.view.isUserInteractionEnabled = true
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
            
                if self.hudRefreshView != nil {
                    self.hudRefreshView.stopLoaderWithAnimation()
                }
                self.lblNOResult.isHidden = true
                if StreamList.sharedInstance.arrayStream.count == 0 {
                    self.lblNOResult.isHidden = false
                }
                DispatchQueue.main.async {
                    self.profileCollection.reloadData()
                }
                
                self.profileCollection.isHidden = false
                self.profileCollection.isUserInteractionEnabled = true
                
                if type == .up {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                }else if type == .down {
                    
                    if StreamList.sharedInstance.arrayMyStream.count == 0 {
                        if streamType == "2" {
                            self.lblNOResult.text = kAlert_No_Stream_found
                        }
                        self.lblNOResult.isHidden = false
                    }
                    if streamType == "1" {
                        self.profileStreamShow()
                        self.isCalledMyStream = false
                    }else {
                        self.layout.headerHeight = 0
                        self.arrayColabStream = StreamList.sharedInstance.arrayMyStream
                        self.isCalledColabStream = false
                    }
                    self.profileCollection.reloadData()
                    if !(errorMsg?.isEmpty)! {
                        self.showToastIMsg(type: .error, strMSG: errorMsg!)
                    }
                }
                
                if !(errorMsg?.isEmpty)! {
                    self.showToastIMsg(type: .success, strMSG: errorMsg!)
                }
            }
      
       
    }

    func followUser(){
     
        APIServiceManager.sharedInstance.apiForFollowUser(userID: self.objPeople.userId) { (isSuccess, errorMSG) in
          
            if (errorMSG?.isEmpty)! {
                self.objPeople.isFollowing = true
                self.btnFollow.setImage(#imageLiteral(resourceName: "unfollow_btn"), for: .normal)
            }else {
                self.showToastIMsg(type: .error, strMSG: errorMSG!)
            }
        }
    }
    func unFollowUser(){
       
        APIServiceManager.sharedInstance.apiForUnFollowUser(userID: self.objPeople.userId) { (isSuccess, errorMSG) in
           
            if (errorMSG?.isEmpty)! {
                self.objPeople.isFollowing = false
                self.btnFollow.setImage(#imageLiteral(resourceName: "follow_btn"), for: .normal)
            }else {
               self.showToastIMsg(type: .error, strMSG: errorMSG!)
            }
        }
    }
  

}



extension ViewProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout,ProfileStreamViewDelegate {
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
        cell.layer.cornerRadius = 5.0
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
        
        cell.lblName.text = ""
        cell.lblName.isHidden = true
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {

        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.streamType == "1" {
            let tempStream = self.arrayMyStreams[indexPath.row]
            let tempIndex = StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == tempStream.ID.trim()})
            let obj : StreamViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Stream) as! StreamViewController
            if tempIndex != nil {
                obj.currentStreamIndex = tempIndex!
            }else {
                obj.currentStreamIndex = indexPath.row
            }
            StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayMyStream
            obj.arrStream = self.arrayMyStreams
            ContentList.sharedInstance.objStream = nil
           self.present(obj, animated: false, completion: nil)
            
        }else {
            ContentList.sharedInstance.mainStreamIndex = nil
            StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayMyStream
            let obj : StreamViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Stream) as! StreamViewController
            if SharedData.sharedInstance.iMessageNavigation == kNavigation_Stream {
                var arrayTempStream  = [StreamDAO]()
                arrayTempStream.append(SharedData.sharedInstance.streamContent!)
                obj.arrStream = arrayTempStream
                self.present(obj, animated: false, completion: nil)
                
            }
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
            headerView.imgCover.layer.cornerRadius = 5.0
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
  
    func actionForCover(imageView: UIImageView) {
        let obj:StreamViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Stream) as! StreamViewController
        
        let index = StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == self.objPeople.stream?.ID.trim()})
        if index != nil {
            obj.currentStreamIndex = index
        }else {
            StreamList.sharedInstance.arrayMyStream.insert(self.objPeople.stream!, at: 0)
            obj.currentStreamIndex = 0
        }
        
        let array = StreamList.sharedInstance.arrayMyStream.filter { $0.isAdd == false }
        StreamList.sharedInstance.arrayViewStream = array
        print(array)
        obj.arrStream = array
        ContentList.sharedInstance.objStream = nil
        self.present(obj, animated: false, completion: nil)
        
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

