//
//  ProfileStreamViewCell.swift
//  iMessageExt
//
//  Created by Northout on 27/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class ProfileStreamViewCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnLock: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var imgAdd: UIImageView!
    
    var size:CGSize! = CGSize(width: 250, height: 250)
    // MARK: - Prepare Layouts
    func prepareLayouts(stream:StreamDAO){
        
        if stream.isAdd {
            self.cardView.isHidden =  true
            self.imgAdd.isHidden =  false
           
        }else {
            self.imgCover.contentMode = .scaleAspectFill
            self.cardView.isHidden =  false
            self.lblName.isHidden = false
            self.imgAdd.isHidden =  true
       
            self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: kPlaceholderImage)
            self.lblTitle.text = stream.Title.trim().capitalized
            self.lblTitle.minimumScaleFactor = 1.0
            self.accessibilityLabel =   stream.Title.trim()
            self.lblName.text =  "by \(stream.Author.trim().capitalized)"
            self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
            btnEdit.isHidden = true
            if stream.IDcreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                btnEdit.isHidden = false
            }
            if stream.streamType.lowercased() == "private" {
                self.btnLock.setImage(#imageLiteral(resourceName: "lock_icon"), for: .normal)
            }else {
                self.btnLock.setImage(#imageLiteral(resourceName: "unlock_icon"), for: .normal)
            }
            self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim()) { (_, imgSize) in
                self.size = imgSize
            }
          
        }
      
    }
}
