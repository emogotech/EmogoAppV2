//
//  PreviewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class PreviewController: UIViewController {

    // MARK: - UI Elements

    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var txtTitleImage: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnShareAction: UIButton!
    @IBOutlet weak var btnPreviewOpen: UIButton!
    @IBOutlet weak var previewCollection: UICollectionView!
    @IBOutlet weak var kPreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var kWidthOptions: NSLayoutConstraint!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    // MARK: - Variables

    var isPreviewOpen:Bool! = false
    var selectedIndex:Int! = 0
    var photoEditor:PhotoEditorViewController!
    let shapes = ShapeDAO()
    var objContent:ContentDAO?
    var isContentAdded:Bool! = false
    var seletedImage:ContentDAO!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        // Preview Height
        self.preparePreview(index: 0)
        kPreviewHeight.constant = 129.0
        kWidthOptions.constant = 0.0
        imgPreview.backgroundColor = .black
        self.imgPreview.contentMode = .scaleAspectFit
        viewOptions.isHidden = true
        // Preview Footer
        self.previewCollection.reloadData()
    }
   
    
    
    func preparePreview(index:Int) {
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
        self.selectedIndex = index
       
        seletedImage =  ContentList.sharedInstance.arrayContent[index]
        if  seletedImage.imgPreview != nil {
            self.imgPreview.image = seletedImage.imgPreview
        }else{
            
        }
        if seletedImage.type == .image {
            self.btnPlayIcon.isHidden = true
        }else {
            self.btnPlayIcon.isHidden = false
        }
        if !seletedImage.name.isEmpty {
            self.txtTitleImage.text = seletedImage.name.trim()
        }
        if !seletedImage.description.isEmpty {
            self.txtDescription.text = seletedImage.description.trim()
        }
        
        if seletedImage.imgPreview != nil {
            self.imgPreview.image = seletedImage.imgPreview?.resizedImage(withMaximumSize: CGSize(width: self.imgPreview.frame.width * 2.0, height: self.imgPreview.frame.height * 2.0))
        }
        
    }
    
    
    func hideControls(isHide:Bool) {
        
    }
    
    // MARK: -  Action Methods And Selector

    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popNormal()
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            if seletedImage.type == .image {
                self.openEditor(image:seletedImage.imgPreview!)
            }
        }else {
            self.showToast(type: .error, strMSG: "You don't have image to Edit.")
        }
    }
    @IBAction func btnActionShare(_ sender: Any) {
    }
    @IBAction func btnActionAddStream(_ sender: Any) {
        isContentAdded = true
        if objContent != nil {
             addContentToStream()
        }else {
            if (self.txtTitleImage.text?.isEmpty)! {
                self.txtTitleImage.shake()
            }else {
                self.uploadFile()
            }
        }
    }
    @IBAction func btnDoneAction(_ sender: Any) {
         isContentAdded = false
        if (self.txtTitleImage.text?.isEmpty)! {
            self.txtTitleImage.shake()
        }else {
            self.uploadFile()
        }
    }
    @IBAction func btnAnimateViewAction(_ sender: Any) {
        self.animateView()
    }
    @IBAction func btnPlayAction(_ sender: Any) {
    }
    @IBAction func btnDeleteAction(_ sender: Any) {
        if  ContentList.sharedInstance.arrayContent.count != 0 {
             ContentList.sharedInstance.arrayContent.remove(at: self.selectedIndex)
            if  ContentList.sharedInstance.arrayContent.count != 0 {
                self.preparePreview(index: 0)
            }else{
                self.navigationController?.pop()
            }
            self.previewCollection.reloadData()
        }
    }
    @objc func playIconTapped(sender:UIButton) {
        self.preparePreview(index: sender.tag)
    }
    
    // MARK: - Class Methods

    private func animateView(){
        UIView.animate(withDuration: 0.5) {
            self.isPreviewOpen = !self.isPreviewOpen
            if self.isPreviewOpen == false {
                // Down icon
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
                self.kPreviewHeight.constant = 129.0
               self.imgPreview.contentMode = .scaleAspectFit

            }else {
                // Up icon
                self.kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
               self.imgPreview.contentMode = .scaleToFill

            }
            self.view.updateConstraintsIfNeeded()
         //   self.imgPreview.image =  GalleryDAO.sharedInstance.Images[self.selectedIndex].imgPreview.resizeImage(targetSize: CGSize(width: self.imgPreview.bounds.width * 2.0, height: self.imgPreview.bounds.height * 2.0))
        }
    }
   
    
    private func openEditor(image:UIImage){
        AppDelegate.appDelegate.keyboardResign(isActive: false)
        photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
           photoEditor.image = image
        //PhotoEditorDelegate
         photoEditor.photoEditorDelegate = self
         photoEditor.hiddenControls = [.share]
        photoEditor.stickers = shapes.shapes
         photoEditor.colors = [.red,.blue,.green, .black, .brown, .cyan, .darkGray, .yellow, .lightGray, .purple , .groupTableViewBackground]
          present(photoEditor, animated: true) {
        }
    }
    
    func setPreviewContent(title:String, description:String) {
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            seletedImage.name = title
            seletedImage.description = description
            ContentList.sharedInstance.arrayContent[selectedIndex] = seletedImage
        }
    }
    // MARK: - API Method
    
    func uploadFile(){
        HUDManager.sharedInstance.showProgress()
        let dispatchGroup = DispatchGroup()
        var fileUrl:URL!
        var type:String! = "Picture"
        if seletedImage.type == .video {
            dispatchGroup.enter()
            type = "Video"
            Document.compressVideoFile(name: seletedImage.fileName, inputURL: seletedImage.fileUrl!, handler: { (compressed) in
                if compressed != nil {
                    fileUrl = URL(fileURLWithPath: compressed!)
                    print(fileUrl)
                }
                dispatchGroup.leave()
            })
        }else {
            dispatchGroup.enter()
            let image = seletedImage.imgPreview?.reduceSize()
            let compressedData = UIImageJPEGRepresentation(image!, 1.0)
            let url = Document.saveFile(data: compressedData!, name: seletedImage.fileName)
            fileUrl = URL(fileURLWithPath: url)
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            print("Both functions complete 👍")
            AWSManager.sharedInstance.uploadFile(fileUrl, name: self.seletedImage.fileName) { (fileUrl,error) in
                HUDManager.sharedInstance.hideProgress()
                if error == nil {
                    HUDManager.sharedInstance.showHUD()
                    DispatchQueue.main.async {
                        self.addContent(fileUrl: fileUrl!,type:type)
                    }
                }
            }
        }
        
    }
    
    func addContent(fileUrl:String,type:String){
        APIServiceManager.sharedInstance.apiForCreateContent(contentName: (txtTitleImage.text?.trim())!, contentDescription: (txtDescription.text?.trim())!, coverImage: fileUrl, coverType: type) { (contents, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                if !self.isContentAdded {
                    self.showToast(type: .success, strMSG: kAlertContentAdded)
                }
                self.modifyObjects(contents: contents!)
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func modifyObjects(contents:[ContentDAO]){
        
        if self.isContentAdded {
            self.addContentToStream()
        }
    }
    
    func addContentToStream(){
        if objContent != nil {
            let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
            obj.objContent = objContent
            self.navigationController?.push(viewController: obj)
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


extension PreviewController:UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  ContentList.sharedInstance.arrayContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PreviewCell, for: indexPath) as! PreviewCell
        let obj =  ContentList.sharedInstance.arrayContent[indexPath.row]
        cell.setupPreviewWithType(content:obj)
        cell.playIcon.tag = indexPath.row
        cell.playIcon.addTarget(self, action: #selector(self.playIconTapped(sender:)), for: .touchUpInside)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height - 30, height: collectionView.frame.size.height)
    }
    
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.preparePreview(index: indexPath.row)
    }
    
}

extension PreviewController:PhotoEditorDelegate
{
    func doneEditing(image: UIImage) {
        // the edited image
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        seletedImage.imgPreview = image
        ContentList.sharedInstance.arrayContent[selectedIndex] = seletedImage
        self.preparePreview(index: selectedIndex)
        self.previewCollection.reloadData()
    }
    
    func canceledEditing() {
        print("Canceled")
        AppDelegate.appDelegate.keyboardResign(isActive: true)
    }
}


extension PreviewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtTitleImage {
            txtDescription.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
            self.setPreviewContent(title: (txtTitleImage.text?.trim())!, description: (txtDescription.text?.trim())!)
        }
        return true
    }
}
