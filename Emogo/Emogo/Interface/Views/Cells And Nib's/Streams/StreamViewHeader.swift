//
//  StreamViewHeader.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class StreamViewHeader: UICollectionViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnCollab: MIBadgeButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    
    func prepareLayout(stream:StreamViewDAO?){
        btnEdit.isHidden = true
        btnDelete.isHidden = true
        guard let objStream = stream  else {
            return
        }
        self.imgCover.contentMode = .scaleAspectFill
     //   self.imgCover.backgroundColor = .black
        btnCollab.badgeString = "\(objStream.arrayColab.count)"
        self.lblName.text = objStream.title.trim().capitalized
        self.lblDescription.text = objStream.description.trim()
        self.imgCover.setImageWithURL(strImage: objStream.coverImage, placeholder: "stream-card-placeholder")
        self.viewContainer.layer.contents = UIImage(named: "gradient")?.cgImage
        if objStream.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            btnEdit.isHidden = false
            btnDelete.isHidden = false
        }
    }

}
