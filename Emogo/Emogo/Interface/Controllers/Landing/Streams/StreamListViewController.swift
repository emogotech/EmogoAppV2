//
//  StreamListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import ESPullToRefresh

class StreamListViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var streamCollectionView: UICollectionView!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var menuView: FSPagerView! {
        didSet {
            self.menuView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            menuView.backgroundView?.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 0)
            menuView.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 0)
            menuView.currentIndex = 3
            menuView.itemSize = CGSize(width: 130, height: 130)
            menuView.transformer = FSPagerViewTransformer(type:.ferrisWheel)
            menuView.delegate = self
            menuView.dataSource = self
            menuView.isHidden = true
        }
    }
    // Varibales
    private let headerNib = UINib(nibName: "StreamSearchCell", bundle: Bundle.main)
    var menu = MenuDAO()
    var isMenuOpen:Bool! = false
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureLandingNavigation()
        self.getStreamList(type:.start)
        menuView.isHidden = true
        self.viewMenu.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      self.prepareLayoutForApper()
    }
    
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        
        // Attach datasource and delegate
        
        self.streamCollectionView.dataSource  = self
        self.streamCollectionView.delegate = self
        
        if let layout: IOStickyHeaderFlowLayout = self.streamCollectionView.collectionViewLayout as? IOStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 60.0)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: layout.itemSize.height)
            layout.parallaxHeaderAlwaysOnTop = false
            layout.disableStickyHeaders = true
            self.streamCollectionView.collectionViewLayout = layout
        }
        
        self.streamCollectionView.register(self.headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader, withReuseIdentifier: kHeader_StreamHeaderView)
        self.configureLoadMoreAndRefresh()

    }
    // MARK: - Prepare Layouts When View Appear
    
    func prepareLayoutForApper(){
        self.viewMenu.layer.contents = UIImage(named: "home_gradient")?.cgImage
        menuView.isAddBackground = false
        menuView.isAddTitle = true
        self.menuView.layer.contents = UIImage(named: "bottomPager")?.cgImage

    }
    
    func configureLoadMoreAndRefresh(){
        
        self.streamCollectionView.es.addPullToRefresh {
            self.getStreamList(type:.up)
        }

        self.streamCollectionView.es.addInfiniteScrolling {
            self.getStreamList(type:.down)
        }
    }
  
    // MARK: -  Action Methods And Selector
    
    override func btnCameraAction() {
        let obj:CameraViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CameraViewController
        self.navigationController?.push(viewController: obj)
    }
    
    override func btnHomeAction() {
        
    }
    
    override func btnMyProfileAction() {
        kDefault?.set(false, forKey: kUserLogggedIn)
        let obj = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_InitialView)
        self.navigationController?.reverseFlipPush(viewController: obj!)
    }

    
    @IBAction func btnActionAdd(_ sender: Any) {
        self.actionForAddStream()
    }
    
    @IBAction func btnActionOpenMenu(_ sender: Any) {
        self.viewMenu.isHidden = true
        isMenuOpen = true
        Animation.viewSlideInFromTopToBottom(views: self.viewMenu)
        self.menuView.isHidden = false
        Animation.viewSlideInFromBottomToTop(views:self.menuView)
    }

    // MARK: - Class Methods

   
    
    // MARK: - API Methods
    private func getStreamList(type:RefreshType){
        if type == .start {
            HUDManager.sharedInstance.showHUD()
        }
        APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type) { (refreshType, errorMsg) in
             if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if (errorMsg?.isEmpty)! {
                if refreshType == .end {
                    self.streamCollectionView.es.stopLoadingMore()
                }
                if type == .up {
                    self.streamCollectionView.es.stopPullToRefresh()
                }else if type == .down {
                    self.streamCollectionView.es.stopLoadingMore()
                }
                self.streamCollectionView.reloadData()
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

// MARK: - EXTENSION
// MARK: - Delegate and Datasource
extension StreamListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StreamList.sharedInstance.arrayStream.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamCell, for: indexPath) as! StreamCell
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
        cell.prepareLayouts(stream: stream)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var cell = UICollectionReusableView()
        switch kind {
        case IOStickyHeaderParallaxHeader:
            cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_StreamHeaderView, for: indexPath) as! StreamSearchCell
            return cell
        default:
            assert(false, "Unexpected element kind")
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isMenuOpen {
            isMenuOpen = false
            self.menuView.isHidden = true
            Animation.viewSlideInFromTopToBottom(views: self.menuView)
            self.viewMenu.isHidden = false
            Animation.viewSlideInFromBottomToTop(views:self.viewMenu)
        }
       
    }
    
}


