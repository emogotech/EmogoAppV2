//
//  MyStreamViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class MyStreamViewController: UIViewController {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var myStreamCollectionView: UICollectionView!
    @IBOutlet weak var lblNoResult: UILabel!

    // MARK: - Variables
    private let headerNib = UINib(nibName: "MyStreamHeaderView", bundle: Bundle.main)
    var objContent:ContentDAO!
    var currentType:RefreshType! = .start

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
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        
        // Attach datasource and delegate
        
        self.myStreamCollectionView.dataSource  = self
        self.myStreamCollectionView.delegate = self
        if let layout: IOStickyHeaderFlowLayout = self.myStreamCollectionView.collectionViewLayout as? IOStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 230.0)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 40.0)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: layout.itemSize.height)
            layout.parallaxHeaderAlwaysOnTop = false
            layout.disableStickyHeaders = true
            self.myStreamCollectionView.collectionViewLayout = layout
        }
        myStreamCollectionView.alwaysBounceVertical = true
        self.myStreamCollectionView.register(self.headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader, withReuseIdentifier: kHeader_MyStreamHeaderView)
          self.getMyStreams(type:.start,filter: .myStream)

        // Load More
        
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
       
        self.myStreamCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
                print("reload more called")
                self?.getMyStreams(type:.down,filter: .myStream)
        }
         self.myStreamCollectionView.expiredTimeInterval = 20.0
        
    }

    // MARK: -  Action Methods And Selector
    
    @IBAction func btnActionDone(_ sender: Any) {
        var streamID  = [String]()
        for stream in StreamList.sharedInstance.arrayStream {
            if stream.isSelected == true {
                streamID.append(stream.ID.trim())
            }
        }
        if streamID.count == 0 {
            self.showToast(strMSG: kAlertSelectStream)
            return
        }else {
            self.associateContentToStream(id: streamID)
        }
    }
    @objc func backButtonAction(sender:UIButton){
        self.navigationController?.pop()
    }

    @objc func playButtonAction(sender:UIButton){
        
    }

    // MARK: - Class Methods
    
    
    // MARK: - API Methods
    
    func getMyStreams(type:RefreshType,filter:StreamType){
        if type == .start{
            HUDManager.sharedInstance.showHUD()
            StreamList.sharedInstance.arrayStream.removeAll()
            self.myStreamCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForiPhoneGetStreamList(type: type,filter: filter) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.myStreamCollectionView.es.stopLoadingMore()
                 self.myStreamCollectionView.es.removeRefreshFooter()
            }
            if type == .down {
                self.myStreamCollectionView.es.stopLoadingMore()
            }
          //  self.lblNoResult.isHidden = true
            if StreamList.sharedInstance.arrayStream.count == 0 {
             //   self.lblNoResult.isHidden = false
            }
            self.currentType = refreshType
            self.myStreamCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }

    func associateContentToStream(id:[String]){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForContentAddOnStream(contentID: [objContent.contentID], streams: id) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.showToast(strMSG: kAlertContentAssociatedToStream)
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


extension MyStreamViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return StreamList.sharedInstance.arrayStream.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_MyStreamCell, for: indexPath) as! MyStreamCell
        // for Add Content
        let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
        cell.prepareLayout(stream: stream)
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = UICollectionReusableView()
        switch kind {
        case IOStickyHeaderParallaxHeader:
            let  view:MyStreamHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_MyStreamHeaderView, for: indexPath) as! MyStreamHeaderView
            view.btnBack.addTarget(self, action: #selector(self.backButtonAction(sender:)), for: .touchUpInside)
            view.btnPlay.addTarget(self, action: #selector(self.playButtonAction(sender:)), for: .touchUpInside)
            view.prepareLayout(content: self.objContent)
            return view
        default:
            assert(false, "Unexpected element kind")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stream = StreamList.sharedInstance.arrayStream[indexPath.row]
        stream.isSelected = !stream.isSelected
        StreamList.sharedInstance.arrayStream[indexPath.row] = stream
        self.myStreamCollectionView.reloadData()
    }
    
}

