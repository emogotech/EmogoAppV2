 //
//  LinkViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import SwiftLinkPreview

class LinkViewController: UIViewController {
    
     //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎

    @IBOutlet weak var txtLink: UITextField!
    @IBOutlet weak var linkCollectionView: UICollectionView!
    
     //MARK: ⬇︎⬇︎⬇︎ Varibales ⬇︎⬇︎⬇︎
    
    let layout = CHTCollectionViewWaterfallLayout()
    
     //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayouts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Items")
        self.configureNavigationWithTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            var arrayIndex = [Int]()
            let tempArray =  ContentList.sharedInstance.arrayContent.filter { $0.isSelected == true }
            ContentList.sharedInstance.arrayContent = tempArray
            for obj in tempArray {
                for (index,temp) in ContentList.sharedInstance.arrayLink.enumerated() {
                    if temp.contentID.trim() == obj.contentID.trim() {
                        arrayIndex.append(index)
                    }
                }
            }
            
            for (index,_) in  ContentList.sharedInstance.arrayLink.enumerated() {
                if arrayIndex.contains(index) {
                    ContentList.sharedInstance.arrayLink[index].isSelected = true
                }else {
                    ContentList.sharedInstance.arrayLink[index].isSelected = false
                }
            }
        }else {
            for (index,_) in  ContentList.sharedInstance.arrayLink.enumerated() {
                ContentList.sharedInstance.arrayLink[index].isSelected = false
                
            }
        }
        
        self.linkCollectionView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎
    
    func prepareLayouts(){
        // Attach datasource and delegate
        
        self.linkCollectionView.dataSource  = self
        self.linkCollectionView.delegate = self
        linkCollectionView.alwaysBounceVertical = true
        ContentList.sharedInstance.arrayContent.removeAll()
        
        layout.minimumColumnSpacing = 13.0
        layout.minimumInteritemSpacing = 13.0
        layout.sectionInset = UIEdgeInsetsMake(13, 13, 0, 13)
        layout.columnCount = 2
        
        self.getMyLinks(type:.start)
        self.linkCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.linkCollectionView.collectionViewLayout = layout
        // Load More
        self.configureLoadMoreAndRefresh()
    }
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.linkCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
          
            self?.getMyLinks(type:.down)
        }
        
        self.linkCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            self?.getMyLinks(type:.up)
        }
        
        self.linkCollectionView.expiredTimeInterval = 20.0
        
    }
     //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎
    
    @IBAction func btnConfirmActiion(_ sender: Any) {
        self.view.endEditing(true)
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            if (txtLink.text?.trim().isEmpty)! {
                let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
                objPreview.isShowRetake = true
                self.navigationController?.push(viewController: objPreview)
            }else{
                self.smartURLFetchData()
            }
            return
        }
        if (txtLink.text?.trim().isEmpty)! {
            txtLink.shake()
            return
        }else if  (txtLink.text?.trim().checkUrlExists())! {
            self.showToast(strMSG: "Enter valid url.")
            return
        }else{
            self.smartURLFetchData()
        }
        
    }
      //MARK: ⬇︎⬇︎⬇︎Other Methods ⬇︎⬇︎⬇︎
    
    func smartURLFetchData(){
        if let smartUrl = txtLink.text?.stringByAddingPercentEncodingForURLQueryParameter()?.trim().smartURL() {
            if Validator.verifyUrl(urlString: smartUrl.absoluteString) {
                HUDManager.sharedInstance.showHUD()
                let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: DisabledCache.instance)
                
                slp.preview(smartUrl.absoluteString,
                            onSuccess: { result in
                                
                                debugPrint(result)
                                let content = ContentDAO(contentData: [:])
                                let title = result[SwiftLinkResponseKey.title]
                                let description = result[SwiftLinkResponseKey.description]
                                let imageUrl = result[SwiftLinkResponseKey.image]
                                if let title = title {
                                    content.name = (title as! String).trim().findUrl()
                                    if content.name.trim().count > 75 {
                                        content.name = content.name.trim(count: 75)
                                    }
                                }
                                if let description = description {
                                    var str  = (description as! String).trim()
                                    if str.count > 250 {
                                        str = (description as! String).trim(count: 250)
                                    }
                                    content.description = str
                                }
                                content.coverImage = smartUrl.absoluteString
                                content.type = .link
                               content.imgPreview = #imageLiteral(resourceName: "stream-card-placeholder")
                                content.isUploaded = false
                                var imgUrl:String! = ""
                            
                                if let imageUrl = imageUrl {
//                                    imgUrl = imageUrl as! String
                                    if let arrStr = imageUrl as? [String] {
                                        imgUrl = arrStr.first
                                    }else if let str = imageUrl as? String {
                                        imgUrl = str
                                    }
                                    
                                }
                                if imgUrl.isEmpty {
                                    let imageUrl1 = result[SwiftLinkResponseKey.icon]
                                    if let imageUrl = imageUrl1 {
                                        imgUrl = imageUrl as! String
                                    }
                                }
                                if imgUrl.isEmpty {
                                    let imageUrl1 = result[SwiftLinkResponseKey.images]
                                    if let imageUrl = imageUrl1 {
                                        let arrayImages:[Any] = imageUrl as! [Any]
                                        if arrayImages.count != 0 {
                                            imgUrl = arrayImages[0] as! String
                                        }
                                    }
                                }
                                
                                if imgUrl.isEmpty {
                                    let imageUrl1 = result[SwiftLinkResponseKey.finalUrl]
                                    let url:String = (imageUrl1 as! URL).absoluteString.trim().slice(from: "?imgurl=", to: "&imgrefurl")!
                                   
                                    imgUrl = url
                                }
                                
                                if !imgUrl.trim().isEmpty {
                                    SharedData.sharedInstance.downloadFile(strURl:  imgUrl.trim(), handler: { (image,_) in
                                        if let img =  image {
                                            content.height = Int(img.size.height)
                                            content.width = Int(img.size.width)
                                        }
                                        content.coverImageVideo = imgUrl.trim()
                                        content.imgPreview = nil
                                        self.createContentForExtractedData(content: content)
                                    })
                                }
                                if imgUrl.isEmpty {
                                    content.coverImageVideo = imgUrl.trim()
                                    self.createContentForExtractedData(content: content)
                                }
                },
                            onError: {
                                error in print("\(error)")
                                HUDManager.sharedInstance.hideHUD()
                                self.showToast(strMSG: "Enter valid url.")
                })
                
            }else{
             
                self.showToast(strMSG: "Enter valid url.")
            }
        }else {
            self.showToast(strMSG: "Enter valid url.")
        }
    }
    
  
    func createContentForExtractedData(content:ContentDAO){
        HUDManager.sharedInstance.hideHUD()
      if  ContentList.sharedInstance.arrayContent.count > 0 {
            ContentList.sharedInstance.arrayContent.append(content)
            
        }else{
            ContentList.sharedInstance.arrayContent.insert(content, at: 0)
        }
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            objPreview.isShowRetake = true
            self.navigationController?.push(viewController: objPreview)
            return
        }
    }
    
   //MARK: ⬇︎⬇︎⬇︎ API Methods ⬇︎⬇︎⬇︎
    
    func getMyLinks(type:RefreshType){
        if type == .start  {
            HUDManager.sharedInstance.showHUD()
            ContentList.sharedInstance.arrayLink.removeAll()
            self.linkCollectionView.reloadData()
        }
        if type == .up  {
            ContentList.sharedInstance.arrayLink.removeAll()
            self.linkCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetLink(type: type) { (refreshType, errorMsg) in
           
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.linkCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.linkCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.linkCollectionView.es.stopLoadingMore()
            }
            
            self.linkCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }

  
}

 //MARK: ⬇︎⬇︎⬇︎ EXTENSION ⬇︎⬇︎⬇︎
 //MARK: ⬇︎⬇︎⬇︎ Delegate And Datasource ⬇︎⬇︎⬇︎
 
extension LinkViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension LinkViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ContentList.sharedInstance.arrayLink.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let content = ContentList.sharedInstance.arrayLink[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_LinkListCell, for: indexPath) as! LinkListCell
        // for Add Content
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.prepareLayout(content:content)
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(self.btnSelectAction(button:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {

        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth - 23*kScale)
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        ContentList.sharedInstance.arrayContent = ContentList.sharedInstance.arrayLink
        if ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
            objPreview.currentIndex = indexPath.row
            let content = ContentList.sharedInstance.arrayLink[indexPath.row]
            let nav = UINavigationController(rootViewController: objPreview)
            let indexPath = IndexPath(row: indexPath.row, section: 0)
            
            if let imageCell = collectionView.cellForItem(at: indexPath) as? LinkListCell {
                navigationImageView = nil
                let value = kFrame.size.width / CGFloat(content.width)
                kImageHeight  = CGFloat(content.height) * value
                if !content.description.trim().isEmpty  {
                    kImageHeight = kImageHeight + content.description.trim().height(withConstrainedWidth: kFrame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0)) + 25.0
                }
                if kImageHeight < collectionView.bounds.size.height {
                    kImageHeight = collectionView.bounds.size.height
                }
                navigationImageView = imageCell.imgCover
                nav.cc_setZoomTransition(originalView: navigationImageView!)
                nav.cc_swipeBackDisabled = false
            }
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    func updateSelected(obj:ContentDAO){
        
        if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == obj.contentID.trim()}) {
            ContentList.sharedInstance.arrayContent.remove(at: index)
        }else {
            if obj.isSelected  {
                ContentList.sharedInstance.arrayContent.insert(obj, at: 0)
            }
        }
        
        let tempArray =  ContentList.sharedInstance.arrayContent.filter { $0.isSelected == true }
        ContentList.sharedInstance.arrayContent = tempArray
        
    }
    
    @objc func btnSelectAction(button : UIButton)  {
        let index   =   button.tag
        let indexPath   =   IndexPath(item: index, section: 0)
        if let cell = self.linkCollectionView.cellForItem(at: indexPath) {
            let content = ContentList.sharedInstance.arrayLink[indexPath.row]
            content.isSelected = !content.isSelected
            if content.isSelected {
                (cell as! LinkListCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! LinkListCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            self.updateSelected(obj: content)
        }
    }
  
}




