//
//  StreamViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 29/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class StreamViewController: MSMessagesAppViewController {

    // MARK:- UI Elements
    @IBOutlet weak var lblStreamTitle : UILabel!
    @IBOutlet weak var btnNextStream : UIButton!
    @IBOutlet weak var btnPreviousStream : UIButton!
    @IBOutlet weak var lblStreamName : UILabel!
    @IBOutlet weak var lblStreamDesc : UILabel!
    @IBOutlet weak var imgStream : UIImageView!
    @IBOutlet weak var imgGradient : UIImageView!
    @IBOutlet weak var collectionStreams : UICollectionView!
    
    // MARK: -Variables
    var arrStream = [StreamDAO]()
    var currentStreamIndex : Int!
    var arrContentData : NSMutableArray = NSMutableArray()
    
    // MARK: - Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareLayout()
    }
    
    // MARK: -PrepareLayout
    func prepareLayout() {
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        imgGradient.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        imgGradient.addGestureRecognizer(swipeLeft)
        
        if currentStreamIndex == 0 {
            btnPreviousStream.isEnabled = false
        }
        if currentStreamIndex == arrStream.count-1 {
            btnNextStream.isEnabled = false
        }
        dummyArrData()
        loadViewForUI()
    }
    
   @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if currentStreamIndex !=  arrStream.count-1 {
                    self.nextImageLoad()
                }
                print("Swiped left")
                break
                
            case UISwipeGestureRecognizerDirection.right:
                if currentStreamIndex != 0 {
                    self.previousImageLoad()
                }
                break
                
            default:
                break
            }
        }
    }

    // MARK: -Dummmy Data
    func dummyArrData(){
        for v in 1...5 {
            let tempDict = NSMutableDictionary()
            tempDict.setObject("food\(v)", forKey: "img" as NSCopying)
            tempDict.setObject("FOOD \(v)", forKey: "title" as NSCopying)
            self.arrContentData.add(tempDict)
        }
        self.collectionStreams.reloadData()
    }
    //-------------------------//
    
    // MARK: -Load Data in UI
    func loadViewForUI(){
        let stream = self.arrStream[currentStreamIndex]
       // self.imgStream.image = stream.imgCover
        self.lblStreamTitle.text = stream.Title
        self.lblStreamName.text = stream.Title
        self.lblStreamDesc.text = "Posted By Jon"
    }
    
    // MARK: -Enable/Disable - Next/Previous Button
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
    
    // MARK: - Action Methods
    @IBAction func btnNextAction(_ sender:UIButton){
        nextImageLoad()
    }
    
    func nextImageLoad(){
        if(currentStreamIndex < arrStream.count-1) {
            currentStreamIndex = currentStreamIndex + 1
        }
        btnEnableDisable()
        loadViewForUI()
        self.addRightTransitionImage(imgV: self.imgStream)
    }
    
    func previousImageLoad(){
        if currentStreamIndex != 0{
            currentStreamIndex =  currentStreamIndex - 1
        }
        btnEnableDisable()
        loadViewForUI()
        self.addLeftTransitionImage(imgV: self.imgStream)
    }
    
    @IBAction func btnPreviousAction(_ sender:UIButton){
      previousImageLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension StreamViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrContentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : StreamCollectionViewCell = self.collectionStreams.dequeueReusableCell(withReuseIdentifier: iMgsSegue_StreamCollection, for: indexPath) as! StreamCollectionViewCell
        let tempDict : NSMutableDictionary = self.arrContentData.object(at: indexPath.row) as! NSMutableDictionary
        if(indexPath.row == 0){
            cell.viewAddContent.isHidden = false
        } else {
            cell.viewAddContent.isHidden = true
            cell.imgFood.image = UIImage(named: "\(tempDict.object(forKey: "img") as! String)")
            cell.lblFoodName.text = "\(tempDict.object(forKey: "title") as! String)"
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.row == 0) {
            return CGSize(width: self.collectionStreams.frame.size.width/2-15, height: self.collectionStreams.frame.size.width/2-50)
        }
        return CGSize(width: self.collectionStreams.frame.size.width/2-15, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionStreams.deselectItem(at: indexPath, animated:false)
        
        let obj : StreamContentViewController = self.storyboard!.instantiateViewController(withIdentifier: iMsgSegue_StreamContent) as! StreamContentViewController
        self.addRippleTransition()
        
        
        obj.currentStreamIndex = currentStreamIndex
        obj.currentContentIndex  = indexPath.row
        obj.arrStream = arrStream
        obj.arrContentData = arrContentData
        
        self.present(obj, animated: false, completion: nil)
    }
    
}
