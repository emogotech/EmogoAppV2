//
//  ProfileStreamCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Haptica

class ProfileStreamCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnLock: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var imgAdd: UIImageView!


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
            self.viewContent.isHidden = true
            self.lblTitle.text = stream.Title.trim()
            self.lblTitle.minimumScaleFactor = 1.0
            self.accessibilityLabel =   stream.Title.trim()
            self.lblName.text =  "\(stream.Author.trim())"
            self.viewContent.layer.contents = UIImage(named: "card-gradient")?.cgImage
            self.btnLock.isHidden = true
            btnEdit.isHidden = true
            if stream.IDcreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                btnEdit.isHidden = false
            }
            if stream.streamType.lowercased() == "private" {
                self.btnLock.isHidden = false
                self.btnLock.setImage(#imageLiteral(resourceName: "lock_icon"), for: .normal)
            }else {
                self.btnLock.isHidden = true
       
            }
         self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim()) { (isLoaded) in
                if isLoaded! {
                    self.viewContent.isHidden = false
                }
                
            }
        }
    }
}
