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
    @IBOutlet weak var switchAddPeople: PMSwitch!
    @IBOutlet weak var btnChangeCover: UIButton!
    @IBOutlet weak var switchEmogoPrivate: PMSwitch!
    @IBOutlet weak var switchAddContent: PMSwitch!
    @IBOutlet weak var switchMakeEmogoGlobal: PMSwitch!
    @IBOutlet weak var lblCaption: UILabel!
    
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
        self.switchAddPeople.onImage = UIImage(named: "unlockSwitch")
        self.switchEmogoPrivate.onImage = UIImage(named: "unlockSwitch")
        self.switchMakeEmogoGlobal.onImage = UIImage(named: "unlockSwitch")
        self.switchAddContent.onImage = UIImage(named: "unlockSwitch")
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Action For Buttons
    
    @IBAction func switchActionForAddContent(_ sender: PMSwitch) {
        self.switchAddContent.isOn = sender.isOn
        self.switchAddContent.onImage = UIImage(named: "lockSwitch")
        print(self.switchAddContent.isOn)
    }
    
    @IBAction func switchActionForAddPeople(_ sender: PMSwitch) {
        self.switchAddPeople.isOn = sender.isOn
        self.switchAddPeople.onImage = UIImage(named: "lockSwitch")
        
    }
    @IBAction func btnChangeCover(_ sender: Any) {
        actionForUploadCover()
    }
    @IBAction func switchActionForEmogoGlobal(_ sender: PMSwitch) {
        sender.isOn = !sender.isOn
        if self.switchMakeEmogoGlobal.isOn {
            streamType = "Public"
            self.switchMakeEmogoGlobal.onImage = UIImage(named: "lockSwitch")
        }
    }
   
    
    @IBAction func switchActionForEmogoPrivate(_ sender: PMSwitch) {
        
        sender.isOn = !sender.isOn
        if self.switchEmogoPrivate.isOn {
            self.switchEmogoPrivate.onImage = UIImage(named: "lockSwitch")
            streamType = "Private"
            self.switchAddPeople.isUserInteractionEnabled = false
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isOn = false
            self.switchAddContent.isOn = false
           
        }else{
            streamType = "Public"
            self.isExpandRow = false
            self.switchAddPeople.isUserInteractionEnabled = false
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isOn = false
            self.switchAddContent.isOn = false
            
        }
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
        APIServiceManager.sharedInstance.apiForEditStream(streamID:self.streamID!,streamName: self.tfEmogoTitle.text!, streamDescription: self.tfDescription.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: false, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.isOn, canAddPeople: self.switchAddPeople.isOn,height:hieght,width:width) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToastOnWindow(strMSG: kAlert_Stream_Edited_Success)
                DispatchQueue.main.async{
                    self.navigationController?.popNormal()
                    NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Image_Cover), object: nil)
                }
            }else {
                self.showToastOnWindow(strMSG: errorMsg!)
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


