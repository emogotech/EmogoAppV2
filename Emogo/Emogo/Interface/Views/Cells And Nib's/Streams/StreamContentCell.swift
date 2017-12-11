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

    func prepareLayout(content:ContentDAO){
        if content.isAdd == true {
            imgAdd.isHidden = false
            viewCard.isHidden = true
        }else {
            imgAdd.isHidden = true
            viewCard.isHidden = false
            self.lblName.text = content.name.trim().capitalized
            self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
            if content.type == "Picture" {
                self.btnPlay.isHidden = true
                self.imgCover.setImageWithURL(strImage: content.coverImage, placeholder: "stream-card-placeholder")
            }else {
                self.btnPlay.isHidden = false
            }
        }
     
    }
}
