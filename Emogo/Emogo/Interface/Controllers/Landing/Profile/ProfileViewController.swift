//
//  ProfileViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit


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
  

    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayouts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureProfileNavigation()
         prepareLayout()
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
        self.getStreamList(type:.start,filter: .myStream)
        configureLoadMoreAndRefresh()
        
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        layout.columnCount = 2
        // Collection view attributes
        self.profileCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.profileCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.profileCollectionView.collectionViewLayout = layout
        

    }
    
    func prepareLayout() {
        lblUserName.text = UserDAO.sharedInstance.user.fullName.trim().capitalized
        
        if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
            self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage.trim())
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
    
    @IBAction func btnActionMenuSelected(_ sender: UIButton) {
       self.updateSegment(selected: sender.tag)
    }
    
    @IBAction func btnActionProfileUpdate(_ sender: UIButton) {
        let objUpdate:ProfileUpdateViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileUpdateView) as! ProfileUpdateViewController
        let objPopup = BIZPopupViewController(contentViewController: objUpdate, contentSize:  CGSize(width: 280.0, height: 340.0))
        objPopup?.showDismissButton = false
        self.present(objPopup!, animated: true, completion: nil)
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
    let stream = StreamList.sharedInstance.arrayStream[sender.tag]
    let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
       obj.streamID = stream.ID
     self.navigationController?.push(viewController: obj)
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
        cell.btnEdit.tag = indexPath.row
        cell.btnEdit.addTarget(self, action: #selector(self.btnActionForEdit(sender:)), for: .touchUpInside)
        let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
        cell.prepareLayouts(stream: stream)
        return cell

        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if currentMenu == .stuff {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            return CGSize(width: content.width, height: content.height)
        }else {
            let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
            return CGSize(width: stream.width, height: stream.hieght)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentMenu == .stuff {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
            content.isShowAddStream = true
            content.isEdit = true
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


