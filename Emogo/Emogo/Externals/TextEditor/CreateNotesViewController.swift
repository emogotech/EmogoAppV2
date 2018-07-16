//
//  CreateNotesViewController.swift
//  Emogo
//
//  Created by Pushpendra on 05/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import RichEditorView

protocol CreateNotesViewControllerDelegate {
    func updatedNotes(content:ContentDAO)
}

class CreateNotesViewController: UIViewController {

    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var linkContainerView: UIView!
    @IBOutlet var viewPreview: UIView!
    @IBOutlet var lblPreviewLink: UILabel!
    @IBOutlet var txtURL: UITextView!
    @IBOutlet var viewURL: UIView!
    @IBOutlet var txtURLTitle: UITextField!
    @IBOutlet var kPreviewHeight: NSLayoutConstraint!


    var isCommandTapped:Bool! = false
    var isLinkSelected:Bool! = false

    var contentDAO:ContentDAO?
    var delegate:CreateNotesViewControllerDelegate?
    var isOpenFrom:String?
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        
        return toolbar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayout(){
        prepareEditiorView()
        self.viewContainer.isHidden = true
        if let content = contentDAO {
            self.editorView.html = content.description
          _ = self.editorView.becomeFirstResponder()
            self.editorView.focus()
        }
    }
    
    
    func configureNaviationBar(){
        //0,122,255
        self.title = nil
        self.navigationItem.hidesBackButton = true
        let imgP = UIImage(named: "back_icon_stream")
        let btnback = UIBarButtonItem(image: imgP, style: .plain, target: self, action: #selector(self.backButtonAction))
        self.navigationItem.leftBarButtonItem = btnback
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor(r: 0, g: 122, b: 255)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        let rightButon = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(self.doneButtonAction))
         navigationItem.rightBarButtonItem  = rightButon
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNaviationBar()
    }
    
    func prepareEditiorView(){
        editorView.delegate = self
        // editorView.inputAccessoryView = toolbar
        editorView.placeholder = "TYPE SOMETHING"
        editorView.inputAccessoryView = toolbar
        toolbar.delegate = self
        toolbar.editor = editorView
        self.editorView.isScrollEnabled = true
        prepareToolBar()
    
        UITextField.appearance().keyboardAppearance = .dark
    }
    
    
    func prepareToolBar(){
        var options = toolbar.options

        let blank = RichEditorOptionItem(image: nil, title: "") { (toolbar) in
        }
        options.append(blank)

        let itemText = RichEditorOptionItem(image: #imageLiteral(resourceName: "icon_sentence"), title: "") { (toolbar) in
          
            self.view.endEditing(true)
            let textView = TextEditorView.instanceFromNib()
            textView.delegate = self
            self.presentView(view: textView)
            self.viewContainer.isHidden = false
        }
        options.append(itemText)
        
        let itemOrder = RichEditorOptionItem(image: #imageLiteral(resourceName: "numberBullet-icon"), title: "") { (toolbar) in
            
            toolbar.editor?.orderedList()
        }
        
        options.append(itemOrder)

        let itemBullet = RichEditorOptionItem(image: #imageLiteral(resourceName: "icon_list"), title: "") { (toolbar) in
           
            toolbar.editor?.unorderedList()
        }
        options.append(itemBullet)

        
        let itemHorizontal = RichEditorOptionItem(image: #imageLiteral(resourceName: "horizontal"), title: "") { (toolbar) in
            let  value = toolbar.editor?.contentHTML
           // editorView.html = value + "<div>nbsp<hr/></div>"
            toolbar.editor?.placeholder = ""
            toolbar.editor?.html = value! + "<br><div><hr/></div>"
            toolbar.editor?.focus()
        }
        options.append(itemHorizontal)

        
        let itemPhoto = RichEditorOptionItem(image: #imageLiteral(resourceName: "photo_video"), title: "") { (toolbar) in
            self.openCamera()
        }
        options.append(itemPhoto)

        let itemLink = RichEditorOptionItem(image: #imageLiteral(resourceName: "link_block"), title: "") { (toolbar) in
            self.isLinkSelected = true
            self.view.endEditing(true)
            self.showLinkView()
        }
        options.append(itemLink)

        let itemColor = RichEditorOptionItem(image: #imageLiteral(resourceName: "color_box"), title: "") { (toolbar) in
           
            self.view.endEditing(true)
            let colorPicker = ColorPickerView.instanceFromNib()
            colorPicker.delegate = self
            self.presentView(view: colorPicker)
            DispatchQueue.main.async {
                colorPicker.prepareView()
            }
            self.viewContainer.isHidden = false
            
        }
        options.append(itemColor)

        
        toolbar.options = options
    }
    
    @objc func backButtonAction(){
        self.navigationController?.pop()
    }
    
    @objc func doneButtonAction(){
        if isLinkSelected {
            if (self.txtURLTitle.text?.trim().isEmpty)! {
                return
            }else if (self.txtURL.text?.trim().isEmpty)! {
                return
            }
            
               isLinkSelected = false
                _ =  self.editorView.becomeFirstResponder()
                let  value = editorView.contentHTML
              var strTitle:String = (txtURLTitle.text?.trim())!
              if strTitle.isEmpty {
                  strTitle = self.txtURL.text
              }
                editorView.html = value + "<a href=\(self.txtURL.text)>\(strTitle)</a>"
                  self.editorView.focus()
               // self.editorView.insertLink(url.absoluteString, title: "AttachmentURL")
               // self.editorView.focus()
                self.linkContainerView.isHidden = true
        }else {
            self.view.endEditing(true)
            if self.editorView.contentHTML.isEmpty || self.editorView.text.trim().isEmpty {
                self.showAlert(strMessage: "Unable to save blank note.")
                return
            }
           
            HUDManager.sharedInstance.showHUD()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let name = NSUUID().uuidString + ".png"
                let image = self.editorView.toImage()
                AWSRequestManager.sharedInstance.imageUpload(image: image, name: name, isContent: true, completion: { (fileURL, errorMSG) in
                    if let fileURL = fileURL {
                        if self.contentDAO == nil {
                            self.createContentAPI(imageURl: fileURL, width: Int(image.size.width), height: Int(image.size.height))
                        }else {
                            self.updateContent(coverImage: fileURL, width: Int(image.size.width), height: Int(image.size.height))
                        }
                        
                    }else {
                        HUDManager.sharedInstance.hideHUD()
                    }
                })
            }
            }
           
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewContainer.layer.borderWidth = 1.0
        self.viewContainer.layer.borderColor = UIColor(r: 74, g: 74, b: 74).cgColor
    }

    
    @IBAction func btnActionForCommand(_ sender: Any) {
//        isCommandTapped = !isCommandTapped
//        if isCommandTapped {
//        //    self.viewEditOption.isHidden = false
//            self.setView(hidden: false)
//            self.btnCommand.setImage(#imageLiteral(resourceName: "icons8-multiply"), for: .normal)
//        }else {
//          //  self.viewEditOption.isHidden = true
//            self.setView(hidden: true)
//            self.btnCommand.setImage(#imageLiteral(resourceName: "icons8-command"), for: .normal)
//        }
    }
    
    
    func btnActionForEditOptions(_ tag: Int) {
        self.linkContainerView.isHidden = true
        isLinkSelected = false
        switch tag {
        case 101:
            self.view.endEditing(true)
            let textView = TextEditorView.instanceFromNib()
            textView.delegate = self
            self.presentView(view: textView)
            DispatchQueue.main.async {
                //  colorPicker.prepareView()
            }
            viewContainer.isHidden = false
            break
        case 102:
           
            self.editorView.orderedList()
            break
        case 103:
            let  value = editorView.contentHTML
          //  print(value)
            editorView.html = value + "<div>nbsp<hr/></div>"
            //editorView.html = value + "<div>nbsp<hr/><br></div>"
            editorView.placeholder = ""
           // self.editorView.focus()
            break
        case 104:
           
            openCamera()
            break
        case 105:
           
            isLinkSelected = true
            self.showLinkView()
            break
        case 106:
            self.view.endEditing(true)
           
            let colorPicker = ColorPickerView.instanceFromNib()
            colorPicker.delegate = self
            self.presentView(view: colorPicker)
            DispatchQueue.main.async {
                colorPicker.prepareView()
            }
            self.viewContainer.isHidden = false
            break
        case 107:
                self.editorView.unorderedList()
            break
        default:
            break
        }
    }
    
    func showLinkView(){
        let linkView = LinkPickerView.instanceFromNib()
        linkView.delegate = self
        self.presentView(view: linkView)
        self.linkContainerView.isHidden = false
        if let myString = UIPasteboard.general.string {
            var URL:String! = ""
            
            let linkDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = linkDetector?.matches(in: myString, options: [], range: NSRange(location: 0, length: myString.count))
            for match: NSTextCheckingResult? in matches ?? [NSTextCheckingResult?]() {
                if match?.resultType == .link {
                    let url: URL? = match?.url
                    if let anUrl = url {
                        print("found URL: \(anUrl)")
                        URL = anUrl.absoluteString
                    }
                }
            }
            
            if !URL.isEmpty {
                lblPreviewLink.text = URL
                self.viewPreview.isHidden = false
                self.kPreviewHeight.constant = 62.0
            }else {
                self.viewPreview.isHidden = true
                self.kPreviewHeight.constant = 0.0
            }
        }else {
            self.viewPreview.isHidden = true
            self.kPreviewHeight.constant = 0.0
        }
        viewPreview.layer.borderWidth = 1.0
        viewPreview.layer.masksToBounds = true
        viewPreview.layer.borderColor = UIColor.lightGray.cgColor
        viewPreview.layer.cornerRadius = 10.0
        viewURL.layer.borderWidth = 1.0
        viewURL.layer.borderColor = UIColor.lightGray.cgColor
        viewURL.layer.cornerRadius = 10.0
        viewURL.layer.masksToBounds = true
    }
    
    func addView() -> UIView {
        if let viewWithTag = self.view.viewWithTag(43934398) {
            viewWithTag.removeFromSuperview()
        }
        let Y = self.editorView.frame.size.height + 50
       // print(Y)
        print(self.view.frame)
        let H = self.view.frame.size.height - (self.editorView.frame.size.height + 50)
        let  tempView = UIView(frame: CGRect(x: 0, y: Y, width: self.view.frame.size.width, height:H))
        tempView.backgroundColor = UIColor.red
        //   tempView.layer.zPosition = CGFloat(MAXFLOAT)
        tempView.tag = 43934398
        UIApplication.shared.keyWindow?.addSubview(tempView)
        return tempView
    }
    
    func presentView(view: UIView) {
        // Remove any child view controllers that have been presented.
        view.translatesAutoresizingMaskIntoConstraints = false
        for subview in viewContainer.subviews {
            subview.removeFromSuperview()
        }
        viewContainer.addSubview(view)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: viewContainer.leftAnchor),
            view.rightAnchor.constraint(equalTo: viewContainer.rightAnchor),
            view.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
            ])
        viewContainer.isHidden = false
    }

    func openCamera(){
        let cameraViewController:CustomCameraViewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CustomCameraViewController
        cameraViewController.isDismiss = true
        cameraViewController.delegate = self
        cameraViewController.isForImageOnly = true
        ContentList.sharedInstance.arrayContent.removeAll()
        let nav = UINavigationController(rootViewController: cameraViewController)
        self.present(nav, animated: true, completion: nil)
    }
    
    func uploadImage(image:UIImage){
        let name = NSUUID().uuidString + ".png"
        AWSRequestManager.sharedInstance.imageUpload(image: image.resize(to: CGSize(width: 300, height: 300)), name: name) { (fileURL, errorMSG) in
          
            DispatchQueue.main.async {
                if let fileURL = fileURL {
                    print(fileURL)
                    _ =  self.editorView.becomeFirstResponder()
                    self.editorView.insertImage(fileURL, alt: "attachment")
                }
                HUDManager.sharedInstance.hideHUD()
            }
        }
    }
    
    
    func createContentAPI(imageURl:String,width:Int,height:Int){
        APIServiceManager.sharedInstance.apiForCreateContent(contentName: "", contentDescription: self.editorView.contentHTML, coverImage: imageURl, coverImageVideo: "", coverType: PreviewType.notes.rawValue, width: width, height: height) { (contents, errorMSG) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMSG?.isEmpty)! {
                for obj in contents! {
                    ContentList.sharedInstance.arrayContent.append(obj)
                    let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
                    objPreview.isShowRetake = false
                    objPreview.isFromNotes = self.isOpenFrom
                    self.navigationController?.pushNormal(viewController: objPreview)
                }
            }
        }
    }
    
    
    func updateContent(coverImage:String ,width:Int,height:Int){
        APIServiceManager.sharedInstance.apiForEditContent(contentID: (self.contentDAO?.contentID)!, contentName: "", contentDescription: self.editorView.contentHTML, coverImage: coverImage, coverImageVideo: "", coverType: (self.contentDAO?.type.rawValue)!, width: width, height: height) { (content, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                if ContentList.sharedInstance.objStream != nil {
                    NotificationCenter.default.post(name: NSNotification.Name(kNotification_Update_Image_Cover), object: nil)
                }
                if self.delegate != nil {
                    self.delegate?.updatedNotes(content: content!)
                }
                self.navigationController?.popNormal()
                
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

extension CreateNotesViewController:RichEditorDelegate {
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
        } else {
        }
        print(content)
    }
    func richEditorDidLoad(_ editor: RichEditorView) {
        
    }
    func richEditorLostFocus(_ editor: RichEditorView) {
        print("focus Lost")
    }
    func richEditorTookFocus(_ editor: RichEditorView) {
        self.viewContainer.isHidden = true
        print("focus Recieved")
    }
    
    func richEditor(_ editor: RichEditorView, handle action: String) {
   
    }
    
}
extension CreateNotesViewController:TextEditorViewDelegate {

    func selectFontFamily(family:String){
        self.editorView.setFontFamily(family)
    }

    func selectHeader(tag: Int) {
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.header(tag)
    }
    
    func selectBold() {
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.bold()

    }
    
    func selectItalic() {
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.italic()
    }
    
    func selectUnderline() {
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.underline()
    }
    
    func selectAlignment(alignment: NoteTextAlignment) {
        _ =  self.editorView.becomeFirstResponder()
        switch alignment {
        case .left:
            self.editorView.alignLeft()
            break
        case .center:
            self.editorView.alignCenter()
            break
        case .right:
            self.editorView.alignRight()
            break
        }
    }
    func selectBody(){
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.removeFormat()
        let  value = editorView.contentHTML
        editorView.html = value + "<div><br></div>"
        self.editorView.focus()
    }
}

extension CreateNotesViewController:ColorPickerViewDelegate,LinkPickerViewDelegate {
    func selectedBackgroundColor(color: UIColor) {
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.setTextBackgroundColor(color)
    }
    
    func selectedTextColor(color: UIColor) {
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.setTextColor(color)
    }
    
    func selectedContent(content:ContentDAO){
        _ =  self.editorView.becomeFirstResponder()
        let  value = editorView.contentHTML
        var strTitle:String = content.name
        let url:String = content.coverImage
        if strTitle.isEmpty {
            strTitle = url
        }
        editorView.html = value + "<a href=\(url)>\(strTitle)</a>"
        self.editorView.focus()
        isLinkSelected = false
        self.linkContainerView.isHidden = true
    }

}

extension CreateNotesViewController:CustomCameraViewControllerDelegate {
    func dismissWith(image: UIImage?) {
        if let img = image {
            HUDManager.sharedInstance.showHUD()
            self.uploadImage(image: img)
        }
    }
}


extension CreateNotesViewController:UITextFieldDelegate,UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtURL {
            txtURL.becomeFirstResponder()
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            txtURL.resignFirstResponder()
            return false
        }
        return textView.text.length + (text.length - range.length) <= 250
    }
}

extension CreateNotesViewController: RichEditorToolbarDelegate {
    
}


