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
import Contacts


class AddStreamViewController: UITableViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var txtStreamName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtStreamCaption: MBAutoGrowingTextView!
    @IBOutlet weak var switchMakePrivate: PMSwitch!
    @IBOutlet weak var switchAnyOneCanEdit: PMSwitch!
    @IBOutlet weak var switchAddPeople: PMSwitch!
    @IBOutlet weak var lblAnyOneCanEdit: UILabel!
    @IBOutlet weak var rowHieght: NSLayoutConstraint!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var switchAddCollaborators: PMSwitch!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var lblStreamDescPlaceHolder : UILabel!

       @IBOutlet weak var switchAddContent: PMSwitch!
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
    var isAddContent:Bool!
    var minimumSize: CGSize = CGSize.zero
    
    var contentRowHeight : CGFloat = 30.0 

    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: false, allowResizing: false, allowMoving: false, minimumSize: minimumSize)
    }
    
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
        txtStreamCaption.placeholder = "Stream Caption"
        txtStreamCaption.placeholderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        txtStreamName.selectedLineColor = .clear
        self.lblStreamDescPlaceHolder.text = "Stream Caption"
        self.lblStreamDescPlaceHolder.font = UIFont.systemFont(ofSize: 13)
        if self.txtStreamCaption.text.count > 0 {
            self.lblStreamDescPlaceHolder.isHidden = false
        }else{
            self.lblStreamDescPlaceHolder.isHidden = true
        }
        
        txtStreamName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.txtStreamName.maxLength = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
      
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
        // If Stream is public
        self.rowHieght.constant = 0.0
        self.isExpandRow = false
        self.switchAddCollaborators.isOn = false
        self.switchAddPeople.isOn = false
        self.switchAddContent.isOn = false
        self.switchAddPeople.isUserInteractionEnabled = false
        self.switchAddContent.isUserInteractionEnabled = false
        self.switchAnyOneCanEdit.isUserInteractionEnabled = true
    }
    
    
    func prepareLayoutForApper(){
        self.viewGradient.layer.contents = UIImage(named: "strems_name_gradient")?.cgImage
    }

    func prepareForEditStream(){
        if self.objStream != nil {
            self.title =  self.objStream?.title.trim()
            txtStreamName.text = self.objStream?.title.trim()
            txtStreamCaption.text = self.objStream?.description.trim()
            if !(objStream?.coverImage.trim().isEmpty)!  {
                self.imgCover.setImageWithURL(strImage: (objStream?.coverImage)!, handler: { (image, _) in
                   // self.imgCover.image = image
                    self.imgCover.backgroundColor = image?.getColors().background
                })
                self.imgCover.setImageWithURL(strImage: (objStream?.coverImage)!, placeholder: "add-stream-cover-image-placeholder")
                self.strCoverImage = objStream?.coverImage
            }
            
            self.switchAnyOneCanEdit.isOn = (self.objStream?.anyOneCanEdit)!
            
            if self.objStream?.type.lowercased() == "public"{
                self.switchMakePrivate.isOn = false
            }else {
                self.switchMakePrivate.isOn = true
                streamType = "Private"
            }
            
            // If Editor is Creator
            if objStream?.idCreatedBy.trim() == UserDAO.sharedInstance.user.userId.trim() {
                self.prepareEdit(isEnable: true)
                
                if self.switchAnyOneCanEdit.isOn == true {
                    self.rowHieght.constant = 0.0
                    self.isExpandRow = false
                    self.switchAddCollaborators.isOn = false
                    self.switchAddCollaborators.isUserInteractionEnabled = false
                    self.switchAddContent.isUserInteractionEnabled = false
                    self.switchAddPeople.isUserInteractionEnabled  = false
                    self.switchAddPeople.isOn       = false
                    self.switchAddContent.isOn      = false
                }else {
                    
                    self.switchAddCollaborators.isUserInteractionEnabled = true
                    self.switchAnyOneCanEdit.isUserInteractionEnabled = false
                    self.switchAnyOneCanEdit.isOn = false

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
                }

            }else {
                // Colab is Logged in as Editor
            self.prepareEdit(isEnable: false)
            self.switchAddCollaborators.isUserInteractionEnabled = true

            self.switchAddPeople.isOn = (self.objStream?.userCanAddPeople)!
            self.switchAddContent.isOn = (self.objStream?.userCanAddContent)!
            if self.switchAddPeople.isOn == true {
                self.switchAddPeople.isUserInteractionEnabled  = true
            }else {
                self.switchAddPeople.isUserInteractionEnabled  = false
                }
                
            if self.switchAddContent.isOn == true {
                    self.switchAddContent.isUserInteractionEnabled  = true
            }else {
                self.switchAddContent.isUserInteractionEnabled  = false
                }
            if self.selectedCollaborators.count != 0 {
                    self.rowHieght.constant = 325.0
                    self.isExpandRow = true
                    self.switchAddCollaborators.isOn = true
            }
                
        }
            
        isPerform = true
        self.performSegue(withIdentifier: kSegue_AddCollaboratorsView, sender: self)
        }
        
        if self.txtStreamCaption.text.count > 0 {
            self.lblStreamDescPlaceHolder.isHidden = false
        }else{
            self.lblStreamDescPlaceHolder.isHidden = true
        }
        
        if self.txtStreamCaption.contentSize.height > contentRowHeight {
            contentRowHeight = self.txtStreamCaption.contentSize.height
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        self.tableView.reloadData()
    }
    
    func prepareEdit(isEnable:Bool) {
        self.txtStreamName.isUserInteractionEnabled = isEnable
        self.txtStreamCaption.isUserInteractionEnabled = isEnable
        self.btnCamera.isUserInteractionEnabled = isEnable
        switchMakePrivate.isUserInteractionEnabled = isEnable
        switchAnyOneCanEdit.isUserInteractionEnabled = isEnable
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
        if self.switchAnyOneCanEdit.isOn == true {
            self.switchAddContent.isOn = false
            self.switchAddPeople.isOn = false
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isUserInteractionEnabled = false
            self.switchAddCollaborators.isOn = false
            self.switchAddCollaborators.isUserInteractionEnabled = false
            self.rowHieght.constant = 0.0
            self.isExpandRow = false
        }else {
            self.switchAddCollaborators.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func makePrivateAction(_ sender: PMSwitch) {
            sender.isOn = !sender.isOn
            if self.switchMakePrivate.isOn {
                streamType = "Private"
                self.switchAnyOneCanEdit.isOn = false
                self.switchAnyOneCanEdit.isUserInteractionEnabled = false
                self.switchAddPeople.isUserInteractionEnabled = false
                self.switchAddContent.isUserInteractionEnabled = false
                self.switchAddPeople.isOn = false
                self.switchAddContent.isOn = false
                self.switchAddCollaborators.isUserInteractionEnabled = true
            }else{
                streamType = "Public"
                self.switchAddCollaborators.isOn = false
                self.rowHieght.constant = 0.0
                self.isExpandRow = false
                self.switchAnyOneCanEdit.isOn = false
                self.switchAnyOneCanEdit.isUserInteractionEnabled = true
                self.switchAddPeople.isUserInteractionEnabled = false
                self.switchAddContent.isUserInteractionEnabled = false
                self.switchAddPeople.isOn = false
                self.switchAddContent.isOn = false
                self.switchAddCollaborators.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func addCollaboatorsAction(_ sender: PMSwitch) {
        if self.switchAddCollaborators.isOn {
            self.switchAddContent.isOn = false
            self.switchAddPeople.isOn = false
            self.switchAddContent.isUserInteractionEnabled = true
            self.switchAddPeople.isUserInteractionEnabled = true
            self.getContacts()
        }else{
            self.switchAddContent.isOn = false
            self.switchAddPeople.isOn = false
            self.switchAddContent.isUserInteractionEnabled = false
            self.switchAddPeople.isUserInteractionEnabled = false
            self.rowHieght.constant = 0.0
            self.isExpandRow = false
            selectedCollaborators.removeAll()
            self.tableView.reloadData()
        }
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
                    self.editStream(cover: self.strCoverImage,width:(self.objStream?.width)!,hieght:(self.objStream?.hieght)! )
                }
            }
        }
    }
    
    @IBAction func btnActionCamera(_ sender: Any) {
        
        let cameraViewController:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        cameraViewController.isDismiss = true
        cameraViewController.delegate = self
        self.present(cameraViewController, animated: true, completion: nil)
        
        /*
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            if let img = image{
                self?.setCoverImage(image: img)
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
 */
       
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
        let text = (txtStreamName.text?.trim())! + "\n" +  txtStreamCaption.text.trim()

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
                    } else {
                    self.editStream(cover: imageUrl!,width:Int(image!.size.width) ,hieght:Int(image!.size.height))
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
    
    private func createStream(cover:String,width:Int,hieght:Int){
        
     APIServiceManager.sharedInstance.apiForCreateStream(streamName: self.txtStreamName.text!, streamDescription: self.txtStreamCaption.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: self.switchAnyOneCanEdit.isOn, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.isOn, canAddPeople: self.switchAddPeople.isOn,height:hieght,width:width) { (isSuccess, errorMsg,stream) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToastOnWindow(strMSG: kAlert_Stream_Added_Success)
                DispatchQueue.main.async{
                    currentStreamType = StreamType.myStream
                    StreamList.sharedInstance.arrayStream.insert(stream!, at: 0)
                       NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Filter ), object: nil)
                    if self.isAddContent != nil {
                        self.associateContentToStream(id: (stream?.ID)!)
                    }else {
                         let array = StreamList.sharedInstance.arrayStream.filter { $0.selectionType == currentStreamType }
                        StreamList.sharedInstance.arrayViewStream = array
                        let obj:ViewStreamController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream) as! ViewStreamController
                        obj.currentIndex = 0
                        obj.streamType = currentStreamType.rawValue
                        ContentList.sharedInstance.objStream = nil
                    self.navigationController?.popToViewController(vc: obj)

                        
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
    
    
    private func editStream(cover:String,width:Int,hieght:Int){
        APIServiceManager.sharedInstance.apiForEditStream(streamID:self.streamID!,streamName: self.txtStreamName.text!, streamDescription: self.txtStreamCaption.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: self.switchAnyOneCanEdit.isOn, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.isOn, canAddPeople: self.switchAddPeople.isOn,height:hieght,width:width) { (isSuccess, errorMsg) in
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
   
    
    func getContacts() {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            self.rowHieght.constant = 325.0
            self.isExpandRow = true
            self.tableView.reloadData()
            break
        case .denied, .restricted :
            SharedData.sharedInstance.showPermissionAlert(viewController: (AppDelegate.appDelegate.window?.rootViewController)!, strMessage: "contacts")
            self.switchAddCollaborators.isOn = false
            break
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else{
                    self.switchAddCollaborators.isOn = false
                    SharedData.sharedInstance.showPermissionAlert(viewController: (AppDelegate.appDelegate.window?.rootViewController)!, strMessage: "contacts")
                    return
                }
                self.rowHieght.constant = 325.0
                self.isExpandRow = true
                self.tableView.reloadData()
            }
            break
            
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
        }else if indexPath.row == 1 {
            return contentRowHeight  + 30
        }else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}


extension AddStreamViewController :UITextViewDelegate, UITextFieldDelegate {
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtStreamName {
            txtStreamCaption.becomeFirstResponder()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.lblStreamDescPlaceHolder.isHidden = textView.text.isEmpty
        
        if self.txtStreamCaption.contentSize.height > contentRowHeight {
            contentRowHeight = self.txtStreamCaption.contentSize.height
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
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


extension AddStreamViewController:CustomCameraViewControllerDelegate {
    func dismissWith(image: UIImage?) {
        if let img = image {
            self.setCoverImage(image: img)
        }
    }

}




