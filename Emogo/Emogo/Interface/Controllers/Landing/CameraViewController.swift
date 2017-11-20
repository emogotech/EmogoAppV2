//
//  CameraViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import SwiftyCam
import DKImagePickerController

class CameraViewController: SwiftyCamViewController {
    
    
    // MARK: - UI Elements
    @IBOutlet weak var btnFlash:  VKExpandableButton!
    @IBOutlet weak var btnPreviewOpen: UIButton!
    @IBOutlet weak var kPreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var previewCollection: UICollectionView!

    // MARK: - Variables
    var isRecording:Bool! = false
    var isPreviewOpen:Bool! = false
    var arrayPreview = [UIImage]()
    

    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareLayouts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Prepare Layouts

    func prepareLayouts(){
        
        cameraDelegate = self
        // Preview Height
        kPreviewHeight.constant = 0.0
        // adding FlashButton
        self.btnFlash.direction      = .Left
        self.btnFlash.options        = ["ON", "OFF",#imageLiteral(resourceName: "flash-icon")]
        self.btnFlash.imageInsets    = UIEdgeInsetsMake(12, 12, 12, 12)
        self.btnFlash.buttonBackgroundColor = UIColor.clear
        self.btnFlash.expandedButtonBackgroundColor = self.btnFlash.buttonBackgroundColor
        self.btnFlash.currentValue   = self.btnFlash.options[2]
        
        self.btnFlash.optionSelectionBlock = {
            index in
            print("[Left] Did select cat at index: \(index)")
            if index == 0 {
                self.flashEnabled = true
            }else {
                self.flashEnabled = false
            }
            self.btnFlash.currentValue   = self.btnFlash.options[2]
        }
        
      
    }
    
    
    // MARK: -  Action Methods And Selector
    @IBAction func btnActionCamera(_ sender: Any) {
        takePhoto()
    }
    
    @IBAction func btnActionTimer(_ sender: Any) {
    }
    
   
    @IBAction func btnActionRecord(_ sender: Any) {
        self.isRecording = !self.isRecording
        if self.isRecording == true {
            startVideoRecording()
        }else {
            stopVideoRecording()
        }
    }

    @IBAction func btnActionGallery(_ sender: Any) {
        let pickerController = DKImagePickerController()
        pickerController.sourceType = .photo
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
        }
        self.present(pickerController, animated: true, completion: nil)

    }
    
    @IBAction func btnActionShutter(_ sender: Any) {
    }
    
    @IBAction func btnActionBack(_ sender: Any) {
        self.navigationController?.pop()
    }
    
    @IBAction func btnAnimateViewAction(_ sender: Any) {
        self.animateView()
    }
    
    // MARK: - Class Methods
    

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
            self.view.layoutIfNeeded()
        }
    }
    private  func viewUP(){
        UIView.animate(withDuration: 0.5) {
            self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
            self.kPreviewHeight.constant = 129.0
              self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - API Methods

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - EXTESNION

// MARK: - Delegate And DataSources

extension CameraViewController:SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        self.arrayPreview.insert(photo, at: 0)
        if self.arrayPreview.count == 1 {
            self.kPreviewHeight.constant = 24.0
            self.view.layoutIfNeeded()
        }
        self.previewCollection.reloadData()
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        // Called if a SwiftyCamButton ends a long press gesture
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
        print(url)
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



extension CameraViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayPreview.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PreviewCell, for: indexPath) as! PreviewCell
        cell.setupPreviewWithType(type: .image, image: self.arrayPreview[indexPath.row])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 71.0, height: collectionView.frame.size.height)
    }
}

