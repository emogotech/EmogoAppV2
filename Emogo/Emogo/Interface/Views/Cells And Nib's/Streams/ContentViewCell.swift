//
//  ContentViewCell.swift
//  Emogo
//
//  Created by Pushpendra on 14/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class ContentViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblTitleImage: UILabel!
    @IBOutlet weak var lblImageDescription: UILabel!
    @IBOutlet weak var btnPlayIcon: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareView(seletedImage:ContentDAO) {
        
        self.imgCover.image = nil
        self.imgCover.animatedImage = nil
    
        self.lblTitleImage.text = ""
        self.lblImageDescription.text = ""
        if  seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }
        
        
        if seletedImage.type == .image || seletedImage.type == .gif {
           // self.btnPlayIcon.isHidden = true
        }else {
           // self.btnPlayIcon.isHidden = true
        }
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
            seletedImage.imgPreview?.getColors({ (colors) in
                self.imgCover.backgroundColor = colors.primary
                
            })
        }else {
            if seletedImage.type == .image || seletedImage.type == .notes {
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImage)
                
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImage, handler: { (image) in
                    
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.primary
                    })
                })
                
                //self.btnPlayIcon.isHidden = true
            }else   if seletedImage.type == .video {
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.primary
                    })
                })
              //  self.btnPlayIcon.isHidden = false
            }else if seletedImage.type == .link {
                //self.btnPlayIcon.isHidden = true
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.primary
                    })
                })
            }else {
                self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgCover.backgroundColor = colors.primary
                    })
                })
            }
        }
        
    
        self.imgCover.contentMode = .scaleAspectFit
        // disable Like Unlike and save icon
        self.lblTitleImage.addShadow()
        self.lblImageDescription.addShadow()
        self.lblImageDescription.isHidden = false
        self.lblTitleImage.isHidden = false
        if seletedImage.name.trim().isEmpty {
            self.lblTitleImage.isHidden = true
        }else {
            self.lblTitleImage.text = seletedImage.name.trim()
        }
        if seletedImage.description.trim().isEmpty {
            self.lblImageDescription.isHidden = true
        }else {
            self.lblImageDescription.numberOfLines = 0
            
            self.lblImageDescription.text = seletedImage.description.trim()
            let lines = self.lblImageDescription.numberOfVisibleLines
            if lines > 2 {
              //  self.btnMore.isHidden = false
            }else {
               // self.btnMore.isHidden = true
            }
            self.lblImageDescription.numberOfLines = 2
        }
        
        if seletedImage.type == .notes {
            self.lblImageDescription.text = ""
        }
    }
    
}
