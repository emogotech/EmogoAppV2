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
import XLActionController
import CropViewController

class EditStreamController: UITableViewController {
    
    //MARK:- IBOutlet Connections
    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var tfDescription: MBAutoGrowingTextView!
    @IBOutlet weak var tfEmogoTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var switchAddPeople: PMAnimatedSwitch!
    @IBOutlet weak var btnChangeCover: UIButton!
    @IBOutlet weak var switchEmogoPrivate: PMAnimatedSwitch!
    @IBOutlet weak var switchAddContent: PMAnimatedSwitch!
    @IBOutlet weak var switchMakeEmogoGlobal: PMAnimatedSwitch!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var btnAddCollab: UIButton!
    @IBOutlet weak var viewTitle: UIView!

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
        prepareSwitches()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Prepare Layouts
    
    private func prepareLayouts(){
        tfEmogoTitle.delegate = self
        tfEmogoTitle.placeholder = nil
        tfEmogoTitle.title = nil
        tfDescription.placeholder = "CAPTION(OPTIONAL)"
        tfDescription.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
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
        
        let btnBack = UIBarButtonItem(title: "CANCEL", style: .plain, target: self, action: #selector(self.btnCancelAction(_:)))
        btnBack.tintColor = UIColor.lightGray
        self.navigationItem.leftBarButtonItem = btnBack
        
        let btnDone = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(self.btnDoneAction(_:)))
        self.navigationItem.rightBarButtonItem = btnDone
        self.title = "Edit Emogo"
    }
    
    
    func prepareSwitches(){
        switchEmogoPrivate.tag = 101
        switchEmogoPrivate.delegate = self
        switchEmogoPrivate.setImages(onImage: #imageLiteral(resourceName: "lockSwitch"), offImage: #imageLiteral(resourceName: "unlockSwitch"))
        switchEmogoPrivate.layer.borderWidth = 1.0
        switchEmogoPrivate.layer.borderColor = UIColor.black.cgColor
        
        switchAddContent.tag = 102
        switchAddContent.delegate = self
        switchAddContent.isRoundButton = true
        switchAddContent.layer.borderWidth = 1.0
        switchAddContent.layer.borderColor = UIColor.black.cgColor
        
        
        switchAddPeople.tag = 103
        switchAddPeople.delegate = self
        switchAddPeople.isRoundButton = true
        switchAddPeople.layer.borderWidth = 1.0
        switchAddPeople.layer.borderColor = UIColor.black.cgColor
        
        
        switchMakeEmogoGlobal.tag = 104
        switchMakeEmogoGlobal.delegate = self
        switchMakeEmogoGlobal.isRoundButton = true
        switchMakeEmogoGlobal.layer.borderWidth = 1.0
        switchMakeEmogoGlobal.layer.borderColor = UIColor.black.cgColor
        self.viewTitle.layer.contents = UIImage(named: "gradient")?.cgImage

    }
    //MARK:- Action For Buttons
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
                    self.editStream(cover: self.strCoverImage,width:(self.objStream?.width)!,hieght:(self.objStream?.hieght)! )
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
        actionVC.arraySelected = self.selectedCollaborators
        actionVC.objStream = self.objStream
        let nav = UINavigationController(rootViewController: actionVC)
        customPresentViewController(PresenterNew.AddCollabPresenter, viewController: nav, animated: true, completion: nil)
        
    }
   
    @IBAction func btnChangeCover(_ sender: Any) {
        actionForUploadCover()
    }

    func prepareForEditStream(){
        if self.objStream != nil {
            self.title =  self.objStream?.title.trim()
            tfEmogoTitle.text = self.objStream?.title.trim()
            tfDescription.text = self.objStream?.description.trim()
            if !(objStream?.coverImage.trim().isEmpty)!  {
                self.imgCover.setImageWithURL(strImage: (objStream?.coverImage)!, handler: { (image, _) in
                    // self.imgCover.image = image
                    self.imgCover.backgroundColor = image?.getColors().background
                })
                self.imgCover.setImageWithURL(strImage: (objStream?.coverImage)!, placeholder: "add-stream-cover-image-placeholder")
                self.strCoverImage = objStream?.coverImage
            }
           
            
            self.switchMakeEmogoGlobal.on = (self.objStream?.anyOneCanEdit)!
            
            if self.objStream?.type.lowercased() == "public"{
                self.switchEmogoPrivate.on = false
                self.switchEmogoPrivate.animationSwitcherButton()
                streamType = "Public"

            }else {
                self.switchEmogoPrivate.on = true
                streamType = "Private"
                self.switchEmogoPrivate.animationSwitcherButton()
            }
            
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isUserInteractionEnabled  = false
            self.switchAddPeople.on       = false
            self.switchAddContent.on      = false
            self.switchAddPeople.animationSwitcherButton()
            self.switchAddContent.animationSwitcherButton()
            
            if objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                
                self.selectedCollaborators = (self.objStream?.arrayColab)!
                
                if self.selectedCollaborators.count != 0 {
                    self.switchAddContent.isUserInteractionEnabled = true
                    self.switchAddPeople.isUserInteractionEnabled  = true
                }
            }else {
                self.switchEmogoPrivate.isUserInteractionEnabled = false
                self.switchEmogoPrivate.isUserInteractionEnabled = false
                self.btnChangeCover.isHidden = true
                self.tfEmogoTitle.isUserInteractionEnabled = false
                self.tfDescription.isUserInteractionEnabled = false
                self.selectedCollaborators = (self.objStream?.arrayColab)!
                if self.selectedCollaborators.count != 0 {
                    self.switchAddPeople.isUserInteractionEnabled = (self.objStream?.userCanAddPeople)!
                    self.switchAddContent.isUserInteractionEnabled = (self.objStream?.userCanAddContent)!
                }
                self.btnAddCollab.isUserInteractionEnabled = (self.objStream?.userCanAddPeople)!

            }
            
             /*
            // If Editor is Creator
            if objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                self.prepareEdit(isEnable: true)
                
                if self.switchMakeEmogoGlobal.on == true {
                    
                    self.switchAddContent.isUserInteractionEnabled = false
                    self.switchAddPeople.isUserInteractionEnabled  = false
                    self.switchAddPeople.on       = false
                    self.switchAddContent.on      = false
                }else {
                    
                    
                    //   self.switchAddCollaborators.isUserInteractionEnabled = true
                    self.switchMakeEmogoGlobal.isUserInteractionEnabled = false
                    self.switchMakeEmogoGlobal.on = false
                    if !self.switchEmogoPrivate.on {
                        self.switchMakeEmogoGlobal.isUserInteractionEnabled = true
                    }
                    self.selectedCollaborators = (self.objStream?.arrayColab)!
                    if self.selectedCollaborators.count != 0 {
                        
                    }
                    
                }
                
            }else {
                // Colab is Logged in as Editor
                self.prepareEdit(isEnable: false)
                //  self.switchAddCollaborators.isUserInteractionEnabled = true
                if self.switchAddPeople.on == true {
                    self.switchAddPeople.isUserInteractionEnabled  = true
                }else {
                    self.switchAddPeople.isUserInteractionEnabled  = false
                }
                
                if self.switchAddContent.on == true {
                    self.switchAddContent.isUserInteractionEnabled  = true
                }else {
                    self.switchAddContent.isUserInteractionEnabled  = false
                }
                if self.selectedCollaborators.count != 0 {
                    
                }
                
            }
             */
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
        self.switchAddPeople.on = (self.objStream?.userCanAddPeople)!
        self.switchAddContent.on = (self.objStream?.userCanAddContent)!
        self.switchAddPeople.animationSwitcherButton()
        self.switchAddContent.animationSwitcherButton()

        if (self.objStream?.anyOneCanEdit)! {
            self.btnAddCollab.isUserInteractionEnabled = false
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isUserInteractionEnabled = false
            self.switchAddPeople.on = false
            self.switchAddContent.on = false
            self.switchAddPeople.animationSwitcherButton()
            self.switchAddContent.animationSwitcherButton()
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
        print(self.fileName)
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
    
    
    private func uploadCoverImage(){
        HUDManager.sharedInstance.showHUD()
        let image = self.coverImage
        let imageData = UIImageJPEGRepresentation(image!, 1.0)
        let url = Document.saveFile(data: imageData!, name: self.fileName)
        let fileUrl = URL(fileURLWithPath: url)
        AWSManager.sharedInstance.uploadFile(fileUrl, name: self.fileName) { (imageUrl,error) in
            if error == nil {
                DispatchQueue.main.async {
                    if self.streamID == nil   {
                        self.editStream(cover: imageUrl!,width:Int(image!.size.width) ,hieght:Int(image!.size.height))
                    }
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
    private func editStream(cover:String,width:Int,hieght:Int){
        APIServiceManager.sharedInstance.apiForEditStream(streamID:self.streamID!,streamName: self.tfEmogoTitle.text!, streamDescription: self.tfDescription.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: self.switchMakeEmogoGlobal.on, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.on, canAddPeople: self.switchAddPeople.on,height:hieght,width:width) { (isSuccess, errorMsg) in
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
    
   
    func actionForUploadCover(){
        
        //        let optionMenu = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
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
    
    @objc func textFieldDidChange(_ textField: SkyFloatingLabelTextField) {
        if (tfEmogoTitle.text?.trim().isEmpty)! {
            tfEmogoTitle.placeholder = "Emogo Title"
            tfEmogoTitle.title = nil
        }else {
            tfEmogoTitle.placeholder = nil
            tfEmogoTitle.title = "Emogo Title"
        }
    }
}
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
        if textField == tfDescription {
            tfDescription.becomeFirstResponder()
        }else{
            tfEmogoTitle.becomeFirstResponder()
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
        if indexPath.row == 1 {
            return contentRowHeight  + 30
        }else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
extension EditStreamController :PMSwitcherChangeValueDelegate{
    func switcherDidChangeValue(switcher: PMAnimatedSwitch, value: Bool) {
        
        switch switcher.tag {
        case 101:
            if value {
                streamType = "Private"
                self.switchMakeEmogoGlobal.on = false
              //  self.switchAddPeople.on = false
                // self.switchAddPeople.isUserInteractionEnabled = false
                //self.switchAddContent.on = false
                //self.switchAddContent.isUserInteractionEnabled = false
                //self.switchAddPeople.animationSwitcherButton()
                //self.switchAddContent.animationSwitcherButton()
                self.switchMakeEmogoGlobal.animationSwitcherButton()

            }else{
                streamType = "Public"
                self.switchMakeEmogoGlobal.on = false
             //   self.switchAddPeople.isUserInteractionEnabled = false
               // self.switchAddContent.isUserInteractionEnabled = false
                //self.switchAddPeople.on = false
                //self.switchAddContent.on = false
                //self.switchAddPeople.animationSwitcherButton()
                //self.switchAddContent.animationSwitcherButton()
                self.switchMakeEmogoGlobal.animationSwitcherButton()
                
            }
            break
        case 102:
            if value {
                print("102 on")
            }else {
                print("102 off")
            }
            break
        case 103:
            if value {
                print("103 on")
            }else {
                print("103 off")
            }
            break
        case 104:
            if value {
                self.switchAddContent.on = false
                self.switchAddContent.isUserInteractionEnabled = false
                self.switchAddPeople.on = false
                self.switchAddPeople.isUserInteractionEnabled = false
                if switchEmogoPrivate.on == true {
                    self.switchEmogoPrivate.on = false
                    self.switchEmogoPrivate.animationSwitcherButton()
                    self.streamType = "Public"
                }
                self.switchAddContent.animationSwitcherButton()
                self.switchAddPeople.animationSwitcherButton()
                self.btnAddCollab.isUserInteractionEnabled = false
            }else {
                self.switchAddContent.on = false
                self.switchAddContent.isUserInteractionEnabled = false
                self.switchAddPeople.on = false
                self.switchAddPeople.isUserInteractionEnabled = false
                self.btnAddCollab.isUserInteractionEnabled = true
            }
            
            break
            
        default:
            break
        }
        
        
    }
    
    
}

extension EditStreamController :AddCollabViewControllerDelegate{
    func selectedColabs(arrayColab: [CollaboratorDAO]) {
        self.selectedCollaborators = arrayColab
        self.switchAddPeople.isUserInteractionEnabled = true
        self.switchAddContent.isUserInteractionEnabled = true
    }
}
