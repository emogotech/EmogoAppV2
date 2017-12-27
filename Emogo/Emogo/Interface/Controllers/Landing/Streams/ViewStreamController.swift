//
//  ViewStreamController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class ViewStreamController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var viewStreamCollectionView: UICollectionView!
    
    // Varibales
    private let headerNib = UINib(nibName: "StreamViewHeader", bundle: Bundle.main)
    var streamType:String!
    var objStream:StreamViewDAO?

    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kNotificationUpdateImageCover)), object: self)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.updateImageAfterEdit), name: NSNotification.Name(rawValue: kNotificationUpdateImageCover), object: nil)
//
        
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }
    
    @objc func updateImageAfterEdit(){
        self.perform(#selector(updateLayOut), with: nil, afterDelay: 0.3)
    }
    
   @objc func updateLayOut(){
    if StreamList.sharedInstance.arrayStream.count != 0 {
        if StreamList.sharedInstance.selectedStream != nil {
        self.getStream(currentStream:StreamList.sharedInstance.selectedStream)
        }
    }
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.prepareNavigation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)
    }
    // MARK: - Prepare Layouts
    func prepareLayouts(){
       
        // Attach datasource and delegate
        self.viewStreamCollectionView.dataSource  = self
        self.viewStreamCollectionView.delegate = self

        if let layout: IOStickyHeaderFlowLayout = self.viewStreamCollectionView.collectionViewLayout as? IOStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 200.0)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: layout.itemSize.height)
            layout.parallaxHeaderAlwaysOnTop = false
            layout.disableStickyHeaders = true
            self.viewStreamCollectionView.collectionViewLayout = layout
        }
        viewStreamCollectionView.alwaysBounceVertical = true
        self.viewStreamCollectionView.register(self.headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader, withReuseIdentifier: kHeader_ViewStreamHeaderView)
    }
    
    func prepareNavigation(){
        
        self.title = streamType
        self.configureNavigationTite()
        // Cancel Button

//        let img1 = UIImage(named: "stream_cross_icon")
//        let btnCancel = UIBarButtonItem(image: img1, style: .plain, target: self, action: #selector(self.btnCancelAction))
//
        // next Button
//        let img = UIImage(named: "forward_icon")
//        let btnNext = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.btnNextAction))
//        self.navigationItem.rightBarButtonItems = [btnNext,btnCancel]
        // previous Button
        let imgP = UIImage(named: "back_icon")
        let btnback = UIBarButtonItem(image: imgP, style: .plain, target: self, action: #selector(self.btnCancelAction))
        self.navigationItem.leftBarButtonItem = btnback
        
//
//        AWSRequestManager.sharedInstance.updateSuccessHandler = { _ in
////            if self.isRefresh == true {
////                self.updateLayOut()
////            }
//        }
        
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kUpdateStreamViewIdentifier), object: nil, queue: nil) { (notification) in
            if StreamList.sharedInstance.selectedStream != nil {
                self.updateLayOut()
            }
        }
        
        self.updateLayOut()
    }
    
    
    
    // MARK: -  Action Methods And Selector
    @objc func deleteStreamAction(sender:UIButton){
        let alert = UIAlertController(title: "Confirmation!", message: "Are you sure, You want to Delete Stream?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "YES", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
           self.deleteStream()
        }
        let no = UIAlertAction(title: "NO", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
   @objc func editStreamAction(sender:UIButton){
    if self.objStream != nil {
        let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
        obj.streamID = self.objStream?.streamID
        self.navigationController?.push(viewController: obj)
    }
}
    
    @objc  func btnCancelAction(){
        let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
        self.navigationController?.popToViewController(vc: obj)
        // self.navigationController?.pop()
    }
/*
   @objc  func btnNextAction(){
    
    if currentIndex == StreamList.sharedInstance.arrayStream.count - 1 {
        current = 0
    }
    else {
        current += 1
    }
    self.prepareList()
    }
    
    @objc  func btnPreviousAction(){
        
        if(self.currentIndex == 0)
        {
            self.currentIndex = StreamList.sharedInstance.arrayStream.count - 1
        }
        else
        {
            self.currentIndex  -= 1
        }
        self.prepareList()
    }
    
   
 
    // MARK: - Class Methods

    func prepareList(){
        print("index---->\(self.currentIndex)")
        if self.currentIndex <= 0 {
            return
        }
        let stream = StreamList.sharedInstance.arrayStream[self.currentIndex!]
        self.getStream(currentStream:stream )
    }
     */

    // MARK: - API Methods

    func getStream(currentStream:StreamDAO){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForViewStream(streamID: currentStream.ID) { (stream, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.objStream = stream
                self.viewStreamCollectionView.reloadData()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    func deleteStream(){
        HUDManager.sharedInstance.showHUD()
     APIServiceManager.sharedInstance.apiForDeleteStream(streamID: (objStream?.streamID)!) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()

            if (errorMsg?.isEmpty)! {
                if let i = StreamList.sharedInstance.arrayStream.index(where: { $0.ID.trim() == StreamList.sharedInstance.selectedStream.ID.trim() }) {
                    StreamList.sharedInstance.arrayStream.remove(at: i)
                }
                self.navigationController?.pop()
              //self.prepareList()
            }else {
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



extension ViewStreamController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if objStream != nil {
            return objStream!.arrayContent.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
         let content = objStream?.arrayContent[indexPath.row]
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.prepareLayout(content:content!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = UICollectionReusableView()
        switch kind {
        case IOStickyHeaderParallaxHeader:
            let  view:StreamViewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_ViewStreamHeaderView, for: indexPath) as! StreamViewHeader
            view.btnDelete.addTarget(self, action: #selector(self.deleteStreamAction(sender:)), for: .touchUpInside)
            view.btnEdit.addTarget(self, action: #selector(self.editStreamAction(sender:)), for: .touchUpInside)
            view.prepareLayout(stream:self.objStream)
            return view
        default:
            assert(false, "Unexpected element kind")
        }
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = objStream?.arrayContent[indexPath.row]
        if content?.isAdd == true {
            let obj:CameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CameraViewController
                kContainerNav = "1"
                currentTag = 111
            ContentList.sharedInstance.objStream = self.objStream
             arraySelectedContent = [ContentDAO]()
             arrayAssests = [ImportDAO]()
            ContentList.sharedInstance.arrayContent.removeAll()
            self.navigationController?.push(viewController: obj)
            //self.navigationController?.push(viewController: obj)
        }else {
                ContentList.sharedInstance.arrayContent.removeAll()
             let array = objStream?.arrayContent.filter { $0.isAdd == false }
             ContentList.sharedInstance.arrayContent = array
             ContentList.sharedInstance.objStream = objStream
              let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                objPreview.currentIndex = indexPath.row - 1
                self.navigationController?.pushNormal(viewController: objPreview)

        }
    }
    
}
