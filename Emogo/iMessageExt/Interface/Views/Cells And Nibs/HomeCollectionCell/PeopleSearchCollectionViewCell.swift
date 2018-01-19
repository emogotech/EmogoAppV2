//
//  PeopleSearchCollectionViewCell.swift
//  iMessageExt
//
//  Created by Sushobhit on 20/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class PeopleSearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width/2.0
        self.imgUser.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        //hide or reset anything you want hereafter, for example
//        label.isHidden = true
//
//    }
    
    func prepareData(people:PeopleDAO){
        self.lblName.text = people.fullName!
        lblName.minimumScaleFactor = 1.0
        if people.userImage.isEmpty {
            self.imgUser.setImage(string: people.fullName, color:#colorLiteral(red: 0, green: 0.6784313725, blue: 0.9529411765, alpha: 1), circular: true)
        }else {
            self.imgUser.setImageWithURL(strImage: people.userImage.trim(), placeholder: "")
        }
    }
    
}
