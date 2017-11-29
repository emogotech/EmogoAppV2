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
    
    @IBOutlet weak var imgStream : UIImageView!

    
    // MARK: -Variables
    var arrStream = [StreamDAO]()
    var arrContentData : NSMutableArray!
    var currentStreamIndex : Int!
    var currentContentIndex : Int!
    
    // MARK: -Life-cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: iMsgNotificationManageScreen), object: nil)
    }

    
    // MARK:- Selector Methods
    @objc func requestMessageScreenChangeSize(){
//        UIView.animate(withDuration: 1.0) {
//             self.perform(#selector(self.changeUI), with: nil, afterDelay: 0.2)
//        }
    }
    
    // MARK: -PrepareLayouy
    func prepareLayout(){
        
        
        let tempDict = self.arrContentData.object(at: currentContentIndex) as! NSMutableDictionary
        imgStream.image = UIImage(named: tempDict.object(forKey: "img") as! String)
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imgStream.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imgStream.addGestureRecognizer(swipeLeft)
        
        let currenProgressValue = Float(currentStreamIndex)/Float(arrContentData.count-1)
        contentProgressView.setProgress(currenProgressValue, animated: false)
        
        if currentStreamIndex == 0 {
            btnPreviousStream.isEnabled = false
        }
        
        if currentStreamIndex == arrStream.count-1 {
            btnNextStream.isEnabled = false
        }
        
        loadViewForUI()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if currentContentIndex !=  arrContentData.count-1 {
                    self.nextImageLoad()
                }
                print("Swiped left")
                break
                
            case UISwipeGestureRecognizerDirection.right:
                if currentContentIndex != 0 {
                    self.previousImageLoad()
                }
                break
                
            default:
                break
            }
        }
    }
    
    func nextImageLoad(){
        if(currentContentIndex < arrContentData.count-1) {
            currentContentIndex = currentContentIndex + 1
        }
        
        loadViewForUI()
        self.addRightTransitionImage(imgV: self.imgStream)
        let tempDict = self.arrContentData.object(at: currentContentIndex) as! NSMutableDictionary
        imgStream.image = UIImage(named: tempDict.object(forKey: "img") as! String)
        let currenProgressValue = Float(currentContentIndex)/Float(arrContentData.count-1)
        self.contentProgressView.setProgress(currenProgressValue, animated: true)
    }
    
    func previousImageLoad(){
        if currentContentIndex != 0{
             currentContentIndex = currentContentIndex - 1
        }
        loadViewForUI()
        self.addLeftTransitionImage(imgV: self.imgStream)
        let tempDict = self.arrContentData.object(at: currentContentIndex) as! NSMutableDictionary
         imgStream.image = UIImage(named: tempDict.object(forKey: "img") as! String)
        let currenProgressValue = Float(currentContentIndex)/Float(arrContentData.count-1)
        self.contentProgressView.setProgress(currenProgressValue, animated: true)
    }
    
    //MARK: -Load Data in UI
    func loadViewForUI(){
        let stream = self.arrStream[currentStreamIndex]
        self.lblStreamTitle.text = stream.title
    }
    
    //MARK: -Enable/Disable - Next/Previous Button
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
    @IBAction func btnNextAction(_ sender:UIButton){
        if(currentStreamIndex < arrStream.count-1) {
            currentStreamIndex = currentStreamIndex + 1
        }
        btnEnableDisable()
        loadViewForUI()
    }
    
    @IBAction func btnPreviousAction(_ sender:UIButton){
        if currentStreamIndex != 0{
            currentStreamIndex =  currentStreamIndex - 1
        }
        btnEnableDisable()
        loadViewForUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


