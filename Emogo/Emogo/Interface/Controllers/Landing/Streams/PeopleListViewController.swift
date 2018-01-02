//
//  PeopleListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class PeopleListViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var peopleCollectionView: UICollectionView!
    
    
    var arrayColab:[CollaboratorDAO]!
    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.peopleCollectionView.reloadData()
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        self.title = "Collaborator List"
        self.configureNavigationWithTitle()
    }
    

    // MARK: -  Action Methods And Selector

    // MARK: - Class Methods

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension PeopleListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrayColab == nil {
            return 0
        }else {
            return arrayColab.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_AddCollaboratorsView, for: indexPath) as! AddCollaboratorsViewCell
        let collaborator = self.arrayColab[indexPath.row]
        cell.lblTitle.text = collaborator.name
        cell.imgSelect.isHidden = true
        if !collaborator.imgUser.isEmpty {
            cell.imgCover.layer.cornerRadius = cell.imgCover.frame.size.width/2.0
            cell.imgCover.layer.masksToBounds = true
        }else {
            cell.imgCover.setImage(string: collaborator.name, color: UIColor.colorHash(name: collaborator.name), circular: true)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
        return CGSize(width: itemWidth, height: 100)
    }
    
    
}
