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
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnPlay: UIButton!


    func prepareLayout(content:ContentDAO?){
        guard let content = content  else {
            return
        }
        self.lblTitle.text = content.name.trim()
        self.lblDescription.text =  content.description.trim()
        if (self.lblTitle.text?.trim().isEmpty)! && (self.lblDescription.text?.trim().isEmpty)!{
            self.viewContent.layer.contents = nil
           }else {
            self.viewContent.layer.contents = UIImage(named: "card-gradient")?.cgImage
        }
        self.viewContent.isHidden = true
        self.btnPlay.isHidden = true

        imgCover.contentMode = .scaleAspectFill
        if !content.color.trim().isEmpty {
            imgCover.backgroundColor = UIColor(hex: content.color.trim())
        }
        if content.type == .image {
            self.imgCover.setForAnimatedImage(strImage: content.coverImage) { (_) in
                self.viewContent.isHidden = (self.lblTitle.text?.trim().isEmpty)!
            }
        }else if content.type == .video {
            self.imgCover.image = nil
            self.imgCover.setForAnimatedImage(strImage: content.coverImageVideo) { (_) in
                self.viewContent.isHidden = (self.lblTitle.text?.trim().isEmpty)!
                self.btnPlay.isHidden = false
            }
        }else if content.type == .link {
            self.imgCover.image = nil
            self.imgCover.setForAnimatedImage(strImage: content.coverImageVideo) { (_) in
                self.viewContent.isHidden = (self.lblTitle.text?.trim().isEmpty)!
            }
           
        }else {
            self.imgCover.setForAnimatedImage(strImage: content.coverImage) { (_) in
                self.viewContent.isHidden = (self.lblTitle.text?.trim().isEmpty)!
            }
       
        }
        if content.type == .notes {
            self.lblDescription.text = ""
        }
        
        if content.isSelected {
            imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
        }else {
            imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
        }
    }
}
