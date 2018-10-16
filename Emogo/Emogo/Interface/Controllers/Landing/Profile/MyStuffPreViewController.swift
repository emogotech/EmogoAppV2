//
//  MyStuffPreViewController.swift
//  Emogo
//
//  Created by pushpendra on 13/03/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//



import UIKit

class MyStuffPreViewController: UIViewController {
    
     //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
      //MARK: ⬇︎⬇︎⬇︎ Varibales ⬇︎⬇︎⬇︎
    
    var selectedType:StuffType!
    var selectedIndex:IndexPath?


      //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎
    
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
    
     //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎
    
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
    
    //MARK: ⬇︎⬇︎⬇︎ API Methods ⬇︎⬇︎⬇︎
    
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
    

}
//MARK: ⬇︎⬇︎⬇︎ EXTENSION ⬇︎⬇︎⬇︎


//MARK: ⬇︎⬇︎⬇︎ Delegate And Datasource ⬇︎⬇︎⬇︎

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
                let content = array[indexPath.row]
            let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
                objPreview.currentIndex = indexPath.row
                objPreview.isFromAll = "YES"
                let nav = UINavigationController(rootViewController: objPreview)
                let indexPath = IndexPath(row: indexPath.row, section: 0)
                if let imageCell = collectionView.cellForItem(at: indexPath) as? StreamContentCell {
                    navigationImageView = nil
                    let value = kFrame.size.width / CGFloat(content.width)
                    kImageHeight  = CGFloat(content.height) * value
                    if !content.description.trim().isEmpty  {
                        kImageHeight = kImageHeight + content.description.trim().height(withConstrainedWidth: kFrame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0)) + 25.0
                    }
                    if kImageHeight < self.profileCollectionView.bounds.size.height {
                        kImageHeight = self.profileCollectionView.bounds.size.height
                    }
                    navigationImageView = imageCell.imgCover
                    nav.cc_setZoomTransition(originalView: navigationImageView!)
                    nav.cc_swipeBackDisabled = false
                    self.present(nav, animated: true, completion: nil)
                }
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

}
