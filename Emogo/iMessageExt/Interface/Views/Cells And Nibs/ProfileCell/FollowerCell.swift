//
//  FollowerCell.swift
//  Emogo
//
//  Created by Pushpendra on 18/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class FollowerCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var ViewUser: UIView!
    @IBOutlet weak var viewMessage: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func prepareData(follow:FollowerDAO,type:FollowerType) {
        self.lblUserName.isHidden = false
        self.lblName.text = follow.displayName
        self.lblUserName.text = follow.fullName
        if follow.userImage.trim().isEmpty {
         
            if follow.displayName.isEmpty {
                self.imgUser.setImage(string: follow.fullName, color: UIColor.colorHash(name: follow.fullName ), circular: true)
            }else{
                self.imgUser.setImage(string: follow.displayName, color: UIColor.colorHash(name: follow.displayName ), circular: true)
                }
           // self.imgUser.image = #imageLiteral(resourceName: "demo_images")
        }else {
            self.imgUser.setImageWithResizeURL(follow.userImage.trim())
        }
        if type == .Follower {
            if follow.isFollowing {
                self.btnFollow.setImage(#imageLiteral(resourceName: "following_button"), for: .normal)
            }else {
                self.btnFollow.setImage(#imageLiteral(resourceName: "follow_button"), for: .normal)
            }
        }else {
            self.btnFollow.setImage(#imageLiteral(resourceName: "following_button"), for: .normal)
        }
        if follow.displayName.trim().isEmpty {
            self.lblName.text = follow.fullName
            self.lblUserName.isHidden = true
        }
      
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
