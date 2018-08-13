//
//  AddContentCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class AddContentCell: UICollectionViewCell {
    
}


class LinkListCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgSelect: UIImageView!
    @IBOutlet weak var btnSelect: UIButton!

    func prepareLayout(content:ContentDAO?){
        guard let content = content  else {
            return
        }
        self.lblTitle.text = content.name.trim()
        self.lblDescription.text =  content.description.trim()
        self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
        //  self.imgCover.backgroundColor = .black
        imgCover.contentMode = .scaleAspectFill
        if content.isSelected {
            imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
        }else {
            imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
        }
        self.imgCover.image = nil
         self.viewContent.isHidden = true
        self.imgCover.setForAnimatedImage(strImage: content.coverImageVideo) { (_) in
            self.viewContent.isHidden = false
        }
    }
}

