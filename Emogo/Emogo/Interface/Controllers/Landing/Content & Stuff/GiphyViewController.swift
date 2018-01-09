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
    var arrayURL = [String]()

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
        client.search("cats") { (response, error) in
            
            if let error = error as NSError? {
                // Do what you want with the error
                print(error.localizedDescription)
            }
            
            if let response = response, let data = response.data, let pagination = response.pagination {
                for result in data {
                    print(result.contentUrl)
                    print(result.bitlyUrl)
                    print(result.bitlyGifUrl)
                    print(result.title)
                    print(result.caption)
                    self.arrayURL.append(result.bitlyGifUrl!)
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
        return arrayURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_GiphyCell, for: indexPath) as! GiphyCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        let url = URL(string: arrayURL[indexPath.row])
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.thumbnailImage = FLAnimatedImage(gifData: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0 - 12.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = self.giphyCollectionView.cellForItem(at: indexPath) {
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

