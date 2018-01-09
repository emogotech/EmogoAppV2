//
//  GiphyViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import FLAnimatedImage

class GiphyViewController: UIViewController {
    @IBOutlet weak var giphyCollectionView: UICollectionView!
    var arrayGiphy = [ContentDAO]()
    var filteredArray = [ContentDAO]()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayout(){
        let client = GPHClient(apiKey: kGiphyAPIKey)
        client.trending { (response, error) in
            
            if let error = error as NSError? {
                // Do what you want with the error
                print(error.localizedDescription)
            }
            //let pagination = response.pagination
            if let response = response, let data = response.data {
                for result in data {
                    let content = ContentDAO(contentData: [:])
                    content.coverImage = result.bitlyGifUrl
                    content.name = result.title
                    content.description = result.caption
                    content.isUploaded = false
                    self.arrayGiphy.append(content)
                }
                self.giphyCollectionView.reloadData()
            } else {
                print("No Results Found")
            }
        }
    }

    func searchGiphy(text:String) {
        let client = GPHClient(apiKey: kGiphyAPIKey)
        client.search(text) { (response, error) in
            
            if let error = error as NSError? {
                // Do what you want with the error
                print(error.localizedDescription)
            }
            //let pagination = response.pagination
            if let response = response, let data = response.data {
                for result in data {
                    let content = ContentDAO(contentData: [:])
                    content.coverImage = result.bitlyGifUrl
                    content.name = result.title
                    content.description = result.caption
                    content.isUploaded = false
                    self.arrayGiphy.append(content)
                }
                self.giphyCollectionView.reloadData()
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


extension GiphyViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    
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
            self.updateSelected(obj: content)
        }
    }
    
    func updateSelected(obj:ContentDAO){
        
    }
    
}

extension GiphyViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let string1 = string
        let string2 = textField.text
        var finalString = ""
        if string.count > 0 {
            finalString = string2! + string1
        }else if string2!.count > 0 {
            finalString = String(string2!.dropLast())
        }
        self.searchGiphy(text: finalString)
        return true
    }
}

