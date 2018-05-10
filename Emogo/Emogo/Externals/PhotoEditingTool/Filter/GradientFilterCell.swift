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
  
    
    func setup(filter:Filter) {
            lblName.text = filter.iconName
            self.imgPreview.image = filter.icon
    }
}




class GradientfilterDAO {
    
    var imgPreview:UIImage = #imageLiteral(resourceName: "stream-card-placeholder")
    var imgOriginal:UIImage = #imageLiteral(resourceName: "stream-card-placeholder")
    var isFileRecieved:Bool! = false
    var name:String!
    init(name:String ) {
        self.name = name
    }
}

