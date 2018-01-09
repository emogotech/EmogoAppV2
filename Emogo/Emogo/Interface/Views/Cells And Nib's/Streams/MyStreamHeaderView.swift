//
//  MyStreamHeaderView.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

protocol MyStreamHeaderViewDelegate {
    func selected(index:Int)
}

class MyStreamHeaderView: UICollectionViewCell,KASlideShowDelegate,KASlideShowDataSource {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var sliderCover: KASlideShow!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    var arrayContent = [Any]()
    var arrayContents = [ContentDAO]()
    var delegate:MyStreamHeaderViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        arrayContent = [Any]()
        self.btnPlay.addTarget(self, action: #selector(self.playButtonAction(sender:)), for: .touchUpInside)

    }

    func prepareLayout(contents:[ContentDAO]){
        arrayContents = contents
        for obj in contents {
            if obj.type == .image {
                if obj.imgPreview != nil {
                    arrayContent.append(obj.imgPreview!)
                }else {
                    if !obj.coverImage.trim().isEmpty {
                        let url = URL(string: obj.coverImage.stringByAddingPercentEncodingForURLQueryParameter()!)
                        arrayContent.append(url!)
                    }
                }
            }else {
                if obj.imgPreview != nil {
                    arrayContent.append(obj.imgPreview!)
                }else {
                    if !obj.coverImageVideo.trim().isEmpty {
                        let url = URL(string: obj.coverImageVideo.stringByAddingPercentEncodingForURLQueryParameter()!)
                        arrayContent.append(url!)
                    }
                }
            }
        }
        
        sliderCover.datasource = self
        sliderCover.delegate = self
        sliderCover.delay = 1 // Delay between transitions
        sliderCover.transitionDuration = 0.5 // Transition duration
        sliderCover.transitionType = KASlideShowTransitionType.slideHorizontal // Choose a transition type (fade or slide)
        sliderCover.imagesContentMode = .scaleAspectFill // Choose a content mode for images to display
        sliderCover.add(KASlideShowGestureType.all)
        sliderCover.isExclusiveTouch = true
        prepareLayout(content:contents[0])
        sliderCover.reloadData()
    }
    
    
    func prepareLayout(content:ContentDAO?) {
        guard let content = content  else {
            return
        }
    
        self.lblName.text = content.name.trim().capitalized
        self.lblDescription.text = content.description.trim()
        self.viewContainer.layer.contents = UIImage(named: "gradient")?.cgImage
        self.lblDescription.numberOfLines = 3
        //self.imgCover.backgroundColor = .black
        if content.type == .image {
            self.btnPlay.isHidden = true
        }else {
            self.btnPlay.isHidden = false
        }
    }
    
    
    @objc func playButtonAction(sender:UIButton){
        if self.delegate != nil {
            self.delegate?.selected(index: Int(sliderCover.currentIndex))
        }
    }


    // MARK: - KASlideShow datasource
    
    func slideShowImagesNumber(_ slideShow: KASlideShow!) -> Int {
        return arrayContent.count
    }
    func slideShow(_ slideShow: KASlideShow!, objectAt index: Int) -> NSObject! {
        return arrayContent[index] as! NSObject
    }
    // MARK: - KASlideShow delegate
    func slideShowDidShowNext(_ slideShow: KASlideShow!) {
        self.btnPlay.tag = Int(slideShow.currentIndex)
        let content = arrayContents[Int(slideShow.currentIndex)]
        self.prepareLayout(content: content)
    }
    func slideShowDidShowPrevious(_ slideShow: KASlideShow!) {
        self.btnPlay.tag = Int(slideShow.currentIndex)
        let content = arrayContents[Int(slideShow.currentIndex)]
        self.prepareLayout(content: content)
    }
    func slideShowDidSelect(_ slideShow: KASlideShow!) {
        if delegate != nil {
            self.delegate?.selected(index: Int(slideShow.currentIndex))
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
        self.imgCover.setImageWithURL(strImage: stream.CoverImage.trim(), placeholder: kPlaceholderImage)
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
