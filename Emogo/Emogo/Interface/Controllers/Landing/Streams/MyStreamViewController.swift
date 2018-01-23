//
//  MyStreamViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Lightbox
import GSKStretchyHeaderView

class MyStreamViewController: UIViewController {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var myStreamCollectionView: UICollectionView!
    @IBOutlet weak var lblNoResult: UILabel!

    // MARK: - Variables
    var currentType:RefreshType! = .start
    var objContent:ContentDAO!
    var streamID:String?
    
    var stretchyHeader: MyStreamHeaderView!
    
    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kShowOnlyMyStream = ""
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        
        // Attach datasource and delegate
        self.configureStrechyHeader()
        self.myStreamCollectionView.dataSource  = self
        self.myStreamCollectionView.delegate = self
        
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        layout.columnCount = 2
        // Collection view attributes
        self.myStreamCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.myStreamCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.myStreamCollectionView.collectionViewLayout = layout
        
         kShowOnlyMyStream = "1"
        HUDManager.sharedInstance.showHUD()
          self.getMyStreams(type:.start,filter: .myStream)
        // Load More
        configureLoadMoreAndRefresh()
    }
    
    func configureStrechyHeader(){
        let nibViews = Bundle.main.loadNibNamed("MyStreamHeaderView", owner: self, options: nil)
        self.stretchyHeader = nibViews?.first as! MyStreamHeaderView
        self.myStreamCollectionView.addSubview(self.stretchyHeader)
    }
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.myStreamCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            self?.getMyStreams(type:.up,filter: .myStream)
        }
        self.myStreamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
           
            self?.getMyStreams(type:.down,filter: .myStream)
            
        }
        self.myStreamCollectionView.expiredTimeInterval = 20.0
    }
    
    

    // MARK: -  Action Methods And Selector
    
    @IBAction func btnActionDone(_ sender: Any) {
        var streamID  = [String]()
        for stream in StreamList.sharedInstance.arrayMyStream {
            if stream.isSelected == true {
                streamID.append(stream.ID.trim())
            }
        }
        if streamID.count == 0 {
            self.showToast(strMSG: kAlert_Select_Stream)
            return
        }else {
            self.associateContentToStream(id: streamID)
        }
    }
    @objc func backButtonAction(sender:UIButton){
        self.navigationController?.pop()
    }

    

    // MARK: - Class Methods
    func openFullView(index:Int){
        var arrayContents = [LightboxImage]()
        var arrayTemp = [ContentDAO]()
        if objContent == nil {
            arrayTemp = ContentList.sharedInstance.arrayContent
        }else{
            arrayTemp.append(objContent)
        }
        for obj in arrayTemp {
            var image:LightboxImage!
            let text = obj.name.trim() + "\n" +  obj.description.trim()
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
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - API Methods
    
    func getMyStreams(type:RefreshType,filter:StreamType){
        if type == .start || type == .up {
            StreamList.sharedInstance.arrayMyStream.removeAll()
            let stream = StreamDAO(streamData: [:])
            stream.isAdd = true
            StreamList.sharedInstance.arrayMyStream.insert(stream, at: 0)
            self.myStreamCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
           
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.myStreamCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.myStreamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.myStreamCollectionView.es.stopLoadingMore()
            }
            
          //  self.lblNoResult.isHidden = true
            if StreamList.sharedInstance.arrayMyStream.count == 0 {
             //   self.lblNoResult.isHidden = false
            }
            self.currentType = refreshType
            if self.streamID != nil {
                if let index =   StreamList.sharedInstance.arrayMyStream.index(where: {$0.ID.trim() == self.streamID?.trim()}) {
                    StreamList.sharedInstance.arrayMyStream.remove(at: index)
                }
            }
            self.myStreamCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }

    func associateContentToStream(id:[String]){
        if self.objContent != nil {
         HUDManager.sharedInstance.showHUD()
            AWSRequestManager.sharedInstance.associateContentToStream(streamID: id, contents: [self.objContent], completion: { (isScuccess, errorMSG) in
              HUDManager.sharedInstance.hideHUD()
                if (errorMSG?.isEmpty)! {
                    self.navigationController?.pop()
                }
            })
            
        }else {
            if ContentList.sharedInstance.arrayContent.count != 0 {
                HUDManager.sharedInstance.showProgress()
                let array = ContentList.sharedInstance.arrayContent
                AWSRequestManager.sharedInstance.associateContentToStream(streamID: id, contents: array!, completion: { (isScuccess, errorMSG) in
                    if (errorMSG?.isEmpty)! {
                        
                    }
                })
                
                let when = DispatchTime.now() + 1.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    let objStream = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
                    self.navigationController?.popToViewController(vc: objStream)
                }
                
                ContentList.sharedInstance.arrayContent.removeAll()
            }
        }
    }
    
    func actionForAddStream(){
        let obj:AddStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddStreamView) as! AddStreamViewController
         obj.isAddContent = true
        self.navigationController?.push(viewController: obj)
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


extension MyStreamViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return StreamList.sharedInstance.arrayMyStream.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_MyStreamCell, for: indexPath) as! MyStreamCell
        // for Add Content
        let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
        cell.prepareLayout(stream: stream)
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            let itemWidth = collectionView.bounds.size.width/2.0
            return CGSize(width: itemWidth, height: itemWidth - 40)
    }
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
        if stream.isAdd {
            actionForAddStream()
        }else {
            if let cell = self.myStreamCollectionView.cellForItem(at: indexPath) {
                let stream = StreamList.sharedInstance.arrayMyStream[indexPath.row]
                stream.isSelected = !stream.isSelected
                StreamList.sharedInstance.arrayMyStream[indexPath.row] = stream
                if stream.isSelected {
                    (cell as! MyStreamCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
                }else {
                    (cell as! MyStreamCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
                }
            }
        }
    }
    
    
}



extension MyStreamViewController:MyStreamHeaderViewDelegate {
    func selected(index: Int) {
        self.openFullView(index:index)
    }
}
