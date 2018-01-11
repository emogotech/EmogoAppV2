//
//  ProfileUpdateViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation

class ProfileUpdateViewController: UIViewController {
    
    @IBOutlet weak var imgUser: NZCircularImageView!
    
    var imageToUpload:UIImage!
    var fileName:String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayouts(){
        self.title = "Profile"
        self.imgUser.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profilepicUpload))
        tap.numberOfTapsRequired = 1
        self.imgUser.addGestureRecognizer(tap)
       
    }

    @objc func profilepicUpload() {
        
        let alert = UIAlertController(title: "Upload Picture", message: "", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            
            self.checkCameraPermission()
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.checkPhotoLibraryPermission()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func setCoverImage(image:UIImage) {
        self.imageToUpload = image
        self.imgUser.image = image
        self.fileName =  NSUUID().uuidString + ".png"
    }
    
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("Gallery Open")
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.openGallery()
            }
            break
        //handle authorized status
        case .denied :
            print("denied ")
            SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "gallery")
            break
            
        case .restricted:
            
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            print("denied ")
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    let when = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.openGallery()
                    }
                    break
                // as above
                case .denied, .restricted:
                    SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "gallery")
                    break
                // as above
                case .notDetermined:
                    break
                    // won't happen but still
                }
            }
        }
    }
    
    func checkCameraPermission(){
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.openCamera()
            break
        case .denied, .restricted :
            SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "camera")
            break
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    print("camera Open")
                    self.openCamera()
                } else {
                    //access denied
                    SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "camera")
                }
            })
            break
        }
        
    }
    
    
    private func openCamera(){
        if  UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            DispatchQueue.main.async {
                self.topMostController().present(imagePicker, animated: true, completion: nil)
            }
        }else {
            
        }
    }
    
    private func openGallery(){
        if  UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            DispatchQueue.main.async {
                self.topMostController().present(imagePicker, animated: true, completion: nil)
            }
        }else {
            
        }
        
    }
    
    func topMostController() -> UIViewController {
        
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    
    // MARK: - API
    
    private func uploadProfileImage(){
        HUDManager.sharedInstance.showHUD()
        let image = self.imageToUpload.reduceSize()
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let url = Document.saveFile(data: imageData!, name: self.fileName)
        let fileUrl = URL(fileURLWithPath: url)
        AWSManager.sharedInstance.uploadFile(fileUrl, name: self.fileName) { (imageUrl,error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.profileUpdate(strURL: imageUrl!)
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
    
    
    private func profileUpdate(strURL:String){
        
        
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



extension ProfileUpdateViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.setCoverImage(image: pickedImage)
        }
    }
    
}

