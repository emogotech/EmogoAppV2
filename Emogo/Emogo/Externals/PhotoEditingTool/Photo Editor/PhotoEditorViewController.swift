//
//  PhotoEditorViewController.swift
//  Emogo
//
//  Created by Pushpendra on 03/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import AVFoundation


enum FeatureType:String {
    case Text = "1"
    case Drawing = "2"
    case Sticker = "3"
    case None = "4"
}


class PhotoEditorViewController: UIViewController {
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var drawingView: ACEDrawingView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var baseImageView: UIImageView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtImageCaption: MBAutoGrowingTextView!
    @IBOutlet weak var viewSaveButton: UIView!
    @IBOutlet weak var viewDescription: UIView!


    var image:UIImage!
    fileprivate var edgeMenu: DPEdgeMenu?
    fileprivate var edgeMenuLeft: DPEdgeMenu?
    var stickersViewController: StickersViewController!
    var imageViewToPan: UIImageView?
    var stickersVCIsVisible = false
    var isStriker : Bool = false
    public var stickers : [UIImage] = []
    var lastPoint: CGPoint!
    var lastPanPoint: CGPoint?
    var selectedFeature:FeatureType! = FeatureType.None
    var originalImage:UIImage?
    public var colors  : [UIColor] = []
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    let shapes = ShapeDAO()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.prepareLayouts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareLayoutsWhenViewAppear()
    }
    

    func prepareLayouts(){
        self.baseImageView.image = self.image
        txtImageCaption.delegate = self
        self.txtImageCaption.text = ""
        self.txtImageCaption.placeholder = "Description"
        self.txtImageCaption.placeholderColor = .white
        
//        let size = self.image.suitableSize(widthLimit: UIScreen.main.bounds.size.width)
//        print(size?.height)
//        self.colorPickerViewBottomConstraint.constant = (size?.height)!
        configureCollectionView()
      //  configureKeyboardWithColor()
        self.deleteView.isHidden = true
        self.colorPickerView.isHidden = true
       // self.drawingView.draggableTextFontName = "MarkerFelt-Thin"
        self.baseImageView.isHidden = false
        self.originalImage = self.baseImageView.image
        self.drawingView.clear()
        prepareRightSideMenu()
        prepareLeftMenu()
        self.drawingView.delegate = self
        self.drawingView.isHidden = true
        self.stickers = shapes.shapes
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
    }
    
    
    func prepareLayoutsWhenViewAppear(){
        self.baseImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.updateContainerFrame()
        /*
        self.edgesForExtendedLayout = []//Optional our as per your view ladder
        
        let newView = UIView()
        newView.backgroundColor = .red
        self.view.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            newView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            newView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            newView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            newView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        } else {
            NSLayoutConstraint(item: newView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view, attribute: .top,
                               multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: newView,
                               attribute: .leading,
                               relatedBy: .equal, toItem: view,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: newView, attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            
            newView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
 */
        
    }
    
    func updateContainerFrame(){
          let frame  = AVMakeRect(aspectRatio: (self.baseImageView?.image?.size)!, insideRect: self.baseImageView.frame)
        print(frame)
        print(self.canvasView.frame)

        if frame.size.width > self.canvasView.frame.size.width {
             self.drawingView.frame = CGRect(x: self.canvasView.frame.origin.x, y: frame.origin.y, width: self.canvasView.frame.size.width, height: frame.size.height)
        }else {
            self.drawingView.frame  = frame
        }
        
       viewSaveButton.addBlurView()
       viewDescription.addBlurView()
    }
    
    func prepareNavigationBar(){
      
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
       self.prepareNavigationButton(isEditing: false)
    }
    
    func prepareNavigationButton(isEditing:Bool) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        if isEditing {
            let btnSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.actionForSaveButton))
             let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.actionForCancelButton))
            self.navigationItem.leftBarButtonItem = btnCancel
            self.navigationItem.rightBarButtonItem = btnSave
        }else {
            let back = UIBarButtonItem(image: #imageLiteral(resourceName: "photo-edit-back"), style: .plain, target: self, action: #selector(self.actionForBackButton))
            self.navigationItem.leftBarButtonItem = back
            let save = UIBarButtonItem(image:#imageLiteral(resourceName: "photo-Save") , style: .plain, target: self, action: #selector(self.actionForBackButton))
            self.navigationItem.rightBarButtonItem = save
        }
       
    }
    
    func hideView(isEditing:Bool) {
        if isEditing {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1.2 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                if self.selectedFeature != .Sticker {
                    self.colorPickerView.isHidden = false
                    Animation.viewSlideInFromBottomToTop(views: self.colorPickerView)
                }
                self.viewDescription.isHidden = true
                self.viewSaveButton.isHidden = true
                Animation.viewSlideInFromTopToBottom(views: self.viewDescription)
                Animation.viewSlideInFromTopToBottom(views: self.viewSaveButton)
            })
            
        }else {
            self.drawingView.isHidden = true
            self.deleteView.isHidden = true
            self.colorPickerView.isHidden = true
            Animation.viewSlideInFromTopToBottom(views: self.colorPickerView)
            self.viewDescription.isHidden = false
            self.viewSaveButton.isHidden = false
            Animation.viewSlideInFromBottomToTop(views: self.viewDescription)
            Animation.viewSlideInFromBottomToTop(views: self.viewSaveButton)
        }
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
    
    func configureKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)),
                                               name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)),
                                               name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillChangeFrame(_:)),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    
    
    func prepareRightSideMenu(){
        
        let btnText = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnText.setImage(#imageLiteral(resourceName: "add_text"), for: .normal)
        btnText.setBackgroundImage(#imageLiteral(resourceName: "rectangle_up"), for: .normal)
        btnText.tag = 102
        btnText.isExclusiveTouch = true
        btnText.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnDraw = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnDraw.setImage(#imageLiteral(resourceName: "draw"), for: .normal)
        btnDraw.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnDraw.tag = 103
        btnDraw.isExclusiveTouch = true
        btnDraw.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnSticker = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnSticker.setImage(#imageLiteral(resourceName: "add_stickers"), for: .normal)
        btnSticker.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnSticker.tag = 104
        btnSticker.isExclusiveTouch = true
        btnSticker.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnNext = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnNext.setImage(#imageLiteral(resourceName: "other-gradient") , for: .normal)
        btnNext.setBackgroundImage(#imageLiteral(resourceName: "rectangle_down"), for: .normal)
        btnNext.tag = 105
        btnNext.isExclusiveTouch = true
        btnNext.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        self.edgeMenu = DPEdgeMenu(items: [btnText, btnDraw, btnSticker,btnNext],
                                   animationDuration: 0.8, menuPosition: .right)
        guard let edgeMenu = self.edgeMenu else { return }
        edgeMenu.backgroundColor = UIColor.clear
        edgeMenu.itemSpacing = 0.0
        edgeMenu.animationDuration = 0.5
        
        edgeMenu.open()
        //        weak var weakSelf = self
        //        self.view.setMenuActionWithBlock { (tapGesture) in
        //            let strongSelf = weakSelf
        //            strongSelf!.updateSideBar()
        //        }
        self.view.addSubview(edgeMenu)
        
    }
    
    
    func prepareLeftMenu(){
        let draw1 = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        draw1.setImage(#imageLiteral(resourceName: "pen_big"), for: .normal)
        draw1.setBackgroundImage(#imageLiteral(resourceName: "rectangle_up"), for: .normal)
        draw1.tag = 101
        draw1.addTarget(self, action: #selector(self.actionForLeftMenu(sender:)), for: .touchUpInside)
        let draw2 = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        draw2.setImage(#imageLiteral(resourceName: "pen_medium"), for: .normal)
        draw2.setBackgroundImage(#imageLiteral(resourceName: "back_icon_base_big"), for: .normal)
        draw2.tag = 102
        draw2.addTarget(self, action: #selector(self.actionForLeftMenu(sender:)), for: .touchUpInside)
        let draw3 = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        draw3.setImage(#imageLiteral(resourceName: "pen_small"), for: .normal)
        draw3.setBackgroundImage(#imageLiteral(resourceName: "rectangle_down"), for: .normal)
        draw3.tag = 103
        draw3.addTarget(self, action: #selector(self.actionForLeftMenu(sender:)), for: .touchUpInside)
        
        self.edgeMenuLeft = DPEdgeMenu(items: [draw1, draw2, draw3],
                                       animationDuration: 0.8, menuPosition: .left)
        guard let edgeMenu = self.edgeMenuLeft else { return }
        edgeMenu.backgroundColor = UIColor.clear
        edgeMenu.itemSpacing = 1.0
        edgeMenu.animationDuration = 0.5
        if edgeMenu.superview == nil {
            self.view.addSubview(edgeMenu)
        }
    }
    
    
    func addStickersViewController() {
          stickersVCIsVisible = true
        // hideToolbar(hide: true)
        //  self.canvasImageView.isUserInteractionEnabled = false
        stickersViewController.stickersViewControllerDelegate = self
        
        for image in self.stickers {
            stickersViewController.stickers.append(image)
        }
        self.addChildViewController(stickersViewController)
        self.view.addSubview(stickersViewController.view)
        stickersViewController.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        stickersViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeStickersView() {
        stickersVCIsVisible = false
        isStriker = false
        for beforeTextViewHide in self.baseImageView.subviews {
            if beforeTextViewHide.isKind(of: UIImageView.self){
                if beforeTextViewHide.tag == 111{
                    isStriker = true
                }
            }
            if beforeTextViewHide.isKind(of: UIView.self){
                if   beforeTextViewHide.tag == 112 {
                    isStriker = true
                }
            }
        }
        self.baseImageView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.stickersViewController.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.stickersViewController.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.stickersViewController.view.removeFromSuperview()
            self.stickersViewController.removeFromParentViewController()
            if self.isStriker == true{
                //self.endDone()
            }else{
                //   self.hideToolbar(hide: false)
            }
            
        })
    }
    
    
    @objc func actionForBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func actionForSaveButton() {
        if self.selectedFeature == .Sticker {
            let img = self.baseImageView.toImage()
            self.baseImageView.image = img
            self.baseImageView.subviews[0].removeFromSuperview()
        }else {
            self.drawingView.prepareForSnapshot()
            let baseImage: UIImage = baseImageView.image!
            let resultImage: UIImage = self.drawingView.applyDraw(to: baseImage)
//            // close it after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(3 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                self.baseImageView.image = resultImage
                self.drawingView.clear()
            })
        }
        self.drawingView.isHidden = true
        self.deleteView.isHidden = true
        self.prepareNavigationButton(isEditing: false)
        guard let edgeMenu = self.edgeMenu else { return }
        if  edgeMenu.opened == false {
            edgeMenu.open()
        }
        
        guard let edgeMenuLeft = self.edgeMenuLeft else { return }
        if  edgeMenuLeft.opened == true {
            edgeMenuLeft.close()
        }
        self.hideView(isEditing: false)

    }
    
    @objc func actionForCancelButton() {
        if self.selectedFeature == .Sticker {
            if self.baseImageView.subviews.count > 0 {
                self.baseImageView.subviews[0].removeFromSuperview()
            }
        }else {
            self.drawingView.clear()
        }
        self.prepareNavigationButton(isEditing: false)
        guard let edgeMenu = self.edgeMenu else { return }
        if  edgeMenu.opened == false {
            edgeMenu.open()
        }
        
        guard let edgeMenuLeft = self.edgeMenuLeft else { return }
        if  edgeMenuLeft.opened == true {
            edgeMenuLeft.close()
        }
        self.drawingView.isHidden = true
        self.deleteView.isHidden = true
        self.hideView(isEditing: false)
    }
    
    @objc func actionForRightMenu(sender:UIButton) {
      
        switch sender.tag {
        case 101:
            break
        case 102:
            self.drawingView.isHidden = false
            self.deleteView.isHidden = true
            self.drawingView.drawTool = ACEDrawingToolTypeDraggableText
            selectedFeature = FeatureType.Text
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1.2 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                self.colorPickerView.isHidden = false
                Animation.viewSlideInFromBottomToTop(views: self.colorPickerView)
            })
            break
        case 103:
            self.deleteView.isHidden = true
            self.drawingView.isHidden = false
            self.drawingView.drawTool = ACEDrawingToolTypePen
            selectedFeature = FeatureType.Drawing
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1.2 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                guard let edgeMenu = self.edgeMenuLeft else { return }
                edgeMenu.open()
                self.colorPickerView.isHidden = false
                Animation.viewSlideInFromBottomToTop(views: self.colorPickerView)
            })
            break
        case 104:
            self.drawingView.isHidden = true
            self.deleteView.isHidden = false
            self.addStickersViewController()
            selectedFeature = FeatureType.Sticker
            self.colorPickerView.isHidden = true
            break
        case 105:
            
            let obj:FilterViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_FilterView) as! FilterViewController
            obj.image = self.baseImageView.image
            self.navigationController?.pushViewController(obj, animated: true)
            break
        default:
            break
        }
        
        if sender.tag != 105 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1.2 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
                guard let edgeMenu = self.edgeMenu else { return }
                edgeMenu.close()
                self.prepareNavigationButton(isEditing: true)
            })
            self.hideView(isEditing: true)
        }
        
    }
    
    @objc func actionForLeftMenu(sender:UIButton) {
        switch sender.tag {
        case 101:
            self.drawingView.lineWidth = 5.0
            break
        case 102:
            self.drawingView.lineWidth = 10.0
            break
        case 103:
            self.drawingView.lineWidth = 15.0
            break
        default:
            break
        }
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
