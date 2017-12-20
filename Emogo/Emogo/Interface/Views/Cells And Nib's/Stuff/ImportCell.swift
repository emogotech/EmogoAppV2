//
//  ImportCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Photos

class ImportCell: UICollectionViewCell {
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgSelect: UIImageView!

    
    func prepareLayout(content:ContentDAO?){
        guard let content = content  else {
            return
        }
        if content.isSelected {
            imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
        }else {
            imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
        }
        if content.imgPreview !=  nil {
            imgCover.image = content.imgPreview
        }
        if content.type == .image {
            self.btnPlay.isHidden = true
        }else {
            self.btnPlay.isHidden = false
        }
    }
    
}


class GridViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgSelect: UIImageView!
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
   
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}


class  ImportDAO {
    var strID:String! = ""
    var isSelected:Bool! = false
    var assest:PHAsset!

    init(id:String,isSelected:Bool) {
        self.strID = id
        self.isSelected = isSelected
    }
}

