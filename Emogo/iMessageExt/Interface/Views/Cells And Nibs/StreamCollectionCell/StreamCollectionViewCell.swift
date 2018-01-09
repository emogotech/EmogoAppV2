//
//  StreamCollectionViewCell.swift
//  iMessageExt
//
//  Created by Sushobhit on 29/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class StreamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewAddContent   : UIView!
    @IBOutlet weak var imgCover         : UIImageView!
    @IBOutlet weak var lblName          : UILabel!
    @IBOutlet weak var btnPlay          : UIButton!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    func prepareLayout(content:ContentDAO){
        self.imgCover.contentMode = .scaleAspectFill
        if content.isAdd == true {
            viewAddContent.isHidden = false
        }else {
            viewAddContent.isHidden  = true
            self.lblName.text = content.name.trim().capitalized
            
            if content.type == .image {
                self.imgCover.setImageWithURL(strImage: content.coverImage, placeholder: kPlaceholderImage)
                self.btnPlay.isHidden = true
            }else if content.type == .video  {
                self.imgCover.setImageWithURL(strImage: content.coverImageVideo, placeholder: kPlaceholderImage)
                self.btnPlay.isHidden = false
            }else  if content.type == .link {
                self.imgCover.setImageWithURL(strImage: content.coverImageVideo, placeholder: kPlaceholderImage)
                self.btnPlay.isHidden = true
            }
        }
    }
}
