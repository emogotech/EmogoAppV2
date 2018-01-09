//
//  StreamCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class StreamCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    var coverImage:UIImage!

    
    // MARK: - Override Functions
    
    override func awakeFromNib() {
        
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(stream:StreamDAO){
        
        self.imgCover.contentMode = .scaleAspectFill
        
     //   self.imgCover.backgroundColor = .black
        self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: kPlaceholderImage)
         self.lblTitle.text = stream.Title.trim().capitalized
        self.accessibilityLabel =   stream.Title.trim()
         self.lblName.text =  "by \(stream.Author.trim().capitalized)"
        self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
    }
   
}
