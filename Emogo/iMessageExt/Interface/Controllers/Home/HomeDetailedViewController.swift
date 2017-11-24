//
//  HomeDetailedViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 23/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class HomeDetailedViewController: MSMessagesAppViewController {

    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnNext : UIButton!
    @IBOutlet weak var btnPreviour : UIButton!
    @IBOutlet weak var lblStreamName : UILabel!
    @IBOutlet weak var lblStreamDesc : UILabel!
    @IBOutlet weak var imgStream : UIImageView!
    
    var arrValues = [StreamDAO]()
    var currentIndex : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentIndex)
        print(arrValues)
        if currentIndex == 0 {
            btnPreviour.isHidden = true
        }
        loadViewForUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loadViewForUI(){
        let stream = self.arrValues[currentIndex]
        self.imgStream.image = stream.imgCover
        self.lblTitle.text = stream.title
        self.lblStreamName.text = stream.title
        self.lblStreamDesc.text = "Posted By Jon"
    }
    
    @IBAction func btnNextTap(_ sender:UIButton){
        
        if(currentIndex < arrValues.count-1) {
             currentIndex = currentIndex + 1
        }
        
        configureAction()
        loadViewForUI()
        addTransition()
    }
    
    @IBAction func btnPreviousTap(_ sender:UIButton){
        if currentIndex != 0{
            currentIndex =  currentIndex - 1
        }
        configureAction()
        loadViewForUI()
        addTransitionLeft()
    }
    
    func configureAction(){
        if currentIndex ==  0 {
            btnPreviour.isHidden = true
        }
        else {
            btnPreviour.isHidden = false
        }
        
        if currentIndex ==  arrValues.count-1 {
            btnNext.isHidden = true
        }
        else {
            btnNext.isHidden = false
        }
    }
    
    func addTransition(){
        let transition = CATransition()
        transition.duration = 0.7
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        imgStream!.layer.add(transition, forKey: kCATransition)
    }
    
    func addTransitionLeft(){
        let transition = CATransition()
        transition.duration = 0.7
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        imgStream!.layer.add(transition, forKey: kCATransition)
    }
}
