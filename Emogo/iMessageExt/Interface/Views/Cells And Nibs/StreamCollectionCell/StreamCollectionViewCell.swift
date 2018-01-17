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
    @IBOutlet weak var imgCover         : FLAnimatedImageView!
//    @IBOutlet weak var imgGradient        : UIImageView!
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
            self.lblName.minimumScaleFactor = 1.0
            if (self.lblName.text?.trim().isEmpty)! {
               // self.imgGradient.isHidden = true
            }else {
              //  self.imgGradient.isHidden = false
            }
            if content.type == .image {
                self.btnPlay.isHidden = true
                self.imgCover.setForAnimatedImage(strImage:content.coverImage)
            }else if content.type == .video  {
                self.imgCover.setForAnimatedImage(strImage:content.coverImageVideo)
                self.btnPlay.isHidden = false
            }else  if content.type == .link {
                self.imgCover.setForAnimatedImage(strImage:content.coverImageVideo)
                self.btnPlay.isHidden = true
            }else {
                self.btnPlay.isHidden = true
                self.imgCover.setForAnimatedImage(strImage:content.coverImage)
            }
            
        }
    }
    
}

