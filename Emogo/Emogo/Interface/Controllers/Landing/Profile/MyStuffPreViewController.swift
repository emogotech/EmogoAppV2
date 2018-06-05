//
//  MyStuffPreViewController.swift
//  Emogo
//
//  Created by pushpendra on 13/03/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//



import UIKit

class MyStuffPreViewController: UIViewController {
    @IBOutlet weak var profileCollectionView: UICollectionView!
    var selectedType:StuffType!
    var selectedIndex:IndexPath?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.profileCollectionView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayout(){
        configureNavigationWithTitle()
        self.profileCollectionView.dataSource  = self
        self.profileCollectionView.delegate = self
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        layout.columnCount = 2
        // Collection view attributes
        self.profileCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.profileCollectionView.alwaysBounceVertical = true
        // Add the waterfall layout to your collection view
        self.profileCollectionView.collectionViewLayout = layout
        configureLoadMoreAndRefresh()
        HUDManager.sharedInstance.showHUD()
        self.getStuff(type: .start)
        if selectedType == .All {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
            self.profileCollectionView.addGestureRecognizer(longPressGesture)
            self.title = selectedType.rawValue
        }else {
            if selectedType.rawValue == "Giphy" {
                self.title = "Gifs"
            }else  if selectedType.rawValue == "Picture"{
                self.title = "Photos"
            }else {
                self.title = selectedType.rawValue + "s"
            }
        }
      
        
    }
    

    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.profileCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
           self?.getStuff(type: .up)
        }
        self.profileCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            self?.getStuff(type: .down)
        }
        self.profileCollectionView.expiredTimeInterval = 20.0
    }
    
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        if self.selectedType != .All {
            return
        }
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.profileCollectionView.indexPathForItem(at: gesture.location(in: self.profileCollectionView)) else {
                break
            }
            selectedIndex = selectedIndexPath
            profileCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            profileCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: self.profileCollectionView))
            
        case UIGestureRecognizerState.ended:
            profileCollectionView.endInteractiveMovement()
            selectedIndex = nil
        default:
            profileCollectionView.cancelInteractiveMovement()
            selectedIndex = nil
        }
    }
    
    
    func getStuff(type:RefreshType){
        if type == .start || type == .up {
            ContentList.sharedInstance.arrayStuff.removeAll()
            self.profileCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetStuffList(type: type,contentType: selectedType) { (refreshType, errorMsg) in
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
    
    func reorderContent(orderArray:[ContentDAO]) {
        
        APIServiceManager.sharedInstance.apiForReorderMyContent(orderArray: orderArray) { (isSuccess,errorMSG)  in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                self.profileCollectionView.reloadData()
                self.selectedIndex = nil
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

extension MyStuffPreViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ContentList.sharedInstance.arrayStuff.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.prepareLayout(content:content)
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            if selectedIndex != nil {
                let tempContent = ContentList.sharedInstance.arrayStuff[selectedIndex!.row]
                return CGSize(width: tempContent.width, height: tempContent.height)
            }
            return CGSize(width: content.width, height: content.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
            let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isAdd == false }
                ContentList.sharedInstance.arrayContent = array
            if ContentList.sharedInstance.arrayContent.count != 0 {
                    let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                    objPreview.currentIndex = indexPath.row
                    objPreview.isFromAll = "YES"
                    self.navigationController?.push(viewController: objPreview)
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
      
            let contentDest = ContentList.sharedInstance.arrayStuff[sourceIndexPath.row]
            ContentList.sharedInstance.arrayStuff.remove(at: sourceIndexPath.row)
            ContentList.sharedInstance.arrayStuff.insert(contentDest, at: destinationIndexPath.row)
            DispatchQueue.main.async {
                self.profileCollectionView.reloadItems(at: [destinationIndexPath,sourceIndexPath])
                HUDManager.sharedInstance.showHUD()
                self.reorderContent(orderArray:ContentList.sharedInstance.arrayStuff)
            }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if selectedType == .All {
            return true
        }else {
            return false
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
//
//        if proposedIndexPath.item == 0 {
//            return IndexPath(item: 1, section: 0)
//        }else {
//            return proposedIndexPath
//        }
//    }

}
