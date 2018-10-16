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
    
      //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎
    
    @IBOutlet weak var giphyCollectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnNext: UIButton!

    //MARK: ⬇︎⬇︎⬇︎ Varibales ⬇︎⬇︎⬇︎
    
    var arrayGiphy = [GiphyDAO]()
    var filteredArray = [GiphyDAO]()
    var isEditingEnable:Bool! = true

   //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationWithTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            var arrayIndex = [Int]()
            let tempArray =  ContentList.sharedInstance.arrayContent.filter { $0.isSelected == true }
            ContentList.sharedInstance.arrayContent = tempArray
            for obj in tempArray {
                for (index,temp) in self.arrayGiphy.enumerated() {
                    if temp.url.trim() == obj.coverImage.trim() {
                        arrayIndex.append(index)
                    }
                }
            }
            
            for (index,_) in  self.arrayGiphy.enumerated() {
                if arrayIndex.contains(index) {
                    self.arrayGiphy[index].isSelected = true
                }else {
                    self.arrayGiphy[index].isSelected = false
                }
            }
        }else {
            for (index,_) in  self.arrayGiphy.enumerated() {
                self.arrayGiphy[index].isSelected = false
                self.btnNext.isHidden = true
            }
        }
        self.giphyCollectionView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎
    
    func prepareLayout(){
        ContentList.sharedInstance.arrayContent.removeAll()
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 13.0
        layout.minimumInteritemSpacing = 13.0
        layout.sectionInset = UIEdgeInsetsMake(13, 13, 0, 13)
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
    
  
    //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎
    
    @IBAction func btnActionNext(_ sender: Any) {
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView)
            self.navigationController?.push(viewController: objPreview)
        }else {
            self.showToast(strMSG: kAlert_contentSelect)
        }
        
      
    }
    
    //MARK: ⬇︎⬇︎⬇︎API Methods ⬇︎⬇︎⬇︎
    
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
              
            }
        }
    }
    
     //MARK: ⬇︎⬇︎⬇︎Other Methods ⬇︎⬇︎⬇︎
    
    @objc func textFieldDidChange(textfield:UITextField) {
        if (textfield.text?.trim().length)! > 2 {
            self.arrayGiphy.removeAll()
            self.giphyCollectionView.reloadData()
            self.searchGiphy(text: (textfield.text?.trim())!)
        }
    }

}

//MARK: ⬇︎⬇︎⬇︎ EXTENSION ⬇︎⬇︎⬇︎
//MARK: ⬇︎⬇︎⬇︎ Delegate And Datasource ⬇︎⬇︎⬇︎

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
        cell.layer.cornerRadius = 11.0
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
