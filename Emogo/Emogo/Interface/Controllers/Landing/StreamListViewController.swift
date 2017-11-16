//
//  StreamListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout

class StreamListViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var streamCollectionView: UICollectionView!
    
    // Varibales
     var arrayStreams = [StreamDAO]()
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Prepare Layouts
    func prepareLayouts(){
        self.configureLandingNavigation()
        // Attach datasource and delegate
        self.streamCollectionView.dataSource  = self
        self.streamCollectionView.delegate = self
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.columnCount = 2
        // Collection view attributes
        self.streamCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.streamCollectionView.alwaysBounceVertical = true
        self.streamCollectionView.collectionViewLayout = layout
        self.prepareDummyData()
    }

    // MARK: - Class Methods

    func prepareDummyData(){
        for i in 1..<8 {
            let obj = StreamDAO(title: "Cover Image1", image: UIImage(named: "image\(i)")!)
            self.arrayStreams.append(obj)
        }
        self.streamCollectionView.reloadData()
        
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

// MARK: - EXTENSION
// MARK: - Delegate and Datasource

extension StreamListViewController:UICollectionViewDelegate,UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
    

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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/2.0
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}


