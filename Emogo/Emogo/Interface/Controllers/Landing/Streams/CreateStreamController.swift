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

protocol CreateStreamControllerDelegate {
    func streamCreatedWith(stream:StreamDAO)
}
class CreateStreamController: UITableViewController {
    
    
    //MARK:- IBOutlet Connections
    
    @IBOutlet weak var viewAddCoverImage: UIView!
    @IBOutlet weak var tfEmogoTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDescription: MBAutoGrowingTextView!
   // @IBOutlet weak var switchForEmogoPrivate: PMAnimatedSwitch!
    @IBOutlet weak var switchForEmogoPrivate: UISwitch!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var lblAddCoverImage: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var textFieldNext: UITextField!

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
    var buttonDone = UIButton(type: .system)
    var contentRowHeight : CGFloat = 30.0
    var exestingNavigation:UINavigationController?
    //var delegate:CreateStreamControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  self.navigationController?.isNavigationBarHidden = true
        prepareNavigationbarButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // self.viewTitle.layer.contents = UIImage(named: "gradient")?.cgImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    @objc func doneClicked() {
        view.endEditing(true)
    }*/
    
    // MARK: - Prepare Layouts
    
    private func prepareLayouts(){
          tfEmogoTitle.becomeFirstResponder()
       
//        tfEmogoTitle.inputAccessoryView = toolBar
//        textFieldNext.inputAccessoryView = toolBar
//        tfDescription.inputAccessoryView = toolBar
        tfEmogoTitle.placeholder = "Emogo Title"
        tfEmogoTitle.title = "Emogo Title"
        tfDescription.placeholder = "Caption (Optional)"
        tfDescription.placeholderColor = UIColor(r: 150, g: 150, b: 150)
    
        tfEmogoTitle.selectedLineColor = .clear
        self.lblCaption.text = "Caption (Optional)"
        if self.tfDescription.text.count > 0 {
            self.lblCaption.isHidden = false
        }else{
            self.lblCaption.isHidden = true
        }
        self.lblCaption.isHidden = true
        self.tableView.tableFooterView = UIView()
        AppDelegate.appDelegate.keyboardResign(isActive: true)
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
        self.switchForEmogoPrivate.isOn = false
       
        self.switchForEmogoPrivate.thumbTintColor = UIColor.lightGray
        
      
//        switchForEmogoPrivate.delegate = self
//        switchForEmogoPrivate.setImages(onImage: #imageLiteral(resourceName: "lockSwitch"), offImage: #imageLiteral(resourceName: "unlockSwitch"))
//        switchForEmogoPrivate.layer.borderWidth = 1.0
//        switchForEmogoPrivate.layer.borderColor = UIColor.black.cgColor
    }
    
    func prepareNavigationbarButtons(){
        
        let button   = UIButton(type: .system)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.frame = CGRect(x: 10, y: -12, width: 60, height: 40)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.addTarget(self, action: #selector(self.btnCloseAction(_:)), for: .touchUpInside)
        let btnBack = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = btnBack
        
        buttonDone  = UIButton(type: .system)
        buttonDone.setTitle("Done", for: .normal)
        buttonDone.setTitleColor(UIColor.lightGray, for: .normal)
        buttonDone.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
       // buttonDone.setTitleColor(kNavigationColor, for: .normal)
        buttonDone.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        buttonDone.addTarget(self, action: #selector(self.btnDoneAction(_:)), for: .touchUpInside)
        let btnDone = UIBarButtonItem(customView: buttonDone)
        self.navigationItem.rightBarButtonItem = btnDone
        self.title = "Create New Emogo"
        
    }
    //MARK:- action for buttons
    
    @IBAction func switchActionForEmogoPrivate(_ sender: Any) {
        
        if self.switchForEmogoPrivate.isOn {
            streamType = StreamType.Private.rawValue
            self.switchForEmogoPrivate.thumbTintColor = UIColor.white
        }else{
            streamType = StreamType.Public.rawValue
            self.switchForEmogoPrivate.thumbTintColor = UIColor.lightGray
        }
        
    }
    @IBAction func btnCloseAction(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        if coverImage == nil {
            self.showToastOnWindow(strMSG: kAlert_Stream_Cover_Empty)
        }
        else if (self.tfEmogoTitle.text?.trim().isEmpty)! {
            tfEmogoTitle.shake()
            self.showToastOnWindow(strMSG: kAlert_Stream_Title_Empty)
        } else {
            self.view.endEditing(true)
            self.showToastOnWindow(strMSG: kAlert_Upload_Wait_Msg)
                self.uploadCoverImage()
        }
    }
    @IBAction func btnActionForAddCoverImage(_ sender: Any) {
        self.actionForUploadCover()
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
        self.viewAddCoverImage.isHidden = true
        self.lblAddCoverImage.isHidden = true
       // print(self.fileName)
        self.tfEmogoTitle.becomeFirstResponder()
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
                        self.createStream(cover: imageUrl!,width:Int(image!.size.width) ,hieght:Int(image!.size.height), color: (image?.getColors().primary.toHexString)!)
                    }
                }
            }else {
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
    private func createStream(cover:String,width:Int,hieght:Int,color:String){
        
        APIServiceManager.sharedInstance.apiForCreateStream(streamName: self.tfEmogoTitle.text!, streamDescription: self.tfDescription.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: false, collaborator: self.selectedCollaborators, canAddContent: false , canAddPeople: false ,height:hieght,width:width,color:color) { (isSuccess, errorMsg,stream) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToast(type: .error, strMSG: kAlert_Stream_Added_Success)
                DispatchQueue.main.async{
//                    if self.switchForEmogoPrivate.on {
//                        currentStreamType = StreamType.Private
//                    }else {
//                        currentStreamType = StreamType.Public
//                    }
                    
                    if self.switchForEmogoPrivate.isOn {
                        currentStreamType = StreamType.Private
                        self.switchForEmogoPrivate.thumbTintColor = UIColor.white
                    }else {
                        currentStreamType = StreamType.Public
                        self.switchForEmogoPrivate.thumbTintColor = UIColor.lightGray
                    }
                    
                    StreamList.sharedInstance.arrayStream.insert(stream!, at: 0)
                    NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Filter ), object: nil)
                    if isAssignProfile != nil {
                        self.assignProfileStream(streamID: (stream?.ID)!)
                    }else {
                        if self.isAddContent != nil {
                            self.associateContentToStream(id: (stream?.ID)!)
                        }else {
                            self.dismiss(animated: true, completion: nil)
                            let array = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                            StreamList.sharedInstance.arrayViewStream = array
//                            let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                            let obj:EmogoDetailViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EmogoDetailView) as! EmogoDetailViewController
                            obj.currentIndex = 0
                          
                            obj.isFromCreateStream = "TRUE"
                            obj.streamType = currentStreamType.rawValue
                            ContentList.sharedInstance.objStream = nil
                            self.navigationController?.pushNormal(viewController: obj)
                            //self.exestingNavigation?.popToViewController(vc: obj)
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
                self.dismiss(animated: true, completion: nil)
                isAssignProfile = nil
                let obj : ProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView) as! ProfileViewController
                self.exestingNavigation?.popToViewController(vc: obj)
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
                self.dismiss(animated: true, completion: nil)
                
//                if self.switchForEmogoPrivate.on {
//                    currentStreamType = StreamType.Private
//                }else {
//                    currentStreamType = StreamType.Public
//                }
//
                if self.switchForEmogoPrivate.isOn {
                    currentStreamType = StreamType.Private
                    self.switchForEmogoPrivate.thumbTintColor = UIColor.white
                }else {
                    currentStreamType = StreamType.Public
                    self.switchForEmogoPrivate.thumbTintColor = UIColor.white
                }
                
                let array  = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                if array.count != 0 {
                    StreamList.sharedInstance.arrayViewStream = array
                    let obj:EmogoDetailViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_EmogoDetailView) as! EmogoDetailViewController
                   
//                    let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                    obj.streamType = currentStreamType.rawValue
                    ContentList.sharedInstance.objStream = id
                    self.navigationController?.pushNormal(viewController: obj)
                   // self.exestingNavigation?.popToViewController(vc: obj)
                }
                
            }
        }
    }
    
    
    func selectedCollaborator(colabs:[CollaboratorDAO]){
      //  print(self.selectedCollaborators)
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
    
    @objc func textFieldDidChange(_ textField: SkyFloatingLabelTextField) {
        buttonDone.setTitleColor(UIColor(r: 0, g: 122, b: 255), for: .normal)
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

extension CreateStreamController :UITextViewDelegate, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmogoTitle {
            tfDescription.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
      
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
     //   self.lblCaption.isHidden = textView.text.isEmpty
        self.tfDescription.text = self.tfDescription.text.trim().replacingOccurrences(of: "\n", with: "")
        if self.tfDescription.contentSize.height > contentRowHeight {
            print(self.tfDescription.text)
            if self.tfDescription.text.trim().replacingOccurrences(of: "\n", with: "").isEmpty {
                contentRowHeight = 30
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }else {
                contentRowHeight = self.tfDescription.contentSize.height
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
          
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            tfDescription.resignFirstResponder()
            if tfDescription.text.isEmpty {
                tfDescription.placeholder = "Caption (Optional)"
            }
            //textFieldNext.becomeFirstResponder()
            return false
        }
        return textView.text.length + (text.length - range.length) <= 250
    }
}
extension CreateStreamController {
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        if indexPath.row == 2 {
            return contentRowHeight  + 10
        }else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
extension CreateStreamController :PMSwitcherChangeValueDelegate{
    func switcherDidChangeValue(switcher: PMAnimatedSwitch, value: Bool) {
        if value {
            streamType = "Private"
        }else {
            streamType = "Public"
        }
    }
    
  
}
