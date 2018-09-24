//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit


enum EditingFeature {
    case drawing
    case text
    case sticker
    case none
}
 class PhotoEditorViewController: UIViewController {
    
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var animatedImageView: FLAnimatedImageView!

    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var txtDescription: MBAutoGrowingTextView!
    @IBOutlet weak var txtTitle: UITextField!

    var isForEditOnly:Bool!
    
    public var image: UIImage?
    var imageToFilter:UIImage?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var stickers : [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    public var colors  : [UIColor] = []
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    // list of controls to be hidden
    public var hiddenControls : [control] = []
    
    
    var stickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    var lastScale:CGFloat! = 0.0

    var drawWidth:CGFloat = 5.0
    var stickersViewController: StickersViewController!
    
    var isText : Bool = false
    var isStriker : Bool = false
    var viewTxt : UIView?

     var edgeMenu: DPEdgeMenu?
     var edgeMenuLeft: DPEdgeMenu?
    var selectedFeature:EditingFeature! = .none
    
    var seletedImage:ContentDAO!
    var initContent:ContentDAO!
    var initImage:UIImage?
    var tempContentArray = [ContentDAO]()


    //Register Custom font before we load XIB
    public override func loadView() {
        registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        self.setImageView(image: image!)
        initContent = self.seletedImage
       
        initImage = image
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.screenEdgeSwiped(_:)))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)),
                                               name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)),
                                               name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillChangeFrame(_:)),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
        
        
        configureCollectionView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        activeTextView?.keyboardAppearance = .dark
        gradientImageView.isHidden = true
        prepareLeftMenu()
        self.txtDescription.text = ""
        self.txtDescription.placeholder = "Description"
        self.txtDescription.placeholderColor = UIColor.white
        
        self.txtTitle.placeholderColor(text: "Title", color:UIColor.white)
        
        txtDescription.delegate = self
        txtTitle.delegate = self
        if !seletedImage.description.isEmpty {
            var description  = seletedImage.description.trim()
            if seletedImage.description.count > 250 {
                description = seletedImage.description.trim(count: 250)
            }
            self.txtDescription.text = description
        }else{
            self.txtDescription.text = ""
        }
        
        if !seletedImage.name.isEmpty {
            var name  = seletedImage.name.trim()
            if seletedImage.name.count > 75 {
                name = seletedImage.name.trim(count: 75)
            }
            self.txtTitle.text = name
        }else{
            self.txtTitle.text = ""
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareRightSideMenu()
        self.hideStatusBar()
        self.prepareNavigation()
        self.viewDescription.isHidden = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         self.showStatusBar()
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewDescription.addShadow()
        self.txtTitle.addShadow()
        self.txtDescription.addShadow()
        self.viewDescription.addBlurView()
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
    
    func prepareRightSideMenu(){
        if self.seletedImage.type != .gif {

        let btnText = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnText.setImage(#imageLiteral(resourceName: "add_text"), for: .normal)
        btnText.setBackgroundImage(#imageLiteral(resourceName: "rectangle_up"), for: .normal)
        btnText.tag = 101
        btnText.isExclusiveTouch = true
        btnText.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnDraw = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnDraw.setImage(#imageLiteral(resourceName: "draw"), for: .normal)
        btnDraw.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnDraw.tag = 102
        btnDraw.isExclusiveTouch = true
        btnDraw.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnSticker = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnSticker.setImage(#imageLiteral(resourceName: "add_stickers"), for: .normal)
        btnSticker.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnSticker.tag = 103
        btnSticker.isExclusiveTouch = true
        btnSticker.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnNext = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnNext.setImage(#imageLiteral(resourceName: "other-gradient") , for: .normal)
        btnNext.setBackgroundImage(#imageLiteral(resourceName: "rectangle_down"), for: .normal)
        btnNext.tag = 104
        btnNext.isExclusiveTouch = true
        btnNext.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        self.edgeMenu = DPEdgeMenu(items: [btnText, btnDraw, btnSticker,btnNext],
                                   animationDuration: 0.0, menuPosition: .right)
        guard let edgeMenu = self.edgeMenu else { return }
        edgeMenu.backgroundColor = UIColor.clear
        edgeMenu.itemSpacing = 0.0
        edgeMenu.animationDuration = 0.1
        
        //        weak var weakSelf = self
        //        self.view.setMenuActionWithBlock { (tapGesture) in
        //            let strongSelf = weakSelf
        //            strongSelf!.updateSideBar()
        //        }
            self.view.addSubview(edgeMenu)
            edgeMenu.open()
        }

    }
    
    
    func prepareLeftMenu(){
        let draw1 = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        draw1.setImage(#imageLiteral(resourceName: "pen_big"), for: .normal)
        draw1.setBackgroundImage(#imageLiteral(resourceName: "rectangle_up"), for: .normal)
        draw1.tag = 101
        draw1.addTarget(self, action: #selector(self.actionForLeftMenu(sender:)), for: .touchUpInside)
        let draw2 = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        draw2.setImage(#imageLiteral(resourceName: "pen_medium"), for: .normal)
        draw2.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        draw2.tag = 102
        draw2.addTarget(self, action: #selector(self.actionForLeftMenu(sender:)), for: .touchUpInside)
        let draw3 = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        draw3.setImage(#imageLiteral(resourceName: "pen_small"), for: .normal)
        draw3.setBackgroundImage(#imageLiteral(resourceName: "rectangle_down"), for: .normal)
        draw3.tag = 103
        draw3.addTarget(self, action: #selector(self.actionForLeftMenu(sender:)), for: .touchUpInside)
        
        self.edgeMenuLeft = DPEdgeMenu(items: [draw1, draw2, draw3],
                                       animationDuration: 0.0, menuPosition: .left)
        guard let edgeMenu = self.edgeMenuLeft else { return }
        edgeMenu.backgroundColor = UIColor.clear
        edgeMenu.itemSpacing = 0.0
        edgeMenu.animationDuration = 0.1
        if edgeMenu.superview == nil {
            self.view.addSubview(edgeMenu)
        }
    }
    
    
    func setImageView(image: UIImage) {
        //imageView.image = image
        if self.seletedImage.type != .gif {
            self.animatedImageView.isHidden = true
            self.canvasView.isHidden = false
            self.canvasImageView.image = image
            let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
            imageViewHeightConstraint.constant = (size?.height)!
            canvasImageView.clipsToBounds = true
        }else {
            prepareGifView()
        }
    }
    
    func prepareGifView(){
        self.canvasView.isHidden = true
        self.animatedImageView.isHidden = false
        self.animatedImageView.setForAnimatedImage(strImage: seletedImage.coverImageVideo) { (_) in
            
        }
       // self.animatedImageView.setForAnimatedImage(strImage:seletedImage.coverImageVideo)
        SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
            image?.getColors({ (colors) in
                self.animatedImageView.backgroundColor = colors.primary
            })
        })
        self.animatedImageView.contentMode = .scaleAspectFit
    }
    func hideToolbar(hide: Bool?) {
        if hide == nil {
            configureNavigationButtons()
        }else if hide! {
            self.configureNavigationForText()
        }else {
            configureNavigationForSticker()
        }
    }
    
    func prepareNavigation() {

        if self.navigationController?.isNavigationBarHidden == true {
            self.navigationController?.isNavigationBarHidden = false
            let myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
            
            self.navigationController?.navigationBar.titleTextAttributes = myAttribute2
            navigationItem.hidesBackButton = true
            self.navigationController?.navigationBar.tintColor = UIColor.white
        }
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        
        configureNavigationButtons()
    }
    
    
    func configureNavigationForSticker(){
       configureNavigationForText()
        self.viewDescription.isHidden = true
    }
    
    func configureNavigationForText(){
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.btnCancelAction))
        btnCancel.tintColor = UIColor.white
        let btnSave = UIBarButtonItem(title: "Save ", style: .plain, target: self, action: #selector(self.btnApplyFeatureAction))
        btnSave.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = btnCancel
        self.navigationItem.rightBarButtonItem = btnSave
        
        navigationItem.hidesBackButton = true
    }
    
    func configureNavigationButtons(){
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        let btnback = UIBarButtonItem(image: #imageLiteral(resourceName: "back icon_shadow"), style: .plain, target: self, action: #selector(self.buttonBackAction))
        if self.seletedImage.type == .link {
            let imgSave = UIImage(named: "change_cover")
            let btnSave = UIBarButtonItem(image: imgSave, style: .plain, target: self, action: #selector(self.btnChangeCoverAction(_:)))
            self.navigationItem.rightBarButtonItem = btnSave
        }
        self.navigationItem.leftBarButtonItem = btnback
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == false{
            edgeMenu.open()
            
        }
    }
    func removeNavigationButtons(){
        navigationItem.hidesBackButton = true

        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}





