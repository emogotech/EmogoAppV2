//
//  MyStuffCollectionCell.swift
//  Emogo
//
//  Created by pushpendra on 09/03/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit


class MyStuffCollectionCell: UITableViewCell {
    @IBOutlet weak var profileCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.prepareLayout()
    }
    
    func prepareLayout(){
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        layout.columnCount = 2
        layout.itemRenderDirection = .chtCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight
        // Collection view attributes
        self.profileCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        // Add the waterfall layout to your collection view
        self.profileCollectionView.collectionViewLayout = layout
    }
    
    func prepareCellWithData() {
        self.profileCollectionView.reloadData()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension MyStuffCollectionCell:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return ContentList.sharedInstance.arrayStuff.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamContentCell, for: indexPath) as! StreamContentCell
            // for Add Content
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true
            cell.isExclusiveTouch = true
            cell.prepareLayout(content:content)
            return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            let content = ContentList.sharedInstance.arrayStuff[indexPath.row]
            if content.isAdd == true {
                return CGSize(width: #imageLiteral(resourceName: "add_content_icon").size.width, height: #imageLiteral(resourceName: "add_content_icon").size.height)
            }
//            if selectedIndex != nil {
//                let tempContent = ContentList.sharedInstance.arrayStuff[selectedIndex!.row]
//                return CGSize(width: tempContent.width, height: tempContent.height)
//            }
            return CGSize(width: content.width, height: content.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    /*
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

