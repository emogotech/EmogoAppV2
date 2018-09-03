//
//  StreamListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 03/09/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit


var selectedImageView:UIImageView?

class StreamListViewController: UIViewController {
    
    @IBOutlet weak var streamCollectionView: UICollectionView!
    @IBOutlet weak var lblNoResult: UILabel!
    
    
    var collectionLayout = CHTCollectionViewWaterfallLayout()
    var arrayToShow = [StreamDAO]()
    var selectedCell:StreamCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLandingNavigation()
    }
    
    func prepareLayout(){
        self.navigationController?.isNavigationBarHidden = false
   //    self.configureLandingNavigation()
        self.lblNoResult.isHidden = true
        self.streamCollectionView.dataSource  = self
        self.streamCollectionView.delegate = self
        
        // Change individual layout attributes for the spacing between cells
        collectionLayout.minimumColumnSpacing = 13.0
        collectionLayout.minimumInteritemSpacing = 13.0
        collectionLayout.sectionInset = UIEdgeInsetsMake(12, 13, 0, 13)
        
        collectionLayout.columnCount = 2
        // Collection view attributes
        self.streamCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.streamCollectionView.alwaysBounceVertical = true
        // Add the waterfall layout to your collection view
        self.streamCollectionView.collectionViewLayout = collectionLayout
        configureLoadMoreAndRefresh()
        getTopStreamList()
    }
    
    
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.streamCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            if currentStreamType == .People {
                // self?.getUsersList(type:.up)
            }else {
                self?.getStreamList(type:.up,filter:currentStreamType)
            }
        }
        
        self.streamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            
            if currentStreamType == .People {
                
            }else {
                self?.getStreamList(type:.down,filter:currentStreamType)
            }
            
        }
        self.streamCollectionView.expiredTimeInterval = 15.0
    }
   
    
    override func btnCameraAction() {
        self.view.endEditing(true)
        //actionForCamera()
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.objStream = nil
        kContainerNav = ""
        self.navigationController?.pushNormal(viewController: obj)
    }
    
    override func btnHomeAction() {
        
    }
    
    override func btnMyProfileAction() {
        self.view.endEditing(true)
        let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
        self.addLeftTransitionView(subtype: kCATransitionFromLeft)
        self.navigationController?.pushViewController(obj, animated: false)
    }
    
    
    
    func getTopStreamList() {
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForGetTopStreamList { (streams, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if (errorMsg?.isEmpty)! {
                StreamList.sharedInstance.arrayStream.removeAll()
                StreamList.sharedInstance.arrayStream = streams
                DispatchQueue.main.async {
                    self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                    if self.arrayToShow.count == 0 {
                        self.lblNoResult.isHidden = false
                        self.lblNoResult.text = kAlert_No_Stream_found
                    }else {
                        self.lblNoResult.isHidden = true
                    }
                    self.streamCollectionView.reloadData()
                }
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    
    func getStreamList(type:RefreshType,filter:StreamType){
        
        if type == .start || type == .up {
            for _ in StreamList.sharedInstance.arrayStream {
                if let index = StreamList.sharedInstance.arrayStream.index(where: { $0.selectionType == currentStreamType}) {
                    StreamList.sharedInstance.arrayStream.remove(at: index)
                }
            }
        }
        
        
        APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            if refreshType == .end {
                self.streamCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.streamCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.streamCollectionView.es.stopLoadingMore()
            }
            print(self.arrayToShow)
            self.lblNoResult.isHidden = true
            // self.lblNoResult.text = kAlert_No_Stream_found
            
            
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                
                if self.arrayToShow.count == 0 {
                    self.lblNoResult.isHidden = false
                    self.lblNoResult.text = kAlert_No_Stream_found
                }else {
                    self.lblNoResult.isHidden = true
                }
                self.streamCollectionView.reloadData()
            }
            self.streamCollectionView.reloadData()
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


extension StreamListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout {
    
   

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamCell, for: indexPath) as! StreamCell
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        let stream = self.arrayToShow[indexPath.row]
        cell.prepareLayouts(stream: stream)
        cell.cardView.shadowColor = UIColor.blue
        cell.cardView.shadowOffsetWidth = 0
        cell.cardView.shadowOffsetHeight = 10
        cell.cardView.shadowOpacity = 1.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth - 23*kScale)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            self.selectedCell = cell as! StreamCell
            selectedImageView = self.selectedCell.imgCover
            StreamList.sharedInstance.arrayViewStream = self.arrayToShow
            let obj:EmogoDetailViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EmogoDetailView) as! EmogoDetailViewController
            obj.currentIndex = indexPath.row
            obj.streamType = currentStreamType.rawValue
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
}
