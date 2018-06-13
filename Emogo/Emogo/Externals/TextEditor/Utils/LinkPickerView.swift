//
//  LinkPickerView.swift
//  RichTextEditor
//
//  Created by Pushpendra on 05/06/18.
//  Copyright © 2018 Pushpendra. All rights reserved.
//

import UIKit

protocol LinkPickerViewDelegate {
    func selectedContent(content:ContentDAO)

}

class LinkPickerView: UIView {
    @IBOutlet weak var linkCollectionView: UICollectionView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var delegate:LinkPickerViewDelegate?
    let cellIdentifier = "linkPickerViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareLayouts()
    }
    
    class func instanceFromNib() -> LinkPickerView {
        return  UINib(nibName: "LinkPickerView", bundle: nil).instantiate(withOwner: nil, options: nil).first  as! LinkPickerView
    }
    
    
    func prepareLayouts(){
        // Attach datasource and delegate
       activity.isHidden = true
        self.linkCollectionView.register( UINib(nibName: "LinkPickerViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        self.linkCollectionView.dataSource  = self
        self.linkCollectionView.delegate = self
        ContentList.sharedInstance.arrayContent.removeAll()
        
        self.getMyLinks(type:.start)
        
        // Load More
        self.configureLoadMoreAndRefresh()
    }
    
    func configureLoadMoreAndRefresh(){
        let header:ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshHeaderAnimator(frame: .zero)
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        
        self.linkCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            print("reload more called")
            self?.getMyLinks(type:.down)
        }
        
        self.linkCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            UIApplication.shared.beginIgnoringInteractionEvents()
            self?.getMyLinks(type:.up)
        }
        
        self.linkCollectionView.expiredTimeInterval = 20.0
        
    }
    
    
    func getMyLinks(type:RefreshType){
        if type == .start  {
            activity.isHidden = false
            activity.startAnimating()
            ContentList.sharedInstance.arrayLink.removeAll()
            self.linkCollectionView.reloadData()
        }
        if type == .up  {
            ContentList.sharedInstance.arrayLink.removeAll()
            self.linkCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetLink(type: type) { (refreshType, errorMsg) in
            
            if type == .start {
                self.activity.stopAnimating()
                self.activity.isHidden = true
            }
            if refreshType == .end {
                self.linkCollectionView.es.noticeNoMoreData()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.linkCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.linkCollectionView.es.stopLoadingMore()
            }
            
            self.linkCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
            }
        }
    }

    
    
    

}

extension LinkPickerView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ContentList.sharedInstance.arrayLink.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let content = ContentList.sharedInstance.arrayLink[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! LinkPickerViewCell
        cell.prepareData(content: content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 130.0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = ContentList.sharedInstance.arrayLink[indexPath.row]
        if self.delegate != nil {
            self.delegate?.selectedContent(content: content)
        }
    }
    
    
}
