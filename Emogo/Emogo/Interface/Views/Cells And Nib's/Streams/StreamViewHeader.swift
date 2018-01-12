//
//  StreamViewHeader.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

protocol StreamViewHeaderDelegate {
    func showPreview()
}

class StreamViewHeader: UICollectionViewCell {
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnCollab: MIBadgeButton!
    var delegate:StreamViewHeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPreview))
        self.imgCover.addGestureRecognizer(tap)
    }
    
    func prepareLayout(stream:StreamViewDAO?){
        btnEdit.isHidden = true
        btnDelete.isHidden = true
        guard let objStream = stream  else {
            return
        }
        self.imgCover.contentMode = .scaleAspectFill
     //   self.imgCover.backgroundColor = .black
        if objStream.arrayColab.count == 0 {
            btnCollab.isHidden = true
        }else {
            btnCollab.badgeString = "\(objStream.arrayColab.count)"
            btnCollab.isHidden = false
            btnCollab.badgeEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0)

        }
        self.lblName.text = objStream.title.trim().capitalized
        self.lblDescription.text = objStream.description.trim()
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

        if self.lblDescription.heightOfLbl > self.lblDescription.frame.size.height  {
            if self.lblDescription.isTruncated {
                self.btnDropDown.isHidden = false
            }else{
                self.btnDropDown.isHidden = true
            }
        }else{
            if self.lblDescription.frame.size.height == 0.0 || self.lblDescription.numberOfVisibleLines < 2{
                self.btnDropDown.isHidden = true
            }else{
                self.btnDropDown.isHidden = false
            }
        }
        
    }
    
    @IBAction func btnShowFullDescription(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.lblDescription.numberOfLines = 5
            self.lblDescription.sizeToFit()
        }else {
            self.lblDescription.numberOfLines = 1
            self.lblDescription.sizeToFit()
        }
      }
    
    @objc func showPreview(){
        
        if self.delegate != nil {
            delegate?.showPreview()
        }
    }

}
