//
//  ProfileStreamView.swift
//  Emogo
//
//  Created by Pushpendra on 16/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class ProfileStreamView: UICollectionReusableView {
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var imgCover: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepareLayout(stream:StreamDAO,isCurrentUser:Bool){
        
        if isCurrentUser {
            imgUser.isHidden = true
        }else {
            imgUser.isHidden = false
        }
    self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: kPlaceholderImage)

    }
    
}
