//
//  ProfileStreamView.swift
//  Emogo
//
//  Created by Pushpendra on 16/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
protocol ProfileStreamViewDelegate {
    func actionForCover()
}
class ProfileStreamView: UICollectionReusableView {
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!

    var delegate:ProfileStreamViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.imgCover.addGestureRecognizer(tap)
        imgCover.isUserInteractionEnabled = true
    }
    
    func prepareLayout(stream:StreamDAO,isCurrentUser:Bool,image:String? = nil){
        
        if isCurrentUser {
            if  !UserDAO.sharedInstance.user.userImage.isEmpty {
        self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage)
            }
        }else {
            if image != nil {
                if  !(image?.isEmpty)! {
                    self.imgUser.setImageWithResizeURL(image!)
                }
            }
           
        }
     self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: kPlaceholderImage)
        self.imgCover.contentMode = .scaleAspectFill
        self.imgUser.layer.masksToBounds = true
        self.lblTitle.text = stream.Title.trim().capitalized
        self.lblTitle.addShadow()
    }
    
    @objc func tap(gesture:UITapGestureRecognizer) {
        if self.delegate != nil {
            self.delegate?.actionForCover()
        }
    }
    
}
