//
//  ContentViewCell.swift
//  Emogo
//
//  Created by Pushpendra on 14/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class ContentViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblTitleImage: UILabel!
    @IBOutlet weak var lblImageDescription: UILabel!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var kLinkIogoWidth: NSLayoutConstraint!
    @IBOutlet weak var linkLogo: UIImageView!

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.roundCorners([.topLeft, .topRight], radius: 10)
        }
    }
    
    func prepareView(seletedImage:ContentDAO) {
        
        self.imgCover.image = nil
        self.imgCover.animatedImage = nil
        if !seletedImage.color.trim().isEmpty {
            imgCover.backgroundColor = UIColor(hex: seletedImage.color.trim())
        }
        self.lblTitleImage.text = ""
        self.lblImageDescription.text = ""
        
        if  seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
            
        }
        if seletedImage.type == .link {
            linkLogo.isHidden = false
            kLinkIogoWidth.constant = 30.0
            
        }else {
            kLinkIogoWidth.constant = 0.0
            linkLogo.isHidden = true
        }
        
        if !seletedImage.color.trim().isEmpty {
            imgCover.backgroundColor = UIColor(hex: seletedImage.color.trim())
        }
        
        self.btnPlayIcon.isHidden = true
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }else {
            if seletedImage.type == .image || seletedImage.type == .notes {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImage) { (img) in
                    if let img = img {
                        img.getColors({ (colors) in
                            self.imgCover.backgroundColor = colors.primary
                        })
                    }
                }
                
                //self.btnPlayIcon.isHidden = true
            }else   if seletedImage.type == .video {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
                    if let img = img {
                        img.getColors({ (colors) in
                            self.imgCover.backgroundColor = colors.primary
                        })
                    }
                }
                self.btnPlayIcon.isHidden = false
            }else if seletedImage.type == .link {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
                    if let img = img {
                        img.getColors({ (colors) in
                            self.imgCover.backgroundColor = colors.primary
                        })
                    }
                }
            }else {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
                    if let img = img {
                        img.getColors({ (colors) in
                            self.imgCover.backgroundColor = colors.primary
                        })
                    }
                }
            }
        }
        navigationImageView =  self.imgCover
        self.imgCover.contentMode = .scaleAspectFit
        // disable Like Unlike and save icon
        self.lblTitleImage.addShadow()
        self.lblImageDescription.addShadow()
        self.lblImageDescription.isHidden = false
        self.lblTitleImage.isHidden = false
        if seletedImage.name.trim().isEmpty {
            self.lblTitleImage.isHidden = true
        }else {
            self.lblTitleImage.text = seletedImage.name.trim()
        }
        if seletedImage.description.trim().isEmpty {
            self.lblImageDescription.isHidden = true
        }else {
            self.lblImageDescription.numberOfLines = 0
            
            self.lblImageDescription.text = seletedImage.description.trim()
            let lines = self.lblImageDescription.numberOfVisibleLines
            if lines > 2 {
                //  self.btnMore.isHidden = false
            }else {
                // self.btnMore.isHidden = true
            }
            self.lblImageDescription.numberOfLines = 0
        }
        
        if seletedImage.type == .notes {
            self.lblImageDescription.text = ""
        }
    }
    
    
    
    
/*
    lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }()
    
    lazy var backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }()

    open fileprivate(set) lazy var overlayView: UIView = { [unowned self] in
        let view = UIView(frame: CGRect.zero)
        let gradient = CAGradientLayer()
        let colors = [UIColor(hex: "090909").alpha(0), UIColor(hex: "040404")]
        
        view.addGradientLayer(colors)
        view.alpha = 0
        
        return view
        }()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        effectView.frame = self.frame
        backgroundImageView.frame = effectView.frame
        if overlayView.superview != nil {
            overlayView.removeFromSuperview()
        }
        if overlayView.superview != nil {
            overlayView.removeFromSuperview()
        }
        if backgroundImageView.superview != nil {
            backgroundImageView.removeFromSuperview()
        }
        self.insertSubview(overlayView, at: 0)
        self.insertSubview(effectView, at: 0)
        self.insertSubview(backgroundImageView, at: 0)
        DispatchQueue.main.async {
            self.roundCorners([.topLeft, .topRight], radius: 10)
        }
    }
    
    func prepareView(seletedImage:ContentDAO) {
        
        self.imgCover.image = nil
        self.imgCover.animatedImage = nil
        if !seletedImage.color.trim().isEmpty {
            imgCover.backgroundColor = UIColor(hex: seletedImage.color.trim())
        }
        self.lblTitleImage.text = ""
        self.lblImageDescription.text = ""
        
        if  seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
            
        }
        if seletedImage.type == .link {
            linkLogo.isHidden = false
            kLinkIogoWidth.constant = 30.0
            
        }else {
            kLinkIogoWidth.constant = 0.0
            linkLogo.isHidden = true
        }
        self.btnPlayIcon.isHidden = true
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
            self.loadDynamicBackground("", image: seletedImage.imgPreview)
        }else {
            if seletedImage.type == .image || seletedImage.type == .notes {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImage) { (_) in
                    
                }
               
                self.loadDynamicBackground(seletedImage.coverImage)
                //self.btnPlayIcon.isHidden = true
            }else   if seletedImage.type == .video {
                //self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (_) in
                    
                }
                self.loadDynamicBackground(seletedImage.coverImageVideo)
                 self.btnPlayIcon.isHidden = false
            }else if seletedImage.type == .link {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (_) in
                    
                }
               // self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                self.loadDynamicBackground(seletedImage.coverImageVideo)
            }else {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (_) in
                    
                }
               // self.imgCover.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                self.loadDynamicBackground(seletedImage.coverImageVideo)

            }
        }
        
        overlayView.frame = imgCover.frame
        overlayView.resizeGradientLayer()
        self.imgCover.contentMode = .scaleAspectFit
        // disable Like Unlike and save icon
        self.lblTitleImage.addShadow()
        self.lblImageDescription.addShadow()
        self.lblImageDescription.isHidden = false
        self.lblTitleImage.isHidden = false
        if seletedImage.name.trim().isEmpty {
            self.lblTitleImage.isHidden = true
        }else {
            self.lblTitleImage.text = seletedImage.name.trim()
        }
        if seletedImage.description.trim().isEmpty {
            self.lblImageDescription.isHidden = true
        }else {
            self.lblImageDescription.numberOfLines = 0
            
            self.lblImageDescription.text = seletedImage.description.trim()
            let lines = self.lblImageDescription.numberOfVisibleLines
            if lines > 2 {
              //  self.btnMore.isHidden = false
            }else {
               // self.btnMore.isHidden = true
            }
            self.lblImageDescription.numberOfLines = 0
        }
        
        if seletedImage.type == .notes {
            self.lblImageDescription.text = ""
        }
    }
    
    fileprivate func loadDynamicBackground(_ imageURL: String,image:UIImage? = nil) {
        if imageURL.isEmpty {
            backgroundImageView.image = image
        }else {
            self.backgroundImageView.setImageWithURL(strImage: imageURL, placeholder: "")
        }
        backgroundImageView.layer.add(CATransition(), forKey: kCATransitionFade)
    }
    */
}


extension UIView {
    
    @discardableResult func addGradientLayer(_ colors: [UIColor]) -> CAGradientLayer {
        if let gradientLayer = gradientLayer { return gradientLayer }
        
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        layer.insertSublayer(gradient, at: 0)
        
        return gradient
    }
    
    func removeGradientLayer() -> CAGradientLayer? {
        gradientLayer?.removeFromSuperlayer()
        
        return gradientLayer
    }
    
    func resizeGradientLayer() {
        gradientLayer?.frame = bounds
    }
    
    fileprivate var gradientLayer: CAGradientLayer? {
        return layer.sublayers?.first as? CAGradientLayer
    }
}
