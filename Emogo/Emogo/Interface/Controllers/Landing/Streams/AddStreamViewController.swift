//
//  AddStreamViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation
import Lightbox

class AddStreamViewController: UITableViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var txtStreamName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtStreamCaption: UIFloatLabelTextView!
    @IBOutlet weak var switchMakePrivate: PMSwitch!
    @IBOutlet weak var switchAnyOneCanEdit: PMSwitch!
    @IBOutlet weak var switchAddContent: PMSwitch!
    @IBOutlet weak var switchAddPeople: PMSwitch!
    @IBOutlet weak var lblAnyOneCanEdit: UILabel!
    @IBOutlet weak var rowHieght: NSLayoutConstraint!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var switchAddCollaborators: PMSwitch!
    @IBOutlet weak var btnCamera: UIButton!

    
    // Varibales

    var isExpandRow: Bool = false {
        didSet {
            self.configureCollaboatorsRowExpandCollapse()
        }
    }
  
    var coverImage:UIImage!
    var fileName:String! = ""
    var selectedCollaborators = [CollaboratorDAO]()
    var streamType:String! = "Public"
    var streamID:String!
    var objStream:StreamViewDAO?
    var strCoverImage:String! = ""
    var isPerform:Bool! = false
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareLayouts()

    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareLayoutForApper()
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

    // MARK: - Prepare Layouts
    
    private func prepareLayouts(){
        self.title = "Create a Stream"
        self.configureNavigationWithTitle()
        txtStreamName.placeholder = "Stream Name"
        txtStreamName.title = "Stream Name"
        txtStreamCaption.placeholderName = "Stream Caption"
        txtStreamCaption.placeholder = "Stream Caption"
        txtStreamName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtStreamCaption.placeholderTextColor = UIColor(r: 70.0, g: 70.0, b: 70.0)
        txtStreamCaption.delegate = self
        txtStreamCaption.floatLabelActiveColor = UIColor(r: 70.0, g: 70.0, b: 70.0)
        txtStreamCaption.floatLabelPassiveColor = UIColor.darkGray
        self.txtStreamName.maxLength = 50
        self.switchAddContent.isUserInteractionEnabled = false
        self.switchAddPeople.isUserInteractionEnabled = false
        self.imgCover.contentMode = .scaleAspectFill
        if self.streamID != nil {
            self.getStream()
        }else {
            isPerform = true
            self.performSegue(withIdentifier: kSegue_AddCollaboratorsView, sender: self)
            self.tableView.reloadData()
        }
        
        self.imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 1
        self.imgCover.addGestureRecognizer(tap)
    }
    
    
    func prepareLayoutForApper(){
        self.viewGradient.layer.contents = UIImage(named: "strems_name_gradient")?.cgImage
    }

    func prepareForEditStream(){
        if self.objStream != nil {
            
            self.title =  self.objStream?.title.trim()
            txtStreamName.text = self.objStream?.title.trim()
            txtStreamCaption.text = self.objStream?.description.trim()
            if !txtStreamCaption.text.trim().isEmpty {
                txtStreamCaption.placeholderName = ""
            }else{
                txtStreamCaption.placeholderName = ""
            }
            if !(objStream?.coverImage.trim().isEmpty)!  {
                self.imgCover.setImageWithURL(strImage: (objStream?.coverImage)!, placeholder: "add-stream-cover-image-placeholder")
                self.strCoverImage = objStream?.coverImage
            }
//            self.switchAddPeople.isOn = (self.objStream?.canAddPeople)!
//            self.switchAddContent.isOn = (self.objStream?.canAddContent)!
            if self.objStream?.type.lowercased() == "public"{
                self.switchMakePrivate.isOn = false
            }else {
             self.switchMakePrivate.isOn = true
                streamType = "Private"
            }
            self.switchAnyOneCanEdit.isOn = (self.objStream?.anyOneCanEdit)!
            self.selectedCollaborators = (self.objStream?.arrayColab)!
            if self.selectedCollaborators.count != 0 {
                self.rowHieght.constant = 325.0
                self.isExpandRow = true
                self.switchAddCollaborators.isOn = true
            }

            if self.switchAddCollaborators.isOn == false{
                self.switchAddContent.isUserInteractionEnabled = false
                self.switchAddPeople.isUserInteractionEnabled  = false
                self.switchAddPeople.isOn       = false
                self.switchAddContent.isOn      = false
            }else{
                self.switchAddContent.isUserInteractionEnabled = true
                self.switchAddPeople.isUserInteractionEnabled  = true
                self.switchAddPeople.isOn = (self.objStream?.canAddPeople)!
                self.switchAddContent.isOn = (self.objStream?.canAddContent)!
            }

            if self.objStream?.canAddPeople == true {
                self.prepareEdit(isEnable: false)
            }
            if objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
            self.prepareEdit(isEnable: true)
            }
            
            
            isPerform = true
            self.performSegue(withIdentifier: kSegue_AddCollaboratorsView, sender: self)
            self.tableView.reloadData()
        }
    }
    
    func prepareEdit(isEnable:Bool) {
        self.txtStreamName.isUserInteractionEnabled = isEnable
        self.txtStreamCaption.isUserInteractionEnabled = isEnable
        self.btnCamera.isUserInteractionEnabled = isEnable
        switchMakePrivate.isUserInteractionEnabled = isEnable
        switchAnyOneCanEdit.isUserInteractionEnabled = isEnable
        if self.objStream?.canAddContent == true {
            switchAddContent.isUserInteractionEnabled = true
        }else {
            switchAddContent.isUserInteractionEnabled = false
        }
        if self.objStream?.canAddPeople == true {
            switchAddPeople.isUserInteractionEnabled = true
        }else {
            switchAddPeople.isUserInteractionEnabled = false
        }
    }
    
    // MARK: -  Action Methods And Selector
    @IBAction func addContentAction(_ sender: PMSwitch) {
        self.switchAddContent.isOn = sender.isOn
        print(self.switchAddContent.isOn)
    }
    
    @IBAction func addPeopleAction(_ sender: PMSwitch) {
        self.switchAddPeople.isOn = sender.isOn
    }
    
    @IBAction func anyOneCanEditAction(_ sender: PMSwitch) {
        self.switchAnyOneCanEdit.isOn = sender.isOn
    }
    
    @IBAction func makePrivateAction(_ sender: PMSwitch) {
            sender.isOn = !sender.isOn
            if self.switchMakePrivate.isOn {
                streamType = "Private"
                self.switchAnyOneCanEdit.isOn = false
                self.switchAnyOneCanEdit.isUserInteractionEnabled = false
            }else{
                streamType = "Public"
                self.switchAnyOneCanEdit.isUserInteractionEnabled = true
            }
    }
    
    @IBAction func addCollaboatorsAction(_ sender: PMSwitch) {
        if self.switchAddCollaborators.isOn {
            self.switchAddContent.isOn = false
            self.switchAddPeople.isOn = false
            self.switchAddContent.isEnabled = true
            self.switchAddPeople.isEnabled = true
            self.switchAddContent.isUserInteractionEnabled = true
            self.switchAddPeople.isUserInteractionEnabled = true
                self.rowHieght.constant = 325.0
                self.isExpandRow = true
        }else{
            self.switchAddContent.isOn = false
            self.switchAddPeople.isOn = false
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isUserInteractionEnabled = false
            
            self.rowHieght.constant = 0.0
            self.isExpandRow = false
            selectedCollaborators.removeAll()
        }
        self.tableView.reloadData()
    }
    @IBAction func btnActionDone(_ sender: Any) {
        
        self.view.endEditing(true)
        if coverImage == nil && strCoverImage.isEmpty{
            self.showToastOnWindow(strMSG: kAlert_Stream_Cover_Empty)
        }
       else if (self.txtStreamName.text?.trim().isEmpty)! {
            txtStreamName.shake()
        }else if switchAddCollaborators.isOn  && self.selectedCollaborators.count == 0{
            self.showToastOnWindow(strMSG: kAlert_Stream_Colab_Empty)
        }else {
             self.showToastOnWindow(strMSG: kAlert_Upload_Wait_Msg)
            if self.streamID == nil {
                self.uploadCoverImage()
            }else {
                if self.strCoverImage.isEmpty {
                    self.uploadCoverImage()
                }else {
                    self.editStream(cover: self.strCoverImage)
                }
            }
        }
    }
    
    
    @IBAction func btnActionCamera(_ sender: Any) {
        
        let alert = UIAlertController(title: "Upload Picture", message: "", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.checkCameraPermission()
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.checkPhotoLibraryPermission()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
         alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)

    }
    
    @objc func textFieldDidChange(_ textField: SkyFloatingLabelTextField) {
        if (txtStreamName.text?.trim().isEmpty)! {
            txtStreamName.placeholder = "Stream Name"
            txtStreamName.title = nil
        }else {
            txtStreamName.placeholder = nil
            txtStreamName.title = "Stream Name"
        }
    }
    
   
    
    // MARK: - CLASS FUNCTION
    // MARK: - Expand Collapse Row

    func configureCollaboatorsRowExpandCollapse() {
            self.tableView.beginUpdates()
            let index = IndexPath(row: 3, section: 0)
            self.tableView.reloadRows(at: [index], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.reloadData()
    }

    // MARK: - Set Cover Image

    func setCoverImage(image:UIImage) {
        self.coverImage = image
        self.imgCover.image = image
        self.fileName =  NSUUID().uuidString + ".png"
        self.strCoverImage = ""
        self.imgCover.contentMode = .scaleAspectFill
        print(self.fileName)
    }
   
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("Gallery Open")
            self.openGallery()
            break
        //handle authorized status
        case .denied, .restricted :
            print("denied ")
            SharedData.sharedInstance.showPermissionAlert(viewController:self,strMessage: "gallery")
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            print("denied ")
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    self.openGallery()
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
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            print("camera Open")
            self.openCamera()
        } else {
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
        }
    }
    

    
   private func openCamera(){
        if  UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            
        }
    }
    
   private func openGallery(){
        if  UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            
        }
        
    }
    
    @objc func openFullView(){
        var image:LightboxImage!
        if self.coverImage == nil {
            if self.objStream != nil {
                guard  let url = URL(string: (self.objStream?.coverImage.stringByAddingPercentEncodingForURLQueryParameter())!) else
                {
                    return
                }
                
                image = LightboxImage(imageURL: url, text: "", videoURL: nil)
            }
          
        }else {
            image = LightboxImage(image: coverImage)
        }
        if let obj = image {
            let controller = LightboxController(images: [obj], startIndex: 0)
            controller.dynamicBackground = true
            present(controller, animated: true, completion: nil)
        }
    }
    
    
   private func uploadCoverImage(){
        HUDManager.sharedInstance.showHUD()
         let image = self.coverImage.reduceSize()
        let imageData = UIImageJPEGRepresentation(image, 1.0)
       let url = Document.saveFile(data: imageData!, name: self.fileName)
        let fileUrl = URL(fileURLWithPath: url)
        AWSManager.sharedInstance.uploadFile(fileUrl, name: self.fileName) { (imageUrl,error) in
            if error == nil {
                DispatchQueue.main.async {
                    if self.streamID == nil   {
                        self.createStream(cover: imageUrl!)
                    } else {
                        self.editStream(cover: imageUrl!)
                    }
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
   
   
    func selectedCollaborator(colabs:[CollaboratorDAO]){
        print(self.selectedCollaborators)
        self.selectedCollaborators = colabs
    }
    
    // MARK: - API Methods
    
   
    
    func getStream(){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForViewStream(streamID: self.streamID) { (stream, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.objStream = stream
                self.prepareForEditStream()
            }else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
    }
    
    private func createStream(cover:String){
        txtStreamCaption.placeholder = ""
        APIServiceManager.sharedInstance.apiForCreateStream(streamName: self.txtStreamName.text!, streamDescription: self.txtStreamCaption.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: self.switchAnyOneCanEdit.isOn, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.isOn, canAddPeople: self.switchAddPeople.isOn) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToastOnWindow(strMSG: kAlert_Stream_Added_Success)
                DispatchQueue.main.async{
                      self.navigationController?.pop()
                       NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Filter ), object: nil)
                }
            }else {
                self.showToastOnWindow(strMSG: errorMsg!)
            }
        }
    }
    private func editStream(cover:String){
         txtStreamCaption.placeholder = ""
        APIServiceManager.sharedInstance.apiForEditStream(streamID:self.streamID!,streamName: self.txtStreamName.text!, streamDescription: self.txtStreamCaption.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: self.switchAnyOneCanEdit.isOn, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.isOn, canAddPeople: self.switchAddPeople.isOn) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToastOnWindow(strMSG: kAlert_Stream_Edited_Success)
                DispatchQueue.main.async{
                    self.navigationController?.pop()
                     NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Image_Cover), object: nil)
                }
            }else {
                self.showToastOnWindow(strMSG: errorMsg!)
            }
        }
    }
    
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == kSegue_AddCollaboratorsView) {
            let childViewController = segue.destination as! AddCollaboratorsViewController
            if self.objStream != nil {
                childViewController.arraySelected = self.objStream?.arrayColab
            }
            // Now you have a pointer to the child view controller.
            // You can save the reference to it, or pass data to it.
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return isPerform
    }

}



// MARK: - EXTENSION

// MARK: - DataSource And Delegate

extension AddStreamViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isExpandRow  && indexPath.row == 3{
            return 340.0
        }else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}


extension AddStreamViewController:UITextViewDelegate,UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtStreamName {
            txtStreamCaption.becomeFirstResponder()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        txtStreamCaption.placeholderName = "Stream Caption"
        if let placeholderLabel = txtStreamCaption.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = txtStreamCaption.text.count > 0
        }
    }
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if txtStreamCaption.text.trim() == "Stream Caption"{
//            txtStreamCaption.text = nil
//        }
//    }

    func textViewDidEndEditing(_ textView: UITextView) {
       if txtStreamCaption.text.isEmpty {
            txtStreamCaption.placeholder = ""
        }
    }
   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      
        if(text == "\n") {
           txtStreamCaption.resignFirstResponder()
            return false
        }
        
        return textView.text.length + (text.length - range.length) <= 250

    }
}

extension AddStreamViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   
    
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
