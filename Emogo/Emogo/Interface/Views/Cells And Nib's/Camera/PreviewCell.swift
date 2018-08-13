//
//  PreviewCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit


class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: FLAnimatedImageView!
    @IBOutlet weak var playIcon: UIButton!


    func setupPreviewWithType(content:ContentDAO){
        
        if content.imgPreview != nil {
            if let image = content.imgPreview {
                print(self.previewImage)
                self.previewImage.image = image
            }
        }else {
            
            if content.type == .image ||  content.type == .notes {
                 self.previewImage.setForAnimatedImage(strImage: content.coverImage) { (_) in
                    
                }
            }else if content.type == .gif {
                 self.previewImage.setForAnimatedImage(strImage: content.coverImage) { (_) in
                    
                }
            }else {
                 self.previewImage.setForAnimatedImage(strImage: content.coverImageVideo) { (_) in
                    
                }
            }
        }
        if content.type == .image {
            self.playIcon.isHidden = true
        }else if content.type == .video{
            self.playIcon.isHidden = false
        }else {
            self.playIcon.isHidden = true
        }
       
        
    }
}
