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
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var viewContent: UIView!

    
    // MARK: - Override Functions
    
    override func awakeFromNib() {
        
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(stream:StreamDAO){
        self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: "stream-card-placeholder")
        self.lblTitle.attributedText = setInfo(cover: stream.Title.trim(), postedBy: "\nPosted By \(stream.Author!)")
        self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
        self.lblTitle.numberOfLines = 0
    }
    
    func setInfo(cover:String,postedBy:String) -> NSMutableAttributedString {
    
        let coverAttribute:[NSAttributedStringKey:Any?] = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16.0)]
        
        let nameAttribute:[NSAttributedStringKey:Any?] = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]

        let coverStr =  NSMutableAttributedString(string: cover, attributes: coverAttribute)
        let nameStr =  NSMutableAttributedString(string: postedBy, attributes: nameAttribute)
        coverStr.append(nameStr)
        return coverStr
    }
}
