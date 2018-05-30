//
//  VideoEditorViewController.swift
//  Emogo
//
//  Created by Pushpendra on 15/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import BMPlayer
import PryntTrimmerView
import AVFoundation

enum VideoEditorFeature {
    case trimer
    case resolution
    case sticker
    case rate
    case text
    case none
}

protocol VideoEditorDelegate {
    func saveEditing(image: ContentDAO)
    func cancelEditing()
}
class VideoEditorViewController: UIViewController {

    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var kTrimmerHeight: NSLayoutConstraint!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var txtDescription: MBAutoGrowingTextView!
    @IBOutlet weak var txtTitleImage: UITextField!
    @IBOutlet weak var btnSave: UIButton!

    var player = BMPlayer()
    var seletedImage:ContentDAO!
    var edgeMenu: DPEdgeMenu?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var fileLocalPath:String! = ""
    var avPlayer: AVPlayer?
    var selectedFeature:VideoEditorFeature! = .none
    var editManager = PMVideoEditor()
    var localFileURl:URL?
    var originalFile:String! = ""
    var originalFileURl:URL?
    var editedFileURL:URL?
    var stickersViewController: StickersViewController!
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var stickersVCIsVisible = false
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    var stickers : [UIImage] = []
    var colors  : [UIColor] = []
    var isTyping: Bool = false
    var isForEditOnly: Bool? = true
    let shapes = ShapeDAO()
    var textColor: UIColor = UIColor.white
    var delegate:VideoEditorDelegate?
    var isEdit:Bool!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareLayout()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewDescription.addBlurView()
        self.txtTitleImage.addShadow()
        self.txtDescription.addShadow()
        self.btnSave.addShadow()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.fileLocalPath != nil {
            Document.deleteFile(name: self.fileLocalPath.getName())
        }
    }
    
    func prepareLayout(){
        self.stickers = self.shapes.shapes
     stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        configureCollectionView()
        self.kTrimmerHeight.constant = 0.0
        prepareNavigation()
        self.prepareMenu()
         getVideo()
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.screenEdgeSwiped(_:)))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        self.txtDescription.text = ""
        self.txtDescription.placeholder = "Description"
        self.txtDescription.placeholderColor = .white
        self.keyboardSetup()
        
        if !seletedImage.description.isEmpty {
            var description  = seletedImage.description.trim()
            if seletedImage.description.count > 250 {
                description = seletedImage.description.trim(count: 250)
            }
            self.txtDescription.text = description
        }else{
            self.txtDescription.text = ""
        }
        self.txtTitleImage.maxLength = 50
        self.txtTitleImage.text = self.seletedImage.name.trim()
        txtDescription.isUserInteractionEnabled = true
        txtTitleImage.isUserInteractionEnabled = true
    }
    

    
    func prepareNavigation() {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        let myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
        
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor =  UIColor.black.withAlphaComponent(0.7)

        self.configureNavigationButtons()
    }
    
    func prepareMenu(){
        
        let btnTrim = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnTrim.setImage(#imageLiteral(resourceName: "trim_icon"), for: .normal)
        btnTrim.setBackgroundImage(#imageLiteral(resourceName: "rectangle_up"), for: .normal)
        btnTrim.tag = 101
        btnTrim.isExclusiveTouch = true
        btnTrim.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnAddText = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnAddText.setImage(#imageLiteral(resourceName: "add_image_icon"), for: .normal)
        btnAddText.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnAddText.tag = 102
        btnAddText.isExclusiveTouch = true
        btnAddText.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnResoultion = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnResoultion.setImage(#imageLiteral(resourceName: "rate_of_video_icon"), for: .normal)
        btnResoultion.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnResoultion.tag = 103
        btnResoultion.isExclusiveTouch = true
        btnResoultion.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnRate = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnRate.setImage(#imageLiteral(resourceName: "rate_of_video") , for: .normal)
        btnRate.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnRate.tag = 104
        btnRate.isExclusiveTouch = true
        btnRate.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnText = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnText.setImage(#imageLiteral(resourceName: "add_text"), for: .normal)
        btnText.setBackgroundImage(#imageLiteral(resourceName: "rectangle_down"), for: .normal)
        btnText.tag = 105
        btnText.isExclusiveTouch = true
        btnText.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        self.edgeMenu = DPEdgeMenu(items: [btnTrim, btnAddText, btnResoultion,btnRate,btnText],
                                   animationDuration: 0.8, menuPosition: .right)
        guard let edgeMenu = self.edgeMenu else { return }
        edgeMenu.backgroundColor = UIColor.clear
        edgeMenu.itemSpacing = 0.0
        edgeMenu.animationDuration = 0.8
        self.view.addSubview(edgeMenu)
    }
    

    func getVideo(){
    
        if self.seletedImage.isUploaded {
            activity.startAnimating()
            activity.isHidden = false
            let strvideo = self.seletedImage.coverImage.trim()
            self.getLocalPath(strURl: strvideo) { (filePath,fileURL) in
                if let filePath = filePath, let fileURL = fileURL {
                    self.fileLocalPath = filePath
                    self.localFileURl = fileURL
                    self.originalFileURl = fileURL
                    self.originalFile = filePath
                    self.openPlayer(videoUrl: fileURL)
                }
                self.activity.stopAnimating()
                self.activity.isHidden = true
                guard let edgeMenu = self.edgeMenu else { return }
                if edgeMenu.opened  == false{
                    edgeMenu.open()
                }
            }
        }else {
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.fileLocalPath = self.seletedImage.fileUrl?.absoluteString
                self.localFileURl = self.seletedImage.fileUrl
                self.originalFileURl = self.seletedImage.fileUrl
                self.originalFile = self.seletedImage.fileUrl?.absoluteString
                self.openPlayer(videoUrl: self.seletedImage.fileUrl!)
                guard let edgeMenu = self.edgeMenu else { return }
                if edgeMenu.opened  == false{
                    edgeMenu.open()
                }
            }
        }
       
    }
    
    
    func configureNavigationButtons(){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        let btnback = UIBarButtonItem(image: #imageLiteral(resourceName: "back_new"), style: .plain, target: self, action: #selector(self.buttonBackAction))
        let imgSave = UIImage(named: "icons8-download")
        let btnSave = UIBarButtonItem(image: imgSave, style: .plain, target: self, action: #selector(self.btnSaveAction))
        self.navigationItem.leftBarButtonItem = btnback
        self.navigationItem.rightBarButtonItem = btnSave
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == false{
            edgeMenu.open()
        }
    }
    
    
    func configureNavigationForEditing(){
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == true {
            edgeMenu.close()
        }
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.btnCancelAction))
        let btnSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.btnApplyFeatureAction))
        self.navigationItem.leftBarButtonItem = btnCancel
        self.navigationItem.rightBarButtonItem = btnSave
        navigationItem.hidesBackButton = true
    }
    
    func removeAllNavButtons(){
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == true {
            edgeMenu.close()
        }
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func configureNavigationForTextEditing(){
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == true {
            edgeMenu.close()
        }
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        let btnCancel = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.btnTextEditingDone))
        self.navigationItem.rightBarButtonItem = btnCancel
        navigationItem.hidesBackButton = true
    }
    
    
    
  
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    
    func closePreview(){
        self.kTrimmerHeight.constant = 0.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func openPlayer(videoUrl:URL){
        
        player = BMPlayer()
        let asset = BMPlayerResource(url: videoUrl)
        player.setVideo(resource: asset)
        playerContainerView.addSubview(player)
        player.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.playerContainerView)
            maker.leading.equalTo(self.playerContainerView)
            maker.trailing.equalTo(self.playerContainerView)
            maker.bottom.equalTo(self.playerContainerView)
        }
        // Back button event
        player.backBlock = {  (isFullScreen) in
            if isFullScreen == true { return }
            //let _ = self.navigationController?.popViewController(animated: true)
        }
        player.playStateDidChange = { (isPlaying: Bool) in
            print("playStateDidChange \(isPlaying)")
        }
        
        //Listen to when the play time changes
        player.playTimeDidChange = { (currentTime: TimeInterval, totalTime: TimeInterval) in
            print("playTimeDidChange currentTime: \(currentTime) totalTime: \(totalTime)")
        }
        if !(self.edgeMenu?.opened)! {
            self.edgeMenu?.open()
        }
        
    }
    
    
    
    func getLocalPath(strURl: String,handler:@escaping (_ filePath: String?, _ fileURL:URL?)-> Void){
        APIManager.sharedInstance.download(strFile: strURl) { (filePath,fileURL) in
                handler(filePath,fileURL)
        }
    }
    
    func showActivity(){
        self.activity.isHidden = false
        self.activity.startAnimating()
    }
    func hideActivity(){
        self.activity.stopAnimating()
        self.activity.isHidden = true
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
