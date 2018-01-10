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
    
    func prepareLayout(){
        
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        layout.columnCount = 2
        // Collection view attributes
        self.giphyCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.giphyCollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.giphyCollectionView.collectionViewLayout = layout
        
        txtSearch.addTarget(self, action: #selector(self.textFieldDidChange(textfield:)), for: .editingChanged)
        

        let client = GPHClient(apiKey: kGiphyAPIKey)
        client.trending { (response, error) in
            
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
                            print(value)
                            gip = GiphyDAO(previewData: (value as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            
                            if let nameDict = result.jsonRepresentation!["user"]{
                                if let name = (nameDict as! [String:Any])["display_name"] {
                                    gip.name = name as! String
                                }
                            }
                            
                        }
                    }
                    if gip != nil {
                        self.arrayGiphy.append(gip)
                    }
                }
                DispatchQueue.main.async { // Correct
                    self.giphyCollectionView.reloadData()
                }
            } else {
                print("No Results Found")
            }
        }
    }
    
    
    @objc func textFieldDidChange(textfield:UITextField) {
        if (textfield.text?.trim().length)! > 2 {
            self.arrayGiphy.removeAll()
            self.giphyCollectionView.reloadData()
            self.searchGiphy(text: (textfield.text?.trim())!)
        }else{
            self.arrayGiphy.removeAll()
            self.giphyCollectionView.reloadData()
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
                            print(value)
                            gip = GiphyDAO(previewData: (value as! NSDictionary).replacingNullsWithEmptyStrings() as! [String : Any])
                            
                            if let nameDict = result.jsonRepresentation!["user"]{
                                if let name = (nameDict as! [String:Any])["display_name"] {
                                    gip.name = name as! String
                                }
                            }
                            
                        }
                    }
                    if gip != nil {
                        self.arrayGiphy.append(gip)
                    }
                }
                DispatchQueue.main.async { // Correct
                    self.giphyCollectionView.reloadData()
                }
            } else {
                print("No Results Found")
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
        return cell
    }
    
    
   
    
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = self.giphyCollectionView.cellForItem(at: indexPath) {
            let content = self.arrayGiphy[indexPath.row]
            content.isSelected = !content.isSelected
            self.arrayGiphy[indexPath.row] = content
//            if content.isSelected {
//                (cell as! GiphyCell).imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
//            }else {
//                (cell as! GiphyCell).imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
//            }
           // self.updateSelected(obj: content)
        }
    }
 */
    
    func updateSelected(obj:ContentDAO){
        
    }
    
}

extension GiphyViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        return isEditingEnable
    }
}

