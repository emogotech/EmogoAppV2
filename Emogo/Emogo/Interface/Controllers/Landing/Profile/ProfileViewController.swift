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
    @IBOutlet weak var tblMyStuff: UITableView!

    @IBOutlet weak var lblUserName: UILabel!
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
    var arrayTopContent = [TopContent]()
    
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
        tblMyStuff.register(UINib(nibName: "ProfileHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: kHeader_ProfileHeaderView)
        self.profileCollectionView.dataSource  = self
        self.profileCollectionView.delegate = self
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
        
        self.btnStream.setTitleColor(colorSelected, for: .normal)
        self.btnStream.titleLabel?.font = fontSelected
        self.btnColab.setTitleColor(color, for: .normal)
        self.btnColab.titleLabel?.font = font
        self.btnStuff.setTitleColor(color, for: .normal)
        self.btnStuff.titleLabel?.font = font
    }
    
    func prepareLayout() {
        lblUserName.text = "@" + UserDAO.sharedInstance.user.fullName.trim()
        lblUserName.minimumScaleFactor = 1.0
        lblFullName.text =  UserDAO.sharedInstance.user.fullName.trim().capitalized
        lblFullName.minimumScaleFactor = 1.0
        lblWebsite.text = UserDAO.sharedInstance.user.website.trim()
        lblWebsite.minimumScaleFactor = 1.0
        lblLocation.text = UserDAO.sharedInstance.user.location.trim()
        lblLocation.minimumScaleFactor = 1.0
        imgLink.isHidden = false
        imgLocation.isHidden = false

        if UserDAO.sharedInstance.user.location.trim().isEmpty {
            imgLocation.isHidden = true
        }
        if UserDAO.sharedInstance.user.website.trim().isEmpty {
            imgLink.isHidden = true
        }
        //print(UserDAO.sharedInstance.user.userImage.trim())
        self.imgUser.image = #imageLiteral(resourceName: "camera_icon_cover_images")
        if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
        self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage.trim())
        }
        btnContainer.addBorders(edges: [UIRectEdge.top,UIRectEdge.bottom], color: color, thickness: 1)
    }
    
    func updateList(){
        if isEdited {
            HUDManager.sharedInstance.showHUD()
            isEdited = false
            if  self.currentMenu == .stuff {
                self.getMyStuff()
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
                //self?.getMyStuff(type: .up)
            }else {
                self?.getColabs(type: .up)
            }
        }
        self.profileCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            if self?.currentMenu == .stream {
                self?.getStreamList(type:.down,filter: .myStream)
            }else if self?.currentMenu == .stuff {
               // self?.getMyStuff(type: .down)
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
       
        let textToShare = [ "Hey checkout the \(UserDAO.sharedInstance.user.fullName.capitalized)'s profile, \n \(UserDAO.sharedInstance.user.shareURL)via Emogo" ]
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
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
        let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileUpdateView)
        let nav = UINavigationController(rootViewController: obj)
        self.present(nav, animated: true, completion: nil)
    }
    
   
    
    private func updateSegment(selected:Int){
       
        switch selected {
        case 101:
            self.btnStream.setTitleColor(colorSelected, for: .normal)
            self.btnStream.titleLabel?.font = fontSelected
            self.btnColab.setTitleColor(color, for: .normal)
            self.btnColab.titleLabel?.font = font
            self.btnStuff.setTitleColor(color, for: .normal)
            self.btnStuff.titleLabel?.font = font

//            self.btnStream.setImage(#imageLiteral(resourceName: "strems_active_icon"), for: .normal)
//            self.btnColab.setImage(#imageLiteral(resourceName: "collabs_icon"), for: .normal)
//            self.btnStuff.setImage(#imageLiteral(resourceName: "stuff_icon"), for: .normal)
            self.currentMenu = .stream
            break
        case 102:
        
            self.btnStream.setTitleColor(color, for: .normal)
            self.btnColab.setTitleColor(colorSelected, for: .normal)
            self.btnStuff.setTitleColor(color, for: .normal)
            self.btnStream.titleLabel?.font = font
            self.btnColab.titleLabel?.font = fontSelected
            self.btnStuff.titleLabel?.font = font
            self.currentMenu = .colabs
            break
        case 103:
            self.btnStream.setTitleColor(color, for: .normal)
            self.btnColab.setTitleColor(color, for: .normal)
            self.btnStuff.setTitleColor(colorSelected, for: .normal)
            self.btnStream.titleLabel?.font = font
            self.btnColab.titleLabel?.font = font
            self.btnStuff.titleLabel?.font = fontSelected
            self.currentMenu = .stuff
            break
        default:
            break
        }
    }
    
    private func updateConatiner(){
        
        switch currentMenu {
        case .stuff:
            self.profileCollectionView.isHidden = true
            self.tblMyStuff.isHidden = false
            HUDManager.sharedInstance.showHUD()
            self.getMyStuff()
            break
        case .stream:
            self.profileCollectionView.isHidden = false
            self.tblMyStuff.isHidden = true
            HUDManager.sharedInstance.showHUD()
            self.getStreamList(type:.start,filter: .myStream)
            break
        case .colabs:
            self.profileCollectionView.isHidden = false
            self.tblMyStuff.isHidden = true
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
    
    func getStreamList(type:RefreshType,filter:StreamType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayProfileStream.removeAll()
//            let stream = StreamDAO(streamData: [:])
//            stream.isAdd = true
//            StreamList.sharedInstance.arrayProfileStream.insert(stream, at: 0)
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
            
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getMyStuff(){
        APIServiceManager.sharedInstance.apiForGetTopContent { (results, errorMsg) in
            
            HUDManager.sharedInstance.hideHUD()
            
            if (errorMsg?.isEmpty)! {
                self.arrayTopContent = results!
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
            self.profileCollectionView.isHidden = true
            self.tblMyStuff.isHidden = false
            self.tblMyStuff.reloadData()
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
            
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    // MARK: - API
    
    
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




extension ProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout,MyStuffCollectionCellDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return StreamList.sharedInstance.arrayProfileStream.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
       
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_ProfileStreamCell, for: indexPath) as! ProfileStreamCell
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            cell.btnEdit.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(self.btnActionForEdit(sender:)), for: .touchUpInside)
            let stream = StreamList.sharedInstance.arrayProfileStream[indexPath.row]
            cell.prepareLayouts(stream: stream)
            if currentMenu == .stream {
                cell.lblName.text = ""
                cell.lblName.isHidden = true
            }
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
       
        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
            let stream = StreamList.sharedInstance.arrayProfileStream[indexPath.row]
            if stream.isAdd {
                  isEdited = true
                let controller = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView)
                self.navigationController?.push(viewController: controller)
            }else {
                isEdited = true
                var index = 0
                if currentMenu == .stream {
                    let array = StreamList.sharedInstance.arrayProfileStream.filter { $0.isAdd == false }
                    StreamList.sharedInstance.arrayViewStream = array
                    index = indexPath.row - 1
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
    
    func selectedItem(index:Int,content:ContentDAO){
        let content = ContentList.sharedInstance.arrayStuff[index]
        if content.isAdd {
            btnActionForAddContent()
        }else {
            isEdited = true
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isAdd == false }
            ContentList.sharedInstance.arrayContent = array
            if ContentList.sharedInstance.arrayContent.count != 0 {
                let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                objPreview.currentIndex = index
                self.navigationController?.push(viewController: objPreview)
            }
        }
    }
    
}

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.arrayTopContent.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyStuffCollectionCell = tableView.dequeueReusableCell(withIdentifier: kCell_MyStuffCollectionCell, for: indexPath) as! MyStuffCollectionCell
        cell.selectionStyle = .none
        let array = self.arrayTopContent[indexPath.section].Contents
        cell.prepareCellWithData(contents:array)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.tblMyStuff.frame.size.height - 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:ProfileHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kHeader_ProfileHeaderView) as! ProfileHeaderView
         headerView.btnShowMore.addTarget(self, action: #selector(self.btnShowMoreAction(sender:)), for: .touchUpInside)
          let top = self.arrayTopContent[section]

        if top.image == nil {
            headerView.lblTitle.text = top.name
            headerView.iconWidth.constant = 0
            headerView.btnShowMore.tag = section
            headerView.btnIcon.isHidden = true
        }else {
            headerView.lblTitle.text = top.name
            headerView.iconWidth.constant = 50
            headerView.btnShowMore.tag = section
            headerView.btnIcon.setImage(top.image, for: .normal)
            headerView.btnIcon.isHidden = false
        }
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}



