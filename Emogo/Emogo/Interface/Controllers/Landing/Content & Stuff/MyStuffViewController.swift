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
    
    // MARK: - UI Elements
    
    @IBOutlet weak var stuffCollectionView: UICollectionView!
    @IBOutlet weak var btnNext: UIButton!

    
    // MARK: - Variables


    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.stuffCollectionView.accessibilityLabel = "MyStuffCollectionView"
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationWithTitle()
    }
    
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        
        btnNext.isUserInteractionEnabled = false
        ContentList.sharedInstance.arrayContent.removeAll()
        // Attach datasource and delegate

        self.stuffCollectionView.dataSource  = self
        self.stuffCollectionView.delegate = self
        stuffCollectionView.alwaysBounceVertical = true
        HUDManager.sharedInstance.showHUD()
        self.getMyStuff(type:.start)
        
       
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 0, 8)
        layout.columnCount = 2
        // Collection view attributes
        self.stuffCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.stuffCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.stuffCollectionView.collectionViewLayout = layout
        
        self.configureLoadMoreAndRefresh()
        
    }
    
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.stuffCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            print("reload more called")
            self?.getMyStuff(type:.down)
        }
        
        self.stuffCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            self?.getMyStuff(type:.up)
        }
        
        self.stuffCollectionView.expiredTimeInterval = 20.0
        
    }
    
    
    
    
    @IBAction func btnActionNext(_ sender: Any) {
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
        }else {
            self.showToast(strMSG: kAlert_contentSelect)
        }
        /*
        if let parent = self.parent {
            if arraySelectedContent?.count != 0 {
            HUDManager.sharedInstance.showHUD()
                (parent as! ContainerViewController).updateConatentForGallery(array: arrayAssests!, completed: { (result) in
                HUDManager.sharedInstance.hideHUD()
                 ContentList.sharedInstance.arrayContent.removeAll()
                let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
                ContentList.sharedInstance.arrayContent = arraySelectedContent
                objPreview.strPresented = "TRUE"
                let nav = UINavigationController(rootViewController: objPreview)
                self.parent?.present(nav, animated: true, completion: nil)
            })
//            arraySelectedContent?.removeAll()
//            arrayAssests?.removeAll()
            }else {
                self.showToast(strMSG: kAlert_contentSelect)
            }
        }
       */
    }
    
    @objc func btnPlayAction(sender:UIButton){
        self.openFullView(index: sender.tag)
    }
    
    // MARK: - Class Methods
    func openFullView(index:Int){
        var arrayContents = [LightboxImage]()
        for obj in ContentList.sharedInstance.arrayStuff {
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
                    let url = URL(string: obj.coverImage)
                    let videoUrl = URL(string: obj.coverImage)
                    image = LightboxImage(imageURL: url!, text: text.trim(), videoURL: videoUrl!)
                }
            }
            if image != nil {
                arrayContents.append(image)
            }
        }
        
        let controller = LightboxController(images: arrayContents, startIndex: index)
        controller.dynamicBackground = true
        if arrayContents.count != 0 {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - API Methods
    
    func getMyStuff(type:RefreshType){
        
        if type == .start || type == .up {
        ContentList.sharedInstance.arrayStuff.removeAll()
          self.stuffCollectionView.reloadData()
     }
        APIServiceManager.sharedInstance.apiForGetStuffList(type: type) { (refreshType, errorMsg) in
          
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
            
            
            if ContentList.sharedInstance.arrayStuff.count == 0 {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
                label.text = "No Contents Found!"
                label.sizeToFit()
                label.center = self.view.center
                self.view.addSubview(label)
            }
            self.stuffCollectionView.reloadData()
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


extension MyStuffViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ContentList.sharedInstance.arrayStuff.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_MyStuffCell, for: indexPath) as! MyStuffCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.prepareLayout(content:content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
        return CGSize(width: content.width, height: content.height)
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = self.stuffCollectionView.cellForItem(at: indexPath) {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            content.isSelected = !content.isSelected
            ContentList.sharedInstance.arrayStuff[indexPath.row] = content
            if content.isSelected {
               (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            self.updateSelected(obj: content)
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
        
        let contains =  ContentList.sharedInstance.arrayContent.contains(where: { $0.isSelected == true })
        
        if contains {
            btnNext.isUserInteractionEnabled = true
        }else {
            btnNext.isUserInteractionEnabled = false
        }

    }
    }
    

