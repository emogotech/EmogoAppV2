//
//  LinkViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import ReadabilityKit

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
    
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        // Attach datasource and delegate
        self.linkCollectionView.dataSource  = self
        self.linkCollectionView.delegate = self
        linkCollectionView.alwaysBounceVertical = true
        self.getMyLinks(type:.start)
        
        // Load More
        
        let  footer: ESRefreshProtocol & ESRefreshAnimatorProtocol = RefreshFooterAnimator(frame: .zero)
        self.linkCollectionView.es.removeRefreshHeader()
        self.linkCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            print("reload more called")
            self?.getMyLinks(type:.down)
        }
        self.linkCollectionView.expiredTimeInterval = 20.0
        
    }
    
    @IBAction func btnConfirmActiion(_ sender: Any) {
        if Validator.verifyUrl(urlString: txtLink.text!) {
            let articleUrl = URL(string: txtLink.text!)
            Readability.parse(url: articleUrl!, completion: { data in
                print(data)
                let title = data?.title
                let description = data?.description
                let keywords = data?.keywords
                let imageUrl = data?.topImage
                let videoUrl = data?.topVideo
                print(title)
                print(description)
                print(keywords)
                print(imageUrl)
                print(videoUrl)
                let content = ContentDAO(contentData: [:])
                if let title = title {
                    content.name = title.trim()
                }
                if let description = description {
                    content.description = description.trim()
                }
                if let imageUrl = imageUrl {
                    content.coverImageVideo = imageUrl.trim()
                }
                content.coverImage = articleUrl?.absoluteString
                content.type = .link
                content.isUploaded = false
                self.createContentForExtractedData(content: content)
            })
        }else{
            print("Invalid")
        }
    }
    
    
    // MARK: - Class Methods

    
    func createContentForExtractedData(content:ContentDAO){
        if let parent = self.parent {
            arraySelectedContent?.append(content)
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
                arraySelectedContent?.removeAll()
                arrayAssests?.removeAll()
            }
        }
        
    }
    
    // MARK: - API Methods
    
    func getMyLinks(type:RefreshType){
        if type == .start{
            ContentList.sharedInstance.arrayLink.removeAll()
            self.linkCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetLink(type: type) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.linkCollectionView.es.stopLoadingMore()
                self.linkCollectionView.es.removeRefreshFooter()
            }
               if type == .down {
                 self.linkCollectionView.es.stopLoadingMore()
               }
                let array = arraySelectedContent
                for i in 0..<ContentList.sharedInstance.arrayLink.count {
                    let con = ContentList.sharedInstance.arrayLink[i]
                    if array?.count != 0 {
                        if let index =  array?.index(where: {$0.contentID.trim() == con.contentID.trim()}) {
                            if array![index].isSelected == true {
                                con.isSelected = true
                                ContentList.sharedInstance.arrayLink[i] = con
                            }
                        }
                    }
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
        
        if let cell = self.linkCollectionView.cellForItem(at: indexPath) {
            let content = ContentList.sharedInstance.arrayLink[indexPath.row]
            content.isSelected = !content.isSelected
            ContentList.sharedInstance.arrayLink[indexPath.row] = content
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
            print(arrayAssests?.count)
        }
    }
    
}

