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

    func prepareData(follow:FollowerDAO) {
        self.lblName.text = follow.displayName
        self.lblUserName.text = follow.fullName
        self.imgUser.setImageWithResizeURL(follow.userImage.trim())
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
