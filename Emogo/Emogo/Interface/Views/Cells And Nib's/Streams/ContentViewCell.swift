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
    @IBOutlet weak var lblImageDescription: MBAutoGrowingTextView!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var kLinkIogoWidth: NSLayoutConstraint!
    @IBOutlet weak var linkLogo: UIImageView!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var scrollView: PMScrollView!
    @IBOutlet weak var kConsimgHeight: NSLayoutConstraint!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var kCenterX: NSLayoutConstraint!
    @IBOutlet weak var kCenterY: NSLayoutConstraint!
    @IBOutlet weak var tempImageView: FLAnimatedImageView!
    @IBOutlet weak var viewCollection: UIView!
    
    var isReadMore:Bool! = false
    var strDescription:String! = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func prepareView(seletedImage:ContentDAO) {
       // self.imgCover.backgroundColor  = .black
        self.scrollView.isHidden = true
        self.tempImageView.isHidden = false
        self.kCenterX.priority = .defaultHigh
        self.kCenterY.priority = .defaultHigh
        self.imgCover.image = nil
        self.imgCover.animatedImage = nil
        self.tempImageView.image = nil
        self.tempImageView.animatedImage = nil
        imgCover.backgroundColor = UIColor.white
        viewCollection.backgroundColor = UIColor.white
        tempImageView.backgroundColor = UIColor.white
        
        if !seletedImage.color.trim().isEmpty {
            imgCover.backgroundColor =  UIColor.white
            viewCollection.backgroundColor =  UIColor.white
            tempImageView.backgroundColor =  UIColor.white
//            imgCover.backgroundColor = UIColor(hex: seletedImage.color.trim())
//            viewCollection.backgroundColor = UIColor(hex: seletedImage.color.trim())
//            tempImageView.backgroundColor = UIColor(hex: seletedImage.color.trim())
        }
        self.lblTitleImage.text = ""
        self.lblImageDescription.text = ""
         self.scrollView.isScrollEnabled = false
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
        
//        if !seletedImage.color.trim().isEmpty {
//            imgCover.backgroundColor = UIColor(hex: seletedImage.color.trim())
//        }
//        
//        if !seletedImage.color.trim().isEmpty {
//            tempImageView.backgroundColor = UIColor(hex: seletedImage.color.trim())
//        }
       
//        var contentRect = CGRect.zero
//        for view in scrollView.subviews {
//            contentRect = contentRect.union(view.frame)
//        }
//        scrollView.contentSize = contentRect.size
        self.viewDescription.isHidden = false
        self.btnPlayIcon.isHidden = true
        self.imgCover.isHidden = false
        self.playerContainerView.isHidden = true
        let scale = Int(kFrame.size.width) / seletedImage.width
        let newHeight = seletedImage.height * scale
        let frameHeight = Int(kFrame.size.height)
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }else {
            if seletedImage.type == .image || seletedImage.type == .notes {
                self.tempImageView.setForAnimatedImage(strImage: seletedImage.coverImage) { (img) in
                    navigationImageView =  self.tempImageView

                }
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImage) { (img) in
                    if let img = img {
                        img.getColors({ (colors) in
                        //    self.imgCover.backgroundColor = colors.primary
                          
                        })

                        if newHeight > frameHeight  {
                            navigationImageView =  self.imgCover
                            if seletedImage.width <  seletedImage.height {
                                self.scrollView.isScrollEnabled = true
                                self.kCenterX.priority = .defaultLow
                                self.kCenterY.priority = .defaultLow
                                self.imgCover.image =  img.resizeToScreenSize()
                                self.kConsimgHeight.constant = img.resizeToScreenSize().size.height
                                self.tempImageView.isHidden = true
                                self.scrollView.isHidden = false
                          }
                        }
                    }
                }
                
                //self.btnPlayIcon.isHidden = true
            }else   if seletedImage.type == .video {
                self.scrollView.isScrollEnabled = false
                self.tempImageView.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
                    navigationImageView =  self.tempImageView
                }
               self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
                    if let img = img {
                        img.getColors({ (colors) in
                        //    self.imgCover.backgroundColor = colors.primary
                        })
                    }
                navigationImageView =  self.imgCover

                }
                 self.btnPlayIcon.isHidden = false

            }else if seletedImage.type == .link {
                
                self.tempImageView.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
                    navigationImageView =  self.tempImageView
                }
                
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
                    if let img = img {
                        img.getColors({ (colors) in
                        //    self.imgCover.backgroundColor = colors.primary
                        })

                        if newHeight > frameHeight  {
                            if seletedImage.width <  seletedImage.height {
                                self.scrollView.isScrollEnabled = true
                                self.kCenterX.priority = .defaultLow
                                self.kCenterY.priority = .defaultLow
                                self.imgCover.image =  img.resizeToScreenSize()
                                self.kConsimgHeight.constant = img.resizeToScreenSize().size.height
                                self.tempImageView.isHidden = true
                                self.scrollView.isHidden = false
                                navigationImageView =  self.imgCover
                            }
                        }
                        
                    }
                }
            }else {
                
                self.tempImageView.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
                navigationImageView =  self.tempImageView

//                self.tempImageView.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
//                    navigationImageView =  self.tempImageView
//                }
                /*
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (img) in
                    if let img = img {
                        img.getColors({ (colors) in
                         //   self.imgCover.backgroundColor = colors.primary
                        })
                        navigationImageView =  self.imgCover

                    }
                }
                */
            }
        }
        self.imgCover.contentMode = .scaleAspectFit
        self.tempImageView.contentMode = .scaleAspectFit
        // disable Like Unlike and save icon
       // self.lblTitleImage.addShadow()
      //  self.lblImageDescription.addShadow()
        self.lblImageDescription.isHidden = false
        self.lblTitleImage.isHidden = false
        if seletedImage.name.trim().isEmpty {
            self.lblTitleImage.isHidden = true
            self.btnMore.isHidden = true
        }else {
            self.lblTitleImage.numberOfLines = 2
            self.lblTitleImage.text = seletedImage.name.trim()
        }
        strDescription = seletedImage.description.trim()
        if seletedImage.description.trim().isEmpty {
            self.lblImageDescription.isHidden = true
            self.btnMore.isHidden = true
        }else {
            if seletedImage.description.trim().count <  100 {
                self.btnMore.isHidden = true
                self.lblImageDescription.text = seletedImage.description.trim()
            }else {
                self.btnMore.isHidden = false
                 self.lblImageDescription.text = seletedImage.description.trim().trim(count: 100)
            }
          
        }
        
        if seletedImage.type == .notes {
            self.lblImageDescription.text = ""
        }
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
 
    
    @IBAction func btnMoreAction(_ sender: Any) {
        isReadMore = !isReadMore
        if isReadMore {
            self.lblImageDescription.text = strDescription.trim()
        }else {
            self.lblImageDescription.text = strDescription.trim().trim(count: 100)
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
