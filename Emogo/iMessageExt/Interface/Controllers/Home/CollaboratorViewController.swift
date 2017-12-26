//
//  CollaboratorViewController.swift
//  iMessageExt
//
//  Created by Sushobhit on 05/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Messages

class CollaboratorViewController: MSMessagesAppViewController {

    //MARK: - UI Elements
    @IBOutlet weak var collectionCollaborator   : UICollectionView!
    @IBOutlet weak var btnBack                  : UIButton!
    @IBOutlet weak var lblTitle                 : UILabel!
    
    //MARK: - Variables
    var arrCollaborator                         : [CollaboratorDAO]!
    var strTitle                                : String!
    
    //MARK: - Life-Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionProperties()
        self.prepareLayout()
        setupCollectionProperties()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Life-Cycle methods
    func prepareLayout() {
        self.btnBack.transform = self.btnBack.transform.rotated(by: -CGFloat(Double.pi / 2))
        lblTitle.text = "\(strTitle!)"
    }
    
    //MARK: - Setup collection Properties
    func setupCollectionProperties() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.itemSize = CGSize(width: self.collectionCollaborator.frame.size.width/3, height: 100)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 10
        collectionCollaborator!.collectionViewLayout = layout
        
        collectionCollaborator.delegate = self
        collectionCollaborator.dataSource = self
    }
    
    //MARK: - Action Methods
    @IBAction func btnClose(_ sender:UIButton){
     self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Extension Collection Delegate
extension CollaboratorViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrCollaborator.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CollaboratorCollectionViewCell = self.collectionCollaborator.dequeueReusableCell(withReuseIdentifier: iMgsSegue_CollaboratorCollectionCell, for: indexPath) as! CollaboratorCollectionViewCell
        cell.prepareLayout(content: self.arrCollaborator[indexPath.row])
        
        return cell
    }
}
