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
    

    func prepareData(people:StreamDAO){
        self.lblName.text = people.fullName!
        
        if people.userImage.isEmpty {
            self.imgUser.setImage(string: people.fullName, color: UIColor(r: 0, g: 173, b: 243), circular: true)
        }else {
            self.imgUser.setImageWithURL(strImage: people.userImage.trim(), placeholder: "")
        }
    }

    
}
