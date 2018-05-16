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
            cell.imgPreview.tag = indexPath.row
            cell.lblName.text = filter.iconName
            if filter.icon ==  nil {
                self.prepareImageFor(obj: filter, index: indexPath.row) { (objFilter) in
                    
                    DispatchQueue.main.async {
                        if  cell.imgPreview.tag == indexPath.row {
                            if let objFilter = objFilter {
                                self.images[indexPath.row] = objFilter
                                cell.setup(filter: objFilter)
                            }
                        }
                    }
                    
                }
            }else {
                cell.setup(filter: filter)
            }
          
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
            self.prepareImageFor(obj: filter, index: indexPath.row) { (objFilter) in
                DispatchQueue.main.async {
                    if let objFilter = objFilter {
                        self.imageGradientFilter = objFilter.icon
                        self.images[indexPath.row] = objFilter
                        if let image = self.imageGradientFilter {
                            self.canvasImageView.image = image.resize(to: (self.imageToFilter?.size)!)
                        }
                    }
                   
                }
            }
         
        }else {
            self.btnFilterOptionSelected(index:indexPath.row)
        }
    }
    
}

