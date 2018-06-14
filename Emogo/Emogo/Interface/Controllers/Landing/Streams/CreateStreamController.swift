//
//  CreateStreamController.swift
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

class CreateStreamController: UITableViewController {
    
    
    //MARK:- IBOutlet Connections
    
    @IBOutlet weak var btnAddCoverImage: UIButton!
    @IBOutlet weak var tfEmogoTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDescription: MBAutoGrowingTextView!
    @IBOutlet weak var switchForEmogoPrivate: PMSwitch!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var lblAddCoverImage: UILabel!
    
    var delegate:CustomCameraViewControllerDelegate?
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
    var isAddContent:Bool!
    var minimumSize: CGSize = CGSize.zero
    
    var contentRowHeight : CGFloat = 30.0
    
    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: false, allowResizing: false, allowMoving: false, minimumSize: minimumSize)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfEmogoTitle.becomeFirstResponder()
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked) )
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        tfEmogoTitle.inputAccessoryView = keyboardToolBar
        tfDescription.inputAccessoryView = keyboardToolBar
        self.prepareLayouts()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
   
    
    // MARK: - Prepare Layouts
    
    private func prepareLayouts(){
       
        tfEmogoTitle.placeholder = "Emogo Title"
        tfEmogoTitle.title = "Emogo Title"
        tfDescription.placeholder = "Caption(Optional)"
        tfDescription.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        tfEmogoTitle.selectedLineColor = .clear
        self.lblCaption.text = "Caption(Optional)"
        self.lblCaption.font = UIFont.systemFont(ofSize: 13)
        if self.tfDescription.text.count > 0 {
            self.lblCaption.isHidden = false
        }else{
            self.lblCaption.isHidden = true
        }
        self.tableView.tableFooterView = UIView()
        self.switchForEmogoPrivate.offImage = UIImage(named: "unlockSwitch")
        tfEmogoTitle.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.tfEmogoTitle.maxLength = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        self.imgCover.contentMode = .scaleAspectFill
        if self.streamID != nil {
            //self.getStream()
        }else {
            isPerform = true
//           self.performSegue(withIdentifier: kSegue_AddCollaboratorsView, sender: self)
//            self.tableView.reloadData()
        }
        self.imgCover.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 1
        self.imgCover.addGestureRecognizer(tap)
        // If Stream is public
        //self.rowHieght.constant = 0.0
        self.isExpandRow = false
        
   
    }
    //MARK:- action for buttons
    
    @IBAction func btnActionForAddCoverImage(_ sender: Any) {
        self.actionForUploadCover()
    }
    @IBAction func switchActionForEmogoPrivate(_ sender: PMSwitch) {
        sender.isOn = !sender.isOn
        if self.switchForEmogoPrivate.isOn {
            self.switchForEmogoPrivate.onImage = UIImage(named: "lockSwitch")
            streamType = "Private"
        }
    }
    
    func configureCollaboatorsRowExpandCollapse() {
        self.reloadIndex(index: 2)
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
        self.btnAddCoverImage.isHidden = true
        self.lblAddCoverImage.isHidden = true
        
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
                        self.createStream(cover: imageUrl!,width:Int(image!.size.width) ,hieght:Int(image!.size.height))
                    }
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
    private func createStream(cover:String,width:Int,hieght:Int){
        
        APIServiceManager.sharedInstance.apiForCreateStream(streamName: self.tfEmogoTitle.text!, streamDescription: self.tfDescription.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: false, collaborator: self.selectedCollaborators, canAddContent: false , canAddPeople: false ,height:hieght,width:width) { (isSuccess, errorMsg,stream) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToastOnWindow(strMSG: kAlert_Stream_Added_Success)
                DispatchQueue.main.async{
                    currentStreamType = StreamType.myStream
                    StreamList.sharedInstance.arrayStream.insert(stream!, at: 0)
                    NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Filter ), object: nil)
                    if isAssignProfile != nil {
                        self.assignProfileStream(streamID: (stream?.ID)!)
                    }else {
                        if self.isAddContent != nil {
                            self.associateContentToStream(id: (stream?.ID)!)
                        }else {
                            let array = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                            StreamList.sharedInstance.arrayViewStream = array
                            let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                            obj.currentIndex = 0
                            obj.isFromCreateStream = "TRUE"
                            obj.streamType = currentStreamType.rawValue
                            ContentList.sharedInstance.objStream = nil
                            self.navigationController?.popToViewController(vc: obj)
                        }
                        
                        
                        
                        // self.navigationController?.popNormal()
                        
                        //                        if kNavForProfile.isEmpty {
                        //                            self.navigationController?.popNormal()
                        //                        }else {
                        //                            let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView)
                        //                            self.navigationController?.popToViewController(vc: obj)
                        //                        }
                    }
                }
            }else {
                self.showToastOnWindow(strMSG: errorMsg!)
            }
        }
    }
    
    func assignProfileStream(streamID:String){
        
        APIServiceManager.sharedInstance.apiForAssignProfileStream(streamID: streamID) { (isUpdated, errorMSG) in
            if (errorMSG?.isEmpty)! {
                self.showToast(strMSG: kAlert_ProfileStreamAdded)
                isAssignProfile = nil
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.navigationController?.popToViewController(vc: obj)
            }else {
                self.showToast(strMSG: errorMSG!)
            }
        }
    }
    func associateContentToStream(id:String){
        if  ContentList.sharedInstance.arrayToCreate.count != 0 {
            HUDManager.sharedInstance.showProgress()
            let array = ContentList.sharedInstance.arrayToCreate
            AWSRequestManager.sharedInstance.associateContentToStream(streamID: [id], contents: array!, completion: { (isScuccess, errorMSG) in
                HUDManager.sharedInstance.hideProgress()
                if (errorMSG?.isEmpty)! {
                }
            })
            ContentList.sharedInstance.arrayToCreate.removeAll()
            ContentList.sharedInstance.arrayContent.removeAll()
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Back Screen
                currentStreamType = StreamType.myStream
                let array  = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                if array.count != 0 {
                    StreamList.sharedInstance.arrayViewStream = array
                    let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                    obj.streamType = currentStreamType.rawValue
                    ContentList.sharedInstance.objStream = id
                    self.navigationController?.popToViewController(vc: obj)
                }
                
            }
        }
    }
    
    
    func selectedCollaborator(colabs:[CollaboratorDAO]){
        print(self.selectedCollaborators)
        self.selectedCollaborators = colabs
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

extension CreateStreamController:CustomCameraViewControllerDelegate {
    func dismissWith(image: UIImage?) {
        if let img = image {
            self.setCoverImage(image: img)
        }
    }
    
}

extension CreateStreamController:CropViewControllerDelegate {
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
