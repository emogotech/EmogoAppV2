//
//  PreviewCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var playIcon: UIButton!

    func setupPreviewWithType(content:ContentDAO){
        if content.type == .image {
            self.playIcon.isHidden = true
        }else {
            self.playIcon.isHidden = false
        }
        if content.imgPreview != nil {
            self.previewImage.image = content.imgPreview
        }else {
            self.previewImage.setImageWithURL(strImage: content.coverImage, placeholder: "")
        }
    }
}
