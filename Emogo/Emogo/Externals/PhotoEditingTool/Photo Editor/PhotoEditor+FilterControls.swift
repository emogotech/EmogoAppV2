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
            return  images.count
        }else {
            return  self.filter.arrayMenu.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGradientFilter {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "gradientFilterCell", for: indexPath) as! GradientFilterCell
            
            let objImage = images[indexPath.row]
            cell.prepareCellData(filter: objImage)
           //  cell.prepareCell(filter:self.filter.arrayGradient[indexPath.row])
            return cell

        }else {
            let cell  = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterCell
            cell.prepareCell(filter:self.filter.arrayMenu[indexPath.row])
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isGradientFilter {
//            self.gradientImageView.image = UIImage(named: "filter_gradient_\(1 + indexPath.row).png")
//            self.btnFilterOptionSelected(index:indexPath.row)
            self.canvasImageView.image = self.images[indexPath.row].imgOriginal
        }else {
           self.btnFilterOptionSelected(index:indexPath.row)
        }
    }
 
}
