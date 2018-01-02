//
//  StreamViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 29/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class StreamViewController: MSMessagesAppViewController {
    
    // MARK:- UI Elements
    @IBOutlet weak var lblStreamTitle       : UILabel!
    @IBOutlet weak var lblStreamName        : UILabel!
    @IBOutlet weak var lblStreamDesc        : UILabel!
    
    @IBOutlet weak var btnNextStream        : UIButton!
    @IBOutlet weak var btnPreviousStream    : UIButton!
    @IBOutlet weak var btnCollaborator      : UIButton!
    @IBOutlet weak var btnEdit              : UIButton!
    @IBOutlet weak var btnDelete            : UIButton!
    
    @IBOutlet weak var imgStream            : UIImageView!
    @IBOutlet weak var imgGradient          : UIImageView!
    
    @IBOutlet weak var collectionStreams    : UICollectionView!
    
    // MARK: - Variables
    var lblCount                            : UILabel!
    var arrStream                           = [StreamDAO]()
    var currentStreamIndex                  : Int!
    var hudView                             : LoadingView!
    var objStream                           :StreamViewDAO?
    
    // MARK: - Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: iMsgNotificationManageScreen), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTblData), name: NSNotification.Name(rawValue: iMsgNotificationReloadStreamContent), object: nil)
        
        requestMessageScreenChangeSize()
        
        self.prepareLayout()
    }
    
    // MARK:- Selector Methods
    @objc func requestMessageScreenChangeSize() {
        if(SharedData.sharedInstance.isMessageWindowExpand == false){
            imgGradient.isUserInteractionEnabled = false
        }
        else{
            imgGradient.isUserInteractionEnabled = true
        }
    }
    
    @objc func updateTblData() {
        objStream!.arrayContent = ContentList.sharedInstance.arrayContent
        if objStream!.arrayContent.count == 0{
            self.dismiss(animated: false, completion: nil)
             NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationReloadContenData), object: nil)
        }else{
            self.collectionStreams.reloadData()
        }
    }
    
    // MARK: - PrepareLayout
    func prepareLayout() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imgGradient.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imgGradient.addGestureRecognizer(swipeLeft)
        
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
            self.getStream(type: "Redirect")
        }
        else {
             self.getStream(type: "Direct")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
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
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.itemSize = CGSize(width: self.collectionStreams.frame.size.width/2-15, height: 100)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 10
        collectionStreams!.collectionViewLayout = layout
        
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
                    } else {
                        self.showToastIMsg(type: .error, strMSG: kAlertNetworkErrorMsg)
                    }
                }
                break
                
            case UISwipeGestureRecognizerDirection.right:
                if currentStreamIndex != 0 {
                    if Reachability.isNetworkAvailable() {
                        self.previousImageLoad()
                    } else {
                        self.showToastIMsg(type: .error, strMSG: kAlertNetworkErrorMsg)
                    }
                }
                break
                
            default:
                break
            }
        }
    }
    
    // MARK: - Load Data in UI
    func loadViewForUI() {
        let stream = self.arrStream[currentStreamIndex]
        self.imgStream.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: "stream-card-placeholder")
        self.lblStreamTitle.text = stream.Title
        self.lblStreamName.text = stream.Title
        lblCount.text = ""
        btnCollaborator.isUserInteractionEnabled = false
        lblCount.isHidden = true
        btnEdit.isHidden = true
        btnDelete.isHidden = true
        if objStream?.arrayColab.count != 0 {
            lblCount.text = String(format: "%d", (objStream?.arrayColab.count)!)
            btnCollaborator.isUserInteractionEnabled = true
            lblCount.isHidden = false
        }
        if stream.IDcreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim(){
            btnEdit.isHidden = false
            btnDelete.isHidden = false
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
    }
    
    @IBAction func btnClose(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
        SharedData.sharedInstance.iMessageNavigation = ""
        NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationReloadContenData), object: nil)
    }
    
    func nextImageLoad() {
        if(currentStreamIndex < arrStream.count-1) {
            currentStreamIndex = currentStreamIndex + 1
        }
        btnEnableDisable()
        self.addRightTransitionImage(imgV: self.imgStream)
        getStream(type: "Direct")
    }
    
    func previousImageLoad() {
        if currentStreamIndex != 0{
            currentStreamIndex =  currentStreamIndex - 1
        }
        btnEnableDisable()
        self.addLeftTransitionImage(imgV: self.imgStream)
        getStream(type: "Direct")
    }
    
    @IBAction func btnPreviousAction(_ sender:UIButton) {
        previousImageLoad()
    }
    
    @IBAction func btnAddStreamContent(_ sender: UIButton) {
        
        let alert = UIAlertController(title: iMsgAlertTitle_Confirmation, message: iMsgAlert_ConfirmationDescriptionForAddContent, preferredStyle: .alert)
        let yes = UIAlertAction(title: iMsgAlert_ConfirmationTitle, style: .default) { (action) in
            let strUrl = "\(kDeepLinkURL)\(kDeepLinkTypeAddContent)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let no = UIAlertAction(title: iMsgAlert_CancelTitle, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
       
    }
    
    @IBAction func btnShowCollaborator(_ sender:UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "CollaboratorViewController") as! CollaboratorViewController
        obj.strTitle = "Collaborator List"
        obj.arrCollaborator = objStream?.arrayColab
        self.present(obj, animated: true, completion: nil)
    }
    
    @IBAction func btnEditStream(_ sender:UIButton) {
        let alert = UIAlertController(title: "Confirmation!", message: iMsgAlert_ConfirmationDescriptionForEditStream , preferredStyle: .alert)
        let yes = UIAlertAction(title: "YES", style: .default) { (action) in
            let stream = self.arrStream[self.currentStreamIndex]
            let strUrl = "\(kDeepLinkURL)\(stream.ID!)/\(kDeepLinkTypeEditStream)"
            SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
        }
        let no = UIAlertAction(title: "NO", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnDeleteStream(_ sender:UIButton) {
        let alert = UIAlertController(title: iMsgAlertTitle_Confirmation, message: kAlert_DeleteStreamMsg, preferredStyle: .alert)
        let yes = UIAlertAction(title: iMsgAlert_ConfirmationTitle, style: .default) { (action) in
            let stream = self.arrStream[self.currentStreamIndex]
            APIServiceManager.sharedInstance.apiForDeleteStream(streamID: (stream.ID)!) { (isSuccess, errorMsg) in
                if (errorMsg?.isEmpty)! {
                    self.arrStream.remove(at: self.currentStreamIndex)
                    StreamList.sharedInstance.arrayStream.remove(at:self.currentStreamIndex)
                    if(self.arrStream.count == 0){
                        self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationReloadContenData), object: nil)
                        return
                    }
                    if(self.currentStreamIndex != 0){
                        self.currentStreamIndex = self.currentStreamIndex - 1
                    }
                    self.getStream(type: "Direct")
                } else {
                    self.showToastIMsg(type: .success, strMSG: errorMsg!)
                }
            }
        }
        let no = UIAlertAction(title: iMsgAlert_CancelTitle, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- calling webservice
    @objc func getStream(type:String) {
        if Reachability.isNetworkAvailable() {
            DispatchQueue.main.async {
                self.hudView.startLoaderWithAnimation()
            }
            let stream = self.arrStream[currentStreamIndex]
            if type == "Direct"{
                APIServiceManager.sharedInstance.apiForViewStream(streamID: stream.ID!) { (stream, errorMsg) in
                    if (errorMsg?.isEmpty)! {
                        self.objStream = stream
                        self.lblStreamDesc.text = self.objStream?.description.trim()
                        self.loadViewForUI()
                        self.collectionStreams.reloadData()
                        if self.hudView != nil {
                            self.hudView.stopLoaderWithAnimation()
                        }
                    }
                    else {
                        self.showToastIMsg(type: .success, strMSG: errorMsg!)
                    }
                }
            } else {
                APIServiceManager.sharedInstance.apiForViewStream(streamID: stream.ID!) { (stream, errorMsg) in
                    if (errorMsg?.isEmpty)! {
                        self.objStream = stream
                        if SharedData.sharedInstance.iMessageNavigation == iMsg_NavigationContent {
                            let conntenData = self.objStream?.arrayContent
                            var arrayTempStream  = [StreamDAO]()
                            arrayTempStream.append(SharedData.sharedInstance.streamContent!)
                            self.arrStream = arrayTempStream
                            self.loadViewForUI()
                            for i in 0...(conntenData?.count)!-1 {
                                let data : ContentDAO = conntenData![i]
                                if data.contentID ==  SharedData.sharedInstance.iMessageNavigationCurrentContentID {
                                    let obj : StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
                                    obj.arrContentData = (self.objStream?.arrayContent)!
                                    obj.currentStreamID = self.objStream?.streamID!
                                    obj.currentContentIndex  = i
                                    self.present(obj, animated: false, completion: nil)
                                    
                                    break
                                }
                            }
                        }else if SharedData.sharedInstance.iMessageNavigation == iMsg_NavigationStream{
                            var arrayTempStream  = [StreamDAO]()
                            arrayTempStream.append(SharedData.sharedInstance.streamContent!)
                            self.arrStream = arrayTempStream
                        }
                        self.loadViewForUI()
                        self.collectionStreams.reloadData()
                         if self.hudView != nil {
                            self.hudView.stopLoaderWithAnimation()
                        }
                   }
                    else {
                        self.showToastIMsg(type: .success, strMSG: errorMsg!)
                    }
                }
            }
        }
        else {
            self.showToastIMsg(type: .error, strMSG: kAlertNetworkErrorMsg)
        }
    }
}

// MARK: -  Extension CollcetionView Delegates
extension StreamViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
        cell.prepareLayout(content:content!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let content = objStream?.arrayContent[indexPath.row]
        let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        if content?.isAdd == true {
            return CGSize(width: itemWidth, height: 110)
        }else{
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionStreams.deselectItem(at: indexPath, animated:false)
        
        let obj : StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
        obj.arrContentData = (objStream?.arrayContent)!
        self.addRippleTransition()
        obj.currentStreamID = objStream?.streamID!
        obj.currentContentIndex  = indexPath.row
        self.present(obj, animated: false, completion: nil)
    }
}

