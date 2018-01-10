//
//  StreamContentCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class StreamContentCell: UICollectionViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewCard: CardView!
    @IBOutlet weak var imgAdd: UIImageView!

    func prepareLayout(content:ContentDAO){
         self.imgCover.contentMode = .scaleAspectFill
        if content.isAdd == true {
            imgAdd.isHidden = false
            viewCard.isHidden = true
            self.accessibilityLabel = "StreamContentCellAddContent"
        }else {
            self.accessibilityLabel = "StreamContentCellContent"
            imgAdd.isHidden = true
            viewCard.isHidden = false
            self.lblName.text = content.name.trim().capitalized
            self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
            if content.type == .image {
                self.btnPlay.isHidden = true
                self.imgCover.setImageWithURL(strImage: content.coverImage, placeholder: kPlaceholderImage)
            }else if content.type == .video  {
                self.imgCover.setImageWithURL(strImage: content.coverImageVideo, placeholder: kPlaceholderImage)
                self.btnPlay.isHidden = false
            }else  if content.type == .link {
                self.imgCover.setImageWithURL(strImage: content.coverImageVideo, placeholder: kPlaceholderImage)
                self.btnPlay.isHidden = true
            }else {
                self.btnPlay.isHidden = true
                self.imgCover.setForAnimatedImage(strImage:content.coverImage)
            }
        }
     
    }
}
