//
//  CreateNotesViewController.swift
//  Emogo
//
//  Created by Pushpendra on 05/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import RichEditorView

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

    var isCommandTapped:Bool! = false

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
        configureNaviationBar()
    }
    func configureNaviationBar(){
        //0,122,255
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor(r: 0, g: 122, b: 255)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        let rightButon = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(self.doneButtonAction))
        navigationItem.rightBarButtonItem  = rightButon
        editorView.inputAccessoryView = self.prepareToolBar()

    }
    
    func prepareToolBar() -> UIToolbar{
        
      let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: kFrame.size.width, height: 50))
        var barButtons = [UIBarButtonItem]()
        // Options
        
        let btnColor = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnColor.setImage(#imageLiteral(resourceName: "color_box_active"), for: .normal)
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
        btnPhoto.setImage(#imageLiteral(resourceName: "photo_video_active"), for: .normal)
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
        return toolbar
    }
    
    @objc func doneButtonAction(){
         let image = self.editorView.toImage()
        let name = NSUUID().uuidString + ".png"
         let content = ContentDAO(contentData: [:])
         content.imgPreview = image
        content.type = PreviewType.notes
        content.isUploaded = false
        content.fileName  = name
        ContentList.sharedInstance.arrayContent.removeAll()
        ContentList.sharedInstance.arrayContent.insert(content, at: 0)
        let objPreview:PreviewController = kStoryboardMain.instantiateViewController(withIdentifier: kStoryboardID_PreView) as! PreviewController
        objPreview.isShowRetake = false
        objPreview.selectedIndex = 0
        self.navigationController?.pushNormal(viewController: objPreview)
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
        
    }
    func richEditorTookFocus(_ editor: RichEditorView) {
        self.viewContainer.isHidden = true
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

extension CreateNotesViewController:ColorPickerViewDelegate {
    func selectedBackgroundColor(color: UIColor) {
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.setTextBackgroundColor(color)
    }
    
    func selectedTextColor(color: UIColor) {
        _ =  self.editorView.becomeFirstResponder()
        self.editorView.setTextColor(color)
    }
    
    
}

extension CreateNotesViewController:CustomCameraViewControllerDelegate {
    func dismissWith(image: UIImage?) {
        if let img = image {
            self.uploadImage(image: img)
        }
    }
}

