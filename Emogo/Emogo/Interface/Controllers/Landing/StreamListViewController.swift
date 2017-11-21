//
//  StreamListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class StreamListViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var streamCollectionView: UICollectionView!
    
    // Varibales
     var arrayStreams = [StreamDAO]()
    private let headerNib = UINib(nibName: "StreamSearchCell", bundle: Bundle.main)

    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureLandingNavigation()
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        // Attach datasource and delegate
        self.streamCollectionView.dataSource  = self
        self.streamCollectionView.delegate = self
        
        if let layout: IOStickyHeaderFlowLayout = self.streamCollectionView.collectionViewLayout as? IOStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 60.0)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: layout.itemSize.height)
            layout.parallaxHeaderAlwaysOnTop = false
            layout.disableStickyHeaders = true
            self.streamCollectionView.collectionViewLayout = layout
        }
        
        self.streamCollectionView.register(self.headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader, withReuseIdentifier: kHeader_StreamHeaderView)

        self.prepareDummyData()
    }
    
    
    // MARK: -  Action Methods And Selector
    
    override func btnCameraAction() {
        let obj:CameraViewController = self.storyboard?.instantiateViewController(withIdentifier: kStoryboardID_CameraView) as! CameraViewController
        self.navigationController?.push(viewController: obj)
    }
    
    override func btnHomeAction() {
        
    }
    
    override func btnMyProfileAction() {
        
    }

    

    // MARK: - Class Methods


    func prepareDummyData(){
        for i in 1..<8 {
            let obj = StreamDAO(title: "Cover Image \(i)", image: UIImage(named: "image\(i)")!)
            self.arrayStreams.append(obj)
        }
        self.streamCollectionView.reloadData()
        
    }
    
    // MARK: - API Methods

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - EXTENSION
// MARK: - Delegate and Datasource
extension StreamListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayStreams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_StreamCell, for: indexPath) as! StreamCell
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        let stream = self.arrayStreams[indexPath.row]
        cell.prepareLayouts(stream: stream)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0 - 10.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case IOStickyHeaderParallaxHeader:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kHeader_StreamHeaderView, for: indexPath) as! StreamSearchCell
            return cell
        default:
            assert(false, "Unexpected element kind")
        }
        
    }

}


