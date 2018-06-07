//
//  StreamViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 29/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages
import Lightbox

class StreamViewController: MSMessagesAppViewController {
    
    // MARK:- UI Elements
    @IBOutlet weak var lblStreamTitle       : UILabel!
    @IBOutlet weak var lblStreamName        : UILabel!
    @IBOutlet weak var lblStreamDesc        : UILabel!
    @IBOutlet weak var lblNoContent        : UILabel!
    
    @IBOutlet weak var btnNextStream        : UIButton!
    @IBOutlet weak var btnPreviousStream    : UIButton!
    @IBOutlet weak var btnCollaborator      : UIButton!
    @IBOutlet weak var btnEdit              : UIButton!
    @IBOutlet weak var btnDelete            : UIButton!
    @IBOutlet weak var btnExpandDesc        : UIButton!
    @IBOutlet weak var btnLike              : UIButton!
    
    @IBOutlet weak var imgStream            : UIImageView!
    @IBOutlet weak var imgGradient          : UIImageView!
    @IBOutlet weak var imgGuesture          : UIImageView!
    
    @IBOutlet weak var collectionStreams    : UICollectionView!
    @IBOutlet weak var lbl_LikeCount        : UILabel!
    @IBOutlet weak var lbl_ViewCount        : UILabel!
    @IBOutlet weak var heightbtnDelete      : NSLayoutConstraint!
    @IBOutlet weak var viewStream           : UIView!
    @IBOutlet weak var btnContainerLikeView : UIView!
    
    // MARK: - Variables
    var lblCount                            : UILabel!
    var arrStream                           = [StreamDAO]()
    var objStream                           : StreamViewDAO?
    var currentIndex                        : Int!
    var currentStreamIndex                  : Int!
    var hudView                             : LoadingView!
    var isViewCount                         : String?
    
    var getImageData : NSMutableArray = NSMutableArray()
    var collectionLayout = CHTCollectionViewWaterfallLayout()
    var selectedIndex:IndexPath?

    
    // MARK: - Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotification_Reload_Stream_Content), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: kNotification_Manage_Screen_Size), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTblData), name: NSNotification.Name(rawValue: kNotification_Reload_Stream_Content), object: nil)
        
        requestMessageScreenChangeSize()
        
        self.prepareLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
         self.apiForIncreaseViewCount()
        
    }
    // MARK:- Selector Methods
    @objc func requestMessageScreenChangeSize() {
        if(SharedData.sharedInstance.isMessageWindowExpand == false){
            imgGradient.isUserInteractionEnabled = false
        }
        else {
            imgGradient.isUserInteractionEnabled = true
        }
    }
    
    @objc func updateTblData() {
        objStream!.arrayContent = ContentList.sharedInstance.arrayContent
        if objStream!.arrayContent.count == 0{
            self.dismiss(animated: false, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Content_Data), object: nil)
        }else{
            if objStream?.likeStatus == "0" {
                self.btnLike.setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
            }else{
                self.btnLike.setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
            }
            self.getStream()
           
        }
    }
    
    // MARK: - PrepareLayout
    func prepareLayout() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imgGuesture.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imgGuesture.addGestureRecognizer(swipeLeft)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        imgGuesture.addGestureRecognizer(swipeDown)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        imgGuesture.addGestureRecognizer(tapRecognizer)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
        self.collectionStreams.addGestureRecognizer(longPressGesture)
        
        if currentStreamIndex == 0 {
            btnPreviousStream.isEnabled = false
            
        }
        if currentStreamIndex == arrStream.count-1 {
            btnNextStream.isEnabled = false
           
        }
        setupLoader()
        self.perform(#selector(setupLabelInCollaboratorButton), with: nil, afterDelay: 0.01)
        self.perform(#selector(setupCollectionProperties), with: nil, afterDelay: 0.01)
        
        if SharedData.sharedInstance.iMessageNavigation != "" {
            self.perform(#selector(setupLabelInCollaboratorButton), with: nil, afterDelay: 0.01)
        }
        self.perform(#selector(getStream), with: nil, afterDelay: 0.01)
        self.lblStreamDesc.numberOfLines = 2
        
        if self.objStream?.likeStatus == "0" {
            self.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
            
        }else{
            self.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        }
       // if isViewCount != nil {
        
        //}
       
    }
    func apiForIncreaseViewCount(){
        if let streamID = ContentList.sharedInstance.objStream {
            APIServiceManager.sharedInstance.apiForIncreaseStreamViewCount(streamID: streamID) { (_, _) in
                
            }
        }
        
    }
    @objc func setupLabelInCollaboratorButton() {
        lblCount = UILabel(frame: CGRect(x: btnCollaborator.frame.size.width-20, y: 0, width: 20, height: 20))
        lblCount.layer.cornerRadius = lblCount.frame.size.width/2
        lblCount.clipsToBounds = true
        lblCount.isHidden = true
        lblCount.textAlignment = NSTextAlignment.center
        lblCount.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        lblCount.font = UIFont.systemFont(ofSize: 10)
        lblCount.text = ""
        lblCount.backgroundColor = #colorLiteral(red: 0, green: 0.6784313725, blue: 0.9843137255, alpha: 0.9048360475)
        self.btnCollaborator.addSubview(lblCount)
    }
    
    @objc func setupCollectionProperties() {
        collectionLayout.minimumColumnSpacing = 8.0
        collectionLayout.minimumInteritemSpacing = 8.0
        collectionLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        collectionLayout.columnCount = 2
        collectionStreams!.collectionViewLayout = collectionLayout
        
        collectionStreams.delegate = self
        collectionStreams.dataSource = self
    }
    
    // MARK:- LoaderSetup
    func setupLoader() {
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if currentStreamIndex !=  arrStream.count-1 {
                    if Reachability.isNetworkAvailable() {
                        self.nextImageLoad()
                        if self.objStream?.likeStatus == "0" {
                            self.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                            
                        }else{
                            self.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                        }
                    } else {
                        self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
                    }
                }
                break
            case UISwipeGestureRecognizerDirection.right:
                if currentStreamIndex != 0 {
                    if Reachability.isNetworkAvailable() {
                        self.previousImageLoad()
                        if self.objStream?.likeStatus == "0" {
                            self.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                            
                        }else{
                            self.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                        }
                    } else {
                        self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
                    }
                }
                break
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
        
                break
            default:
                break
            }
        }
        else {
            self.openFullView()
        }
    }
    
    // MARK: - Load Data in UI
    func loadViewForUI() {
        self.imgStream.setImageWithURL(strImage: (self.objStream?.coverImage.trim())!, placeholder: kPlaceholderImage)
        self.lblStreamTitle.text = ""
        self.lblStreamName.text = ""
        self.lblStreamDesc.text = ""
        self.lblStreamDesc.numberOfLines = 2
        btnExpandDesc.tag = 0
        UIView.animate(withDuration: 0.0) {
            self.lblStreamDesc.text = self.objStream?.description
            self.lblStreamName.text = self.objStream?.title
            self.lblStreamTitle.text = self.objStream?.title
            self.perform(#selector(self.updateExpand), with: nil, afterDelay: 0.1)
            self.lblStreamDesc.minimumScaleFactor = 1.0
            self.lblStreamName.minimumScaleFactor = 1.0
            self.lblStreamTitle.minimumScaleFactor = 1.0
        }
        self.lbl_LikeCount.text = objStream?.totalLikeCount.trim()
        self.lbl_ViewCount.text = objStream?.viewCount.trim()
        lblCount.text = ""
        btnCollaborator.isUserInteractionEnabled = false
        lblCount.isHidden = true
        btnEdit.isHidden = true
        btnDelete.isHidden = true
        heightbtnDelete.constant = 0
        if objStream?.arrayColab.count != 0 {
            lblCount.text = String(format: "%d", (objStream?.arrayColab.count)!)
            btnCollaborator.isUserInteractionEnabled = true
            lblCount.isHidden = false
            btnCollaborator.isHidden = false
        }
        else {
            btnCollaborator.isHidden = true
        }
      
        if self.objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim(){
            btnEdit.isHidden = false
            btnDelete.isHidden = false
            heightbtnDelete.constant = 29
            btnContainerLikeView.isHidden = false
            
        }
      else{
            btnContainerLikeView.isHidden = true
            
        }
    }
    
    @objc func updateExpand(){
        if self.lblStreamDesc.heightOfLbl > self.lblStreamDesc.frame.size.height  {
            if self.lblStreamDesc.isTruncated {
                self.btnExpandDesc.isHidden = false
            }else{
                self.btnExpandDesc.isHidden = true
            }
        }else{
            if self.lblStreamDesc.frame.size.height == 0.0 || self.lblStreamDesc.numberOfVisibleLines < 2{
                self.btnExpandDesc.isHidden = true
            }else{
                self.btnExpandDesc.isHidden = false
            }
        }
    }
    //MARK:- Like Dislike Stream
    
    func likeDislikeStream(){
        let stream = self.arrStream[self.currentStreamIndex]
    
        APIServiceManager.sharedInstance.apiForLikeUnlikeStream(stream: (stream.ID)!, status: (self.objStream?.likeStatus)!) {(count,status, error) in
           
            if (error?.isEmpty)! {
                self.objStream?.likeStatus = status
                self.objStream?.totalLiked = count
                if status == "0" {
                   if let totalLike = self.objStream?.totalLiked.trim(){
                    self.lbl_LikeCount.text = "\(totalLike)"
                   }
                    self.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                }else{
                   if let totalLike = self.objStream?.totalLiked.trim(){
                    self.lbl_LikeCount.text = "\(totalLike)"
                    }
                    self.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                }
                
            }else{
                self.showToastIMsg(type: .success, strMSG: error!)
                
            }
        }
    }
    
    // MARK: - Enable/Disable - Next/Previous Button
    func btnEnableDisable() {
        if currentStreamIndex ==  0 {
            btnPreviousStream.isEnabled = false
        }
        else {
            btnPreviousStream.isEnabled = true
        }
        if currentStreamIndex ==  arrStream.count-1 {
            btnNextStream.isEnabled = false
        }
        else {
            btnNextStream.isEnabled = true
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnNextAction(_ sender:UIButton) {
        nextImageLoad()
        if self.objStream?.likeStatus == "0" {
            self.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
            
        }else{
            self.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        }
    }
    
    @IBAction func btnLikeAction(_ sender: Any) {
        
        if self.objStream?.likeStatus == "0" {
            self.objStream?.likeStatus = "1"
        }else{
            self.objStream?.likeStatus = "0"
        }
        self.likeDislikeStream()
    }
    
    @IBAction func btnCollapseExpand(_ sender:UIButton) {
        if sender.tag == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.btnExpandDesc.transform = self.btnExpandDesc.transform.rotated(by: -CGFloat(Double.pi))
                self.lblStreamDesc.numberOfLines = 4
                sender.isSelected =  true
                sender.tag = 1
            })
        }
        else {
            UIView.animate(withDuration: 0.5, animations: {
                self.btnExpandDesc.transform = self.btnExpandDesc.transform.rotated(by: -CGFloat(Double.pi))
                sender.isSelected =  false
                self.lblStreamDesc.numberOfLines = 2
                sender.tag = 0
            })
        }
    }
    
    @IBAction func btnClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
        SharedData.sharedInstance.iMessageNavigation = ""
        NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Content_Data), object: nil)
    }
    
    func nextImageLoad() {
        lblStreamTitle.text = ""
        lblStreamName.text = ""
        lblStreamDesc.text = ""
        btnEdit.isHidden = true
        btnCollaborator.isHidden = true
        
        imgStream.image = UIImage(named: kPlaceholderImage)
        
        if(currentStreamIndex < arrStream.count-1) {
            currentStreamIndex = currentStreamIndex + 1
        }
        
        btnEnableDisable()
        self.addRightTransitionImage(imgV: self.imgStream)
        getStream()
    }
    
    func previousImageLoad() {
        lblStreamTitle.text = ""
        lblStreamName.text = ""
        lblStreamDesc.text = ""
        btnEdit.isHidden = true
        btnCollaborator.isHidden = true
        
        imgStream.image = UIImage(named: kPlaceholderImage)
        if currentStreamIndex != 0{
            currentStreamIndex =  currentStreamIndex - 1
        }
        btnEnableDisable()
        self.addLeftTransitionImage(imgV: self.imgStream)
        getStream()
    }
    
    @IBAction func btnPreviousAction(_ sender:UIButton) {
        previousImageLoad()
        if self.objStream?.likeStatus == "0" {
            self.btnLike .setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
            
        }else{
            self.btnLike .setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
        }
    }
    
    @IBAction func btnAddStreamContent(_ sender: UIButton) {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Add_Content, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            let streamID : String = (self.objStream?.streamID!)!
            let strUrl = "\(kDeepLinkURL)\(streamID)/\(kDeepLinkTypeAddContent)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnShowCollaborator(_ sender:UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: iMsgSegue_Collaborator) as! CollaboratorViewController
        obj.strTitle = kCollaobatorList
        obj.arrCollaborator = objStream?.arrayColab
        self.present(obj, animated: true, completion: nil)
    }
    
    @IBAction func btnEditStream(_ sender:UIButton) {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Confirmation_Description_For_Edit_Stream , preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            let stream = self.arrStream[self.currentStreamIndex]
            let strUrl = "\(kDeepLinkURL)\(stream.ID!)/\(kDeepLinkTypeEditStream)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnDeleteStream(_ sender:UIButton) {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Delete_Stream_Msg, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
            let stream = self.arrStream[self.currentStreamIndex]
            APIServiceManager.sharedInstance.apiForDeleteStream(streamID: (stream.ID)!) { (isSuccess, errorMsg) in
                if (errorMsg?.isEmpty)! {
                    self.arrStream.remove(at: self.currentStreamIndex)
                    StreamList.sharedInstance.arrayStream.remove(at:self.currentStreamIndex)
                    if(self.arrStream.count == 0){
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(kNotification_Reload_Content_Data), object: nil)
                        return
                    }
                    if(self.currentStreamIndex != 0){
                        self.currentStreamIndex = self.currentStreamIndex - 1
                    }
                    self.getStream()
                } else {
                    self.showToastIMsg(type: .success, strMSG: errorMsg!)
                }
            }
        }
        let no = UIAlertAction(title: kAlert_Cancel_Title, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func openFullView(){
        var arrayContents = [LightboxImage]()
        let arrayTemp = [self.objStream]
        let text = (self.objStream?.title!)! + "\n" +  (self.objStream?.description!)!
        for obj in arrayTemp {
            var image:LightboxImage!
            if obj?.coverImage != nil {
                image = LightboxImage(image: imgStream.image!, text: text.trim(), videoURL: nil)
            }else{
                let url = URL(string: (obj?.coverImage)!)
                if url != nil {
                    image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: nil)
                }
            }
            if image != nil {
                arrayContents.append(image)
            }
        }
        
        let controller = LightboxController(images: arrayContents, startIndex: 0)
        controller.dynamicBackground = true
        if arrayContents.count != 0 {
            present(controller, animated: true, completion: nil)
        }
    }
    
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        if self.objStream?.idCreatedBy.trim() != UserDAO.sharedInstance.user.userId.trim() {
            return
        }
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionStreams.indexPathForItem(at: gesture.location(in: self.collectionStreams)) else {
                break
            }
            selectedIndex = nil
            collectionStreams.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionStreams.updateInteractiveMovementTargetPosition(gesture.location(in: self.collectionStreams))
            
        case UIGestureRecognizerState.ended:
            collectionStreams.endInteractiveMovement()
            selectedIndex = nil
        default:
            collectionStreams.cancelInteractiveMovement()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- calling webservice
    @objc func getStream() {
        if Reachability.isNetworkAvailable() {
            DispatchQueue.main.async {
                self.hudView.startLoaderWithAnimation()
            }
            let stream = self.arrStream[currentStreamIndex]
            
            APIServiceManager.sharedInstance.apiForViewStream(streamID: stream.ID!) { (stream, errorMsg) in
                if (errorMsg?.isEmpty)! {
                    self.objStream = stream
                    if SharedData.sharedInstance.iMessageNavigation == kNavigation_Content {
                        let conntenData = self.objStream?.arrayContent
                        var arrayTempStream  = [StreamDAO]()
                        arrayTempStream.append(SharedData.sharedInstance.streamContent!)
                        self.arrStream = arrayTempStream
                        self.loadViewForUI()
                        var isNavigateContent = false
                        for i in 0...(conntenData?.count)!-1 {
                            let data : ContentDAO = conntenData![i]
                            if data.contentID ==  SharedData.sharedInstance.iMessageNavigationCurrentContentID {
                                let obj : StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
                                obj.arrContentData = (self.objStream?.arrayContent)!
                                obj.currentStreamID = self.objStream?.streamID!
                                obj.currentContentIndex  = i
                                obj.currentStreamTitle = self.objStream?.title
                                self.present(obj, animated: false, completion: nil)
                                isNavigateContent = true
                                break
                            }
                        }
                        if !isNavigateContent {
                            self.showToastIMsg(type: .error, strMSG: kAlert_Content_Not_Found)
                        }
                        
                    }else if SharedData.sharedInstance.iMessageNavigation == kNavigation_Stream{
                        var arrayTempStream  = [StreamDAO]()
                        arrayTempStream.append(SharedData.sharedInstance.streamContent!)
                        self.arrStream = arrayTempStream
                    }
                    
                    if self.objStream!.arrayContent.count == 0 {
                        self.lblNoContent.isHidden = false
                    }else{
                        self.lblNoContent.isHidden = true
                    }
                    if self.objStream!.likeStatus == "0" {
                        self.btnLike.setImage(#imageLiteral(resourceName:                  "Unlike_icon"), for: .normal)
                    }else{
                        self.btnLike.setImage(#imageLiteral(resourceName: "like_icon"), for: .normal)
                    }
                    self.loadViewForUI()
                    self.collectionStreams.reloadData()
                    if self.hudView != nil {
                        self.hudView.stopLoaderWithAnimation()
                    }
                }
                else if errorMsg == APIStatus.NotFound.rawValue{
                    self.showToastIMsg(type: .error, strMSG: kAlert_Stream_Not_Found)
                }else{
                    self.showToastIMsg(type: .error, strMSG: errorMsg!)
                }
            }
        }
        else {
            self.showToastIMsg(type: .error, strMSG: kAlert_Network_ErrorMsg)
        }
    }
    
    func reorderContent(orderArray:[ContentDAO]) {
        
        APIServiceManager.sharedInstance.apiForReorderStreamContent(orderArray: orderArray, streamID: (self.objStream?.streamID)!) { (isSuccess,errorMSG)  in

            if self.hudView != nil {
                self.hudView.stopLoaderWithAnimation()
            }
            
            if (errorMSG?.isEmpty)! {
                self.selectedIndex = nil
                self.collectionStreams.reloadData()
            }
        }
    }
    
    
}

// MARK: -  Extension CollcetionView Delegates
extension StreamViewController : UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let content = objStream?.arrayContent[indexPath.row]
        if content?.isAdd == true {
            return CGSize(width: #imageLiteral(resourceName: "add_content_icon").size.width, height: #imageLiteral(resourceName: "add_content_icon").size.height)
        }
        if selectedIndex != nil {
            let tempContent = objStream?.arrayContent[selectedIndex!.row]
            return CGSize(width: (tempContent?.width)!, height: (tempContent?.height)!)
        }
        return CGSize(width: (content?.width)!, height: (content?.height)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if objStream != nil {
            return objStream!.arrayContent.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : StreamCollectionViewCell = self.collectionStreams.dequeueReusableCell(withReuseIdentifier: iMgsSegue_StreamCollection, for: indexPath) as! StreamCollectionViewCell
        let content = objStream?.arrayContent[indexPath.row]
        
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.prepareLayout(content:content!)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionStreams.deselectItem(at: indexPath, animated:false)
        
        let obj : StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
        
        obj.arrContentData = (objStream?.arrayContent)!
        
        self.addRippleTransition()
        obj.currentStreamID = objStream?.streamID!
        obj.currentContentIndex  = indexPath.row
        obj.currentStreamTitle = lblStreamTitle.text
        self.present(obj, animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if destinationIndexPath.row == 0 {
            return
        }
        let contentDest = objStream?.arrayContent[sourceIndexPath.row]
        objStream?.arrayContent.remove(at: sourceIndexPath.row)
        objStream?.arrayContent.insert(contentDest!, at: destinationIndexPath.row)
        DispatchQueue.main.async {
            self.collectionStreams.reloadItems(at: [destinationIndexPath,sourceIndexPath])
                self.hudView.startLoaderWithAnimation()
            self.reorderContent(orderArray: (self.objStream?.arrayContent)!)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        if proposedIndexPath.row == 0 {
            return originalIndexPath
        }else {
            return proposedIndexPath
        }
    }

    
    @objc func btnPlayAction(sender:UIButton){
        var index : Int = 0
        if (self.objStream?.canAddContent)! {
          index   = sender.tag - 1
        }else {
            index = sender.tag
        }
        
        let array = objStream?.arrayContent.filter { $0.isAdd == false }
        let seletedImage = array![index]
        let videoUrl = URL(string: (seletedImage.coverImage)!)
        LightboxConfig.handleVideo(self, videoUrl!)
        
    }
    
    func openFullView(index:Int?){
        var arrayContents = [LightboxImage]()
     
            let array = objStream?.arrayContent.filter { $0.isAdd == false }
            for obj in array! {
                var image:LightboxImage!
                if obj.type == .image {
                    if obj.imgPreview != nil {
                        image = LightboxImage(image: obj.imgPreview!, text: obj.name, videoURL: nil)
                    }else{
                        let url = URL(string: obj.coverImage)
                        if url != nil {
                            image = LightboxImage(imageURL: url!, text: obj.name, videoURL: nil)
                        }
                    }
                }else if obj.type == .video {
                    if obj.imgPreview != nil {
                        image = LightboxImage(image: obj.imgPreview!, text: obj.name, videoURL: obj.fileUrl)
                    }else {
                        let url = URL(string: obj.coverImage)
                        let videoUrl = URL(string: obj.coverImage)
                        image = LightboxImage(imageURL: url!, text: obj.name, videoURL: videoUrl!)
                    }
                }
                if image != nil {
                    arrayContents.append(image)
                }
            }
        
        
        if (self.objStream?.canAddContent)! {
            let controller = LightboxController(images: arrayContents, startIndex: index! - 1)
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            }
        }else {
            let controller = LightboxController(images: arrayContents, startIndex: index!)
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            }
        }
    }
}

