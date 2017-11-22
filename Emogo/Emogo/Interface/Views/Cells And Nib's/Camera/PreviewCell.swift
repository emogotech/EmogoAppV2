//
//  PreviewCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

enum PreviewType:String
{
    case image = "1"
    case video = "2"
}

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var playIcon: UIButton!

    func setupPreviewWithType(type:PreviewType, image:UIImage){
        if type == .image {
            self.playIcon.isHidden = true
        }else {
            self.playIcon.isHidden = false
        }
        self.previewImage.image = image
    }
}
