//
//  MyStreamHeaderView.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class MyStreamHeaderView: UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPlay: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func prepareLayout(content:ContentDAO?){
        guard let content = content  else {
            return
        }
        self.lblName.text = content.name.trim().capitalized
        self.lblDescription.text = content.description.trim()
        self.viewContainer.layer.contents = UIImage(named: "gradient")?.cgImage
        self.lblDescription.numberOfLines = 3
        self.imgCover.contentMode = .scaleAspectFit
        self.imgCover.backgroundColor = .black
        if content.type == "Picture" {
            self.btnPlay.isHidden = true
            self.imgCover.setImageWithURL(strImage: content.coverImage, placeholder: "stream-card-placeholder")
        }else {
            if !content.coverImage.isEmpty {
                let url = URL(string: content.coverImage.stringByAddingPercentEncodingForURLQueryParameter()!)
                if  let image = SharedData.sharedInstance.getThumbnailImage(url: url!) {
                    self.imgCover.image = image
                }
            }
            self.btnPlay.isHidden = false
        }
    }

}


class MyStreamCell:UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgSelect: UIImageView!
    
    func prepareLayout(stream:StreamDAO?){
        guard let stream = stream  else {
            return
        }
        
        self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: "stream-card-placeholder")
        self.lblTitle.text = stream.Title.trim().capitalized
        self.lblName.text =  "by \(stream.Author.trim().capitalized)"
        self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
        if stream.isSelected {
            imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
        }else {
            imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
        }
    }

}
