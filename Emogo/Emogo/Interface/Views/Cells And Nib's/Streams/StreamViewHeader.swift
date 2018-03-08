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

    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnCollab: MIBadgeButton!
    var streamDelegate:StreamViewHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPreview))
        self.imgCover.addGestureRecognizer(tap)
        
        self.expansionMode = .immediate
        // You can change the minimum and maximum content heights
        self.minimumContentHeight = 0 // you can replace the navigation bar with a stretchy header view
        self.stretchDelegate  = self
        
    }
    
    func prepareLayout(stream:StreamViewDAO?){
        btnEdit.isHidden = true
        btnDelete.isHidden = true
        self.lblDescription.numberOfLines = 2
        guard let objStream = stream  else {
            return
        }
        self.imgCover.contentMode = .scaleAspectFill
        //   self.imgCover.backgroundColor = .black
        if objStream.totalCollaborator.isEmpty || objStream.totalCollaborator == "0"  {
            btnCollab.isHidden = true
        }else {
            btnCollab.badgeString = objStream.totalCollaborator
            btnCollab.isHidden = false
            btnCollab.badgeEdgeInsets = UIEdgeInsetsMake(0, -7, -7, 0)
        }
        self.lblName.text = objStream.title.trim().capitalized
        self.lblName.shadow()
        self.lblName.minimumScaleFactor = 1.0
        self.lblDescription.text = objStream.description.trim()
        self.lblDescription.minimumScaleFactor = 1.0
        self.imgCover.setOriginalImage(strImage: objStream.coverImage, placeholder: kPlaceholderImage)
        self.viewContainer.layer.contents = UIImage(named: "gradient")?.cgImage
        if objStream.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            btnEdit.isHidden = false
            btnDelete.isHidden = false
        }
        if objStream.anyOneCanEdit == true {
            btnCollab.isHidden = true
        }
        if  objStream.canAddPeople == true {
            btnEdit.isHidden = false
        }
        
        let lineCount = lblDescription.lineCountForLabel()
        if lineCount < 2 {
            
            self.btnDropDown.isHidden = true
        }else{
            self.lblDescription.numberOfLines = 1
            self.btnDropDown.isHidden = false
        }
        
        if objStream.description.trim().isEmpty {
            self.btnDropDown.isHidden = true
        }
        
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
