//
//  ProfileUpdateViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CropViewController

class ProfileUpdateViewController: UITableViewController {
    
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtBio: UITextView!
    @IBOutlet weak var txtWebsite: UITextView!
    @IBOutlet weak var txtLocation: UITextView!
    @IBOutlet weak var txtBirthday: UITextView!
    @IBOutlet weak var txtDisplayName: UITextView!


    var imageToUpload:UIImage!
    var fileName:String! = ""
    var delegate:CustomCameraViewControllerDelegate?
    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: false, allowResizing: false, allowMoving: false, minimumSize: CGSize.zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepreNavigation()

    }
    func prepareLayouts(){
       self.prepareData()
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    
    func prepareData(){
        txtName.text = UserDAO.sharedInstance.user.fullName.trim().capitalized
        txtName.isUserInteractionEnabled = false
        txtBio.text = UserDAO.sharedInstance.user.biography.trim()
        txtWebsite.text = UserDAO.sharedInstance.user.website.trim()
        txtDisplayName.text = UserDAO.sharedInstance.user.displayName.trim()
        //txtBirthday.text = UserDAO.sharedInstance.user.birthday.trim()
        txtLocation.text = UserDAO.sharedInstance.user.location.trim()
      //  self.imgUser.image = #imageLiteral(resourceName: "camera_icon_cover_images")
        if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
            self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage)
        }else{
            if UserDAO.sharedInstance.user.displayName.isEmpty {
                self.imgUser.setImage(string:UserDAO.sharedInstance.user.fullName, color: UIColor.colorHash(name:UserDAO.sharedInstance.user.fullName ), circular: true)
            }else{
                self.imgUser.setImage(string:UserDAO.sharedInstance.user.displayName, color: UIColor.colorHash(name:UserDAO.sharedInstance.user.displayName ), circular: true)
            }
        }
        
    }
    
    func prepreNavigation(){
        
        var myAttribute2:[NSAttributedStringKey:Any]!
        if let font = UIFont(name: kFontBold, size: 20.0) {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: font]
        }else {
            myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
        }
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2

        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "00ADF3")
        self.navigationController?.navigationBar.barTintColor = .white
        let img = UIImage(named: "profile_close_icon")
        let btnClose = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.btnCloseAction))
        self.navigationItem.leftBarButtonItem = btnClose
        
        let btnSave = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(self.btnDoneAction(_:)))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(myAttribute2, for: .normal)
        self.navigationItem.rightBarButtonItem = btnSave
       
        
        self.title = "Edit Profile"
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
//        let url = NSURL(string: txtWebsite.text.trim())
//        print(url)
//        if !txtWebsite.text.trim().isEmpty && NSURL(string: txtWebsite.text.trim()) == nil  {
//
//            self.showToast(strMSG: kAlert_ValidWebsite)
//            return
//        }
        if self.imageToUpload != nil {
            self.uploadProfileImage()
        }else {
            HUDManager.sharedInstance.showHUD()
            self.profileUpdate(strURL: UserDAO.sharedInstance.user.userImage)
        }
    }
    
    @IBAction func btnProfileChangeAction(_ sender: UIButton) {
      profilepicUpload()
    }
    
    @IBAction func btnBirthdayAction(_ sender: UIButton) {
        datePickerTapped()
    }
    
    @IBAction func btnAssignProfileStream(_ sender: UIButton) {
        let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
           isAssignProfile = "YES"
        self.navigationController?.push(viewController: obj)
    }
    
    @objc func profilepicUpload() {
        
        let optionMenu = UIAlertController()
        let takePhotoAction = UIAlertAction(title: kAlertSheet_TakePhoto, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.actionForCamera()
            
        })
        
        let selectFromCameraRollAction = UIAlertAction(title: kAlertSheet_SelectFromCameraRoll, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.btnImportAction()
        })
        
        let cancelAction = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(selectFromCameraRollAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
        
    
    }
    @objc func btnCloseAction(){
        self.navigationController?.popViewAsDismiss()
    }
    
    func actionForCamera(){
        let cameraViewController:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        cameraViewController.isDismiss = true
        cameraViewController.delegate = self
        cameraViewController.isForImageOnly = true
        ContentList.sharedInstance.arrayContent.removeAll()
        let nav = UINavigationController(rootViewController: cameraViewController)
        self.present(nav, animated: true, completion: nil)
    }
    
    func btnImportAction(){
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            //     self?.selectedAssets = assets
            if assets.count != 0 {
                self?.prepareCoverImage(asset:assets[0])
            }
            }, didCancel: nil)
        viewController.didExceedMaximumNumberOfSelection = { (picker) in
            //exceed max selection
        }
        viewController.selectedAssets = [TLPHAsset]()
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 1
        configure.muteAudio = true
        configure.usedCameraButton = false
        configure.allowedVideo = false
        configure.usedPrefetch = false
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
    }
    
    func prepareCoverImage(asset:TLPHAsset){
        if let image = asset.fullResolutionImage {
            self.presentCropperWithImage(image: image)
            return
        }
        asset.cloudImageDownload(progressBlock: { (_) in
        }, completionBlock: { (image) in
            if let image = image {
                self.presentCropperWithImage(image: image)
            }
        })
    }
    
    func presentCropperWithImage(image:UIImage){
        let croppingStyle = CropViewCroppingStyle.default
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // your code here
            self.present(cropController, animated: true, completion: nil)
        }
    }

    func datePickerTapped() {
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = -100
        let minDate: Date = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))!
        
        components.year = -10
        let maxDate: Date = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))!
        
        DatePickerDialog().show("Birthday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: maxDate, minimumDate: minDate, maximumDate: maxDate, datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM,dd yyyy"
                 self.txtBirthday.text = formatter.string(from: dt)
            }
        }
      
    }
    
    
    func setCoverImage(image:UIImage) {
        self.imageToUpload = image
        self.imgUser.image = image
        self.fileName =  NSUUID().uuidString + ".png"
    }
    
    
    // MARK: - API
    
    private func uploadProfileImage(){
        HUDManager.sharedInstance.showHUD()
        let image = self.imageToUpload.resizeImage(targetSize: CGSize(width: 200, height: 200))
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
        
        APIServiceManager.sharedInstance.apiForUserProfileUpdate(name: (txtName.text?.trim())!, location: (txtLocation.text?.trim())!, website: (txtWebsite.text?.trim())!, biography: (txtBio.text?.trim())!,birthday: "", profilePic: strURL, displayName: txtDisplayName.text.trim()) { (isSuccess, errorMsg) in
            
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                self.navigationController?.popViewAsDismiss()
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 6 {
            cell.hideSeparator()
        }else {
            cell.showSeparator()
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


extension ProfileUpdateViewController:CustomCameraViewControllerDelegate {
    func dismissWith(image: UIImage?) {
        if let img = image {
            self.setCoverImage(image: img)
        }
    }
}

extension ProfileUpdateViewController:UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
         if textView == txtDisplayName {
            return textView.text.length + (text.length - range.length) <= 40
        }else if textView == txtBio {
        return textView.text.length + (text.length - range.length) <= 160
        }else if textView == txtLocation {
            return textView.text.length + (text.length - range.length) <= 25
        }
        return true
    }
}

extension ProfileUpdateViewController:CropViewControllerDelegate {
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            self.dismiss(animated: true, completion: nil)
            if self.delegate != nil {
                self.dismiss(animated: true, completion: {
                    self.delegate?.dismissWith(image: image)
                })
            }
            self.setCoverImage(image: image)
        }
        
        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            self.dismiss(animated: true, completion: nil)
            if self.delegate != nil {
                
                self.dismiss(animated: true, completion: {
                    //  self.delegate?.dismissWith(image: cropViewController.image)
                })
            }
            
        }
    }

//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if (text == "\n") {
//            if textView == txtBio {
//                txtWebsite.becomeFirstResponder()
//            }else if textView == txtWebsite {
//                txtLocation.becomeFirstResponder()
//            }else  {
//                textView.resignFirstResponder()
//            }
//            return false
//        }
//
//        return true
//    }



