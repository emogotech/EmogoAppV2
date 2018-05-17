//
//  VideoEditorViewController.swift
//  Emogo
//
//  Created by Pushpendra on 15/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import BMPlayer
import PryntTrimmerView
import AVFoundation

enum VideoEditorFeature {
    case trimer
    case resolution
    case sticker
    case rate
    case none
}

class VideoEditorViewController: UIViewController {

    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var kTrimmerHeight: NSLayoutConstraint!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    var player = BMPlayer()
    var seletedImage:ContentDAO!
    var edgeMenu: DPEdgeMenu?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var fileLocalPath:String! = ""
    var avPlayer: AVPlayer?
    var selectedFeature:VideoEditorFeature! = .none
    var editManager = PMVideoEditor()
    var localFileURl:URL?
    var originalFile:String! = ""
    var originalFileURl:URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareLayout()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Document.deleteFile(name: self.fileLocalPath.getName())
    }
    
    func prepareLayout(){
        self.kTrimmerHeight.constant = 0.0
        prepareNavigation()
        self.prepareMenu()
         getVideo()
    }
    

    
    func prepareNavigation() {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        let myAttribute2 = [ NSAttributedStringKey.foregroundColor: UIColor.black ,NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.0)]
        
        self.navigationController?.navigationBar.titleTextAttributes = myAttribute2
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor =  UIColor.black.withAlphaComponent(0.7)

        self.configureNavigationButtons()
    }
    
    func prepareMenu(){
        
        let btnTrim = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnTrim.setImage(#imageLiteral(resourceName: "trim_icon"), for: .normal)
        btnTrim.setBackgroundImage(#imageLiteral(resourceName: "rectangle_up"), for: .normal)
        btnTrim.tag = 101
        btnTrim.isExclusiveTouch = true
        btnTrim.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnAddText = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnAddText.setImage(#imageLiteral(resourceName: "add_image_icon"), for: .normal)
        btnAddText.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnAddText.tag = 102
        btnAddText.isExclusiveTouch = true
        btnAddText.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnResoultion = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnResoultion.setImage(#imageLiteral(resourceName: "rate_of_video_icon"), for: .normal)
        btnResoultion.setBackgroundImage(#imageLiteral(resourceName: "rectangle_center"), for: .normal)
        btnResoultion.tag = 103
        btnResoultion.isExclusiveTouch = true
        btnResoultion.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        let btnRate = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 52))
        btnRate.setImage(#imageLiteral(resourceName: "rate_of_video") , for: .normal)
        btnRate.setBackgroundImage(#imageLiteral(resourceName: "rectangle_down"), for: .normal)
        btnRate.tag = 104
        btnRate.isExclusiveTouch = true
        btnRate.addTarget(self, action: #selector(self.actionForRightMenu(sender:)), for: .touchUpInside)
        
        self.edgeMenu = DPEdgeMenu(items: [btnTrim, btnAddText, btnResoultion,btnRate],
                                   animationDuration: 0.8, menuPosition: .right)
        guard let edgeMenu = self.edgeMenu else { return }
        edgeMenu.backgroundColor = UIColor.clear
        edgeMenu.itemSpacing = 0.0
        edgeMenu.animationDuration = 0.8
        self.view.addSubview(edgeMenu)
    }
    

    func getVideo(){
        activity.startAnimating()
        activity.isHidden = false
        let strvideo = self.seletedImage.coverImage.trim()
        self.getLocalPath(strURl: strvideo) { (filePath,fileURL) in
            self.fileLocalPath = filePath
            self.localFileURl = fileURL
            self.originalFileURl = fileURL
            self.originalFile = filePath
            self.openPlayer(videoUrl: fileURL!)
            self.activity.stopAnimating()
            self.activity.isHidden = true
        }
    }
    
    
    func configureNavigationButtons(){
        
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        let btnback = UIBarButtonItem(image: #imageLiteral(resourceName: "back_new"), style: .plain, target: self, action: #selector(self.buttonBackAction))
        let imgSave = UIImage(named: "icons8-download")
        let btnSave = UIBarButtonItem(image: imgSave, style: .plain, target: self, action: #selector(self.btnSaveAction))
        self.navigationItem.leftBarButtonItem = btnback
        self.navigationItem.rightBarButtonItem = btnSave
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == false{
            edgeMenu.open()
        }
    }
    
    
    func configureNavigationForEditing(){
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == true {
            edgeMenu.close()
        }
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.btnCancelAction))
        let btnSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.btnApplyFeatureAction))
        self.navigationItem.leftBarButtonItem = btnCancel
        self.navigationItem.rightBarButtonItem = btnSave
        navigationItem.hidesBackButton = true
    }
    
    func removeAllNavButtons(){
        guard let edgeMenu = self.edgeMenu else { return }
        if edgeMenu.opened  == true {
            edgeMenu.close()
        }
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
    }
  
    
    func closePreview(){
        self.kTrimmerHeight.constant = 0.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func openPlayer(videoUrl:URL){
        
        player = BMPlayer()
        let asset = BMPlayerResource(url: videoUrl)
        player.setVideo(resource: asset)
        playerContainerView.addSubview(player)
        player.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.playerContainerView)
            maker.leading.equalTo(self.playerContainerView)
            maker.trailing.equalTo(self.playerContainerView)
            maker.bottom.equalTo(self.playerContainerView)
        }
        // Back button event
        player.backBlock = {  (isFullScreen) in
            if isFullScreen == true { return }
            //let _ = self.navigationController?.popViewController(animated: true)
        }
        player.playStateDidChange = { (isPlaying: Bool) in
            print("playStateDidChange \(isPlaying)")
        }
        
        //Listen to when the play time changes
        player.playTimeDidChange = { (currentTime: TimeInterval, totalTime: TimeInterval) in
            print("playTimeDidChange currentTime: \(currentTime) totalTime: \(totalTime)")
        }
        if !(self.edgeMenu?.opened)! {
            self.edgeMenu?.open()
        }
        
    }
    
    
    
    func getLocalPath(strURl: String,handler:@escaping (_ filePath: String?, _ fileURL:URL?)-> Void){
        APIManager.sharedInstance.download(strFile: strURl) { (filePath,fileURL) in
            if let filePath = filePath {
                handler(filePath,fileURL)
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
