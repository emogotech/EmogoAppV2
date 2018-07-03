//
//  CountryCell.swift
//  Emogo
//
//  Created by Pushpendra on 18/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class CountryCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneCode: UILabel!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var imgCountryFlag: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
