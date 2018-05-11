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
            let filter = images[indexPath.row]
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
            
            let dict:[String:String] = self.filter.arrayFilters[indexPath.row] as! [String : String]
            if let value = dict["value"] {
                
                let numbersRange = value.rangeOfCharacter(from: .decimalDigits)
                let hasNumbers = (numbersRange != nil)
                if hasNumbers  && !value.contains(".png") {
                    let filter = filters[indexPath.row]
                    if renderedFilterBuffer[filter.name] != nil {
                        if let buffer = renderedFilterBuffer[filter.name] {
                            imageBuffer = buffer
                        }
                    }
                }
            }
            self.updateImageView(dict: dict)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
        }else {
            self.btnFilterOptionSelected(index:indexPath.row)
        }
    }
    
}

