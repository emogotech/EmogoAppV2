//
//  MyStuffViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class MyStuffViewController: UIViewController {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var stuffCollectionView: UICollectionView!
    
    
    // MARK: - Variables


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
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        
        // Attach datasource and delegate
        self.stuffCollectionView.dataSource  = self
        self.stuffCollectionView.delegate = self
        stuffCollectionView.alwaysBounceVertical = true
        HUDManager.sharedInstance.showHUD()
        self.getMyStuff(type:.start)
        
        // Load More
        
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
         self.stuffCollectionView.es.removeRefreshHeader()
        self.stuffCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            print("reload more called")
            self?.getMyStuff(type:.down)
        }
        self.stuffCollectionView.expiredTimeInterval = 20.0
        
    }
    
    @IBAction func btnActionNext(_ sender: Any) {
        if let parent = self.parent {
            if arraySelectedContent?.count != 0 {
            HUDManager.sharedInstance.showHUD()
                (parent as! ContainerViewController).updateConatentForGallery(array: arrayAssests!, completed: { (result) in
                HUDManager.sharedInstance.hideHUD()
                 ContentList.sharedInstance.arrayContent.removeAll()
                let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
                ContentList.sharedInstance.arrayContent = arraySelectedContent
                objPreview.strPresented = "TRUE"
                let nav = UINavigationController(rootViewController: objPreview)
                self.parent?.present(nav, animated: true, completion: nil)
            })
//            arraySelectedContent?.removeAll()
//            arrayAssests?.removeAll()
            }
        }
       
    }
    
    // MARK: - API Methods
    
    func getMyStuff(type:RefreshType){
        if type == .start{
            ContentList.sharedInstance.arrayStuff.removeAll()
            self.stuffCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetStuffList(type: type) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.stuffCollectionView.es.stopLoadingMore()
                self.stuffCollectionView.es.removeRefreshFooter()
            }
            if type == .down {
                self.stuffCollectionView.es.stopLoadingMore()
            }
            
                let array = arraySelectedContent
                for i in 0..<ContentList.sharedInstance.arrayStuff.count {
                    let con = ContentList.sharedInstance.arrayStuff[i]
                    if array?.count != 0 {
                        if let index =  array?.index(where: {$0.contentID.trim() == con.contentID.trim()}) {
                            if array![index].isSelected == true {
                                con.isSelected = true
                                ContentList.sharedInstance.arrayStuff[i] = con
                            }
                        }
                    }
                }
            
            self.stuffCollectionView.reloadData()
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


extension MyStuffViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        cell.prepareLayout(content:content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = self.stuffCollectionView.cellForItem(at: indexPath) {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            content.isSelected = !content.isSelected
            ContentList.sharedInstance.arrayStuff[indexPath.row] = content
            if content.isSelected {
               (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! MyStuffCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            self.updateSelected(obj: content)
        }
        
    }
    
    func updateSelected(obj:ContentDAO){
        
        if let index =  arraySelectedContent?.index(where: {$0.contentID.trim() == obj.contentID.trim()}) {
                arraySelectedContent?.remove(at: index)
            }else {
                if obj.isSelected  {
                    arraySelectedContent?.append(obj)
                }
            }
    }
    
}


