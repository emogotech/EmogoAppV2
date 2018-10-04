//
//  MyStreamViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Lightbox
import GSKStretchyHeaderView
import Haptica

var isAssignProfile:String? = nil

class MyStreamViewController: UIViewController {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var myStreamCollectionView: UICollectionView!
    @IBOutlet weak var lblNoResult: UILabel!
    @IBOutlet weak var btnDone: UIButton!


    // MARK: - Variables
    var currentType:RefreshType! = .start
    var objContent:ContentDAO!
    var streamID:String?
    let fontSegment = UIFont(name: "SFProDisplay-Bold", size: 15.0)
    var selectedType:StreamType! = StreamType.Emogo
    var stretchyHeader: MyStreamHeaderView!
    var lastSelectedIndex:IndexPath?
    var arraySelected = [StreamDAO]()
    var layout = CHTCollectionViewWaterfallLayout()
    
    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isAssignProfile == nil {
            self.navigationController?.isNavigationBarHidden = true
        }else {
            self.configureNavigationWithTitle()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        
        // Attach datasource and delegate
      //  self.navigationController?.isNavigationBarHidden = false
        self.myStreamCollectionView.dataSource  = self
        self.myStreamCollectionView.delegate = self
      //  self.configureNewNavigation()
       
        // Change individual layout attributes for the spacing between cells

        layout.minimumColumnSpacing = 13.0
        layout.minimumInteritemSpacing = 13.0
        layout.sectionInset = UIEdgeInsetsMake(12, 13, 0, 13)
        layout.columnCount = 2
        
        // Collection view attributes
        self.myStreamCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.myStreamCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.myStreamCollectionView.collectionViewLayout = layout
        
         kShowOnlyMyStream = "1"
          self.getMyStreams(type:.start,filter: .Emogo)
        // Load More
        configureLoadMoreAndRefresh()
        if isAssignProfile == nil {
            ContentList.sharedInstance.arrayToCreate.removeAll()
            if objContent == nil {
                ContentList.sharedInstance.arrayToCreate = ContentList.sharedInstance.arrayContent
            }else{
                ContentList.sharedInstance.arrayToCreate.insert(objContent, at: 0)
            }
            self.configureStrechyHeader()
            
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            self.myStreamCollectionView.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            self.myStreamCollectionView.addGestureRecognizer(swipeLeft)
        }
      
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                
               if selectedType == .Emogo  {
                    if  self.stretchyHeader.segmentControl != nil {
                        self.stretchyHeader.segmentControl.selectedSegmentIndex = 1
                    }
                 Animation.addRightTransition(collection: self.myStreamCollectionView)
                 self.updateStuffList(index: 1)
               }
                break
                case UISwipeGestureRecognizerDirection.right:
                   if  selectedType == .Collab {
                        if  self.stretchyHeader.segmentControl != nil {
                            self.stretchyHeader.segmentControl.selectedSegmentIndex = 0
                            
                        }
                        Animation.addLeftTransition(collection: self.myStreamCollectionView)
                        self.updateStuffList(index: 0)
                   }
                 break
            default:
                 break
            }
        }
        
    }
    /*
    func configureNewNavigation(){
       
        //  let imgP = UIImage(named: "back_icon_stream")
        let imgP = UIImage(named: "back_icon")
        let btnback = UIBarButtonItem(image: imgP, style: .plain, target: self, action: #selector(self.btnCancelAction))
        self.navigationItem.leftBarButtonItem = btnback
    }
    @objc  func btnCancelAction(){
       
            self.navigationController?.popViewController(animated: true)
            //   self.navigationController?.pop()
        
    }*/
    
    
    func configureStrechyHeader(){
        let nibViews = Bundle.main.loadNibNamed("MyStreamHeaderView", owner: self, options: nil)
        self.stretchyHeader = nibViews?.first as! MyStreamHeaderView
        self.myStreamCollectionView.addSubview(self.stretchyHeader)
        if self.objContent != nil {
            self.stretchyHeader.prepareLayout(contents: ContentList.sharedInstance.arrayToCreate)
        }else {
            self.stretchyHeader.prepareLayout(contents: ContentList.sharedInstance.arrayToCreate)
        }
        
        self.stretchyHeader.btnBack.addTarget(self, action: #selector(self.backButtonAction(sender:)), for: .touchUpInside)
        self.stretchyHeader.sliderDelegate = self
       
        
        // Segment control Configure
        
        self.stretchyHeader.segmentControl.sectionTitles = ["Emogos", "Collabs"]
        self.stretchyHeader.segmentControl.indexChangeBlock = {(_ index: Int) -> Void in
            print("Selected index \(index) (via block)")
            self.updateStuffList(index: index)
        }
        
        self.stretchyHeader.segmentControl.selectionIndicatorHeight = 1.0
        self.stretchyHeader.segmentControl.backgroundColor =  UIColor(r: 245, g: 245, b: 245)
        self.stretchyHeader.segmentControl.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 155, g: 155, b: 155),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 15.0)]
        self.stretchyHeader.segmentControl.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
        self.stretchyHeader.segmentControl.selectedTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 74, g: 74, b: 74),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 15.0)]
        self.stretchyHeader.segmentControl.selectionStyle = .textWidthStripe
        self.stretchyHeader.segmentControl.selectedSegmentIndex = 0
        self.stretchyHeader.segmentControl.selectionIndicatorLocation = .down
        self.stretchyHeader.segmentControl.shouldAnimateUserSelection = false
    }
    
    func configureLoadMoreAndRefresh(){
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.myStreamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
           
            self?.getMyStreams(type:.down,filter: .Emogo)
            
        }
        self.myStreamCollectionView.expiredTimeInterval = 20.0
    }
    func updateStuffList(index:Int){
        switch index {
        case 0:
            layout.sectionInset = UIEdgeInsetsMake(13, 13, 0, 13)
            self.selectedType = .Emogo
            self.getMyStreams(type: .start, filter: .Emogo)
            
            break
        case 1:
            self.selectedType = .Collab
            layout.sectionInset = UIEdgeInsetsMake(13, 13, 0, 13)
            self.getColabStreams(type: .start)
            break
            
        default:
            self.selectedType = .Emogo
            
        }
      
        
    }
    
    
    // MARK: -  Action Methods And Selector
    
    @IBAction func btnActionDone(_ sender: Any) {
        if isAssignProfile != nil  {
            assignProfileStream()
        }else {
            var streamID  = [String]()
            for stream in self.arraySelected {
                if stream.isSelected == true {
                    streamID.append(stream.ID.trim())
                }
            }
            if streamID.count == 0 {
                self.showToast(strMSG: kAlert_Select_Stream)
                return
            }else {
                self.associateContentToStream(id: streamID)
            }
        }
      
    }
    @objc func backButtonAction(sender:UIButton){
         isAssignProfile = nil
        self.navigationController?.pop()
    }

    

    // MARK: - Class Methods
    func openFullView(index:Int){
        var arrayContents = [LightboxImage]()
       
        for obj in  ContentList.sharedInstance.arrayToCreate {
            var image:LightboxImage!
            let text = obj.name.trim() + "\n" +  obj.description.trim()
            if obj.type == .image {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: text.trim(), videoURL: nil)
                }else{
                    let url = URL(string: obj.coverImage)
                    if url != nil {
                        image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: nil)
                    }
                }
            }else if obj.type == .video {
                if obj.imgPreview != nil {
                    image = LightboxImage(image: obj.imgPreview!, text: text.trim(), videoURL: obj.fileUrl)
                }else {
                    let url = URL(string: obj.coverImageVideo)
                    let videoUrl = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: videoUrl!)
                }
            }
            if image != nil {
                arrayContents.append(image)
            }
        }
        if arrayContents.count != 0 {
            let controller = LightboxController(images: arrayContents, startIndex: index)
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - API Methods
    
    func getMyStreams(type:RefreshType,filter:StreamType){
        if type == .start || type == .up {
            HUDManager.sharedInstance.showHUD()
            StreamList.sharedInstance.arrayMyStream.removeAll()
            let stream = StreamDAO(streamData: [:])
            stream.isAdd = true
            stream.canAddContent = true
            StreamList.sharedInstance.arrayMyStream.insert(stream, at: 0)
            self.myStreamCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
           
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.myStreamCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.myStreamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.myStreamCollectionView.es.stopLoadingMore()
            }
            
            self.lblNoResult.isHidden = true
            self.btnDone.isUserInteractionEnabled = true
            if StreamList.sharedInstance.arrayMyStream.count == 1 {
              //  self.lblNoResult.isHidden = false
                self.btnDone.isUserInteractionEnabled = false
                }
            self.currentType = refreshType
            if self.streamID != nil {
                if let index =   StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == self.streamID?.trim()}) {
                    StreamList.sharedInstance.arrayMyStream.remove(at: index)
                }
            }
            
            if self.arraySelected.count != 0 {
                for (index,obj) in StreamList.sharedInstance.arrayMyStream.enumerated() {
                    
                    if self.arraySelected.contains(where: {$0.ID.trim() == obj.ID.trim()}) {
                        let stream = obj
                        stream.isSelected = true
                        StreamList.sharedInstance.arrayMyStream[index] = stream
                    }
                }
            }
            let array =   StreamList.sharedInstance.arrayMyStream.filter { $0.canAddContent == true }
            
            if array.count == 0 {
                self.lblNoResult.isHidden =  false
                self.lblNoResult.text = "No Emogo Found"
                self.btnDone.isHidden =  true
            }
            self.btnDone.isHidden = false
             StreamList.sharedInstance.arrayMyStream = array
            self.myStreamCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    //MARK:- Get Collab List
    
    
    func getColabStreams(type:RefreshType){
        if type == .start || type == .up {
            HUDManager.sharedInstance.showHUD()
            StreamList.sharedInstance.arrayMyStream.removeAll()
            self.myStreamCollectionView.reloadData()
        }
        
        APIServiceManager.sharedInstance.apiForGetMyStreamCollabList(type: type) { (refreshType, errorMsg) in
            
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.myStreamCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.myStreamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.myStreamCollectionView.es.stopLoadingMore()
            }
            
            self.btnDone.isUserInteractionEnabled = true
            if StreamList.sharedInstance.arrayMyStream.count == 0 {
                self.btnDone.isHidden = true
                self.btnDone.isUserInteractionEnabled = false
            }
            self.btnDone.isHidden = false
            self.currentType = refreshType
            if self.streamID != nil {
                if let index =   StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == self.streamID?.trim()}) {
                    StreamList.sharedInstance.arrayMyStream.remove(at: index)
                }
            }
            if self.arraySelected.count != 0 {
                for (index,obj) in StreamList.sharedInstance.arrayMyStream.enumerated() {
                    
                    if self.arraySelected.contains(where: {$0.ID.trim() == obj.ID.trim()}) {
                        let stream = obj
                        stream.isSelected = true
                        StreamList.sharedInstance.arrayMyStream[index] = stream
                    }
                }
            }
            
            let array =   StreamList.sharedInstance.arrayMyStream.filter { $0.canAddContent == true }
            
            if array.count == 0 {
                self.lblNoResult.isHidden =  false
                self.lblNoResult.text = "No Emogo Found"
                self.btnDone.isHidden =  true
            }
            
            StreamList.sharedInstance.arrayMyStream = array
            self.myStreamCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
            
        }
        
    }
    func associateContentToStream(id:[String]){
        if self.objContent != nil {
         HUDManager.sharedInstance.showHUD()
            AWSRequestManager.sharedInstance.associateContentToStream(streamID: id, contents: ContentList.sharedInstance.arrayToCreate, completion: { (isScuccess, errorMSG) in
                HUDManager.sharedInstance.hideProgress()
                HUDManager.sharedInstance.hideHUD()
                if (errorMSG?.isEmpty)! {
                    self.navigationController?.pop()
                }
            })
            
        }else {
            if ContentList.sharedInstance.arrayContent.count != 0 {
                HUDManager.sharedInstance.showProgress()
                let array = ContentList.sharedInstance.arrayToCreate
                AWSRequestManager.sharedInstance.associateContentToStream(streamID: id, contents: array!, completion: { (isScuccess, errorMSG) in
                    HUDManager.sharedInstance.hideProgress()
                    if (errorMSG?.isEmpty)! {
                    }
                })
                
                let when = DispatchTime.now() + 1.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    let objStream = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
                    self.navigationController?.popToViewController(vc: objStream)
                }
                ContentList.sharedInstance.arrayToCreate.removeAll()
                ContentList.sharedInstance.arrayContent.removeAll()
            }
        }
    }
    
    func assignProfileStream(){
        
        let index = StreamList.sharedInstance.arrayMyStream.index(where: {$0.isSelected == true})
        if index == nil {
            self.showToast(strMSG: kAlert_Select_Stream_For_Assign)
            return
        }
        HUDManager.sharedInstance.showHUD()
        let stream = StreamList.sharedInstance.arrayMyStream[index!]
        APIServiceManager.sharedInstance.apiForAssignProfileStream(streamID: stream.ID) { (isUpdated, errorMSG) in
         HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.showToast(strMSG: kAlert_ProfileStreamAdded)
                isAssignProfile = nil
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.navigationController?.popToViewController(vc: obj)
            }else {
                self.showToast(strMSG: errorMSG!)
            }
        }
    }
    
    func actionForAddStream(){
        
        if kDefault?.bool(forKey: kHapticFeedback) == true{
            Haptic.impact(.light).generate()
        }else{
            
        }
        let createVC : CreateStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CreateStreamView) as! CreateStreamController
        createVC.exestingNavigation = self.navigationController
        createVC.isAddContent = true
        let nav = UINavigationController(rootViewController: createVC)
        customPresentViewController(PresenterNew.CreateStreamPresenter, viewController: nav, animated: true, completion: nil)
    }
    
    func gifPreview(content:ContentDAO){
        let obj:ShowPreviewViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ShowPreviewView) as! ShowPreviewViewController
        obj.objContent = content
        self.present(obj, animated: false, completion: nil)
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


extension MyStreamViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return StreamList.sharedInstance.arrayMyStream.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_MyStreamCell, for: indexPath) as! MyStreamCell
        // for Add Content
        let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
        cell.prepareLayout(stream: stream)
      //  cell.imgCover.setImageWithURL(strImage: self.objContent.coverImage, placeholder: kPlaceholderImage)
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            let itemWidth = collectionView.bounds.size.width/2.0
            return CGSize(width: itemWidth, height: itemWidth - 23*kScale)
    }
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
        if stream.isAdd  {
            actionForAddStream()
        }else {
            if isAssignProfile == nil {
                if let cell = self.myStreamCollectionView.cellForItem(at: indexPath) {
                    let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
                    stream.isSelected = !stream.isSelected
                    StreamList.sharedInstance.arrayMyStream[indexPath.row] = stream
                    if stream.isSelected {
                        (cell as! MyStreamCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
                       
                    }else {
                        (cell as! MyStreamCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
                        
                    }
                    if  let index = self.arraySelected.index(where: {$0.ID.trim() == stream.ID.trim()}) {
                        self.arraySelected.remove(at: index)
                    }else {
                        self.arraySelected.insert(stream, at: 0)
                    }

                }
            }else {
                if let cell = self.myStreamCollectionView.cellForItem(at: indexPath) {
                    
                    let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
                    stream.isSelected = !stream.isSelected
                    StreamList.sharedInstance.arrayMyStream[indexPath.row] = stream
                    if stream.isSelected {
                        (cell as! MyStreamCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
                    }else {
                        (cell as! MyStreamCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
                    }
                    if lastSelectedIndex != nil {
                        if lastSelectedIndex?.row != indexPath.row {
                            let lastStream = StreamList.sharedInstance.arrayMyStream[(lastSelectedIndex?.row)!]
                            lastStream.isSelected = false
                            self.myStreamCollectionView.reloadItems(at: [lastSelectedIndex!])
                        }
                    }
                    if  let index = self.arraySelected.index(where: {$0.ID.trim() == stream.ID.trim()}) {
                        self.arraySelected.remove(at: index)
                    }else {
                        self.arraySelected.insert(stream, at: 0)
                    }

                    lastSelectedIndex = indexPath
                }
            }
           
        }
    }
}



extension MyStreamViewController:MyStreamHeaderViewDelegate {
    func selected(index: Int, content: ContentDAO) {
        if content.type == .gif {
            self.gifPreview(content: content)
            return
        }
        if content.type == .link {
            guard let url = URL(string: content.coverImage) else {
                return //be safe
            }
            self.openURL(url: url)
        }else {
            self.openFullView(index:index)
        }
    }
    
   
}
