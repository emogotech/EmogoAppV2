//
//  MyStuffCollectionCell.swift
//  Emogo
//
//  Created by pushpendra on 09/03/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

protocol MyStuffCollectionCellDelegate {
    func selectedItem(index:Int,content:ContentDAO)
}
class MyStuffCollectionCell: UITableViewCell {
    
    @IBOutlet weak var profileCollectionView: ASCollectionView!
    var delegate:MyStuffCollectionCellDelegate?
    var contents = [ContentDAO]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.prepareLayout()
    }
    
    func prepareLayout(){
        profileCollectionView.delegate = self
        profileCollectionView.asDataSource = self
        profileCollectionView.enableLoadMore = false
    }
    
    func prepareCellWithData(contents:[ContentDAO]) {
        self.contents = contents
        self.profileCollectionView.reloadData()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension MyStuffCollectionCell:ASCollectionViewDataSource,ASCollectionViewDelegate {
   
    func numberOfItemsInASCollectionView(_ asCollectionView: ASCollectionView) -> Int {
        return contents.count
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let content = contents[indexPath.row]
        let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
        // for Add Content
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        cell.isExclusiveTouch = true
        cell.prepareLayout(content:content)
        return cell
    }
    
   

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.delegate != nil {
            let content = contents[indexPath.row]
            self.delegate?.selectedItem(index: indexPath.row, content: content)
        }
       /*
         let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
         if content.isAdd {
         btnActionForAddContent()
         }else {
         isEdited = true
         let array =  ContentList.sharedInstance.arrayStuff.filter { $0.isAdd == false }
         ContentList.sharedInstance.arrayContent = array
         if ContentList.sharedInstance.arrayContent.count != 0 {
         let objPreview:ContentViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ContentView) as! ContentViewController
         objPreview.currentIndex = indexPath.row - 1
         self.navigationController?.push(viewController: objPreview)
         }
         }
 */
            
    }
    
  
    /*
     func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
     if destinationIndexPath.row == 0 {
     return
     }
     let contentDest = ContentList.sharedInstance.arrayStuff[sourceIndexPath.row]
     ContentList.sharedInstance.arrayStuff.remove(at: sourceIndexPath.row)
     ContentList.sharedInstance.arrayStuff.insert(contentDest, at: destinationIndexPath.row)
     DispatchQueue.main.async {
     self.profileCollectionView.reloadItems(at: [destinationIndexPath,sourceIndexPath])
     HUDManager.sharedInstance.showHUD()
     //  self.reorderContent(orderArray:ContentList.sharedInstance.arrayStuff)
     }
     }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if currentMenu == .stuff {
            return true
        }else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        if proposedIndexPath.item == 0 {
            return IndexPath(item: 1, section: 0)
        }else {
            return proposedIndexPath
        }
    }
    */
}

