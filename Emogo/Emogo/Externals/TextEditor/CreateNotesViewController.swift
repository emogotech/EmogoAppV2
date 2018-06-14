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
    @IBOutlet var btnCommand: UIButton!
    @IBOutlet var btnText: UIButton!
    @IBOutlet var btnHorizontal: UIButton!
    @IBOutlet var btnAlignment: UIButton!
    @IBOutlet var btnPhoto: UIButton!
    @IBOutlet var btnLink: UIButton!
    @IBOutlet var btnColor: UIButton!
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var optionButtons : [UIButton]!
    @IBOutlet var viewEditOptions: UIView!
    @IBOutlet var kWidthConstant: NSLayoutConstraint!
    @IBOutlet var linkContainerView: UIView!
    @IBOutlet var viewPreview: UIView!
    @IBOutlet var kPreviewHeight: NSLayoutConstraint!
    @IBOutlet var lblPreviewLink: UILabel!
    @IBOutlet var txtURL: UITextView!
    @IBOutlet var viewURL: UIView!
    @IBOutlet var txtURLTitle: UITextField!

    var isCommandTapped:Bool! = false
    var isLinkSelected:Bool! = false

    var contentDAO:ContentDAO?
    var delegate:CreateNotesViewControllerDelegate?
    
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
        editorView.delegate = self
        editorView.inputAccessoryView = nil
        self.viewContainer.isHidden = true
        editorView.placeholder = "TYPE SOMETHING"
        btnText.contentMode = .scaleAspectFit
        btnAlignment.contentMode = .scaleAspectFit
        btnHorizontal.contentMode = .scaleAspectFit
        btnPhoto.contentMode = .scaleAspectFit
        btnLink.contentMode = .scaleAspectFit
        btnColor.contentMode = .scaleAspectFit
        if let content = contentDAO {
            self.editorView.html = content.description
        }
    }
    func configureNaviationBar(){
        //0,122,255
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor(r: 0, g: 122, b: 255)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        let rightButon = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(self.doneButtonAction))
         navigationItem.rightBarButtonItem  = rightButon
        self.viewEditOptions.isHidden = false
        if UIDevice.current.modelName.lowercased().contains("iphone 5")  {
            self.viewEditOptions.isHidden = true
            self.kWidthConstant.constant = 0
            editorView.inputAccessoryView = self.prepareToolBar()
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNaviationBar()
    }
    func prepareToolBar() -> UIView{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kFrame.size.width, height: 50.0))
 
       let toolbarScroll = UIScrollView()
       let toolbar = UIToolbar()
       let backgroundToolbar = UIToolbar()
        view.autoresizingMask = .flexibleWidth
        view.backgroundColor = .clear
        backgroundToolbar.frame = view.bounds
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbar.autoresizingMask = .flexibleWidth
        toolbar.backgroundColor = .clear
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbarScroll.frame = view.bounds
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = .clear
        toolbarScroll.addSubview(toolbar)
        view.addSubview(backgroundToolbar)
        view.addSubview(toolbarScroll)
        
        var barButtons = [UIBarButtonItem]()
        
        let btnColor = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnColor.setImage(#imageLiteral(resourceName: "color_box"), for: .normal)
        btnColor.tag  = 106
        btnColor.addTarget(self, action: #selector(self.btnActionForEditOptions(_:)), for: .touchUpInside)
        let colorBtn = UIBarButtonItem(customView: btnColor)
        barButtons.append(colorBtn)
        
        let btnLink = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnLink.setImage(#imageLiteral(resourceName: "link_block"), for: .normal)
        btnLink.tag  = 105
        btnLink.addTarget(self, action: #selector(self.btnActionForEditOptions(_:)), for: .touchUpInside)
        let linkBtn = UIBarButtonItem(customView: btnLink)
        barButtons.append(linkBtn)
        
        let btnPhoto = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnPhoto.setImage(#imageLiteral(resourceName: "photo_video"), for: .normal)
        btnPhoto.tag  = 104
        btnPhoto.addTarget(self, action: #selector(self.btnActionForEditOptions(_:)), for: .touchUpInside)
        let photoBtn = UIBarButtonItem(customView: btnPhoto)
        barButtons.append(photoBtn)
        
        let btnHorizontal = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnHorizontal.setImage(#imageLiteral(resourceName: "horizontal"), for: .normal)
        btnHorizontal.tag  = 103
        btnHorizontal.addTarget(self, action: #selector(self.btnActionForEditOptions(_:)), for: .touchUpInside)
        let horizontalBtn = UIBarButtonItem(customView: btnHorizontal)
        barButtons.append(horizontalBtn)
        
        let btnAlignment = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnAlignment.setImage(#imageLiteral(resourceName: "icon_list"), for: .normal)
        btnAlignment.tag  = 102
        btnAlignment.addTarget(self, action: #selector(self.btnActionForEditOptions(_:)), for: .touchUpInside)
        let allignBtn = UIBarButtonItem(customView: btnAlignment)
        barButtons.append(allignBtn)
        
        let btnNoBullet = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnNoBullet.setImage(#imageLiteral(resourceName: "icon_list"), for: .normal)
        btnNoBullet.tag  = 107
        btnNoBullet.addTarget(self, action: #selector(self.btnActionForEditOptions(_:)), for: .touchUpInside)
        let bulletBtn = UIBarButtonItem(customView: btnNoBullet)
        barButtons.append(bulletBtn)
        
        let btnText = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnText.setImage(#imageLiteral(resourceName: "icon_sentence"), for: .normal)
        btnText.tag  = 101
        btnText.addTarget(self, action: #selector(self.btnActionForEditOptions(_:)), for: .touchUpInside)
        let textBtn = UIBarButtonItem(customView: btnText)
        barButtons.append(textBtn)
        
        toolbar.items = barButtons
        
        let defaultIconWidth: CGFloat = 50
        let barButtonItemMargin: CGFloat = 11
        let width: CGFloat = barButtons.reduce(0) {sofar, new in
            if let tempView = new.value(forKey: "view") as? UIView {
                return sofar + tempView.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < view.frame.size.width {
            toolbar.frame.size.width = view.frame.size.width
        } else {
            toolbar.frame.size.width = width - 45
        }
        toolbar.frame.size.height = 50
        toolbarScroll.contentSize.width = width
        return view
    }
    
    @objc func doneButtonAction(){
        if isLinkSelected {
            if let url = URL(string: self.txtURL.text) {
                _ =  self.editorView.becomeFirstResponder()
                let  value = editorView.contentHTML
                let strTitle:String = (txtURLTitle.text?.trim())!
                editorView.html = value + "<a href=\(url.absoluteString)>\(strTitle)</a>"
                  self.editorView.focus()
               // self.editorView.insertLink(url.absoluteString, title: "AttachmentURL")
               // self.editorView.focus()
                self.linkContainerView.isHidden = true
            }
        }else {
            
            self.view.endEditing(true)
           
            let image = self.editorView.toImage()
            HUDManager.sharedInstance.showHUD()
            let name = NSUUID().uuidString + ".png"
            AWSRequestManager.sharedInstance.imageUpload(image: image, name: name) { (fileURL, errorMSG) in
                
                if let fileURL = fileURL {
                    if self.contentDAO == nil {
                         self.createContentAPI(imageURl: fileURL, width: Int(image.size.width), height: Int(image.size.height))
                    }else {
                        self.updateContent(coverImage: fileURL, width: Int(image.size.width), height: Int(image.size.height))
                    }
                   
                }else {
                    HUDManager.sharedInstance.hideHUD()
                }
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }

    
    @IBAction func btnActionForCommand(_ sender: Any) {
        isCommandTapped = !isCommandTapped
        if isCommandTapped {
        //    self.viewEditOption.isHidden = false
            self.setView(hidden: false)
            self.btnCommand.setImage(#imageLiteral(resourceName: "icons8-multiply"), for: .normal)
        }else {
          //  self.viewEditOption.isHidden = true
            self.setView(hidden: true)
            self.btnCommand.setImage(#imageLiteral(resourceName: "icons8-command"), for: .normal)
        }
    }
    
    
    @IBAction func btnActionForEditOptions(_ sender: UIButton) {
        self.linkContainerView.isHidden = true
        isLinkSelected = false
        switch sender.tag {
        case 101:
            self.view.endEditing(true)
            btnText.isSelected = true
            btnAlignment.isSelected = false
            btnHorizontal.isSelected = false
            btnPhoto.isSelected = false
            btnLink.isSelected = false
            btnColor.isSelected = false
            let textView = TextEditorView.instanceFromNib()
            textView.delegate = self
            self.presentView(view: textView)
            DispatchQueue.main.async {
                //  colorPicker.prepareView()
            }
            viewContainer.isHidden = false
            break
        case 102:
            btnText.isSelected = false
            btnAlignment.isSelected = true
            btnHorizontal.isSelected = false
            btnPhoto.isSelected = false
            btnLink.isSelected = false
            btnColor.isSelected = false
            self.editorView.orderedList()
            break
        case 103:
            btnText.isSelected = false
            btnAlignment.isSelected = false
            btnHorizontal.isSelected = true
            btnPhoto.isSelected = false
            btnLink.isSelected = false
            btnColor.isSelected = false
            let  value = editorView.contentHTML
            print(value)
            editorView.html = value + "<div><hr/><br></div>"
            self.editorView.focus()
            break
        case 104:
            btnText.isSelected = false
            btnAlignment.isSelected = false
            btnHorizontal.isSelected = false
            btnPhoto.isSelected = true
            btnLink.isSelected = false
            btnColor.isSelected = false
            openCamera()
            break
        case 105:
            btnText.isSelected = false
            btnAlignment.isSelected = false
            btnHorizontal.isSelected = false
            btnPhoto.isSelected = false
            btnLink.isSelected = true
            btnColor.isSelected = false
            viewContainer.isHidden = false
            isLinkSelected = true
            self.showLinkView()
            break
        case 106:
            self.view.endEditing(true)
            btnText.isSelected = false
            btnAlignment.isSelected = false
            btnHorizontal.isSelected = false
            btnPhoto.isSelected = false
            btnLink.isSelected = false
            btnColor.isSelected = true
            let colorPicker = ColorPickerView.instanceFromNib()
            colorPicker.delegate = self
            self.presentView(view: colorPicker)
            DispatchQueue.main.async {
                colorPicker.prepareView()
            }
            self.viewContainer.isHidden = false
            break
        case 107:
                btnText.isSelected = false
                btnAlignment.isSelected = true
                btnHorizontal.isSelected = false
                btnPhoto.isSelected = false
                btnLink.isSelected = false
                btnColor.isSelected = false
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
        viewPreview.layer.borderColor = UIColor(r: 74, g: 74, b: 74).cgColor
        viewPreview.layer.cornerRadius = 5.0
        viewURL.layer.borderWidth = 1.0
        viewURL.layer.borderColor = UIColor(r: 74, g: 74, b: 74).cgColor
        viewURL.layer.cornerRadius = 5.0
    }
    
    
    
    func setView(hidden: Bool) {
        for obj in self.optionButtons {
            UIView.transition(with: obj, duration: 0.5, options: .transitionCrossDissolve, animations: {
                obj.isHidden = hidden
            })
        }
    }
    
    
    func addView() -> UIView {
        if let viewWithTag = self.view.viewWithTag(43934398) {
            viewWithTag.removeFromSuperview()
        }
        let Y = self.editorView.frame.size.height + 50
        print(Y)
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
        viewContainer.addSubview(view)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: viewContainer.leftAnchor),
            view.rightAnchor.constraint(equalTo: viewContainer.rightAnchor),
            view.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
            ])
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
            if let fileURL = fileURL { 
                print(fileURL)
                DispatchQueue.main.async {
                    _ =  self.editorView.becomeFirstResponder()
                    self.editorView.insertImage(fileURL, alt: "attachment")
                }
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
                    objPreview.isFromNotes = true
                    self.navigationController?.pushNormal(viewController: objPreview)
                }
            }
        }
    }
    
    
    func updateContent(coverImage:String ,width:Int,height:Int){
        APIServiceManager.sharedInstance.apiForEditContent(contentID: (self.contentDAO?.contentID)!, contentName: "", contentDescription: "", coverImage: coverImage, coverImageVideo: "", coverType: (self.contentDAO?.type.rawValue)!, width: width, height: height) { (content, errorMsg) in
            HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                if self.delegate != nil {
                    self.delegate?.updatedNotes(content: content!)
                }
                self.navigationController?.popViewAsDismiss()
                
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
        
        if self.editorView.hasRangeSelection == true {
            self.editorView.insertLink(content.coverImage, title: content.name)
        }
    }

}

extension CreateNotesViewController:CustomCameraViewControllerDelegate {
    func dismissWith(image: UIImage?) {
        if let img = image {
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


