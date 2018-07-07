//  HomeViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 11/17/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//


import UIKit
import Messages

class HomeViewController: MSMessagesAppViewController,MyStreamSegmentDelegate {
    
    // MARK:- UI Elements
    @IBOutlet weak var collectionStream         : UICollectionView!
    
    @IBOutlet weak var pagerContent             : UIView!
    @IBOutlet weak var searchView               : UIView!
    @IBOutlet weak var viewStream               : UIView!
    @IBOutlet weak var viewStreamHeader         : UIView!
    @IBOutlet weak var viewPeople               : UIView!
    @IBOutlet weak var viewPeopleHeader         : UIView!
    @IBOutlet weak var viewCollections          : UIView!
    @IBOutlet weak var viewCollectionsMain      : UIView!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var searchText               : UITextField!
    
    @IBOutlet weak var kSearchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnFeature               : UIButton!
    @IBOutlet weak var btnSearchHeader          : UIButton!
    
    @IBOutlet weak var kHeightViewSegment: NSLayoutConstraint!
    @IBOutlet weak var btnStreamSearch          : UIButton!
    @IBOutlet weak var btnPeopleSearch          : UIButton!
    
    @IBOutlet weak var viewSegment: UIView!
    @IBOutlet weak var kViewSearchButtonHeight  : NSLayoutConstraint!
    
    @IBOutlet weak var lblNoResult              : UILabel!
    @IBOutlet weak var lblStreamSearch          : UILabel!
    @IBOutlet weak var lblPeopleSearch          : UILabel!
    @IBOutlet weak var viewSearchButton         : UIView!
    @IBOutlet weak var kWidthCancel: NSLayoutConstraint!
    
    // MARK: - Varibales
    var hudView                                 : LoadingView!
    var hudRefreshView                          : LoadingView!
    var lastIndex                               : Int = 10
    var refresher                               : UIRefreshControl?
    var footerView                              : HomeCollectionReusableView?
    var paging                                  : Int = 1;
    var currentIndex                            : Int = 1
    var fectchingStreamData                     : Bool = true
    var heightPeople                            : NSLayoutConstraint?
    var heightStream                            : NSLayoutConstraint?
    var isStreamEnable                          : Bool = true
    var isSearch                                    : Bool = false
    var isLoadCall                                : Bool = false
    var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var arrayToShow = [StreamDAO]()
    var lastSelectedType:StreamType! = StreamType.featured
    var segmentHeader:MyStreamSegmentHeaderView!
    let fontSegment = UIFont(name: "SFProText-Medium", size: 12.0)
  //  var selectedType:StreamType! = StreamType.Public
    let kSearchHeight = 60.0
    
   // fileprivate let arrImages = ["PopularDeselected","MyStreamsDeselected","FeatutreDeselected","emogoDeselected","ProfileDeselected","PeopleDeselect","LikedDeselected","FollowingDeselected"]
   // fileprivate let arrImagesSelected = ["Popular","My Streams","Featured","Emogo Streams","Profile","People"]
    fileprivate let arrImages = ["MyStreamsDeselected","PopularDeselected","FeatutreDeselected","emogoDeselected","ProfileDeselected","LikedDeselected","FollowingDeselected"]
    fileprivate let arrImagesSelected = ["My Streams","Popular","Featured","Emogo Streams","Profile","Liked Streams", "Following Streams"]

    
    // MARK:- Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoader()
        //setupAnchor()
        self.getTopStreamList()
        viewSearchButton.isHidden = true
        kSearchViewHeight.constant = 0.0
        kViewSearchButtonHeight.constant = 0.0
        self.kSearchViewHeight.constant = 0.0
        kWidthCancel.constant = 0.0
        self.viewSegment.isHidden = true
        self.kHeightViewSegment.constant = 0.0
        
        SharedData.sharedInstance.tempViewController = self
        self.perform(#selector(prepareLayout), with: nil, afterDelay: 0.01)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kLogoutIdentifier), object: nil, queue: nil) { (notification) in
            kDefault?.set(false, forKey: kUserLogggedIn)
            kDefault?.removeObject(forKey: kUserLogggedInData)
            let obj:MessagesViewController = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_Root) as! MessagesViewController
            self.addTransitionAtNaviagtePrevious()
            self.present(obj, animated: false, completion: nil)
        }
      
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadStreamData), name: NSNotification.Name(rawValue: kNotification_Reload_Content_Data), object: nil)
        
        if SharedData.sharedInstance.iMessageNavigation == kNavigation_Stream {
            self.getStream(streamID: (SharedData.sharedInstance.streamContent?.ID)!)
        }
        else if SharedData.sharedInstance.iMessageNavigation == kNavigation_Content {
            if SharedData.sharedInstance.iMessageNavigationCurrentStreamID == "" {
                self.getContenData()
            }else{
                self.getStream(streamID: SharedData.sharedInstance.iMessageNavigationCurrentStreamID)
            }
            
        }
        btnStreamSearch.isUserInteractionEnabled = false
        btnPeopleSearch.isUserInteractionEnabled = true
    }
    

    
    @objc func reloadStreamData(){
        
        if !isSearch {
                 self.changePager()
        }
      
      
//        }else if isSearch && !isStreamEnable{
//            self.getStreamGlobleSearch(searchText: searchText.text!, type: .start)
//        }else{
//
//        }
            
}
            //self.getStreamList(type:.start,filter:self.streamType)
        

    //MARK:- Configure Stream Header
    
    func configureStreamHeader() {
        self.viewSegment.isHidden = false
        self.kHeightViewSegment.constant = 33.0
        let nibViews = Bundle.main.loadNibNamed("MyStreamSegmentHeaderView", owner: self, options: nil)
        self.segmentHeader = nibViews?.first as! MyStreamSegmentHeaderView 
        self.viewSegment.addSubview(self.segmentHeader)
        self.segmentHeader.segmentDelegate = self
        self.segmentHeader.segmentControl.isHidden = false
        self.segmentHeader.frame = CGRect(x: self.segmentHeader.frame.origin.x, y: self.segmentHeader.frame.origin.y, width: kFrame.size.width, height: 33)
        self.setSegmentControl()
    
    
    }
    //MARK:- update segment
    
    func updateStreamSegment(index:Int){
        switch index {
        case 0:
            currentStreamType = StreamType.Public
            break
        case 1:
            currentStreamType = StreamType.Private
            break
            
        default:
            break
        }
      
        DispatchQueue.main.async {
            self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
            if self.arrayToShow.count == 0 {
                self.lblNoResult.isHidden = false
            }else {
                self.lblNoResult.isHidden = true
            }
            self.collectionStream.reloadData()
        }
          // self.getStreamList(type: .start, filter: currentStreamType)
    }
    


    // MARK:- prepareLayout
    
    @objc func prepareLayout() {
        
        let sizeofTextField = self.searchText.font?.pointSize
        self.searchText.minimumFontSize = sizeofTextField!
      
        collectionStream.delegate = self
        collectionStream.dataSource = self
         self.view.isUserInteractionEnabled = true
      //  lblStreamSearch.font = lblPeopleSearch.font
        
//        self.searchView.layer.cornerRadius = 18
//        self.searchView.clipsToBounds = true
        
        currentStreamType =  StreamType.featured
      
        //        streamType = StreamType.featured
        //        self.getStreamList(type:.start,filter:.featured)
        self.collectionStream.register(UINib(nibName: iMgsSegue_HomeCollectionReusableV, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: iMgsSegue_HomeCollectionReusableV)
        
     
       
        //viewCollections.isHidden = true
        // streamType  = StreamType.featured
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
    
    func setupAnchor(){
//        viewStream.translatesAutoresizingMaskIntoConstraints = false
//        viewPeople.translatesAutoresizingMaskIntoConstraints = false
//
//        heightStream = viewStream.heightAnchor.constraint(equalToConstant: 40)
//        heightStream?.isActive = false
//        viewStream.isHidden = false
//        viewPeople.isHidden = false
//        viewStream.topAnchor.constraint(equalTo: viewCollections.topAnchor).isActive = true
//        viewStream.leftAnchor.constraint(equalTo: viewCollections.leftAnchor).isActive = true
//        viewStream.rightAnchor.constraint(equalTo: viewCollections.rightAnchor).isActive = true
//        viewStream.bottomAnchor.constraint(equalTo: viewPeople.topAnchor).isActive = true
//
//        viewPeople.bottomAnchor.constraint(equalTo: viewCollections.bottomAnchor).isActive = true
//        heightPeople = viewPeople.heightAnchor.constraint(equalToConstant: 40)
//        heightPeople?.isActive = true
//        viewPeople.leftAnchor.constraint(equalTo: viewCollections.leftAnchor).isActive = true
//        viewPeople.rightAnchor.constraint(equalTo: viewCollections.rightAnchor).isActive = true
    }
    
    func preparePagerFrame() {
        let pagerView = FSPagerView()
        pagerView.frame = pagerContent.bounds
        pagerContent.addSubview(pagerView)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 0)
        pagerView.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 0)
       
        pagerView.currentIndex = 2
        lastIndex = 2
        pagerView.itemSize = CGSize(width: 120, height: 100)
        pagerView.transformer = FSPagerViewTransformer(type:.ferrisWheel)
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.isHidden = false
        pagerView.isAddBackground = false
        pagerView.isAddTitle = false
        pagerView.layer.contents = UIImage(named: "home_gradient")?.cgImage
       
        let blurEffect = UIBlurEffect(style: .light)
        // 3
        let blurView = UIVisualEffectView(effect: blurEffect)
        // 4
        var blurFrame = pagerView.bounds
        let blurHeight = (blurFrame.size.height / 2)
        blurFrame.size.height    =  blurHeight
        blurFrame.origin.y      =   blurHeight + 10
        blurView.frame = blurFrame
        blurView.setTopCurve()
        pagerView.insertSubview(blurView, at: 0)
        print(blurView)
        
        
        if SharedData.sharedInstance.isMessageWindowExpand {
            if SharedData.sharedInstance.isPortrate {
                pagerContent.isHidden = false
                btnFeature.tag = 1
            }else{
                pagerContent.isHidden = false
                btnFeature.tag = 0
            }
        }
    }
  
    
    // MARK:- pull to refresh LoaderSetup
    
    func setupRefreshLoader() {
        if self.refresher == nil {
            self.refresher = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: self.collectionStream.frame.size.width, height: 100))
            
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
            
            self.collectionStream!.alwaysBounceVertical = true
            self.refresher?.tintColor = UIColor.clear
            self.refresher?.addTarget(self, action: #selector(pullToDownAction), for: .valueChanged)
            self.collectionStream!.addSubview(refresher!)
            self.view.isUserInteractionEnabled = true
           // viewCollections.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
          //  viewStream.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }
    
    func setupCollectionProperties() {
        self.view.isUserInteractionEnabled = true
        if self.isSearch == false {
           if currentStreamType == StreamType.Public {
                layout.sectionInset = UIEdgeInsets(top:10, left: 8, bottom: 8, right: 8)
                layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/2 - 12.0, height: self.collectionStream.frame.size.width/2-30)
                layout.minimumInteritemSpacing = 8
                layout.minimumLineSpacing = 8
                collectionStream!.collectionViewLayout = layout
            }

           else {
                
                layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/2 - 12.0, height: self.collectionStream.frame.size.width/2-30)
                layout.minimumInteritemSpacing = 8
                layout.minimumLineSpacing = 8
                collectionStream!.collectionViewLayout = layout
               
                
           }
        }
        else {
            if isSearch && !isStreamEnable {
                layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/3 - 12.0, height: self.collectionStream.frame.size.width/3 )
                layout.minimumInteritemSpacing = 8
                layout.minimumLineSpacing = 8
                collectionStream!.collectionViewLayout = layout
            }
            else {
                layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/2 - 12.0, height: self.collectionStream.frame.size.width/2-30)
                layout.minimumInteritemSpacing = 8
                layout.minimumLineSpacing = 8
                collectionStream!.collectionViewLayout = layout
                
            }
        }
        
        
       return
        
        if (isSearch == true && !isStreamEnable){
        }
        else if (isSearch == true &&  isStreamEnable){
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/2 - 12.0, height: self.collectionStream.frame.size.width/2-30)
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            collectionStream!.collectionViewLayout = layout
        }
            /*
        else  if (btnFeature.titleLabel?.text == "PEOPLE"){
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/3 - 12.0, height: self.collectionStream.frame.size.width/3 )
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            collectionStream!.collectionViewLayout = layout
        }*/
        else  {
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/2 - 12.0, height: self.collectionStream.frame.size.width/2-30)
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            collectionStream!.collectionViewLayout = layout
        }
    }
    
    
    // MARK:- Selector Methods
    
    @objc func requestMessageScreenChangeSize(){
        if SharedData.sharedInstance.isPortrate {
            
            if (searchText.text?.trim().isEmpty)! {
                pagerContent.isHidden = true
                btnFeature.tag = 0
            }else{
                pagerContent.isHidden = false
                btnFeature.tag = 1
            }
            
            self.collectionStream.reloadData()
        }else{
            pagerContent.isHidden = true
            btnFeature.tag = 0
            self.collectionStream.reloadData()
        }
        self.perform(#selector(self.changeUI), with: nil, afterDelay: 0.4)
    }
    
    @objc func changeUI(){
        if(SharedData.sharedInstance.isMessageWindowExpand) {
            self.perform(#selector(self.updatUIWhileSearch), with: nil, afterDelay: 0.4)
            if searchText.text == "" {
                if SharedData.sharedInstance.isPortrate {
                    pagerContent.isHidden = false
                    btnFeature.tag = 1
                }else{
                    pagerContent.isHidden = true
                    btnFeature.tag = 0
                }
            }
            else{
                pagerContent.isHidden = true
                btnFeature.tag = 0
            }
        }
        else {
            pagerContent.isHidden = true
            btnFeature.tag = 0
            self.perform(#selector(self.updatUIWhileSearch), with: self, afterDelay: 0.4)
        }
        self.view.layoutIfNeeded()
    }
    
    @objc func changeUIInBackgroundCollapse(){
        self.perform(#selector(self.updatUIWhileSearch), with: self, afterDelay: 0.2)
    }
    
    @objc func updatUIWhileSearch(){
        if  self.isSearch == true && isStreamEnable{
            self.collectionStream.isHidden = true
            DispatchQueue.main.async {
//                self.collectionStream.frame = CGRect(x: self.collectionStream.frame.origin.x, y: self.viewStream.frame.origin.y+40, width: self.collectionStream.frame.size.width, height: self.viewStream.frame.size.height-40)
               // self.setupCollectionProperties()
                self.collectionStream.isHidden = false
                self.collectionStream.reloadData()
            }
            
        } else if  self.isSearch == true && !isStreamEnable{
            DispatchQueue.main.async {
//                self.collectionStream.frame = CGRect(x: self.collectionStream.frame.origin.x, y: self.viewPeople.frame.origin.y+40, width: self.viewPeople.frame.size.width, height: self.viewPeople.frame.size.height-40)
                //self.setupCollectionProperties()
                self.collectionStream.isHidden = false
                self.collectionStream.reloadData()
            }
        }
    }
    
    @objc func pullToDownAction() {
        
        self.refresher?.frame = CGRect(x: 0, y: 0, width: self.collectionStream.frame.size.width, height: 100)
        SharedData.sharedInstance.nextStreamString = ""
        self.hudRefreshView.startLoaderWithAnimation()
        self.collectionStream.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        if self.isSearch == false {
//            if currentStreamType == .People {
//                self.view.isUserInteractionEnabled = false
//                self.getUsersList(type: .up)
//            }else {
                 self.view.isUserInteractionEnabled = true
                 self.getTopStreamList()
                // self.getStreamList(type: .up, filter: currentStreamType)
            //}
        }
        else {
            if isSearch && !isStreamEnable {
               
                self.view.isUserInteractionEnabled = false
                 self.getPeopleGlobleSearch(searchText: (self.searchText.text?.trim())!, type: .up)
            }
            else {
                
                self.view.isUserInteractionEnabled = false
                 self.getStreamGlobleSearch(searchText: (self.searchText.text?.trim())!, type: .up)
            }
        }
    }
    
    @objc func resignRefreshLoader(){
        self.refresher?.endRefreshing()
        if hudRefreshView != nil {
            hudRefreshView.stopLoaderWithAnimation()
        }
        self.view.isUserInteractionEnabled = true
        self.refresher?.frame = CGRect.zero
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        DispatchQueue.main.async {
            
            if self.isSearch == false {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
            }
        }
        if !checkIsAvailableFilter() {
            preparePagerFrame()
        }
        
        collectionStream.translatesAutoresizingMaskIntoConstraints = false
        SharedData.sharedInstance.tempViewController = self
        btnFeature.setTitleColor(#colorLiteral(red: 0, green: 0.6784313725, blue: 0.9529411765, alpha: 1), for: UIControlState.normal)
         self.view.isUserInteractionEnabled = true
        self.setupCollectionProperties()
        self.setupRefreshLoader()
        
        if (isSearch  && !isStreamEnable){
           // PeopleList.sharedInstance.arrayPeople.removeAll()
          //  StreamList.sharedInstance.requestURl = ""
          //  PeopleList.sharedInstance.requestURl = ""
            self.arrayToShow.removeAll()
            self.collectionStream.reloadData()
            self.hudView.startLoaderWithAnimation()
            self.getPeopleGlobleSearch(searchText: self.searchText.text!, type: .start)
        }
        else if (isSearch  &&  isStreamEnable){
           // PeopleList.sharedInstance.arrayPeople.removeAll()
            self.arrayToShow.removeAll()
            self.collectionStream.reloadData()
            StreamList.sharedInstance.requestURl = ""
            PeopleList.sharedInstance.requestURl = ""
            self.hudView.startLoaderWithAnimation()
            self.getStreamGlobleSearch(searchText: searchText.text!, type: .start)
        }else {
            self.getTopStreamList()
        }
        
        
//        //Shobhit
//        DispatchQueue.main.async {
//            self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
//            if self.arrayToShow.count == 0 {
//                self.lblNoResult.isHidden = false
//            }else {
//                self.lblNoResult.isHidden = true
//            }
//            self.collectionStream.reloadData()
//        }
        
    }
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !checkIsAvailableFilter() {
            preparePagerFrame()
        }
     
        collectionStream.translatesAutoresizingMaskIntoConstraints = false
        SharedData.sharedInstance.tempViewController = self
        btnFeature.setTitleColor(#colorLiteral(red: 0, green: 0.6784313725, blue: 0.9529411765, alpha: 1), for: UIControlState.normal)
        
        self.setupCollectionProperties()
        self.setupRefreshLoader()
        
        if (isSearch  && !isStreamEnable){
            PeopleList.sharedInstance.arrayPeople.removeAll()
            StreamList.sharedInstance.requestURl = ""
            PeopleList.sharedInstance.requestURl = ""
            self.arrayToShow.removeAll()
            self.collectionStream.reloadData()
            self.getPeopleGlobleSearch(searchText: self.searchText.text!, type: .start)
        }
        else if (isSearch  &&  isStreamEnable){
            PeopleList.sharedInstance.arrayPeople.removeAll()
            self.arrayToShow.removeAll()
            self.collectionStream.reloadData()
            StreamList.sharedInstance.requestURl = ""
            PeopleList.sharedInstance.requestURl = ""
            self.getStreamGlobleSearch(searchText: searchText.text!, type: .start)
        }else {
            self.getTopStreamList()
        }
        
        
        //Shobhit
        DispatchQueue.main.async {
            self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
            if self.arrayToShow.count == 0 {
                self.lblNoResult.isHidden = false
            }else {
                self.lblNoResult.isHidden = true
            }
            self.collectionStream.reloadData()
        }
        
    }*/
    
    func checkIsAvailableFilter() -> Bool {
        for subView in pagerContent.subviews {
            if subView.isKind(of: FSPagerView.self){
                return true
            }
        }
        return false
    }
    //MARK:- Segment Control
    
    func setSegmentControl(){
        // Segment control Configure
        self.segmentHeader.segmentControl.isHidden = false
        self.segmentHeader.segmentControl.sectionTitles = ["Public", "Private"]
        self.segmentHeader.segmentControl.indexChangeBlock = {(_ index: Int) -> Void in
            print("Selected index \(index) (via block)")
            self.updateStreamSegment(index: index)
        }
        self.segmentHeader.segmentControl.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        self.segmentHeader.segmentControl.selectionIndicatorHeight = 1.0
        self.segmentHeader.segmentControl.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 155, g: 155, b: 155),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 15.0)]
        self.segmentHeader.segmentControl.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
        self.segmentHeader.segmentControl.selectedTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 74, g: 74, b: 74),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 15.0)]
        self.segmentHeader.segmentControl.selectionStyle = .textWidthStripe
        self.segmentHeader.segmentControl.selectedSegmentIndex = 0
        self.segmentHeader.segmentControl.selectionIndicatorLocation = .down
        self.segmentHeader.segmentControl.shouldAnimateUserSelection = false
    }
    
    // MARK:- Action methods
    @IBAction func btnSearchAction(_ sender: UIButton) {
        if sender.tag == 0 {
            self.searchText.resignFirstResponder()
            if(!(self.searchText.text?.trim().isEmpty)!) {
                sender.isSelected = true
                sender.tag = 1
                isSearch = true
                self.hudView.startLoaderWithAnimation()
                StreamList.sharedInstance.requestURl = ""
//                if btnFeature.titleLabel?.text == "PEOPLE" {
//                    isStreamEnable = false
//                    self.btnStreamSearch.isUserInteractionEnabled = true
//                    self.btnPeopleSearch.isUserInteractionEnabled = false
//                    lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
//                    lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
//
//                    PeopleList.sharedInstance.arrayPeople.removeAll()
//                    collectionStream.reloadData()
//                    self.collectionStream.isHidden = true
//                    StreamList.sharedInstance.requestURl = ""
//                    PeopleList.sharedInstance.requestURl = ""
//                    SharedData.sharedInstance.isMoreContentAvailable = false
//                    self.getPeopleGlobleSearch(searchText: self.searchText.text!, type: .start)
//                }else{
                    isStreamEnable = true
                    //lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
                  //  lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
                    self.btnStreamSearch.isUserInteractionEnabled = false
                    self.btnPeopleSearch.isUserInteractionEnabled = true
                    PeopleList.sharedInstance.arrayPeople.removeAll()
                    collectionStream.reloadData()
                    self.collectionStream.isHidden = true
                    StreamList.sharedInstance.requestURl = ""
                    PeopleList.sharedInstance.requestURl = ""
                    SharedData.sharedInstance.isMoreContentAvailable = false
                    self.getStreamGlobleSearch(searchText: self.searchText.text!, type: .start)
              //  }
              
            } else if searchText.text?.trim() != "" {
                btnCancel.tag = 1
                //   btnSearch.setImage(#imageLiteral(resourceName: "cross_search"), for: UIControlState.normal)
                self.didTapActionSearch(searchString: (searchText.text?.trim())!)
                //self.viewMenu.isHidden = true
                isSearch = true
            }
        }
        else {
          
            self.viewSearchButton.isHidden = true
            self.viewSegment.isHidden = false
            self.kSearchViewHeight.constant = 0.0
            self.kHeightViewSegment.constant = 33.0
            self.kWidthCancel.constant = 0.0
            self.kViewSearchButtonHeight.constant = 0.0
            sender.isSelected = false
            sender.tag = 0
            self.btnFeature.isUserInteractionEnabled = true
            self.searchText.text = ""
            isSearch = false
            self.searchText.resignFirstResponder()
           // self.viewCollections.isHidden = true
            SharedData.sharedInstance.isMoreContentAvailable = false
            PeopleList.sharedInstance.requestURl = ""
            PeopleList.sharedInstance.arrayPeople.removeAll()
            collectionStream.reloadData()
            //            if btnFeature.titleLabel?.text == "PEOPLE" {
            ////                self.getUsersList(type: .start)
            //            }else{
            ////                self.getStreamList(type: .start, filter: streamType)
            //            }
            DispatchQueue.main.async {
                self.collectionStream.isHidden = false
//                self.collectionStream.frame = CGRect(x: self.collectionStream.frame.origin.x, y: 0, width: self.collectionStream.frame.size.width, height: self.viewCollectionsMain.frame.height)
                self.setupCollectionProperties()
                self.collectionStream.reloadData()
            }
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                if self.arrayToShow.count == 0 {
                    self.lblNoResult.isHidden = false
                }else {
                    self.lblNoResult.isHidden = true
                }
                self.collectionStream.reloadData()
            }
            
            
            
        }
    }
    
    @IBAction func btnFeaturedTap(_ sender: UIButton) {
        isSearch = false
        if(btnFeature.tag == 1) {
            pagerContent.isHidden = true
            btnFeature.tag = 0
        } else {
            if(SharedData.sharedInstance.isMessageWindowExpand) {
                if SharedData.sharedInstance.isPortrate {
                    pagerContent.isHidden = false
                    btnFeature.tag = 1
                }else{
                    pagerContent.isHidden = true
                    btnFeature.tag = 0
                }
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Expand), object: nil)
                if SharedData.sharedInstance.isPortrate {
                    pagerContent.isHidden = false
                    btnFeature.tag = 1
                }else{
                    pagerContent.isHidden = true
                    btnFeature.tag = 0
                }
            }
        }
    }
    
    @IBAction func btnActionStreamSearch(_ sender : UIButton){
        switch sender.tag {
            
        case 0:         //Stream
  
            
//            lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
//            lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            self.hudView.startLoaderWithAnimation()
            self.isStreamEnable = true
            self.isSearch = true
            PeopleList.sharedInstance.arrayPeople.removeAll()
            collectionStream.reloadData()
            self.collectionStream.isHidden = false
            self.btnPeopleSearch.setImage(#imageLiteral(resourceName: "people_button_inactive"), for: .normal)
            self.btnStreamSearch.setImage(#imageLiteral(resourceName: "emogo_button_active"), for: .normal)
            StreamList.sharedInstance.requestURl = ""
            PeopleList.sharedInstance.requestURl = ""
            SharedData.sharedInstance.isMoreContentAvailable = false
            self.getStreamGlobleSearch(searchText: searchText.text!, type: .start)
            break
            
        case 1:         //People
           // lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            //lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
            
            self.hudView.startLoaderWithAnimation()
            PeopleList.sharedInstance.arrayPeople.removeAll()
            self.isStreamEnable = false
            self.isSearch = true
            self.collectionStream.reloadData()
            self.setupCollectionProperties()
            self.btnPeopleSearch.setImage(#imageLiteral(resourceName: "people_button_active"), for: .normal)
            self.btnStreamSearch.setImage(#imageLiteral(resourceName: "emogos_inactive_button"), for: .normal)
            PeopleList.sharedInstance.requestURl = ""
            StreamList.sharedInstance.requestURl = ""
            SharedData.sharedInstance.isMoreContentAvailable = false
            self.getPeopleGlobleSearch(searchText: self.searchText.text!, type: .start)
            break
            
        default:
            break
            
        }
    }
    
    
    func expandPeopleHeight() {
        self.collectionStream.isHidden = true
        
        UIView.animate(withDuration: 0.7, animations: {
            self.heightStream?.isActive = true
            self.heightPeople?.isActive = false
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.isStreamEnable = false
            self.isSearch = true
            
            DispatchQueue.main.async {
//                self.collectionStream.frame = CGRect(x: self.collectionStream.frame.origin.x, y: self.viewPeople.frame.origin.y+40, width: self.collectionStream.frame.size.width, height: self.viewPeople.frame.size.height-40)
             self.collectionStream.isHidden = false
//
//                self.setupCollectionProperties()
                self.collectionStream.reloadData()
            }
        }
    }
    
    func expandStreamHeight(){
        self.collectionStream.isHidden = true
        UIView.animate(withDuration: 0.7, animations: {
            self.heightStream?.isActive = false
            self.heightPeople?.isActive = true
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.isStreamEnable = true
            self.isSearch = true
            DispatchQueue.main.async {
                self.collectionStream.isHidden = false
//                self.collectionStream.frame = CGRect(x: self.collectionStream.frame.origin.x, y: self.viewStream.frame.origin.y+40, width: self.collectionStream.frame.size.width, height: self.viewStream.frame.size.height-40)
//                self.setupCollectionProperties()
                self.collectionStream.reloadData()
            }
        }
    }
    
    
    // MARK: - API Methods
    
    func getTopStreamList() {
      
        APIServiceManager.sharedInstance.apiForGetTopStreamList { (streams, errorMsg) in
            self.streaminputDataType(type: .start)
             self.view.isUserInteractionEnabled = true
            
            if (errorMsg?.isEmpty)! {
                StreamList.sharedInstance.arrayStream.removeAll()
                StreamList.sharedInstance.arrayStream = streams
               
                if self.hudRefreshView != nil {
                    self.hudRefreshView.stopLoaderWithAnimation()
                }
                DispatchQueue.main.async {
                    self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                    if self.arrayToShow.count == 0 {
                        self.lblNoResult.isHidden = false
                    }else {
                        self.lblNoResult.isHidden = true
                    }
                     self.setupCollectionProperties()
                     self.collectionStream.reloadData()
                }
            } else {
                self.showToastIMsg(type: .success, strMSG: errorMsg!)
                
            }
        }
    }
   
    func getStreamList(type:RefreshType,filter:StreamType){
        lblNoResult.text = kAlert_No_Stream_found
        if(SharedData.sharedInstance.iMessageNavigation != ""){
            return
        }
    
            if type == .start || type == .up {
                for _ in StreamList.sharedInstance.arrayStream {
                    if let index = StreamList.sharedInstance.arrayStream.index(where: { $0.selectionType == currentStreamType}) {
                        StreamList.sharedInstance.arrayStream.remove(at: index)
                        print("Removed")
                    }
                }
            }

            APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
                self.view.isUserInteractionEnabled = true
                self.streaminputDataType(type: type)
                self.lblNoResult.isHidden = true

//                if StreamList.sharedInstance.arrayStream.count == 0 {
//                    self.lblNoResult.isHidden = false
//                }
                if refreshType == .end {
                    self.fectchingStreamData = false
                }else{
                    self.fectchingStreamData = true
                }

//                DispatchQueue.main.async {
//                    self.collectionStream.isHidden = false
////                    self.collectionStream.frame = CGRect(x: self.collectionStream.frame.origin.x, y: 0, width: self.collectionStream.frame.size.width, height: self.viewCollectionsMain.frame.height)
//                    self.setupCollectionProperties()
//                    self.collectionStream.reloadData()
//                }
                self.setupCollectionProperties()
           
                self.collectionStream.isUserInteractionEnabled = true
                print(currentStreamType)
                DispatchQueue.main.async {
                    self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                    if self.arrayToShow.count == 0 {
                        self.lblNoResult.isHidden = false
                    }else {
                        self.lblNoResult.isHidden = true
                    }
                    self.collectionStream.reloadData()
                }
                self.collectionStream.reloadData()
                if !(errorMsg?.isEmpty)! {
                    self.showToastIMsg(type: .success, strMSG: errorMsg!)
                }
            }
    }
    
    //MARK:- calling webservice
    @objc func getStream(streamID:String) {
        if Reachability.isNetworkAvailable() {
            APIServiceManager.sharedInstance.apiForViewStream(streamID: streamID) { (stream, errorMsg) in
                self.view.isUserInteractionEnabled = true
                if (errorMsg?.isEmpty)! {
                    let obj : StreamViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Stream) as! StreamViewController
                    if SharedData.sharedInstance.iMessageNavigation == kNavigation_Stream {
                        var arrayTempStream  = [StreamDAO]()
                        arrayTempStream.append(SharedData.sharedInstance.streamContent!)
                        obj.arrStream = arrayTempStream
                        
                    }
                    else if SharedData.sharedInstance.iMessageNavigation == kNavigation_Content {
                        
                        if SharedData.sharedInstance.iMessageNavigationCurrentStreamID == "" {
                            
                        } else{
                            var arrayTempStream  = [StreamDAO]()
                            var streamDatas  = [String:Any]()
                            streamDatas["id"] = SharedData.sharedInstance.iMessageNavigationCurrentStreamID
                            SharedData.sharedInstance.streamContent = StreamDAO.init(streamData: streamDatas)
                            arrayTempStream.append(SharedData.sharedInstance.streamContent!)
                            obj.arrStream = arrayTempStream
                        }
                    }
                    obj.currentStreamIndex = 0
                    self.present(obj, animated: false, completion: nil)
                }
                    
                else if errorMsg == APIStatus.NotFound.rawValue{
                    if self.hudView != nil {
                        self.hudView.stopLoaderWithAnimation()
                    }
                    self.showToastIMsg(type: .error, strMSG: kAlert_Stream_Not_Found)
                    self.lblNoResult.text = kAlert_No_Stream_found
                    self.lblNoResult.isHidden = false
                    SharedData.sharedInstance.iMessageNavigation = ""
                    SharedData.sharedInstance.streamContent?.ID = ""
                }else{
                    if self.hudView != nil {
                        self.hudView.stopLoaderWithAnimation()
                    }
                    self.showToastIMsg(type: .error, strMSG: errorMsg!)
                    SharedData.sharedInstance.iMessageNavigation = ""
                    SharedData.sharedInstance.streamContent?.ID = ""
                    self.lblNoResult.text = kAlert_No_Stream_found
                    self.lblNoResult.isHidden = false
                    
                }
                
                
            }
        }
        else {
            self.view.isUserInteractionEnabled = true
            self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
    
    func getContenData(){
        APIServiceManager.sharedInstance.apiForGetContent(contenID: SharedData.sharedInstance.iMessageNavigationCurrentContentID) { (dict, error) in
            //            if error == nil {
            self.view.isUserInteractionEnabled = true
            if !(error?.isEmpty)! {
                self.showToastIMsg(type: .success, strMSG: kAlert_Content_Not_Found)
                return
            }
            let objContent = ContentDAO.init(contentData: dict!)
            let obj : StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
            obj.arrContentData = [objContent]
            obj.currentContentIndex  = 0
            obj.currentStreamTitle = ""
            self.present(obj, animated: false, completion: nil)
    
        }
    }

    func getUsersList(type:RefreshType){
        lblNoResult.text = kAlert_No_User_Record_Found
        if SharedData.sharedInstance.iMessageNavigation == "" {
            if Reachability.isNetworkAvailable() {
                
                if type == .up {
                    for _ in StreamList.sharedInstance.arrayStream {
                        if let index = StreamList.sharedInstance.arrayStream.index(where: { $0.selectionType == currentStreamType}) {
                            StreamList.sharedInstance.arrayStream.remove(at: index)
                            print("Removed")
                        }
                    }
                }
                self.collectionStream.reloadData()
                APIServiceManager.sharedInstance.apiForGetPeopleList(type:type, deviceType: .iPhone) { (refreshType, errorMsg) in
                    self.view.isUserInteractionEnabled = true
                    self.streaminputDataType(type: type)
                    self.lblNoResult.isHidden = true
                    self.collectionStream.isHidden = false
                    
                    if self.hudRefreshView != nil {
                        self.hudRefreshView.stopLoaderWithAnimation()
                    }
                    if refreshType == .end {
                        self.fectchingStreamData = false
                    }else{
                        self.fectchingStreamData = true
                    }
                    
                    if PeopleList.sharedInstance.arrayPeople.count == 0 {
                        self.lblNoResult.isHidden = false
                    }
                    DispatchQueue.main.async {
                        self.collectionStream.isHidden = false
//                        self.collectionStream.frame = CGRect(x: self.collectionStream.frame.origin.x, y: 0, width: self.collectionStream.frame.size.width, height: self.viewCollectionsMain.frame.height)
                        self.setupCollectionProperties()
                        self.collectionStream.isUserInteractionEnabled = true
                        self.collectionStream.reloadData()
                    }
                    
                    DispatchQueue.main.async {
                        self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                        if self.arrayToShow.count == 0 {
                            self.lblNoResult.isHidden = false
                        }else {
                            self.lblNoResult.isHidden = true
                        }
                        self.collectionStream.reloadData()
                    }
                    
                    if !(errorMsg?.isEmpty)! {
                        self.showToastIMsg(type: .success, strMSG: errorMsg!)
                    }
                }
            }else{
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
  
  
    func getPeopleGlobleSearch(searchText:String, type:RefreshType){
      
        lblNoResult.text = kAlert_No_User_Record_Found
        StreamList.sharedInstance.arrayMyStream.removeAll()
        self.arrayToShow.removeAll()
        self.collectionStream.reloadData()
        
        APIServiceManager.sharedInstance.apiForSearchPeople(strSearch: searchText, type: type) { (refreshType, errorMsg) in
            self.view.isUserInteractionEnabled = true
            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            
            if self.hudRefreshView != nil {
                self.hudRefreshView.stopLoaderWithAnimation()
            }
            
            if refreshType == .end {
                self.fectchingStreamData = false
            }else{
                self.fectchingStreamData = true
            }
            
            if !(errorMsg?.isEmpty)! {
                self.showToastIMsg(type: .success, strMSG: errorMsg!)
                return
            }
            self.streaminputDataType(type: type)
            self.lblNoResult.isHidden = true
            self.btnStreamSearch.isUserInteractionEnabled = true
            self.btnPeopleSearch.isUserInteractionEnabled = false
          //  self.viewCollections.isHidden = true
            self.collectionStream.isUserInteractionEnabled = true
            self.setupCollectionProperties()
            //self.expandPeopleHeight()
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayMyStream
                if self.arrayToShow.count == 0 {
                    self.lblNoResult.isHidden = false
                    //self.lblPeopleSearch.text = "People"
                   // self.lblStreamSearch.text = "Stream"

                }else {
                    self.lblNoResult.isHidden = true
                    let count = "(\(self.arrayToShow.count))"
                    print(count)
                   // self.lblPeopleSearch.text = "People \(count)"
                   // self.lblStreamSearch.text = "Stream"
                }
                self.collectionStream.reloadData()
            }
        }
    }
    
    func getStreamGlobleSearch(searchText:String, type:RefreshType){
       
        lblNoResult.text = kAlert_No_Stream_found
        StreamList.sharedInstance.arrayMyStream.removeAll()
        self.arrayToShow.removeAll()
        self.collectionStream.reloadData()
        
        if SharedData.sharedInstance.iMessageNavigation == "" {
            APIServiceManager.sharedInstance.apiForSearchStream(strSearch: searchText, type: type, completionHandler: { (refreshType, errorMsg) in
                self.view.isUserInteractionEnabled = true
                if self.hudView != nil {
                    self.hudView.stopLoaderWithAnimation()
                }
                
                if self.hudRefreshView != nil {
                    self.hudRefreshView.stopLoaderWithAnimation()
                }
                
                if refreshType == .end {
                    self.fectchingStreamData = false
                }else{
                    self.fectchingStreamData = true
                }
                
                if !(errorMsg?.isEmpty)! {
                    self.showToastIMsg(type: .success, strMSG: errorMsg!)
                    return
                }
                self.btnStreamSearch.isUserInteractionEnabled = false
                self.btnPeopleSearch.isUserInteractionEnabled = true
                self.lblNoResult.isHidden = true
                self.collectionStream.isHidden = false
             //   self.viewCollections.isHidden = true
                self.collectionStream.isUserInteractionEnabled = true
                self.streaminputDataType(type: type)
                self.setupCollectionProperties()
               // self.expandStreamHeight()
                DispatchQueue.main.async {
                    self.arrayToShow = StreamList.sharedInstance.arrayMyStream
                    if self.arrayToShow.count == 0 {
                        self.lblNoResult.isHidden = false
                        //self.lblStreamSearch.text = "Stream"
                       // self.lblPeopleSearch.text = "People"
                    }else {
                        self.lblNoResult.isHidden = true
                        let count = "(\(self.arrayToShow.count))"
                        print(count)
                        //self.lblStreamSearch.text = "Stream \(count)"
                        //self.lblPeopleSearch.text = "People"

                    }
                    self.collectionStream.reloadData()
                }
            })
        }
    }
    
    func streaminputDataType(type:RefreshType) {
        if(type == .down) {
            self.footerView?.loadingView.stopLoaderWithAnimation()
        }
        else  if(type == .start){
            if hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            self.resignRefreshLoader()
        }
        else{
            self.resignRefreshLoader()
        }
         self.view.isUserInteractionEnabled = true
    }
    
    func didTapActionSearch(searchString: String) {
        // btnSearch.setImage(#imageLiteral(resourceName: "cross_search"), for: UIControlState.normal)
        btnCancel.tag = 1
        self.viewSegment.isHidden = true
        self.kHeightViewSegment.constant = 0.0
        self.searchText.text? = searchString
        kWidthCancel.constant = 65.0
        self.viewSearchButton.isHidden = false
        self.kViewSearchButtonHeight.constant = CGFloat(self.kSearchHeight)
        self.btnPeopleSearch.setImage(#imageLiteral(resourceName: "people_button_inactive"), for: .normal)
        self.btnStreamSearch.setImage(#imageLiteral(resourceName: "emogo_button_active"), for: .normal)
        self.getStreamGlobleSearch(searchText: searchString, type: .start)
        layout.sectionInset = UIEdgeInsets(top:10, left: 8, bottom: 8, right: 8)
    }
}

// MARK:- Extension collectionview delegate
extension HomeViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
  
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    //
    //        if (isSearch == true && !isStreamEnable){
    //            let itemWidth = collectionView.bounds.size.width/3.0
    //            return CGSize(width: itemWidth, height: itemWidth+20)
    //        }
    //        else if (isSearch == true &&  isStreamEnable){
    //            let itemWidth = collectionView.bounds.size.width/2.0
    //            if SharedData.sharedInstance.isPortrate {
    //                return CGSize(width: itemWidth, height: itemWidth - 35)
    //            }else{
    //                return CGSize(width: itemWidth, height: (itemWidth / 2+10))
    //            }
    //
    //        }
    //        else  if (btnFeature.titleLabel?.text == "PEOPLE"){
    //            let itemWidth = collectionView.bounds.size.width/3.0
    //            return CGSize(width: itemWidth, height: itemWidth+20)
    //        }  else  {
    //            let itemWidth = collectionView.bounds.size.width/2.0
    //            if SharedData.sharedInstance.isPortrate {
    //                return CGSize(width: itemWidth, height: itemWidth - 35)
    //            }else{
    //                return CGSize(width: itemWidth, height: (itemWidth / 2+10))
    //            }
    //        }
    //    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell  = UICollectionViewCell()
        if self.isSearch == false {
            if currentStreamType == .People {
                let people = self.arrayToShow[indexPath.row]
                cell  = collectionStream.dequeueReusableCell(withReuseIdentifier: iMsgSegue_HomeCollectionPeople, for: indexPath) as! PeopleSearchCollectionViewCell
                (cell as! PeopleSearchCollectionViewCell).prepareData(people:people)
            }
            else {
                let stream = self.arrayToShow[indexPath.row]
                cell  = collectionStream.dequeueReusableCell(withReuseIdentifier: iMsgSegue_HomeCollection, for: indexPath) as! HomeCollectionViewCell
                (cell as! HomeCollectionViewCell).prepareLayouts(stream: stream)
                (cell as! HomeCollectionViewCell).imgStream.tag = indexPath.row
                (cell as! HomeCollectionViewCell).btnView.tag = indexPath.row
                (cell as! HomeCollectionViewCell).btnView.addTarget(self, action: #selector(self.btnViewAction(_:)), for: UIControlEvents.touchUpInside)
                (cell as! HomeCollectionViewCell).btnShare.tag = indexPath.row
                (cell as! HomeCollectionViewCell).btnShare.addTarget(self, action: #selector(self.btnShareAction(_:)), for: UIControlEvents.touchUpInside)
            }
        }
        else {
            if isSearch && !isStreamEnable {
                let people = self.arrayToShow[indexPath.row]
                cell  = collectionStream.dequeueReusableCell(withReuseIdentifier: iMsgSegue_HomeCollectionPeople, for: indexPath) as! PeopleSearchCollectionViewCell
                (cell as! PeopleSearchCollectionViewCell).prepareData(people:people)
            }
            else {
                let stream = self.arrayToShow[indexPath.row]
                cell  = collectionStream.dequeueReusableCell(withReuseIdentifier: iMsgSegue_HomeCollection, for: indexPath) as! HomeCollectionViewCell
                (cell as! HomeCollectionViewCell).prepareLayouts(stream: stream)
                (cell as! HomeCollectionViewCell).imgStream.tag = indexPath.row
                (cell as! HomeCollectionViewCell).btnView.tag = indexPath.row
                (cell as! HomeCollectionViewCell).btnView.addTarget(self, action: #selector(self.btnViewAction(_:)), for: UIControlEvents.touchUpInside)
                (cell as! HomeCollectionViewCell).btnShare.tag = indexPath.row
                (cell as! HomeCollectionViewCell).btnShare.addTarget(self, action: #selector(self.btnShareAction(_:)), for: UIControlEvents.touchUpInside)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionFooter {
            let aFooterView = collectionStream.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: iMgsSegue_HomeCollectionReusableV, for: indexPath) as! HomeCollectionReusableView
            self.footerView = aFooterView
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: iMsgSegue_CollectionReusable_Footer, for: indexPath)
            return headerView
        }
    }
   
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if !fectchingStreamData {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.hudRefreshView?.startLoaderWithAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.hudRefreshView?.stopLoaderWithAnimation()
        }
    }
    
    @objc func btnViewAction(_ sender:UIButton) {
        let obj : StreamViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Stream) as! StreamViewController
        self.addRippleTransition()
        //StreamList.sharedInstance.arrayViewStream = self.arrayToShow
        obj.arrStream = self.arrayToShow
        obj.currentStreamIndex = sender.tag
       // obj.strStream =  "viewStream"
        self.present(obj, animated: false, completion: nil)
        self.changeCellImageAnimation(sender.tag)
    }
    
    @objc func btnShareAction(_ sender:UIButton) {
        if(SharedData.sharedInstance.isMessageWindowExpand){
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Manage_Request_Style_Compact), object: nil)
        }
        let stream = self.arrayToShow[sender.tag]
        self.sendMessage(content: stream, sender: sender.tag)
    }
    
    func sendMessage(content:StreamDAO, sender:Int) {
        let indexPath = NSIndexPath(row: sender, section: 0)
        if let sel = self.collectionStream.cellForItem(at: indexPath as IndexPath){
            let session = MSSession()
            let message = MSMessage(session: session)
            let layout = MSMessageTemplateLayout()
            layout.caption = content.Title.trim()
            layout.subcaption = "by \(content.Author!)"
            layout.image  = (sel as! HomeCollectionViewCell).imgStream.image
            message.layout = layout
            message.url = URL(string: "\(kNavigation_Stream)/\(content.ID!)/\(content.Author!)/\(content.CoverImage!)/\(content.IDcreatedBy!)")
            SharedData.sharedInstance.savedConversation?.insert(message, completionHandler: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        pagerContent.isHidden = true
        btnFeature.tag = 0
        
        if self.isSearch == false {
            if currentStreamType == .People {
                for subV in pagerContent.subviews {
                    if subV.isKind(of: FSPagerView.self){
                        showAlert(5, pagerView: (subV as! FSPagerView), alert: kAlert_Title_Confirmation, messgae: kAlert_Confirmation_Description_For_People, selectedIndex: indexPath.row)
                        return
                    }
                }
                
            }else {
                self.changeCellImageAnimation(indexPath.row)
                
            }
        }
        else {
            
            if isSearch && !isStreamEnable {
                for subV in pagerContent.subviews {
                    if subV.isKind(of: FSPagerView.self){
                        let people = self.arrayToShow[indexPath.row]
                        let objPeople = PeopleDAO(peopleData: [:])
                        objPeople.fullName = people.fullName
                        objPeople.userId = people.userId
                        objPeople.userProfileID = people.userProfileId
                        objPeople.userImage = people.userImage
                        objPeople.phoneNumber = people.phoneNumber
                        objPeople.userProfileID = people.userProfileId
                        let obj:ViewProfileViewController = self.storyboard!.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                        obj.objPeople = objPeople
                        self.present(obj, animated: false, completion: nil)
//                        showAlert(5, pagerView: (subV as! FSPagerView), alert: kAlert_Title_Confirmation, messgae: kAlert_Confirmation_Description_For_People, selectedIndex: indexPath.row)
                        return
                    }
                }
                
            }
            else {
                self.changeCellImageAnimation(indexPath.row)
                
            }
        }
        
    }
    
    func changeCellImageAnimation(_ sender : Int) {
        for row in 0 ..< self.collectionStream.numberOfItems(inSection: 0){
            let indexPath = NSIndexPath(row: row, section: 0)
            if let sel = self.collectionStream.cellForItem(at: indexPath as IndexPath){
                if(sender == (sel as! HomeCollectionViewCell).imgStream?.tag){
                    if((sel as! HomeCollectionViewCell).viewShowHide.isHidden == false){
                        (sel as! HomeCollectionViewCell).viewShowHide.isHidden = true
                    }
                    else{
                        (sel as! HomeCollectionViewCell).viewShowHide.isHidden = false
                    }
                    addTransition(vi : (sel as! HomeCollectionViewCell))
                } else {
                    (sel as! HomeCollectionViewCell).viewShowHide.isHidden = true
                }
            }
        }
    }
    
    func addTransition(vi : HomeCollectionViewCell) {
        let transition = CATransition()
        transition.duration = 0.7
        transition.type = "flip"
        transition.subtype = kCATransitionFromRight
        vi.layer.add(transition, forKey: kCATransition)
    }
    
}

// MARK:- Extension TextField delegate
extension HomeViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(!(self.searchText.text?.trim().isEmpty)!) {
            self.btnFeature.isUserInteractionEnabled = false
            self.hudView.startLoaderWithAnimation()
            isSearch = true
            isStreamEnable = true
          // btnSearchHeader.isSelected = true
           // btnSearchHeader.tag = 1
            self.searchText.resignFirstResponder()
            
//            if btnFeature.titleLabel?.text == "PEOPLE" {
//                isStreamEnable = false
//                self.btnStreamSearch.isUserInteractionEnabled = true
//                self.btnPeopleSearch.isUserInteractionEnabled = false
//                PeopleList.sharedInstance.arrayPeople.removeAll()
//                collectionStream.reloadData()
//                StreamList.sharedInstance.requestURl = ""
//                PeopleList.sharedInstance.requestURl = ""
//                SharedData.sharedInstance.isMoreContentAvailable = false
//                lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
//                lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
//                //                self.setupCollectionProperties()
//                self.getPeopleGlobleSearch(searchText: self.searchText.text!, type: .start)
//            }else{
                isStreamEnable = true
//                lblStreamSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
//                lblPeopleSearch.textColor = #colorLiteral(red: 0.2245908678, green: 0.6891257167, blue: 0.8883596063, alpha: 1)
                PeopleList.sharedInstance.arrayPeople.removeAll()
                //collectionStream.reloadData()
                StreamList.sharedInstance.requestURl = ""
                PeopleList.sharedInstance.requestURl = ""
                SharedData.sharedInstance.isMoreContentAvailable = false
                self.btnStreamSearch.isUserInteractionEnabled = false
                self.btnPeopleSearch.isUserInteractionEnabled = true
               // self.setupCollectionProperties()
              //  self.getStreamGlobleSearch(searchText: self.searchText.text!, type: .start)
           // }
            
            pagerContent.isHidden = true
            btnFeature.tag = 0
            self.didTapActionSearch(searchString: (self.searchText.text!.trim()))
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        pagerContent.isHidden = true
        btnFeature.tag = 0
        if(!SharedData.sharedInstance.isMessageWindowExpand) {
            NotificationCenter.default.post(name:   NSNotification.Name(kNotification_Manage_Request_Style_Expand), object: nil)
            btnFeature.tag = 0
        }else{
            btnFeature.tag = 0
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}

// MARK:- Extension FSPagerView delegate
extension HomeViewController : FSPagerViewDataSource,FSPagerViewDelegate {
    
    // MARK:- FSPagerViewDataSource
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return arrImages.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        if(index == pagerView.currentIndex) {
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = UIImage(named: self.arrImagesSelected[index])
            cell.addLayerInImageView(isTrue : true)
        }
        else {
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = UIImage(named: self.arrImages[index])
        }
        
        cell.imageView?.tag = index
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)!/2
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        if(lastIndex != index){
            
            let last = lastIndex
            
            lastIndex = index
            
            self.btnStreamSearch.isUserInteractionEnabled = false
            self.btnPeopleSearch.isUserInteractionEnabled = true
           // self.viewCollections.isHidden = true
           
            
            switch  index {
                
            case 0:
                lastIndex = index
                currentStreamType  =  StreamType.populer
                lastSelectedType = currentStreamType
                if last > index {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                self.changePager()
                break
                
            case 1:
                lastIndex = index
                currentStreamType = StreamType.Public
                self.segmentHeader.segmentControl.selectedSegmentIndex = 0
               // currentStreamType =  StreamType.myStream
                lastSelectedType = currentStreamType
                if last > index {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
            
                self.changePager()
                break
                
            case 2:
                lastIndex = index
                currentStreamType =  StreamType.featured
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > index {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
               
                self.changePager()
                break
                
            case 3:
                lastIndex = index
                currentStreamType = StreamType.emogoStreams
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > index {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
               
                self.changePager()
                break
                
            case 4:
                lastIndex = index
                currentStreamType = StreamType.profile
                lastSelectedType = currentStreamType
                if last > index {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                let obj = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.present(obj, animated: true, completion: nil)
                
              // showAlert(index, pagerView: pagerView, alert: kAlert_Title_Confirmation, messgae: kAlert_Confirmation_Description_For_Profile, selectedIndex: 0)
                self.changePager()

                break
           /*
            case 5:
               
                lastIndex = index
                currentStreamType = StreamType.People
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > index {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                self.changePager()
                break
            */
            case 5:
                lastIndex = index
                currentStreamType = StreamType.Liked
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > index {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                
                self.changePager()
                break
            case 6:
                lastIndex = index
                currentStreamType = StreamType.Following
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > index {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
          
                self.changePager()
                break
          
            default :
                break
            }
            

            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(index, pagerView: pagerView)
            })
            
        }
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        
        if(lastIndex != pagerView.currentIndex) {
             let last = lastIndex
            self.btnStreamSearch.isUserInteractionEnabled = false
            self.btnPeopleSearch.isUserInteractionEnabled = true
          //  self.viewCollections.isHidden = true
            if self.segmentHeader != nil {
                if self.segmentHeader.superview != nil {
                    self.segmentHeader.segmentView.isHidden = true
                    self.segmentHeader.removeFromSuperview()
                }
            }

            
            switch  pagerView.currentIndex {
            case 0:
                
                lastIndex = pagerView.currentIndex
                currentStreamType = StreamType.Public
              //  currentStreamType =  StreamType.myStream
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > pagerView.currentIndex {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                self.changePager()
                break
                
                
            case 1:
                lastIndex = pagerView.currentIndex
                currentStreamType  =  StreamType.populer
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > pagerView.currentIndex {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                
                self.changePager()
                break
                
            case 2:
                lastIndex = pagerView.currentIndex
                currentStreamType =  StreamType.featured
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > pagerView.currentIndex {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                
                self.changePager()
                break
                
            case 3:
                lastIndex = pagerView.currentIndex
                currentStreamType = StreamType.emogoStreams
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > pagerView.currentIndex {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                 
                self.changePager()
                break
                
            case 4:
                currentStreamType = StreamType.profile
                let obj = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.present(obj, animated: true, completion: nil)
                 currentStreamType = StreamType.profile
               // showAlert(pagerView.currentIndex, pagerView: pagerView, alert: kAlert_Title_Confirmation, messgae: kAlert_Confirmation_Description_For_Profile, selectedIndex: 0)
                 self.changePager()

                break
            /*
            case 5:
                lastIndex = pagerView.currentIndex
                currentStreamType = StreamType.People
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > pagerView.currentIndex {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                self.changePager()
                break
            */
            case 5:
                lastIndex = pagerView.currentIndex
                currentStreamType = StreamType.Liked
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > pagerView.currentIndex {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                self.changePager()
                break
            case 6 :
                lastIndex = pagerView.currentIndex
                currentStreamType = StreamType.Following
                lastSelectedType = currentStreamType
                StreamList.sharedInstance.updateRequestType(filter: currentStreamType)
                if last > pagerView.currentIndex {
                    self.addLeftTransitionCollection(imgV: self.collectionStream)
                }
                else{
                    self.addRightTransitionCollection(imgV: self.collectionStream)
                }
                self.changePager()
                break
            default :
                break
            }

            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(pagerView.currentIndex, pagerView: pagerView)
            })
        }
    }
    
    func addRightTransitionCollection(imgV:UICollectionView){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
    func addLeftTransitionCollection(imgV:UICollectionView){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft      
        imgV.layer.add(transition, forKey: kCATransition)
    }
    
    func changePager() {
     
        DispatchQueue.main.async {
            self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
            self.viewSegment.isHidden = true
            self.kHeightViewSegment.constant = 0.0
            if  currentStreamType == StreamType.Public ||  currentStreamType == StreamType.Private{
              
                if self.segmentHeader != nil {
                    if self.segmentHeader.superview != nil {
                        self.segmentHeader.removeFromSuperview()
                    }
                }
                 self.configureStreamHeader()
                if currentStreamType == StreamType.Public {
                    self.segmentHeader.segmentControl.selectedSegmentIndex = 0
                }else {
                    self.segmentHeader.segmentControl.selectedSegmentIndex = 1
                }
   
            }
            if self.arrayToShow.count == 0 {
                self.lblNoResult.isHidden = false
            }
            else {
                self.lblNoResult.isHidden = true
            }
            
           // self.setupCollectionProperties()
            self.collectionStream.reloadData()
        }
    }

    func changeCellImageAnimationt(_ sender : Int, pagerView: FSPagerView) {
        for row in 0 ..< pagerView.numberOfItems {
            let indexPath = NSIndexPath(row: row, section: 0)
            if let sel = pagerView.collectionView.cellForItem(at: indexPath as IndexPath) {
                if(sender == (sel as! FSPagerViewCell).imageView?.tag){
                    (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
                    (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                    (sel as! FSPagerViewCell).imageView?.image = UIImage(named: self.arrImagesSelected[indexPath.row])
                    (sel as! FSPagerViewCell).addLayerInImageView(isTrue : true)
                } else {
                    (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
                    (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                    (sel as! FSPagerViewCell).imageView?.image = UIImage(named: self.arrImages[indexPath.row])
                }
                (sel as! FSPagerViewCell).imageView?.layer.cornerRadius = ((sel as! FSPagerViewCell).imageView?.frame.size.width)!/2
            }
        }
        let strLbl = "\(self.arrImagesSelected[sender])"
        var strTitle :String! = ""
        if strLbl.lowercased() == "my streams" {
            strTitle = strLbl.replacingOccurrences(of: "Streams", with: "Emogo")
        }else {
            strTitle = strLbl.replacingOccurrences(of: "Streams", with: "")
        }
        pagerView.lblCurrentType.text = strTitle.uppercased()
        btnFeature.setTitle(pagerView.lblCurrentType.text, for: .normal)
    }
    
    func showAlert(_ index: Int, pagerView:FSPagerView, alert:String, messgae:String, selectedIndex:Int) {
        let alert = UIAlertController(title: alert, message: messgae, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: kAlert_Cancel_Title, style: UIAlertActionStyle.default, handler: { action in
            switch action.style{
            case .default:
                UIView.animate(withDuration: 0.7, animations: {
                    if self.isSearch == false {
                        pagerView.currentIndex = self.lastIndex
                        let strLbl = "\(self.arrImagesSelected[pagerView.currentIndex])"
                        var strTitle :String! = ""
                        if strLbl.lowercased() == "my streams" {
                            strTitle = strLbl.replacingOccurrences(of: "Streams", with: "Emogo")
                        }else {
                            strTitle = strLbl.replacingOccurrences(of: "Streams", with: "")
                        }
                        pagerView.lblCurrentType.text = strTitle.uppercased()
                        self.btnFeature.setTitle(strTitle.uppercased(), for: .normal)
                        pagerView.reloadData()
                        currentStreamType = self.lastSelectedType
                        self.changePager()
                    }
                    })
                break
            case .cancel:
                break
            case .destructive:
                break
            }}))
        
        alert.addAction(UIAlertAction(title: kAlert_Confirmation_Button_Title, style: UIAlertActionStyle.cancel, handler: { action in
            switch action.style{
            case .cancel:
                switch index {
                case 4:
                    self.lastIndex = index
                    let strUrl = "\(kDeepLinkURL)\(self.arrImagesSelected[self.lastIndex])"
                    SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
                    break
                case 5:
                    self.lastIndex = index
                    let strUrl = "\(kDeepLinkURL)\(self.arrImagesSelected[self.lastIndex])"
                    let userInfo = self.arrayToShow[selectedIndex]
                    let str = self.createURLWithComponents(userInfo: userInfo, urlString: strUrl)
                    SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: str!)
                    break
                    
                default:
                    break
                }
                break
            case .default:
                break
            case .destructive:
                break
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createURLWithComponents(userInfo: StreamDAO, urlString:String) -> String? {
        // create "https://api.nasa.gov/planetary/apod" URL using NSURLComponents
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "Emogo";
        urlComponents.host = "emogo"
        
        // add params
        let fullName = URLQueryItem(name: "fullName", value: userInfo.fullName!)
        let phoneNumber = URLQueryItem(name: "phoneNumber", value: userInfo.phoneNumber!)
        let userProfileID = URLQueryItem(name: "user_profile_id", value: userInfo.userProfileId!)
        let userId = URLQueryItem(name: "userId", value: userInfo.userId!)
        let userImage = URLQueryItem(name: "userImage", value: userInfo.userImage!)
        urlComponents.queryItems = [fullName, phoneNumber, userId, userProfileID,userImage]
        let strURl = "\(urlComponents.url!)/\(kDeepLinkTypePeople)"
        print(strURl)
        return strURl
    }
}

// MARK:- Extension ScrollView delegate
extension HomeViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pagerContent.isHidden = true
        btnFeature.tag = 0
       
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        let threshold   = 100.0
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let diffHeight = contentHeight - contentOffset
        let frameHeight = scrollView.bounds.size.height
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold)
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0)
        if pullRatio >= 1 {
            if self.fectchingStreamData {
                self.footerView?.loadingView.isHidden = false
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = fabs(diffHeight - frameHeight);
        if pullHeight < 1.0 {
            if self.fectchingStreamData {
                self.footerView?.loadingView.isHidden = false
                self.footerView?.loadingView.startLoaderWithAnimation()
                self.collectionStream.reloadData()
                if self.isSearch == false {
//                    if currentStreamType == .People {
//                         self.view.isUserInteractionEnabled = false
//                        self.getUsersList(type: .down)
//                    }else {
                         self.view.isUserInteractionEnabled = false
                         self.getStreamList(type: .down, filter: currentStreamType)
                    //}
                }
                else {
                    if isSearch && !isStreamEnable {
                         self.view.isUserInteractionEnabled = false
                        self.getPeopleGlobleSearch(searchText: (self.searchText.text?.trim())!, type: .down)
                    }
                    else {
                         self.view.isUserInteractionEnabled = false
                        self.getStreamGlobleSearch(searchText: (self.searchText.text?.trim())!, type: .down)
                        
                    }
                }
            }
        }
    }
}

