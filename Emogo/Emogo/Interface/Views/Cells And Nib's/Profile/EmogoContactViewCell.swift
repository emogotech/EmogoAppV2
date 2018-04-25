//
//  EmogoContactViewCell.swift
//  Emogo
//
//  Created by Northout on 23/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class EmogoContactViewCell: UITableViewCell {
    

    var imgProfile : UIImageView =  {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = 25
        img.layer.borderWidth = 0.5
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        
        return img
        
    }()
    
    var lblEmogoContact : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.init(r: 74.0 , g: 74.0 , b: 74.0 )
        
        return lbl
    }()
    
    var btnCheck :UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named:"unchecked_checkbox"), for: .normal)
        return btn
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(imgProfile)
        self.addSubview(lblEmogoContact)
        self.addSubview(btnCheck)
        
        imgProfile.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15
            ).isActive = true
        imgProfile.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imgProfile.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imgProfile.centerYAnchor.constraint(equalTo:self.centerYAnchor).isActive = true
        imgProfile.layer.cornerRadius = 25
        
        lblEmogoContact.leadingAnchor.constraint(equalTo: self.imgProfile.trailingAnchor, constant: 50).isActive = true
        lblEmogoContact.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        lblEmogoContact.centerYAnchor.constraint(equalTo: self.imgProfile.centerYAnchor).isActive = true
        
        btnCheck.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        btnCheck.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }

}
