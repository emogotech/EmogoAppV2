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
import Gallery

class AddStreamViewController: UITableViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var txtStreamName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtStreamCaption: UITextView!
    @IBOutlet weak var switchMakePrivate: PMSwitch!
    @IBOutlet weak var switchAnyOneCanEdit: PMSwitch!
    @IBOutlet weak var switchAddContent: PMSwitch!
    @IBOutlet weak var switchAddPeople: PMSwitch!
    @IBOutlet weak var lblAnyOneCanEdit: UILabel!
    @IBOutlet weak var rowHieght: NSLayoutConstraint!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var switchAddCollaborators: PMSwitch!
    
    
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
    var gallery: GalleryController!
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
        txtStreamName.title = "Stream Name"
        txtStreamCaption.delegate = self
        Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
        Gallery.Config.initialTab =  .cameraTab
        Gallery.Config.Camera.imageLimit =  1
        self.switchAddContent.isEnabled = false
        self.switchAddPeople.isEnabled = false
        if self.streamID != nil {
            self.getStream()
        }else {
            isPerform = true
            self.performSegue(withIdentifier: kSegue_AddCollaboratorsView, sender: self)
            self.tableView.reloadData()
        }
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
                self.imgCover.setImageWithURL(strImage: (objStream?.coverImage)!, placeholder: "add-stream-cover-image-placeholder")
                self.strCoverImage = objStream?.coverImage
            }
            self.switchAddPeople.isOn = (self.objStream?.canAddPeople)!
            self.switchAddContent.isOn = (self.objStream?.canAddContent)!
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
            isPerform = true
            self.performSegue(withIdentifier: kSegue_AddCollaboratorsView, sender: self)
            self.tableView.reloadData()
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
        self.switchMakePrivate.isOn = sender.isOn
        self.switchAddContent.isOn = false
        self.switchAddPeople.isOn = false
        self.switchAddPeople.isEnabled = sender.isOn
        self.switchAddContent.isEnabled = sender.isOn
        if sender.isOn {
            streamType = "Private"
             self.switchAnyOneCanEdit.isEnabled = false
        }else {
            streamType = "Public"
            self.switchAnyOneCanEdit.isEnabled = true
        }
        if self.objStream?.arrayColab.count != 0 {
            self.switchAddCollaborators.isOn = true
            self.rowHieght.constant = 325.0
            self.isExpandRow = true
        }
    }
    @IBAction func addCollaboatorsAction(_ sender: PMSwitch) {
        self.switchAddCollaborators.isOn = sender.isOn
       
        if sender.isOn {
            self.rowHieght.constant = 325.0
            self.isExpandRow = true
            
        }else {
            self.switchAddContent.isOn = false
            self.switchAddPeople.isOn = false
            self.rowHieght.constant = 0.0
            self.isExpandRow = false
            selectedCollaborators.removeAll()
        }
        self.tableView.reloadData()
    }
    @IBAction func btnActionDone(_ sender: Any) {
        if coverImage == nil && strCoverImage.isEmpty{
            self.showToastOnWindow(strMSG: kAlertStreamCoverEmpty)
        }
       else if (self.txtStreamName.text?.trim().isEmpty)! {
            txtStreamName.shake()
        }else if switchAddCollaborators.isOn  && self.selectedCollaborators.count == 0{
            self.showToastOnWindow(strMSG: kAlertStreamColabEmpty)
        }else {
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
        gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
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

    func setCoverImage(asset:Image) {
        Image.resolve(images: [asset]) { (images) in
            if images.count != 0 {
                let image = images[0]
                self.imgCover.image = image
                                self.coverImage = image
                                self.strCoverImage = ""
                                self.imgCover.contentMode = .redraw
                                if let file =  asset.asset.value(forKey: "filename"){
                                   self.fileName =  file as! String
                                    print(self.fileName)
                }
            }
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
        print(colabs.count)
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
        
        APIServiceManager.sharedInstance.apiForCreateStream(streamName: self.txtStreamName.text!, streamDescription: self.txtStreamCaption.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: self.switchAnyOneCanEdit.isOn, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.isOn, canAddPeople: self.switchAddPeople.isOn) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToastOnWindow(strMSG: kAlertStreamAddedSuccess)
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.navigationController?.pop()
                      NotificationCenter.default.post(name: NSNotification.Name(kNotificationUpdateFilter ), object: nil)
                }
            }else {
                self.showToastOnWindow(strMSG: errorMsg!)
            }
        }
    }
    private func editStream(cover:String){
        APIServiceManager.sharedInstance.apiForEditStream(streamID:self.streamID!,streamName: self.txtStreamName.text!, streamDescription: self.txtStreamCaption.text.trim(), coverImage: cover, streamType: streamType, anyOneCanEdit: self.switchAnyOneCanEdit.isOn, collaborator: self.selectedCollaborators, canAddContent: self.switchAddContent.isOn, canAddPeople: self.switchAddPeople.isOn) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true{
                self.showToastOnWindow(strMSG: kAlertStreamEditedSuccess)
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.navigationController?.pop()
                  
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
           txtStreamCaption.resignFirstResponder()
            return false
        }
        return true
    }
    
}
extension AddStreamViewController:GalleryControllerDelegate {
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        self.setCoverImage(asset: images[0])
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    }
    
    
}
