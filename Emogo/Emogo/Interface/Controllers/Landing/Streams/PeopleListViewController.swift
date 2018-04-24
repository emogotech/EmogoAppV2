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
    
    
    var arrayColab = [CollaboratorDAO]()
    var streamID:String!
    var streamNavigate:String!
    var currentIndex:Int!
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
        if self.currentIndex != nil {
            ContentList.sharedInstance.mainStreamNavigate = streamNavigate
            ContentList.sharedInstance.mainStreamIndex = currentIndex
        }
        getColabListForStream()
    }

    // MARK: -  Action Methods And Selector

    // MARK: - Class Methods

    func getColabListForStream(){
        HUDManager.sharedInstance.showHUD()
        APIServiceManager.sharedInstance.apiForGetStreamColabList(streamID: self.streamID) { (arrayColab, errorMsg) in
           HUDManager.sharedInstance.hideHUD()
            if (errorMsg?.isEmpty)! {
                self.arrayColab = arrayColab!
                self.arrayColab.sort {
                    $0.name < $1.name
                }
            self.peopleCollectionView.reloadData()
            } else {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
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


extension PeopleListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
    {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return arrayColab.count
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
            cell.imgCover.setImage(string: collaborator.name, color: UIColor(r: 0, g: 173, b: 243), circular: true)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
        return CGSize(width: itemWidth, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collaborator = self.arrayColab[indexPath.row]
        if collaborator.userID != "" {
            let people = PeopleDAO(peopleData:[:])
            people.fullName = collaborator.name
            people.userProfileID = collaborator.userID
          //  people.userProfileID =
            let obj:ViewProfileViewController = kStoryboardStuff.instantiateViewController(withIdentifier: kStoryboardID_UserProfileView) as! ViewProfileViewController
            obj.objPeople = people
            self.navigationController?.push(viewController: obj)
        }else{
            self.showToast(strMSG: "Seems user is not registered with Emogo yet!")
        }

    }
    
    
}
