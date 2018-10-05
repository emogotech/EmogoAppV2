//
//  ContentViewCell.swift
//  Emogo
//
//  Created by Pushpendra on 14/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import BMPlayer

protocol ContentDetailViewCellDelegate {
    func actionForDidSelect(indexPath:IndexPath?)
    func actionForPlayerSelect(indexPath:IndexPath)
    func dismissView()
    func tapActionHandler(isShow:Bool)

}

class ContentDetailViewCell: UICollectionViewCell,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {
    @IBOutlet weak var viewTableContainer: UIView!
    @IBOutlet weak var tblView: UITableView!

    let cellIdentifier = "contentDetailTableViewCell"
    let kImageHeight:CGFloat = 0.0
    var seletedImage:ContentDAO!
    private var lastContentOffset: CGFloat = 0
    var delegate:ContentDetailViewCellDelegate?
    var isSwipeDissmiss:Bool! = false
    var indexPath:IndexPath!
    var isCanScroll:Bool! = false

    var playerView:BMPlayer? = {
        let player = BMPlayer()
        player.isPanControlsEnable = false
        BMPlayerConf.enablePlaytimeGestures = false
        BMPlayerConf.enableBrightnessGestures = false
        BMPlayerConf.enableVolumeGestures = false
        return player
    }()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        tblView.delegate = self
        tblView.dataSource = self
        tblView.estimatedRowHeight = 300
        tblView.rowHeight = UITableViewAutomaticDimension
        let swipGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(gesture:)))
        swipGesture.direction = .down
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(swipGesture)
      //  self.tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:  0, right: 0)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.playerView?.superview == nil {
            self.tblView.reloadData()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("reuse called")
        if self.playerView?.superview != nil {
            if  (self.playerView?.isPlaying)! {
                self.playerView?.pause()
            }
            self.playerView?.removeFromSuperview()
        }else {
            if  (self.playerView?.isPlaying)! {
                self.playerView?.pause()
            }
        }
        isCanScroll = false
    }
    
    
    
    func prepareView(seletedImage:ContentDAO,indexPath:IndexPath) {
        self.seletedImage = seletedImage
     //   tblView.setContentOffset(.zero, animated: false)
        self.tblView.reloadData()
        if !seletedImage.description.trim().isEmpty  || !seletedImage.name.trim().isEmpty {
            self.tblView.contentInset = UIEdgeInsets(top:0, left: 0, bottom:  51, right: 0)
        }
        self.tblView.reloadData()
}
    
    func reloadAllInputs(){
        if self.playerView?.superview != nil {
            if  (self.playerView?.isPlaying)! {
                self.playerView?.pause()
            }
            self.playerView?.removeFromSuperview()
        }else {
            if  (self.playerView?.isPlaying)! {
                self.playerView?.pause()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.seletedImage == nil {
            return 0
        }else {
            return 1
        }
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ContentDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ContentDetailTableViewCell
        cell.btnPlayIcon.addTarget(self, action: #selector(self.btnPlayAction(sender:)), for: .touchUpInside)
        cell.prepareView(seletedImage: seletedImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let value = kFrame.size.width / CGFloat(seletedImage.width)
        let expectedHeight = CGFloat(seletedImage.height) * value
        var tempHeight:CGFloat = 0.0
        if !seletedImage.name.trim().isEmpty  {
            tempHeight = seletedImage.name.trim().height(withConstrainedWidth: self.frame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0))
        }
        if !seletedImage.description.trim().isEmpty  {
            tempHeight = tempHeight + seletedImage.description.trim().height(withConstrainedWidth: self.frame.size.width - 10, font: UIFont.boldSystemFont(ofSize: 13.0))
        }
        var deviceHeight:CGFloat! = 0.0
        let actualHeight = tempHeight + expectedHeight
        if #available(iOS 11, *), UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            deviceHeight = kFrame.size.height -  84.0
        }else {
            deviceHeight = kFrame.size.height -  64.0
        }
        if actualHeight > deviceHeight {
           // self.tblView.isScrollEnabled = true
            return actualHeight
        }else {
           // self.tblView.isScrollEnabled = false
            return  deviceHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.delegate != nil {
            self.delegate?.actionForDidSelect(indexPath: indexPath)
    }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isSwipeDissmiss = true
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return
//    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isSwipeDissmiss {
            return
        }
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            if self.lastContentOffset < -100.0 {
                if self.delegate != nil {
                    self.delegate?.actionForDidSelect(indexPath: nil)
                }
            }
        }
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    
    }
    
   
    
   
    
    @objc func btnPlayAction(sender:UIButton){
        let index = IndexPath(row: 0, section: 0)
        self.playButtonTapped(sender: index)
    }
    @objc func swipeGesture(gesture:UISwipeGestureRecognizer){
        if self.delegate != nil {
            self.delegate?.dismissView()
        }
    }
    
    
    @objc func playButtonTapped(sender:IndexPath) {
        if let cell = tblView.cellForRow(at: sender) as? ContentDetailTableViewCell {
            if self.playerView?.superview != nil {
                self.playerView?.removeFromSuperview()
            }
            if seletedImage.type == .video {
                DispatchQueue.main.async {
                    if let player = self.playerView {
                        if player.superview == nil {
                            cell.playerContainerView.isHidden = false
                            cell.imgCover.isHidden = true
                            cell.btnPlayIcon.isHidden = true
                            self.playerView?.frame = cell.playerContainerView.bounds
                            cell.playerContainerView.addSubview(self.playerView!)
                            //                            self.collectionView.backgroundColor = .black
                            //                            cell.viewCollection.backgroundColor = .black
                            
                            self.preparePlayerView(strURL: self.seletedImage.coverImage)
                        }
                    }
                    
                }
            }
            
        }
    }
    
    func preparePlayerView(strURL:String){
        
        guard let videoUrl =  URL(string: strURL) else {
            return
        }
        let asset = BMPlayerResource(url: videoUrl)
        playerView?.setVideo(resource: asset)
        // Back button event
        playerView?.tapActionHandler = {  (isTapped) in
                print("taopppppeddde\(isTapped)")
           
            if self.delegate != nil {
                self.delegate?.tapActionHandler(isShow: isTapped)
            }
    }
        

        playerView?.playStateDidChange = { (isPlaying: Bool) in
            print("playStateDidChange \(isPlaying)")
//            if isPlaying == false {
//                if self.playerView?.superview != nil {
//                    self.playerView?.isUserInteractionEnabled = false
//                }
//            }else {
//                if self.playerView?.superview != nil {
//                    self.playerView?.isUserInteractionEnabled = true
//                }
//            }
        }
        
        //Listen to when the play time changes
        playerView?.playTimeDidChange = { (currentTime: TimeInterval, totalTime: TimeInterval) in
            print("playTimeDidChange currentTime: \(currentTime) totalTime: \(totalTime)")
            if currentTime == totalTime {
              
            }
            if self.playerView?.superview == nil {
                if (self.playerView?.isPlaying)! {
                    self.playerView?.pause()
                }
            }
        }
    }
    
    
}


class ContentDetailTableViewCell:UITableViewCell {
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    @IBOutlet weak var lblTitleImage: UILabel!
    @IBOutlet weak var lblImageDescription: UILabel!
    @IBOutlet weak var kLinkIogoWidth: NSLayoutConstraint!
    @IBOutlet weak var linkLogo: UIImageView!
    @IBOutlet weak var kConstantImageHeight: NSLayoutConstraint!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var playerContainerView: UIView!

    
    func prepareView(seletedImage:ContentDAO) {

        self.imgCover.image = nil
        self.imgCover.animatedImage = nil
        imgCover.backgroundColor = UIColor.white
        if !seletedImage.color.trim().isEmpty {
            imgCover.backgroundColor =  UIColor.white
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
        self.imgCover.isHidden = false
        self.playerContainerView.isHidden = true
        self.lblImageDescription.isHidden = false
        self.lblTitleImage.isHidden = false
        if seletedImage.name.trim().isEmpty {
            self.lblTitleImage.isHidden = true
        }else {
            self.lblTitleImage.numberOfLines = 2
            self.lblTitleImage.text = seletedImage.name.trim()
        }
        self.lblImageDescription.text = seletedImage.description.trim()
        
        if seletedImage.description.trim().isEmpty {
            self.lblImageDescription.isHidden = true
        }
        if seletedImage.type == .notes {
            self.lblImageDescription.text = ""
        }
        
        let value = kFrame.size.width / CGFloat(seletedImage.width)
        let expectedHeight = CGFloat(seletedImage.height) * value
        self.kConstantImageHeight.constant = expectedHeight
        self.btnPlayIcon.isHidden = true
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }else {
            if seletedImage.type == .image || seletedImage.type == .notes {
                
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImage)
            }else   if seletedImage.type == .video {
                self.btnPlayIcon.isHidden = false
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo)
            }else if seletedImage.type == .link {
                
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo)
            }else {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo)
            }
        }
        navigationImageView =  self.imgCover
        viewDescription.backgroundColor = .clear
        viewDescription.addBlurView(style:.light)
        self.imgCover.contentMode = .scaleAspectFill
    }
}

/*

class ContentViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCover: FLAnimatedImageView!
    //@IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblTitleImage: UILabel!
    @IBOutlet weak var lblImageDescription: UILabel!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var kLinkIogoWidth: NSLayoutConstraint!
    @IBOutlet weak var linkLogo: UIImageView!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var scrollView: PMScrollView!
    @IBOutlet weak var kConstantImageHeight: NSLayoutConstraint!
    @IBOutlet weak var kConstantsConatinerHeight: NSLayoutConstraint!
    @IBOutlet weak var kTopConstarintPriority: NSLayoutConstraint!
    @IBOutlet weak var kBottomConstarintPriority: NSLayoutConstraint!

    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var viewCollection: UIView!
    
    var isReadMore:Bool! = false
    var strDescription:String! = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
    }
    
    
    func prepareView(seletedImage:ContentDAO) {
       // self.imgCover.backgroundColor  = .black
        self.scrollView.isHidden = false
        self.imgCover.image = nil
        self.imgCover.animatedImage = nil
        imgCover.backgroundColor = UIColor.white
        viewCollection.backgroundColor = UIColor.white
        
        if !seletedImage.color.trim().isEmpty {
            imgCover.backgroundColor =  UIColor.white
            viewCollection.backgroundColor =  UIColor.white
//            imgCover.backgroundColor = UIColor(hex: seletedImage.color.trim())
//            viewCollection.backgroundColor = UIColor(hex: seletedImage.color.trim())
//            tempImageView.backgroundColor = UIColor(hex: seletedImage.color.trim())
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

        self.lblImageDescription.isHidden = false
        self.lblTitleImage.isHidden = false
        if seletedImage.name.trim().isEmpty {
            self.lblTitleImage.isHidden = true
        }else {
            self.lblTitleImage.numberOfLines = 2
            self.lblTitleImage.text = seletedImage.name.trim()
        }
        strDescription = seletedImage.description.trim()
        self.lblImageDescription.text = seletedImage.description.trim()

        if seletedImage.description.trim().isEmpty {
            self.lblImageDescription.isHidden = true
        }/*
        else {
            if seletedImage.description.trim().count <  100 {
                self.btnMore.isHidden = true
                self.lblImageDescription.text = seletedImage.description.trim()
            }else {
                self.btnMore.isHidden = false
                self.lblImageDescription.text = seletedImage.description.trim().trim(count: 100)
            }
            
        }
 */
        if seletedImage.type == .notes {
            self.lblImageDescription.text = ""
        }
        
        self.scrollView.isScrollEnabled = true
        let value = kFrame.size.width / CGFloat(seletedImage.width)
        let expectedHeight = CGFloat(seletedImage.height) * value
        var size:CGFloat = 0.0
        if (self.lblImageDescription.text?.trim().isEmpty)! {
            size  = expectedHeight + 31.0
           self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)

        }else {
            size  = expectedHeight + (self.lblImageDescription!.text?.height(withConstrainedWidth: self.lblImageDescription.frame.size.width, font: UIFont.boldSystemFont(ofSize: 14.0)))! + 160.0
            self.scrollView.contentInset = UIEdgeInsetsMake(160.0, 0, 0, 0)
        }
//        if expectedHeight < kFrame.size.height {
//            self.kTopConstarintPriority.priority = .required
//            self.kTopConstarintPriority.priority = .required
//        }else {
//            self.kTopConstarintPriority.priority = .defaultLow
//            self.kTopConstarintPriority.priority = .defaultLow
//        }
        self.kConstantImageHeight.constant = expectedHeight
        self.kConstantsConatinerHeight.constant = size
        self.scrollView.contentSize = CGSize(width: kFrame.size.width, height: size)
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }else {
            if seletedImage.type == .image || seletedImage.type == .notes {
            
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImage)
            }else   if seletedImage.type == .video {
                self.scrollView.isScrollEnabled = false
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo)
                 self.btnPlayIcon.isHidden = false
            }else if seletedImage.type == .link {
                
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo)
            }else {
                self.imgCover.setForAnimatedImage(strImage: seletedImage.coverImageVideo)
            }
        }
        self.imgCover.contentMode = .scaleAspectFit
        navigationImageView =  self.imgCover

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

*/
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
