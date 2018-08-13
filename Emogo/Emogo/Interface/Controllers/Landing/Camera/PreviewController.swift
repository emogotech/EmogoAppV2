//
//  PreviewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import MessageUI
import Messages
import SwiftLinkPreview

class PreviewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var actionContainerView : UIView!
    @IBOutlet weak var imgPreview: FLAnimatedImageView!
    @IBOutlet weak var txtTitleImage: UITextField!
    @IBOutlet weak var txtDescription: MBAutoGrowingTextView!
    @IBOutlet weak var btnShareAction: UIButton!
    @IBOutlet weak var btnPreviewOpen: UIButton!
    @IBOutlet weak var previewCollection: UICollectionView!
    @IBOutlet weak var kPreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnPlayIcon: UIButton!
    @IBOutlet weak var kWidthOptions: NSLayoutConstraint!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnAddStream: UIButton!
    @IBOutlet weak var kWidth: NSLayoutConstraint!
    @IBOutlet weak var btnAddMore: UIButton!
    @IBOutlet weak var viewLinkPreview: CardView!
    @IBOutlet weak var kLinkPreviewHieght: NSLayoutConstraint!
    @IBOutlet weak var lblURL: UILabel!
    @IBOutlet weak var lblLinkTitle: UILabel!
    @IBOutlet weak var lblLinkDescription: UILabel!
    @IBOutlet weak var imgLogo: FLAnimatedImageView!
    @IBOutlet weak var kLinkLogoWidth: NSLayoutConstraint!

    
    // MARK: - Variables
    
    var isPreviewOpen:Bool! = false
    var selectedIndex:Int!
    var photoEditor:PhotoEditorViewController!
    let shapes = ShapeDAO()
    var isContentAdded:Bool! = false
    var seletedImage:ContentDAO!
    var strPresented:String!
    var isEditingContent:Bool! = false
    var isShowRetake:Bool?
    var isFromNotes:String?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideStatusBar()
        if self.isEditingContent{
            self.preparePreview(index: selectedIndex)
        }
      
        self.previewCollection.reloadData()
        self.prepareNavBarButtons()
        
        if #available(iOS 11, *), UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
          
            self.actionContainerView.translatesAutoresizingMaskIntoConstraints = false

            let guide = view.safeAreaLayoutGuide
            
            self.actionContainerView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
            self.actionContainerView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
            self.actionContainerView.topAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
            
            guide.bottomAnchor.constraintEqualToSystemSpacingBelow(actionContainerView.bottomAnchor, multiplier: 1.0).isActive = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.btnShareAction.addShadow()
        self.viewLinkPreview.layer.borderWidth = 1.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showStatusBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        // Preview Height
        // Remove Duplicate Objects
        if selectedIndex == nil {
            selectedIndex = 0
        }
        viewLinkPreview.isHidden = true
        self.view.backgroundColor = .black
        self.txtTitleImage.maxLength = 50
        txtDescription.delegate = self
        self.txtDescription.placeholder = "Description"
        self.txtDescription.placeholderColor = .white
        self.txtTitleImage.addShadow()
        self.txtDescription.addShadow()
        
        var seen = Set<String>()
        var unique = [ContentDAO]()
        
      
        if  SharedData.sharedInstance.deepLinkType == kDeepLinkTypeShareAddContent {
            
            ContentList.sharedInstance.arrayContent.removeAll()
            ContentList.sharedInstance.arrayContent = SharedData.sharedInstance.contentList.arrayContent!
            print(ContentList.sharedInstance.arrayContent.count)
             self.isShowRetake = true
         //   ContentList.sharedInstance.objStream = nil
          //  SharedData.sharedInstance.contentList.objStream = nil
            if ContentList.sharedInstance.arrayContent.count == 1 {
                let conten = ContentList.sharedInstance.arrayContent[selectedIndex]
                
                if !conten.name.isEmpty {
                    if conten.name.trim().count > 75 {
                        conten.name = conten.name.trim(count: 75)
                    }
                }
                if !conten.description.isEmpty {
                    if conten.description.trim().count > 250 {
                        conten.description = conten.description.trim(count: 250)
                    }
                }
                conten.isUploaded = false
                
                conten.type = conten.type == .image ? .image : .link
                
                ContentList.sharedInstance.arrayContent.removeAll()
                ContentList.sharedInstance.arrayContent.append(conten)
            }
          
            if selectedIndex == nil {
                selectedIndex = 0
            }
            self.preparePreview(index: selectedIndex)
           
            SharedData.sharedInstance.deepLinkType = ""
        }else{
            self.preparePreview(index: selectedIndex)
        }
        
        
        for obj in  ContentList.sharedInstance.arrayContent {
            if obj.isUploaded {
                if !seen.contains(obj.contentID) {
                    unique.append(obj)
                    seen.insert(obj.contentID)
                }
            }else if obj.type == .gif || obj.type == .link {
                if !seen.contains(obj.coverImage.trim()) {
                    unique.append(obj)
                    seen.insert(obj.coverImage.trim())
                }
            }else {
                if !seen.contains(obj.fileName.trim()) {
                    unique.append(obj)
                    seen.insert(obj.fileName.trim())
                }
            }
        }
        ContentList.sharedInstance.arrayContent = unique
       
        kPreviewHeight.constant = 129.0
        self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "preview_down_arrow"), for: .normal)
        //  kWidthOptions.constant = 0.0
        viewOptions.isHidden = false
        //        if self.strPresented != nil {
        kWidthOptions.constant = 63.0
        //            viewOptions.isHidden = false
        //        }
        imgPreview.backgroundColor = .black
        
        self.imgPreview.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openFullView))
        tap.numberOfTapsRequired = 1
        self.imgPreview.addGestureRecognizer(tap)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureAction(gesture:)))
        swipeUp.direction = .up
        self.imgPreview.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureAction(gesture:)))
        swipeDown.direction = .down
        self.imgPreview.addGestureRecognizer(swipeDown)
        
        let swipeDown1 = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureAction(gesture:)))
        swipeDown1.direction = .down
        self.previewCollection.addGestureRecognizer(swipeDown1)
        
        // Preview Footer
        self.previewCollection.reloadData()
       
        self.imgPreview.contentMode = .scaleAspectFit
       // kWidth.constant = 0.0
        kLinkPreviewHieght.constant = 0.0
        /*
        if self.isShowRetake != nil  {
            self.btnShareAction.isHidden = false
          //  kWidth.constant = 50.0
        }
        if self.seletedImage != nil {
            if self.seletedImage.type == .link {
                self.btnShareAction.isHidden = false
                self.btnDone.isHidden = true
            }else {
                self.btnShareAction.isHidden = true
                self.btnDone.isHidden = true
            }
        }
         */

      
      
    }
    
    
    func prepareNavBarButtons(){
        btnDone.isUserInteractionEnabled = true
        btnAddStream.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = false

//        self.navigationController?.navigationBar.barTintColor = .clear
//        self.navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.1)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.navigationController?.navigationBar.tintColor = .white //.clear
        
//        UIButton *useButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        useButton.frame = CGRectMake(100, 430, 100, 40);
//        useButton.layer.masksToBounds = NO;
//        useButton.layer.cornerRadius = 10;
//        useButton.layer.shadowOffset = CGSizeMake(1.5, 1.5);
//        useButton.layer.shadowRadius = 0.5;
//        useButton.layer.shadowOpacity = 1.0;
//        useButton.layer.shadowColor = [UIColor blackColor].CGColor;
//        useButton.backgroundColor = [UIColor redColor];
        
//        let btnBack = UIBarButtonItem(image: #imageLiteral(resourceName: "back-circle-icon"), style: .plain, target: self, action: #selector(self.btnBack))
        let button = self.getShadowButton(Alignment: 0)
       // button.setBackgroundImage(#imageLiteral(resourceName: "back-circle-icon"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "back icon_shadow"), for: .normal)
        button.addTarget(self, action: #selector(self.btnBack), for: .touchUpInside)
        let btnBack = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = btnBack
    }
    
   
    
    func changeButtonAccordingSwipe(selected:ContentDAO){
        //editing_cross_icon
        var arrButtons = [UIBarButtonItem]()

        self.navigationItem.setRightBarButtonItems([], animated: true)
        
//        var imgEdit = #imageLiteral(resourceName: "edit_icon")
//        var btnEdit = UIBarButtonItem(image: imgEdit, style: .plain, target: self, action: #selector(self.btnEditAction(_:)))
        
        let buttonEdit = self.getShadowButton(Alignment: 2)
        buttonEdit.setImage(#imageLiteral(resourceName: "edit icon_new"), for: .normal)
      //  buttonEdit.setBackgroundImage(#imageLiteral(resourceName: "edit_icon"), for: .normal)
        buttonEdit.addTarget(self, action: #selector(self.btnEditAction(_:)), for: .touchUpInside)
        let btnEdit = UIBarButtonItem.init(customView: buttonEdit)
        
        
        
//        let imgDelete = #imageLiteral(resourceName: "delete_icon-cover_image")
//        let btnDelete = UIBarButtonItem(image: imgDelete, style: .plain, target: self, action: #selector(self.btnDeleteAction(_:)))

        let buttonDel = self.getShadowButton(Alignment: 2)
      //  buttonDel.setBackgroundImage(#imageLiteral(resourceName: "delete_new"), for: .normal)
        buttonDel.setImage(#imageLiteral(resourceName: "delete icon_new"), for: .normal)
        buttonDel.addTarget(self, action: #selector(self.btnDeleteAction(_:)), for: .touchUpInside)
        let btnDelete = UIBarButtonItem.init(customView: buttonDel)
        
        
        
        if selected.isUploaded == false {
            arrButtons.append(btnEdit)
            arrButtons.append(btnDelete)
        }else{
            if selected.isEdit == true {
                    arrButtons.append(btnEdit)
//                if selected.type == .link {
//
//                    let buttonDel = self.getShadowButton(Alignment: 1)
//                    buttonDel.setImage(#imageLiteral(resourceName: "change_link"), for: .normal)
//                    buttonDel.addTarget(self, action: #selector(self.btnEditAction(_:)), for: .touchUpInside)
//                    let btnEdit = UIBarButtonItem.init(customView: buttonDel)
//                    arrButtons.append(btnEdit)
//                }
                
                if selected.isDelete == true {
                    arrButtons.append(btnDelete)
                }
                self.navigationItem.setRightBarButtonItems(arrButtons, animated: true)
            }else{
                var arrButtons = [UIBarButtonItem]()
                arrButtons.append(btnDelete)
            }
        }
        self.navigationItem.setRightBarButtonItems(arrButtons, animated: true)
    }
    
    
    @objc func swipeGestureAction(gesture : UISwipeGestureRecognizer){
        if gesture.direction == .up ||  gesture.direction == .down {
            self.animateView()
        }
    }
    
    func preparePreview(index:Int) {
        
        if ContentList.sharedInstance.objStream != nil {
            self.btnDone.isHidden = true
        }
        self.btnShareAction.isHidden = true
        self.txtTitleImage.text = ""
        txtDescription.text = ""
        self.selectedIndex = index
        self.imgPreview.contentMode = .scaleAspectFit
        seletedImage =  ContentList.sharedInstance.arrayContent[index]
        if !seletedImage.name.isEmpty {
            var title  = seletedImage.name.trim()
            if seletedImage.name.count > 75 {
                title = seletedImage.name.trim(count: 75)
            }
            self.txtTitleImage.text = title.trim()
        }
        if !seletedImage.description.isEmpty {
            var description  = seletedImage.description.trim()
            if seletedImage.description.count > 250 {
                description = seletedImage.description.trim(count: 250)
            }
            self.txtDescription.text = description
        }
        if seletedImage.type == .image {
            self.btnPlayIcon.isHidden = true
        }else if seletedImage.type == .video {
            self.btnPlayIcon.isHidden = false
        }else {
            self.btnPlayIcon.isHidden = true
        }
        if seletedImage.imgPreview != nil {
            self.imgPreview.image = seletedImage.imgPreview
            seletedImage.imgPreview?.getColors({ (colors) in
                self.imgPreview.backgroundColor = colors.primary
                self.txtTitleImage.textColor = .white//colors.secondary
                self.txtDescription.textColor = .white//colors.secondary
                self.txtTitleImage.placeholderColor(text:"Title",color: .white)//colors.secondary
            })
        }else {
            if seletedImage.type == .image  || seletedImage.type == .notes {
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImage, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgPreview.backgroundColor = colors.primary
                        self.txtTitleImage.textColor = .white//colors.secondary
                        self.txtDescription.textColor = .white//colors.secondary
                        self.txtTitleImage.placeholderColor(text:"Title",color: .white)//colors.secondary
                    })
                })
                
                if seletedImage.name == "SharedImage_group.com.emogotechnologiesinc.thoughtstream" {
//                   // print("image from Share - Extension")
//                    let img = UIImage(data: (UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")?.value(forKey: "imageObj") as! Data))
//                    self.imgPreview.image   =   img
//                    seletedImage.imgPreview =   img
//                    seletedImage.name       =   ""
//                    self.txtTitleImage.text = ""
//                    self.txtDescription.text    =   ""
//
//                    UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")?.set(nil, forKey: "imageObj")
//                    UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")?.synchronize()
                }else{
                    self.imgPreview.setForAnimatedImage(strImage: seletedImage.coverImage) { (_) in
                        
                    }
                    //self.imgPreview.setForAnimatedImage(strImage:seletedImage.coverImage)
                }
                
            }else {
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    image?.getColors({ (colors) in
                        self.imgPreview.backgroundColor = colors.primary
                        self.txtTitleImage.textColor = .white//colors.secondary
                        self.txtDescription.textColor = .white//colors.secondary
                        self.txtTitleImage.placeholderColor(text:"Title",color: .white)//colors.secondary
                    })
                })
                self.imgPreview.setForAnimatedImage(strImage: seletedImage.coverImageVideo.trim()) { (_) in
                    
                } //self.imgPreview.setForAnimatedImage(strImage:seletedImage.coverImageVideo.trim())
            }
        }
        self.txtTitleImage.isUserInteractionEnabled = true
        self.txtDescription.isUserInteractionEnabled = true
        self.txtTitleImage.isHidden = false
        self.txtDescription.isHidden = false
        if seletedImage.isUploaded {
           
            self.txtTitleImage.isUserInteractionEnabled = false
            self.txtDescription.isUserInteractionEnabled = false
            
            if seletedImage.name.trim().isEmpty {
                self.txtTitleImage.isHidden = true
            }
            if seletedImage.description.trim().isEmpty {
                self.txtDescription.isHidden = true
            }
        }
       
        self.changeButtonAccordingSwipe(selected: seletedImage)
        viewLinkPreview.isHidden = true
         kLinkPreviewHieght.constant = 0.0
        if self.seletedImage.type == .link {
            if !self.seletedImage.coverImage.isEmpty {
                self.smartURLFetchData()
            }
        }
        if self.seletedImage.type == .notes {
            self.txtTitleImage.isHidden = true
            self.txtDescription.isHidden = true
        }
        if self.seletedImage.isUploaded {
            
            self.btnShareAction.isHidden = true
            self.btnDone.isHidden = true
        }else {
            self.btnAddStream.isHidden = false
            self.btnDone.isHidden = false
        }
        if  self.seletedImage.type == .link {
            self.btnShareAction.isHidden = false
        }
       
        if self.seletedImage.type == .link && self.seletedImage.isUploaded && self.seletedImage.imgPreview != nil {
            self.btnDone.isHidden = false
            self.btnAddStream.isHidden = true
        }
        
      
     }
    
    
    func hideControls(isHide:Bool) {
        
    }
    
    func resetLayout(){
        self.imgPreview.image = nil
        self.txtTitleImage.text = ""
        self.txtDescription.text = ""
    }
    
    // MARK: -  Action Methods And Selector
    
   @objc func btnBack() {
    if self.isFromNotes != nil{
        if self.isFromNotes == "Stream"{
            let controller = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
            self.navigationController?.popToViewController(vc: controller)
        }else if isFromNotes == "StreamView" {
            let controller = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream)
            self.navigationController?.popToViewController(vc: controller)
        }else if isFromNotes == "Profile" {
            let controller = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView)
            self.navigationController?.popToViewController(vc: controller)
        }else {
            self.navigationController?.popNormal()
        }
        return
    }
        if self.strPresented == nil {
            self.imgPreview.image = nil
            self.navigationController?.popNormal()
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        if self.strPresented == nil {
            self.imgPreview.image = nil
            self.navigationController?.popNormal()
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func linkPrevewAction(_ sender: Any) {
        if seletedImage.type == .link {
            guard let url = URL(string: seletedImage.coverImage) else {
                return //be safe
            }
            self.openURL(url: url)
        }
    }
    @IBAction func btnAddMoreAction(_ sender: Any) {
        
        kDefault?.removeObject(forKey: kRetakeIndex)
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        self.navigationController?.popToViewController(vc: obj)
      
    }
    @IBAction func btnEditAction(_ sender: Any) {
        if   ContentList.sharedInstance.arrayContent.count != 0 {
            if seletedImage.type == .image {
                if self.seletedImage.imgPreview == nil {
                    HUDManager.sharedInstance.showHUD()
                    SharedData.sharedInstance.downloadImage(url: seletedImage.coverImage, handler: { (image) in
                        HUDManager.sharedInstance.hideHUD()
                        if image != nil {
                            self.openEditor(image:image!)
                        }
                    })
                    
                }else {
                    self.openEditor(image:seletedImage.imgPreview!)
                }
            }else if seletedImage.type == .link {
                HUDManager.sharedInstance.showHUD()
                SharedData.sharedInstance.downloadImage(url: seletedImage.coverImageVideo, handler: { (image) in
                    HUDManager.sharedInstance.hideHUD()
                    if image != nil {
                        self.openEditor(image:image!)
                    }
                })
              
            }else if seletedImage.type == .video {
                AppDelegate.appDelegate.keyboardResign(isActive: false)
                let objVideoEditor:VideoEditorViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_VideoEditorView) as! VideoEditorViewController
                  if self.seletedImage.isUploaded == false{
                      objVideoEditor.isEdit = true
                   }
                objVideoEditor.delegate = self
                objVideoEditor.seletedImage = self.seletedImage
                self.navigationController?.pushAsPresent(viewController: objVideoEditor)
            }else if seletedImage.type == .notes{
                let controller:CreateNotesViewController = kStoryboardPhotoEditor.instantiateViewController(withIdentifier: kStoryboardID_CreateNotesView) as! CreateNotesViewController
                controller.contentDAO = self.seletedImage
                controller.isOpenFrom = "Preview"
                controller.delegate = self
                self.navigationController?.pushNormal(viewController: controller)
            }else {
                self.openEditor(image:imgPreview.image!)
            }
        }else {
            self.showToast(type: .error, strMSG: kAlert_Edit_Image)
        }
    }
    @IBAction func btnActionShare(_ sender: Any) {
        self.isEditingContent = true
           let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        kDefault?.set(self.selectedIndex, forKey: kRetakeIndex)
        self.navigationController?.popToViewController(vc: obj)
    }
    @IBAction func btnActionAddStream(_ sender: Any) {
        self.view.endEditing(true)
        btnDone.isUserInteractionEnabled = false
        if ContentList.sharedInstance.arrayContent.count > 10 {
            self.alertForLimit()
            return
        }
        
        if ContentList.sharedInstance.objStream != nil {
            if ContentList.sharedInstance.arrayContent.count != 0 {
                HUDManager.sharedInstance.showProgress()
                let array = ContentList.sharedInstance.arrayContent
                AWSRequestManager.sharedInstance.associateContentToStream(streamID: [(ContentList.sharedInstance.objStream)!], contents: array!, completion: { (isScuccess, errorMSG) in
                    HUDManager.sharedInstance.hideProgress()
                    if (errorMSG?.isEmpty)! {
                    }
                })
                ContentList.sharedInstance.arrayContent.removeAll()
                self.resetLayout()
                self.previewCollection.reloadData()
                let when = DispatchTime.now() + 1.5
                DispatchQueue.main.asyncAfter(deadline: when) {
                    // Back Screen
                    if kNavForProfile.isEmpty {
                        let obj = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_viewStream)
                        obj.title = currentStreamType.rawValue
                        //                    obj.streamType
                        self.navigationController?.popToViewController(vc: obj)
                    }else {
                        kNavForProfile = ""
                        let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView)
                        self.navigationController?.popToViewController(vc: obj)
                    }
                    
                }
            }
        }else {
            // Navigate to View Stream
            addContentToStream()
        }
        
    }
    @IBAction func btnDoneAction(_ sender: Any) {
        self.view.endEditing(true)
        btnAddStream.isUserInteractionEnabled = false
        if self.seletedImage.type == .link && self.seletedImage.isUploaded && self.seletedImage.imgPreview != nil {
            self.uploadFile()
            return
        }
        
        if ContentList.sharedInstance.arrayContent.count != 0 {
            let array = ContentList.sharedInstance.arrayContent.filter { $0.isUploaded == false }
            if array.count != 0 {
                HUDManager.sharedInstance.showProgress()
                let arrayC = [String]()
                AWSRequestManager.sharedInstance.startContentUpload(StreamID: arrayC, array: array)
            }
        
            self.imgPreview.image = nil
            self.resetLayout()
            ContentList.sharedInstance.arrayContent.removeAll()
            self.previewCollection.reloadData()
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                if kNavForProfile.isEmpty {
                    let objStream = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_StreamListView)
                    
                    self.navigationController?.popToViewController(vc: objStream)
                }else {
                    kNavForProfile = ""
                    let obj = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_ProfileView)
                    self.navigationController?.popToViewController(vc: obj)
                }
            }
        }
        
    }
    @IBAction func btnAnimateViewAction(_ sender: Any) {
        self.animateView()
    }
    @IBAction func btnPlayAction(_ sender: Any) {
        self.openFullView()
    }
    
    @IBAction func btnGalleryAction(_ sender: Any) {
        self.openGallery()
    }
    @IBAction func btnCameraAction(_ sender: Any) {
        kDefault?.removeObject(forKey: kRetakeIndex)
        let obj:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        self.navigationController?.popToViewController(vc: obj)
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            
            let alert = UIAlertController(title: kAlert_Title_Confirmation, message: kAlert_Delete_Content_Msg, preferredStyle: .alert)
            let yes = UIAlertAction(title: kAlertTitle_Yes, style: .default) { (action) in
                self.deleteSelectedContent()
            }
            let no = UIAlertAction(title: kAlertTitle_No, style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(yes)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        }
    }
    @objc func playIconTapped(sender:UIButton) {
        self.preparePreview(index: sender.tag)
    }
    
    // MARK: - Class Methods
    
    func deleteSelectedContent(){
        
        if self.seletedImage.isUploaded {
            if let index =  arraySelectedContent?.index(where: {$0.contentID.trim() == seletedImage.contentID.trim()}) {
                arraySelectedContent?.remove(at: index)
            }
            
            if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == seletedImage.contentID.trim()}) {
                ContentList.sharedInstance.arrayContent.remove(at: index)
            }
            
        }else {
            
            if self.seletedImage.type == .gif {
                
                if let index =  arraySelectedContent?.index(where: {$0.coverImage.trim() == self.seletedImage.coverImage.trim()}) {
                    arraySelectedContent?.remove(at: index)
                }
                
                if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.coverImage.trim() == seletedImage.coverImage.trim()}) {
                    ContentList.sharedInstance.arrayContent.remove(at: index)
                }
                
            }else {
                if let index =  arrayAssests?.index(where: {$0.name.lowercased().trim() == seletedImage.fileName.lowercased().trim()}) {
                    arrayAssests?.remove(at: index)
                }
                
                if let index =  arraySelectedContent?.index(where: {$0.fileName.trim() == self.seletedImage.fileName.trim()}) {
                    arraySelectedContent?.remove(at: index)
                }
                
                if let index =  ContentList.sharedInstance.arrayContent.index(where: {$0.fileName.trim() == seletedImage.fileName.trim()}) {
                    ContentList.sharedInstance.arrayContent.remove(at: index)
                }
                
            }
        }
        
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            self.preparePreview(index: 0)
        }else{
            arrayAssests?.removeAll()
            arraySelectedContent?.removeAll()
            if self.strPresented == nil {
                self.navigationController?.popNormal()
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.previewCollection.reloadData()
    }
    @objc private func animateView(){
        UIView.animate(withDuration: 0.5) {
            self.isPreviewOpen = !self.isPreviewOpen
            if self.isPreviewOpen == false {
                // Down icon
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "preview_down_arrow"), for: .normal)
                self.kPreviewHeight.constant = 129.0
                self.imgPreview.contentMode = .scaleAspectFit
                //  kWidthOptions.constant = 0.0
                self.viewOptions.isHidden = false
                self.kWidthOptions.constant = 63.0
                
            }else {
                // Up icon
                self.kPreviewHeight.constant = 24.0
                self.btnPreviewOpen.setImage(#imageLiteral(resourceName: "white_up_arrow"), for: .normal)
                self.imgPreview.contentMode = .scaleAspectFit
                self.kWidthOptions.constant = 0.0
                self.viewOptions.isHidden = true
                
            }
            self.view.updateConstraintsIfNeeded()
            //   self.imgPreview.image =  GalleryDAO.sharedInstance.Images[self.selectedIndex].imgPreview.resizeImage(targetSize: CGSize(width: self.imgPreview.bounds.width * 2.0, height: self.imgPreview.bounds.height * 2.0))
        }
    }
    
    
    private func openEditor(image:UIImage){
        AppDelegate.appDelegate.keyboardResign(isActive: false)
        photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.seletedImage = self.seletedImage
        photoEditor.image = image
        photoEditor.isForEditOnly = false
        //PhotoEditorDelegate
        photoEditor.photoEditorDelegate = self
        photoEditor.hiddenControls = [.share]
        photoEditor.stickers = shapes.shapes
        photoEditor.colors = [.red,.blue,.green, .black, .brown, .cyan, .darkGray, .yellow, .lightGray, .purple , .groupTableViewBackground]
        self.navigationController?.pushAsPresent(viewController: photoEditor)
    }
    
    func setPreviewContent(title:String, description:String) {
        if  ContentList.sharedInstance.arrayContent.count != 0 {
            seletedImage.name = title
            seletedImage.description = description
            ContentList.sharedInstance.arrayContent[selectedIndex] = seletedImage
        }
    }
    
    func shareSticker(){
        if MFMessageComposeViewController.canSendAttachments(){
            let composeVC = MFMessageComposeViewController()
            composeVC.recipients = []
            composeVC.message = composeMessage()
            composeVC.messageComposeDelegate = self
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    func composeMessage() -> MSMessage {
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        
        layout.caption = txtTitleImage.text!
        layout.image  = imgPreview.image?.fixOrientation()
        layout.subcaption = txtDescription.text
        let content = self.seletedImage
        message.layout = layout
        if ContentList.sharedInstance.objStream == nil {
            let strURl = kNavigation_Content + "/" + (content?.contentID!)!
            message.url = URL(string: strURl)
        }else {
            let strURl = kNavigation_Content + "/" + (content?.contentID!)! + "/" + ContentList.sharedInstance.objStream!
            message.url = URL(string: strURl)
        }
        
        return message
    }
    
    
    // MARK: - API Method
    
    func uploadFile(){
        // Create a object array to upload file to AWS
            if  seletedImage.type == .link {
                HUDManager.sharedInstance.showHUD()
                AWSRequestManager.sharedInstance.imageUpload(image: seletedImage.imgPreview!, name: seletedImage.fileName!, completion: { (fileURL, error) in
                    if let fileURL = fileURL {
                        DispatchQueue.main.async {
                             self.updateContent(coverImage: self.seletedImage.coverImage, coverVideo: fileURL, type: self.seletedImage.type.rawValue, width: Int((self.seletedImage.imgPreview?.size.width)!), height: Int((self.seletedImage.imgPreview?.size.height)!))
                        }
                       
                    }else {
                        HUDManager.sharedInstance.hideHUD()
                    }
                    
                })
            }
    }
    
    func addContent(fileUrl:String,type:String,fileUrlVideo:String){
        APIServiceManager.sharedInstance.apiForCreateContent(contentName: (txtTitleImage.text?.trim())!, contentDescription: (txtDescription.text?.trim())!, coverImage: fileUrl,coverImageVideo:fileUrlVideo, coverType: type,width:0,height:0) { (contents, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                if !self.isContentAdded {
                    self.showToast(type: .success, strMSG: kAlert_Content_Added)
                }
                self.modifyObjects(contents: contents!)
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func updateContent(coverImage:String,coverVideo:String, type:String,width:Int,height:Int){
        APIServiceManager.sharedInstance.apiForEditContent(contentID: self.seletedImage.contentID, contentName: (txtTitleImage.text?.trim())!, contentDescription: txtDescription.text!, coverImage: coverImage, coverImageVideo: coverVideo, coverType: type, width: width, height: height) { (content, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                
                if let index =   ContentList.sharedInstance.arrayContent.index(where: {$0.contentID.trim() == content?.contentID.trim()}) {
                    self.seletedImage = content
                    ContentList.sharedInstance.arrayContent[index] = content!
                }
                self.btnAddStream.isHidden = false
                self.btnAddStream.isUserInteractionEnabled = true
                self.btnDone.isHidden = true
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    
    func modifyObjects(contents:[ContentDAO]){
        
        if contents.count != 0 {
            self.seletedImage = contents[0]
            ContentList.sharedInstance.arrayContent[selectedIndex] = seletedImage
            self.preparePreview(index: selectedIndex)
        }
        
        if self.isContentAdded {
            self.addContentToStream()
        }
    }
    
    func addContentToStream(){
        let obj:MyStreamViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_MyStreamView) as! MyStreamViewController
        self.navigationController?.push(viewController: obj)
    }
    
    func deleteContent(){
        HUDManager.sharedInstance.showHUD()
        let content = [seletedImage.contentID.trim()]
        APIServiceManager.sharedInstance.apiForDeleteContent(contents: content) { (isSuccess, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if isSuccess == true {
                ContentList.sharedInstance.arrayContent.remove(at: self.selectedIndex)
                if  ContentList.sharedInstance.arrayContent.count != 0 {
                    self.preparePreview(index: 0)
                }else{
                    self.navigationController?.pop()
                }
                self.previewCollection.reloadData()
            }else {
                self.showToast(strMSG: errorMsg!)
            }
        }
    }
    
    func alertForLimit(){
        let alert = UIAlertController(title: kAlert_Capture_Title, message: kAlert_Capture_Limit_Exceeded, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: kAlert_Confirmation_Button_Title, style: .default) { (action) in
        }
        
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
    }
    
    func associateContent() {
        
        //        if ContentList.sharedInstance.objStream != nil && contents.count != 0{
        //            AWSRequestManager.sharedInstance.associateContentToStream(streamID: (ContentList.sharedInstance.objStream?.streamID)!, contentID: contents, completion: { (isSuccess, errorMsg) in
        //                if (errorMsg?.isEmpty)! {
        //                self.showToast(strMSG: kAlert_Content_Associated_To_Stream)
        //                }else {
        //                self.showToast(strMSG: errorMsg!)
        //                }
        //            })
        //        }
        
    }
    
    func smartURLFetchData(){
        let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: InMemoryCache.init())
        
        slp.preview(self.seletedImage.coverImage,
                    onSuccess: { result in
                       // print(result)
                        debugPrint(result)
                        if let title = result[SwiftLinkResponseKey.title] {
                            self.lblLinkTitle.text = title as? String
                        }
                        if let url = result[SwiftLinkResponseKey.canonicalUrl] {
                            self.lblURL.text = url as? String
                        }
                        
                        if let description = result[SwiftLinkResponseKey.description] {
                            self.lblLinkDescription.text = description as? String
                        }
                        
                        let imageUrl = result[SwiftLinkResponseKey.image]
                        var imgUrl:String! = ""

                        if let imageUrl = imageUrl {
                            //                                    imgUrl = imageUrl as! String
                            if let arrStr = imageUrl as? [String] {
                                imgUrl = arrStr.first
                            }else if let str = imageUrl as? String {
                                imgUrl = str
                            }
                            
                        }
                        if imgUrl.isEmpty {
                            let imageUrl1 = result[SwiftLinkResponseKey.icon]
                            if let imageUrl = imageUrl1 {
                                imgUrl = imageUrl as! String
                            }
                        }
                        if imgUrl.isEmpty {
                            let imageUrl1 = result[SwiftLinkResponseKey.images]
                            if let imageUrl = imageUrl1 {
                                let arrayImages:[Any] = imageUrl as! [Any]
                                if arrayImages.count != 0 {
                                    imgUrl = arrayImages[0] as! String
                                }
                            }
                        }
                        
                        if imgUrl.isEmpty {
                            let imageUrl1 = result[SwiftLinkResponseKey.finalUrl]
                            let url:String = (imageUrl1 as! URL).absoluteString.trim().slice(from: "?imgurl=", to: "&imgrefurl")!
                            //print(url)
                            imgUrl = url
                        }
                        self.kLinkLogoWidth.constant = 120.0
                        self.kLinkPreviewHieght.constant = 120.0
                        self.viewLinkPreview.isHidden = false
                        
                        if imgUrl.isEmpty {
                            self.kLinkLogoWidth.constant = 0.0
                        }
                       // self.imgLogo.setForAnimatedImage(strImage: imgUrl)
                        self.imgLogo.setForAnimatedImage(strImage: imgUrl) { (_) in
                            
                        }
                      
        },
                    onError: {
                        
                        error in print("\(error)")
                         self.kLinkPreviewHieght.constant = 0.0
                        self.viewLinkPreview.isHidden = true
        })
        
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
