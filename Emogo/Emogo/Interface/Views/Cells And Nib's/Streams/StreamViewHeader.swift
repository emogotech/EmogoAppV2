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
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnLike:UIButton!
    @IBOutlet weak var btnCollab: MIBadgeButton!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var viewViewCount: UIView!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var imgCollabTwo: NZCircularImageView!
    @IBOutlet weak var imgCollabOne: NZCircularImageView!
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var btnLikeList: UIButton!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var lblColabLabel: UILabel!
    @IBOutlet weak var kConstantImageWidth: NSLayoutConstraint!
    @IBOutlet weak var kConstantLikeWidth: NSLayoutConstraint!
    @IBOutlet weak var btnLikeOtherUser:UIButton!
    @IBOutlet weak var kConsImgTop: NSLayoutConstraint!
    @IBOutlet weak var imgViewTopGradient: UIImageView!

    var streamDelegate:StreamViewHeaderDelegate?
    var objColab:StreamViewDAO!
    let kImageFormat = "http"
    
    override func awakeFromNib() {
        super.awakeFromNib()
//          self.lblName.shadow()
//          self.lblName.minimumScaleFactor = 1.0
      
        // Initialization code
        imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPreview))
        tap.numberOfTapsRequired = 1
        self.imgCover.isExclusiveTouch = true
        self.imgCover.addGestureRecognizer(tap)
       
        self.expansionMode = .topOnly
        self.contentExpands = false
        // You can change the minimum and maximum content heights
        self.minimumContentHeight = 0 // you can replace the navigation bar with a stretchy header view
        self.stretchDelegate  = self
        self.maximumContentHeight = 200

    }
    func prepareLayout(stream:StreamDAO?){
        self.lblName.text = nil
        imgCollabTwo.isHidden = true
        imgCollabOne.isHidden = true
     //   imgUser.isHidden = true

        self.viewContainer.layer.contents = UIImage(named: "stream-bottom-gradient")?.cgImage
      //  self.viewTop.layer.contents = UIImage(named: "stream-top-gradient")?.cgImage
        //top-gradient
        // self.viewTop.addBlurView(style: UIBlurEffectStyle.dark)
        let objStream = stream!
//        guard let objStream = stream  else {
//            return
//        }
        imgCover.isHidden = false
        if !objStream.color.trim().isEmpty {
            imgCover.backgroundColor = UIColor(hex: objStream.color.trim())
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
         let strname = objStream.Title.trim()
       
         //self.lblName.text  = ""
        print("stream Name ---->\(objStream.Title.trim())")
        self.lblName.text = strname
   
        self.lblDescription.text = objStream.description.trim()
        self.lblDescription.shadow()
        self.lblDescription.numberOfLines = 0
        //  self.lblDescription.minimumScaleFactor = 1.0
        
        self.lblLikeCount.text = objStream.totalLikeCount.trim()
        self.lblViewCount.text = objStream.viewCount.trim()
        self.viewTop.fadeIn(0.1, delay: 0.4) { (_) in
            
        }
//        self.viewContainer.fadeIn(0.2, delay: 0.4) { (_) in
//
//        }
        self.imgViewTopGradient.fadeIn(0.1, delay: 0.4) { (_) in
            
        }
        if (stream?.color.trim().isEmpty)! {
            imgCover.backgroundColor = UIColor(hex: (stream?.color.trim())!)
        }
        
       
        self.imgCover.setOriginalImage(strImage: objStream.CoverImage, placeholder: kPlaceholderImage)
    
//        if objStream.anyOneCanEdit == true {
//            btnCollab.isHidden = true
//        }
        if  objStream.canAddPeople == true {
            // btnEdit.isHidden = false
        }
        btnCollab.isHidden = false
        
        if !objStream.userImage.trim().isEmpty {
            self.imgUser.isHidden = false
            self.imgUser.setImageWithResizeURL(objStream.userImage.trim())
        }
        else {
            
            self.imgUser.setImage(string:objStream.Author.trim(), color: UIColor(r: 0, g: 122, b: 255), circular: true)
        }
      
        if !objStream.colabImageFirst.trim().isEmpty && objStream.colabImageSecond.trim().isEmpty {
            
            self.imgCollabOne.isHidden = false
            self.imgCollabTwo.isHidden = true
            
            if  objStream.colabImageFirst.contains(kImageFormat) {
                self.imgCollabOne.setImageWithResizeURL(objStream.colabImageFirst.trim())
                
            }else {
                self.imgCollabOne.setImage(string:objStream.colabImageFirst.trim(), color: UIColor.cyan, circular: true)
                
            }
            
        }else if objStream.colabImageFirst.trim().isEmpty && !objStream.colabImageSecond.trim().isEmpty {
            self.imgCollabOne.isHidden = false
            if  objStream.colabImageSecond.contains(kImageFormat) {
                self.imgCollabOne.setImageWithResizeURL(objStream.colabImageSecond.trim())
                
            }else {
                self.imgCollabOne.setImage(string:objStream.colabImageSecond.trim(), color: UIColor.cyan, circular: true)
                
            }
            self.imgCollabTwo.isHidden = true
        }else if !objStream.colabImageFirst.trim().isEmpty && !objStream.colabImageSecond.trim().isEmpty{
            
            self.imgCollabOne.isHidden = false
            self.imgCollabTwo.isHidden = false
            if !objStream.colabImageSecond.trim().isEmpty {
                
                if  objStream.colabImageSecond.contains(kImageFormat) {
                    self.imgCollabTwo.setImageWithResizeURL(objStream.colabImageSecond.trim())
                    
                }else {
                    self.imgCollabTwo.setImage(string:objStream.colabImageSecond.trim(), color: UIColor.cyan, circular: true)
                    
                }
            }else{
                self.imgCollabTwo.isHidden = true
            }
            
            if !objStream.colabImageFirst.trim().isEmpty {
                
                if  objStream.colabImageFirst.contains(kImageFormat) {
                    self.imgCollabOne.setImageWithResizeURL(objStream.colabImageFirst.trim())
                    
                }else {
                    
                    self.imgCollabOne.setImage(string:objStream.colabImageFirst.trim(), color: UIColor.brown, circular: true)
                }
                
            }else{
                self.imgCollabOne.isHidden = true
            }
            
        }
        var colabcount:Int! = 0
        if !objStream.totalCollaborator.trim().isEmpty {
            colabcount = Int(objStream.totalCollaborator!)
            if colabcount! > 2 {
                self.lblColabLabel.text = " " +  objStream.Author + "\n & \(colabcount!-1) others"
            }else {
                self.lblColabLabel.text = " " +  objStream.Author + "\n & \(colabcount!-1) other"
            }
            kConstantImageWidth.constant = 60.0
        }
        
        if colabcount == 0 ||  colabcount == 1 {
            self.lblColabLabel.text =  " " + objStream.Author
            kConstantImageWidth.constant = 40.0
        }
    }
    
    func prepareLayout(stream:StreamViewDAO?){
        if stream == nil {
            return
        }
        imgCollabTwo.isHidden = false
        imgCollabOne.isHidden = false
      
        self.viewContainer.layer.contents = UIImage(named: "stream-bottom-gradient")?.cgImage
        self.viewTop.layer.contents = UIImage(named: "stream-top-gradient")?.cgImage
        //top-gradient
       // self.viewTop.addBlurView(style: UIBlurEffectStyle.dark)
        guard let objStream = stream  else {
            return
        }
        imgCover.isHidden = false

        self.imgCover.contentMode = .scaleAspectFill
        //   self.imgCover.backgroundColor = .black
        if objStream.totalCollaborator.isEmpty || objStream.totalCollaborator == "0"  {
            btnCollab.isHidden = false
        }else {
         //   btnCollab.badgeString = objStream.totalCollaborator
            btnCollab.isHidden = false
           // btnCollab.badgeEdgeInsets = UIEdgeInsetsMake(0, -7, -7, 0)
        }
        self.lblName.text = objStream.title.trim()
        self.lblName.shadow()
        self.lblName.minimumScaleFactor = 1.0
        self.lblDescription.text = objStream.description.trim()
        self.lblDescription.shadow()
        self.lblDescription.numberOfLines = 0
      //  self.lblDescription.minimumScaleFactor = 1.0
     
        self.lblLikeCount.text = objStream.totalLikeCount.trim()
        self.lblViewCount.text = objStream.viewCount.trim()
    
        if (stream?.color.trim().isEmpty)! {
            imgCover.backgroundColor = UIColor(hex: (stream?.color.trim())!)
        }
        self.imgCover.setOriginalImage(strImage: objStream.coverImage, placeholder: kPlaceholderImage)
        
//        if objStream.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
//            btnEdit.isHidden = false
//            btnDelete.isHidden = false
//            btnContainer.isHidden = false
//            heightEdit.constant = 40
//            heigtDelete.constant = 40
//        }else{
//            btnContainer.isHidden = true
//            heightEdit.constant = 0
//            heigtDelete.constant = 0
//        }
        if objStream.anyOneCanEdit == true {
            btnCollab.isHidden = true
        }
        if  objStream.canAddPeople == true {
           // btnEdit.isHidden = false
        }
         btnCollab.isHidden = false
    
        if !objStream.userImage.trim().isEmpty {
            self.imgUser.setImageWithResizeURL(objStream.userImage.trim())
        }
        else {
            
            self.imgUser.setImage(string:objStream.author.trim(), color: UIColor(r: 0, g: 122, b: 255), circular: true)
        }
     
    
        if !objStream.colabImageFirst.trim().isEmpty && objStream.colabImageSecond.trim().isEmpty {
            
            self.imgCollabOne.isHidden = false
            self.imgCollabTwo.isHidden = true
            
            if  objStream.colabImageFirst.contains(kImageFormat) {
                self.imgCollabOne.setImageWithResizeURL(objStream.colabImageFirst.trim())
                
            }else {
                self.imgCollabOne.setImage(string:objStream.colabImageFirst.trim(), color: UIColor.cyan, circular: true)
                
            }
            
        }else if objStream.colabImageFirst.trim().isEmpty && !objStream.colabImageSecond.trim().isEmpty {
            
            self.imgCollabOne.isHidden = false
            self.imgCollabTwo.isHidden = true
            
            if  objStream.colabImageSecond.contains(kImageFormat) {
                self.imgCollabOne.setImageWithResizeURL(objStream.colabImageSecond.trim())
                
            }else {
                self.imgCollabOne.setImage(string:objStream.colabImageSecond.trim(), color: UIColor.cyan, circular: true)
                
            }
            
            
        }else if !objStream.colabImageFirst.trim().isEmpty && !objStream.colabImageSecond.trim().isEmpty{
            
            self.imgCollabOne.isHidden = false
            self.imgCollabTwo.isHidden = false
            if !objStream.colabImageSecond.trim().isEmpty {
                
                if  objStream.colabImageSecond.contains(kImageFormat) {
                    self.imgCollabTwo.setImageWithResizeURL(objStream.colabImageSecond.trim())
                    
                }else {
                    self.imgCollabTwo.setImage(string:objStream.colabImageSecond.trim(), color: UIColor.cyan, circular: true)
                    
                }
            }else{
                self.imgCollabTwo.isHidden = true
            }
            
            if !objStream.colabImageFirst.trim().isEmpty {
                
                if  objStream.colabImageFirst.contains(kImageFormat) {
                    self.imgCollabOne.setImageWithResizeURL(objStream.colabImageFirst.trim())
                    
                }else {
                    
                    self.imgCollabOne.setImage(string:objStream.colabImageFirst.trim(), color: UIColor.brown, circular: true)
                }
                
            }else{
                self.imgCollabOne.isHidden = true
            }
            
        }
        var colabcount:Int! = 0
        if !objStream.totalCollaborator.trim().isEmpty {
            colabcount = Int(objStream.totalCollaborator!)
            if colabcount! > 2 {
                self.lblColabLabel.text = " " +  objStream.author.capitalized + "\n & \(colabcount!-1) others"
            }else {
                self.lblColabLabel.text = " " +  objStream.author.capitalized + "\n & \(colabcount!-1) other"
            }
            kConstantImageWidth.constant = 60.0
        }
        
        if colabcount == 0 ||  colabcount == 1 {
            self.lblColabLabel.text =  " " + objStream.author.capitalized
            kConstantImageWidth.constant = 40.0
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
            self.imgCover.isUserInteractionEnabled = true
            streamDelegate?.showPreview()
        }
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        
    }
    
    func stretchyHeaderView(_ headerView: GSKStretchyHeaderView, didChangeStretchFactor stretchFactor: CGFloat) {
        var alpha: CGFloat = 1
     //   var blurAlpha: CGFloat = 1
        if stretchFactor > 1 {
            alpha = CGFloatTranslateRange(stretchFactor, 1, 1.12, 1, 0)
         //   blurAlpha = alpha
        } else if stretchFactor < 0.8 {
            alpha = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1)
        }
        alpha = max(0, alpha)
        
     //   self.imgCover.alpha = blurAlpha
        viewTop.alpha = alpha
        viewContainer.alpha = alpha
        btnLikeOtherUser.alpha = alpha

    }
    
}
