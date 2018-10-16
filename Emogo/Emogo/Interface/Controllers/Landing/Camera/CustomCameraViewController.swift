//
//  CustomCameraViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import SwiftyCam
import CropViewController
import RS3DSegmentedControl
import Haptica

//MARK: ⬇︎⬇︎⬇︎ PROTOCOLS ⬇︎⬇︎⬇︎


protocol CustomCameraViewControllerDelegate {
    func dismissWith(image:UIImage?)
}




class CustomCameraViewController: SwiftyCamViewController {
    
    
    //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎
    
    @IBOutlet weak var btnFlash:  UIButton!
    @IBOutlet weak var btnPreviewOpen: UIButton!
    @IBOutlet var cameraButtonContainer: UIView!
    @IBOutlet weak var btnCamera: SwiftyRecordButton!
    @IBOutlet var btnCameraSwitch: UIButton!
    @IBOutlet weak var btnTimer: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnFlashOn: UIButton!
    @IBOutlet weak var btnFlashOff: UIButton!
    @IBOutlet weak var btnFlashAuto: UIButton!
    @IBOutlet weak var viewFlashOptions: UIStackView!
    @IBOutlet weak var kPreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var previewCollection: UICollectionView!
    @IBOutlet weak var lblRecordTimer: UILabel!
    @IBOutlet weak var cameraModeOptions: UIView!
    @IBOutlet weak var previewContainer: UIView!
    
    //MARK: ⬇︎⬇︎⬇︎ Variables ⬇︎⬇︎⬇︎

    var isRecording:Bool! = false
    var isPreviewOpen:Bool! = false
    var isFlashClicked:Bool! = false
    var isCaptureMode: Bool! = true
    
    var timer:Timer!
    var timeSec = 0
    var captureInSec:Int?
    var beepSound: Sound?
    let interactor = PMInteractor()
    var selectedAssets = [TLPHAsset]()
    var delegate:CustomCameraViewControllerDelegate?
    var isDismiss:Bool?
    var cameraMode:CameraMode! = .normal
    
    var isForImageOnly    :   Bool?
    
    //  var cameraOption:HMSegmentedControl = HMSegmentedControl()
    var cameraOption:RS3DSegmentedControl = RS3DSegmentedControl()
    
    fileprivate var focusing                     = false
    fileprivate var focusingOverlay              : UIImageView!
    var isSelected:Bool! = false
    
    
    
    //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.prepareLayouts()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        self.hideStatusBar()
        lblRecordTimer.isHidden = true
        SharedData.sharedInstance.tempVC = self
   
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.stopVideo), name: NSNotification.Name("StopRec"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.forceStopVideoRecording), name: NSNotification.Name("ForceStopVideoRecording"), object: nil)
        
        isSelected = false
        
        if self.isDismiss == nil {
            if ContentList.sharedInstance.arrayContent.count == 0 {
                kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
                self.addNextButton(isAddButton: false)
            }
        }
        print(isSessionRunning)
        
        if self.isForImageOnly != nil {
            self.cameraModeOptions.isHidden = true
        }
        prepareNavBarButtons()
        self.prepareContainerToPresent()
        self.previewCollection.reloadData()
        if self.focusingOverlay != nil {
            if self.focusingOverlay.superview != nil  {
                self.focusingOverlay.removeFromSuperview()
            }
        }
       
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SharedData.sharedInstance.tempVC = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ForceStopVideoRecording"), object: nil)
        
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("StopRec"), object: nil)
        if isSelected == false {
//            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//            self.navigationController?.navigationBar.shadowImage = nil
        }
        self.showStatusBar()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "adjustingFocus" {
            self.isFocusing(change: change!)
        }
        
    }
    
    
    
    
    //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎

    func prepareLayouts(){
        btnCamera.isEnabled = true
        btnCamera.delegate = self
        if kDefault?.bool(forKey: kHapticFeedback) == true {
            self.btnCamera.isHaptic = true
            self.btnCamera.hapticType = .impact(.heavy)
        }else{
            self.btnCamera.isHaptic = false
        }
        
        //        btnCamera.center = self.cameraButtonContainer.center
        //        let frameForCamera = self.cameraButtonContainer.frame
        //        btnCamera.frame = frameForCamera
        //        self.cameraButtonContainer.addSubview(btnCamera)
        //        view.addSubview(btnCamera)
        //        btnCamera.frame = CGRect(x: view.frame.midX - 37.5, y: view.frame.height - 160.0, width: 75.0, height: 75.0)
        
        cameraDelegate = self
        tapToFocus = true
        doubleTapCameraSwitch = false
        allowAutoRotate = true
        shouldUseDeviceOrientation = true
        allowBackgroundAudio = true
        self.btnPreviewOpen.isHidden = true
        self.viewFlashOptions.isHidden = true
        // Set ContDownLabel
        lblRecordTimer.isHidden = true
        self.lblRecordTimer.addAnimation()
        self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
        // Preview Height
        kPreviewHeight.constant = 24.0
        videoGravity = .resizeAspectFill
        // Configure Sound For timer
        if let bUrl = Bundle.main.url(forResource: "beep", withExtension: "wav") {
            beepSound = Sound(url: bUrl)
        }
        
        // Configure record and capture Button
        
        if self.isForImageOnly != nil {
            self.btnCamera.gestureRecognizers?.removeAll()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(captureModeTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        btnCamera.addGestureRecognizer(tapGesture)
        
        if self.isDismiss == nil {
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordingModeTap(_:)))
            btnCamera.addGestureRecognizer(longGesture)
        }
        self.cameraModeOptions.isUserInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeCameraModeGestureAction(gesture:)))
        swipeLeft.direction = .left
        self.cameraModeOptions.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeCameraModeGestureAction(gesture:)))
        swipeRight.direction = .right
        self.cameraModeOptions.addGestureRecognizer(swipeRight)
        
        // Camera Options
        if self.isForImageOnly != true {
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureAction(gesture:)))
            swipeDown.direction = .down
            self.previewCollection.addGestureRecognizer(swipeDown)
            self.perform(#selector(self.prepareForCameraMode), with: nil, afterDelay: 0.2)
         
            
        }
        
    }
    
  
    
    func prepareNavBarButtons(){
        if self.navigationController?.isNavigationBarHidden == true {
            self.navigationController?.isNavigationBarHidden = false
            navigationItem.hidesBackButton = true
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = .clear
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = .clear
        let button   = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        button.contentHorizontalAlignment  = .left
        button.contentVerticalAlignment = .bottom
        button.setImage(#imageLiteral(resourceName: "back icon_shadow"), for: .normal)
        button.addTarget(self, action: #selector(self.btnBack), for: .touchUpInside)
        let btnBack = UIBarButtonItem(customView: button)
      
        self.navigationItem.leftBarButtonItem = btnBack
    }
    
    func addNextButton(isAddButton:Bool){
        if isAddButton {
            self.navigationItem.rightBarButtonItem  = nil
            let buttonNext   = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
            buttonNext.setImage(#imageLiteral(resourceName: "share_button"), for: .normal)
            buttonNext.addTarget(self, action: #selector(self.previewScreenNavigated), for: .touchUpInside)
            buttonNext.showsTouchWhenHighlighted = false
            buttonNext.adjustsImageWhenHighlighted = false

            buttonNext.isHighlighted = false
            buttonNext.contentHorizontalAlignment  = .right
            buttonNext.contentVerticalAlignment = .bottom
            buttonNext.adjustsImageWhenHighlighted = false
            let btnNext = UIBarButtonItem(customView: buttonNext)
            self.navigationItem.rightBarButtonItem = btnNext
        }else {
            self.navigationItem.rightBarButtonItem  = nil
        }
        
    }
    func setupButtonWhileRecording(isAddButton:Bool){
        if isAddButton {
            self.navigationItem.rightBarButtonItem  = nil
            self.navigationItem.leftBarButtonItem  = nil
            let button   = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
            button.setImage(#imageLiteral(resourceName: "back icon_shadow"), for: .normal)
            button.addTarget(self, action: #selector(self.btnBack), for: .touchUpInside)
            button.contentHorizontalAlignment  = .left
            button.contentVerticalAlignment = .bottom
            let btnBack = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = btnBack
            
            let buttonNext   = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
            buttonNext.setImage(#imageLiteral(resourceName: "share_button"), for: .normal)
            buttonNext.addTarget(self, action: #selector(self.previewScreenNavigated), for: .touchUpInside)
            buttonNext.showsTouchWhenHighlighted = false
            buttonNext.isHighlighted = false
            buttonNext.adjustsImageWhenHighlighted = false
            buttonNext.contentHorizontalAlignment  = .right
            buttonNext.contentVerticalAlignment = .bottom
            let btnNext = UIBarButtonItem(customView: buttonNext)
            self.navigationItem.rightBarButtonItem = btnNext
        }else {
            self.navigationItem.rightBarButtonItem  = nil
            self.navigationItem.leftBarButtonItem  = nil
        }
        
    }
    
    
    func prepareContainerToPresent(){
        if ContentList.sharedInstance.arrayContent.count == 0 {
           
            self.addNextButton(isAddButton: false)
            self.btnPreviewOpen.isHidden = true
            kPreviewHeight.constant = 24.0
        }else {
            
            self.addNextButton(isAddButton: true)
        }
    }
    
    
    //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎
    
    @IBAction func btnActionCamera(_ sender: Any) {
        
        
        if isCaptureMode == true {
            self.performCamera(action: .capture)
        }else {
            self.isRecording = !self.isRecording
            if self.isRecording == true {
                self.btnCamera.setImage(#imageLiteral(resourceName: "video_stop"), for: .normal)
                self.lblRecordTimer.text = "00:00:00"
                self.timeSec = 0
                self.lblRecordTimer.isHidden = false
                self.performCamera(action: .recording)
            }else {
               
                self.performCamera(action: .stop)
            }
        }
        
    }
    
    @IBAction func btnActionTimer(_ sender: Any) {
        timeSec = 0
        let alert = UIAlertController(title: kAlert_Select_Time, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: TimerSet.fiveSec.rawValue, style: .default) { (action) in
            self.captureInSec = 5
        }
        let action2 = UIAlertAction(title: TimerSet.tenSec.rawValue, style: .default) { (action) in
            
            self.captureInSec = 10
        }
        let action3 = UIAlertAction(title: TimerSet.fifteenSec.rawValue, style: .default) { (action) in
            self.captureInSec = 15
        }
        
        let action = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel) { (action) in
            
        }
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func btnActionSwitchCamera(_ sender: Any) {
        
        if kDefault?.bool(forKey: kHapticFeedback) == true {
            Haptic.impact(.heavy).generate()
            self.btnCameraSwitch.isHaptic = true
            self.btnCameraSwitch.hapticType = .impact(.heavy)
        }else{
            self.btnCameraSwitch.isHaptic = false
        }
        switchCamera()
    }
    
    @IBAction func btnActionGallery(_ sender: Any) {
        
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            //     self?.selectedAssets = assets
            if assets.count > 0 {
                self?.preparePreview(assets: assets)
            }
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
            //exceed max selection
        }
        viewController.selectedAssets = [TLPHAsset]()
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        if self.isDismiss != nil {
            configure.allowedVideo =  false
            configure.singleSelectedMode = true
            configure.maxSelectedAssets = 1
        }else if kDefault?.value(forKey: kRetakeIndex) != nil  {
            configure.allowedVideo =  false
            configure.singleSelectedMode = true
            configure.maxSelectedAssets = 1
        }
        else {
            configure.maxSelectedAssets = 10
        }
        configure.muteAudio = false
        configure.usedCameraButton = false
        configure.usedPrefetch = false
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    @IBAction func btnActionShutter(_ sender: Any) {
        previewScreenNavigated()
    }
    
    @IBAction func btnActionFlash(_ sender: Any) {
        self.isFlashClicked = !self.isFlashClicked
        if self.isFlashClicked == true {
            self.viewFlashOptions.isHidden = false
        }else {
            self.viewFlashOptions.isHidden = true
        }
        
    }
    
    @IBAction func btnActionBack(_ sender: Any) {
       
        if timer != nil {
            self.timer.invalidate()
        }
        if self.isDismiss != nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
     
        if self.isCaptureMode == false {
            self.isRecording = false
         
        }else {
            if kContainerNav.isEmpty {
               
                
                self.navigationController?.popNormal()
            }else {
                kContainerNav = "1"
                self.prepareContainerToPresent()
            }
        }
    }
    
    
    
    
    @IBAction func btnAnimateViewAction(_ sender: Any) {
        self.animateView()
    }
    
    @IBAction func btnActionFlashOptions(_ sender: UIButton) {
        switch sender.tag {
        case 111:
            self.flashOption(options: .on)
            break
        case 222:
            self.flashOption(options: .off)
            break
        case 333:
            self.flashOption(options: .auto)
            break
        default:
            break
        }
    }
    
    
    
    
    @objc func stopVideo(){
        if isRecording {
            if timer != nil {
                self.timer.invalidate()
                self.timeSec = 0
            }
            DispatchQueue.main.async {
                self.lblRecordTimer.isHidden = true
            }
            if ContentList.sharedInstance.arrayContent.count > 0 {
                self.setupButtonWhileRecording(isAddButton: true)
            }else{
                self.prepareNavBarButtons()
            }
            self.cameraOption.isUserInteractionEnabled = true
            //            self.recordButtonTapped(isShow: false)
            self.performCamera(action: .stop)
        }
    }
    
    
    @objc func forceStopVideoRecording(){
        if isRecording {
            if timer != nil {
                self.timer.invalidate()
                self.timeSec = 0
            }
            self.lblRecordTimer.isHidden = true
            if ContentList.sharedInstance.arrayContent.count > 0 {
                self.setupButtonWhileRecording(isAddButton: true)
            }else{
                self.prepareNavBarButtons()
            }
            self.cameraOption.isUserInteractionEnabled = true
            forceStopRecording()
        }
    }
    
    @objc func prepareForCameraMode(){
        
        self.cameraOption = RS3DSegmentedControl(frame: CGRect(x: 0, y: 0, width: self.cameraModeOptions.frame.size.width, height: self.cameraModeOptions.frame.size.height))
        cameraModeOptions.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        self.cameraOption.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        self.cameraOption.delegate = self
        self.cameraOption.selectedSegmentIndex = UInt(cameraMode.hashValue)
        self.cameraOption.textFont = UIFont(name: kFontRegular, size: 14.0)
        
        self.cameraModeOptions.addSubview(self.cameraOption)
    }
    
    
    
    @objc func swipeGestureAction(gesture : UISwipeGestureRecognizer){
        if gesture.direction == .down {
            if ContentList.sharedInstance.arrayContent.count > 0{
                self.animateView()
            }
        }
     }
    
    @objc func swipeCameraModeGestureAction(gesture : UISwipeGestureRecognizer){
        if gesture.direction == .left {
            if cameraOption.selectedSegmentIndex == 0 {
                self.cameraOption.selectedSegmentIndex = 1
            }
        }else if gesture.direction == .right {
            if cameraOption.selectedSegmentIndex == 1 {
                self.cameraOption.selectedSegmentIndex = 0
            }
        }
    }
    
    
    @objc func captureModeTap(_ sender: UIGestureRecognizer){
        // print("Normal tap")
        
        
        if self.cameraMode  == .handFree {
            if isRecording {
                self.lblRecordTimer.isHidden = true
                //                self.recordButtonTapped(isShow: false)
                self.performCamera(action: .stop)
                isRecording = false
            }else {
                self.lblRecordTimer.isHidden = true
                if self.captureInSec != nil {
                    self.performCamera(action: .timer)
                    self.btnCamera.isUserInteractionEnabled = false
                    self.cameraOption.isUserInteractionEnabled = false
                }else {
                    isRecording = true
                    self.lblRecordTimer.text = "00:00:00"
                    self.timeSec = 0
                    self.lblRecordTimer.isHidden = false
                    self.performCamera(action: .recording)
                    self.cameraOption.isUserInteractionEnabled = false
                    setupButtonWhileRecording(isAddButton: false)
                    
                   
                }
            }
        }else {
            self.lblRecordTimer.isHidden = true
            if self.captureInSec != nil {
                self.performCamera(action: .timer)
                self.btnCamera.isUserInteractionEnabled = false
            }else {
                self.performCamera(action: .capture)
            }
        }
        
    }
    
    @objc func recordingModeTap(_ sender: UIGestureRecognizer){

        switch sender.state {
        case .began:
      
            self.lblRecordTimer.isHidden = true
            self.performCamera(action: .recording)
            self.cameraOption.isUserInteractionEnabled = false
          
            break
        case.cancelled:
            let button   = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
            button.setImage(#imageLiteral(resourceName: "back icon_shadow"), for: .normal)
            button.addTarget(self, action: #selector(self.btnBack), for: .touchUpInside)
            button.contentHorizontalAlignment  = .left
            button.contentVerticalAlignment = .bottom
            let btnBack = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = btnBack
            break
        case .ended:
            if self.cameraMode == .normal {
             
                self.lblRecordTimer.isHidden = true
             
                self.performCamera(action: .stop)
            }else{
       
            }
            break
            
        default: break
        }
    }
    
    @objc func hideFocusOverlay(){
        print("Hide Indicator")
        UIView.animate(withDuration: 0.25, animations: {
            self.focusingOverlay.alpha = 0.0
        }) { finished in
            self.focusingOverlay.removeFromSuperview()
        }
    }
    
    
    @objc  func btnBack() {
        self.navigationController?.navigationBar.isTranslucent = false
        kDefault?.removeObject(forKey: kRetakeIndex)
        if timer != nil {
            self.timer.invalidate()
        }
        if self.isDismiss != nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
     
        if self.isCaptureMode == false {
            self.isRecording = false
 
        }else {
            if kContainerNav.isEmpty {
                self.addLeftTransitionView(subtype: kCATransitionFromLeft)
              
               self.navigationController?.popNormal()
            }else {
                kContainerNav = "1"
                self.prepareContainerToPresent()
            }
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        SharedData.sharedInstance.tempVC = nil
        
    }
    
    @objc func previewScreenNavigated(){
        if !kContainerNav.isEmpty {
            kContainerNav = "1"
            self.prepareContainerToPresent()
            return
        }
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            
            let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            objPreview.isShowRetake = true
            if kDefault?.value(forKey: kRetakeIndex) != nil {
                let value:Int = kDefault?.value(forKey: kRetakeIndex) as! Int
                objPreview.selectedIndex = value
                kDefault?.removeObject(forKey: kRetakeIndex)
            }else {
                objPreview.selectedIndex = 0
            }
            self.addLeftTransitionView(subtype: kCATransitionFromRight)
            self.navigationController?.pushViewController(objPreview, animated: false)
            
        }
    }
    
    
    
    //MARK: ⬇︎⬇︎⬇︎Other Methods ⬇︎⬇︎⬇︎

    
    func preparePreview(assets:[TLPHAsset]){
        
        if self.isDismiss != nil {
            if self.delegate != nil {
                if assets[0].fullResolutionImage == nil
                {
                    assets[0].cloudImageDownload(progressBlock: { (progress) in
                        
                    }, completionBlock: { (image) in
                        if let img = image {
                            self.presentCropperWithImage(image: img)
                        }
                    })
                }else {
                    self.presentCropperWithImage(image: assets[0].fullResolutionImage!)
                    
                }
            }
            return
        }
        
        if   ContentList.sharedInstance.arrayContent.count == 0  && assets.count != 0 {
            self.viewUP()
        }
        HUDManager.sharedInstance.showHUD()
        let group = DispatchGroup()
        for obj in assets {
            group.enter()
            let camera = ContentDAO(contentData: [:])
            camera.isUploaded = false
            if obj.type == .photo || obj.type == .livePhoto {
                camera.fileName = NSUUID().uuidString + ".png"
                camera.type = .image
                
                if obj.fullResolutionImage != nil {
                    camera.imgPreview = obj.fullResolutionImage
                    self.updateData(content: camera)
                    group.leave()
                }else {
                    
                    obj.cloudImageDownload(progressBlock: { (progress) in
                        
                    }, completionBlock: { (image) in
                        if let img = image {
                            camera.imgPreview = img
                            camera.color = img.getColors().primary.toHexString
                            self.updateData(content: camera)
                        }
                        group.leave()
                    })
                }
                
            }else if obj.type == .video {
                camera.type = .video
                obj.tempCopyMediaFile(progressBlock: { (progress) in
                    print(progress)
                }, completionBlock: { (url, mimeType) in
                    camera.fileUrl = url
                    camera.fileName = url.lastPathComponent
                    obj.phAsset?.getOrigianlImage(handler: { (img, _) in
                        if img != nil {
                            camera.imgPreview = img
                            camera.color = img?.getColors().primary.toHexString
                        }else {
                            camera.imgPreview = #imageLiteral(resourceName: "stream-card-placeholder")
                        }
                        self.updateData(content: camera)
                        group.leave()
                    })
                })
            }
        }
        
        group.notify(queue: .main, execute: {
            HUDManager.sharedInstance.hideHUD()
            self.btnPreviewOpen.isHidden = false
            // self.btnShutter.isHidden = false
            self.addNextButton(isAddButton: true)
            self.previewCollection.reloadData()
            if kDefault?.value(forKey: kRetakeIndex) != nil  {
                self.previewScreenNavigated()
            }
        })
        
    }
    
    private func animateView(){
        UIView.animate(withDuration: 0.2) {
            
            
            self.isPreviewOpen = !self.isPreviewOpen
            if self.isPreviewOpen == false {
                // Down icon
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "preview_down_arrow"), for: .normal)
                self.kPreviewHeight.constant = 191.0
            }else {
                // Up icon
                self.kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
            }
           
            self.previewCollection.reloadData()
           
        }
    }
    private  func viewUP(){
        self.kPreviewHeight.constant = 191.0
        UIView.animate(withDuration: 0.2) {
            self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "preview_down_arrow"), for: .normal)
          
            self.isPreviewOpen = false
        }
    }
    
    func updateData(content:ContentDAO) {
        
        if  ContentList.sharedInstance.arrayContent.count == 0 {
       
            self.addNextButton(isAddButton: true)
            self.viewUP()
        }
        
        if kDefault?.value(forKey: kRetakeIndex) != nil {
            let value:Int = kDefault?.value(forKey: kRetakeIndex) as! Int
            let linkContent = ContentList.sharedInstance.arrayContent[value]
            linkContent.imgPreview = content.imgPreview
            linkContent.fileName = content.fileName
            if linkContent.type == .link {
                linkContent.coverImageVideo = ""
            }
            print(linkContent.type)
            print(linkContent.fileName)
            
            ContentList.sharedInstance.arrayContent[value] = linkContent
        }else   {
            ContentList.sharedInstance.arrayContent.insert(content, at: 0)
        }
        if self.isPreviewOpen == true {
            self.viewUP()
        }
        self.btnPreviewOpen.isHidden = false
        
    }
    
    
    
  
    // MARK: - Navigation
    
    // In a storyboard-based  application, you will often want to do a little preparation before navigation
    
    
    func presentCropperWithImage(image:UIImage){
        let croppingStyle = CropViewCroppingStyle.default
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // your code here
            self.present(cropController, animated: true, completion: nil)
        }
    }
    
  
    func isFocusing(change:[NSKeyValueChangeKey : Any]) {
        if let adjustingFocus = change[NSKeyValueChangeKey.newKey] as? Int {
            if adjustingFocus == 1 {
                focusing = true
                showFocusOverlay()
            }else {
                if focusing {
                    focusing = false
                    hideFocusOverlay()
                }
            }
        }
    }
    
    func showFocusOverlay(point:CGPoint? = nil){
        print("Show Preview")
        self.focusingOverlay = UIImageView(image: UIImage(named: "focus.png"))
        if self.focusingOverlay.superview != nil  {
            return
        }
        self.focusingOverlay.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        if point != nil {
            focusingOverlay.center = point!
        }else{
            focusingOverlay.center = self.view.center
        }
        focusingOverlay.alpha = 0.0
        print(focusingOverlay)
        view.addSubview(focusingOverlay)
        view.bringSubview(toFront: focusingOverlay)
        UIView.animate(withDuration: 0.25, animations: {
            self.focusingOverlay.alpha = 1.0
        })
        if point != nil {
            self.perform(#selector(self.hideFocusOverlay), with: nil, afterDelay: 0.1)
        }
    }
  
}


//MARK: ⬇︎⬇︎⬇︎ EXTENSION ⬇︎⬇︎⬇︎

//MARK: ⬇︎⬇︎⬇︎ Delegate And Datasource ⬇︎⬇︎⬇︎

extension CustomCameraViewController:SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        
        if kDefault?.bool(forKey: kHapticFeedback) == true {
            self.btnCamera.isHaptic = true
            self.btnCamera.hapticType = .impact(.heavy)
            Haptic.impact(.heavy).generate()
            if #available(iOS 10.0, *) {
                let impact = UIImpactFeedbackGenerator()
                impact.impactOccurred() // 2
            } else {
                // Fallback on earlier versions
            } // 1
            
            
        }
        
        if isDismiss == nil {
            let camera = ContentDAO(contentData: [:])
            camera.type = .image
            camera.imgPreview = photo
            camera.color = photo.getColors().primary.toHexString
            camera.fileName = NSUUID().uuidString + ".png"
            self.updateData(content: camera)
            self.btnCamera.isUserInteractionEnabled = true
            self.cameraOption.isUserInteractionEnabled = true
            DispatchQueue.main.async {
                self.previewCollection.reloadData()
                self.previewCollection.scrollToItemIfAvailable(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
            }
       
            
        }else {
            self.presentCropperWithImage(image: photo)
        }
        
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        
        if self.isForImageOnly != nil {
            return
        }
        
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
        isRecording = true
        self.lblRecordTimer.text = "00:00:00"
        self.timeSec = 0
        self.lblRecordTimer.isHidden = false
        self.cameraOption.isUserInteractionEnabled = false
  
        setupButtonWhileRecording(isAddButton: false)
        btnCamera.growButton()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(CustomCameraViewController.updateRecordingTime)), userInfo: nil, repeats: true)
        UIView.animate(withDuration: 0.25, animations: {
            self.btnFlash.alpha = 0.0
            self.btnTimer.alpha = 0.0
            self.btnGallery.alpha = 0.0
            self.btnCameraSwitch.alpha = 0.0
           
            
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        // Called if a SwiftyCamButton ends a long press gesture
        
        if self.isForImageOnly != nil {
            return
        }
        
        btnCamera.shrinkButton()
        timer.invalidate()
        self.lblRecordTimer.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            self.btnFlash.alpha = 1.0
            self.btnTimer.alpha = 1.0
            self.btnGallery.alpha = 1.0
            self.btnCameraSwitch.alpha = 1.0
           
        })
        
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
        
        if self.isForImageOnly != nil {
            return
        }
        Haptic.notification(.success).generate()
        if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:url,isSave:true) {
            let camera = ContentDAO(contentData: [:])
            camera.type = .video
            camera.imgPreview = image
            camera.color = image.getColors().primary.toHexString
            camera.fileName = url.absoluteString.getName()
            camera.fileUrl = url
            print(camera.fileName)
            self.cameraOption.isUserInteractionEnabled = true
            setupButtonWhileRecording(isAddButton: true)
            self.updateData(content: camera)
            self.previewCollection.reloadData()
            DispatchQueue.main.async {
                self.previewCollection.reloadData()
                self.previewCollection.scrollToItemIfAvailable(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        // Called when a user initiates a tap gesture on the preview layer
        // Will only be called if tapToFocus = true
        // Returns a CGPoint of the tap location on the preview layer
          self.showFocusOverlay(point: point)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        // Called when a user initiates a pinch gesture on the preview layer
        // Will only be called if pinchToZoomn = true
        // Returns a CGFloat of the current zoom level
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        // Called when user switches between cameras
        // Returns current camera selection
    }
    func swipeBackDelegate() {
        if self.isForImageOnly != nil || isRecording == true{
            return
        }
        self.addLeftTransitionView(subtype: kCATransitionFromLeft)
        self.navigationController?.popNormal()
    }
    func swipeUpDelegate() {
        if self.isForImageOnly != nil {
            return
        }
        if ContentList.sharedInstance.arrayContent.count > 0{
            self.animateView()
        }
    }
    func swipeDownDelegate() {
        if self.isForImageOnly != nil {
            return
        }
        if ContentList.sharedInstance.arrayContent.count > 0{
            self.animateView()
        }
    }
    
    func forceStopVideoRecordingDelegate() {
        if self.isForImageOnly != nil {
            return
        }
        btnCamera.forceShrinkButton()
        if timer != nil {
            timer.invalidate()
        }
        self.lblRecordTimer.isHidden = true
        self.btnFlash.alpha = 1.0
        self.btnTimer.alpha = 1.0
        self.btnGallery.alpha = 1.0
        self.btnCameraSwitch.alpha = 1.0
        self.setupButtonWhileRecording(isAddButton: false)
    }
    func unableToOpenCamera(){
        if self.isDismiss != nil {
            self.dismiss(animated: true, completion: nil)
            return
        }else {
            self.navigationController?.popNormal()
        }
    }
}



extension CustomCameraViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  ContentList.sharedInstance.arrayContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PreviewCell, for: indexPath) as! PreviewCell
        let obj =  ContentList.sharedInstance.arrayContent[indexPath.row]
        cell.setupPreviewWithType(content:obj)
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        cell.layer.cornerRadius = 8.0
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height - 65, height: collectionView.frame.size.height - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isSelected = true
        let obj =  ContentList.sharedInstance.arrayContent[indexPath.row]
        if obj.type == .image || obj.type == .video {
            self.openFullView(index: indexPath.row)
        }
    }
}

extension CustomCameraViewController:CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.dismiss(animated: true, completion: nil)
        
        if self.delegate != nil {
            self.dismiss(animated: true, completion: {
                self.delegate?.dismissWith(image: image)
            })
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        if self.delegate != nil {
            self.dismiss(animated: true, completion: {
                //   self.delegate?.dismissWith(image: cropViewController.image)
            })
        }
    }
}




