//
//  LinkPickerViewCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class LinkPickerViewCell: UICollectionViewCell {
    @IBOutlet weak var imgLogo: FLAnimatedImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var cardView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        cardView.layer.cornerRadius = 5.0
        cardView.clipsToBounds = true
    }
    
    func prepareData(content:ContentDAO) {
        self.lblTitle.text = content.name.trim().capitalized
        self.lblLink.text = content.coverImage.trim()
        self.lblDescription.text =  content.description.trim()
        self.imgLogo.image = nil
        self.imgLogo.setForAnimatedImage(strImage:content.coverImageVideo)
        self.imgLogo.clipsToBounds = true
        self.imgLogo.contentMode = .scaleAspectFit
       
    }

}
