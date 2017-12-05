//
//  StreamContentViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 29/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class StreamContentViewController: MSMessagesAppViewController {

    // MARK:- UI Elements
    @IBOutlet weak var lblStreamTitle : UILabel!
    @IBOutlet weak var btnNextStream : UIButton!
    @IBOutlet weak var btnPreviousStream : UIButton!
    @IBOutlet  weak var contentProgressView : UIProgressView!
    @IBOutlet weak var lblStreamName : UILabel!
    @IBOutlet weak var lblStreamDesc : UILabel!
    
    @IBOutlet weak var imgStream : UIImageView!
    @IBOutlet weak var imgGradient : UIImageView!
    
    @IBOutlet weak var viewAction : UIView!
    @IBOutlet weak var viewAddStream: UIView!

    
    // MARK: - Variables
    var arrStream = [StreamDAO]()
    var arrContentData : NSMutableArray!
    var currentStreamIndex : Int!
    var currentContentIndex : Int!
    
    // MARK: - Life-cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayout()
        requestMessageScreenChangeSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentProgressView.transform = CGAffineTransform(scaleX: 1, y: 3)
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: iMsgNotificationManageScreen), object: nil)
    }
    
    // MARK:- Selector Methods
    @objc func requestMessageScreenChangeSize(){
        if(SharedData.sharedInstance.isMessageWindowExpand == false){
            imgStream.isUserInteractionEnabled = false
            viewAddStream.isHidden = true
        }else{
            imgStream.isUserInteractionEnabled = true
            viewAddStream.isHidden = false
        }
    }
    
    // MARK: - PrepareLayout
    func prepareLayout(){
        
        loadViewForUI()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imgStream.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imgStream.addGestureRecognizer(swipeLeft)
        
        if currentStreamIndex == 0 {
            btnPreviousStream.isEnabled = false
        }
        if currentStreamIndex == arrStream.count-1 {
            btnNextStream.isEnabled = false
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if currentContentIndex !=  arrContentData.count-1 {
                    self.nextContentLoad()
                }
                break
            case UISwipeGestureRecognizerDirection.right:
                if currentContentIndex != 0 {
                    self.previousContentLoad()
                }
                break
            default:
                break
            }
        }
    }
    
    func nextContentLoad() {
        if(currentContentIndex < arrContentData.count-1) {
            currentContentIndex = currentContentIndex + 1
        }
        self.addRightTransitionImage(imgV: self.imgStream)
        loadViewForUI()
    }
    
    func previousContentLoad(){
        if currentContentIndex != 0{
             currentContentIndex = currentContentIndex - 1
        }
        self.addLeftTransitionImage(imgV: self.imgStream)
        loadViewForUI()
    }
    
    //MARK: - Load Data in UI
    func loadViewForUI(){
        let stream = self.arrStream[currentStreamIndex]
        self.lblStreamTitle.text = stream.Title
        
        let tempDict = self.arrContentData.object(at: currentContentIndex) as! NSMutableDictionary
        debugPrint(tempDict)
        imgStream.image = UIImage(named: tempDict.object(forKey: "img") as! String)
        lblStreamName.text = tempDict.object(forKey: "titleName") as? String
        lblStreamDesc.text = (tempDict.object(forKey: "titleDescription") as! String)
        
        let currenProgressValue = Float(currentContentIndex)/Float(arrContentData.count-1)
        contentProgressView.setProgress(currenProgressValue, animated: true)
    }
    
    //MARK: - Enable/Disable - Next/Previous Button
    func btnEnableDisable() {
        if currentStreamIndex ==  0 {
            btnPreviousStream.isEnabled = false
        }
        else {
            btnPreviousStream.isEnabled = true
        }
        if currentStreamIndex ==  arrStream.count-1 {
            btnNextStream.isEnabled = false
        }
        else {
            btnNextStream.isEnabled = true
        }
    }
    
    //MARK: - Action Methods
    @IBAction func btnNextStreamAction(_ sender:UIButton){
        if(currentStreamIndex < arrStream.count-1) {
            currentStreamIndex = currentStreamIndex + 1
        }
        currentContentIndex = 0
        btnEnableDisable()
        loadViewForUI()
    }
    
    @IBAction func btnPreviousStreamAction(_ sender:UIButton){
        if currentStreamIndex != 0 {
            currentStreamIndex =  currentStreamIndex - 1
        }
        currentContentIndex = 0
        btnEnableDisable()
        loadViewForUI()
    }
    
    @IBAction func btnClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
