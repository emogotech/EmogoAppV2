//
//  MyStuffViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import ESPullToRefresh

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
        self.getMyStuff(type:.start)
        
        // Load More
        
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.stuffCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            print("reload more called")
            self?.getMyStuff(type:.down)
        }
        self.stuffCollectionView.expiredTimeInterval = 20.0
        
    }
    
    
    // MARK: - API Methods
    
    func getMyStuff(type:RefreshType){
        if type == .start{
            HUDManager.sharedInstance.showHUD()
            StreamList.sharedInstance.arrayStream.removeAll()
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
        return ContentList.sharedInstance.arrayContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let content = ContentList.sharedInstance.arrayContent[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
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
        let content = ContentList.sharedInstance.arrayContent[indexPath.row]
    }
    
}
