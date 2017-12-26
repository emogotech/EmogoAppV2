//
//  ContainerViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyCam
import Photos

enum ContainerType: String {
    case stuff = "200"
    case gallery = "201"
    case giphy = "204"
    case link = "400"
}


class ContainerViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnStuff: UIButton!
    @IBOutlet weak var btnImport: UIButton!
    @IBOutlet weak var btnLink: UIButton!
    @IBOutlet weak var btnGiphy: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var buttonNext: UIButton!

    var arraySelectedContent = [ContentDAO]()
    var arrayAssests = [ImportDAO]()

    var selectedConatiner: ContainerType = .stuff {
        
        didSet {
            updateConatiner()
        }
    }
    
    var btnNext:UIButton! = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "content_next_btn"), for: .normal)
        return btn
    }()
    var interactor:PMInteractor? = nil
    var captureSession = AVCaptureSession();
    var sessionOutput = AVCapturePhotoOutput();

    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]);
    var previewLayer = AVCaptureVideoPreviewLayer();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        arraySelectedContent = ContentList.sharedInstance.arrayContent
     }
    
    
    func prepareLayouts(){
        self.buttonNext.isHidden = true
        selectedConatiner = .stuff
        showHelperCircle()
        //  openPreviewCamera()
        self.checkCameraPermission()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareLayouts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = cameraView.bounds
    }
    
    
    func openPreviewCamera(){
        let controller = instantiatePreviewController()
        addChildViewController(controller)
        controller.view.frame = kFrame
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        cameraView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: cameraView.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: cameraView.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: cameraView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor),
            ])
       controller.didMove(toParentViewController: self)
    }
    
    func presentViewController(controller: UIViewController) {
        // Remove any child view controllers that have been presented.
        removeAllChildViewControllers()
        addChildViewController(controller)
        controller.view.frame = viewContainer.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        viewContainer.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: viewContainer.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: viewContainer.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
            ])
        controller.didMove(toParentViewController: self)
    }
    
    func checkCameraPermission(){
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .denied: break
        case .authorized:
            self.prepareCamera()
            break
        case .restricted: break
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    print("Granted access to \(cameraMediaType)")
                    self.prepareCamera()
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
            }
        }
    }
    
    func prepareCamera(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInDuoCamera, AVCaptureDevice.DeviceType.builtInTelephotoCamera,AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        for device in (deviceDiscoverySession.devices) {
            if(device.position == AVCaptureDevice.Position.back){
                do{
                        let input = try AVCaptureDeviceInput(device: device)
                        if(captureSession.canAddInput(input)){
                            captureSession.addInput(input);
                            
                            if(captureSession.canAddOutput(sessionOutput)){
                                captureSession.addOutput(sessionOutput);
                                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
                                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
                                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait;
                                DispatchQueue.main.async { // Correct
                                    self.cameraView.layer.addSublayer(self.previewLayer);
                                }
                            }
                        }
                    }
                    catch{
                        print("exception!");
                    }
                }
            }
        
        captureSession.startRunning()

    }
    
    @IBAction func btnActionController(_ sender: UIButton) {
       self.updateSegment(selected: sender.tag)
    }
    @IBAction func btnBackAction(_ sender: UIButton) {
        kBackNav = "2"
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    @IBAction func btnActionCamera(_ sender: Any) {
        kContainerNav = "2"
        ContentList.sharedInstance.arrayContent = self.arraySelectedContent
        dismiss(animated: true, completion: nil)
    }
    
    func showHelperCircle(){
        let center = CGPoint(x: view.bounds.width * 0.5, y: 100)
        let small = CGSize(width: 30, height: 30)
        let circle = UIView(frame: CGRect(origin: center, size: small))
        circle.layer.cornerRadius = circle.frame.width/2
        circle.backgroundColor = UIColor.white
        circle.layer.shadowOpacity = 0.8
        circle.layer.shadowOffset = CGSize()
        view.addSubview(circle)
        UIView.animate(
            withDuration: 0.5,
            delay: 0.25,
            options: [],
            animations: {
                circle.frame.origin.y += 200
                circle.layer.opacity = 0
        },
            completion: { _ in
                circle.removeFromSuperview()
        }
        )
    }
    
    // MARK: - Remove all Child ViewController
    
    private func removeAllChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    // MARK: - UIViewControllers
    
    private func instantiateMyStuffController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_MyStuffView) as? MyStuffViewController else { fatalError("Unable to instantiate an ViewController from the storyboard") }
        return controller
    }
    
    private func instantiateLinkController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_LinkView) as? LinkViewController else { fatalError("Unable to instantiate an ViewController from the storyboard") }
        return controller
    }
    private func instantiateImportController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ImportView) as? ImportViewController else { fatalError("Unable to instantiate an ViewController from the storyboard") }
        return controller
    }
    private func instantiateGiphyController() -> UIViewController  {
        guard let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_GiphyView) as? GiphyViewController else { fatalError("Unable to instantiate an ViewController from the storyboard") }
        return controller
    }
    
    
    @IBAction func btnActionNext(_ sender: Any) {
        HUDManager.sharedInstance.showHUD()

    self.updateConatentForGallery(array: self.arrayAssests) { (result) in
        HUDManager.sharedInstance.hideHUD()
        if self.arraySelectedContent.count
                != 0 {
    ContentList.sharedInstance.arrayContent = self.arraySelectedContent
    let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
    objPreview.strPresented = "TRUE"
    let nav = UINavigationController(rootViewController: objPreview)
    self.present(nav, animated: true, completion: nil)
    }
   self.arrayAssests.removeAll()
    }
        
    }
    
    func updateConatentForGallery(array:[ImportDAO],completed:@escaping ( _ result:Bool?)->Void){
        if array.count != 0 {
            let group = DispatchGroup()
            for imp in array {
                group.enter()
                let obj = imp.assest
                if obj?.mediaType == .video {
                    self.getVideoURL(asset: obj!, handler: { (url, image) in
                        if let url = url, let image = image {
                            let  con = ContentDAO(contentData: [:])
                            con.type = .video
                            con.imgPreview = image
                            con.fileUrl = url
                            con.isUploaded = false
                            if let file =  obj?.value(forKey: "filename"){
                            con.fileName = file as! String
                            }
                            //find(arr, "c")!              // 2
                            self.arraySelectedContent.insert(con, at: 0)
                        }
                        group.leave()
                    })
                }else {
                    self.getOrigianlImage(asset: obj!, handler: { (image) in
                        let con = ContentDAO(contentData: [:])
                        con.type = .image
                        con.imgPreview = image
                        con.isUploaded = false
                        if let file =  obj?.value(forKey: "filename"){
                            con.fileName = file as! String
                        }
                        self.arraySelectedContent.insert(con, at: 0)
                        group.leave()
                    })
                }
            }
            
            group.notify(queue: .main, execute: {
                print(self.arraySelectedContent.count)
                completed(true)
            })
        }else {
            completed(true)
        }
    }
    
    private func instantiatePreviewController() -> UIViewController  {
         let controller = PreviewCamera()
        return controller
    }
    
    private func updateConatiner(){
        switch selectedConatiner {
        case .stuff:
            let selectedVC = instantiateMyStuffController()
            self.presentViewController(controller:selectedVC)
            break
        case .link:
            let selectedVC = instantiateLinkController()
            self.presentViewController(controller:selectedVC)
            break
        case .gallery:
            let selectedVC = instantiateImportController()
            self.presentViewController(controller:selectedVC)
            break
        case .giphy:
            let selectedVC = instantiateGiphyController()
            self.presentViewController(controller:selectedVC)
            break
        }
    }
    
    func updateSegment(selected:Int){
        self.buttonNext.isHidden = true
        switch selected {
        case 111:
            self.selectedConatiner = .stuff
            self.btnStuff.setImage(#imageLiteral(resourceName: "my_stuff_active_icon"), for: .normal)
            self.btnLink.setImage(#imageLiteral(resourceName: "link_unactive_icon"), for: .normal)
            self.btnImport.setImage(#imageLiteral(resourceName: "import_unactive_icon"), for: .normal)
            self.btnGiphy.setImage(#imageLiteral(resourceName: "giphy_unactive_icon"), for: .normal)
            break
        case 222:
            self.btnStuff.setImage(#imageLiteral(resourceName: "my_stuff_unactive_icon"), for: .normal)
            self.btnLink.setImage(#imageLiteral(resourceName: "link_active_icon"), for: .normal)
            self.btnImport.setImage(#imageLiteral(resourceName: "import_unactive_icon"), for: .normal)
            self.btnGiphy.setImage(#imageLiteral(resourceName: "giphy_unactive_icon"), for: .normal)
            self.selectedConatiner = .link
            break
        case 333:
            self.btnStuff.setImage(#imageLiteral(resourceName: "my_stuff_unactive_icon"), for: .normal)
            self.btnLink.setImage(#imageLiteral(resourceName: "link_unactive_icon"), for: .normal)
            self.btnImport.setImage(#imageLiteral(resourceName: "import_active_icon"), for: .normal)
            self.btnGiphy.setImage(#imageLiteral(resourceName: "giphy_unactive_icon"), for: .normal)
            self.buttonNext.isHidden = false
            self.selectedConatiner = .gallery
            break
        case 444:
            self.btnStuff.setImage(#imageLiteral(resourceName: "my_stuff_unactive_icon"), for: .normal)
            self.btnLink.setImage(#imageLiteral(resourceName: "link_unactive_icon"), for: .normal)
            self.btnImport.setImage(#imageLiteral(resourceName: "import_unactive_icon"), for: .normal)
            self.btnGiphy.setImage(#imageLiteral(resourceName: "giphy_active_icon"), for: .normal)
            self.selectedConatiner = .giphy
            break
        default:
            break
        }
    }
    
    
    func getVideoURL(asset:PHAsset,handler:@escaping ( _ tempURL:URL?, _ image:UIImage?)->Void){
        
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset, info,ss) in
            
            if let urlAsset = asset as? AVURLAsset {
                if let image = SharedData.sharedInstance.getThumbnailImage(url: urlAsset.url) {
                    handler(urlAsset.url,image)
                }
            } else {
                handler( nil, nil)
            }
        }
        
    }
    
    
    func getOrigianlImage(asset:PHAsset,handler:@escaping (_ image:UIImage?)->Void){
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: self.view.bounds.size, contentMode: PHImageContentMode.aspectFill, options: options) { (image, userInfo) -> Void in
            handler(image)
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


class PreviewCamera:SwiftyCamViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
