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
         self.stuffCollectionView.es.removeRefreshHeader()
        self.stuffCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            print("reload more called")
            self?.getMyStuff(type:.down)
        }
        self.stuffCollectionView.expiredTimeInterval = 20.0
        
    }
    
    @IBAction func btnActionNext(_ sender: Any) {
        HUDManager.sharedInstance.showHUD()
        let group = DispatchGroup()
        for obj in ContentList.sharedInstance.arrayContent {
            group.enter()
            var objImage:ImageDAO!
            if obj.type == "Picture" {
                SharedData.sharedInstance.downloadImage(url: obj.coverImage, handler: { (image) in
                    if image != nil {
                        objImage = ImageDAO(type: .image, image: image!)
                        objImage.isUploaded = true
                        objImage.fileUrl = URL(string: obj.coverImage)
                        GalleryDAO.sharedInstance.Images.append(objImage)
                    }
                    group.leave()
                })
            }else {
                let url = URL(string: obj.coverImage.stringByAddingPercentEncodingForURLQueryParameter()!)
                if  let image = SharedData.sharedInstance.getThumbnailImage(url: url!) {
                    objImage = ImageDAO(type: .video, image: image)
                    objImage.isUploaded = true
                    objImage.fileUrl = URL(string: obj.coverImage)
                    GalleryDAO.sharedInstance.Images.append(objImage)
                    group.leave()
                }
                
            }
         }
        
        group.notify(queue: .main, execute: {
            HUDManager.sharedInstance.hideHUD()
            if   GalleryDAO.sharedInstance.Images.count != 0 {
                let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
                self.navigationController?.pushNormal(viewController: objPreview)
            }
        })
    }
    
    // MARK: - API Methods
    
    func getMyStuff(type:RefreshType){
        if type == .start{
            if ContentList.sharedInstance.arrayContent.count == 0 {
                HUDManager.sharedInstance.showHUD()
            }
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
        let content = ContentList.sharedInstance.arrayContent[indexPath.row]
        content.isSelected = !content.isSelected
       ContentList.sharedInstance.arrayContent[indexPath.row] = content
        self.stuffCollectionView.reloadData()
    }
    
}
