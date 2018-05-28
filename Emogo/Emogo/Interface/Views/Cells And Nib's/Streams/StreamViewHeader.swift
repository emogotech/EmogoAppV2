//
//  StreamViewHeader.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import GSKStretchyHeaderView

protocol StreamViewHeaderDelegate {
    func showPreview()
}

class StreamViewHeader: GSKStretchyHeaderView,GSKStretchyHeaderViewStretchDelegate {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerTitle: UIView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnCollab: MIBadgeButton!
    @IBOutlet weak var btnContainer: UIView!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var heigtDelete: NSLayoutConstraint!
    @IBOutlet weak var heightEdit: NSLayoutConstraint!
    @IBOutlet weak var imgCollabTwo: NZCircularImageView!
    @IBOutlet weak var imgCollabOne: NZCircularImageView!
    @IBOutlet weak var imgUser: NZCircularImageView!
    
    var streamDelegate:StreamViewHeaderDelegate?
    var objColab:StreamViewDAO!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPreview))
        self.imgCover.addGestureRecognizer(tap)
        
        self.expansionMode = .topOnly
        
        // You can change the minimum and maximum content heights
        self.minimumContentHeight = 0 // you can replace the navigation bar with a stretchy header view
        self.stretchDelegate  = self
        self.maximumContentHeight = 306

    }
    
    func prepareLayout(stream:StreamViewDAO?){
        self.viewContainerTitle.layer.contents = UIImage(named: "gradient")?.cgImage
        btnEdit.isHidden = true
        btnDelete.isHidden = true
        guard let objStream = stream  else {
            return
        }
        self.imgCover.contentMode = .scaleAspectFill
        //   self.imgCover.backgroundColor = .black
        if objStream.totalCollaborator.isEmpty || objStream.totalCollaborator == "0"  {
            btnCollab.isHidden = false
        }else {
         //   btnCollab.badgeString = objStream.totalCollaborator
            btnCollab.isHidden = false
           // btnCollab.badgeEdgeInsets = UIEdgeInsetsMake(0, -7, -7, 0)
        }
        self.lblName.text = objStream.title.trim().capitalized
        self.lblName.shadow()
        self.lblName.minimumScaleFactor = 1.0
        self.lblDescription.text = objStream.description.trim()
        self.lblDescription.minimumScaleFactor = 1.0
        self.lblLikeCount.text = objStream.totalLikeCount.trim()
        self.lblViewCount.text = objStream.viewCount.trim()
        self.imgCover.setOriginalImage(strImage: objStream.coverImage, placeholder: kPlaceholderImage)
        if objStream.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            btnEdit.isHidden = false
            btnDelete.isHidden = false
            btnContainer.isHidden = false
            heightEdit.constant = 40
            heigtDelete.constant = 40
        }else{
            btnContainer.isHidden = true
            heightEdit.constant = 0
            heigtDelete.constant = 0 
        }
        if objStream.anyOneCanEdit == true {
            btnCollab.isHidden = true
        }
        if  objStream.canAddPeople == true {
            btnEdit.isHidden = false
        }
         btnCollab.isHidden = false
        if objStream.description.trim().isEmpty {
            self.heightConstant.constant = 0
        }else {
            let height = objStream.description.trim().height(withConstrainedWidth: self.lblDescription.bounds.size.width, font: self.lblDescription.font)
            self.heightConstant.constant = height + 10
        }
        if !objStream.userImage.trim().isEmpty {
            self.imgUser.setImageWithResizeURL(objStream.userImage.trim())
        }
        else {
            self.imgUser.setImage(string:objStream.author.trim(), color: UIColor.colorHash(name:objStream.author.trim()), circular: true)
            
        }
     
        if !objStream.colabImageFirst.trim().isEmpty {
            self.imgCollabOne.setImageWithResizeURL(objStream.colabImageFirst.trim())
           
        }else{
             self.imgCollabOne.setImage(string:objStream.author.trim(), color: UIColor.colorHash(name:objStream.author.trim()), circular: true)
        }
        
        if !objStream.colabImageSecond.trim().isEmpty {
              self.imgCollabTwo.setImageWithResizeURL(objStream.colabImageSecond.trim())
          
        }else{
            self.imgCollabTwo.setImage(string:objStream.author.trim(), color: UIColor.colorHash(name:objStream.author.trim()), circular: true)
        }
        // For  Now
       // btnEdit.isHidden = false
      
      
        
    }
   
    
    
    @IBAction func btnShowFullDescription(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.lblDescription.numberOfLines = 0
            self.lblDescription.sizeToFit()
        }else {
            self.lblDescription.numberOfLines = 1
            self.lblDescription.sizeToFit()
        }
    }
    
    @objc func showPreview(){
        
        if self.streamDelegate != nil {
            streamDelegate?.showPreview()
        }
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        
    }
    
    func stretchyHeaderView(_ headerView: GSKStretchyHeaderView, didChangeStretchFactor stretchFactor: CGFloat) {
       
    }
    
}
