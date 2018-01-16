//
//  ProfileUpdateViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import ALCameraViewController

class ProfileUpdateViewController: UIViewController {
    
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var txtName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPhone: SkyFloatingLabelTextField!

    var imageToUpload:UIImage!
    var fileName:String! = ""
    var minimumSize: CGSize = CGSize(width: 100, height: 100)
    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: minimumSize)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayouts(){
        self.imgUser.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profilepicUpload))
        tap.numberOfTapsRequired = 1
        self.imgUser.addGestureRecognizer(tap)
       self.prepareData()
    }

    
    func prepareData(){
        txtName.text = UserDAO.sharedInstance.user.fullName
        txtPhone.text = UserDAO.sharedInstance.user.phoneNumber
        self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage)
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
        if self.imageToUpload == nil {
            HUDManager.sharedInstance.showHUD()
            self.profileUpdate(strURL:UserDAO.sharedInstance.user.userImage)
        }else {
            
            self.uploadProfileImage()
        }
    }
    
    @objc func profilepicUpload() {
        
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            if let img = image{
                self?.setCoverImage(image: img)
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
        
    }
    
    func setCoverImage(image:UIImage) {
        self.imageToUpload = image
        self.imgUser.image = image
        self.fileName =  NSUUID().uuidString + ".png"
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
        
        APIServiceManager.sharedInstance.apiForUserProfileUpdate(name: (txtName.text?.trim())!, profilePic: strURL) { (isSuccess, errorMsg) in
            
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(strMSG: errorMsg!)
            }
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

