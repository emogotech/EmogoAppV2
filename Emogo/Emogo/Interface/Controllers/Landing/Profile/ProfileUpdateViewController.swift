//
//  ProfileUpdateViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ProfileUpdateViewController: UITableViewController {
    
    @IBOutlet weak var imgUser: NZCircularImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtBio: UITextView!
    @IBOutlet weak var txtWebsite: UITextView!
    @IBOutlet weak var txtLocation: UITextView!
    @IBOutlet weak var txtBirthday: UITextView!


    var imageToUpload:UIImage!
    var fileName:String! = ""
    
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
    
    func prepareLayouts(){
       self.prepareData()
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    
    func prepareData(){
        txtName.text = UserDAO.sharedInstance.user.fullName.trim().capitalized
        txtName.isUserInteractionEnabled = false
        txtBio.text = UserDAO.sharedInstance.user.biography.trim()
        txtWebsite.text = UserDAO.sharedInstance.user.website.trim()
        txtBirthday.text = UserDAO.sharedInstance.user.birthday.trim()
        txtLocation.text = UserDAO.sharedInstance.user.location.trim()
        self.imgUser.image = #imageLiteral(resourceName: "camera_icon_cover_images")
        if !UserDAO.sharedInstance.user.userImage.trim().isEmpty {
            self.imgUser.setImageWithResizeURL(UserDAO.sharedInstance.user.userImage)
        }
        prepreNavigation()
    }
    
    func prepreNavigation(){
       let  myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0, weight: .light)]
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2

        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
        let img = UIImage(named: "profile_close_icon")
        let btnClose = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.btnCloseAction))
        self.navigationItem.leftBarButtonItem = btnClose
        self.title = "Edit Profile"
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
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
    
    @objc func profilepicUpload() {
        
        let cameraViewController:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        cameraViewController.isDismiss = true
        cameraViewController.delegate = self
        cameraViewController.isForImageOnly = true
        ContentList.sharedInstance.arrayContent.removeAll()
        let nav = UINavigationController(rootViewController: cameraViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    @objc func btnCloseAction(){
        self.dismiss(animated: true, completion: nil)
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
                formatter.dateFormat = "MMM dd yyyy"
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
        
        APIServiceManager.sharedInstance.apiForUserProfileUpdate(name: (txtName.text?.trim())!, location: (txtLocation.text?.trim())!, website: (txtWebsite.text?.trim())!, biography: (txtBio.text?.trim())!,birthday: (txtBirthday.text?.trim())!, profilePic: strURL) { (isSuccess, errorMsg) in
            
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                self.dismiss(animated: true, completion: nil)
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
        if textView == txtBio {
        return textView.text.length + (text.length - range.length) <= 160
        }else if textView == txtLocation {
            return textView.text.length + (text.length - range.length) <= 25
        }
        return true
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

}

