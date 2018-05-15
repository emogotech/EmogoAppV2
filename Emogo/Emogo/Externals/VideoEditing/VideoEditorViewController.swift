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

class VideoEditorViewController: UIViewController {

    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var kTrimmerHeight: NSLayoutConstraint!
    var player:BMPlayer?
    var seletedImage:ContentDAO!
    var edgeMenu: DPEdgeMenu?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareLayout()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareLayout(){
        self.kTrimmerHeight.constant = 0.0
        prepareNavigation()
        self.prepareMenu()
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
    
        
    func loadAssest(){
        let file = Bundle.main.path(forResource: "file", ofType: "mp4")
        let videoUrl: URL? = URL(fileURLWithPath: file!)
        guard let url = videoUrl  else {
            return
        }
        let asset = AVAsset(url: url)
        self.trimmerView.delegate = self
        self.trimmerView.asset = asset
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
