//
//  EditStreamController.swift
//  Emogo
//
//  Created by Northout on 14/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation
import Lightbox
import Contacts
import CropViewController

class EditStreamController: UITableViewController {
    
    //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎

    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var tfDescription: MBAutoGrowingTextView!
    @IBOutlet weak var tfEmogoTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var btnChangeCover: UIButton!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var btnAddCollab: UIButton!
    @IBOutlet weak var viewTitle: UIView!
    
    @IBOutlet weak var switchEmogoPrivate: UISwitch!
    @IBOutlet weak var switchAddContent: UISwitch!
    @IBOutlet weak var switchMakeEmogoGlobal:  UISwitch!
    @IBOutlet weak var switchAddPeople:  UISwitch!

    var delegate:CustomCameraViewControllerDelegate?
    var coverImage:UIImage!
    var fileName:String! = ""
    var selectedCollaborators = [CollaboratorDAO]()
    var streamType:String! = "Public"
    var streamID:String!
    var objStream:StreamViewDAO?
    var strCoverImage:String! = ""
    var isAddContent:Bool!
    var minimumSize: CGSize = CGSize.zero
    var isfromProfile:String?
    var contentRowHeight : CGFloat = 30.0
    var objNavigationController:PMNavigationController?
    
    
    //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareLayouts()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationTite(color:UIColor.white)
        prepareNavigationbarButtons()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // prepareSwitches()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: ⬇︎⬇︎⬇︎ Prepare Layouts ⬇︎⬇︎⬇︎

    
    private func prepareLayouts(){
        tfEmogoTitle.delegate = self
        tfEmogoTitle.placeholder = nil
        tfEmogoTitle.title = nil
        tfDescription.placeholder = "Caption (Optional)"
        tfDescription.placeholderColor = UIColor(r: 150, g: 150, b: 150)
        tfEmogoTitle.selectedLineColor = .clear
        self.lblCaption.text = ""
        self.lblCaption.font = UIFont.systemFont(ofSize: 13)
        self.lblCaption.isHidden = true
        self.tableView.tableFooterView = UIView()
        
        tfEmogoTitle.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.tfEmogoTitle.maxLength = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        self.imgCover.contentMode = .scaleAspectFill
        if self.streamID != nil {
            self.getStream()
        }
        self.imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 1
        self.imgCover.addGestureRecognizer(tap)
      
    }
    
    
    func prepareNavigationbarButtons(){
        let button   = UIButton(type: .system)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.frame = CGRect(x: 10, y: -12, width: 60, height: 40)
     
        button.addTarget(self, action: #selector(self.btnCancelAction(_:)), for: .touchUpInside)
        let btnBack = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = btnBack
        
         let buttonDone  = UIButton(type: .system)
        buttonDone.setTitle("Done", for: .normal)
       
        buttonDone.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
       // buttonDone.setTitleColor(UIColor.lightGray, for: .normal)
        // buttonDone.setTitleColor(kNavigationColor, for: .normal)
        buttonDone.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        buttonDone.addTarget(self, action: #selector(self.btnDoneAction(_:)), for: .touchUpInside)
        let btnDone = UIBarButtonItem(customView: buttonDone)
        self.navigationItem.rightBarButtonItem = btnDone
        self.title = "Edit Emogo"
        

    }
    
    
    
    func prepareForEditStream(){
        if self.objStream != nil {
            self.title =  self.objStream?.title.trim()
            tfEmogoTitle.text = self.objStream?.title.trim()
            tfDescription.text = self.objStream?.description.trim()
            if !(objStream?.coverImage.trim().isEmpty)!  {
                self.imgCover.setImageWithURL(strImage: (objStream?.coverImage)!, handler: { (image, _) in
                    
                    self.imgCover.backgroundColor = image?.getColors().background
                })
                self.imgCover.setImageWithURL(strImage: (objStream?.coverImage)!, placeholder: "add-stream-cover-image-placeholder")
                self.strCoverImage = objStream?.coverImage
            }
            
            self.switchMakeEmogoGlobal.isOn = (self.objStream?.anyOneCanEdit)!
            
            if self.objStream?.type.lowercased() == "public"{
                self.switchEmogoPrivate.isOn = false
                self.switchEmogoPrivate.thumbTintColor =  UIColor.lightGray
                self.switchMakeEmogoGlobal.thumbTintColor = UIColor.lightGray
                
                streamType = "Public"
                
            }else {
                self.switchEmogoPrivate.isOn = true
                self.switchEmogoPrivate.thumbTintColor =  UIColor.white
                self.switchMakeEmogoGlobal.thumbTintColor = UIColor.lightGray
                
                streamType = "Private"
                
            }
            
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isUserInteractionEnabled  = false
            self.switchAddPeople.isOn       = false
            self.switchAddContent.isOn      = false
            self.switchAddPeople.thumbTintColor = UIColor.lightGray
            self.switchAddContent.thumbTintColor = UIColor.lightGray
            if objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                
                self.selectedCollaborators = (self.objStream?.arrayColab)!
                
                if self.selectedCollaborators.count != 0 {
                    self.switchAddContent.isUserInteractionEnabled = true
                    self.switchAddPeople.isUserInteractionEnabled  = true
                    self.switchAddPeople.thumbTintColor = UIColor.lightGray
                    self.switchAddContent.thumbTintColor = UIColor.lightGray
                }
            }else {
                self.switchEmogoPrivate.isUserInteractionEnabled = false
                self.switchMakeEmogoGlobal.isUserInteractionEnabled = false
                self.btnChangeCover.isHidden = true
                self.tfEmogoTitle.isUserInteractionEnabled = false
                self.tfDescription.isUserInteractionEnabled = false
                self.selectedCollaborators = (self.objStream?.arrayColab)!
                if self.selectedCollaborators.count != 0 {
                    self.switchAddPeople.isUserInteractionEnabled = (self.objStream?.userCanAddPeople)!
                    self.switchAddContent.isUserInteractionEnabled = (self.objStream?.userCanAddContent)!
                }
                self.btnAddCollab.isUserInteractionEnabled = (self.objStream?.canAddPeople)!
                
            }
            
            
        }
        
        if self.tfDescription.text.count > 0 {
            self.lblCaption.isHidden = false
        }else{
            self.lblCaption.isHidden = true
        }
        
        if self.tfDescription.contentSize.height > contentRowHeight {
            contentRowHeight = self.tfDescription.contentSize.height
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        self.switchAddPeople.isOn = (self.objStream?.userCanAddPeople)!
        self.switchAddContent.isOn = (self.objStream?.userCanAddContent)!
        
        if self.switchAddPeople.isOn == true {
            self.switchAddPeople.thumbTintColor =  UIColor.white
        }else{
            self.switchAddPeople.thumbTintColor =  UIColor.lightGray
        }
        
        if self.switchAddContent.isOn == true {
            self.switchAddContent.thumbTintColor =  UIColor.white
        }else{
            self.switchAddPeople.thumbTintColor =  UIColor.lightGray
        }
        
        if (self.objStream?.anyOneCanEdit)! {
            self.btnAddCollab.isUserInteractionEnabled = false
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isUserInteractionEnabled = false
            self.switchAddPeople.isOn = false
            self.switchAddContent.isOn = false
            self.switchMakeEmogoGlobal.thumbTintColor =  UIColor.white
        }
        self.tableView.reloadData()
    }
    
    func prepareEdit(isEnable:Bool) {
        self.tfEmogoTitle.isUserInteractionEnabled = isEnable
        self.tfDescription.isUserInteractionEnabled = isEnable
        self.btnChangeCover.isUserInteractionEnabled = isEnable
        self.switchMakeEmogoGlobal.isUserInteractionEnabled = isEnable
        switchEmogoPrivate.isUserInteractionEnabled = isEnable
        
    }
    func configureCollaboatorsRowExpandCollapse() {
        self.reloadIndex(index: 3)
    }
    
    func reloadIndex(index:Int) {
        self.tableView.beginUpdates()
        let index = IndexPath(row: index, section: 0)
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
        self.imgCover.contentMode = .scaleAspectFit
        self.imgCover.backgroundColor = image.getColors().background
        self.tfEmogoTitle.becomeFirstResponder()
        print(self.fileName)
    }
    
    
    //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎

    
    @IBAction func switchActionEmogoPrivate(_ sender: UISwitch) {
        if self.switchEmogoPrivate.isOn {
            streamType = "Private"
            self.switchMakeEmogoGlobal.isOn = false
            self.switchMakeEmogoGlobal.thumbTintColor = UIColor.lightGray
            self.switchEmogoPrivate.thumbTintColor = UIColor.white

        }else {
            streamType = "Public"
            self.switchMakeEmogoGlobal.isOn = false
            self.switchMakeEmogoGlobal.thumbTintColor = UIColor.lightGray
            self.switchEmogoPrivate.thumbTintColor = UIColor.lightGray
        }
    }
    
    @IBAction func switchActionAddContent(_ sender: UISwitch) {
        if self.switchAddContent.isOn {
                print("102 on")
               self.switchAddContent.thumbTintColor = UIColor.white
        }else {
                print("102 off")
               self.switchAddContent.thumbTintColor = UIColor.lightGray
        }
    }
    
    @IBAction func switchActionAddPeople(_ sender: UISwitch) {
        if self.switchAddPeople.isOn {
             print("103 on")
             self.switchAddPeople.thumbTintColor = UIColor.white
        }else {
             print("103 off")
            self.switchAddPeople.thumbTintColor = UIColor.lightGray
        }
    }
    
    
    
    @IBAction func switchActionEmogoGlobal(_ sender: UISwitch) {
        if self.switchMakeEmogoGlobal.isOn {
            self.switchAddContent.isOn = false
            self.switchAddContent.thumbTintColor = UIColor.lightGray
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isOn = false
            self.switchAddPeople.isUserInteractionEnabled = false
            self.switchAddPeople.thumbTintColor = UIColor.lightGray
            self.switchMakeEmogoGlobal.thumbTintColor = UIColor.white
            if switchEmogoPrivate.isOn == true {
                self.switchEmogoPrivate.isOn = false
                 self.switchMakeEmogoGlobal.thumbTintColor = UIColor.white
                self.streamType = "Public"
            }
            self.switchEmogoPrivate.thumbTintColor = UIColor.lightGray
            self.btnAddCollab.isUserInteractionEnabled = false
        }else {
            self.switchAddContent.isOn = false
            self.switchAddContent.thumbTintColor = UIColor.lightGray
            self.switchAddPeople.isOn = false
            self.switchAddPeople.thumbTintColor = UIColor.lightGray
            if self.objStream?.arrayColab.count == 0 {
                self.switchAddPeople.isUserInteractionEnabled = false
                self.switchAddContent.isUserInteractionEnabled = false
            }else {
                self.switchAddPeople.isUserInteractionEnabled = true
                self.switchAddContent.isUserInteractionEnabled = true
            }
            self.switchMakeEmogoGlobal.thumbTintColor = UIColor.lightGray
            self.btnAddCollab.isUserInteractionEnabled = true
        }
       
    }
   
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.view.endEditing(true)
        if coverImage == nil && strCoverImage.isEmpty{
            self.showToastOnWindow(strMSG: kAlert_Stream_Cover_Empty)
        }
        else if (self.tfEmogoTitle.text?.trim().isEmpty)! {
            tfEmogoTitle.shake()
            self.showToastOnWindow(strMSG: kAlert_Stream_Title_Empty)
        }else {
            self.showToastOnWindow(strMSG: kAlert_Upload_Wait_Msg)
            if self.streamID == nil {
                self.uploadCoverImage()
            }else {
                if self.strCoverImage.isEmpty {
                    self.uploadCoverImage()
                }else {
                    
                    self.editStream(cover: self.strCoverImage,width:(self.objStream?.width)!,hieght:(self.objStream?.hieght)!,color:(self.objStream?.color)!)
                }
            }
        }
    }
    @IBAction func btnCancelAction(_ sender: Any) {
    NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Image_Cover), object: nil)

        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnActionAddCollab(_ sender: Any) {
        
        let actionVC : AddCollabViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_AddCollabView) as! AddCollabViewController
        actionVC.delegate = self
        actionVC.strEdit = "EDIT"
        actionVC.arraySelected = self.selectedCollaborators
        actionVC.currentStream = self.objStream
        actionVC.objNavigationController = self.navigationController as? PMNavigationController
        let nav = UINavigationController(rootViewController: actionVC)
        customPresentViewController(PresenterNew.AddCollabPresenter, viewController: nav, animated: true, completion: nil)
        
       
        
    }
   
    @IBAction func btnChangeCover(_ sender: Any) {
        actionForUploadCover()
    }

    @objc func openFullView(){
        var image:LightboxImage!
        let text = (tfEmogoTitle.text?.trim())! + "\n" +  tfDescription.text.trim()
        
        if self.coverImage == nil {
            if self.objStream != nil {
                guard  let url = URL(string: (self.objStream?.coverImage.stringByAddingPercentEncodingForURLQueryParameter())!) else
                {
                    return
                }
                image = LightboxImage(imageURL: url, text: text, videoURL: nil)
            }
            
        }else {
            image = LightboxImage(image: coverImage,text:text.trim())
        }
        if let obj = image {
            let controller = LightboxController(images: [obj], startIndex: 0)
            controller.dynamicBackground = true
            present(controller, animated: true, completion: nil)
        }
    }
    
    
    @objc func textFieldDidChange(_ textField: SkyFloatingLabelTextField) {
        if (tfEmogoTitle.text?.trim().isEmpty)! {
            tfEmogoTitle.placeholder = "Emogo Title"
            tfEmogoTitle.title = nil
        }else {
            tfEmogoTitle.placeholder = nil
            tfEmogoTitle.title = "Emogo Title"
        }
    }
    
    func actionForUploadCover(){
        
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
    
    //MARK: ⬇︎⬇︎⬇︎Other Methods ⬇︎⬇︎⬇︎

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
        configure.muteAudio = false
        configure.usedCameraButton = false
        configure.allowedVideo = false
        configure.usedPrefetch = false
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
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
  
    //MARK: ⬇︎⬇︎⬇︎ API Methods ⬇︎⬇︎⬇︎

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
  
    
    private func uploadCoverImage(){
        HUDManager.sharedInstance.showHUD()
        let image = self.coverImage
        let imageData = UIImageJPEGRepresentation(image!, 1.0)
        let url = Document.saveFile(data: imageData!, name: self.fileName)
        let fileUrl = URL(fileURLWithPath: url)
        AWSManager.sharedInstance.uploadFile(fileUrl, name: self.fileName) { (imageUrl,error) in
            if error == nil {
                DispatchQueue.main.async {
                    if self.streamID != nil   {
                        self.editStream(cover: imageUrl!,width:Int(image!.size.width) ,hieght:Int(image!.size.height),color: (image?.getColors().primary.toHexString)! )
                    }else {
                        HUDManager.sharedInstance.hideHUD()
                    }
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
    
    private func editStream(cover:String,width:Int,hieght:Int,color:String){
        
        APIServiceManager.sharedInstance.apiForEditStream(streamID:self.streamID!,streamName: self.tfEmogoTitle.text!, streamDescription: self.tfDescription.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: self.switchMakeEmogoGlobal.isOn, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.isOn, canAddPeople: self.switchAddPeople.isOn,height:hieght,width:width,color:color) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToastOnWindow(strMSG: kAlert_Stream_Edited_Success)
                DispatchQueue.main.async{
                    self.dismiss(animated: true, completion: nil)
                    if self.isfromProfile != nil && self.isfromProfile == "fromProfile" {
                        NotificationCenter.default.post(name: NSNotification.Name(kProfileUpdateIdentifier ), object: nil)
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Image_Cover), object: nil)

                }
            }else {
                self.showToastOnWindow(strMSG: errorMsg!)
            }
        }
    }
    
}


//MARK: ⬇︎⬇︎⬇︎ EXTENSION ⬇︎⬇︎⬇︎


//MARK: ⬇︎⬇︎⬇︎ Delegate And Datasource ⬇︎⬇︎⬇︎



extension EditStreamController: CustomCameraViewControllerDelegate {
    func dismissWith(image: UIImage?) {
        if let img = image {
            self.setCoverImage(image: img)
        }
    }
    
}

extension EditStreamController: CropViewControllerDelegate {
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

extension EditStreamController :UITextViewDelegate, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == tfEmogoTitle {
            tfEmogoTitle.resignFirstResponder()
            tfDescription.becomeFirstResponder()
        }else{
             textField.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.lblCaption.isHidden = textView.text.isEmpty
        
        if self.tfDescription.contentSize.height > contentRowHeight {
            contentRowHeight = self.tfDescription.contentSize.height
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            tfDescription.resignFirstResponder()
            return false
        }
        return textView.text.length + (text.length - range.length) <= 250
    }
}
extension EditStreamController {
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return contentRowHeight  + 30
        }else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}


extension EditStreamController :AddCollabViewControllerDelegate{
    
    func dismissSuperView(objPeople: PeopleDAO?) {
        self.dismiss(animated: false) {
            if objPeople == nil {
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.objNavigationController?.popToViewController(vc: obj)
            }else {
                let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
                obj.objPeople = objPeople
                self.objNavigationController?.popToViewController(vc: obj)
            }
        }
    }
    

    func selectedColabs(arrayColab: [CollaboratorDAO]) {
        self.selectedCollaborators = arrayColab
        self.switchAddPeople.isUserInteractionEnabled = true
        self.switchAddContent.isUserInteractionEnabled = true
    }
  
}
