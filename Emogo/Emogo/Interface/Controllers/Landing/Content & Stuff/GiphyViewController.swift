//
//  GiphyViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import GiphyCoreSDK

class GiphyViewController: UIViewController {
    @IBOutlet weak var giphyCollectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnNext: UIButton!

    var arrayGiphy = [GiphyDAO]()
    var filteredArray = [GiphyDAO]()
    var isEditingEnable:Bool! = true


    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationWithTitle()
    }
    
    func prepareLayout(){
        ContentList.sharedInstance.arrayContent.removeAll()
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        layout.columnCount = 2
        // Collection view attributes
        self.giphyCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.giphyCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.giphyCollectionView.collectionViewLayout = layout
        
        txtSearch.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
        HUDManager.sharedInstance.showHUD()
         self.getTrendingList()
        btnNext.isHidden = true
    }
    
    @objc func textFieldDidChange(textfield:UITextField) {
        if (textfield.text?.trim().length)! > 2 {
            self.arrayGiphy.removeAll()
            self.giphyCollectionView.reloadData()
            self.searchGiphy(text: (textfield.text?.trim())!)
        }
    }
    
    @IBAction func btnActionNext(_ sender: Any) {
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
        }else {
            self.showToast(strMSG: kAlert_contentSelect)
        }
        
        /*
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
            }else {
                self.showToast(strMSG: kAlert_contentSelect)
            }
        }
 */
    }
    func getTrendingList(){
        let client = GPHClient(apiKey: kGiphyAPIKey)
        client.trending(.gif, offset: 0, limit: 40, rating: .ratedPG13) { (response, error) in
            
            DispatchQueue.main.async { // Correct
                HUDManager.sharedInstance.hideHUD()
            }
            if let error = error as NSError? {
                // Do what you want with the error
                print(error.localizedDescription)
            }
            //let pagination = response.pagination
            if let response = response, let data = response.data {
                self.arrayGiphy.removeAll()
                for result in data {
                    var gip:GiphyDAO!
                    
                    if let obj = result.jsonRepresentation!["images"]{
                        let dict:[String:Any] =  obj as! [String:Any]
                        if let value = dict["fixed_width"] {
                            gip = GiphyDAO(previewData: (value as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            
                            if let nameDict = result.jsonRepresentation!["user"]{
                                if let name = (nameDict as! [String:Any])["display_name"] {
                                    gip.name = name as! String
                                }
                            }
                            
                        }
                        
                        if let originalvalue = dict["original"] {
                            if let Originalurl = (originalvalue as! [String:Any])["url"] {
                                gip.originalUrl = Originalurl as! String
                            }
                        }
                        
                    }
                    if gip != nil {
                        if result.caption != nil {
                            gip.caption = result.caption
                        }
                        self.arrayGiphy.append(gip)
                    }
                }
                DispatchQueue.main.async { // Correct
                    self.giphyCollectionView.reloadData()
                }
            } else {
                //print("No Results Found")
            }
        }
    }
    func searchGiphy(text:String) {
        isEditingEnable = false
        let client = GPHClient(apiKey: kGiphyAPIKey)
        client.search(text) { (response, error) in
            

            self.isEditingEnable = true
            if let error = error as NSError? {
                // Do what you want with the error
                print(error.localizedDescription)
            }
            //let pagination = response.pagination
            if let response = response, let data = response.data {
                self.arrayGiphy.removeAll()
                for result in data {
                    var gip:GiphyDAO!
                    
                    if let obj = result.jsonRepresentation!["images"]{
                        let dict:[String:Any] =  obj as! [String:Any]
                        if let value = dict["fixed_width"] {
                            gip = GiphyDAO(previewData: (value as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            
                            if let nameDict = result.jsonRepresentation!["user"]{
                                if let name = (nameDict as! [String:Any])["display_name"] {
                                    gip.name = name as! String
                                }
                            }
                        }
                        if let originalvalue = dict["original"] {
                            if let Originalurl = (originalvalue as! [String:Any])["url"] {
                                gip.originalUrl = Originalurl as! String
                            }
                        }
                        
                    }
                    if gip != nil {
                        if result.caption != nil {
                            gip.caption = result.caption
                        }
                        self.arrayGiphy.append(gip)
                    }
                }
                DispatchQueue.main.async { // Correct
                    self.giphyCollectionView.reloadData()
                }
            } else {
               // print("No Results Found")
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


extension GiphyViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let item = self.arrayGiphy[indexPath.row]
        return CGSize(width: item.width, height: item.hieght)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayGiphy.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_GiphyCell, for: indexPath) as! GiphyCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        let content = self.arrayGiphy[indexPath.row]
        cell.prepareLayout(content:content)
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(self.btnSelectAction(button:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = self.arrayGiphy[indexPath.row]
        self.gifPreview(content: content)
    }
    
    @objc func btnSelectAction(button : UIButton)  {
        let index   =   button.tag
        let indexPath   =   IndexPath(item: index, section: 0)
        if let cell = self.giphyCollectionView.cellForItem(at: indexPath) {
            let content = self.arrayGiphy[indexPath.row]
            content.isSelected = !content.isSelected
            self.arrayGiphy[indexPath.row] = content
            if content.isSelected {
                (cell as! GiphyCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
            }else {
                (cell as! GiphyCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
            }
            let insertNew = ContentDAO(contentData: [:])
            insertNew.description = content.caption
            insertNew.name = content.name
            insertNew.type = .gif
            insertNew.coverImage = content.url
            insertNew.isUploaded = false
            insertNew.height = content.hieght
            insertNew.width = content.width
            insertNew.isSelected = content.isSelected
            insertNew.coverImageVideo = content.originalUrl
            self.updateSelected(obj:insertNew)
        }
    }
    
    func gifPreview(content : GiphyDAO){
        let insertNew = ContentDAO(contentData: [:])
        insertNew.description = content.caption
        insertNew.name = content.name
        insertNew.type = .gif
        insertNew.coverImage = content.url
        insertNew.isUploaded = false
        insertNew.height = content.hieght
        insertNew.width = content.width
        insertNew.isSelected = content.isSelected
        insertNew.coverImageVideo = content.originalUrl
        let obj:ShowPreviewViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ShowPreviewView) as! ShowPreviewViewController
        obj.objContent = insertNew
        self.present(obj, animated: false, completion: nil)
    }
    
    
    func updateSelected(obj:ContentDAO){
        
        if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.coverImage.trim() == obj.coverImage.trim()}) {
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
    
}

extension GiphyViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !(textField.text?.trim().isEmpty)! {
            self.searchGiphy(text: (textField.text?.trim())!)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return isEditingEnable
    }
}
