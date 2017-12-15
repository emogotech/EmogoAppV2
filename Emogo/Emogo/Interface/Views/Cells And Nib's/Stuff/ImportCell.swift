//
//  ImportCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class ImportCell: UICollectionViewCell {
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgSelect: UIImageView!

    
    func prepareLayout(content:ImageDAO?){
        guard let content = content  else {
            return
        }
        if content.isSelected {
            imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
        }else {
            imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
        }
        imgCover.image = content.imgPreview
        self.imgCover.backgroundColor = .black
        if content.type == .image {
            self.btnPlay.isHidden = true
        }else {
            self.btnPlay.isHidden = false
        }
    }
    
}
