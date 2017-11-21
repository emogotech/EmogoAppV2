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

    // Varibales
    var arrayStreams = [StreamDAO]()
    
    // MARK:- UI Elements
    @IBOutlet weak var collectionStream : UICollectionView!
    @IBOutlet weak var searchView : UIView!
    @IBOutlet weak var searchText : UITextField!
    
    // MARK:- Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareLayout()
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
    }
    
    // MARK:- Action methods
    @IBAction func btmnSearchAction(_ sender: UIButton){
        self.searchText.resignFirstResponder()
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
