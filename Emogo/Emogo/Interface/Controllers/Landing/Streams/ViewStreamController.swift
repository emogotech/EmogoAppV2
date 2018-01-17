//
//  ViewStreamController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Lightbox

class ViewStreamController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var viewStreamCollectionView: UICollectionView!
    
    // Varibales
    private let headerNib = UINib(nibName: "StreamViewHeader", bundle: Bundle.main)
    var streamType:String!
    var objStream:StreamViewDAO?
    var currentIndex:Int!
    var viewStream:String?

    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kNotification_Update_Image_Cover)), object: self)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.updateImageAfterEdit), name: NSNotification.Name(rawValue: kNotification_Update_Image_Cover), object: nil)
//
        
        // Do any additional setup after loading the view.
        self.viewStreamCollectionView.accessibilityLabel = "ViewStreamCollectionView"
        self.prepareLayouts()
    }
    
    @objc func updateImageAfterEdit(){
        self.perform(#selector(updateLayOut), with: nil, afterDelay: 0.3)
    }
    
   @objc func updateLayOut(){
    if ContentList.sharedInstance.objStream != nil {
        self.getStream(currentStream:nil,streamID:ContentList.sharedInstance.objStream)
    }else {
        if StreamList.sharedInstance.arrayStream.count != 0 {
            if currentIndex != nil {
                let stream =  StreamList.sharedInstance.arrayStream[currentIndex]
                StreamList.sharedInstance.selectedStream = stream
            }
            if StreamList.sharedInstance.selectedStream != nil {
                self.getStream(currentStream:StreamList.sharedInstance.selectedStream)
            }
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

        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        layout.columnCount = 2
        layout.headerHeight = 200.0
        
        // Collection view attributes
        self.viewStreamCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.viewStreamCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.viewStreamCollectionView.collectionViewLayout = layout
        
        self.viewStreamCollectionView.register(self.headerNib, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: kHeader_ViewStreamHeaderView)
        
        if currentIndex != nil {
            viewStreamCollectionView.isUserInteractionEnabled = true
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            viewStreamCollectionView.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            viewStreamCollectionView.addGestureRecognizer(swipeLeft)
        }
       
    }
    
    func prepareNavigation(){
        
        self.title = currentStreamType.rawValue
        self.configureNavigationTite()
      
        let imgP = UIImage(named: "back_icon")
        let btnback = UIBarButtonItem(image: imgP, style: .plain, target: self, action: #selector(self.btnCancelAction))
        self.navigationItem.leftBarButtonItem = btnback
        

        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: kUpdateStreamViewIdentifier)), object: self)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kUpdateStreamViewIdentifier), object: nil, queue: nil) { (notification) in
            
            if ContentList.sharedInstance.objStream != nil {
                self.updateLayOut()
                //  ContentList.sharedInstance.objStream = nil
            }
        }
        self.updateLayOut()
    }
    
    
    @objc func showReportList(){
        let optionMenu = UIAlertController(title: kAlertSheet_Spam, message: "", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: kAlertSheet_Spam, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Spam, user: "", stream: (self.objStream?.streamID!)!, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Stream)
                }
            })
        })
        
        let deleteAction = UIAlertAction(title: kAlertSheet_Inappropiate, style: .destructive, handler:
        {
            (alert: UIAlertAction!) -> Void in
            APIServiceManager.sharedInstance.apiForSendReport(type: kName_Report_Inappropriate, user: "", stream: (self.objStream?.streamID!)!, content: "", completionHandler: { (isSuccess, error) in
                if isSuccess! {
                    self.showToast(type: AlertType.success, strMSG: kAlert_Success_Report_Stream)
                }
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
    
    // MARK: -  Action Methods And Selector
    @objc func deleteStreamAction(sender:UIButton){
        let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Delete_Stream_Msg, preferredStyle: .alert)
        let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
           self.deleteStream()
        }
        let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
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
        if viewStream == nil {
            let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
            self.navigationController?.popToViewController(vc: obj)
        }else {
        self.navigationController?.pop()
        }
    }
    
    @objc func btnPlayAction(sender:UIButton){
        self.openFullView(index: sender.tag)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .left:
                if currentIndex !=  StreamList.sharedInstance.arrayStream.count-1 {
                    self.next()
                }
                break
                
            case .right:
                if currentIndex != 0 {
                    self.previous()
                }
                break
                
            default:
                break
            }
        }
    }
    
    func next() {
        if(currentIndex < StreamList.sharedInstance.arrayStream.count-1) {
            currentIndex = currentIndex + 1
        }
        Animation.addRightTransition(collection: self.viewStreamCollectionView)
        self.updateLayOut()
    }
    
    func previous() {
        if currentIndex != 0{
            currentIndex =  currentIndex - 1
        }
        Animation.addLeftTransition(collection: self.viewStreamCollectionView)
       
        self.updateLayOut()
    }
    
   @objc func btnColabAction(){
    let obj:PeopleListViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PeopleListView) as! PeopleListViewController
    obj.arrayColab = self.objStream?.arrayColab
    self.navigationController?.push(viewController: obj)
    }
    
    @objc func btnViewDropActionWith(button : UIButton){
        print("Drop down Action")
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
   
    
    func openFullView(index:Int?){
        var arrayContents = [LightboxImage]()

        if index == nil {
            
            let url = URL(string: (self.objStream?.coverImage)!)
            if url != nil {
                let image = LightboxImage(imageURL: url!, text:(self.objStream?.title)!, videoURL: nil)
                arrayContents.append(image)
                let controller = LightboxController(images: arrayContents, startIndex:0)
                controller.dynamicBackground = true
                if arrayContents.count != 0 {
                    present(controller, animated: true, completion: nil)
                }
            }
            return
        }else {
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
    

    // MARK: - API Methods

    func getStream(currentStream:StreamDAO?, streamID:String? = nil){
        HUDManager.sharedInstance.showHUD()
        var id:String! = ""
        if streamID != nil {
            id = streamID
        }else {
            id = currentStream?.ID
        }
        APIServiceManager.sharedInstance.apiForViewStream(streamID:id) { (stream, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            
            if (errorMsg?.isEmpty)! {
                self.objStream = stream
                self.viewStreamCollectionView.reloadData()
                if self.objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                    self.navigationItem.rightBarButtonItem = nil
                }else{
                    let btnRightBar = UIBarButtonItem(image: #imageLiteral(resourceName: "content_flag"), style: .plain, target: self, action: #selector(self.showReportList))
                    self.navigationItem.rightBarButtonItem = btnRightBar
                }
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



extension ViewStreamController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
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
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.prepareLayout(content:content!)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let content = objStream?.arrayContent[indexPath.row]
        return CGSize(width: (content?.width)!, height: (content?.height)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case CHTCollectionElementKindSectionHeader:
            let  view:StreamViewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_ViewStreamHeaderView, for: indexPath) as! StreamViewHeader
            view.btnDelete.addTarget(self, action: #selector(self.deleteStreamAction(sender:)), for: .touchUpInside)
            view.btnEdit.addTarget(self, action: #selector(self.editStreamAction(sender:)), for: .touchUpInside)
            view.btnCollab.addTarget(self, action: #selector(self.btnColabAction), for: .touchUpInside)
            view.prepareLayout(stream:self.objStream)
            //            view.btnDropDown.tag = indexPath.section
            view.btnDropDown.addTarget(self, action: #selector(self.btnViewDropActionWith(button:)), for: .touchUpInside)
            view.delegate = self
            return view
            
        default:
            return UICollectionReusableView()
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = objStream?.arrayContent[indexPath.row]
        if content?.isAdd == true {
            let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
                kContainerNav = "1"
                currentTag = 111
            ContentList.sharedInstance.objStream = self.objStream?.streamID
             arraySelectedContent = [ContentDAO]()
             arrayAssests = [ImportDAO]()
            ContentList.sharedInstance.arrayContent.removeAll()
            self.navigationController?.push(viewController: obj)
            //self.navigationController?.push(viewController: obj)
        }else {
                ContentList.sharedInstance.arrayContent.removeAll()
             let array = objStream?.arrayContent.filter { $0.isAdd == false }
             ContentList.sharedInstance.arrayContent = array
             ContentList.sharedInstance.objStream = objStream?.streamID
              let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
            if (self.objStream?.canAddContent)! {
                objPreview.currentIndex = indexPath.row - 1
            }else {
                objPreview.currentIndex = indexPath.row
            }
                self.navigationController?.push(viewController: objPreview)

        }
    }
    
}

extension ViewStreamController:StreamViewHeaderDelegate {
    func showPreview() {
        self.openFullView(index: nil)
    }
}
