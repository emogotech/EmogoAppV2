//
//  LinkViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import SwiftLinkPreview

class LinkViewController: UIViewController {
    
    // MARK: - UI Elements

    @IBOutlet weak var txtLink: UITextField!
    @IBOutlet weak var linkCollectionView: UICollectionView!
    
    // MARK: - Variables
    
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationWithTitle()
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        // Attach datasource and delegate
        ContentList.sharedInstance.arrayContent.removeAll()
        self.linkCollectionView.dataSource  = self
        self.linkCollectionView.delegate = self
        linkCollectionView.alwaysBounceVertical = true
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
    
    
    @IBAction func btnConfirmActiion(_ sender: Any) {
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
            return
        }
        if (txtLink.text?.trim().isEmpty)! {
            txtLink.shake()
            return
        }
            
        if let smartUrl = txtLink.text?.smartURL() {
            if Validator.verifyUrl(urlString: smartUrl.absoluteString) {
                HUDManager.sharedInstance.showHUD()
                let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: DisabledCache.instance)
                
                slp.preview(smartUrl.absoluteString,
                            onSuccess: { result in
                                print("\(result)")
                                
                                let content = ContentDAO(contentData: [:])
                                let title = result[SwiftLinkResponseKey.title]
                                let description = result[SwiftLinkResponseKey.description]
                                let imageUrl = result[SwiftLinkResponseKey.image]
                                if let title = title {
                                    content.name = (title as! String).trim().findUrl()
                                }
                                if let description = description {
                                    content.description = (description as! String).trim()
                                }
                                content.coverImage = smartUrl.absoluteString
                                content.type = .link
                                content.isUploaded = false
                                if let imageUrl = imageUrl {
                                    content.coverImageVideo = (imageUrl as! String).trim()
                                    SharedData.sharedInstance.downloadImage(url:  (imageUrl as! String).trim(), handler: { (image) in
                                        if let img =  image {
                                            content.height = Int(img.size.height)
                                            content.width = Int(img.size.width)
                                        }
                                    })
                                    HUDManager.sharedInstance.hideHUD()
                                    self.createContentForExtractedData(content: content)
                                }
                                

                },
                            onError: {
                                error in print("\(error)")
                                HUDManager.sharedInstance.hideHUD()
                                self.showToast(strMSG: error.localizedDescription )

                })
                
                /*
                Readability.parse(url: smartUrl, completion: { data in
                    print(data)
                    if data != nil {
                        let content = ContentDAO(contentData: [:])
                        let title = data?.title
                        let description = data?.description
                        _ = data?.keywords
                        let imageUrl = data?.topImage
                        _ = data?.topVideo
                        if let title = title {
                        print(title.trim().findUrl())
                        content.name = title.trim().findUrl()
                        }
                        if let description = description {
                            content.description = description.trim()
                        }
                        content.coverImage = smartUrl.absoluteString
                        content.type = .link
                        content.isUploaded = false
                        
                        if let imageUrl = imageUrl {
                            content.coverImageVideo = imageUrl.trim()
                            SharedData.sharedInstance.downloadImage(url:  imageUrl.trim(), handler: { (image) in
                                if let img =  image {
                                    content.height = Int(img.size.height)
                                    content.width = Int(img.size.width)
                                }
                            })
                            HUDManager.sharedInstance.hideHUD()
                            self.createContentForExtractedData(content: content)
                        }
                        
                    }else {
                        HUDManager.sharedInstance.hideHUD()
                        self.showToast(strMSG: "Enter valid url.")
                    }
                })
                 */

            }else{
                print("Invalid")
                self.showToast(strMSG: "Enter valid url.")
            }
        }else {
            self.showToast(strMSG: "Enter valid url.")
        }
    }
    
    
    // MARK: - Class Methods

    
    func createContentForExtractedData(content:ContentDAO){
        ContentList.sharedInstance.arrayContent.insert(content, at: 0)
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
            return
        }
    }
    
    // MARK: - API Methods
    
    func getMyLinks(type:RefreshType){
        if type == .start || type == .up {
            HUDManager.sharedInstance.showHUD()
            ContentList.sharedInstance.arrayLink.removeAll()
            self.linkCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetLink(type: type) { (refreshType, errorMsg) in
           
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
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

extension LinkViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension LinkViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ContentList.sharedInstance.arrayLink.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let content = ContentList.sharedInstance.arrayLink[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_LinkListCell, for: indexPath) as! LinkListCell
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
        
        if let cell = self.linkCollectionView.cellForItem(at: indexPath) {
            let content = ContentList.sharedInstance.arrayLink[indexPath.row]
            content.isSelected = !content.isSelected
            ContentList.sharedInstance.arrayLink[indexPath.row] = content
            if content.isSelected {
                (cell as! LinkListCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! LinkListCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            self.updateSelected(obj: content)
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
    }
    
}




