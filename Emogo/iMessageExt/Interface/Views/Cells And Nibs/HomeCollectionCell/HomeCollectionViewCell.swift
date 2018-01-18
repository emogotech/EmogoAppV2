//
//  HomeCollectionViewCell.swift
//  iMessageExt
//
//  Created by Rohit on 11/21/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgStream        : UIImageView!
    
    @IBOutlet weak var lblStreamName    : UILabel!
    @IBOutlet weak var lblShortDesc     : UILabel!
    
    @IBOutlet weak var viewShowHide     : UIView!
    
    @IBOutlet weak var btnShare         : UIButton!
    @IBOutlet weak var btnView          : UIButton!
    
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        
        var gl:CAGradientLayer!
        
        let colorTop = UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 35.0 / 255.0, green: 2.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor
        
        gl = CAGradientLayer()
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        btnView.layer.insertSublayer(gl, at: 0)
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(stream:StreamDAO){
        self.imgStream.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: kPlaceholderImage)
        self.lblStreamName.text = stream.Title.trim()
      
        self.lblShortDesc.text = "by \(stream.Author!)"
        self.lblStreamName.minimumScaleFactor = 1.0
        self.lblShortDesc.minimumScaleFactor = 1.0
    }

    
}
