//
//  ProfileStreamCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class ProfileStreamCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnLock: UIButton!
    @IBOutlet weak var btnEdit: UIButton!

    
    // MARK: - Prepare Layouts
    func prepareLayouts(stream:StreamDAO){
        
        self.imgCover.contentMode = .scaleAspectFill
        
        //   self.imgCover.backgroundColor = .black
        self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: "stream-card-placeholder")
        self.lblTitle.text = stream.Title.trim().capitalized
        self.accessibilityLabel =   stream.Title.trim()
        self.lblName.text =  "by \(stream.Author.trim().capitalized)"
        self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
    }
    
}
