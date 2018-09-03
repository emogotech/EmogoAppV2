//
//  EmogoListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 03/09/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class EmogoListViewController: UIViewController {

    @IBOutlet private weak var emogoCollectionView: UICollectionView!

    
    var collectionLayout = CHTCollectionViewWaterfallLayout()
    var arrayToShow = [StreamDAO]()
    var selectedCell:StreamCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        prepareLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.configureLandingNavigation()
    }
    
    func prepareLayout(){
        self.emogoCollectionView.dataSource  = self
        self.emogoCollectionView.delegate = self
        
        // Change individual layout attributes for the spacing between cells
        collectionLayout.minimumColumnSpacing = 13.0
        collectionLayout.minimumInteritemSpacing = 13.0
        collectionLayout.sectionInset = UIEdgeInsetsMake(12, 13, 0, 13)
        
        collectionLayout.columnCount = 2
        // Collection view attributes
        self.emogoCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.emogoCollectionView.alwaysBounceVertical = true
        // Add the waterfall layout to your collection view
        self.emogoCollectionView.collectionViewLayout = collectionLayout
        configureLoadMoreAndRefresh()
        getTopStreamList()
    }
    
    
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.emogoCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            if currentStreamType == .People {
                // self?.getUsersList(type:.up)
            }else {
                self?.getStreamList(type:.up,filter:currentStreamType)
            }
        }
        
        self.emogoCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            
            if currentStreamType == .People {
                
            }else {
                self?.getStreamList(type:.down,filter:currentStreamType)
            }
            
        }
        self.emogoCollectionView.expiredTimeInterval = 15.0
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
                    
                    self.emogoCollectionView.reloadData()
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
                self.emogoCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.emogoCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.emogoCollectionView.es.stopLoadingMore()
            }
            print(self.arrayToShow)
            // self.lblNoResult.text = kAlert_No_Stream_found
            
            DispatchQueue.main.async {
                self.arrayToShow = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                
                self.emogoCollectionView.reloadData()
            }
            self.emogoCollectionView.reloadData()
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


extension EmogoListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageListCell", for: indexPath) as! ImageListCell
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        let stream = self.arrayToShow[indexPath.row]
        cell.imageView.setImageWithURL(strImage: stream.CoverImage, placeholder: "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth - 23*kScale)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageListCell
        //   self.selectedCell = cell as! ImageListCell
        selectedImageView = cell.imageView
        StreamList.sharedInstance.arrayViewStream = self.arrayToShow
        let obj:TestDetailViewController = kStoryboardMain.instantiateViewController(withIdentifier: "testDetailView") as! TestDetailViewController
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
}

extension EmogoListViewController: ZoomTransitionSourceDelegate {
    var animationDuration: TimeInterval {
        return 0.4
    }
    
    func transitionSourceImageView() -> UIImageView {
        return selectedImageView ?? UIImageView()
    }
    
    func transitionSourceImageViewFrame(forward: Bool) -> CGRect {
        guard let selectedImageView = selectedImageView else { return .zero }
        return selectedImageView.convert(selectedImageView.bounds, to: view)
    }
    
    func transitionSourceWillBegin() {
        selectedImageView?.isHidden = true
    }
    
    func transitionSourceDidEnd() {
        selectedImageView?.isHidden = false
    }
    
    func transitionSourceDidCancel() {
        selectedImageView?.isHidden = false
    }
    
    // Uncomment method below if you customize the animation.
    func zoomAnimation(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 2,
            options: .curveEaseInOut,
            animations: animations,
            completion: completion)
    }
}

final class ImageListCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}


