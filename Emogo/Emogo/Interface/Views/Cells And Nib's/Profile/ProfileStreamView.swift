//
//  ProfileStreamView.swift
//  Emogo
//
//  Created by Pushpendra on 16/04/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
protocol ProfileStreamViewDelegate {
    func actionForCover(imageView:UIImageView)
}
class ProfileStreamView: UICollectionReusableView {
    
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnEditHeader: UIButton!
    
    var delegate:ProfileStreamViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.imgCover.addGestureRecognizer(tap)
        imgCover.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.viewContainer.layer.contents = UIImage(named: "gradient")?.cgImage
            // self.viewContainer.layer.contents = UIImage(named: "gradient")?.cgImage
           self.viewContainer.roundCorners([.bottomLeft, .bottomRight], radius: 5)
        }
    }
    
    func prepareLayout(stream:StreamDAO,isCurrentUser:Bool,image:String? = nil){
        
        if isCurrentUser {
            if  !UserDAO.sharedInstance.user.userImage.isEmpty {
             self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage)
            }else{
                if !UserDAO.sharedInstance.user.displayName.isEmpty {
                     self.imgUser.setImage(string: UserDAO.sharedInstance.user.username , color: UIColor.colorHash(name: UserDAO.sharedInstance.user.username ), circular: true)
                }else{
                    self.imgUser.setImage(string: UserDAO.sharedInstance.user.displayName, color: UIColor.colorHash(name: UserDAO.sharedInstance.user.displayName), circular: true)
                }
                
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
        self.btnEditHeader.isHidden = true
        if stream.IDcreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            self.btnEditHeader.isHidden = false
        }
     //   self.viewContainer.layer.contents = UIImage(named: "gradient")?.cgImage
    }
    
    @objc func tap(gesture:UITapGestureRecognizer) {
        if self.delegate != nil {
            self.delegate?.actionForCover(imageView:self.imgCover)
        }
    }
    
}
