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
    @IBOutlet weak var cardView: CardView!
    
    var coverImage:UIImage!

    
    // MARK: - Override Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(stream:StreamDAO){
        
         self.imgCover.contentMode = .scaleAspectFill
         self.imgCover.isHidden = false
         self.viewContent.isHidden = true
        
        if !stream.color.trim().isEmpty {
            imgCover.backgroundColor = UIColor(hex: stream.color.trim())
        }
     
        self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim()) { (result) in
            if result! {
                self.viewContent.isHidden = false
            }
        }
         self.lblTitle.minimumScaleFactor = 1.0
         self.accessibilityLabel =   stream.Title.trim()
         self.lblName.text =  "\(stream.Author.trim().capitalized)"
          if stream.Title.trim().count > 15 {
             self.lblTitle.text = "\(stream.Title.trim(count: 15))..."
          }else{
             self.lblTitle.text = stream.Title.trim()
          }
           self.viewContent.layer.contents = UIImage(named: "card-gradient")?.cgImage
       
    }
   
}
