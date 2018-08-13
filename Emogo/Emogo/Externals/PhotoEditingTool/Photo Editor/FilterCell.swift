//
//  FilterCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgView.contentMode = .scaleAspectFit
    }
    
    
    func prepareCell(filter:Filter) {
        lblTitle.text = filter.iconName
       // self.imgView.image = filter.icon?.resize(to: CGSize(width: imgView.bounds.size.width*2, height: imgView.bounds.size.height*2))
        self.imgView.image = filter.icon
    }

}
