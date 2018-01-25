//
//  ProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import XLActionController


enum ProfileMenu:String{
    case stream = "1"
    case colabs = "2"
    case stuff = "3"
}


class ProfileViewController: UIViewController {
    
    
    // MARK: - UI Elements
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var btnStream: UIButton!
    @IBOutlet weak var btnColab: UIButton!
    @IBOutlet weak var btnStuff: UIButton!
    @IBOutlet weak var lblNOResult: UILabel!
    
    
    var currentMenu: ProfileMenu = .stream {
        
        didSet {
            updateConatiner()
        }
    }
    
    var isEdited:Bool! = false
    var isUpdateList:Bool! = false
    var imageToUpload:UIImage!
    var fileName:String! = ""
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: false, allowResizing: false, allowMoving: false, minimumSize: CGSize.zero)
    }
    
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureProfileNavigation()
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
        profileCollectionView.alwaysBounceVertical = true
        HUDManager.sharedInstance.showHUD()
        kShowOnlyMyStream = "1"
        self.getStreamList(type:.start,filter: .myStream)
        configureLoadMoreAndRefresh()
        
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        layout.columnCount = 2
        // Collection view attributes
        self.profileCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.profileCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.profileCollectionView.collectionViewLayout = layout
        self.prepareLayout()
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kProfileUpdateIdentifier)), object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kProfileUpdateIdentifier), object: nil, queue: nil) { (notification) in
            self.prepareLayout()
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.left
        self.profileCollectionView.addGestureRecognizer(swipeRight)
        
    }
    
    func prepareLayout() {
        lblUserName.text = UserDAO.sharedInstance.user.fullName.trim().capitalized
        lblUserName.minimumScaleFactor = 1.0
        print(UserDAO.sharedInstance.user.userImage.trim())
        self.imgUser.image = #imageLiteral(resourceName: "camera_icon_cover_images")
        if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
        self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage.trim())
        }
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
    
    
    
    
    // MARK: -  Action Methods And Selector
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
           
            case UISwipeGestureRecognizerDirection.left:
               
                self.addLeftTransitionView(subtype: kCATransitionFromRight)
                self.navigationController?.popNormal()
                break
                
            default:
                break
            }
        }
    }
    
    
    @IBAction func btnActionMenuSelected(_ sender: UIButton) {
        self.updateSegment(selected: sender.tag)
    }
    
    @IBAction func btnActionProfileUpdate(_ sender: UIButton) {
        self.updateProfileImage()
    }
    
    func updateProfileImage(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionRemove = UIAlertAction(title: kAlert_RemoveProfile, style: .destructive) { (action) in
            HUDManager.sharedInstance.showHUD()
        
            self.profileUpdate(strURL: "")
        }
        let actionUpdate = UIAlertAction(title: kAlert_UpateProfile, style: .default) { (action) in
            self.profilepicUpload()
        }
        let actionCancel = UIAlertAction(title: kAlert_Cancel_Title, style: .destructive) { (action) in
        }
        
        alert.addAction(actionUpdate)
        if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
            alert.addAction(actionRemove)
        }
        alert.addAction(actionCancel)

        present(alert, animated: true, completion: nil)
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
        
        switch currentMenu {
        case .stuff:
            HUDManager.sharedInstance.showHUD()
            self.getMyStuff(type: .start)
            break
        case .stream:
            HUDManager.sharedInstance.showHUD()
            self.getStreamList(type:.start,filter: .myStream)
            break
        case .colabs:
            
            HUDManager.sharedInstance.showHUD()
            self.getColabs(type: .start)
            break
        }
    }
    
    override func btnLogoutAction() {
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Logout, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
            APIServiceManager.sharedInstance.apiForLogoutUser { (isSuccess, errorMsg) in
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
        let stream = StreamList.sharedInstance.arrayMyStream[sender.tag]
        let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
        obj.streamID = stream.ID
        self.navigationController?.push(viewController: obj)
    }
    
    func getStreamList(type:RefreshType,filter:StreamType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
            let stream = StreamDAO(streamData: [:])
            stream.isAdd = true
            StreamList.sharedInstance.arrayMyStream.insert(stream, at: 0)
            self.profileCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
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
               self.lblNOResult.text  = "No Stream Found"
                 self.lblNOResult.minimumScaleFactor = 1.0
               self.lblNOResult.isHidden = false
            }
            
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getMyStuff(type:RefreshType){
        if type == .start || type == .up {
            ContentList.sharedInstance.arrayStuff.removeAll()
            let content = ContentDAO(contentData: [:])
            content.isAdd = true
            ContentList.sharedInstance.arrayStuff.insert(content, at: 0)
            self.profileCollectionView.reloadData()
        }
        
        APIServiceManager.sharedInstance.apiForGetStuffList(type: type) { (refreshType, errorMsg) in
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
            
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getColabs(type:RefreshType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
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
            if StreamList.sharedInstance.arrayMyStream.count == 0 {
                self.lblNOResult.text  = "No Collabs Found"
                self.lblNOResult.minimumScaleFactor = 1.0
                self.lblNOResult.isHidden = false
            }
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    // MARK: - API
    
    private func uploadProfileImage(){
        HUDManager.sharedInstance.showHUD()
        let image = self.imageToUpload.reduceSize()
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let url = Document.saveFile(data: imageData!, name: self.fileName)
        let fileUrl = URL(fileURLWithPath: url)
        AWSManager.sharedInstance.uploadFile(fileUrl, name: self.fileName) { (imageUrl,error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.profileUpdate(strURL: imageUrl!)
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
    
    
    private func profileUpdate(strURL:String){
        
        APIServiceManager.sharedInstance.apiForUserProfileUpdate(name: UserDAO.sharedInstance.user.fullName, profilePic: strURL) { (isSuccess, errorMsg) in
            
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.prepareLayout()
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func profilepicUpload() {
        
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            if let img = image{
                self?.setCoverImage(image: img)
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
        
    }
    
    func setCoverImage(image:UIImage) {
        self.imageToUpload = image
//        self.imgUser.image = image
        self.fileName =  NSUUID().uuidString + ".png"
        self.uploadProfileImage()
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
            if obj.type == .photo {
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
                    obj.phAsset?.getURL(completionHandler: { (url) in
                        camera.fileUrl = url
                        if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:url!) {
                            camera.imgPreview = image
                            self.updateData(content: camera)
                        }
                        group.leave()
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




extension ProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentMenu == .stuff {
            return ContentList.sharedInstance.arrayStuff.count
        }else {
            return StreamList.sharedInstance.arrayMyStream.count
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
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            cell.btnEdit.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(self.btnActionForEdit(sender:)), for: .touchUpInside)
            let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
            cell.prepareLayouts(stream: stream)
            if currentMenu == .stream {
                cell.lblName.isHidden = true
            }
            return cell
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if currentMenu == .stuff {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            if content.isAdd == true {
                return CGSize(width: #imageLiteral(resourceName: "add_content_icon").size.width, height: #imageLiteral(resourceName: "add_content_icon").size.height)
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
                let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                content.isShowAddStream = true
                content.isEdit = true
                objPreview.seletedImage = content
                objPreview.isForEditOnly = true
                objPreview.isEdit = true
                self.navigationController?.push(viewController: objPreview)
            }
            
        }else {
            let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
            if stream.isAdd {
                  isEdited = true
                let controller = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView)
                self.navigationController?.push(viewController: controller)
            }else {
                isEdited = true
                StreamList.sharedInstance.arrayViewStream = StreamList.sharedInstance.arrayMyStream
                let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                obj.currentIndex = indexPath.row
                obj.viewStream = "fromProfile"
                ContentList.sharedInstance.objStream = nil
                self.navigationController?.push(viewController: obj)
            }
            
        }
    }
    
}


