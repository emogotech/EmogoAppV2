//
//  PeopleCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class PeopleCell: UICollectionViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width/2.0
        self.imgUser.layer.masksToBounds = true
    }
    
    func prepareData(people:PeopleDAO){
        self.lblName.text = people.fullName!
        if people.userImage.isEmpty {
            self.imgUser.setImage(string: people.fullName, color: UIColor.colorHash(name: people.fullName), circular: true)
        }else {
            self.imgUser.setImageWithURL(strImage: people.userImage.trim(), placeholder: "")
        }
    }
}
