//
//  HomeCollectionViewCell.swift
//  iMessageExt
//
//  Created by Rohit on 11/21/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
  
    @IBOutlet weak var imgStream : UIImageView!
    @IBOutlet weak var lblStreamName : UILabel!
    @IBOutlet weak var lblShortDesc : UILabel!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(stream:StreamDAO){
        self.imgStream.image = stream.imgCover
        self.lblStreamName.text = stream.title
        self.lblShortDesc.text = "Posted By Jon"
    }
    
}
