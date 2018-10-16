//
//  ProfileHeaderView.swift
//  Emogo
//
//  Created by pushpendra on 09/03/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import GSKStretchyHeaderView

class ProfileHeaderView: GSKStretchyHeaderView,GSKStretchyHeaderViewStretchDelegate {
    

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var btnStream: UIButton!
    @IBOutlet weak var btnColab: UIButton!
    @IBOutlet weak var btnStuff: UIButton!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var imgLink: UIImageView!
    @IBOutlet weak var btnContainer: UIView!
    @IBOutlet weak var lblBirthday: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.expansionMode = .immediate
        // You can change the minimum and maximum content heights
        self.minimumContentHeight = 60 // you can replace the navigation bar with a stretchy header view
        self.stretchDelegate  = self
        self.maximumContentHeight = 278
    }
    
    func prepareLayout() {

        lblFullName.text =  UserDAO.sharedInstance.user.fullName.trim().capitalized
        lblFullName.minimumScaleFactor = 1.0
        lblWebsite.text = UserDAO.sharedInstance.user.website.trim()
        lblWebsite.minimumScaleFactor = 1.0
        lblLocation.text = UserDAO.sharedInstance.user.location.trim()
        lblLocation.minimumScaleFactor = 1.0
        lblBio.text = UserDAO.sharedInstance.user.biography.trim()
        lblBio.minimumScaleFactor = 1.0
        imgLink.isHidden = false
        imgLocation.isHidden = false
        
        if UserDAO.sharedInstance.user.location.trim().isEmpty {
            imgLocation.isHidden = true
        }
        if UserDAO.sharedInstance.user.website.trim().isEmpty {
            imgLink.isHidden = true
        }
       
        self.imgUser.image = #imageLiteral(resourceName: "camera_icon_cover_images")
        if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
            self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage.trim())
        }else{
            if !UserDAO.sharedInstance.user.displayName.isEmpty {
                self.imgUser.setImage(string: UserDAO.sharedInstance.user.username , color: UIColor.colorHash(name: UserDAO.sharedInstance.user.username ), circular: true)
            }else{
                self.imgUser.setImage(string: UserDAO.sharedInstance.user.displayName, color: UIColor.colorHash(name: UserDAO.sharedInstance.user.displayName), circular: true)
            }
        }

    }
    
    
    func stretchyHeaderView(_ headerView: GSKStretchyHeaderView, didChangeStretchFactor stretchFactor: CGFloat) {
        
    }


}
