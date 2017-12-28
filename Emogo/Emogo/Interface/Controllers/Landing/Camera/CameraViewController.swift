//
//  CameraViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import SwiftyCam
import Gallery

class CameraViewController: SwiftyCamViewController {
    
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
    var beepSound: Sound?
    let editor: VideoEditing = VideoEditor()
    let interactor = PMInteractor()

    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareLayouts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.previewCollection.reloadData()
        print(isSessionRunning)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareContainerToPresent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Prepare Layouts

    func prepareLayouts(){
        cameraDelegate = self
        allowBackgroundAudio = true
        self.btnPreviewOpen.isHidden = true
        self.viewFlashOptions.isHidden = true
        // Set ContDownLabel
        lblRecordTimer.isHidden = true
        self.lblRecordTimer.addAnimation()
        // Preview Height
        kPreviewHeight.constant = 24.0
        // Configure Gallery
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        Gallery.Config.tabsToShow = [.imageTab, .videoTab]
        Gallery.Config.initialTab =  .imageTab
        Gallery.Config.Camera.imageLimit =  10

        // Configure Sound For timer
        if let bUrl = Bundle.main.url(forResource: "beep", withExtension: "wav") {
            beepSound = Sound(url: bUrl)
        }
        
        // Configure record and capture Button
        /*
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(captureModeTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        btnCamera.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordingModeTap(_:)))
        btnCamera.addGestureRecognizer(longGesture)
 */
        
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
        let alert = UIAlertController(title: "Select Time", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "5s", style: .default) { (action) in
            self.captreIn(time: 5)
        }
        let action2 = UIAlertAction(title: "10s", style: .default) { (action) in
            self.captreIn(time: 10)
        }
        let action3 = UIAlertAction(title: "15s", style: .default) { (action) in
            self.captreIn(time: 15)
        }
    
        let action = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
   
    @IBAction func btnActionRecord(_ sender: Any) {
        timeSec = 0
        self.btnPreviewOpen.isHidden = true
        self.recordButtonTapped(isShow: true)
    }

    @IBAction func btnActionGallery(_ sender: Any) {
       let gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    
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
        if self.isCaptureMode == false {
            self.isRecording = false
            self.recordButtonTapped(isShow: false)
        }else {
            if kContainerNav.isEmpty {
                self.navigationController?.pop()
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
    
    @objc func captureModeTap(_ sender: UIGestureRecognizer){
        print("Normal tap")
        self.performCamera(action: .capture)
    }
    
    @objc func recordingModeTap(_ sender: UIGestureRecognizer){
        print("Long tap")
        switch sender.state {
        case .began:
            print("UIGestureRecognizerStateBegan.")
            self.lblRecordTimer.text = "00:00:00"
            self.timeSec = 0
            self.lblRecordTimer.isHidden = false
            self.performCamera(action: .recording)
            self.recordButtonTapped(isShow: true)
            break
        case .ended:
            print("UIGestureRecognizerStateEnded")
            self.recordButtonTapped(isShow: false)
            self.performCamera(action: .stop)
            break
            
        default: break
        }
       
    }
    
    
    // MARK: - Class Methods
    
    func preparePreview(assets:[Image]){
        if   ContentList.sharedInstance.arrayContent.count == 0  && assets.count != 0 {
            self.viewUP()
        }
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

extension CameraViewController:SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let camera = ContentDAO(contentData: [:])
        camera.type = .image
        camera.imgPreview = photo.fixOrientation()
        if  ContentList.sharedInstance.arrayContent.count == 0 {
            self.viewUP()
        }
        camera.fileName = NSUUID().uuidString + ".png"
        ContentList.sharedInstance.arrayContent.insert(camera, at: 0)
        self.btnPreviewOpen.isHidden = false
        self.previewCollection.reloadData()
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
        self.lblRecordTimer.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(CameraViewController.updateRecordingTime)), userInfo: nil, repeats: true)
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
            if  ContentList.sharedInstance.arrayContent.count == 0 {
                self.viewUP()
            }
            ContentList.sharedInstance.arrayContent.insert(camera, at: 0)
            self.btnPreviewOpen.isHidden = false
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



extension CameraViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
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


extension CameraViewController:GalleryControllerDelegate {
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        HUDManager.sharedInstance.showHUD()
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    print(tempPath)
                    if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:tempPath) {
                         let camera = ContentDAO(contentData: [:])
                        camera.imgPreview = image
                        camera.isUploaded = false
                        camera.fileName = tempPath.absoluteString.getName()
                        camera.fileUrl = tempPath
                        camera.type = .video
                        print(camera.fileName)
                        if  ContentList.sharedInstance.arrayContent.count == 0 {
                            self.viewUP()
                        }
                        ContentList.sharedInstance.arrayContent.insert(camera, at: 0)
                        self.btnPreviewOpen.isHidden = false
                        self.previewCollection.reloadData()
                        HUDManager.sharedInstance.hideHUD()
                    }
                }
            }
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        self.preparePreview(assets: images)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    }
}


extension CameraViewController: UIViewControllerTransitioningDelegate {
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
