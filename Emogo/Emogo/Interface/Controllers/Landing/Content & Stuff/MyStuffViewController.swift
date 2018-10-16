//
//  MyStuffViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Lightbox

class MyStuffViewController: UIViewController {
    
    
     //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎
 
    @IBOutlet weak var stuffCollectionView: UICollectionView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var segmentControl: HMSegmentedControl!
    @IBOutlet weak var lblNoResult: UILabel!
    
      //MARK: ⬇︎⬇︎⬇︎ Varibales ⬇︎⬇︎⬇︎

    var seletedImage:ContentDAO!
    var selectedType:StuffType! = StuffType.All
    let fontSegment = UIFont(name: "SFProText-Medium", size: 12.0)
    
    //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.stuffCollectionView.accessibilityLabel = "MyStuffCollectionView"
        self.prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationWithTitle()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            var arrayIndex = [Int]()
            let tempArray =  ContentList.sharedInstance.arrayContent.filter { $0.isSelected == true }
            ContentList.sharedInstance.arrayContent = tempArray
            for obj in tempArray {
                for (index,temp) in ContentList.sharedInstance.arrayStuff.enumerated() {
                    if temp.contentID.trim() == obj.contentID.trim() {
                        arrayIndex.append(index)
                    }
                }
            }
            
            for (index,_) in  ContentList.sharedInstance.arrayStuff.enumerated() {
                if arrayIndex.contains(index) {
                    ContentList.sharedInstance.arrayStuff[index].isSelected = true
                }else {
                    ContentList.sharedInstance.arrayStuff[index].isSelected = false
                }
            }
        }else {
            for (index,_) in  ContentList.sharedInstance.arrayStuff.enumerated() {
                ContentList.sharedInstance.arrayStuff[index].isSelected = false
            }
        }
        
        DispatchQueue.main.async {
            self.stuffCollectionView.reloadData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎
    
    
    func prepareLayouts(){
        self.btnNext.isHidden = true
      
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.arrayStuff.removeAll()
        // Attach datasource and delegate
        self.stuffCollectionView.dataSource  = self
        self.stuffCollectionView.delegate = self
        stuffCollectionView.alwaysBounceVertical = true
        HUDManager.sharedInstance.showHUD()
        self.getTopContents()
        
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 13.0
        layout.minimumInteritemSpacing = 13.0
        layout.sectionInset = UIEdgeInsetsMake(12, 13, 0, 13)
        layout.columnCount = 2
        // Collection view attributes
        self.stuffCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.stuffCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.stuffCollectionView.collectionViewLayout = layout
      
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.stuffCollectionView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.stuffCollectionView.addGestureRecognizer(swipeLeft)
        // Segment control Configure
        
        segmentControl.sectionTitles = ["All", "Photos", "Videos", "Links", "Notes","Gifs"]
        segmentControl.indexChangeBlock = {(_ index: Int) -> Void in
            print("Selected index \(index) (via block)")
            self.updateStuffList(index: index)
        }
        
        segmentControl.selectionIndicatorHeight = 1.0
        segmentControl.backgroundColor = UIColor.white
        segmentControl.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 74, g: 74, b: 74),NSAttributedStringKey.font : fontSegment ?? UIFont.systemFont(ofSize: 13.0)]
        segmentControl.selectionIndicatorColor = UIColor(r: 74, g: 74, b: 74)
        segmentControl.selectionStyle = .textWidthStripe
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectionIndicatorLocation = .down
        segmentControl.shouldAnimateUserSelection = false
        
        self.configureLoadMoreAndRefresh()
        
    }
    
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.stuffCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in

            self?.getMyStuff(type:.down)
        }
        
        self.stuffCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            self?.getMyStuff(type:.up)
        }
        
        self.stuffCollectionView.expiredTimeInterval = 20.0
        
    }
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                print("Swie Left")
                if self.selectedType == .Giphy {
                    return
                }
                Animation.addRightTransition(collection: self.stuffCollectionView)
                let index = self.selectedType.hashValue + 1
                self.segmentControl.selectedSegmentIndex = index
                self.updateStuffList(index: index)
                
                break
                
            case UISwipeGestureRecognizerDirection.right:
                print("Swie Right")
                if self.selectedType == .All {
                    return
                }
                Animation.addLeftTransition(collection: self.stuffCollectionView)
                let index = self.selectedType.hashValue - 1
                self.segmentControl.selectedSegmentIndex = index
                self.updateStuffList(index: index)
                
                
                break
            default:
                break
            }
        }
    }
  
    //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎
    
    @IBAction func btnActionNext(_ sender: Any) {
        let tempArray =  ContentList.sharedInstance.arrayContent.filter { $0.isSelected == true }
        ContentList.sharedInstance.arrayContent = tempArray
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
        }else {
            self.showToast(strMSG: kAlert_contentSelect)
        }
      
    }
    
    @objc func btnPlayAction(sender:UIButton){
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        let content = array[sender.tag]
        if content.isAdd {
            //   btnActionForAddContent()
        }else {
            ContentList.sharedInstance.arrayContent = array
            if ContentList.sharedInstance.arrayContent.count != 0 {
            
                
                let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                objPreview.currentIndex = sender.tag
                objPreview.isProfile = "TRUE"
                let nav = UINavigationController(rootViewController: objPreview)
                let indexPath = IndexPath(row: sender.tag, section: 0)
                if let imageCell = stuffCollectionView.cellForItem(at: indexPath) as? MyStuffCell {
                    navigationImageView = nil
                    let value = kFrame.size.width / CGFloat(content.width)
                    kImageHeight  = CGFloat(content.height) * value
                    if !content.description.trim().isEmpty  {
                        kImageHeight = kImageHeight + content.description.trim().height(withConstrainedWidth: kFrame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0)) + 25.0
                    }
                    if kImageHeight < self.stuffCollectionView.bounds.size.height {
                        kImageHeight = self.stuffCollectionView.bounds.size.height
                    }
                    navigationImageView = imageCell.imgCover
                    nav.cc_setZoomTransition(originalView: navigationImageView!)
                    nav.cc_swipeBackDisabled = false
                }
                self.present(nav, animated: true, completion: nil)
              
            }
        }

    }
    
    //MARK: ⬇︎⬇︎⬇︎ API Methods ⬇︎⬇︎⬇︎
    
    func getMyStuff(type:RefreshType) {
        if type == .start || type == .up {
            for _ in  ContentList.sharedInstance.arrayStuff {
                if let index = ContentList.sharedInstance.arrayStuff.index(where: { $0.stuffType == selectedType}) {
                    ContentList.sharedInstance.arrayStuff.remove(at: index)
                    
                }
            }
            ContentList.sharedInstance.arrayContent.removeAll()
            
            self.stuffCollectionView.reloadData()
        }
        
        APIServiceManager.sharedInstance.apiForGetStuffList(type: type,contentType: selectedType) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.stuffCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.stuffCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.stuffCollectionView.es.stopLoadingMore()
            }
            
            self.lblNoResult.isHidden = true
            self.btnNext.isHidden = false
            self.btnNext.isHidden = true
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            if array.count == 0 {
                self.lblNoResult.text  = "No Media Found"
                self.lblNoResult.minimumScaleFactor = 1.0
                self.lblNoResult.isHidden = false
            }
            if ContentList.sharedInstance.arrayContent.count != 0 {
                self.btnNext.isHidden = false
            }
            self.stuffCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    
    func getTopContents(){
        APIServiceManager.sharedInstance.apiForGetTopContent { (_, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.lblNoResult.isHidden = true
                self.btnNext.isHidden = true
                
                let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
                if array.count == 0 {
                    self.lblNoResult.text  = "No Media Found"
                    self.lblNoResult.minimumScaleFactor = 1.0
                    self.lblNoResult.isHidden = false
                    self.btnNext.isHidden = true
                }
                
                self.stuffCollectionView.reloadData()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    
     //MARK: ⬇︎⬇︎⬇︎Other Methods ⬇︎⬇︎⬇︎
    
   
    func openFullView(index:Int){
       
        var arrayContents = [LightboxImage]()
        //var index:Int! = 0
        var arrayTemp = [ContentDAO]()
        self.seletedImage = ContentList.sharedInstance.arrayStuff[index]
       
        arrayTemp.append(seletedImage)
      
        for obj  in arrayTemp {
            var image:LightboxImage!
            let text = obj.name + "\n" +  obj.description
            
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
                    if let url = url, let videoUrl = videoUrl {
                        image = LightboxImage(imageURL: url, text: text.trim(), videoURL: videoUrl)
                    }
                    
                }
            }
            if image != nil {
                arrayContents.append(image)
                if obj.contentID == seletedImage.contentID {
               // index = arrayContents.count - 1
                }
            }
        }
    
            let controller = LightboxController(images: arrayContents, startIndex: index)
            controller.dynamicBackground = true
            if arrayContents.count != 0 {
                present(controller, animated: true, completion: nil)
            
        }
    }
    
    func updateStuffList(index:Int){
        switch index {
        case 0:
            self.selectedType = .All
            break
        case 1:
            self.selectedType = StuffType.Picture
            break
        case 2:
            self.selectedType = StuffType.Video
            break
        case 3:
            self.selectedType = StuffType.Links
            break
        case 4:
            self.selectedType = StuffType.Notes
            break
        case 5:
            self.selectedType = StuffType.Giphy
            break
        default:
            self.selectedType = .All
        }
        stuffCollectionView.es.resetNoMoreData()
        
        // For Unselect Previous selected
        if  ContentList.sharedInstance.arrayContent.count == 0 {
            for i in 0..<ContentList.sharedInstance.arrayStuff.count {
                let obj = ContentList.sharedInstance.arrayStuff[i]
                obj.isSelected = false
                ContentList.sharedInstance.arrayStuff[i] = obj
            }
        }
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        self.lblNoResult.isHidden = true
        self.btnNext.isHidden = true
        
        if ContentList.sharedInstance.arrayContent.count != 0 {
            self.btnNext.isHidden = false
        }
        if array.count == 0  {
            self.lblNoResult.isHidden = false
            self.lblNoResult.text = "No Media Found"
        }
        self.stuffCollectionView.reloadData()
    }
    
   
}

//MARK: ⬇︎⬇︎⬇︎ EXTENSION ⬇︎⬇︎⬇︎

//MARK: ⬇︎⬇︎⬇︎ Delegate And Datasource ⬇︎⬇︎⬇︎

extension MyStuffViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        
        let content = array[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_MyStuffCell, for: indexPath) as! MyStuffCell
        // for Add Content
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(self.btnSelectAction(button:)), for: .touchUpInside)
        cell.prepareLayout(content:content)
        if content.isSelected {
            cell.imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
        }else {
            cell.imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        let content = array[indexPath.row]
        return CGSize(width: content.width, height: content.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
        ContentList.sharedInstance.arrayContent = array
        if ContentList.sharedInstance.arrayContent.count != 0 {
        let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
        objPreview.currentIndex = indexPath.row
        let content = array[indexPath.row]
        let nav = UINavigationController(rootViewController: objPreview)
        let indexPath = IndexPath(row: indexPath.row, section: 0)
        if let imageCell = collectionView.cellForItem(at: indexPath) as? MyStuffCell {
            navigationImageView = nil
            let value = kFrame.size.width / CGFloat(content.width)
            kImageHeight  = CGFloat(content.height) * value
            if !content.description.trim().isEmpty  {
                kImageHeight = kImageHeight + content.description.trim().height(withConstrainedWidth: kFrame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0)) + 25.0
            }
            if kImageHeight < self.stuffCollectionView.bounds.size.height {
                kImageHeight = self.stuffCollectionView.bounds.size.height
            }
            navigationImageView = imageCell.imgCover
            nav.cc_setZoomTransition(originalView: navigationImageView!)
            nav.cc_swipeBackDisabled = false
            }
            self.present(nav, animated: true, completion: nil)
        }

     
    }
    
    @objc func btnSelectAction(button : UIButton)  {
        let index   =   button.tag
        let indexPath   =   IndexPath(item: index, section: 0)
        if let cell = self.stuffCollectionView.cellForItem(at: indexPath) {
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.stuffType == self.selectedType }
            let content = array[indexPath.row]
            content.isSelected = !content.isSelected
            for (tag,obj) in ContentList.sharedInstance.arrayStuff.enumerated() {
                if obj.contentID.trim() == content.contentID.trim() {
                    obj.isSelected =  content.isSelected
                    ContentList.sharedInstance.arrayStuff[tag] = obj
                }
            }
            
            if content.isSelected {
                (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            self.updateSelected(obj: content)
        }
    }
    
    func gifPreview(content : ContentDAO){
        let obj:ShowPreviewViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ShowPreviewView) as! ShowPreviewViewController
        obj.objContent = content
        self.present(obj, animated: false, completion: nil)
    }
    
    func updateSelected(obj:ContentDAO){
        
          let isContains =  ContentList.sharedInstance.arrayContent.contains(where: {$0.contentID.trim() == obj.contentID.trim()})
        if isContains {
            if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == obj.contentID.trim()}) {
                if !obj.isSelected  {
                    ContentList.sharedInstance.arrayContent.remove(at: index)
                }
            }
        }else {
            if obj.isSelected  {
                ContentList.sharedInstance.arrayContent.insert(obj, at: 0)
            }
        }
        
        let tempArray =  ContentList.sharedInstance.arrayContent.filter { $0.isSelected == true }
        ContentList.sharedInstance.arrayContent = tempArray
        
        let contains =  ContentList.sharedInstance.arrayContent.contains(where: { $0.isSelected == true })
        
        if contains {
            btnNext.isHidden = false
        }else {
            btnNext.isHidden = true
        }
    }
}
