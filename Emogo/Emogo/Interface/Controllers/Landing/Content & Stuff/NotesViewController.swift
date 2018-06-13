//
//  NotesViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    @IBOutlet weak var notesCollectionView: UICollectionView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblNoResult: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationWithTitle()
        let addNote = UIBarButtonItem(title: "ADD NEW", style: .plain, target: self, action: #selector(self.btnActionForAddNew))
        self.navigationItem.rightBarButtonItem = addNote
    }
    
    

    func prepareLayouts(){
        self.btnNext.isHidden = true
        //  btnNext.isUserInteractionEnabled = false
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.arrayStuff.removeAll()
        // Attach datasource and delegate
        self.notesCollectionView.dataSource  = self
        self.notesCollectionView.delegate = self
        notesCollectionView.alwaysBounceVertical = true
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 0, 8)
        layout.columnCount = 2
        // Collection view attributes
        self.notesCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.notesCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.notesCollectionView.collectionViewLayout = layout
        
        self.configureLoadMoreAndRefresh()
        
        self.getMyStuff(type:.start)

    }
    
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.notesCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            print("reload more called")
            self?.getMyStuff(type:.down)
        }
        
        self.notesCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            self?.getMyStuff(type:.up)
        }
        
        self.notesCollectionView.expiredTimeInterval = 20.0
        
    }
    
    
    @IBAction func btnActionNext(_ sender: Any) {
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
        }else {
            self.showToast(strMSG: kAlert_contentSelect)
        }
    }
    
    
    @objc func btnSelectAction(button : UIButton)  {
        let index   =   button.tag
        let indexPath   =   IndexPath(item: index, section: 0)
        if let cell = self.notesCollectionView.cellForItem(at: indexPath) {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            content.isSelected = !content.isSelected
            if content.isSelected {
                (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            self.updateSelected(obj: content)
        }
    }
    
   @objc func btnActionForAddNew(){
    let controller = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_CreateNotesView)
    self.navigationController?.push(viewController: controller)
    }
    
    
    func getMyStuff(type:RefreshType) {
        if type == .start  {
            HUDManager.sharedInstance.showHUD()
            ContentList.sharedInstance.arrayStuff.removeAll()
            self.notesCollectionView.reloadData()
        }
        if type == .up  {
            ContentList.sharedInstance.arrayStuff.removeAll()
            self.notesCollectionView.reloadData()
        }
        
        APIServiceManager.sharedInstance.apiForGetStuffList(type: type,contentType: StuffType.Notes ) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.notesCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.notesCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.notesCollectionView.es.stopLoadingMore()
            }
            
            self.lblNoResult.isHidden = true
            self.btnNext.isHidden = true
            if ContentList.sharedInstance.arrayStuff.count == 0 {
                self.lblNoResult.text  = "No Stuff Found"
                self.lblNoResult.minimumScaleFactor = 1.0
                self.lblNoResult.isHidden = false
                self.btnNext.isHidden = true
            }
            
            self.notesCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
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
            btnNext.isHidden = false
        }else {
            btnNext.isHidden = true
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

extension NotesViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return ContentList.sharedInstance.arrayStuff.count
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
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(self.btnSelectAction(button:)), for: .touchUpInside)
        cell.prepareLayout(content:content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
        return CGSize(width: content.width, height: content.height)
}
}
