//
//  PreviewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import iOSPhotoEditor

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        // Preview Height
        kPreviewHeight.constant = 24.0
        self.preparePreview(index: 0)
        self.previewCollection.reloadData()
    }
    
    func preparePreview(index:Int) {
        self.selectedIndex = index
        let obj = self.imagesPreview[index]
        self.imgPreview.image = obj.imgPreview
        if obj.type == .image {
            self.btnPlayIcon.isHidden = true
        }else {
            self.btnPlayIcon.isHidden = false
        }
    }
    
    
    // MARK: -  Action Methods And Selector

    
    @IBAction func btnBackAction(_ sender: Any) {
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        let obj = self.imagesPreview[selectedIndex]
        if obj.type == .image {
            self.openEditor(image:obj.imgPreview)
        }
    }
    @IBAction func btnActionShare(_ sender: Any) {
    }
    @IBAction func btnActionAddStream(_ sender: Any) {
    }
    @IBAction func btnDoneAction(_ sender: Any) {
    }
    @IBAction func btnAnimateViewAction(_ sender: Any) {
        self.animateView()
    }
    @IBAction func btnPlayAction(_ sender: Any) {
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
            self.view.updateConstraintsIfNeeded()
        }
    }
    private  func viewUP(){
        UIView.animate(withDuration: 0.5) {
            self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
            self.kPreviewHeight.constant = 129.0
            self.view.updateConstraintsIfNeeded()
        }
    }
    
    private func openEditor(image:UIImage){
        AppDelegate.appDelegate.keyboardToolBar(disable:true)
        photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
           photoEditor.image = image
        //PhotoEditorDelegate
         photoEditor.photoEditorDelegate = self
         photoEditor.hiddenControls = [.sticker]
         photoEditor.colors = [.red,.blue,.green, .black, .brown, .cyan, .darkGray, .yellow, .lightGray, .purple , .groupTableViewBackground]
          present(photoEditor, animated: true) {
            AppDelegate.appDelegate.keyboardToolBar(disable:false)
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.preparePreview(index: indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.preparePreview(index: indexPath.row)
    }
}

extension PreviewController:PhotoEditorDelegate
{
    func doneEditing(image: UIImage) {
        // the edited image
        let camera = CameraDAO(type: .image, image: image)
        self.imagesPreview[selectedIndex] = camera
        self.previewCollection.reloadData()
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}


extension PreviewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
