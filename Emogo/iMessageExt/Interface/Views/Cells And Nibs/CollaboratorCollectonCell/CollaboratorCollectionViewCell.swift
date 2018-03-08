//
//  CollaboratorCollectionViewCell.swift
//  iMessageExt
//
//  Created by Sushobhit on 05/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class CollaboratorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCollaboratorName  : UILabel!
    @IBOutlet weak var imgCollaborator      : UIImageView!
    
    override func awakeFromNib() {
        imgCollaborator.layer.cornerRadius = self.imgCollaborator.frame.size.width/2
        imgCollaborator.clipsToBounds = true
    }
    
    func prepareLayout(content:CollaboratorDAO){
        self.lblCollaboratorName.text = content.name!
        if content.imgUser == "" {
            self.imgCollaborator.setImage(string: content.name!, color: UIColor.colorHash(name: content.name!), circular: true)
        }else{
            self.imgCollaborator.setImageWithURL(strImage: content.imgUser.trim(), placeholder: "")
        }
    }
}
