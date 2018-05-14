//
//  PhotoEditor+FilterControls.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
extension FilterViewController : UICollectionViewDataSource, UICollectionViewDelegate  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isGradientFilter {
            return  self.images.count
        }else {
            return  self.filter.arrayMenu.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGradientFilter {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "gradientFilterCell", for: indexPath) as! GradientFilterCell
             let filter = self.images[indexPath.row]
             self.prepareImageFor(index: indexPath.row)
             cell.setup(filter:filter)
            return cell
            
        }else {
            let cell  = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterCell
            cell.prepareCell(filter:self.filter.arrayMenu[indexPath.row])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isGradientFilter {
            let filter = self.images[indexPath.row]
            self.updateImageView(image: filter.icon)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
        }else {
            self.btnFilterOptionSelected(index:indexPath.row)
        }
    }
    
}

