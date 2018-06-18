//
//  AddCollabCell.swift
//  Emogo
//
//  Created by Northout on 15/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class AddCollabCell: UITableViewCell {
    @IBOutlet weak var imgProfile: NZCircularImageView!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var lbluserName: UILabel!
    @IBOutlet weak var checkButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

}
