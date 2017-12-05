//
//  CollaboratorCollectionViewCell.swift
//  iMessageExt
//
//  Created by Sushobhit on 05/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class CollaboratorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCollaboratorName : UILabel!
    @IBOutlet weak var imgCollaborator : UIImageView!
    
    override func awakeFromNib() {
        imgCollaborator.layer.cornerRadius = self.imgCollaborator.frame.size.width/2
        imgCollaborator.clipsToBounds = true
    }
}
