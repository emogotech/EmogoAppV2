//
//  LikeListCell.swift
//  Emogo
//
//  Created by Northout on 05/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class LikeListCell: UITableViewCell {
    
    //MARK:- IBOutlet Connection

    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func prepareLayout(like:LikedUser){
        self.lblUserName.text = like.name

        if like.userImage.isEmpty {
            self.imgUser.setImage(string: like.name, color: UIColor(r: 0, g: 173, b: 243), circular: true)
        }else {
            self.imgUser.setImageWithURL(strImage: like.userImage.trim(), placeholder: "")
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   
}
