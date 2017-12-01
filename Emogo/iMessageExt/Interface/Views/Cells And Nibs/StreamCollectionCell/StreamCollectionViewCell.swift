//
//  StreamCollectionViewCell.swift
//  iMessageExt
//
//  Created by Sushobhit on 29/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class StreamCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var viewAddContent : UIView!
    @IBOutlet weak var lblFoodName : UILabel!
    @IBOutlet weak var imgFood : UIImageView!
  
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
}
