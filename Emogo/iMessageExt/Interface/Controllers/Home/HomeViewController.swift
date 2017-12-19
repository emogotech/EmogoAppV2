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
    
    @IBOutlet weak var pagerContent     : UIView!
    @IBOutlet weak var searchView       : UIView!
    
    @IBOutlet weak var searchText       : UITextField!
    
    @IBOutlet weak var btnFeature       : UIButton!
    
    @IBOutlet weak var lblNoResult      : UILabel!
    
    // MARK: - Varibales
    var arrayStreams                    = [StreamDAO]()
    var hudView                         : LoadingView!
    var hudRefreshView                  : LoadingView!
    var lastIndex                       : Int = 10
    var refresher                       : UIRefreshControl?
    var footerView                      : HomeCollectionReusableView?
    var streamType                      : StreamType!
    var paging                          : Int = 1;
    var currentIndex                    : Int = 1
    var fectchingStreamData             : Bool = false
    
    fileprivate let arrImages = ["PopularDeselected","MyStreamsDeselected","FeatutreDeselected","emogoDeselected","ProfileDeselected","PeopleDeselect"]
    
    fileprivate let arrImagesSelected = ["Popular","My Streams","Featured","Emogo Streams","Profile","People"]
    
    // MARK:- Life-cycle method	s
    override func viewDidLoad() {
        super.viewDidLoad()
        streamType  = StreamType.featured
        setupLoader()
        self.perform(#selector(prepareLayout), with: nil, afterDelay: 0.01)
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: iMsgNotificationManageScreen), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadStreamData), name: NSNotification.Name(rawValue: iMsgNotificationReloadContenData), object: nil)
        
    }
    
    @objc func reloadStreamData(){
         self.getStreamList(type:.start,filter:self.streamType)
    }
    
    // MARK:- prepareLayout
    @objc func prepareLayout() {
        self.searchView.layer.cornerRadius = 15
        self.searchView.clipsToBounds = true
        streamType = StreamType.featured
        self.getStreamList(type:.start,filter:.featured)
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
    
    func preparePagerFrame() {
        let pagerView = FSPagerView()
        pagerView.frame = pagerContent.bounds
        pagerContent.addSubview(pagerView)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 0)
        pagerView.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 0)
        pagerView.currentIndex = 2
        lastIndex = 2
        pagerView.itemSize = CGSize(width: 120, height: 100)
        pagerView.transformer = FSPagerViewTransformer(type:.ferrisWheel)
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.isHidden = false
        pagerView.isAddBackground = false
        pagerView.isAddTitle = false
        pagerView.layer.contents = UIImage(named: "grad-bottom")?.cgImage
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
        layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/2 - 12.0, height: self.collectionStream.frame.size.width/2 - 12.0)
       
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
            pagerContent.isHidden = true
            btnFeature.tag = 0
        }
    }
    
    @objc func changeUIInBackground(){
        if(SharedData.sharedInstance.isMessageWindowExpand) {
            pagerContent.isHidden = false
            
        }
    }
    
    @objc func pullToDownAction() {
        if StreamList.sharedInstance.arrayStream.count > 0 {
            self.refresher?.frame = CGRect(x: 0, y: 0, width: self.collectionStream.frame.size.width, height: 100)
            SharedData.sharedInstance.nextStreamString = ""
            hudRefreshView.startLoaderWithAnimation()
            self.getStreamList(type:.up,filter:self.streamType)
        }
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
        if !checkIsAvailableFilter() {
             preparePagerFrame()
        }
       
        self.setupCollectionProperties()
        if(SharedData.sharedInstance.isMessageWindowExpand) {
            pagerContent.isHidden = false
            btnFeature.tag = 1
        }
        self.setupRefreshLoader()
    }
    
    func checkIsAvailableFilter() -> Bool {
        for subView in pagerContent.subviews {
            if subView.isKind(of: FSPagerView.self){
                return true
            }
        }
        return false
    }
    
    // MARK:- Action methods
    @IBAction func btnSearchAction(_ sender: UIButton){
        self.searchText.resignFirstResponder()
    }
    
    @IBAction func btnFeaturedTap(_ sender: UIButton){
        if(btnFeature.tag == 1){
            pagerContent.isHidden = true
            btnFeature.tag = 0
        } else {
            if(SharedData.sharedInstance.isMessageWindowExpand) {
                pagerContent.isHidden = false
                btnFeature.tag = 1
            }else {
                NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyleExpand), object: nil)
            }
        }
    }
    
    // MARK: - API Methods
    func getStreamList(type:RefreshType,filter:StreamType){
        if Reachability.isNetworkAvailable() {
            if type == .start {
                StreamList.sharedInstance.arrayStream.removeAll()
                self.collectionStream.reloadData()
                self.hudView.startLoaderWithAnimation()
            }
            else if  type == .up {
                StreamList.sharedInstance.arrayStream.removeAll()
                self.collectionStream.reloadData()
            }
            APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
                
                self.streaminputDataType(type: type)
                self.lblNoResult.isHidden = true
                if StreamList.sharedInstance.arrayStream.count == 0 {
                    self.lblNoResult.isHidden = false
                }
//                if(type == .start || type == .up){
                    self.arrayStreams = StreamList.sharedInstance.arrayStream!
//                }
//                else {
//                    for stream in StreamList.sharedInstance.arrayStream!{
//                        self.arrayStreams.append(stream)
//                    }
//                }
                self.collectionStream.reloadData()
                if !(errorMsg?.isEmpty)! {
                    // self.showToast(type: .success, strMSG: errorMsg!)
                }
            }
        }
        else{
            self.showToastIMsg(type: .error, strMSG: kAlertNetworkErrorMsg)
        }
    }
    
    func streaminputDataType(type:RefreshType){
        if(SharedData.sharedInstance.isMoreContentAvailable){
            self.fectchingStreamData = true
        }
        else {
            self.fectchingStreamData = false
        }
        if(type == .down) {
            self.footerView?.loadingView.stopLoaderWithAnimation()
        } else  if(type == .start){
            self.hudView.stopLoaderWithAnimation()
            self.resignRefreshLoader()
        } else{
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
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: iMsgSegue_HomeCollection, for: indexPath) as! HomeCollectionViewCell
        
        let stream = self.arrayStreams[indexPath.row]
        cell.prepareLayouts(stream: stream)
        cell.imgStream.tag = indexPath.row
        cell.btnView.tag = indexPath.row
        cell.btnView.addTarget(self, action: #selector(self.btnViewAction(_:)), for: UIControlEvents.touchUpInside)
        cell.btnShare.tag = indexPath.row
        cell.btnShare.addTarget(self, action: #selector(self.btnShareAction(_:)), for: UIControlEvents.touchUpInside)
        
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
        if(SharedData.sharedInstance.isMessageWindowExpand){
             NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyleCompact), object: nil)
        }
        let stream = self.arrayStreams[sender.tag]
        self.sendMessage(content: stream, sender: sender.tag)
    }
    
    func sendMessage(content:StreamDAO, sender:Int){
        let indexPath = NSIndexPath(row: sender, section: 0)
        if let sel = self.collectionStream.cellForItem(at: indexPath as IndexPath){
            let message = MSMessage()
            let layout = MSMessageTemplateLayout()
            layout.caption = content.Title.trim()
            layout.subcaption = "by \(content.Author!)"
            layout.image  = (sel as! HomeCollectionViewCell).imgStream.image
            message.layout = layout
            SharedData.sharedInstance.savedConversation?.insert(message, completionHandler: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        pagerContent.isHidden = true
        btnFeature.tag = 0
        self.changeCellImageAnimation(indexPath.row)
    }
    
    func changeCellImageAnimation(_ sender : Int) {
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
    
    func resetAllCells() {
        for row in 0 ..< self.collectionStream.numberOfItems(inSection: 0){
            let indexPath = NSIndexPath(row: row, section: 0)
            if let sel = self.collectionStream.cellForItem(at: indexPath as IndexPath){
                 (sel as! HomeCollectionViewCell).viewShowHide.isHidden = true
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
            pagerContent.isHidden = true
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
            
            switch  index {
                
            case 0:
                lastIndex = pagerView.currentIndex
                self.streamType = StreamType.populer
                self.getStreamList(type: .start, filter: self.streamType)
                break
                
            case 1:
                lastIndex = pagerView.currentIndex
                self.streamType = StreamType.myStream
                self.getStreamList(type: .start, filter: self.streamType)
                break
                
            case 2:
                lastIndex = pagerView.currentIndex
                self.streamType = StreamType.featured
                self.getStreamList(type: .start, filter: self.streamType)
                break
                
            case 3:
                lastIndex = pagerView.currentIndex
                self.streamType = StreamType.emogoStreams
                self.getStreamList(type: .start, filter: self.streamType)
                break
                
            case 4:
//                lastIndex = pagerView.currentIndex
                let strUrl = "\(kDeepLinkURL)\(self.arrImagesSelected[index])"
                SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
                break
                
            case 5:
                  showAlert(index, pagerView: pagerView)
               
                break
                
            default :
                break
            }
            

            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(index, pagerView: pagerView)
            })
            
        }
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        if(lastIndex != pagerView.currentIndex) {
            
            switch  pagerView.currentIndex {
                
            case 0:
                lastIndex = pagerView.currentIndex
                self.streamType = StreamType.populer
                self.arrayStreams.removeAll()
                self.collectionStream.reloadData()
                self.getStreamList(type: .start, filter: self.streamType)
                break
                
            case 1:
                lastIndex = pagerView.currentIndex
                self.streamType = StreamType.myStream
                self.arrayStreams.removeAll()
                self.collectionStream.reloadData()
                self.getStreamList(type: .start, filter: self.streamType)
                break
                
            case 2:
                lastIndex = pagerView.currentIndex
                self.streamType = StreamType.featured
                self.arrayStreams.removeAll()
                self.collectionStream.reloadData()
                self.getStreamList(type: .start, filter: self.streamType)
                break
                
            case 3:
                lastIndex = pagerView.currentIndex
                self.streamType = StreamType.emogoStreams
                self.arrayStreams.removeAll()
                self.collectionStream.reloadData()
                self.getStreamList(type: .start, filter: self.streamType)
                break
                
            case 4:

                let strUrl = "\(kDeepLinkURL)\(self.arrImagesSelected[lastIndex])"
                SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
                break
                
            case 5:
                showAlert(pagerView.currentIndex, pagerView: pagerView)
                break
                
            default :
                break
            }
            UIView.animate(withDuration: 0.7, animations: {
                self.changeCellImageAnimationt(pagerView.currentIndex, pagerView: pagerView)
            })
        }
    }
    
    func changeCellImageAnimationt(_ sender : Int, pagerView: FSPagerView) {
        for row in 0 ..< pagerView.numberOfItems {
            let indexPath = NSIndexPath(row: row, section: 0)
            if let sel = pagerView.collectionView.cellForItem(at: indexPath as IndexPath) {
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
        let strLbl = "\(self.arrImagesSelected[sender])"
        pagerView.lblCurrentType.text = strLbl.uppercased()
        btnFeature.setTitle(pagerView.lblCurrentType.text, for: .normal)
        resetAllCells()
    }
    
    func showAlert(_ index: Int, pagerView:FSPagerView) {
        let alert = UIAlertController(title: iMsgAlertTitle_Confirmation, message: iMsgAlert_ConfirmationDescription, preferredStyle: UIAlertControllerStyle.alert)
       
        
        alert.addAction(UIAlertAction(title: iMsgAlert_CancelTitle, style: UIAlertActionStyle.default, handler: { action in
            switch action.style{
            case .default:
                UIView.animate(withDuration: 0.7, animations: {
                    pagerView.currentIndex = self.lastIndex
                    let strLbl = "\(self.arrImagesSelected[pagerView.currentIndex])"
                    pagerView.lblCurrentType.text = strLbl.uppercased()
                    self.btnFeature.setTitle(pagerView.lblCurrentType.text, for: .normal)
                    pagerView.reloadData()
                })
                break
            case .cancel:
                break
            case .destructive:
                break
            }}))
        
        alert.addAction(UIAlertAction(title: iMsgAlert_ConfirmationTitle, style: UIAlertActionStyle.cancel, handler: { action in
            switch action.style{
            case .cancel:
                switch index {
                case 4:
                    break
                case 5:
                    self.lastIndex = index
                    let strUrl = "\(kDeepLinkURL)\(kDeepLinkTypePeople)"
                    SharedData.sharedInstance.presentAppViewWithDeepLink(strURL: strUrl)
                    break
                    
                default:
                    break
                }
                break
            case .default:
                break
            case .destructive:
                break
            }}))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK:- Extension ScrollView delegate
extension HomeViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        pagerContent.isHidden = true
        btnFeature.tag = 0
        
        let threshold   = 100.0
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let diffHeight = contentHeight - contentOffset
        let frameHeight = scrollView.bounds.size.height
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold)
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0)
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
                self.getStreamList(type:.down,filter:self.streamType)
            }
        }
    }
}
