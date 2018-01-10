//
//  MyStuffCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class MyStuffCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgSelect: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    
   

    func prepareLayout(content:ContentDAO?){
        guard let content = content  else {
            return
        }
        self.lblTitle.text = content.name.trim().capitalized
        self.lblDescription.text =  content.description.trim()
        self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
      //  self.imgCover.backgroundColor = .black
        imgCover.contentMode = .scaleAspectFill
        if content.isSelected {
            imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
        }else {
            imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
        }
        
        if content.type == .image {
            self.btnPlay.isHidden = true
            self.imgCover.setForAnimatedImage(strImage:content.coverImage)
        }else if content.type == .video {
            self.imgCover.image = nil
            self.imgCover.setForAnimatedImage(strImage:content.coverImageVideo)
            self.btnPlay.isHidden = false
        }else if content.type == .link {
            self.imgCover.image = nil
            self.imgCover.setForAnimatedImage(strImage:content.coverImageVideo)
            self.btnPlay.isHidden = true
        }else {
            self.imgCover.setForAnimatedImage(strImage:content.coverImage)
        }
    }
}
