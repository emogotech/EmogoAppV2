//
//  ContentViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    
    // MARK: - UI Elements
    @IBOutlet weak var imgCover: UIImageView!
    
    @IBOutlet weak var txtTitleImage: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnShareAction: UIButton!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    
    var currentIndex:Int!
    var seletedImage:ContentDAO!
    var photoEditor:PhotoEditorViewController!
    let shapes = ShapeDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         self.prepareLayout()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - PrepareLayout
    
    func prepareLayout() {
        imgCover.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imgCover.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imgCover.addGestureRecognizer(swipeLeft)
        self.updateContent()
    }
    
    
    func updateContent() {
        seletedImage = ContentList.sharedInstance.arrayContent[currentIndex]
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
        
        if  seletedImage.imgPreview != nil {
            self.imgCover.image = Toucan(image: seletedImage.imgPreview!).resize(kFrame.size, fitMode: Toucan.Resize.FitMode.clip).image
        }
        if !seletedImage.name.isEmpty {
            self.txtTitleImage.text = seletedImage.name.trim()
        }
        if !seletedImage.description.isEmpty {
            self.txtDescription.text = seletedImage.description.trim()
        }
        if seletedImage.type == .image {
            self.btnPlayIcon.isHidden = true
        }else {
            self.btnPlayIcon.isHidden = false
        }
        if seletedImage.imgPreview != nil {
            self.imgCover.image = seletedImage.imgPreview
        }else {
            if seletedImage.type == .image {
                self.btnPlayIcon.isHidden = true
                self.imgCover.setImageWithURL(strImage: seletedImage.coverImage, placeholder: "stream-card-placeholder")
            }else {
                self.imgCover.setImageWithURL(strImage: seletedImage.coverImageVideo, placeholder: "stream-card-placeholder")
                self.btnPlayIcon.isHidden = false
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: -  Action Methods And Selector
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popNormal()
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            if seletedImage.type == .image {
                if self.seletedImage.imgPreview == nil {
                    SharedData.sharedInstance.downloadImage(url: self.seletedImage.coverImage, handler: { (image) in
                        if image != nil {
                            self.openEditor(image:image!)
                        }
                    })
                }else {
                    self.openEditor(image:seletedImage.imgPreview!)
                }
            }
        }else {
            self.showToast(type: .error, strMSG: "You don't have image to Edit.")
        }
    }
    @IBAction func btnActionShare(_ sender: Any) {
        self.showToast(type: .error, strMSG: "Content Will be shared by iMessage (work in progress).")
    }
    
    @IBAction func btnActionAddStream(_ sender: Any) {
        let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
        obj.objContent = seletedImage
        self.navigationController?.push(viewController: obj)
    }
    @IBAction func btnDoneAction(_ sender: Any) {
       // Update Content
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            
            let alert = UIAlertController(title: "Confirmation!", message: "Are you sure, You want to Delete This Content?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "YES", style: .default) { (action) in
                self.deleteSelectedContent()
            }
            let no = UIAlertAction(title: "NO", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(yes)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .left:
                if currentIndex !=  ContentList.sharedInstance.arrayContent.count-1 {
                    self.next()
                }
                break
                
            case .right:
                if currentIndex != 0 {
                    self.previous()
                }
                break
                
            default:
                break
            }
        }
    }
    
    func next() {
        if(currentIndex < ContentList.sharedInstance.arrayContent.count-1) {
            currentIndex = currentIndex + 1
        }
        Animation.addRightTransitionImage(imgV: self.imgCover)
        updateContent()
    }
    
    func previous() {
        if currentIndex != 0{
            currentIndex =  currentIndex - 1
        }
        Animation.addLeftTransitionImage(imgV: self.imgCover)
        updateContent()
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

    func deleteSelectedContent(){
        if !self.seletedImage.contentID.trim().isEmpty {
            self.deleteContent()
        }else {
            ContentList.sharedInstance.arrayContent.remove(at: self.currentIndex)
            if  ContentList.sharedInstance.arrayContent.count != 0 {
                updateContent()
            }else{
                self.navigationController?.pop()
            }
        }
    }
    
    func deleteContent(){
        HUDManager.sharedInstance.showHUD()
        let content = [seletedImage.contentID.trim()]
        APIServiceManager.sharedInstance.apiForDeleteContent(contents: content) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true {
                self.deleteFileFromAWS(content: self.seletedImage)
                ContentList.sharedInstance.arrayContent.remove(at: self.currentIndex)
                if  ContentList.sharedInstance.arrayContent.count != 0 {
                    self.updateContent()
                }else{
                    self.navigationController?.pop()
                }
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func deleteFileFromAWS(content:ContentDAO){
        if !content.coverImage.isEmpty {
            AWSManager.sharedInstance.removeFile(name: content.coverImage.getName(), completion: { (isDeleted, error) in
            })
        }
        if !content.coverImageVideo.isEmpty {
            AWSManager.sharedInstance.removeFile(name: content.coverImageVideo.getName(), completion: { (isDeleted, error) in
            })
        }
    }
    
    func updateContent(coverImage:String,coverVideo:String, type:String){
        APIServiceManager.sharedInstance.apiForEditContent(contentID: self.seletedImage.contentID, contentName: txtTitleImage.text!, contentDescription: txtDescription.text!, coverImage: coverImage, coverImageVideo: coverVideo, coverType: type) { (content, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                ContentList.sharedInstance.arrayContent[self.currentIndex] = content!
            }else {
                self.showToast(strMSG: errorMsg!)
            }
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


extension ContentViewController:PhotoEditorDelegate
{
    func doneEditing(image: UIImage) {
        // the edited image
        AppDelegate.appDelegate.keyboardResign(isActive: true)
        seletedImage.imgPreview = image
        ContentList.sharedInstance.arrayContent[currentIndex] = seletedImage
        self.updateContent()
    }
    
    func canceledEditing() {
        print("Canceled")
        AppDelegate.appDelegate.keyboardResign(isActive: true)
    }
}
