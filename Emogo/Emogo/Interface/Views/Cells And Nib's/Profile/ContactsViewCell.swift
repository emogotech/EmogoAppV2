//
//  ContactsViewCell.swift
//  Emogo
//
//  Created by Northout on 23/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class ContactsViewCell: UITableViewCell {

    var imgProfile:UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = 25
        img.layer.borderWidth = 0.5
        img.layer.borderColor = UIColor.lightGray.cgColor
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        
        return img
    }()
    
    var lblContact :UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.init(r: 74.0, g: 74.0, b: 74.0)        
        return lbl
    }()
    
    var btnCheck :UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named:"check-box-empty"), for: .normal)
        return btn
    }()
   
    var lblSeprator : UILabel = {
        let lbl =  UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints =  false
        lbl.backgroundColor = UIColor.init(r: 229.0 , g: 229.0, b: 229.0)
        
        return lbl
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
        self.addSubview(lblContact)
        self.addSubview(lblSeprator)
        self.addSubview(btnCheck)
        
        imgProfile.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        imgProfile.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imgProfile.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imgProfile.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imgProfile.layer.cornerRadius = 25
        
        lblContact.leadingAnchor.constraint(equalTo: self.imgProfile.trailingAnchor, constant: 35).isActive = true
        lblContact.centerYAnchor.constraint(equalTo: self.imgProfile.centerYAnchor).isActive = true
        lblContact.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80).isActive = true
        
        lblSeprator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1).isActive = true
        lblSeprator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1).isActive = true
        lblSeprator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive =  true
        lblSeprator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        btnCheck.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        btnCheck.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
}
