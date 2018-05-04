//
//  GradientFilterCell.swift
//  Emogo
//
//  Created by Pushpendra on 04/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class GradientFilterCell: UICollectionViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgPreview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func prepareCellData(filter:GradientfilterDAO) {
        self.lblName.text = filter.name
        self.imgPreview.image = filter.imgPreview
    }
}




class GradientfilterDAO {
    
    var imgPreview:UIImage?
    var imgOriginal:UIImage?
    var name:String!
    init(name:String,imgPreview:UIImage? = nil, imgOriginal:UIImage? = nil ) {
        self.imgPreview = imgPreview
        self.imgOriginal  = imgOriginal
        self.name = name
    }
}
