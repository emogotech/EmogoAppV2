//
//  ProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation

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

    
    var currentMenu: ProfileMenu = .stream {
        
        didSet {
            updateConatiner()
        }
    }
    var imageToUpload:UIImage!
    var fileName:String! = ""

    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
            self.prepareLayouts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureProfileNavigation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        self.title = "Profile"
        AppDelegate.appDelegate.removeOberserver()
        self.imgUser.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profilepicUpload))
        tap.numberOfTapsRequired = 1
        self.imgUser.addGestureRecognizer(tap)
        lblUserName.text = UserDAO.sharedInstance.user.fullName.trim().capitalized
        
        if UserDAO.sharedInstance.user.userImage.trim().isEmpty {
            self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage.trim())
        }
        self.profileCollectionView.dataSource  = self
        self.profileCollectionView.delegate = self
        profileCollectionView.alwaysBounceVertical = true
        HUDManager.sharedInstance.showHUD()
        self.getStreamList(type:.start,filter: .myStream)
        configureLoadMoreAndRefresh()

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
    
    func setCoverImage(image:UIImage) {
        self.imageToUpload = image
        self.imgUser.image = image
        self.fileName =  NSUUID().uuidString + ".png"
    }
    
    
     // MARK: -  Action Methods And Selector
    
    @IBAction func btnActionMenuSelected(_ sender: UIButton) {
       self.updateSegment(selected: sender.tag)
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
    
    
    @objc func profilepicUpload() {
        
        let alert = UIAlertController(title: "Upload Picture", message: "", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            
            self.checkCameraPermission()
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.checkPhotoLibraryPermission()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("Gallery Open")
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.openGallery()
            }
            break
        //handle authorized status
        case .denied :
            print("denied ")
            SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "gallery")
            break
            
        case .restricted:
                
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            print("denied ")
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    let when = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.openGallery()
                    }
                    break
                // as above
                case .denied, .restricted:
                    SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "gallery")
                    break
                // as above
                case .notDetermined:
                    break
                    // won't happen but still
                }
            }
        }
    }
    
    func checkCameraPermission(){
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.openCamera()
            break
        case .denied, .restricted :
            SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "camera")
            break
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    print("camera Open")
                    self.openCamera()
                } else {
                    //access denied
                    SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "camera")
                }
            })
            break
        }
       
    }
    
    
    private func openCamera(){
        if  UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            DispatchQueue.main.async {
                self.topMostController().present(imagePicker, animated: true, completion: nil)
            }
        }else {
            
        }
    }
    
    private func openGallery(){
        if  UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            DispatchQueue.main.async {
                self.topMostController().present(imagePicker, animated: true, completion: nil)
            }
        }else {
            
        }
        
    }
    
    func topMostController() -> UIViewController {
      
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
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
    
    
    
    func getStreamList(type:RefreshType,filter:StreamType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayStream.removeAll()
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
            
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getMyStuff(type:RefreshType){
        if type == .start || type == .up {
            ContentList.sharedInstance.arrayStuff.removeAll()
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
            
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func getColabs(type:RefreshType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayStream.removeAll()
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
            
            self.profileCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    private func profileUpdate(strURL:String){
        
       
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




extension ProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
            if currentMenu == .stuff {
                return ContentList.sharedInstance.arrayStuff.count
            }else {
                return StreamList.sharedInstance.arrayStream.count
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
        let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
        cell.prepareLayouts(stream: stream)
        return cell

        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
            return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentMenu == .stuff {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
            objPreview.seletedImage = content
            objPreview.isEdit = true
            self.navigationController?.push(viewController: objPreview)
        }else {
            let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
            let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
            obj.currentIndex = indexPath.row
            obj.streamType = stream.Title.capitalized
            obj.viewStream = "View"
            ContentList.sharedInstance.objStream = nil
            self.navigationController?.push(viewController: obj)
        }
}
    
}


extension ProfileViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.setCoverImage(image: pickedImage)
        }
    }
    
}
