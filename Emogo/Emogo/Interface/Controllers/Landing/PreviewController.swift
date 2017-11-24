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

    // MARK: - Variables

    var isPreviewOpen:Bool! = false
    var imagesPreview:[CameraDAO]!
    var selectedIndex:Int! = 0
    var photoEditor:PhotoEditorViewController!
    
    let defaultFooterSize: CGFloat = 63.0
    let FooterSectionIndex: Int = 0

    
    var shouldHideFooter: Bool = false {
        didSet {
            self.previewCollection?.collectionViewLayout.invalidateLayout()
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        // Preview Height
        kPreviewHeight.constant = 129.0
        self.preparePreview(index: 0)
        self.previewCollection.reloadData()
    }
    
    func preparePreview(index:Int) {
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
        self.selectedIndex = index
        let obj = self.imagesPreview[index]
        self.imgPreview.image = obj.imgPreview
        if obj.type == .image {
            self.btnPlayIcon.isHidden = true
        }else {
            self.btnPlayIcon.isHidden = false
        }
        if !obj.title.isEmpty {
            self.txtTitleImage.text = obj.title.trim()
        }
        if !obj.description.isEmpty {
            self.txtDescription.text = obj.description.trim()
        }
    }
    
    
    // MARK: -  Action Methods And Selector

    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.pop()
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        if self.imagesPreview.count != 0 {
            let obj = self.imagesPreview[selectedIndex]
            if obj.type == .image {
                self.openEditor(image:obj.imgPreview)
            }
        }else {
            self.showToast(type: .error, strMSG: "You don't have image to Edit.")
        }
    }
    @IBAction func btnActionShare(_ sender: Any) {
    }
    @IBAction func btnActionAddStream(_ sender: Any) {
        self.showToast(type: .success, strMSG: "Stream added Successfully.")
    }
    @IBAction func btnDoneAction(_ sender: Any) {
        self.showToast(type: .success, strMSG: "Content added Successfully.")
    }
    @IBAction func btnAnimateViewAction(_ sender: Any) {
        self.animateView()
    }
    @IBAction func btnPlayAction(_ sender: Any) {
    }
    @IBAction func btnDeleteAction(_ sender: Any) {
        if self.imagesPreview.count != 0 {
            self.imagesPreview.remove(at: self.selectedIndex)
            if self.imagesPreview.count != 0 {
                self.preparePreview(index: 0)
            }else{
                self.navigationController?.pop()
            }
            self.previewCollection.reloadData()
        }
    }
    
    // MARK: - Class Methods

    private func animateView(){
        UIView.animate(withDuration: 0.5) {
            self.isPreviewOpen = !self.isPreviewOpen
            if self.isPreviewOpen == false {
                // Down icon
                
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
                self.kPreviewHeight.constant = 129.0
            }else {
                // Up icon
                self.kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
            }
            self.imgPreview.contentMode = .scaleAspectFit
            self.view.updateConstraintsIfNeeded()
        }
    }
    private  func viewUP(){
        UIView.animate(withDuration: 0.5) {
            self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
            self.kPreviewHeight.constant = 129.0
            self.imgPreview.contentMode = .scaleAspectFit
            self.view.updateConstraintsIfNeeded()
        }
    }
    
    private func openEditor(image:UIImage){
        photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
           photoEditor.image = image
        //PhotoEditorDelegate
         photoEditor.photoEditorDelegate = self
         photoEditor.hiddenControls = [.share]
         photoEditor.colors = [.red,.blue,.green, .black, .brown, .cyan, .darkGray, .yellow, .lightGray, .purple , .groupTableViewBackground]
          present(photoEditor, animated: true) {
        }
    }
    
    func setPreviewContent(title:String, description:String) {
        if self.imagesPreview.count != 0 {
            let obj = self.imagesPreview[selectedIndex]
            obj.title = title
            obj.description = description
            self.imagesPreview[selectedIndex] = obj
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
        return self.imagesPreview.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PreviewCell, for: indexPath) as! PreviewCell
        let obj = self.imagesPreview[indexPath.row]
        cell.setupPreviewWithType(type: obj.type, image: obj.imgPreview)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height - 30, height: collectionView.frame.size.height)
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.preparePreview(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if self.shouldHideFooter && section == self.FooterSectionIndex {
            return CGSize(width: defaultFooterSize, height: collectionView.bounds.height )
        }
        else {
            return CGSize(width: defaultFooterSize, height: collectionView.bounds.height)
        }
    }
}

extension PreviewController:PhotoEditorDelegate
{
    func doneEditing(image: UIImage) {
        // the edited image
        let camera = CameraDAO(type: .image, image: image)
        self.imagesPreview[selectedIndex] = camera
        self.preparePreview(index: selectedIndex)
        self.previewCollection.reloadData()
    }
    
    func canceledEditing() {
        print("Canceled")
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
