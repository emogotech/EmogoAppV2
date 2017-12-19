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
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    func prepareLayout(content:ContentDAO){
        if content.isAdd == true {
            viewAddContent.isHidden = false
        } else {
            viewAddContent.isHidden  = true
            self.lblName.text = content.name.trim().capitalized
            if content.type == .image {
                self.imgCover.setImageWithURL(strImage: content.coverImage, placeholder: "stream-card-placeholder")
            }else{
                if !content.coverImage.isEmpty {
                    let url = URL(string: content.coverImage.stringByAddingPercentEncodingForURLQueryParameter()!)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                       let image = SharedData.sharedInstance.getThumbnailImage(url: url!)
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                            self.imgCover.image = image
                        }
                    }
                    
                }
            }
        }
    }
    
}
