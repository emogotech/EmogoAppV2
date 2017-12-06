//
//  HomeViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 11/17/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class HomeViewController: MSMessagesAppViewController {
    
    // MARK:- UI Elements
    @IBOutlet weak var collectionStream : UICollectionView!
    @IBOutlet weak var searchView : UIView!
    @IBOutlet weak var searchText : UITextField!
    @IBOutlet weak var btnFeature : UIButton!
    
    // MARK: - Varibales
    var arrayStreams = [StreamDAO]()
    var hudView: LoadingView!
    var hudRefreshView: LoadingView!
    var lastIndex : Int = 10
    var refresher:UIRefreshControl?
    var footerView:HomeCollectionReusableView?
    
    //var Pagning
    var paging : Int = 1;
    var currentIndex : Int = 1
    var fectchingStreamData : Bool = false
    
    fileprivate let arrImages = ["PopularDeselected","MyStreamsDeselected","FeatutreDeselected","emogoDeselected","ProfileDeselected","PeopleDeselect"]
    
    fileprivate let arrImagesSelected = ["Popular","My Streams","Featured","Emogo Streams","Profile","People"]
    
    // MARK:- Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoader()
        self.perform(#selector(prepareLayout), with: nil, afterDelay: 0.01)
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: iMsgNotificationManageScreen), object: nil)
    }
    
    // MARK:- prepareLayout
    @objc func prepareLayout() {
        self.searchView.layer.cornerRadius = 15
        self.searchView.clipsToBounds = true
        self.getStreamList(type: .normal)
        self.collectionStream.register(UINib(nibName: iMgsSegue_HomeCollectionReusableV, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: iMgsSegue_HomeCollectionReusableV)
    }
    
    // MARK:- LoaderSetup
    func setupLoader() {
        hudView  = LoadingView.init(frame: view.frame)
        view.addSubview(hudView)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        DispatchQueue.main.async {
            self.hudView.startLoaderWithAnimation()
        }
    }
    
    // MARK:- pull to refresh LoaderSetup
    func setupRefreshLoader() {
        self.refresher = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: self.collectionStream.frame.size.width, height: 100))
        
        hudRefreshView  = LoadingView.init(frame: (self.refresher?.frame)!)
        hudRefreshView.load?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        hudRefreshView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        hudRefreshView.loaderImage?.isHidden = true
        hudRefreshView.load?.frame = CGRect(x: 0, y: (self.refresher?.frame.width)!/2-30, width: 30, height: 30)
        hudRefreshView.load?.translatesAutoresizingMaskIntoConstraints = false
        hudRefreshView.load?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        hudRefreshView.load?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        hudRefreshView.load?.lineWidth = 3.0
        hudRefreshView.load?.duration = 2.0
        self.refresher?.addSubview(hudRefreshView)
        
        self.collectionStream!.alwaysBounceVertical = true
        self.refresher?.tintColor = UIColor.clear
        self.refresher?.addTarget(self, action: #selector(pullToDownAction), for: .valueChanged)
        self.collectionStream!.addSubview(refresher!)
    }
    
    func setupCollectionProperties() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/2-15, height: 100)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 10
        collectionStream!.collectionViewLayout = layout
        
        collectionStream.delegate = self
        collectionStream.dataSource = self
    }
    
    // MARK:- Selector Methods
    @objc func requestMessageScreenChangeSize(){
        self.perform(#selector(self.changeUI), with: nil, afterDelay: 0.2)
    }
    
    @objc func changeUI(){
        if(SharedData.sharedInstance.isMessageWindowExpand) {
            self.performSelector(inBackground: #selector(self.changeUIInBackground), with: nil)
            btnFeature.tag = 1
        }else{
            SharedData.sharedInstance.hidePager(controller: self)
            btnFeature.tag = 0
        }
    }
    
    @objc func changeUIInBackground(){
        if(SharedData.sharedInstance.isMessageWindowExpand) {
            SharedData.sharedInstance.preparePagerFrame(frame: CGRect(x: 0, y: self.view.frame.size.height - 220, width: self.view.frame.size.width, height: 220), controller: self)
            SharedData.sharedInstance.showPager(controller: self)
        }
    }
    
    @objc func pullToDownAction() {
        self.refresher?.frame = CGRect(x: 0, y: 0, width: self.collectionStream.frame.size.width, height: 100)
        SharedData.sharedInstance.nextStreamString = ""
        hudRefreshView.startLoaderWithAnimation()
        self.getStreamList(type: .pullToRefresh)
    }
    
    @objc func resignRefreshLoader(){
        self.refresher?.endRefreshing()
        hudRefreshView.stopLoaderWithAnimation()
        self.refresher?.frame = CGRect.zero
        self.collectionStream.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.setupCollectionProperties()
        if(SharedData.sharedInstance.isMessageWindowExpand) {
            SharedData.sharedInstance.preparePagerFrame(frame: CGRect(x: 0, y: self.view.frame.size.height - 260, width: self.view.frame.size.width, height: 220), controller: self)
            
            SharedData.sharedInstance.showPager(controller: self)
            btnFeature.tag = 1
        }
        self.setupRefreshLoader()
    }
    
    // MARK:- Action methods
    @IBAction func btnSearchAction(_ sender: UIButton){
        self.searchText.resignFirstResponder()
    }
    
    @IBAction func btnFeaturedTap(_ sender: UIButton){
        if(btnFeature.tag == 1){
            SharedData.sharedInstance.hidePager(controller: self)
            btnFeature.tag = 0
        } else {
            if(SharedData.sharedInstance.isMessageWindowExpand) {
                SharedData.sharedInstance.showPager(controller: self)
                btnFeature.tag = 1
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyleExpand), object: nil)
            }
        }
    }
    
    // MARK: - API Methods
    private func getStreamList(type:StreamInputType){
        if Reachability.isNetworkAvailable() {
            if(type == .normal){
                self.hudView.startLoaderWithAnimation()
            }
            APIServiceManager.sharedInstance.apiForGetStreamList { (results, errorMsg) in
                self.streaminputDataType(type: type)
                if (errorMsg?.isEmpty)! {
                    if(type == .normal || type == .pullToRefresh){
                        self.arrayStreams = results!
                    }else{
                        for stream in results!{
                            self.arrayStreams.append(stream)
                        }
                    }
                    self.collectionStream.reloadData()
                }else {
                    self.showToastIMsg(type: .success, strMSG: errorMsg!)
                }
            }
        }
        else {
            if(type == .normal){
                self.hudView.startLoaderWithAnimation()
            }else{
                self.resignRefreshLoader()
            }
            self.showToastIMsg(type: .error, strMSG: kAlertNetworkErrorMsg)
        }
    }
    
    func streaminputDataType(type:StreamInputType){
        if(SharedData.sharedInstance.isMoreContentAvailable){
            self.fectchingStreamData = true
        }
        else {
            self.fectchingStreamData = false
        }
        if(type == .bottomScrolling) {
            self.footerView?.loadingView.stopLoaderWithAnimation()
        } else  if(type == .normal){
            self.hudView.stopLoaderWithAnimation()
        }else{
            self.resignRefreshLoader()
        }
    }
}

// MARK:- Extension collectionview delegate
extension HomeViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayStreams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : HomeCollectionViewCell = self.collectionStream.dequeueReusableCell(withReuseIdentifier: iMsgSegue_HomeCollection, for: indexPath) as! HomeCollectionViewCell
        
        let stream = self.arrayStreams[indexPath.row]
        cell.prepareLayouts(stream: stream)
        cell.imgStream.tag = indexPath.row
        cell.btnView.tag = indexPath.row
        cell.btnView.addTarget(self, action: #selector(self.btnViewAction(_:)), for: UIControlEvents.touchUpInside)
        cell.btnShare.tag = indexPath.row
        cell.btnView.addTarget(self, action: #selector(self.btnShareAction(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: iMgsSegue_HomeCollectionReusableV, for: indexPath) as! HomeCollectionReusableView
            self.footerView = aFooterView
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CustomFooterView", for: indexPath)
            return headerView
        }
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if !fectchingStreamData {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.hudRefreshView?.startLoaderWithAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.hudRefreshView?.stopLoaderWithAnimation()
        }
    }
    
    @objc func btnViewAction(_ sender:UIButton){
        let obj : StreamViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_Stream) as! StreamViewController
        self.addRippleTransition()
        obj.arrStream = self.arrayStreams
        obj.currentStreamIndex = sender.tag
        self.present(obj, animated: false, completion: nil)
        self.changeCellImageAnimation(sender.tag)
    }
    
    @objc func btnShareAction(_ sender:UIButton){
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        SharedData.sharedInstance.hidePager(controller: self)
        btnFeature.tag = 0
        self.changeCellImageAnimation(indexPath.row)
    }
    
    func changeCellImageAnimation(_ sender : Int){
        for row in 0 ..< self.collectionStream.numberOfItems(inSection: 0){
            let indexPath = NSIndexPath(row: row, section: 0)
            if let sel = self.collectionStream.cellForItem(at: indexPath as IndexPath){
                if(sender == (sel as! HomeCollectionViewCell).imgStream?.tag){
                    if((sel as! HomeCollectionViewCell).viewShowHide.isHidden == false){
                        (sel as! HomeCollectionViewCell).viewShowHide.isHidden = true
                    }
                    else{
                        (sel as! HomeCollectionViewCell).viewShowHide.isHidden = false
                    }
                    addTransition(vi : (sel as! HomeCollectionViewCell))
                } else {
                    (sel as! HomeCollectionViewCell).viewShowHide.isHidden = true
                }
            }
        }
    }
    
    func addTransition(vi : HomeCollectionViewCell){
        let transition = CATransition()
        transition.duration = 0.7
        transition.type = "flip"
        transition.subtype = kCATransitionFromRight
        vi.layer.add(transition, forKey: kCATransition)
    }
    
}

// MARK:- Extension TextField delegate
extension HomeViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(!SharedData.sharedInstance.isMessageWindowExpand) {
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyleExpand), object: nil)
        }else{
            SharedData.sharedInstance.hidePager(controller: self)
            btnFeature.tag = 0
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}

// MARK:- Extension FSPagerView delegate
extension HomeViewController : FSPagerViewDataSource,FSPagerViewDelegate {
    
    // MARK:- FSPagerViewDataSource
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return arrImages.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        if(index == pagerView.currentIndex){
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = UIImage(named: self.arrImagesSelected[index])
            cell.addLayerInImageView(isTrue : true)
        }
        else {
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = UIImage(named: self.arrImages[index])
        }
        
        cell.imageView?.tag = index
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)!/2
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        if(lastIndex != index){
            lastIndex = index
            
            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(index, pagerView: pagerView)
                
//                if(self.arrImagesSelected[index] == kDeepLinkTypePeople){
//                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "CollaboratorViewController") as! CollaboratorViewController
//                    obj.strTitle = "People List"
//                    self.present(obj, animated: true, completion: nil)
//                }
               
            })
            
            if(self.arrImagesSelected[index] == kDeepLinkTypeProfile || self.arrImagesSelected[index] == kDeepLinkTypePeople){
                let strUrl = "\(kDeepLinkURL)\(self.arrImagesSelected[index])"
                SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
            }
        }
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        if(lastIndex != pagerView.currentIndex){
            lastIndex = pagerView.currentIndex
            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(pagerView.currentIndex, pagerView: pagerView)
            })
            if(self.arrImagesSelected[lastIndex] == kDeepLinkTypeProfile){
                let strUrl = "\(kDeepLinkURL)\(self.arrImagesSelected[lastIndex])"
                SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
            }
//            if(self.arrImagesSelected[lastIndex] == kDeepLinkTypePeople){
//                let obj = self.storyboard?.instantiateViewController(withIdentifier: "CollaboratorViewController") as! CollaboratorViewController
//                obj.strTitle = "People List"
//                self.present(obj, animated: true, completion: nil)
//            }
        }
    }
    
    func changeCellImageAnimationt(_ sender : Int, pagerView: FSPagerView){
        for row in 0 ..< pagerView.numberOfItems{
            let indexPath = NSIndexPath(row: row, section: 0)
            if let sel = pagerView.collectionView.cellForItem(at: indexPath as IndexPath){
                if(sender == (sel as! FSPagerViewCell).imageView?.tag){
                    (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
                    (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                    (sel as! FSPagerViewCell).imageView?.image = UIImage(named: self.arrImagesSelected[indexPath.row])
                    (sel as! FSPagerViewCell).addLayerInImageView(isTrue : true)
                } else {
                    (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
                    (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                    (sel as! FSPagerViewCell).imageView?.image = UIImage(named: self.arrImages[indexPath.row])
                }
                (sel as! FSPagerViewCell).imageView?.layer.cornerRadius = ((sel as! FSPagerViewCell).imageView?.frame.size.width)!/2
            }
        }
        pagerView.lblCurrentType.text = "\(self.arrImagesSelected[sender])"
    }
}

// MARK:- Extension ScrollView delegate
extension HomeViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        SharedData.sharedInstance.hidePager(controller: self)
        btnFeature.tag = 0
        
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0);
        if pullRatio >= 1 {
            if(SharedData.sharedInstance.isMoreContentAvailable){
                self.footerView?.loadingView.isHidden = false
            }else{
                self.footerView?.loadingView.isHidden = true
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = fabs(diffHeight - frameHeight);
        if pullHeight == 0.0 {
            if(SharedData.sharedInstance.isMoreContentAvailable){
                DispatchQueue.main.async {
                    self.footerView?.loadingView.startLoaderWithAnimation()
                }
                self.getStreamList(type: .bottomScrolling)
            }
        }
    }
    
}
