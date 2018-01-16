//
//  CustomCameraViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import SwiftyCam

class CustomCameraViewController: SwiftyCamViewController {
    // MARK: - UI Elements
    @IBOutlet weak var btnFlash:  UIButton!
    @IBOutlet weak var btnPreviewOpen: UIButton!
    @IBOutlet weak var btnRecording: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnTimer: UIButton!
    @IBOutlet weak var btnShutter: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnFlashOn: UIButton!
    @IBOutlet weak var btnFlashOff: UIButton!
    @IBOutlet weak var btnFlashAuto: UIButton!
    
    @IBOutlet weak var viewFlashOptions: UIStackView!
    @IBOutlet weak var kPreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var previewCollection: UICollectionView!
    @IBOutlet weak var lblRecordTimer: UILabel!
    
    // MARK: - Variables
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

    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.prepareLayouts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
        lblRecordTimer.isHidden = true
        if ContentList.sharedInstance.arrayContent.count == 0 {
            kPreviewHeight.constant = 24.0
        }
        print(isSessionRunning)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareContainerToPresent()
        self.previewCollection.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        cameraDelegate = self
        doubleTapCameraSwitch = false
        allowBackgroundAudio = true
        self.btnPreviewOpen.isHidden = true
        self.viewFlashOptions.isHidden = true
        // Set ContDownLabel
        lblRecordTimer.isHidden = true
        self.lblRecordTimer.addAnimation()
        // Preview Height
        kPreviewHeight.constant = 24.0
        // Configure Sound For timer
        if let bUrl = Bundle.main.url(forResource: "beep", withExtension: "wav") {
            beepSound = Sound(url: bUrl)
        }
        
        // Configure record and capture Button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(captureModeTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        btnCamera.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordingModeTap(_:)))
        btnCamera.addGestureRecognizer(longGesture)
        
    }
    
    func prepareContainerToPresent(){
        if kContainerNav == "1" {
            kContainerNav = "2"
            arraySelectedContent! += ContentList.sharedInstance.arrayContent
            // remove all duplicate contents
            var seen = Set<String>()
            var unique = [ContentDAO]()
            for obj in arraySelectedContent! {
                if obj.isUploaded {
                    if !seen.contains(obj.contentID) {
                        unique.append(obj)
                        seen.insert(obj.contentID)
                    }
                }else if obj.type == .gif || obj.type == .link{
                    if !seen.contains(obj.coverImage.trim()) {
                        unique.append(obj)
                        seen.insert(obj.coverImage.trim())
                    }
                }else {
                    if !seen.contains(obj.fileName.trim()) {
                        unique.append(obj)
                        seen.insert(obj.fileName.trim())
                    }
                }
            }
            arraySelectedContent = unique
            ContentList.sharedInstance.arrayContent = unique
            performSegue(withIdentifier: kSegue_ContainerSegue, sender: self)
        }
        
        if !kBackNav.isEmpty {
            kBackNav = ""
            self.navigationController?.popNormal()
        }
        
        if ContentList.sharedInstance.arrayContent.count == 0 {
            self.btnShutter.isHidden = true
        }else {
            self.btnShutter.isHidden = false
        }
    }
    
    // MARK: -  Action Methods And Selector
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
                self.recordButtonTapped(isShow: false)
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
        switchCamera()
    }
    
    @IBAction func btnActionGallery(_ sender: Any) {
        
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            //     self?.selectedAssets = assets
            self?.preparePreview(assets: assets)
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
            //exceed max selection
        }
        viewController.selectedAssets = []
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 10
        configure.muteAudio = true
        configure.usedCameraButton = true
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
        
        /*
         let gallery = GalleryController()
         gallery.delegate = self
         present(gallery, animated: true, completion: nil)
         */
        
    }
    
    @IBAction func btnActionShutter(_ sender: Any) {
        if !kContainerNav.isEmpty {
            kContainerNav = "1"
            self.prepareContainerToPresent()
            return
        }
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
            self.navigationController?.pushNormal(viewController: objPreview)
        }
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
        // self.beepSound?.stop()
        if timer != nil {
            self.timer.invalidate()
        }
        if self.isCaptureMode == false {
            self.isRecording = false
            self.recordButtonTapped(isShow: false)
        }else {
            if kContainerNav.isEmpty {
                addLeftTransitionView(subtype: kCATransitionFromLeft)
            }else {
                kContainerNav = "1"
                self.prepareContainerToPresent()
            }
        }
    }
    
    func addLeftTransitionView(subtype:String){
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = subtype
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
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
    
    @objc func captureModeTap(_ sender: UIGestureRecognizer){
        print("Normal tap")
        
        self.lblRecordTimer.isHidden = true
        if self.captureInSec != nil {
            self.performCamera(action: .timer)
            self.btnCamera.isUserInteractionEnabled = false
        }else {
            self.performCamera(action: .capture)
        }
    }
    
    @objc func recordingModeTap(_ sender: UIGestureRecognizer){
        print("Long tap")
        switch sender.state {
        case .began:
            self.lblRecordTimer.text = "00:00:00"
            self.timeSec = 0
            self.lblRecordTimer.isHidden = false
            self.performCamera(action: .recording)
            self.recordButtonTapped(isShow: true)
            break
        case .ended:
            self.lblRecordTimer.isHidden = true
            self.recordButtonTapped(isShow: false)
            self.performCamera(action: .stop)
            break
            
        default: break
        }
        
    }
    
    
    // MARK: - Class Methods
    
    func preparePreview(assets:[TLPHAsset]){
        if   ContentList.sharedInstance.arrayContent.count == 0  && assets.count != 0 {
            self.viewUP()
        }
        HUDManager.sharedInstance.showHUD()
        let group = DispatchGroup()
        for obj in assets {
            group.enter()
            let camera = ContentDAO(contentData: [:])
            camera.isUploaded = false
            camera.fileName = obj.originalFileName
            if obj.type == .photo {
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
                    if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:url) {
                        camera.imgPreview = image
                        self.updateData(content: camera)
                    }
                    group.leave()
                })
            }
        }
        
        group.notify(queue: .main, execute: {
            HUDManager.sharedInstance.hideHUD()
            self.btnPreviewOpen.isHidden = false
            self.btnShutter.isHidden = false
            self.previewCollection.reloadData()
        })
        /*
         
         Image.resolve(images: assets, completion: {  resolvedImages in
         for i in 0..<resolvedImages.count {
         let obj = resolvedImages[i]
         let camera = ContentDAO(contentData: [:])
         camera.imgPreview = obj
         camera.type = .image
         camera.isUploaded = false
         if let file =  assets[i].asset.value(forKey: "filename"){
         camera.fileName = file as! String
         }
         ContentList.sharedInstance.arrayContent.insert(camera, at: 0)
         }
         self.btnPreviewOpen.isHidden = false
         self.previewCollection.reloadData()
         })
         */
        
    }
    
    private func animateView(){
        UIView.animate(withDuration: 0.5) {
            self.isPreviewOpen = !self.isPreviewOpen
            if self.isPreviewOpen == false {
                // Down icon
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
                self.kPreviewHeight.constant = 129.0
            }else {
                // Up icon
                self.kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
            }
            self.previewCollection.reloadData()
            self.view.updateConstraintsIfNeeded()
        }
    }
    private  func viewUP(){
        UIView.animate(withDuration: 0.5) {
            self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
            self.kPreviewHeight.constant = 129.0
            self.view.updateConstraintsIfNeeded()
        }
    }
    
    func updateData(content:ContentDAO) {
        if  ContentList.sharedInstance.arrayContent.count == 0 {
            self.btnShutter.isHidden = false
            self.viewUP()
        }
        ContentList.sharedInstance.arrayContent.insert(content, at: 0)
        self.btnPreviewOpen.isHidden = false
    }
    
    
    // MARK: - API Methods
    
    
    // MARK: - Navigation
    
    // In a storyboard-based  application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == kSegue_ContainerSegue {
            if let destinationViewController = segue.destination as? ContainerViewController {
                destinationViewController.transitioningDelegate = self
                destinationViewController.interactor = interactor
            }
        }
        
    }
}


// MARK: - EXTESNION

// MARK: - Delegate And DataSources

extension CustomCameraViewController:SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let camera = ContentDAO(contentData: [:])
        camera.type = .image
        camera.imgPreview = photo.fixOrientation()
        camera.fileName = NSUUID().uuidString + ".png"
        self.updateData(content: camera)
        self.btnCamera.isUserInteractionEnabled = true
        self.previewCollection.reloadData()
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
        self.lblRecordTimer.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(CustomCameraViewController.updateRecordingTime)), userInfo: nil, repeats: true)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        // Called if a SwiftyCamButton ends a long press gesture
        timer.invalidate()
        self.lblRecordTimer.isHidden = true
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
        if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:url) {
            let camera = ContentDAO(contentData: [:])
            camera.type = .video
            camera.imgPreview = image
            camera.fileName = url.absoluteString.getName()
            camera.fileUrl = url
            print(camera.fileName)
            self.updateData(content: camera)
            self.previewCollection.reloadData()
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        // Called when a user initiates a tap gesture on the preview layer
        // Will only be called if tapToFocus = true
        // Returns a CGPoint of the tap location on the preview layer
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
}



extension CustomCameraViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return   ContentList.sharedInstance.arrayContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PreviewCell, for: indexPath) as! PreviewCell
        let obj =   ContentList.sharedInstance.arrayContent[indexPath.row]
        cell.setupPreviewWithType(content: obj)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height - 30, height: collectionView.frame.size.height - 10)
    }
}




extension CustomCameraViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("dissmiss")
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        DispatchQueue.main.async { // Correct
            self.session.startRunning()
        }
        return interactor.hasStarted ? interactor : nil
    }
}

