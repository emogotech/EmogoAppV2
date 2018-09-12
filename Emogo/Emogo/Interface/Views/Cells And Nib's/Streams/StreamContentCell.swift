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
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewCard: CardView!
    @IBOutlet weak var imgAdd: UIImageView!

    
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        imgCover.image = nil
//    }
    
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
            self.lblName.text = content.name.trim()
            self.lblName.minimumScaleFactor = 1.0
            if (self.lblName.text?.trim().isEmpty)! {
                self.viewContent.isHidden = true
            }else {
                self.viewContent.isHidden = false
            }
            self.viewContent.isHidden = true
            self.btnPlay.isHidden = true
           // self.viewContent.layer.contents = UIImage(named: "content-card-gradient")?.cgImage
            self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
            //  self.viewContent.layer.contents = UIImage(named: "card-gradient")?.cgImage
            if content.type == .image {
                self.btnPlay.isHidden = true
                if !content.color.trim().isEmpty {
                    imgCover.backgroundColor = UIColor(hex: content.color.trim())
                }
                self.imgCover.setImageWithURL(strImage: content.coverImage.trim()) { (result) in
                    if result! {
                        self.viewContent.isHidden = (self.lblName.text?.trim().isEmpty)!
                    }
                }
            }else if content.type == .video  {
              
                self.imgCover.setImageWithURL(strImage: content.coverImageVideo.trim()) { (result) in
                    if result! {
                        self.btnPlay.isHidden = false
                        self.viewContent.isHidden = (self.lblName.text?.trim().isEmpty)!
                    }
                }
  
            }else  if content.type == .link {
                self.btnPlay.isHidden = true

                self.imgCover.setImageWithURL(strImage: content.coverImageVideo.trim()) { (result) in
                                        if result! {
                                            self.viewContent.isHidden = (self.lblName.text?.trim().isEmpty)!
                                        }
                                    }

            }else {
                self.btnPlay.isHidden = true
                self.imgCover.setImageWithURL(strImage: content.coverImage.trim()) { (result) in
                                        if result! {
                                            self.viewContent.isHidden = (self.lblName.text?.trim().isEmpty)!
                                        }
                                    }
            }
        }
     
    }
}
