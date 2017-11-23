//
//  HomeViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 11/17/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class HomeViewController: MSMessagesAppViewController,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate {

    // MARK:- UI Elements
    @IBOutlet weak var collectionStream : UICollectionView!
    @IBOutlet weak var searchView : UIView!
    @IBOutlet weak var searchText : UITextField!
    @IBOutlet weak var btnFeature : UIButton!
    
    // Varibales
    var arrayStreams = [StreamDAO]()
    
    fileprivate let arrImages = ["feverateDeselected","feverateDeselected","featutreDeselected","emogoDeselected","tredingDeselected","peopleDeselected"]
    fileprivate let arrImagesSelected = ["feverateSelected","feverateSelected","featutreSelected","emogoSelected","tredingSelected","peopleSelected"]
    
    
    // MARK:- Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestMessageScreenChangeSize), name: NSNotification.Name(rawValue: iMsgNotificationManageScreen), object: nil)
        
        prepareLayout()
    }
    
    @objc func requestMessageScreenChangeSize(){
        self.perform(#selector(self.changeUI), with: nil, afterDelay: 0.2)
    }
    
    @objc func changeUI(){
        if(SharedData.sharedInstance.isMessageWindowExpand) {
            SharedData.sharedInstance.showPager(controller: self)
             btnFeature.tag = 1
        }else{
            SharedData.sharedInstance.hidePager(controller: self)
             btnFeature.tag = 0
        }
    }

    func prepareLayout() {
        self.searchView.layer.cornerRadius = 15
        self.searchView.clipsToBounds = true
       
        prepareDummyData()
    }
    
    func prepareDummyData(){
        for i in 1..<8 {
            let obj = StreamDAO(title: "Cover Image \(i)", image: UIImage(named: "image\(i)")!)
            self.arrayStreams.append(obj)
        }
        self.collectionStream.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.itemSize = CGSize(width: self.collectionStream.frame.size.width/2-15, height: 100)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 10
        collectionStream!.collectionViewLayout = layout
        
        collectionStream.delegate = self
        collectionStream.dataSource = self
        
        collectionStream.reloadData()
        
         SharedData.sharedInstance.preparePagerFrame(frame: CGRect(x: 0, y: self.view.frame.size.height - 260, width: self.view.frame.size.width, height: 220), controller: self)

        if(SharedData.sharedInstance.isMessageWindowExpand) {
            SharedData.sharedInstance.showPager(controller: self)
            btnFeature.tag = 1
        }

    }
    
    // MARK:- Action methods
    @IBAction func btmnSearchAction(_ sender: UIButton){
       self.searchText.resignFirstResponder()
        
    }
    
    @IBAction func btnFeaturedTap(_ sender: UIButton){
        if(btnFeature.tag == 1){
              SharedData.sharedInstance.hidePager(controller: self)
            btnFeature.tag = 0
        } else {
            if(SharedData.sharedInstance.isMessageWindowExpand) {
                SharedData.sharedInstance.showPager(controller: self)
                btnFeature.tag = 1
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyle), object: nil)
            }
        }
    }
    
    // MARK:- collection-view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayStreams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : HomeCollectionViewCell = self.collectionStream.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        let stream = self.arrayStreams[indexPath.row]
        cell.prepareLayouts(stream: stream)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK:- TextField delegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(!SharedData.sharedInstance.isMessageWindowExpand) {
            NotificationCenter.default.post(name: NSNotification.Name(iMsgNotificationManageRequestStyle), object: nil)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    

}


extension HomeViewController : FSPagerViewDataSource,FSPagerViewDelegate {
    
    // MARK:- FSPagerViewDataSource
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return arrImages.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        if(index == pagerView.currentIndex){
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = UIImage(named: self.arrImagesSelected[index])
            cell.addLayerInImageView(isTrue : true)
        }
        else {
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
            cell.imageView?.center = cell.contentView.center
            cell.imageView?.image = UIImage(named: self.arrImages[index])
        }
        
        cell.imageView?.tag = index
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)!/2
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        pagerView.scrollToItem(at: index, animated: true)
        changeCellImageAnimationt(index, pagerView: pagerView)
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        changeCellImageAnimationt(pagerView.currentIndex, pagerView: pagerView)
    }
    
    func changeCellImageAnimationt(_ sender : Int, pagerView: FSPagerView){
        for section in 0 ..< pagerView.numberOfSections {
            for row in 0 ..< pagerView.numberOfItems{
                let indexPath = NSIndexPath(row: row, section: section)
                if let sel = pagerView.collectionView.cellForItem(at: indexPath as IndexPath){
                    if(sender == (sel as! FSPagerViewCell).imageView?.tag){
                        (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
                        (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                        (sel as! FSPagerViewCell).imageView?.image = UIImage(named: self.arrImagesSelected[indexPath.row])
                        (sel as! FSPagerViewCell).addLayerInImageView(isTrue : true)
                    } else {
                        (sel as! FSPagerViewCell).imageView?.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
                        (sel as! FSPagerViewCell).imageView?.center = (sel as! FSPagerViewCell).contentView.center
                        (sel as! FSPagerViewCell).imageView?.image = UIImage(named: self.arrImages[indexPath.row])
                    }
                    (sel as! FSPagerViewCell).imageView?.layer.cornerRadius = ((sel as! FSPagerViewCell).imageView?.frame.size.width)!/2
                }
            }
        }
    }
}
